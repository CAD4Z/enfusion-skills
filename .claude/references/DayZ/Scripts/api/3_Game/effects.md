Effects system and post-processing. Sources: `effect.c`, `effectmanager.c`, `effects/`, `ppemanager/`

### EffectType

```
NONE, SOUND, PARTICLE
```

### Effect

Base class for effects. Managed. Source: `effect.c`

| Method | Description |
|--------|-------------|
| `Start()` / `Stop()` | Start/stop |
| `IsPlaying()` | Playing |
| `GetEffectType()` | Type (`SOUND` / `PARTICLE`) |
| `SetParent(parent)` / `GetParent()` | Parent entity |
| `SetLocalPosition(pos)` / `SetLocalOrientation(ori)` | Local position/orientation |
| `SetAttachmentPivotIdx(idx)` | Attachment pivot index |
| `SetAutodestroy(state)` | Auto-destroy after stop |
| `ValidateStart()` | Validation hook before start |
| `IsRegistered()` / `GetID()` | Registration in SEffectManager |

#### Events (ScriptInvoker)

`Event_OnStarted`, `Event_OnStopped`, `Event_OnEffectStarted`, `Event_OnEffectEnded`

### EffectParticle

Inherits `Effect`. Particle wrapper. Source: `effects/effectparticle.c`

| Method | Description |
|--------|-------------|
| `GetParticle()` | `Particle` object |
| `SetOrientation(ori)` | Orientation |

### EffectSound

Inherits `Effect`. Sound wrapper. Source: `effects/effectsound.c`

| Method | Description |
|--------|-------------|
| `FadeIn(seconds)` / `FadeOut(seconds)` | Fade in/out |
| `SetVolume(vol)` / `SetPitch(pitch)` | Volume / pitch |

### SEffectManager

Static global effects manager. Source: `effectmanager.c`

#### Effect management

| Method | Description |
|--------|-------------|
| `PlayInWorld(effect, pos)` | Play in the world |
| `PlayOnObject(effect, obj, local_pos, local_ori, force_rotation)` | On an object |
| `Stop(effect_id)` | Stop by ID |
| `EffectRegister(effect)` / `EffectUnregister(effect)` | Registration |

#### Sound shortcuts

| Method | Description |
|--------|-------------|
| `CreateSound(soundSet, pos, ...)` | Create EffectSound |
| `PlaySound(soundSet, pos, ...)` | Create and play |
| `PlaySoundParams(params, pos, ...)` | With SoundParams |

#### System

| Method | Description |
|--------|-------------|
| `Init()` / `InitServer()` / `Cleanup()` | Lifecycle |
| `Event_OnFrameUpdate` | Per-frame update invoker |

### Bullet Impact effects

Hit effects system. Source: `effects/generated/`. Every effect is a descendant of `BulletImpactBase`.

Key ones: `Hit_MeatBones`, `Hit_Metal`, `Hit_Wood`, `Hit_Concrete`, `Hit_Glass`, `Hit_Water`, `Hit_Dirt`, `Hit_Sand`, `Hit_Foliage`, `Hit_Grass`, `Hit_Plastic`, `Hit_Rubber`, `Hit_Ice`, `Hit_Snow`, `Hit_Textile`, `Hit_Plaster`

### Special effects

| Class | Description |
|-------|-------------|
| `BleedingSource` | Bleeding visualization |
| `BloodSplatter` | Blood splatter |
| `Vomit` / `VomitBlood` | Vomit |
| `BreathVapourLight/Medium/Heavy` | Breath vapor |
| `SwarmingFlies` | Flies |
| `VehicleSmoke` / `EngineSmoke` / `ExhaustSmoke` | Vehicle smoke |
| `GeneratorSmoke` | Generator smoke |
| `LandmineExplosion` | Mine explosion |

---

## PPEManager (post-processing system)

Centralized post-processing management. Source: `ppemanager/`

### Architecture

