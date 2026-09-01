Entity hierarchy of the game layer. Sources: `entities/*.c`

### Inheritance hierarchy

```
IEntity (1_Core)
└── ObjectTyped
    └── Entity
        └── EntityAI
            ├── Man (player)
            ├── Building (buildings)
            ├── InventoryItem (items)
            ├── DayZCreatureAI
            │   ├── DayZInfected (zombies)
            │   └── DayZAnimal (animals)
            ├── ScriptedEntity
            └── EntityLightSource
        └── Object (physical object)
        └── Camera (camera)
        └── Pawn (network reconciliation, see note)
```

Note: `Man` inherits `Pawn` when `FEATURE_NETWORK_RECONCILIATION` is enabled, otherwise inherits `EntityAI` directly.

### Entity

Inherits `ObjectTyped`. Source: `entities/entity.c`

#### Simulation and animation (proto native)

| Method | Return | Description |
|--------|--------|-------------|
| `DisableSimulation(bool disable)` | `void` | Enable/disable simulation |
| `GetIsSimulationDisabled()` | `bool` | Check state |
| `GetSimulationTimeStamp()` | `int` | Simulation tick |
| `GetAnimationPhase(animation)` | `float` | Animation phase |
| `SetAnimationPhase(animation, phase)` | `void` | Set phase |
| `ResetAnimationPhase(animation, phase)` | `void` | Reset immediately |
| `GetBoneIndex(proxySelectionName)` | `int` | Bone index by name |
| `GetBoneObject(boneIndex)` | `Object` | Bone proxy object |
| `SetInvisible(invisible)` | `void` | Invisibility |
| `MoveInTime(targetTransform[4], deltaT)` | `void` | Server teleport / client interpolation |

#### Callbacks

| Method | Description |
|--------|-------------|
| `OnAnimationPhaseStarted(animSource, phase)` | Start of animation phase |
| `OnCreatePhysics()` | Physics creation when added to the world |
| `OnNetworkTransformUpdate(out pos, out ypr)` | Transform update over network. `true` = visual snapshot |

### EntityAI

Inherits `Entity`. Main class of entities with inventory, damage, weight, and components. Source: `entities/entityai.c`

#### Key fields

| Field | Type | Description |
|-------|------|-------------|
| `m_KillerData` | `KillerData` | Killer data |
| `m_EM` | `ComponentEnergyManager` | Energy component |
| `m_DamageZoneMap` | `DamageZoneMap` | Damage zone map |
| `m_Weight` / `m_WeightEx` | `float` | Current / additional weight |
| `m_VarTemperature` | `float` | Item temperature |
| `m_IsFrozen` | `bool` | Frozen |

#### Components

| Method | Return | Description |
|--------|--------|-------------|
| `CreateComponent(comp_type, extended_class_name)` | `Component` | Create component |
| `GetComponent(comp_type, extended_class_name)` | `Component` | Get (or create) |
| `DeleteComponent(comp_type)` | `bool` | Delete component |
| `HasComponent(comp_type)` | `bool` | Check presence |

#### ScriptInvokers

| Getter | When invoked |
|--------|--------------|
| `GetOnItemAttached()` | Item attached to this entity |
| `GetOnItemDetached()` | Item detached |
| `GetOnItemAddedIntoCargo()` | Item added to cargo |
| `GetOnItemRemovedFromCargo()` | Item removed from cargo |
| `GetOnItemMovedInCargo()` | Item moved within cargo |
| `GetOnItemFlipped()` | Item flipped |
| `GetOnViewIndexChanged()` | View index changed |
| `GetOnSetLock()` / `GetOnReleaseLock()` | Cargo reservation |
| `GetOnAttachmentSetLock()` / `GetOnAttachmentReleaseLock()` | Attachment reservation |
| `GetOnHitByInvoker()` | Entity took damage |
| `GetOnKilledInvoker()` | Entity killed |

#### Enums

`EWetnessLevel`: `DRY`, `DAMP`, `WET`, `SOAKING`, `DRENCHED`

