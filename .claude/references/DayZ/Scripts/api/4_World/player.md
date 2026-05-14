`4_World` — player. Hierarchy: `ManBase` (C++) → `PlayerBase` → `PlayerBaseClient` → `SurvivorBase`. All characters inherit from `SurvivorBase`. Sources: `entities/manbase/`

### Subsystems

`PlayerBase` owns all managers, creating them in `Init()`:

| Field | Type | Side |
|------|-----|---------|
| `m_PlayerStats` | `PlayerStats` | Both |
| `m_ModifiersManager` | `ModifiersManager` | Server |
| `m_NotifiersManager` | `NotifiersManager` | Server |
| `m_ActionManager` | `ActionManagerBase` | Both |
| `m_BleedingManagerServer` | `BleedingSourcesManagerServer` | Server |
| `m_Environment` | `Environment` | Both |
| `m_StaminaHandler` | `StaminaHandler` | Both |
| `m_ShockHandler` | `ShockHandler` | Both |
| `m_EmoteManager` | `EmoteManager` | Both |
| `m_SymptomManager` | `SymptomManager` | Both |
| `m_SoftSkillsManager` | `SoftSkillsManager` | Both |
| `m_PlayerStomach` | `PlayerStomach` | Server |
| `m_AgentPool` | `PlayerAgentPool` | Server |

### Lifecycle

| Method | Context | When |
|-------|----------|-------|
| `Init()` | Both | Constructor — creates all subsystems |
| `OnPlayerLoaded()` | Both | After spawn (deferred via CallQueue) — HUD, camera, environment |
| `CommandHandler(float pDt, int pCurrentCommandID, bool pCurrentCommandFinished)` | Both | Every frame — main tick for all systems |
| `OnCommandHandlerTick(float pDt, int pCurrentCommandID)` | Both | Hook at the end of `CommandHandler` |
| `OnScheduledTick(float deltaT)` | Both | Timer tick — modifiers, notifiers, environment, bleeding |
| `EEKilled(Object killer)` | Server | Death — log, hive, VoN, corpse |
| `EEHitBy(TotalDamageResult, int damageType, EntityAI source, int component, string dmgZone, string ammo, vector modelPos, float speedCoef)` | Both | Hit — shock, bleeding, fractures |

### Tick layout

```
CommandHandler(dt) [every frame]
 ├── StaminaHandler.Update(dt)
 ├── ShockHandler.Update(dt)
 ├── InjuryHandler.Update(dt)
 └── ActionManager.Update(commandID)

OnScheduledTick(dt) [on timer]
 ├── ModifiersManager.OnScheduledTick(dt)
 ├── NotifiersManager.OnScheduledTick()
 ├── TransferValues.OnScheduledTick(dt)
 ├── VirtualHud.OnScheduledTick()
 ├── BleedingSourcesManager.OnTick(dt)
 └── Environment.Update(dt)
```

### Item EE events

| Method | When |
|-------|-------|
| `EEItemAttached(EntityAI item, string slot_name)` | Item equipped — quickbar, gas mask, NVG, hair |
| `EEItemDetached(EntityAI item, string slot_name)` | Item removed |
| `EEItemIntoHands(EntityAI item)` | Item into hands — reset weapon, heavy item |
| `EEItemOutOfHands(EntityAI item)` | Item out of hands |

### Overridable checks

| Method | What it checks |
|-------|---------------|
| `CanSprint()` | Raised weapon, heavy item, injury, fracture |
| `CanJump()` | Fracture, stamina, injury |
| `CanClimb(int climbType, SHumanCommandClimbResult)` | Fracture, stamina, injury |
| `CanRoll()` | Stamina, emote |
| `CanChangeStance(int prev, int next)` | Water level |

### Command states

| Method | When |
|-------|-------|
| `OnCommandSwimStart/Finish()` | Swimming — inventory lock |
| `OnCommandLadderStart/Finish()` | Ladder |
| `OnCommandFallStart/Finish()` | Falling |
| `OnCommandClimbStart/Finish()` | Climbing |
| `OnCommandVehicleStart/Finish()` | Vehicle |
| `OnCommandDeathStart()` | Death |
| `OnUnconsciousStart/Stop(int)` | Unconscious — HUD, VoN |

### Zones and areas