```
PPEManager (singleton)
├── PPEClassBase (material class — one effect type)
│   └── PPEMatClassParameter* (parameters: float, int, bool, color, vector, texture)
└── PPERequesterBase (requester — requests an effect)
    └── PPERequestData (request data)
```

**Flow**: requester → calls `SetTargetValueFloat/Color/...` on material class parameters → PPEManager aggregates all requests and applies the result.

### PPEManagerStatic

| Method | Description |
|--------|-------------|
| `GetPPEManager()` | Get the singleton |
| `CreateManagerStatic()` / `DestroyManagerStatic()` | Lifecycle |

### PPERequesterBase

Base requester class. Each requester is a single visual effect.

| Method | Description |
|--------|-------------|
| `Start(settings)` / `Stop(settings)` | Start/stop |
| `SetTargetValueFloat(matIdx, paramIdx, value, priority, op)` | Float parameter |
| `SetTargetValueColor(matIdx, paramIdx, color, priority, op)` | Color (vector4) |
| `SetTargetValueBool(matIdx, paramIdx, value, priority, op)` | Bool |
| `SetTargetValueInt(matIdx, paramIdx, value, priority, op)` | Int |

### Parameter types

| Class | Data type |
|-------|-----------|
| `PPEMatClassParameterFloat` | `float` |
| `PPEMatClassParameterInt` | `int` |
| `PPEMatClassParameterBool` | `bool` |
| `PPEMatClassParameterColor` | `vector` (RGBA) |
| `PPEMatClassParameterVector` | `vector` |
| `PPEMatClassParameterTexture` | Texture resource |

### Key requesters

| Class | Effect |
|-------|--------|
| `PPERPain` | Pain |
| `PPERBloodLoss` | Blood loss (vignette) |
| `PPERHealthHit` | Hit flash |
| `PPERCameraNV` | Night vision (green tint) |
| `PPERCameraADS_OPT` | Zoom when aiming |
| `PPERBurlapsack` | Burlap sack on head |
| `PPERContaminated` | Contamination (blur) |
| `PPERDrowningEffect` | Drowning |
| `PPERUnconEffects` | Unconscious state |
| `PPERFever` | Fever |
| `PPERShockHit` | Shock |
| `PPERFlashbangEffects` | Flashbang grenade |
| `PPERDeathDarkening` | Darkening on death |
| `PPERTunnel` | Tunnel vision |
| `PPERGlasses` | Glasses |

Others: `PPERControlsBlur`, `PPERInventoryBlur`, `PPERFeedbackBlur`, `PPERLatencyBlur`, `PPERTutorial`, `PPERUndergroundAcco`, `PPERSpooky`, `PPERIntroChromaBB`, `PPERHMPGhosts`, `PPERHMPLevel3`, `PPERServerBrowser`, `PPERMenuEffects`, `PPERControllerDisconnectBlur`

### Material classes (PPEClassBase)

| Class | Effect |
|-------|--------|
| `PPEDepthOfField` / `PPEDOF` | Depth of field |
| `PPEChromAber` | Chromatic aberration |
| `PPERadialBlur` | Radial blur |
| `PPEDynamicBlur` | Dynamic blur |
| `PPEGaussFilter` | Gaussian blur |
| `PPERotBlur` | Rotational blur |
| `PPEColorGrading` | Color grading |
| `PPEColors` | Color settings |
| `PPEGlow` | Glow (bloom) |
| `PPEFilmGrain` | Film grain |
| `PPEGodRays` | God rays |
| `PPERain` | Rain on screen |
| `PPESnowfall` | Snow on screen |
| `PPEUnderWater` | Underwater distortion |
| `PPEWetDistort` | Wet distortion |
| `PPEDistort` | General distortion |
| `PPEGhost` | Ghost-like glares |
| `PPESunMask` | Sun mask |

Anti-aliasing: `PPESMAA`, `PPEFXAA`, `PPEMedian`

Native: `PPEExposureNative`, `PPEEyeAccomodationNative`, `PPELightIntensityParamsNative`
