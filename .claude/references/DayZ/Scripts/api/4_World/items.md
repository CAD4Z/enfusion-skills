`4_World` — предметы. Базовые классы для всех игровых предметов. Источники: `entities/itembase/`, `entities/core/`

### ItemBase

Иерархия: `InventoryItem` (3_Game) → `ItemBase`. Алиас: `typedef ItemBase Inventory_Base`.

#### EE-события (lifecycle)

| Метод | Когда | Описание |
|-------|-------|----------|
| `EEInit()` | Появление в мире | Инициализация (переопределяется в подклассах) |
| `EEDelete(EntityAI parent)` | Удаление | Очистка quickbar, блокировок |
| `EEKilled(Object killer)` | HP → 0 | Взрыв патронов в костре |
| `EEHitBy(...)` | Получение урона | Каскадный урон на карго/аттачменты |
| `EEHealthLevelChanged(int old, int new, string zone)` | Смена уровня HP | Сброс карго при ruined |
| `EEOnCECreate()` | Создание Central Economy | Установка quantity, урон зон |
| `EEItemAttached/Detached(EntityAI, string slot)` | Аттач/отсоединение | — |
| `OnWasAttached/OnWasDetached(EntityAI, int slot_id)` | После аттача | Звуки, net-sync |
| `OnInventoryEnter/Exit(Man player)` | Вход/выход из инвентаря | Quickbar shortcut |
| `OnVariablesSynchronized()` | Синхронизация с сервера | Звуки удара, quantity, wetness |
| `OnStoreSave/OnStoreLoad(ctx, version)` | Персистентность | Все переменные |
| `ProcessVariables()` | Периодический тик | Wetness, температура, порча еды |

#### Количество (Quantity)

| Метод | Описание |
|-------|----------|
| `SetQuantity(float, destroy_config, destroy_forced)` | Установить (сервер) |
| `SetQuantityNormalized(float 0..1)` | Нормализованное |
| `AddQuantity(float delta)` | Дельта |
| `CanBeSplit()` / `SplitIntoStackMax(...)` | Разделение стаков |

#### Действия

```
override void SetActions()
{
    super.SetActions();
    AddAction(MyAction);         // добавить
    RemoveAction(ActionTakeItem); // убрать
}
```

`SetActionAnimOverrides()` — переопределение анимаций действий для конкретного типа предмета.

#### Проверки инвентаря (переопределяемые)

| Метод | Описание |
|-------|----------|
| `CanPutInCargo(EntityAI parent)` | Можно положить в карго |
| `CanPutAsAttachment(EntityAI parent)` | Можно повесить |
| `CanReceiveItemIntoCargo(EntityAI item)` | Может принять в карго |
| `CanReceiveAttachment(EntityAI, int slotId)` | Может принять аттачмент |
| `CanReleaseAttachment(EntityAI)` | Можно отсоединить |
| `ChangeIntoOnAttach(string slot)` | Морфинг в другой класс при аттаче |
| `ChangeIntoOnDetach()` | Морфинг обратно |

#### Запросы типа (переопределяемые)

`IsLiquidContainer()`, `IsBloodContainer()`, `IsNVG()`, `IsExplosive()`, `IsLightSource()`, `CanBeRepairedByCrafting()`, `CanBeDigged()`, `CanMakeGardenplot()`, `CanBeDisinfected()`, `Open()` / `Close()` / `IsOpen()`

#### InitItemVariables — регистрация из конфига

Quantity (`varQuantityInit/Min/Max`, `varStackMax`), Wetness (`varWetInit/Min/Max`), Cleanness, `liquidContainerType`, `canBeSplit`, `itemBehaviour`, `compatibleLocks`, `lockType`. Всё регистрируется для net-sync.

---

### Edible_Base

`Edible_Base extends ItemBase`. Еда с системой стадий готовки.

#### Ключевые методы

