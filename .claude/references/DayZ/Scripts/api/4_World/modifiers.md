`4_World` — modifiers, agents, symptoms. Three connected systems: agents (infection) → modifiers (disease/condition) → symptoms (manifestation). Sources: `classes/playermodifiers/`, `classes/transmissionagents/`, `classes/playersymptoms/`

### Pipeline

```
Agent intake → Growth/decline in AgentPool → Threshold → Modifier activation → Symptoms
     ↑                    ↑                                    ↓
  Food/Wounds/      ImmuneSystem                         Stat effects
  Air/Zones        (immunity)                            (health, water...)
                       ↑                                    ↓
                  Antibiotics → Lower agents → Deactivation → Temporary immunity
```

---

### Agents

Base class: `AgentBase`. Player pool: `PlayerAgentPool` (`m_AgentPool` on `PlayerBase`).

#### eAgents (bitmask)

| Agent | Value |
|-------|----------|
| `CHOLERA` | 1 |
| `INFLUENZA` | 2 |
| `SALMONELLA` | 4 |
| `BRAIN` | 8 |
| `FOOD_POISON` | 16 |
| `CHEMICAL_POISON` | 32 |
| `WOUND_AGENT` | 64 |
| `NERVE_AGENT` | 128 |
| `HEAVYMETAL` | 256 |

#### AgentBase — configuration (set in `Init()`)

| Field | Description |
|------|----------|
| `m_Type` | `eAgents` value |
| `m_Invasibility` | Growth rate per second |
| `m_TransferabilityIn/Out` | Transfer coefficient |
| `m_TransferabilityAirOut` | Airborne spread |
| `m_Digestibility` | Multiplier during digestion (default 0.1) |
| `m_MaxCount` | Pool maximum |
| `m_Potency` | `EStatLevels` — immunity threshold for growth |
| `m_DieOffSpeed` | Decline rate under strong immunity |
| `m_AutoinfectCount` / `m_AutoinfectProbability` | Auto-infection |

#### AgentBase — overridable

| Method | Description |
|-------|----------|
| `GetInvasibilityEx(PlayerBase)` | Dynamic growth rate |
| `GetPotencyEx(PlayerBase)` | Dynamic threshold (e.g. Influenza raises it when pneumonia is active) |
| `GetDieOffSpeedEx(PlayerBase)` | Dynamic decline |
| `GetDrugResistance(EMedicalDrugsType, PlayerBase)` | Drug resistance (0=none, 1=full) |
| `AutoinfectCheck(float deltaT, PlayerBase)` | Auto-infection logic |
| `CanAutoinfectPlayer(PlayerBase)` | Basic auto-infection eligibility |

#### PlayerAgentPool — key methods

| Method | Description |
|-------|----------|
| `AddAgent(int id, float count)` | Add (respects temporary immunity) |
| `DigestAgent(int id, float count)` | Add × digestibility |
| `RemoveAgent(int id)` | Clear to zero |
| `ReduceAgent(int id, float percent)` | Percentage reduction |
| `GetSingleAgentCount(int id)` | Current count |
| `GetAgents()` | Bitmask of present agents |
| `SetTemporaryResistance(int id, float seconds)` | Temporary immunity |
| `AntibioticsAttack(float value)` | Antibiotics attack |
| `DrugsAttack(EMedicalDrugsType, float value)` | Drug attack |

#### Agent growth (`GrowAgents`, called from `ImmuneSystemTick`)

```
For each agent in the pool:
  if potency <= immunityLevel AND no temporary immunity → count += invasibility × deltaT
  else → count -= dieOffSpeed × deltaT
  clamp [0, maxCount]; on 0 — remove from pool
```

---

### Modifiers

Base class: `ModifierBase`. Manager: `ModifiersManager` (on `PlayerBase.m_ModifiersManager`, server).

#### eModifiers — 59 values (MDF_TEMPERATURE=1 ... MDF_CHELATION)

#### ModifierBase — configuration (set in `Init()`)

| Field | Description |
|------|----------|
| `m_ID` | `eModifiers` value (>= 1) |
| `m_TickIntervalActive` | Tick interval while active (default 3s) |
| `m_TickIntervalInactive` | Activation-check interval (default 3s) |
| `m_IsPersistent` | Saved to DB |
| `m_SyncID` | `eModifierSyncIDs` for client sync (max 32) |
| `m_TickType` | Bitmask: `TICK=1`, `ACTIVATE_CHECK=2`, `DEACTIVATE_CHECK=4` |

#### ModifierBase — overridable

| Method | Description |
|-------|----------|
| `Init()` | Set m_ID, intervals, m_SyncID |
| `ActivateCondition(PlayerBase)` | Checked every `m_TickIntervalInactive` — activate? |
| `DeactivateCondition(PlayerBase)` | Checked every `m_TickIntervalActive` — deactivate? |
| `OnActivate(PlayerBase)` | On activation |
| `OnReconnect(PlayerBase)` | On load from DB |
| `OnDeactivate(PlayerBase)` | On deactivation |
| `OnTick(PlayerBase, float deltaT)` | Tick while active |

#### Modifier tick cycle

