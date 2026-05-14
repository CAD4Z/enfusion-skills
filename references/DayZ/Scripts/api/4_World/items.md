`4_World` — items. Base classes for all in-game items. Sources: `entities/itembase/`, `entities/core/`

### ItemBase

Hierarchy: `InventoryItem` (3_Game) → `ItemBase`. Alias: `typedef ItemBase Inventory_Base`.

#### EE events (lifecycle)

| Method | When | Description |
|-------|-------|----------|
| `EEInit()` | Spawned into the world | Initialization (overridden in subclasses) |
| `EEDelete(EntityAI parent)` | Deletion | Clear quickbar, locks |
| `EEKilled(Object killer)` | HP → 0 | Ammo cook-off in fireplace |
| `EEHitBy(...)` | Damage taken | Cascade damage to cargo/attachments |
| `EEHealthLevelChanged(int old, int new, string zone)` | HP level change | Drop cargo on ruined |
| `EEOnCECreate()` | Created by Central Economy | Set quantity, zone damage |
| `EEItemAttached/Detached(EntityAI, string slot)` | Attach/detach | — |
| `OnWasAttached/OnWasDetached(EntityAI, int slot_id)` | After attachment | Sounds, net-sync |
| `OnInventoryEnter/Exit(Man player)` | Inventory in/out | Quickbar shortcut |
| `OnVariablesSynchronized()` | Sync from the server | Impact sounds, quantity, wetness |
| `OnStoreSave/OnStoreLoad(ctx, version)` | Persistence | All variables |
| `ProcessVariables()` | Periodic tick | Wetness, temperature, food spoilage |

#### Quantity

| Method | Description |
|-------|----------|
| `SetQuantity(float, destroy_config, destroy_forced)` | Set (server) |
| `SetQuantityNormalized(float 0..1)` | Normalized |
| `AddQuantity(float delta)` | Delta |
| `CanBeSplit()` / `SplitIntoStackMax(...)` | Stack splitting |

#### Actions

```
override void SetActions()
{
    super.SetActions();
    AddAction(MyAction);         // add
    RemoveAction(ActionTakeItem); // remove
}
```

`SetActionAnimOverrides()` — overrides action animations for a specific item type.

#### Inventory checks (overridable)

| Method | Description |
|-------|----------|
| `CanPutInCargo(EntityAI parent)` | May be placed in cargo |
| `CanPutAsAttachment(EntityAI parent)` | May be hung as attachment |
| `CanReceiveItemIntoCargo(EntityAI item)` | May accept into cargo |
| `CanReceiveAttachment(EntityAI, int slotId)` | May accept an attachment |
| `CanReleaseAttachment(EntityAI)` | May be detached |
| `ChangeIntoOnAttach(string slot)` | Morph into a different class on attach |
| `ChangeIntoOnDetach()` | Morph back |

#### Type queries (overridable)

`IsLiquidContainer()`, `IsBloodContainer()`, `IsNVG()`, `IsExplosive()`, `IsLightSource()`, `CanBeRepairedByCrafting()`, `CanBeDigged()`, `CanMakeGardenplot()`, `CanBeDisinfected()`, `Open()` / `Close()` / `IsOpen()`

#### InitItemVariables — registration from config

Quantity (`varQuantityInit/Min/Max`, `varStackMax`), Wetness (`varWetInit/Min/Max`), Cleanness, `liquidContainerType`, `canBeSplit`, `itemBehaviour`, `compatibleLocks`, `lockType`. Everything is registered for net-sync.

---

### Edible_Base

`Edible_Base extends ItemBase`. Food with a cooking-stage system.

#### Key methods