| Method | Side | Purpose |
|-------|---------|------------|
| `OnContaminatedAreaEnterServer()` | Server | Activates `MDF_AREAEXPOSURE` |
| `OnContaminatedAreaExitServer()` | Server | Deactivates `MDF_AREAEXPOSURE` |
| `OnPlayerIsNowInsideEffectAreaBeginServer/Client()` | Both | Effect-zone entry |
| `OnPlayerIsNowInsideEffectAreaEndServer/Client()` | Both | Effect-zone exit |

### ScriptInvokers

```
GetOnUnconsciousStart()   // subscribe: player goes unconscious
GetOnUnconsciousStop()    // subscribe: player comes to
```

### Actions

```
SetActions(out TInputActionMap map)             // override to add actions on the controlling player
SetActionsRemoteTarget(out TInputActionMap map) // actions on the target player
```

### Persistence

`OnStoreSave/OnStoreLoad` save: stats, modifiers, agents, symptoms, bleeding, stomach, broken legs, arrows. Versioned via `GAME_STORAGE_VERSION`.

### PlayerStats

Stats container. Versioned via PCO: `PlayerStatsPCO_current` extends `PlayerStatsPCO_v115`.

| Stat | Type | Range | Initial | Sync |
|------|-----|----------|-----------|------|
| `HEATCOMFORT` | float | -1..1 | 0 | No |
| `TREMOR` | float | 0..1 | 0 | No |
| `WET` | int | 0..1 | 0 | No |
| `ENERGY` | float | 0..max | 600 | No |
| `WATER` | float | 0..max | 600 | No |
| `DIET` | float | 0..5000 | 2500 | No |
| `STAMINA` | float | 0..max | 100 | No |
| `SPECIALTY` | float | -1..1 | 0 | No |
| `BLOODTYPE` | int | 0..128 | random | No |
| `TOXICITY` | float | 0..100 | 0 | No |
| `HEATBUFFER` | float | -30..30 | 0 | Yes |

`Blood` and `Health` are not PlayerStats but `DamageSystem` zones: `GetHealth("", "Blood")`.

#### PlayerStat API

| Method | Description |
|-------|----------|
| `Set(T value)` | Set (clamps); RPC to client if synced |
| `Add(T value)` | Set(current + value) |
| `Get()` | Current value |
| `GetNormalized()` | 0..1 |

#### Stat levels

`EStatLevels`: `GREAT, HIGH, MEDIUM, LOW, CRITICAL`

```
GetStatLevelHealth/Blood/Energy/Water/Toxicity()  // level of a specific stat
GetImmunityLevel()     // composite of energy+water+health+blood
GetImmunity()          // 0..1
```

### Notifiers

HUD notification system. Server-side. `NotifiersManager` ticks round-robin — one notifier per call.

| Notifier | ID | What it tracks |
|-------------|----|----|
| `HealthNotfr` | NTF_HEALTHY | Health |
| `HungerNotfr` | NTF_HUNGRY | Energy |
| `ThirstNotfr` | NTF_THIRSTY | Water |
| `BloodNotfr` | NTF_BLOOD | Blood |
| `WarmthNotfr` | NTF_WARMTH | HeatComfort (SMA) |
| `WetnessNotfr` | NTF_WETNESS | Wet |
| `SickNotfr` | NTF_SICK | Diseases |
| `FeverNotfr` | NTF_FEVERISH | Fever |
| `BleedingNotfr` | NTF_BLEEDISH | Bleeding |
| `HeartbeatNotfr` | NTF_HEARTBEAT | Blood (pulse) |
| `FracturedLegNotfr` | NTF_FRACTURE | Fracture |

#### NotifierBase API

| Method | Description |
|-------|----------|
| `GetNotifierType()` | Return the `eNotifiers` ID |
| `GetObservedValue()` | Current value of the tracked stat |
| `OnTick(int currentTime)` | Main tick — log, badge, tendency |
| `DisplayBadge()` / `HideBadge()` | Icon on VirtualHud |
| `DisplayTendency(float delta)` | Tendency arrow |
| `SetActive(bool)` | Enable/disable |

The tendency is computed via a ring buffer (30 values), averaged → `TENDENCY_STABLE / INC_LOW/MED/HIGH / DEC_LOW/MED/HIGH`.
