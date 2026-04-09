Инвентарная система и конечный автомат рук. Источники: `systems/inventory/`, `systems/hand/`

### Режимы инвентаря

```
InventoryMode: PREDICTIVE, LOCAL, JUNCTURE, SERVER
```

- `PREDICTIVE` — клиентская предикция + серверная валидация (основной режим)
- `LOCAL` — локальная операция без сети (singleplayer)
- `JUNCTURE` — через серверный juncture (когда предикция невозможна)
- `SERVER` — серверная операция напрямую

### Типы команд

```
InventoryCommandType: MOVE, SYNC_MOVE, HAND_EVENT, SWAP, FORCESWAP, DESTROY, REPLACE
```

### Результаты валидации

```
InventoryValidationResult: FAILED, JUNCTURE, SUCCESS
InventoryValidationReason: UNKNOWN, JUNCTURE_DENIED, DROP_PREVENTED
InventoryCheckContext: DEFAULT, SYNC_CHECK
```

### GameInventory

Базовый инвентарь сущности. Источник: `systems/inventory/inventory.c`

#### Поиск и перечисление (proto native)

| Метод | Возврат | Описание |
|-------|---------|----------|
| `HasEntityInInventory(entity)` | `bool` | Содержит ли предмет |
| `EnumerateInventory(traversalType, out items)` | `int` | Перечислить все предметы |
| `CountInventory()` | `int` | Количество предметов |
| `GetCargo()` | `CargoBase` | Карго контейнер |

#### Создание предметов (proto native)

| Метод | Описание |
|-------|----------|
| `CreateEntityInCargo(typeName)` | Создать в карго |
| `CreateEntityInCargoEx(typeName, idx, row, col, flip)` | Создать на точной позиции |
| `CreateInInventory(typeName)` | Создать в любом свободном месте |

#### Операции с предметами

Каждая операция имеет 4 варианта по `InventoryMode`:

| Операция | Описание |
|----------|----------|
| `TakeEntityToInventory(mode, flags, item)` | Взять в инвентарь |
| `TakeEntityToCargo(mode, item)` | Взять в карго |
| `TakeEntityAsAttachment(mode, item)` | Взять как аттачмент |
| `TakeEntityToTargetInventory(mode, target, flags, item)` | Переместить в инвентарь цели |
| `TakeEntityToTargetCargo(mode, target, item)` | В карго цели |
| `TakeEntityToTargetAttachment(mode, target, item)` | Как аттачмент цели |
| `SwapEntities(mode, item1, item2)` | Обменять предметы |
| `ForceSwapEntities(mode, item1, dst1, item2, dst2)` | Принудительный обмен |
| `DropEntity(mode, owner, item)` | Бросить на землю |

### HumanInventory

Расширяет `GameInventory` для игрока. Источник: `systems/inventory/humaninventory.c`

#### Руки (proto native)

| Метод | Возврат | Описание |
|-------|---------|----------|
| `GetEntityInHands()` | `EntityAI` | Предмет в руках |
| `CanAddEntityInHands(item)` | `bool` | Можно ли взять в руки |
| `TestAddEntityInHands(item, exclusions, reserved, result)` | `bool` | Тест с подробным результатом |
| `CanRemoveEntityInHands()` | `bool` | Можно ли убрать из рук |
| `CreateInHands(typeName)` | `EntityAI` | Создать предмет прямо в руках |

#### Резервирование

| Метод | Описание |
|-------|----------|
| `GetUserReservedLocationCount()` | Количество зарезервированных мест |
| `SetUserReservedLocation(item, dst)` | Зарезервировать место |
| `GetUserReservedLocation(index, out dst)` | Получить резервацию |
| `ClearUserReservedLocation(item)` | Снять резервацию |
| `FindUserReservedLocationIndex(item)` | Найти индекс |
| `FindCollidingUserReservedLocationIndex(item, dst)` | Найти коллизию |

### InventoryLocation

Описание позиции предмета в инвентаре. Обёртка `int` типа + slot/idx/row/col.

#### Типы расположения

| Тип | Описание |
|-----|----------|
| `UNKNOWN` | Не определено |
| `GROUND` | На земле |
| `ATTACHMENT` | Аттачмент (слот) |
| `CARGO` | В карго |
| `HANDS` | В руках |
| `PROXYCARGO` | Proxy-карго |

#### Ключевые методы

| Метод | Описание |
|-------|----------|
| `GetType()` | Тип расположения |
| `GetParent()` | Родительская сущность |
| `GetItem()` | Предмет |
| `GetSlot()` | Индекс слота (для ATTACHMENT) |
| `GetIdx()` / `GetRow()` / `GetCol()` | Позиция в карго |
| `GetFlip()` | Повёрнут ли |
| `IsValid()` | Валидность |
| `SetGround(item, transform[4])` | Установить на землю |
| `SetAttachment(parent, item, slot)` | В слот аттачмента |
| `SetCargo(parent, item, idx, row, col, flip)` | В карго |
| `SetHands(parent, item)` | В руки |

### InventorySlots

Управление слотами. Static-методы.

| Метод | Описание |
|-------|----------|
| `GetSlotIdFromString(slotName)` | Имя → ID слота |
| `GetSlotName(slotId)` | ID → имя |
| `GetSlotDisplayName(slotId)` | Локализованное имя |
| `GetSlotIdFromWeaponSlot(weaponSlot)` | Weapon slot → ID |
| `GetStackMaxForSlotId(slotId)` | Максимальный стек |

### Hand FSM

Конечный автомат операций с предметами в руках. Управляет анимационными переходами при взятии, выкладывании и замене предметов.

#### Архитектура

```
HandFSM (конечный автомат)
├── HandStableState (стабильные состояния: Empty, Equipped)
├── HandStartAction (начало действия)
├── HandAnimated_* (анимированные переходы)
│   ├── HandAnimatedSwapping
│   ├── HandAnimatedForceSwapping
│   ├── HandAnimatedTakingFromAtt
│   └── HandAnimatedMovingToAtt
└── HandReplacing* (замена предметов)
    ├── HandReplacingItemInHands
    └── HandReplacingItemElsewhereWithNewInHands
```

#### Паттерн использования

FSM получает события (`HandEventBase`) и автоматически управляет анимациями. Модер обычно не работает с FSM напрямую — вместо этого использует `GameInventory` операции, которые генерируют нужные события.

#### Ключевые события

`HandEventTake`, `HandEventDrop`, `HandEventSwap`, `HandEventForceSwap`, `HandEventMoveTo`, `HandEventDestroy`, `HandEventReplace`

#### Guards (условия перехода)

`HandAnimated_Guards` — проверки условий: можно ли взять предмет, достаточно ли места, валиден ли целевой слот.
