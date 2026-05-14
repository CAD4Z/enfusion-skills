Inventory system and hands state machine. Sources: `systems/inventory/`, `systems/hand/`

### Inventory modes

```
InventoryMode: PREDICTIVE, LOCAL, JUNCTURE, SERVER
```

- `PREDICTIVE` — client prediction + server validation (main mode)
- `LOCAL` — local operation without networking (singleplayer)
- `JUNCTURE` — through server juncture (when prediction is not possible)
- `SERVER` — direct server operation

### Command types

```
InventoryCommandType: MOVE, SYNC_MOVE, HAND_EVENT, SWAP, FORCESWAP, DESTROY, REPLACE
```

### Validation results

```
InventoryValidationResult: FAILED, JUNCTURE, SUCCESS
InventoryValidationReason: UNKNOWN, JUNCTURE_DENIED, DROP_PREVENTED
InventoryCheckContext: DEFAULT, SYNC_CHECK
```

### GameInventory

Base entity inventory. Source: `systems/inventory/inventory.c`

#### Search and enumeration (proto native)

| Method | Return | Description |
|--------|--------|-------------|
| `HasEntityInInventory(entity)` | `bool` | Contains the item |
| `EnumerateInventory(traversalType, out items)` | `int` | Enumerate all items |
| `CountInventory()` | `int` | Number of items |
| `GetCargo()` | `CargoBase` | Cargo container |

#### Item creation (proto native)

| Method | Description |
|--------|-------------|
| `CreateEntityInCargo(typeName)` | Create in cargo |
| `CreateEntityInCargoEx(typeName, idx, row, col, flip)` | Create at exact position |
| `CreateInInventory(typeName)` | Create in any free location |

#### Item operations

Each operation has 4 variants by `InventoryMode`:

| Operation | Description |
|-----------|-------------|
| `TakeEntityToInventory(mode, flags, item)` | Take into inventory |
| `TakeEntityToCargo(mode, item)` | Take into cargo |
| `TakeEntityAsAttachment(mode, item)` | Take as attachment |
| `TakeEntityToTargetInventory(mode, target, flags, item)` | Move to target inventory |
| `TakeEntityToTargetCargo(mode, target, item)` | Into target cargo |
| `TakeEntityToTargetAttachment(mode, target, item)` | As target attachment |
| `SwapEntities(mode, item1, item2)` | Swap items |
| `ForceSwapEntities(mode, item1, dst1, item2, dst2)` | Force swap |
| `DropEntity(mode, owner, item)` | Drop on the ground |

### HumanInventory

Extends `GameInventory` for the player. Source: `systems/inventory/humaninventory.c`

#### Hands (proto native)

| Method | Return | Description |
|--------|--------|-------------|
| `GetEntityInHands()` | `EntityAI` | Item in hands |
| `CanAddEntityInHands(item)` | `bool` | Can take into hands |
| `TestAddEntityInHands(item, exclusions, reserved, result)` | `bool` | Test with detailed result |
| `CanRemoveEntityInHands()` | `bool` | Can remove from hands |
| `CreateInHands(typeName)` | `EntityAI` | Create item directly in hands |

#### Reservation

| Method | Description |
|--------|-------------|
| `GetUserReservedLocationCount()` | Number of reserved slots |
| `SetUserReservedLocation(item, dst)` | Reserve a slot |
| `GetUserReservedLocation(index, out dst)` | Get reservation |
| `ClearUserReservedLocation(item)` | Clear reservation |
| `FindUserReservedLocationIndex(item)` | Find index |
| `FindCollidingUserReservedLocationIndex(item, dst)` | Find collision |

### InventoryLocation

Description of an item's position in inventory. A wrapper around an `int` type + slot/idx/row/col.

#### Location types

| Type | Description |
|------|-------------|
| `UNKNOWN` | Undefined |
| `GROUND` | On the ground |
| `ATTACHMENT` | Attachment (slot) |
| `CARGO` | In cargo |
| `HANDS` | In hands |
| `PROXYCARGO` | Proxy cargo |

#### Key methods

| Method | Description |
|--------|-------------|
| `GetType()` | Location type |
| `GetParent()` | Parent entity |
| `GetItem()` | Item |
| `GetSlot()` | Slot index (for ATTACHMENT) |
| `GetIdx()` / `GetRow()` / `GetCol()` | Cargo position |
| `GetFlip()` | Whether flipped |
| `IsValid()` | Validity |
| `SetGround(item, transform[4])` | Place on the ground |
| `SetAttachment(parent, item, slot)` | In attachment slot |
| `SetCargo(parent, item, idx, row, col, flip)` | In cargo |
| `SetHands(parent, item)` | In hands |

### InventorySlots

Slot management. Static methods.

| Method | Description |
|--------|-------------|
| `GetSlotIdFromString(slotName)` | Name → slot ID |
| `GetSlotName(slotId)` | ID → name |
| `GetSlotDisplayName(slotId)` | Localized name |
| `GetSlotIdFromWeaponSlot(weaponSlot)` | Weapon slot → ID |
| `GetStackMaxForSlotId(slotId)` | Max stack |

### Hand FSM

State machine for operations with items in hands. Manages animation transitions when taking, putting down, and replacing items.

#### Architecture

```
HandFSM (state machine)
├── HandStableState (stable states: Empty, Equipped)
├── HandStartAction (action start)
├── HandAnimated_* (animated transitions)
│   ├── HandAnimatedSwapping
│   ├── HandAnimatedForceSwapping
│   ├── HandAnimatedTakingFromAtt
│   └── HandAnimatedMovingToAtt
└── HandReplacing* (item replacement)
    ├── HandReplacingItemInHands
    └── HandReplacingItemElsewhereWithNewInHands
```

#### Usage pattern

The FSM receives events (`HandEventBase`) and manages animations automatically. Modders typically don't work with the FSM directly — instead, they use `GameInventory` operations that generate the appropriate events.

#### Key events

`HandEventTake`, `HandEventDrop`, `HandEventSwap`, `HandEventForceSwap`, `HandEventMoveTo`, `HandEventDestroy`, `HandEventReplace`

#### Guards (transition conditions)

`HandAnimated_Guards` — condition checks: whether the item can be taken, whether there is enough space, whether the target slot is valid.
