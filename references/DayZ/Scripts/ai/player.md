Player: Man (3_Game) → Human (3_Game) → DayZPlayer (3_Game) → DayZPlayerImplement (4_World) → PlayerBase (4_World). The deepest hierarchy — the player is controlled by input rather than AI, but interacts with the AI system as a target.

### Hierarchy

```
EntityAI
 └── Man (3_Game)                     — identity, inventory, speech, TOUCHTRIGGERS
      └── Human (3_Game)              — physics, transforms, commands, InputController
           └── DayZPlayer (3_Game)    — HeadingModel, AimingModel, CommandHandler, camera, deterministic random
                └── DayZPlayerImplement (4_World) — CommandHandler implementation, damage, weapons, melee
                     └── PlayerBase (4_World)     — gameplay wrapper: unconsciousness, stamina, injuries, quickbar
```

Alongside:
```
ManType → DayZPlayerType             — HitComponents, NoiseParams, noise templates
HumanInputController                 — player input (proto native), full analog of DayZCreatureAIInputController
AITargetCallbacksPlayer              — visibility for AI (speed + stance → modifier)
DayZPlayerMeleeFightLogic_LightHeavy — melee combat logic
```

---

### Key difference from creatures

For creatures (infected/animals), **native AI** drives them via `InputController.GetMindState()` while the script reacts. For the player it is the opposite:

- **Input** — from HumanInputController (keyboard/gamepad → proto native)
- **Decisions** — scripted (CommandHandler, FightLogic, ActionManager)
- **AI role** — only as a **target** (AITargetCallbacksPlayer, HitComponentsForAI, NoiseSystem)

---

### Man — the base layer

Inherits EntityAI. Adds:

- `GetIdentity()` — PlayerIdentity (proto native)
- `GetEntityInHands()` / `GetHumanInventory()` — inventory (proto native)
- `IsSoundInsideBuilding()` / `IsCameraInsideVehicle()` — sound attenuation
- `SetFaceTexture()` / `SetFaceMaterial()` — model customization
- `SetSpeechRestricted()` — speech restriction

`Man` sets `EntityFlags.TOUCHTRIGGERS` — reacts to triggers in the world.

---

### Human — physics and commands

**Physics** (proto native):
- `PhysicsGetPositionWS/LS()` — position in world/local space
- `PhysicsIsFalling(validate)` — falling check
- `PhysicsGetVelocity(out velocity)` — controller velocity
- `PhysicsSetSolid(solid)` / `PhysicsSetRagdoll(enable)` — collisions and ragdoll
- `CheckFreeSpace(dir, dist)` — check free space for the collider

**Alignment** (proto native):
- `AlignPositionWS(pos)` / `AlignDirectionWS(dir)` — smooth movement/rotation
- `AlignTranslationWS/LS(translation)` — offset in world/local space

**Linking** (proto native):
- `LinkToLocalSpaceOf(child, matrix)` / `UnlinkFromLocalSpace()` — link to another entity (vehicle)

#### Commands (proto native)

14 main commands + 4 modifiers. Each command is a native state controlling animation and physics:

| Command | COMMANDID | Purpose |
|---------|-----------|---------|
| `StartCommand_Move()` | `COMMANDID_MOVE` | Movement (idle/walk/run/sprint) |
| `StartCommand_Melee2(target, hitType, combo)` | `COMMANDID_MELEE2` | Melee |
| `StartCommand_Fall(yVelocity)` | `COMMANDID_FALL` | Fall (≤0) / Jump (>0) |
| `StartCommand_Ladder(building, index)` | `COMMANDID_LADDER` | Ladder |
| `StartCommand_Swim()` | `COMMANDID_SWIM` | Swimming |
| `StartCommand_Vehicle(transport, pos, seat)` | `COMMANDID_VEHICLE` | Vehicle |
| `StartCommand_Climb(result, type)` | `COMMANDID_CLIMB` | Climbing |
| `StartCommand_Death(type, dir, callback)` | `COMMANDID_DEATH` | Death |
| `StartCommand_Unconscious(type)` | `COMMANDID_UNCONSCIOUS` | Unconsciousness |
| `StartCommand_Damage(type, dir)` | `COMMANDID_DAMAGE` | Full-body damage (stagger) |
| `StartCommand_Action(actionID, callback, stanceMask)` | `COMMANDID_ACTION` | Action (full-body) |
| `StartCommand_Script(cmd)` | `COMMANDID_SCRIPT` | Script command |