`PlantType`: `TREE_HARD(1000)`, `TREE_SOFT`, `BUSH_HARD`, `BUSH_SOFT`

`WeightUpdateType`: `FULL`, `ADD`, `REMOVE`, `RECURSIVE_ADD`, `RECURSIVE_REMOVE`

`EItemManipulationContext`: `UPDATE`, `ATTACHING`, `DETACHING`

`EInventoryIconVisibility` (bitmask): `ALWAYS(0)`, `HIDE_VICINITY(1)`, `HIDE_PLAYER_CONTAINER(2)`, `HIDE_HANDS_SLOT(4)`

`EAttExclusions`: attachment combination restrictions — `EXCLUSION_HEADGEAR_HELMET_0`, `EXCLUSION_MASK_0..3`, `EXCLUSION_GLASSES_REGULAR_0`, `EXCLUSION_GLASSES_TIGHT_0`, etc.

### Man

Inherits `EntityAI` (or `Pawn`). Controlled character. Source: `entities/man.c`

#### Proto native

| Method | Return | Description |
|--------|--------|-------------|
| `GetInputInterface()` | `UAInterface` | Input interface |
| `GetIdentity()` | `PlayerIdentity` | Player identity (MP) |
| `GetDrivingVehicle()` | `EntityAI` | Vehicle being driven (or `NULL`) |
| `GetHumanInventory()` | `HumanInventory` | Player inventory |
| `GetEntityInHands()` | `EntityAI` | Item in hands |
| `GetCurrentWeaponMode()` | `string` | Current weapon mode |
| `SetSpeechRestricted(state)` / `IsSpeechRestricted()` | — / `bool` | Restrict speech |
| `SetFaceTexture(texture)` / `SetFaceMaterial(material)` | `void` | Face texture/material |
| `IsSoundInsideBuilding()` | `bool` | Sound inside a building |
| `IsCameraInsideVehicle()` | `bool` | Camera inside a vehicle |
| `SetMasterAttenuation(att)` / `GetMasterAttenuation()` | — / `string` | Master sound attenuation |

#### Inventory operations

| Method | Description |
|--------|-------------|
| `PredictiveDropEntity(item)` | Drop item (client prediction) |
| `LocalDropEntity(item)` | Drop locally |
| `ServerDropEntity(item)` | Drop on server |
| `IsUnconscious()` | Unconscious |

#### ScriptInvokers

`GetOnItemAddedToHands()`, `GetOnItemRemovedFromHands()` — invoked via `EEItemIntoHands()` / `EEItemOutOfHands()`.

### Building

Inherits `EntityAI`. Buildings with doors and ladders. Source: `entities/building.c`

#### Doors (proto native)

| Method | Description |
|--------|-------------|
| `GetDoorCount()` | Number of doors |
| `GetDoorIndex(componentIndex)` | Component → door index |
| `IsDoorOpen(index)` | Opening requested (phase > 0.5) |
| `IsDoorOpened(index)` / `IsDoorClosed(index)` | Phase at target (1.0 / 0.0) |
| `IsDoorOpening(index)` / `IsDoorClosing(index)` | In animation |
| `IsDoorOpenedAjar(index)` / `IsDoorOpeningAjar(index)` | Slightly open (phase 0.2) |
| `IsDoorLocked(index)` | Locked |
| `OpenDoor(index)` / `CloseDoor(index)` | Open/close |
| `LockDoor(index, force)` | Lock. `force=true` — closes if open |
| `UnlockDoor(index, animate)` | Unlock. `animate=true` — opens slightly |
| `GetDoorSoundPos(index)` / `GetDoorSoundDistance(index)` | Sound position/distance |
| `PlayDoorSound(index)` | Play door sound |

#### Ladders (proto native)

| Method | Description |
|--------|-------------|
| `GetLaddersCount()` | Number of ladders |
| `GetLadderPosTop(index)` / `GetLadderPosBottom(index)` | Top/bottom positions |

#### Door events

