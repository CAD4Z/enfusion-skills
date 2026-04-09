`4_World` — существа. Источники: `entities/creatures/infected/`, `entities/creatures/animals/`

### ZombieBase (заражённые)

Иерархия: `DayZInfected` (3_Game) → `ZombieBase` → `ZombieMaleBase` / `ZombieFemaleBase` → конкретные классы.

#### Синхронизируемые переменные

| Переменная | Тип | Описание |
|-----------|-----|----------|
| `m_MindState` | int (-1..4) | CALM / ALERTED / DISTURBED / CHASE / FIGHT |
| `m_OrientationSynced` | int (0–359) | Квантизованный yaw (каждые 2с или при >30° разницы) |
| `m_MovementSpeed` | float (-1..3) | Скорость передвижения |
| `m_IsCrawling` | bool | Ползание |

#### CommandHandler — основной цикл поведения

```
CommandHandler(dt, commandID, commandFinished)
 1. ModCommandHandlerBefore() → return true = полный перехват
 2. HandleDeath() → StartCommand_Death(type, dir)
 3. HandleMove() / HandleOrientation() → sync
 4. Если команда завершена → StartCommand_Move()
 5. ModCommandHandlerInside() → mid-flow хук
 6. HandleCrawlTransition()
 7. HandleDamageHit()
 8. HandleVault()
 9. HandleMindStateChange() → смена idle-анимации
10. FightLogic() → ChaseAttackLogic / FightAttackLogic → StartCommand_Attack()
11. ModCommandHandlerAfter() → post-flow хук
```

#### Переопределяемые методы

| Метод | Описание |
|-------|----------|
| `ModCommandHandlerBefore(float, int, bool)` | Полный перехват до стандартной логики |
| `ModCommandHandlerInside(float, int, bool)` | Хук в середине |
| `ModCommandHandlerAfter(float, int, bool)` | Хук в конце |
| `IsZombieMilitary()` | `false`, переопределить для военных |
| `IsMale()` | `true`, переопределить для женских |
| `CanBeBackstabbed()` | `true` |
| `EvaluateDeathAnimation(source, component, ammo, out anim, out dir)` | Логика анимации смерти |
| `GetHitComponentForAI()` | Зоны попадания из конфига |

#### Боевая логика

При `COMMANDID_MOVE` + CHASE/FIGHT: получить цель из `DayZInfectedInputController.GetTargetEntity()` → `CanAttackToPosition()` → выбор атаки через `GetDayZInfectedType().ChooseAttack(group, distance, pitch)` → `StartCommand_Attack()`.

При попадании: `DamageSystem.CloseCombatDamageName()`. Заблокированные атаки → `"Dummy_Light"`.

#### Звуковой автомат (HandleSoundEvents)

| MindState | Звук |
|-----------|------|
| CALM | `MINDSTATE_CALM_MOVE` |
| ALERTED | `MINDSTATE_ALERTED_MOVE` |
| DISTURBED | `MINDSTATE_DISTURBED_IDLE` |
| CHASE | `MINDSTATE_CHASE_MOVE` |

---

### AnimalBase (животные)

Иерархия: `DayZAnimal` (3_Game) → `AnimalBase` → конкретные классы.

Большая часть логики в C++ `DayZAnimal`. Скриптовая часть тонкая.

#### Ключевые методы

| Метод | Описание |
|-------|----------|
| `DeathUpdate()` | Спаун мёртвого предмета (`GetDeadItemName()`), перенос свойств, `DeleteSafe()` |
| `IsSelfAdjustingTemperature()` | `return IsAlive()` — саморегуляция температуры |
| `RegisterHitComponentsForAI()` | Зоны попадания и приоритетные веса |
| `CaptureSound()` / `ReleaseSound()` | Звуки для ловушек |
| `IsDanger()` | `true` для хищников (Wolf), `false` для добычи |

---

### AreaDamage (зоны урона)

Источники: `classes/areadamage/areadamagenew/`

#### Архитектура

```
AreaDamageManager (оркестратор)
 ├── AreaDamageTriggerBase (физический триггер в мире)
 └── AreaDamageComponent (стратегия расчёта урона)
```

#### Типы компонентов (`SetDamageComponentType`)

| Тип | Описание |
|-----|----------|
| `BASE` | Фиксированная зона попадания |
| `HITZONE` | Случайная зона из `SetHitZones()` |
| `RAYCASTED` | Raycast от точек модели → определение зоны |

#### Конкретные классы

| Класс | Поведение |
|-------|-----------|
| `AreaDamageOnce` | Один раз при входе |
| `AreaDamageOnceDeferred` | Один раз после задержки `m_DeferDuration` |
| `AreaDamageLooped` | Каждые `m_LoopInterval` секунд, пока внутри |
| `AreaDamageLoopedDeferred` | Цикличный с начальной задержкой |
| `AreaDamageLoopedDeferred_NoVehicle` | То же, но пропускает пассажиров |

#### Паттерн использования

```
AreaDamageLooped dmg = new AreaDamageLooped(parentEntity);
dmg.SetExtents("-0.5 0 -0.5", "0.5 0.5 0.5");
dmg.SetAmmoName("BarbedWireDamage");
dmg.SetDamageType(DamageType.CUSTOM);
dmg.SetDamageableTypes({DayZPlayer, ZombieBase});
dmg.SetLoopInterval(1.0);
dmg.SetDamageComponentType(AreaDamageComponentTypes.HITZONE);
dmg.Spawn();
// ...
dmg.Destroy();
```

---

### ScriptedLightBase (освещение)

Источники: `entities/scriptedlightbase.c`. Работает **только на клиенте**.

#### Иерархия

```
ScriptedLightBase extends EntityLightSource
 ├── PointLightBase → FireplaceLight, TorchLight, PersonalLight...
 └── SpotLightBase → FlashlightLight, HeadTorchLight...
```

#### Создание

```
ScriptedLightBase.CreateLight(MyLight, position, fadeInSeconds);
ScriptedLightBase.CreateLightAtObjMemoryPoint(MyLight, obj, "LightPoint", "LightTarget");
light.AttachOnObject(parentObj, localPos, localOri);
```

#### Настройка (в конструкторе подкласса)

| Метод | Описание |
|-------|----------|
| `SetRadiusTo(float)` | Радиус |
| `SetBrightnessTo(float)` | Яркость |
| `SetDiffuseColor(r,g,b)` | Цвет |
| `SetAmbientColor(r,g,b)` | Ambient |
| `SetCastShadow(bool)` | Тени (дорого) |
| `SetFlickerAmplitude/Speed(float)` | Мерцание |
| `SetDancingShadowsAmplitude/MovementSpeed(float)` | Танцующие тени |
| `SetVisibleDuringDaylight(bool)` | Видимость днём |
| `SetBlinkingSpeed(float)` | Синусоидальное мигание |

#### Управление

| Метод | Описание |
|-------|----------|
| `FadeBrightnessTo(value, time)` | Плавная яркость |
| `FadeRadiusTo(value, time)` | Плавный радиус |
| `FadeIn(time)` / `FadeOut(time)` | Появление / исчезновение |
| `SetLifetime(seconds)` | Автоудаление |
| `Destroy()` | Безопасное удаление |

#### Хук

```
override void OnFrameLightSource(IEntity other, float timeSlice)
{
    // Каждый кадр — динамическое поведение
}
```