**Modifiers** — additive behaviors on top of the main command:

| Modifier | Purpose |
|----------|---------|
| `GetCommandModifier_Additives()` | Head, talking (always-on) |
| `GetCommandModifier_Weapons()` | Weapons: actions, animations (always-on) |
| `AddCommandModifier_Action(actionID, callback)` | Additive action |
| `AddCommandModifier_Damage(type, dir)` | Light damage (additive) |

**Events** — start/end callbacks for each command:
`OnCommandMoveStart/Finish()`, `OnCommandDeathStart/Finish()`, `OnCommandVehicleStart/Finish()`, `OnStanceChange(prev, new)`, etc.

---

### HumanInputController — player input

**Fully proto native**. The analog of `DayZCreatureAIInputController`, but the source is player input rather than the AI brain.

**Movement**:
- `GetMovement(out speed, out localDir)` — speed 0..3 (idle/walk/run/sprint), direction
- `GetHeadingAngle()` — camera direction in radians

**Aiming**:
- `GetAimChange()` / `GetAimDelta(dt)` — per-tick aim change (radians)
- `IsWeaponRaised()` / `WeaponADS()` — whether the weapon is raised, ADS mode

**Actions**:
- `IsUseItemButton()` / `IsAttackButton()` — action / fire (per tick)
- `IsSingleUse()` / `IsContinuousUse()` — single / continuous action (not raised)
- `IsJumpClimb()` — jump/climb
- `IsStanceChange()` — stance change

**Melee**:
- `IsMeleeEvade()` — evasion (SHIFT)
- `IsMeleeFastAttackModifier()` — heavy attack (SHIFT held)
- `IsMeleeLREvade()` — left/right evasion (0/1/2)
- `IsMeleeWeaponAttack()` — weapon strike

**Override methods** — the script can intercept input:

| Override | What it intercepts |
|----------|--------------------|
| `OverrideMovementSpeed(type, value)` | Speed |
| `OverrideMovementAngle(type, value)` | Direction |
| `OverrideAimChangeX/Y(type, value)` | Aiming |
| `OverrideMeleeEvade(type, value)` | Evasion |
| `OverrideRaise(type, value)` | Raising the weapon |
| `OverrideFreeLook(type, value)` | Free look |

`HumanInputControllerOverrideType`: `DISABLED` — return control, `ENABLED` — persistent interception, `ONE_FRAME` — for one tick.

---

### DayZPlayer — logic and camera

**HeadingModel** (per tick):
- `SDayZPlayerHeadingModel` — inputs: `m_iCamMode`, `m_iCurrentCommandID`. Outputs: `m_fOrientationAngle` (where the model faces), `m_fHeadingAngle` (where it aims)
- The script overrides `HeadingModel()` to modify behavior

**AimingModel** (per tick):
- `SDayZPlayerAimingModel` — inputs: camera, current angles. Outputs: camera/hand offsets, mouse shift
- Allows separating the camera and the model (free look, recoil)

**Camera**:
- `CameraHandler(cameraMode)` — returns the camera type for the mode
- `GetCurrentCamera()` / `GetCurrentCameraTransform()` — current camera (proto native)

**Animation graph** (only from CommandHandler):
- `AnimCallCommand(cmd, paramInt, paramFloat)` — call an animgraph command
- `AnimSetFloat/Int/Bool(var, value)` — set variables

