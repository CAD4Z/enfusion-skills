EntityAI — the base class of all interactive entities. Inherits `Entity` (1_Core). Items, creatures, vehicles, and the player all inherit from it.

File: `3_game/entities/entityai.c` (~4600 lines). Describes not AI behavior but the **common foundation for all entities**, including those controlled by AI.

### Inheritance hierarchy

```
Entity (1_Core, proto native)
 └── EntityAI (3_Game)
      ├── DayZCreature → DayZCreatureAI → DayZInfected / DayZAnimal
      ├── Man → DayZPlayer → DayZPlayerImplement
      ├── InventoryItem
      ├── Transport
      └── AdvancedCommunication
```

Type checks: `IsMan()`, `IsAnimal()`, `IsZombie()`, `IsWeapon()`, `IsMagazine()`, `IsTransport()` — all return `false` by default and are overridden in descendants.

---

### Lifecycle

#### Initialization

```
Constructor EntityAI()
 ├── Creation of EnergyManager (if defined in config)
 ├── Registration of network variables
 ├── InitDamageZoneMapping() — mapping of damage zones from config
 ├── InitItemVariables() — temperature parameters from config
 └── CallLater(DeferredInit, 34ms) — deferred initialization
      └── m_Initialized = true

EEInit() — after the entity has been created by the engine
 ├── Inventory initialization
 ├── MaxLifetimeRefreshCalc()
 └── InitTemperature() (server)
```

`DeferredInit()` — invoked 34ms after the constructor. Needed for operations that require the entity to be fully initialized in the world.

#### CE (Central Economy) events

- `EEOnCECreate()` — the entity has been created by the central economy system
- `AfterStoreLoad()` — loaded from the DB (after all child entities have been loaded)
- `EEOnAfterLoad()` — link restoration (for example, electrical connections)

#### Deletion

- `EEDelete(parent)` — immediately before deletion. Notifies the inventory and EnergyManager
- `EEKilled(killer)` — on death. Calls `DeathUpdate()` after 250ms if `ReplaceOnDeath() == true`
- `DeathUpdate()` — creates a dead object (`GetDeadItemName()`), transfers orientation, deletes the original

#### Persistence

- `OnStoreSave(ctx)` — save to the DB. Writes the EnergyManager state and variables
- `OnStoreLoad(ctx, version)` — load from the DB. `version` is for backward compatibility
- `GetPersistentID(out b1, b2, b3, b4)` — unique ID that survives a server restart

---

### Damage system and hit zones

#### Damage Zones

`InitDamageZoneMapping()` during initialization builds the zone map from the config (`DamageSystem.GetDamageZoneMap()`). Each zone is a named region of the model with its own health.

`EEHealthLevelChanged(oldLevel, newLevel, zone)` — the key callback on health level changes. When `STATE_RUINED` is reached:
- Notifies the parent (`OnAttachmentRuined`)
- If `zone` is empty (global health) — `OnDamageDestroyed()`
- Triggers DestructionBehaviour if configured

#### HitComponents for AI

The mechanism by which the AI chooses **where to aim**:

- `GetHitComponentForAI()` — weighted random zone selection. By default — error (must be overridden)
- `GetDefaultHitComponent()` — default zone
- `GetDefaultHitPosition()` — default position
- `GetSuitableFinisherHitComponents()` — zones for finishers (backstab)

Each descendant implements its own logic: for DayZInfected zones come from `DayZInfectedType`, for DayZAnimal — via `RegisterHitComponentsForAI()` with weights.

#### AI Targeting

`CanBeTargetedByAI(EntityAI ai)` — whether the AI can attack this entity:
- `false` if the AI is performing a backstab
- `false` if the physical body is inactive (and it is not Man)
- `false` if `IsDamageDestroyed()`

`SetAITargetCallbacks(callbacks)` — proto native. Registers visibility/position callbacks for the AI system (see infrastructure.md).

---

### Network synchronization

#### Variable registration

Called in the constructor. Variables synchronize automatically on change:

- `RegisterNetSyncVariableBool(name)` — bool
- `RegisterNetSyncVariableBoolSignal(name)` — bool signal (auto-resets to false after sending)
- `RegisterNetSyncVariableInt(name, min, max)` — int with quantization
- `RegisterNetSyncVariableFloat(name, min, max, precision)` — float with quantization
- `RegisterNetSyncVariableObject(name)` — object reference (by network ID)

`SetSynchDirty()` — mark the object for synchronization. `OnVariablesSynchronized()` — callback on the client when data arrives.

Quantization: when min/max is specified, values are compressed to save traffic. `precision` is the number of decimal digits.

---

### Hierarchy and inventory

- `GetHierarchyRoot()` — root of the hierarchy (proto native)
- `GetHierarchyRootPlayer()` — root as Man (proto native)
- `GetHierarchyParent()` — direct parent (proto native)

Inventory events (invoked on the **parent**):
- `EEItemAttached(item, slot)` / `EEItemDetached(item, slot)` — attachments
- `EECargoIn(item)` / `EECargoOut(item)` — cargo
- `EEItemLocationChanged(oldLoc, newLoc)` — any movement

Exclusion-mask system: on attach, slot compatibility is checked (for example, helmet + goggles).

---

### Components

Lazy system via `ComponentsBank`:

- `CreateComponent(type)` — create a component (creates the bank if needed)
- `HasComponent(type)` / `GetComponent(type)` — check/get
- Components receive events: `Event_OnItemAttached`, `Event_OnItemDetached`, `Event_OnFrame`

Main types: `COMP_TYPE_ENERGY_MANAGER`, `COMP_TYPE_BODY_STAGING`, `COMP_TYPE_ETITY_DEBUG`.

---

### Key subsystems (briefly)

**Temperature**: parameters from config (`varTemperatureInit/Min/Max`, `varTemperatureFreezePoint/ThawPoint`). Synchronized over the network. Freezing/thawing with progress. Living organisms (`IsMan/IsAnimal/IsZombie && IsAlive`) self-regulate temperature.

**Weight**: a dirty-flag system. `SetWeightDirty()` on any content change. Recomputation is recursive up the hierarchy.

**Lifetime (CE)**: `SetLifetime()` / `GetLifetime()` — remaining lifetime in seconds. `IncreaseLifetimeUp()` — reset the timer up the hierarchy (interacting with an item extends the lifetime of the container).
