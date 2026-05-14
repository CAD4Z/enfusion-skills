Animals: DayZAnimal (3_Game) → AnimalBase (4_World). The most "native" branch of AI — almost all behavior is in C++, the script portion is thin.

### Hierarchy

```
DayZCreatureAI
 └── DayZAnimal (3_Game)             — CommandHandler, commands, HitComponents, damage
      └── AnimalBase (4_World)       — DeathUpdate, ArrowManager, base class
           ├── Animal_CanisLupus     — wolf (IsDanger = true)
           ├── Animal_UrsusArctos    — bear (IsDanger = true)
           ├── Animal_BosTaurus(F)   — cow
           ├── Animal_CervusElaphus(F) — deer
           ├── Animal_RangiferTarandus(F) — reindeer
           ├── Animal_CapraHircus(F) — goat
           ├── Animal_OvisAries(F)   — sheep
           ├── Animal_SusDomesticus  — pig
           ├── Animal_SusScrofa      — boar
           ├── Animal_GallusGallusDomesticus(F) — chicken/rooster (ReplaceOnDeath)
           ├── Animal_LepusEuropaeus — hare (ReplaceOnDeath)
           └── Animal_VulpesVulpes   — fox (ReplaceOnDeath)
```

The `F` suffix marks a female (inherits from the male unchanged or with a different DeadItem).

---

### Key difference from infected

For infected, the script controls combat logic, attack selection, mind state reactions. For animals, **almost everything is in native**:

- **Behavior** — fully native AI. Behavior slots (`DayZAnimalBehaviourSlot`) and actions (`DayZAnimalBehaviourAction`) are enums defined in C++
- **Decisions** — native AI decides when to be scared, hunt, attack
- **Script** — only CommandHandler (reactive: death, damage, jumps), HitComponents, sounds

### DayZAnimalInputController

Extends `DayZCreatureAIInputController`. Adds:

- `IsDead()` — whether dead (proto native)
- `IsAttack()` — whether AI wants to attack (proto native)
- `OverrideBehaviourAction(state, action)` / `GetBehaviourAction()` — action interception

#### Behavior slots (BehaviourSlot)

Defined in C++, managed by native AI:

| Slot | Context |
|------|---------|
| `CALM` | Calm state |
| `CALM_RESTING` | Resting |
| `CALM_GRAZING` | Grazing |
| `CALM_TRAVELLING` | Traveling |
| `DRINKING` | Drinking |
| `NON_SPECIFIC_THREAT` | Unspecified threat |
| `SPECIFIC_THREAT` | Specific threat |
| `ALERTED` | Alertness |
| `ATTRACTED` | Attraction |
| `PREATTRACTED` | Pre-attraction |
| `SCARED` | Fear (fleeing) |
| `HUNTING` | Hunting (predators) |
| `EATING` | Eating |
| `SIEGE` | Siege |
| `FIREPLACE` | Reaction to a fireplace |
| `ENRAGED` | Rage |
| `ENRAGED_TARGETLOST` | Rage, target lost |
| `INTIMIDATE` | Intimidation |

#### Behavior actions (BehaviourAction)

| Action | Description |
|--------|-------------|
| `SAFETY_INPUT` | Retreating from threat |
| `GRAZE_WALKING/ON_SPOT_INPUT` | Grazing |
| `RESTING_INPUT` | Resting |
| `TRAVELING_INPUT` | Traveling |
| `EATING/DRINKING_INPUT` | Eating/drinking |
| `CHARGING` | Charging attack |
| `APPROACHING/REACH_INPUT` | Approaching the target |
| `WALKING/IDLE1-3_INPUT` | Walking/idle variants |
| `THREAT_WALK_AWAY/TO/STAY_LOOKAT/STAY` | Reactions to a threat |

---

### CommandHandler

Significantly simpler than for infected — no mind states, no combat logic in the script:

