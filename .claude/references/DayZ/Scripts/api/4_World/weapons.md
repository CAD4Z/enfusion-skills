`4_World` — оружие. Weapon FSM, отдача, магазины, аттачменты. Источники: `entities/firearms/`, `classes/weapons/`, `classes/recoilbase/`

### Weapon_Base

Иерархия: `Weapon` (C++) → `Weapon_Base`. Все конкретные виды оружия наследуют `Weapon_Base`.

#### Инициализация

Конструктор: флаги (`m_isJammed`, `m_BayonetAttached`...), `simpleHiddenSelections` для патронов/магазинов, `InitWeaponLength()`, `InitReliability()`, затем **`InitStateMachine()`**.

`InitStateMachine()` — **пустой в Weapon_Base**, обязателен к переопределению. Здесь определяются состояния FSM и переходы.

`EEInit()` — на сервере вызывает `AssembleGun()` (загрузка боеприпасов из хранилища в состояние FSM).

#### Состояния и запросы

| Метод | Описание |
|-------|----------|
| `IsCharged()` | Патрон в патроннике |
| `IsJammed()` | Заклинивание |
| `IsWeaponOpen()` | Затвор открыт |
| `CanProcessWeaponEvents()` | FSM активен |
| `IsIdle()` | FSM в стабильном состоянии |
| `GetCurrentState()` | Текущий `WeaponStateBase` |

#### FSM интерфейс

| Метод | Описание |
|-------|----------|
| `ProcessWeaponEvent(WeaponEventBase e)` | Диспатч события → синхронизация |
| `ProcessWeaponAbortEvent(WeaponEventBase e)` | Прерывание |
| `HasActionAbility(int action, int type)` | Поддерживает ли операцию |
| `GetAbilityCount()` / `GetAbility(int)` | Список возможностей |

#### Стрельба и заклинивание

| Метод | Описание |
|-------|----------|
| `EEFired(int muzzle, int mode, string ammo)` | Выстрел — партиклы, нагрев |
| `JamCheck(int muzzleIndex)` | Проверка заклинивания (синхр. random) |
| `GetChanceToJam()` | Шанс по уровню здоровья |
| `InitReliability(out array<float>)` | Загрузка шансов из конфига |

#### Создание оружия с боеприпасами (статические)

```
Weapon_Base.CreateWeaponWithAmmo(string weaponType, string magazineType, int flags)
SpawnAmmo(string magazineType, int flags)
SpawnAttachedMagazine(string magazineType, int flags)
```

`WeaponWithAmmoFlags`: `CHAMBER`, `CHAMBER_RNG`, `CHAMBER_RNG_SPORADIC`, `QUANTITY_RNG`, `MAX_CAPACITY_MAG`

---

### Weapon FSM

HFSM: `WeaponFSM extends HFSMBase<WeaponStateBase, WeaponEventBase, WeaponActionBase, WeaponGuardBase>`.

#### WeaponStateBase

| Метод | Описание |
|-------|----------|
| `OnEntry(WeaponEventBase e)` | Вход в состояние |
| `OnUpdate(float dt)` | Тик |
| `OnAbort(WeaponEventBase e)` | Прерывание |
| `OnExit(WeaponEventBase e)` | Выход |
| `IsIdle()` | Стабильное состояние |
| `HasFSM()` | Есть вложенная машина |

Состояния вкладываемые — состояние с собственным `WeaponFSM` работает как композитное.

#### WeaponStableState — базовый для idle-состояний

| Метод | Описание |
|-------|----------|
| `HasBullet()` | Патрон в патроннике |
| `HasMagazine()` | Магазин присоединён |
| `IsJammed()` | Заклинивание |
| `IsWeaponOpen()` | Затвор открыт |
| `IsRepairEnabled()` | Разрешить ValidateAndRepair |

`OnEntry` синхронизирует: jammed, charged, open, animation state.

#### Определение переходов

```
m_fsm.AddTransition(new WeaponTransition(srcState, event, dstState, action, guard));
```

#### Группы состояний

