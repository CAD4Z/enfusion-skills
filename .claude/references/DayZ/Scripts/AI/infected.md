Infected (zombies): DayZInfected (3_Game) → ZombieBase (4_World). The most script-heavy branch of AI — most of the combat logic and behavior is accessible from scripts.

### Hierarchy

```
DayZCreatureAI
 └── DayZInfected (3_Game)          — proto native commands, InputController, damage
      └── ZombieBase (4_World)      — CommandHandler, combat logic, mind states, sound
           ├── ZombieMaleBase       — male models
           └── ZombieFemaleBase     — female models
               └── concrete classes (ZmbM_CitizenASkinny, ZmbF_Doctor, ...)
```

Alongside:
```
DayZCreatureAIType → DayZInfectedType — attack table, HitComponents, attack selection
DayZCreatureAIInputController → DayZInfectedInputController — MindState, target (native)
```

---

### Mind States

Defined by **native AI** and read via `DayZInfectedInputController.GetMindState()`. The script does not set them directly — the AI reacts to noise and visibility, the script only reads and reacts.

| State | Value | Behavior |
|-------|-------|----------|
| `MINDSTATE_CALM` | 0 | Idle, wandering. IdleState = 0 |
| `MINDSTATE_DISTURBED` | 1 | Wary, looking around. IdleState = 1 |
| `MINDSTATE_ALERTED` | 2 | Alarmed (sound in infrastructure.md) |
| `MINDSTATE_CHASE` | 3 | Pursuing target. IdleState = 2 |
| `MINDSTATE_FIGHT` | 4 | Melee combat |

On mind state change — attack cooldown is reset and `SetSynchDirty()` is called to synchronize to the client.

---

### DayZInfectedInputController

Extends `DayZCreatureAIInputController` (see creatures.md). Additionally:

- `GetMindState()` — current state (proto native, from the AI brain)
- `GetTargetEntity()` — current AI target (proto native)
- `IsVault()` / `GetVaultHeight()` — whether a vault is needed (analogous to Jump)

All creature control comes from native AI. The script reads via Get methods and reacts in CommandHandler.

---

### CommandHandler — full cycle

```
CommandHandler(dt, currentCommandID, currentCommandFinished)
 1. ModCommandHandlerBefore()        → full interception
 2. HandleDeath()                    → StartCommand_Death(type, direction)
 3. HandleMove() / HandleOrientation() → synchronize speed and yaw
 4. If the command is finished        → StartCommand_Move() with StanceVariation
 5. ModCommandHandlerInside()
 6. HandleCrawlTransition()          → StartCommand_Crawl(type)
 7. HandleDamageHit()                → StartCommand_Hit(heavy, type, direction)
 8. HandleVault()                    → StartCommand_Vault(type)
 9. HandleMindStateChange()          → change idle animation
10. FightLogic()                     → ChaseAttackLogic / FightAttackLogic
11. ModCommandHandlerAfter()
```

#### Synchronization (HandleMove / HandleOrientation)

**Speed** (`m_MovementSpeed`): synchronized when the change is >= 0.9 from the last value. Range: -1..3.

**Orientation** (`m_OrientationSynced`): quantized yaw (0–359°). Synchronized every **2 seconds** or when deviating >30° from the last synchronized value. Minimum update threshold — 5°.

---

### Combat system

#### Attack table (DayZInfectedType)

Attacks are registered in `DayZInfectedType.RegisterAttacks()`. Two groups:

**CHASE** — running attacks (long range):
- Distance 2.4m, center pitch only, cooldown 0.3–0.4s

**FIGHT** — melee (close range):
- Distance 1.4–1.7m, three pitches (up/center/down)
- Light and Heavy variants
- Cooldown 0.1–0.6s, probability 0.4–0.9

Each attack: `{Distance, Pitch, Type, Subtype, AmmoType, IsHeavy, Cooldown, Probability}`

AmmoType is taken from the config: `CfgVehicles → <class> → AttackActions → AttackShort/AttackLong/AttackRun → ammoType`

#### Attack selection (ChooseAttack)

Utility function: `ComputeAttackUtility(attack, distance, pitch, random)`
1. Pitch doesn't match → 0
2. Target is farther than the attack distance → 0
3. `utilityDistance = (1 - (attackDist - targetDist) / 10) * 100` — the closest attack has priority
4. `utilityProbability = (1 - (attackProb - random)) * 10` — random factor
5. The attack with the maximum total utility wins

#### Pitch — choosing attack height

`GetAttackPitch(target)`: compares the Y position of the zombie's head (pos + 1.8m) with the target's `DefaultHitPosition`. Difference <0.3m → center (0), zombie above → down (-1), below → up (1).

#### Chase vs Fight logic

