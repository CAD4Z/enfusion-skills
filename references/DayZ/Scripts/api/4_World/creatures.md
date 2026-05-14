`4_World` — creatures. Sources: `entities/creatures/infected/`, `entities/creatures/animals/`

### ZombieBase (infected)

Hierarchy: `DayZInfected` (3_Game) → `ZombieBase` → `ZombieMaleBase` / `ZombieFemaleBase` → concrete classes.

#### Synchronized variables

| Variable | Type | Description |
|-----------|-----|----------|
| `m_MindState` | int (-1..4) | CALM / ALERTED / DISTURBED / CHASE / FIGHT |
| `m_OrientationSynced` | int (0–359) | Quantized yaw (every 2s or when delta > 30°) |
| `m_MovementSpeed` | float (-1..3) | Movement speed |
| `m_IsCrawling` | bool | Crawling |

#### CommandHandler — main behavior loop

```
CommandHandler(dt, commandID, commandFinished)
 1. ModCommandHandlerBefore() → return true = full override
 2. HandleDeath() → StartCommand_Death(type, dir)
 3. HandleMove() / HandleOrientation() → sync
 4. If command finished → StartCommand_Move()
 5. ModCommandHandlerInside() → mid-flow hook
 6. HandleCrawlTransition()
 7. HandleDamageHit()
 8. HandleVault()
 9. HandleMindStateChange() → swap idle animation
10. FightLogic() → ChaseAttackLogic / FightAttackLogic → StartCommand_Attack()
11. ModCommandHandlerAfter() → post-flow hook
```

#### Overridable methods

| Method | Description |
|-------|----------|
| `ModCommandHandlerBefore(float, int, bool)` | Full override before the standard logic |
| `ModCommandHandlerInside(float, int, bool)` | Mid-loop hook |
| `ModCommandHandlerAfter(float, int, bool)` | End-of-loop hook |
| `IsZombieMilitary()` | `false`, override for military variants |
| `IsMale()` | `true`, override for female variants |
| `CanBeBackstabbed()` | `true` |
| `EvaluateDeathAnimation(source, component, ammo, out anim, out dir)` | Death animation logic |
| `GetHitComponentForAI()` | Hit zones from config |

#### Combat logic

On `COMMANDID_MOVE` + CHASE/FIGHT: get the target from `DayZInfectedInputController.GetTargetEntity()` → `CanAttackToPosition()` → pick an attack via `GetDayZInfectedType().ChooseAttack(group, distance, pitch)` → `StartCommand_Attack()`.

On hit: `DamageSystem.CloseCombatDamageName()`. Blocked attacks → `"Dummy_Light"`.

#### Sound state machine (HandleSoundEvents)

| MindState | Sound |
|-----------|------|
| CALM | `MINDSTATE_CALM_MOVE` |
| ALERTED | `MINDSTATE_ALERTED_MOVE` |
| DISTURBED | `MINDSTATE_DISTURBED_IDLE` |
| CHASE | `MINDSTATE_CHASE_MOVE` |

---

### AnimalBase (animals)

Hierarchy: `DayZAnimal` (3_Game) → `AnimalBase` → concrete classes.

Most of the logic lives in C++ `DayZAnimal`. The script side is thin.

#### Key methods

| Method | Description |
|-------|----------|
| `DeathUpdate()` | Spawn the dead item (`GetDeadItemName()`), transfer properties, `DeleteSafe()` |
| `IsSelfAdjustingTemperature()` | `return IsAlive()` — temperature self-regulation |
| `RegisterHitComponentsForAI()` | Hit zones and priority weights |
| `CaptureSound()` / `ReleaseSound()` | Sounds for traps |
| `IsDanger()` | `true` for predators (Wolf), `false` for prey |

---

### AreaDamage (damage zones)

Sources: `classes/areadamage/areadamagenew/`

#### Architecture

```
AreaDamageManager (orchestrator)
 ├── AreaDamageTriggerBase (physical trigger in the world)
 └── AreaDamageComponent (damage calculation strategy)
```

#### Component types (`SetDamageComponentType`)

| Type | Description |
|-----|----------|
| `BASE` | Fixed hit zone |
| `HITZONE` | Random zone from `SetHitZones()` |
| `RAYCASTED` | Raycast from model points → determines the zone |

#### Concrete classes

| Class | Behavior |
|-------|-----------|
| `AreaDamageOnce` | Once on entry |
| `AreaDamageOnceDeferred` | Once after a delay `m_DeferDuration` |
| `AreaDamageLooped` | Every `m_LoopInterval` seconds while inside |
| `AreaDamageLoopedDeferred` | Looped with an initial delay |
| `AreaDamageLoopedDeferred_NoVehicle` | Same, but skips passengers |

#### Usage pattern

```
AreaDamageLooped dmg = new AreaDamageLooped(parentEntity);
dmg.SetExtents("-0.5 0 -0.5", "0.5 0.5 0.5");
dmg.SetAmmoName("BarbedWireDamage");
dmg.SetDamageType(DamageType.CUSTOM);
dmg.SetDamageableTypes({DayZPlayer, ZombieBase});
dmg.SetLoopInterval(1.0);
dmg.SetDamageComponentType(AreaDamageComponentTypes.HITZONE);
dmg.Spawn();
// ...
dmg.Destroy();
```

---

### ScriptedLightBase (lighting)

Sources: `entities/scriptedlightbase.c`. Runs **client-side only**.

#### Hierarchy

```
ScriptedLightBase extends EntityLightSource
 ├── PointLightBase → FireplaceLight, TorchLight, PersonalLight...
 └── SpotLightBase → FlashlightLight, HeadTorchLight...
```

#### Creation

```
ScriptedLightBase.CreateLight(MyLight, position, fadeInSeconds);
ScriptedLightBase.CreateLightAtObjMemoryPoint(MyLight, obj, "LightPoint", "LightTarget");
light.AttachOnObject(parentObj, localPos, localOri);
```

#### Setup (in the subclass constructor)

| Method | Description |
|-------|----------|
| `SetRadiusTo(float)` | Radius |
| `SetBrightnessTo(float)` | Brightness |
| `SetDiffuseColor(r,g,b)` | Color |
| `SetAmbientColor(r,g,b)` | Ambient |
| `SetCastShadow(bool)` | Shadows (expensive) |
| `SetFlickerAmplitude/Speed(float)` | Flicker |
| `SetDancingShadowsAmplitude/MovementSpeed(float)` | Dancing shadows |
| `SetVisibleDuringDaylight(bool)` | Visibility during the day |
| `SetBlinkingSpeed(float)` | Sinusoidal blinking |

#### Control

| Method | Description |
|-------|----------|
| `FadeBrightnessTo(value, time)` | Smooth brightness change |
| `FadeRadiusTo(value, time)` | Smooth radius change |
| `FadeIn(time)` / `FadeOut(time)` | Fade in / fade out |
| `SetLifetime(seconds)` | Auto-destroy |
| `Destroy()` | Safe destruction |

#### Hook

```
override void OnFrameLightSource(IEntity other, float timeSlice)
{
    // Each frame — dynamic behavior
}
```
