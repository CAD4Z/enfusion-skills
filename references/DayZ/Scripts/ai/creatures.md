DayZCreature → DayZCreatureAI — the shared pipeline for all AI-controlled creatures (infected and animals). An intermediate layer between EntityAI and specific types.

### Hierarchy

```
EntityAI
 └── DayZCreature                    — animations, bones, mod hooks
      └── DayZCreatureAI             — AI agent, sounds, damage, events
           ├── DayZInfected          — infected (see infected.md)
           └── DayZAnimal            — animals (see animals.md)
```

Alongside — the type classes:
```
EntityAIType → DayZCreatureAIType    — template: AnimEvents from config
               ├── DayZInfectedType  — attacks, infected HitComponents
               └── DayZAnimalType    — (empty)
```

---

### DayZCreature — the animation foundation

Inherits EntityAI. All key methods are **proto native**.

**Animation interface** (`DayZCreatureAnimInterface`):
- `BindCommand(name)` — bind an animgraph command
- `BindVariableFloat/Int/Bool(name)` — bind animgraph variables
- `BindTag(name)` / `BindEvent(name)` — tags and events

**Animation control**:
- `SetAnimationInstanceByName(name, uuid, duration)` — switch the animation set
- `GetCurrentAnimationInstanceUUID()` — current UUID

**Death** (proto native):
- `StartDeath()` / `ResetDeath()` / `ResetDeathCooldown()`
- `IsDeathProcessed()` / `IsDeathConditionMet()`

**CommandHandler mod hooks** — three interception points, the same for all creatures:

| Hook | Moment | Returning true |
|------|--------|----------------|
| `ModCommandHandlerBefore(dt, cmdID, finished)` | Before standard logic | Full interception |
| `ModCommandHandlerInside(dt, cmdID, finished)` | In the middle | Interruption |
| `ModCommandHandlerAfter(dt, cmdID, finished)` | After standard logic | Post-processing interception |

---

### DayZCreatureAI — the AI layer

Adds an AI agent and an animation event system on top of DayZCreature.

**AI agent** (proto native):
- `GetAIAgent()` — get the AIAgent (link to AIWorld)
- `InitAIAgent(group)` — manual initialization (for entities created with `init_ai = false`)
- `DestroyAIAgent()` — destroy the agent

**Damage zone** (proto native):
- `AddDamageSphere(bone, ammo, radius, duration, invertTeams)` — create a damage sphere on a model bone for `duration` time. `invertTeams` — deal damage to allies (`false` = to hostiles)

**On death**: creates `COMP_TYPE_BODY_STAGING` for the skinning system.

**Cinematic Controller**: lets the player control the creature directly through input (override `ModCommandHandlerBefore`).

#### Animation event system

The engine calls functions when events occur in an animation. Registered in the constructor via `RegisterAnimationEvent(eventName, functionName)`:

| Event | Function | What happens |
|-------|----------|--------------|
| `"Sound"` | `OnSoundEvent` | Plays a sound + emits noise for AI |
| `"SoundVoice"` | `OnSoundVoiceEvent` | Voice sound + noise + attenuation |
| `"Step"` | `OnStepEvent` | Footstep sound on the surface (client only) |
| `"Damage"` | `OnDamageEvent` | Creates a DamageSphere |

The event config is loaded via `DayZCreatureAIType` from `CfgVehicles → <class> → AnimEvents`:

```
AnimEvents
 ├── Sounds    → AnimSoundEvent      (ID, SoundBuilder, NoiseParams)
 ├── SoundVoice → AnimSoundVoiceEvent (ID, SoundBuilder, NoiseParams)
 ├── Steps     → AnimStepEvent       (ID, SurfaceLookup, NoiseParams)
 └── Damages   → AnimDamageEvent     (ID → CfgDamages: bone, ammo, radius, duration)
```

Each sound/voice event can carry `NoiseParams` — on the server it automatically generates noise via `NoiseSystem` taking weather into account.

Attenuation: if the creature and the player are on opposite sides of a building wall (or the player is in a vehicle), the sound switches to `WaveKind.WAVEATTALWAYS` (muffled).

---

### DayZCreatureAIInputController — control from AI

**Fully proto native**. This is the interface between the native AI brain and script logic. The AI (C++) controls the creature; the script can override via Override methods.

| Parameter | Override | Get |
|-----------|----------|-----|
| Movement speed | `OverrideMovementSpeed(state, speed)` | `GetMovementSpeed()` |
| Turn speed | `OverrideTurnSpeed(state, speed)` | `GetTurnSpeed()` |
| Heading | `OverrideHeading(state, heading)` | `GetHeading()` |
| Jump | `OverrideJump(state, type, height)` | `IsJump()`, `GetJumpType()`, `GetJumpHeight()` |
| Look | `OverrideLookAt(state, direction)` | `IsLookAtEnabled()`, `GetLookAtDirectionWS()` |
| Alert level | `OverrideAlertLevel(state, alerted, level, inLevel)` | `GetAlertLevel()`, `IsAlerted()` |
| Behavior slot | `OverrideBehaviourSlot(state, slot)` | `GetBehaviourSlot()` |

Override pattern: `state=true` — the script takes control, `state=false` — control returns to the AI.

---

### CommandHandler — the central loop

Each tick the engine calls `CommandHandler(dt, currentCommandID, currentCommandFinished)`. This is the **main decision-making point** for the creature.

General structure (the same for animals and infected):

```
1. ModCommandHandlerBefore() → return true = mod has intercepted
2. HandleDeath() → if dead, stay in Death
3. If currentCommandFinished → StartCommand_Move() (return to movement)
4. ModCommandHandlerInside()
5. HandleDamageHit() → handle received damage
6. Specific logic (attacks, vault, mind state...)
7. ModCommandHandlerAfter()
```

**Commands** are proto native states controlling animation and physics:

Animals (`DayZAnimalConstants`):
`COMMANDID_MOVE`, `COMMANDID_JUMP`, `COMMANDID_DEATH`, `COMMANDID_HIT`, `COMMANDID_ATTACK`, `COMMANDID_SCRIPT`

Infected (`DayZInfectedConstants`):
`COMMANDID_MOVE`, `COMMANDID_VAULT`, `COMMANDID_DEATH`, `COMMANDID_HIT`, `COMMANDID_ATTACK`, `COMMANDID_CRAWL`, `COMMANDID_SCRIPT`

`StartCommand_*()` — switch to a new command (proto native). The current command is interrupted, the new one starts. When the command finishes, `currentCommandFinished = true`, and CommandHandler decides what to do next (usually `StartCommand_Move()`).

---

### DayZAnimalCommandScript — scripted commands

Fully scripted behavior for cases when native commands are not enough. **Non-managed** — once handed to CommandHandler, it is controlled by C++.

Two per-tick stages:
1. **PrePhys** — set the transform before physics (`PrePhys_SetTranslation/Rotation` in local space)
2. **PostPhys** — correct after physics (`PostPhys_SetPosition/Rotation` in world space)

`SetFlagFinished(true)` — finish the scripted command, CommandHandler will receive `currentCommandFinished = true`.

---

### Damage handling

Shared pattern for all creatures:

1. `EEHitBy()` — damage received from the engine
2. Compute hit `type` and `direction` (`ComputeDamageHitParams`)
3. `QueueDamageHit(type, direction)` — store for the next tick
4. In `CommandHandler` → `HandleDamageHit()` → `StartCommand_Hit(type, direction)`

Hit direction: the angle between the creature's facing direction and the vector to the damage source → front (±20°) / left / right. Additional offset by hit zone (head, chest, other).