**Deterministic random** — `Random()`, `RandomRange(range)`, `Random01()` — only from CommandHandler. Synchronized between client and server for prediction.

**Melee** (proto native):
- `ProcessMeleeHit(weapon, mode, target, component, hitPos)` — handle a melee hit
- `GetMeleeCombatData()` — current melee data

---

### CommandHandler — DayZPlayerImplement

Full per-tick cycle (simplified):

```
CommandHandler(dt, currentCommandID, currentCommandFinished)
 1. EvaluateDamageHit()                → prepare hit animation (before Jump)
 2. super.CommandHandler()             → DayZPlayer (empty, for overriding)
 3. ModCommandHandlerBefore()          → mod interception
 4. HandleADS()                        → aiming logic
 5. HandleWeapons()                    → firing, reloading
 6. HandleView()                       → camera switching
 7. HandleDeath()                      → StartCommand_Death
 8. Vehicle: swim check on exit        → StartCommand_Swim
 9. If currentCommandFinished:
    - From Unconscious to Vehicle      → StartCommand_Vehicle
    - PhysicsIsFalling                 → StartCommand_Fall
    - Was swimming                     → StartCommand_Swim
    - Default                          → StartCommand_Move
10. ModCommandHandlerInside()
11. Vehicle gear change                → AddCommandModifier_Action
12. Swimming handling                  → CheckSwimmingStart
13. Ladder / Climb                     → specific logic
14. Fall handling                      → FallDamage + noise on landing
15. ProcessJumpOrClimb()               → jump / climb
16. VoN noise                          → AddNoise by voice level
17. HandleDamageHit()                  → StartCommand_Damage / AddCommandModifier_Damage
18. Unconsciousness                    → StartCommand_Unconscious / WakeUp
19. QuickBar                           → OnQuickBarSingleUse / ContinuousUse
20. Melee (FightLogic)                 → HandleFightLogic
21. ModCommandHandlerAfter()
```

Then PlayerBase adds:
- Broken legs, hold breath, weapon/emote/stamina/injury/shock managers update
- Map handling, drowning, stamina sprint limits

---

### Damage system (EEHitBy)

When the player is hit:

1. **Shock tracking**: records `m_LastShockHitTime`, `m_UnconRefillModifier` from the ammo config
2. **Special ammunition**: FlashGrenade → full stamina depletion
3. **Bleeding**: `BleedingManagerServer.ProcessHit()` — a separate system from creatures
4. **Shock → Health**: if `transferShockToDamage = 1` → conversion + damage by zone
5. **Broken legs**: leg/foot health ≤1 → activates the `MDF_BROKEN_LEGS` modifier
6. **Special projectile** (`Bullet_CupidsBolt`): full restoration of all zones, modifiers reset

#### Hit animation (EvaluateDamageHitAnimation)

The logic differs from creatures — it depends on the damage type:

| Damage type | Fullbody condition |
|-------------|--------------------|
| CLOSE_COMBAT | `hitAnimation = 1` in the ammo config + not blocking. From infected — light only |
| FIRE_ARM | `impactBehaviour = 1` + (fireDmg > 80 or shockDmg > 40) + Torso/Head |
| EXPLOSION | No fullbody |

**Throttling**: minimum `HIT_INTERVAL_MIN` (0.3s) between full-body hit animations.

**Fullbody vs Additive**: fullbody → `StartCommand_Damage()` (interrupts the current command), additive → `AddCommandModifier_Damage()` (on top of the current command).

---

### Melee (MeleeFightLogic)

`DayZPlayerMeleeFightLogic_LightHeavy` — all the logic is in the script:

**Attack types** (`EMeleeHitType`):
- `LIGHT` / `HEAVY` — normal strikes (SHIFT = Heavy)
- `WPN_HIT` / `WPN_STAB` / `WPN_HIT_BUTTSTOCK` — weapon strikes (bayonet / buttstock)
- Sprint attack — only at full sprint (>0.5s sprinting, speed >2.99)