| Метод | Описание |
|-------|----------|
| `Consume(float amount, PlayerBase)` | Уменьшить количество, вызвать OnConsume |
| `OnConsume(float, PlayerBase)` | Переопределить — урон от горячей еды |
| `CanBeCooked()` | Переопределить → `true` |
| `CanBeCookedOnStick()` | Переопределить → `true` |
| `OnFoodStageChange(stageOld, stageNew)` | Хук при смене стадии |
| `IsMeat()` / `IsCorpse()` / `IsFruit()` / `IsMushroom()` | Тип еды |
| `FilterAgents(int agentsIn)` | Подавить/разрешить агентов по стадии |
| `GetFoodStageType()` | Текущая стадия |
| `IsFoodRaw/Baked/Boiled/Dried/Burned()` | Проверки стадии |

Нутриенты (статические): `GetFoodEnergy()`, `GetFoodWater()`, `GetFoodToxicity()`, `GetFoodAgents()`, `GetNutritionalProfile()`.

---

### ClothingBase

`Clothing extends Clothing_Base` (C++). Алиас: `typedef Clothing ClothingBase`.

Подклассы: `Belt_Base`, `Backpack_Base`, `Glasses_Base`, `Gloves_Base`, `HeadGear_Base`, `Mask_Base`, `Pants_Base`, `Shoes_Base`, `Top_Base`, `Vest_Base`.

| Метод | Описание |
|-------|----------|
| `IsClothing()` | `true` |
| `CanHaveWetness()` | `true` |
| `GetGlassesEffectID()` | ID эффекта очков |
| `GetEffectWidgetTypes()` | Типы HUD-виджетов эффектов |
| `SmershException(EntityAI)` | Исключение вложенности Smersh |

---

### Container_Base

`Container_Base extends ItemBase`. Контейнеры.

- `IsContainer()` → `true`
- Запрет вложенности одинаковых контейнеров
- `DeployableContainer_Base` — размещаемые: `ActionTogglePlaceObject`, сброс карго при ruined

---

### FireplaceBase

`FireplaceBase extends ItemBase`. Полная симуляция огня.

#### Состояния (FireplaceFireState)

`NO_FIRE → START_FIRE → SMALL_FIRE → NORMAL_FIRE → END_FIRE → EXTINGUISHING_FIRE → EXTINGUISHED_FIRE`

#### Ключевые константы

| Константа | Значение |
|-----------|----------|
| `PARAM_SMALL_FIRE_TEMPERATURE` | 150°C |
| `PARAM_NORMAL_FIRE_TEMPERATURE` | 1000°C |
| `PARAM_MAX_WET_TO_IGNITE` | 0.2 |
| `PARAM_IGNITE_RAIN_THRESHOLD` | 0.1 |
| `PARAM_BURN_WET_THRESHOLD` | 0.40 |
| `PARAM_FULL_HEAT_RADIUS` | 2.0 |
| `PARAM_HEAT_RADIUS` | 4.0 |

Топливо/растопка определяются через статическую карту `m_FireConsumableTypes`.

---

### TentBase

`TentBase extends ItemBase`. Два состояния: `PACKED (0)` / `PITCHED (1)`.

| Метод | Описание |
|-------|----------|
| `TryPitch(bool from_storage)` | Развернуть |
| `Pack(bool from_storage)` | Свернуть |
| `HasClutterCutter()` / `GetClutterCutter()` | Обрезка растительности |
| `IsItemTent()` | `true` |

Система масок открытий (`m_OpeningMask`) — битовая маска для дверей/окон.

---

### TrapBase

`TrapBase extends ItemBase`. Ловушки с двумя состояниями (inactive/active).

#### Конфигурация (в конструкторе)

| Поле | Описание | По умолчанию |
|------|----------|-------------|
| `m_InitWaitTime` | Задержка активации (сек) | 5 |
| `m_DefectRate` | Урон ловушке за срабатывание | 15 |
| `m_DamagePlayers` | Урон игрокам | 25 |
| `m_DamageOthers` | Урон животным/заражённым | 100 |
| `m_NeedActivation` | Нужна ручная активация | true |

#### Переопределяемые

| Метод | Описание |
|-------|----------|
| `OnUpdate(EntityAI victim)` | Основной эффект при срабатывании |
| `StartActivate(PlayerBase)` | Начало активации |
| `SetActive()` | Пометить как взведённую |
| `Deactivate(PlayerBase)` | Разрядить |
| `IsPlaceableAtPosition(vector)` | Проверка размещения |