```
Tick(deltaT):
  Inactive + ACTIVATE_CHECK:
    accumulate time → if > m_TickIntervalInactive:
      ActivateCondition()? → ActivateRequest()
  Active:
    accumulate time → if > m_TickIntervalActive:
      DEACTIVATE_CHECK + DeactivateCondition()? → Deactivate()
      else → OnTick(player, deltaT)
```

#### Conditions vs Diseases

**Conditions** (`modifiers/conditions/`): activated from player state (stats, external events). Do not call `IncreaseDiseaseCount()`. Examples: `BleedingCheckMdfr`, `WetMdfr`, `FeverMdfr`, `TremorMdfr`.

**Diseases** (`modifiers/diseases/`): activated from an agent threshold. Two thresholds — activation (above) and deactivation (below, hysteresis). Call `IncreaseDiseaseCount()` / `DecreaseDiseaseCount()`. Examples: `CommonColdMdfr`, `InfluenzaMdfr`, `CholeraMdfr`.

Multi-stage: `WoundInfection` (Stage1/2), `Contamination` (Stage1/2/3), `HeavyMetal` (Phase1/2/3) — separate classes with different thresholds.

#### ModifiersManager API

| Method | Description |
|-------|----------|
| `ActivateModifier(int id, bool triggerEvent)` | Force activation |
| `DeactivateModifier(int id, bool triggerEvent)` | Force deactivation |
| `IsModifierActive(eModifiers id)` | Check |
| `SetModifierLock(int id, bool state)` | Lock (will not deactivate) |

---

### Symptoms

Base class: `SymptomBase`. Manager: `SymptomManager` (on `PlayerBase.m_SymptomManager`).

#### SymptomTypes

| Type | Description |
|-----|----------|
| `PRIMARY (0)` | Full-body animations, priority queue, max 5 |
| `SECONDARY (1)` | Additive effects, parallel, no priority |

#### SymptomIDs

`SYMPTOM_COUGH`, `SYMPTOM_VOMIT`, `SYMPTOM_BLINDNESS`, `SYMPTOM_BULLET_HIT`, `SYMPTOM_BLEEDING_SOURCE`, `SYMPTOM_BLOODLOSS`, `SYMPTOM_SNEEZE`, `SYMPTOM_FEVERBLUR`, `SYMPTOM_LAUGHTER`, `SYMPTOM_UNCONSCIOUS`, `SYMPTOM_FREEZE`, `SYMPTOM_FREEZE_RATTLE`, `SYMPTOM_HOT`, `SYMPTOM_PAIN_LIGHT`, `SYMPTOM_PAIN_HEAVY`, `SYMPTOM_HAND_SHIVER`, `SYMPTOM_DEAFNESS_COMPLETE`, `SYMPTOM_HMP_SEVERE`, `SYMPTOM_GASP`

#### SymptomBase — configuration (`OnInit()`)

| Field | Description |
|------|----------|
| `m_SymptomType` | PRIMARY / SECONDARY |
| `m_Priority` | Priority in the primary queue (higher = more urgent) |
| `m_ID` | `SymptomIDs` |
| `m_MaxCount` | Max concurrent instances (-1 = unlimited) |
| `m_DestroyOnAnimFinish` | Auto-destroy after animation |
| `m_SyncToClient` | RPC sync |
| `m_IsPersistent` | Saved to DB |

#### SymptomBase — overridable

| Method | Description |
|-------|----------|
| `OnInit()` | Parameter setup |
| `CanActivate()` | Server: may start now? |
| `OnGetActivatedServer/Client(PlayerBase)` | On activation |
| `OnGetDeactivatedServer/Client(PlayerBase)` | On deactivation |
| `OnUpdateServer/Client(PlayerBase, float dt)` | Each frame |
| `SpawnAnimMetaObject()` | Return `SmptAnimMetaFB` (fullbody) or `SmptAnimMetaADD` (additive) |
| `IsSyncToRemotes()` | Visibility to other players |
| `AllowInUnconscious()` | Allowed while unconscious |

#### SymptomManager queues

- **Primary**: ordered by priority, max 5. One active at a time — the first with `CanActivate()=true`. The lowest is dropped on overflow.
- **Secondary**: all run in parallel, no limit.

#### SymptomManager API

| Method | Description |
|-------|----------|
| `QueueUpPrimarySymptom(int id)` | Add a primary by priority |
| `QueueUpSecondarySymptomEx(int id)` | Add a secondary |
| `RemoveSecondarySymptom(int id)` | Remove the first match |
| `RequestSymptomExit(int uid)` | Request completion |

---

### Example: Influenza chain

```
1. Cold → InfluenzaAgent.AutoinfectCheck() → AddAgent(INFLUENZA, 610)
2. GrowAgents: invasibility=0.33/s, potency=MEDIUM → grows if immunity ≤ MEDIUM
3. count ≥ 100 → CommonColdMdfr activates → sneezing
4. count ≥ 600 → InfluenzaMdfr activates → coughing, diseaseCount++
5. FeverMdfr sees MDF_INFLUENZA → SYMPTOM_FEVERBLUR + SYMPTOM_HOT
6. count ≥ 1150 → PneumoniaMdfr → health loss, SYMPTOM_GASP
7. InfluenzaAgent.GetPotencyEx: with pneumonia → potency=GREAT (harder to overcome)
8. Antibiotics → DrugsAttack → count drops → deactivation → 300s immunity
```