**Attack initiation** depends on stance:
- `STANCEIDX_RAISEDERECT` → normal strike (light/heavy) + finishers
- `STANCEIDX_RAISEDPRONE` → prone kick
- `STANCEIDX_ERECT` + sprint → sprint attack

**Combo**: in `COMMANDID_MELEE2`, if `IsInComboRange()` → continue the combo

**Blocking and evasion** (only `STANCEIDX_RAISEDERECT`):
- Evasion: `IsMeleeLREvade()` → `StartMeleeEvadeA(±90°)`, consumes stamina
- Block: `IsInBlock()` → reduces/nullifies incoming damage from infected

---

### AI interaction — the player as a target

#### HitComponents

Defined in `DayZPlayerType`:

| Zone | Weight | Probability |
|------|--------|-------------|
| dmgZone_leftArm | 50 | ~20.4% |
| dmgZone_torso | 65 | ~26.5% |
| dmgZone_rightArm | 50 | ~20.4% |
| dmgZone_leftLeg | 40 | ~16.3% |
| dmgZone_rightLeg | 40 | ~16.3% |

Default: `dmgZone_torso`. Head is commented out (`// TMP comment out`). Finisher zones: `Head`.

#### AITargetCallbacksPlayer — visibility

Determines how well the AI sees the player:

**GetVisionPointPositionWS** — the point the AI tries to see:
- Infected with `MINDSTATE_ALERTED+` → the player's head
- Otherwise → chest (Spine3) or fallback `pos + "0 1 0"`

**GetMaxVisionRangeModifier** — detection range modifier:
- Formula: `(speedCoef + stanceCoef) / 2`
- Speed: `IDLE` / `WALK` / `RUN` (coefficients from PlayerConstants)
- Stance: `STANDING` / `CROUCH` / `PRONE`
- Crouch+run → WALK (for visibility), Prone+anything → WALK
- Stance reduces effective speed for visibility computation

#### Noise (NoiseSystem)

The player generates noise in several situations:

| Source | NoiseParams | Multiplier |
|--------|-------------|-----------|
| Footsteps | Stand/Crouch/Prone | `GetNoiseMultiplier(player) * weatherReduction` |
| Landing (>0.5m) | LandLight / LandHeavy | `weatherReduction` |
| Voice chat | Whisper/Talk/Shout | `weatherReduction` (every 1s) |
| Sound events | AnimEvent.NoiseParams | `weatherReduction` |

`NoiseAIEvaluate.GetNoiseMultiplier(player)` — accounts for speed, footwear, surface (see more in `references/DayZ/Scripts/ai/infrastructure.md`).

---

### Unconsciousness

Managed via `m_ShouldBeUnconscious` (the server sets it via SyncJuncture):

**Entry**: `StartCommand_Unconscious(0)` — when `m_ShouldBeUnconscious = true` and the current command is not Death/Fall/vehicle transition.

**While in state**: `OnUnconsciousUpdate(dt, lastCommandBefore)` — may start swimming if in water.

**Exit**: `WakeUp(wakeUpStance)` — minimum after 2s (`m_UnconsciousTime > 2`). Stance: prone, except for swimming and vehicle.

**From a vehicle**: stores `m_TransportCache` → on exit from unconsciousness, returns to the vehicle.

---

### Death

`HandleDeath()` in DayZPlayerImplement:

1. Determine animation type: `DEATH_DEFAULT` → `GetTypeOfDeath(commandID)`, or `DEATH_FAST` if the ammo has `doPhxImpulse`
2. If in a vehicle: `CrewDeath(seat)` or `CrewGetOut(seat)`, `MarkCrewMemberDead(seat)`
3. If the driver: `Possess(this)` — returns control to the dead player so others can use the vehicle
4. `StartCommand_Death(type, dir, callback)` — taking `keepInLocalSpace` for the vehicle into account