```
CommandHandler(dt, currentCommandID, currentCommandFinished)
 1. ModCommandHandlerBefore()   → mod interception
 2. HandleDeath()               → StartCommand_Death(type, direction)
 3. If the command is finished:
    - If it was Attack → SignalAIAttackEnded()
    - StartCommand_Move()
 4. ModCommandHandlerInside()
 5. HandleDamageHit()           → StartCommand_Hit(type, direction)
 6. If COMMANDID_MOVE:
    - IsJump() → StartCommand_Jump()
    - IsAttack() → StartCommand_Attack() + SignalAIAttackStarted()
 7. ModCommandHandlerAfter()
```

**Attack signals**: `SignalAIAttackStarted()` / `SignalAIAttackEnded()` — proto native notifications to the AI brain about the start/end of an attack. They let native AI coordinate attacks with animations.

### Commands (proto native)

| Command | Purpose |
|---------|---------|
| `StartCommand_Move()` | Normal movement |
| `StartCommand_Jump()` | Jump |
| `StartCommand_Attack()` | Attack |
| `StartCommand_Death(type, dir)` | Death |
| `StartCommand_Hit(type, dir)` | Hit reaction |
| `StartCommand_Script(cmd)` | Script command |

---

### Death

Two mechanisms depending on animal type:

**Large** (cow, deer, bear, wolf, goat, sheep, pig, boar):
- Remain in the world as a corpse
- `CanBeSkinned() = true` (if not frozen) → can be skinned
- `AnimalBase.DeathUpdate()` → creates a dead object, transfers properties via `MiscGameplayFunctions.TransferItemProperties()`, sets full health

**Small** (chicken, hare, fox):
- `ReplaceOnDeath() = true` → replaced with an item (DeadRooster, DeadChicken_*, DeadRabbit, DeadFox)
- `CanBeSkinned() = false` — skinning is done via the item only
- `KeepHealthOnReplace() = false` — the item is created with full health

---

### IsDanger — predators vs prey

`IsDanger()` defines the role in the food chain:

| `IsDanger() = true` | `IsDanger() = false` |
|---------------------|---------------------|
| Wolf (CanisLupus) | All others |
| Bear (UrsusArctos) | |

Used by traps (`TrapBase`) to determine capture/release sounds.

---

### HitComponents — hit zones by species

All animals override `RegisterHitComponentsForAI()`. Default: `Zone_Chest`, position: `Pelvis`.

**Predators** (wolf, bear): low head weight (2–25), high leg weight (70–75).

**Herbivores** (deer, goat, sheep, reindeer): head 2–4, neck 55–65, chest 50, legs 70.

**Livestock** (cow, pig, boar): belly 15–25, neck 55–65, chest 50, legs 70.

**Small** (chicken, hare, fox): head 1–20, chest/back 70, legs 5.

---

### Damage handling

Shared pipeline from `DayZAnimal.EEHitBy()`:

1. **Shock → Health**: if `transferShockToDamage = 1` → conversion using the multiplier `NL_DAMAGE_CLOSECOMBAT/FIREARM_CONVERSION_ANIMALS`
2. **Bleeding**: `ComponentAnimalBleeding.CreateWound()` — a separate component for animals
3. **Hit animation**: `ComputeDamageHitParams()` → `QueueDamageHit(type, direction)`

Direction calculation: the angle between the animal's facing direction and the vector to the source → front (±20°) / left / right. Additional offset by zone: Head (+4), chest/neck (+8), other (+12).

---

### Sounds

The animation event system is inherited from `DayZCreatureAI` (see creatures.md). Config from `CfgVehicles → AnimEvents`.

**Traps**: each species defines `CaptureSound()` / `ReleaseSound()` — sounds when caught in a trap and when released.

---

### Cinematic Controller

Inherited from `DayZCreatureAI`. Allows the player to control an animal via the InputController Override methods. Through `ModCommandHandlerBefore()` it intercepts player input and translates it into movement, turns, and behavior slots. At low speed (<0.5), it automatically raises the alert level to transition to more active animations.