| Method | Description |
|-------|----------|
| `Consume(float amount, PlayerBase)` | Reduce quantity, call OnConsume |
| `OnConsume(float, PlayerBase)` | Override — damage from hot food |
| `CanBeCooked()` | Override → `true` |
| `CanBeCookedOnStick()` | Override → `true` |
| `OnFoodStageChange(stageOld, stageNew)` | Hook on stage change |
| `IsMeat()` / `IsCorpse()` / `IsFruit()` / `IsMushroom()` | Food type |
| `FilterAgents(int agentsIn)` | Suppress/allow agents based on stage |
| `GetFoodStageType()` | Current stage |
| `IsFoodRaw/Baked/Boiled/Dried/Burned()` | Stage checks |

Nutrients (static): `GetFoodEnergy()`, `GetFoodWater()`, `GetFoodToxicity()`, `GetFoodAgents()`, `GetNutritionalProfile()`.

---

### ClothingBase

`Clothing extends Clothing_Base` (C++). Alias: `typedef Clothing ClothingBase`.

Subclasses: `Belt_Base`, `Backpack_Base`, `Glasses_Base`, `Gloves_Base`, `HeadGear_Base`, `Mask_Base`, `Pants_Base`, `Shoes_Base`, `Top_Base`, `Vest_Base`.

| Method | Description |
|-------|----------|
| `IsClothing()` | `true` |
| `CanHaveWetness()` | `true` |
| `GetGlassesEffectID()` | Glasses effect ID |
| `GetEffectWidgetTypes()` | HUD widget types for effects |
| `SmershException(EntityAI)` | Smersh nesting exception |

---

### Container_Base

`Container_Base extends ItemBase`. Containers.

- `IsContainer()` → `true`
- Prevents nesting of identical containers
- `DeployableContainer_Base` — deployable: `ActionTogglePlaceObject`, drops cargo on ruined

---

### FireplaceBase

`FireplaceBase extends ItemBase`. Full fire simulation.

#### States (FireplaceFireState)

`NO_FIRE → START_FIRE → SMALL_FIRE → NORMAL_FIRE → END_FIRE → EXTINGUISHING_FIRE → EXTINGUISHED_FIRE`

#### Key constants

| Constant | Value |
|-----------|----------|
| `PARAM_SMALL_FIRE_TEMPERATURE` | 150°C |
| `PARAM_NORMAL_FIRE_TEMPERATURE` | 1000°C |
| `PARAM_MAX_WET_TO_IGNITE` | 0.2 |
| `PARAM_IGNITE_RAIN_THRESHOLD` | 0.1 |
| `PARAM_BURN_WET_THRESHOLD` | 0.40 |
| `PARAM_FULL_HEAT_RADIUS` | 2.0 |
| `PARAM_HEAT_RADIUS` | 4.0 |

Fuel/kindling are resolved via the static `m_FireConsumableTypes` map.

---

### TentBase

`TentBase extends ItemBase`. Two states: `PACKED (0)` / `PITCHED (1)`.

| Method | Description |
|-------|----------|
| `TryPitch(bool from_storage)` | Pitch |
| `Pack(bool from_storage)` | Pack |
| `HasClutterCutter()` / `GetClutterCutter()` | Vegetation cutter |
| `IsItemTent()` | `true` |

Opening mask system (`m_OpeningMask`) — bitmask for doors/windows.

---

### TrapBase

`TrapBase extends ItemBase`. Traps with two states (inactive/active).

#### Configuration (in the constructor)

| Field | Description | Default |
|------|----------|-------------|
| `m_InitWaitTime` | Activation delay (s) | 5 |
| `m_DefectRate` | Damage to the trap per trigger | 15 |
| `m_DamagePlayers` | Damage to players | 25 |
| `m_DamageOthers` | Damage to animals/infected | 100 |
| `m_NeedActivation` | Requires manual activation | true |

#### Overridable

| Method | Description |
|-------|----------|
| `OnUpdate(EntityAI victim)` | Main effect on trigger |
| `StartActivate(PlayerBase)` | Start activation |
| `SetActive()` | Mark as armed |
| `Deactivate(PlayerBase)` | Disarm |
| `IsPlaceableAtPosition(vector)` | Placement check |