| Группа | Состояния |
|--------|-----------|
| Стрельба | `WeaponFire`, `WeaponFireAndChamberNext`, `WeaponFireLast` |
| Заряжание | `WeaponChambering`, `WeaponChamberingLooped`, `RifleChambering` |
| Магазин | `WeaponAttachMagazine`, `WeaponDetachingMag`, `WeaponReplacingMagAndChamberNext` |
| Извлечение | `WeaponEjectBullet`, `RifleEjectCasing`, `WeaponReChamber` |
| Заклинивание | `WeaponStateJammed`, `WeaponUnjamming` |
| Визуальные | `BulletShow`, `BulletHide`, `MagazineShow`, `MagazineHide` |

#### WeaponEventID

`MECHANISM`, `TRIGGER`, `TRIGGER_JAM`, `TRIGGER_AUTO_START/END`, `LOAD1_BULLET`, `CONTINUOUS_LOADBULLET_START/END`, `UNJAM`, `ATTACH_MAGAZINE`, `DETACH_MAGAZINE`, `SWAP_MAGAZINE`, `HUMANCOMMAND_ACTION_FINISHED/ABORTED`, `SET_NEXT_MUZZLE_MODE`, `ANIMATION_EVENT`

#### ValidateAndRepair

После каждого перехода, если текущее стабильное состояние `IsRepairEnabled()=true` — проверяет соответствие физического состояния (патронник/магазин) и декларации FSM. При рассинхроне — принудительная коррекция.

---

### Отдача (RecoilBase)

Создаётся за выстрел, живёт до конца перезарядки.

#### Параметры (задаются в `Init()`)

| Поле | Описание |
|------|----------|
| `m_MouseOffsetRangeMin/Max` | Диапазон случайного угла (градусы) |
| `m_MouseOffsetDistance` | Суммарное смещение мыши |
| `m_MouseOffsetRelativeTime` | Доля времени перезарядки для мыши (0..1) |
| `m_HandsOffsetRelativeTime` | Доля для анимации рук |
| `m_CamOffsetRelativeTime` | Доля для Z-смещения камеры |
| `m_CamOffsetDistance` | Расстояние Z-смещения |
| `m_HandsCurvePoints` | Bezier-точки анимации рук |

#### Модификаторы

`GetRecoilModifier(Weapon_Base)` читает `weapon.GetPropertyModifierObject().m_RecoilModifiers` → вектор `(x_scale, y_scale, cam_scale)`. Глушители/приклады модифицируют отдачу через этот вектор.

#### Три системы смещения (каждый кадр)

1. `ApplyMouseOffset()` — плавное движение курсора к цели
2. `ApplyHandsOffset()` — Bezier-кривая для рук
3. `ApplyCamOffset()` — Z-push камеры с EaseOutBack

---

### Магазины (Magazine)

`Magazine extends InventoryItemSuper`. Алиас: `Magazine_Base`.

#### Нативные методы (C++)

| Метод | Описание |
|-------|----------|
| `GetAmmoCount()` / `ServerSetAmmoCount(int)` | Текущее/установить кол-во |
| `ServerAcquireCartridge(out float dmg, out string type)` | Извлечь патрон (сервер) |
| `ServerStoreCartridge(float dmg, string type)` | Вставить патрон (сервер) |
| `GetCartridgeAtIndex(int, out float, out string)` | Патрон по индексу |

#### Скриптовые методы

| Метод | Описание |
|-------|----------|
| `GetAmmoMax()` | Максимум (из конфига `count`) |
| `CanAddCartridges(int count)` | Есть место |
| `IsCompatiableAmmo(ItemBase)` | Совместимый тип боеприпаса |
| `GetChanceToJam()` | Шанс заклинивания по здоровью |
| `CanBeSplit()` | Можно разделить (count > 1) |

---

### Аттачменты оружия

- `ButtstockBase` → `OnWasAttached` вызывает `parent.SetButtstockAttached(true)`
- `SuppressorBase` — партиклы дула, нагрев через `ItemBase.HasMuzzle()=true`
- `PoweredOptic_Base extends ItemBase` — прицелы с батареей (NVG)