**ChaseAttackLogic** (MINDSTATE_CHASE):
1. Get the target from InputController
2. Skip if the target is in a vehicle
3. `CanAttackToPosition()` — proto native reachability check
4. `ChooseAttack(CHASE, distance, pitch)`
5. `GetMeleeTarget()` — check a 20° cone around the zombie's heading
6. If the target is in the cone → `StartCommand_Attack(target, type, subtype)`

**FightAttackLogic** (MINDSTATE_FIGHT):
- Same as above, but the cone is wider (30°), plus a **cooldown** between attacks (`m_AttackCooldownTime`)
- Cooldown decreases with multiplier `GameConstants.AI_ATTACKSPEED`

#### Dealing damage

On `WasHit()` in the attack command:
1. Check the distance to the target ≤ `m_Distance²`
2. If the player is blocking (`IsInBlock()`) and looking at the zombie (±`AI_MAX_BLOCKABLE_ANGLE`):
   - Heavy attack → dealt as `"MeleeZombie"` (reduced damage)
   - Light attack → `"Dummy_Light"` (zero damage, animation only)
3. Otherwise → full damage `m_AmmoType`

Damage is applied via `DamageSystem.CloseCombatDamageName()`, the hit zone is `GetHitComponentForAI()`.

#### HitComponents — zombie hit zones

Defined in `DayZInfectedType.RegisterHitComponentsForAI()` with weights:

| Zone | Weight | Probability |
|------|--------|-------------|
| Head | 2 | ~0.7% |
| LeftArm | 50 | ~18.7% |
| Torso | 65 | ~24.3% |
| RightArm | 50 | ~18.7% |
| LeftLeg | 50 | ~18.7% |
| RightLeg | 50 | ~18.7% |

Default: `Torso`. Finisher zones: Head, Neck, Torso.

---

### Taking damage (EEHitBy)

When a zombie is hit:

1. **Shock → Health conversion**: if the ammo has `transferShockToDamage = 1`, Shock is converted into Health (multiplier `NL_DAMAGE_CLOSECOMBAT/FIREARM_CONVERSION_INFECTED`)
2. **Special zones** (`HandleSpecialZoneDamage`): damage ≥74 to the legs → leg health = 0 (cripples). Torso/Head → `m_HeavyHitOverride = true`
3. **If dead** → `EvaluateDeathAnimation()`: pick a death animation, physical impulse if `doPhxImpulse` is set in the ammo. Records killer data, headshot detection
4. **If alive**: check the crawl transition (leg destroyed), otherwise — evaluate the hit animation

#### Stun system

`HandleDamageHit()` decides whether the zombie will be stunned:
- Throttling: minimum 0.3s between hit animations
- Stun probability: `random(0–100) ≤ SHOCK_TO_STUN_MULTIPLIER(2.82) * shockDamage`
- Heavy hit or Calm/Disturbed state → guaranteed stun

---

### Crawl — transition to crawling

An irreversible transition when a leg is destroyed:
1. `EvaluateCrawlTransitionAnimation()` — checks LeftLeg/RightLeg health = 0
2. Animation type: 0/2 = left/right leg, +1 if hit from the front
3. `StartCommand_Crawl(type)` → `m_IsCrawling = true`
4. After the transition the zombie stays in `CommandMove`, but `m_IsCrawling` is synchronized

---

### Vault

Height determines the type:
| Height | Type |
|--------|------|
| ≤ 0.6m | 0 |
| ≤ 1.1m | 1 |
| ≤ 1.6m | 2 |
| > 1.6m | 3 |

After landing (`WasLand()`) — a 2s timer before the vault command completes.

---

### Backstab (finisher)

`SetBeingBackstabbed(backstabType)`:
1. `GetAIAgent().SetKeepInIdle(true)` — AI is disabled
2. Animation choice: BACKSTAB / NECKSTAB / DEFAULT
3. `m_FinisherInProgress = true` → `CanBeTargetedByAI()` will return false for the attacker

`OnRecoverFromDeath()` — if the backstab failed:
1. `SetKeepInIdle(false)` — AI is re-enabled
2. `m_FinisherInProgress = false`

---

### Sound state machine (client)

`HandleSoundEvents()` — invoked on `OnVariablesSynchronized()`. Depends on the synchronized `m_MindState`:

| MindState | Sound event |
|-----------|-------------|
| CALM | `MINDSTATE_CALM_MOVE` |
| ALERTED | `MINDSTATE_ALERTED_MOVE` |
| DISTURBED | `MINDSTATE_DISTURBED_IDLE` |
| CHASE | `MINDSTATE_CHASE_MOVE` |
| FIGHT | Stop |

Voice animation events (`OnSoundVoiceEvent`) interrupt the state sound, after which it is restored.
