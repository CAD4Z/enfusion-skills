`4_World` — транспорт. CarScript (машины), BoatScript (лодки). Источники: `entities/vehicles/`

### CarScript

Иерархия: `Car` (C++) → `CarScript`. Все машины наследуют `CarScript`.

#### Состояние (ключевое)

| Категория | Переменные |
|-----------|-----------|
| Жидкости | `m_FuelAmmount`, `m_CoolantAmmount`, `m_OilAmmount`, `m_BrakeAmmount` |
| Здоровье компонентов | `m_EngineHealth`, `m_RadiatorHealth`, `m_FuelTankHealth`, `m_BatteryHealth`, `m_PlugHealth` (float, -1 = отсутствует) |
| Физика | `m_MomentumPrevTick`, `m_VelocityPrevTick` |
| Урон | `m_dmgContactCoef = 0.058` — множитель импульс→урон |

#### Цикл симуляции (`EOnPostSimulate`, каждый физический тик)

Сервер, каждые `CARS_FLUIDS_TICK`:
1. `CarPartsHealthCheck()` — обновление здоровья компонентов
2. Проверка остановки двигателя: разрушен, нет топлива, здоровье ≤ 0
3. `CheckVitalItem()` — свеча зажигания/накаливания
4. Утечки при работающем двигателе:
   - Радиатор health < 0.5 → утечка охлаждающей жидкости
   - Бак < DAMAGED → утечка топлива
   - Двигатель < DAMAGED → утечка тормозов/масла
5. RPM ≥ Redline → случайный урон двигателю
6. Охлаждающая < 0.5 → урон двигателю
7. Затопление: позиция двигателя под водой > `DROWN_ENGINE_THRESHOLD` → `DROWN_ENGINE_DAMAGE × dt`

#### Система столкновений

`OnContact(zoneName, localPos, other, Contact)` → записывает в `m_ContactCache` (первый контакт на зону за кадр).

`CheckContactCache()` (из EOnPostSimulate):
```
dmg = |impulse × m_dmgContactCoef|
crewDmgBase = |(impulse / mass) × 1000 × m_dmgContactCoef|

dmg < CARS_CONTACT_DMG_MIN → пропуск
dmg < CARS_CONTACT_DMG_THRESHOLD → лёгкий удар, NO_TRANSFER
dmg >= threshold → тяжёлый удар, DamageCrew()
```

`DamageCrew(float dmg)`:
- `dmg > CARS_CONTACT_DMG_KILLCREW` → мгновенная смерть
- Иначе: интерполяция шока (50–150) и HP урона (2–100)

`m_dmgContactCoef` — переопределить в конструкторе подкласса для настройки чувствительности.

#### Запуск двигателя

`CheckOperationalRequirements()` → `ECarOperationalState` (битовая маска):
- `RUINED` — двигатель/машина разрушены
- `NO_FUEL` — нет топлива
- `NO_BATTERY` — нет/сломана/разряжена батарея
- `NO_IGNITER` — нет свечи зажигания

#### Переопределяемые компоненты

| Метод | Описание | По умолчанию |
|-------|----------|-------------|
| `IsVitalCarBattery()` | Нужна батарея | `true` |
| `IsVitalSparkPlug()` | Нужна свеча | `true` |
| `IsVitalGlowPlug()` | Нужна свеча накаливания | `false` |
| `IsVitalRadiator()` | Нужен радиатор | `true` |
| `IsVitalFuelTank()` | Нужен бак | `true` |
| `GetBatteryConsumption()` | Расход батареи на старт | 15 |

#### Callback'и двигателя

| Метод | Описание |
|-------|----------|
| `OnBeforeEngineStart()` | return false = блокировать старт |
| `OnEngineStart()` | Расход батареи, свет, звук |
| `OnEngineStop()` | Обновление батареи, свет, звук |
| `OnIgnition()` | Поворот ключа — звуки ошибок при неисправности |
| `OnDriverExit(Human)` | Остановка двигателя если не на нейтрали |
| `OnGearChanged(int new, int old)` | Смена передачи |
| `OnFluidChanged(CarFluid, float new, float old)` | Изменение жидкости |
| `OnBrakesPressed/Released()` | Тормоз |

#### Аттачменты

`EEItemAttached/Detached` обрабатывает: `CarBattery`, `SparkPlug`, `GlowPlug`, `CarRadiator`, отражатели. Снятие радиатора → утечка. Снятие батареи/свечи → остановка двигателя.

#### Экипаж

| Метод | Описание |
|-------|----------|
| `MarkCrewMemberUnconscious(int idx)` | Остановка если водитель |
| `MarkCrewMemberDead(int idx)` | Остановка если водитель |
| `CanReceiveAttachment(EntityAI, int)` | Блокировка колёс в движении |
| `CanReleaseAttachment(EntityAI)` | Блокировка при работающем двигателе + движении |
| `OnVehicleJumpOutServer(...)` | Урон при прыжке на скорости |
| `DetectFlipped(VehicleFlippedContext)` | Обнаружение переворота |

#### Свет

| Метод | Описание |
|-------|----------|
| `CreateFrontLight()` | Переопределить → свой класс фар |
| `CreateRearLight()` | Переопределить → свой класс задних фонарей |
| `UpdateLights(int gear)` | Обновление состояния |
| `OnBeforeLightOn()` | Проверка батареи |
| `ToggleHeadlights()` | Переключение фар |

#### Звук

`float OnSound(CarSoundCtrl ctrl, float oldValue)` — переопределить для модификации звуковых контроллеров.

---

### BoatScript

Иерархия: `Boat` (C++) → `BoatScript`.

#### Отличия от CarScript

- Только топливо (нет охлаждающей, масла, тормозов)
- `EBoatOperationalState`: `OK`, `RUINED`, `NO_FUEL`, `NO_IGNITER`
- Нет проверки батареи в `OnBeforeEngineStart()`
- Система деградации: `DecayHealthTick()` каждые 10с — урон `0.017`, если нет игрока в 300м или флага территории в 100м
- Система всплесков: отслеживание полёта (`m_SplashIncoming`) → звук при контакте с водой
- 4 водных эффекта: перед, зад, левый/правый борт
- Fade-in/fade-out звука двигателя

`GetVehicleType()` → `"VehicleTypeBoat"` (у CarScript → `"VehicleTypeCar"`).

#### Переопределяемые

| Метод | Описание |
|-------|----------|
| `GetAnimInstance()` | Вариант анимации |
| `GetTransportCameraDistance()` | Дистанция камеры 3-го лица |
| `GetTransportCameraOffset()` | Смещение камеры |
| `CrewCanGetThrough(int posIdx)` | Доступ к позициям |
| `CanReachSeatFromSeat(int, int)` | Пересадка |