`OnDoorOpenStart`, `OnDoorOpenFinish`, `OnDoorOpenAjarStart`, `OnDoorOpenAjarFinish`, `OnDoorCloseStart`, `OnDoorCloseFinish`, `OnDoorLocked`, `OnDoorUnlocked`

### DayZInfected

Inherits `DayZCreatureAI`. Infected (zombies). Source: `entities/dayzinfected.c`

#### Constants

`DayZInfectedConstants` (commands): `COMMANDID_MOVE`, `COMMANDID_VAULT`, `COMMANDID_DEATH`, `COMMANDID_HIT`, `COMMANDID_ATTACK`, `COMMANDID_CRAWL`, `COMMANDID_SCRIPT`

`DayZInfectedConstants` (AI states): `MINDSTATE_CALM`, `MINDSTATE_DISTURBED`, `MINDSTATE_ALERTED`, `MINDSTATE_CHASE`, `MINDSTATE_FIGHT`

`DayZInfectedConstantsMovement`: `MOVEMENTSTATE_IDLE(0)`, `MOVEMENTSTATE_WALK`, `MOVEMENTSTATE_RUN`, `MOVEMENTSTATE_SPRINT`

`DayZInfectedDeathAnims`: `ANIM_DEATH_DEFAULT(0)`, `ANIM_DEATH_IMPULSE(1)`, `ANIM_DEATH_BACKSTAB(2)`, `ANIM_DEATH_NECKSTAB(3)`

#### Commands (proto native)

| Method | Return | Description |
|--------|--------|-------------|
| `StartCommand_Move()` | `DayZInfectedCommandMove` | Start moving |
| `StartCommand_Vault(type)` | — | Vault |
| `StartCommand_Death(type, direction)` | — | Death |
| `StartCommand_Hit(heavy, type, direction)` | — | Take a hit |
| `StartCommand_Attack(target, type, subtype)` | `DayZInfectedCommandAttack` | Attack |
| `StartCommand_Crawl(type)` | — | Crawl |
| `StartCommand_Script(cmd)` / `StartCommand_ScriptInst(typename)` | `DayZInfectedCommandScript` | Scripted command |
| `GetCommand_Move()` / `GetCommand_Vault()` / `GetCommand_Attack()` / `GetCommand_Script()` | — | Get current command |
| `CanAttackToPosition(targetPos)` | `bool` | Can attack the position |

#### Command classes

| Class | Key methods |
|-------|-------------|
| `DayZInfectedCommandMove` | `SetStanceVariation()`, `SetIdleState()`, `StartTurn(dir, speed)`, `IsTurning()` |
| `DayZInfectedCommandAttack` | `WasHit()` |
| `DayZInfectedCommandVault` | `WasLand()` |
| `DayZInfectedCommandScript` | `SetFlagFinished()`, `PrePhys_Get/SetTranslation/Rotation()`, `PostPhys_Get/SetPosition/Rotation()`, `PostPhys_LockRotation()` |

### InventoryItem

Inherits `EntityAI`. Inventory items. Source: `entities/inventoryitem.c`

| Method | Description |
|--------|-------------|
| `SwitchOn()` / `IsOn()` | Turn on/state |
| `EnableCollisionsWithCharacter(state)` | Collisions with character |
| `GetMeleeCombatData()` | Melee combat data |
| `ThrowPhysically(player, force)` | Throw physically |
| `ForceFarBubble(state)` | Force network distance |

### Object

Inherits `Entity`. Physical world object. Source: `entities/object.c`

| Method | Description |
|--------|-------------|
| `Delete()` | Delete object |
| `AddProxyPhysics(proxyName)` / `RemoveProxyPhysics(proxyName)` | Manage proxy physics |
| `GetLODS(out array)` | Get LODs |

### Pawn

Base class for network reconciliation (`FEATURE_NETWORK_RECONCILIATION`). Source: `entities/pawn.c`

| Class | Description |
|-------|-------------|
| `PawnMove` | Movement data for reconciliation |
| `PawnOwnerState` | Owner state |
| `NetworkMoveStrategy` | `NONE`, `LATEST`, `PHYSICS` |
