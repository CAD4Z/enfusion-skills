Particle system. Sources: `particles/`

### ParticleManager

Singleton manager of the particle pool. Source: `particles/particlemanager.c`

#### Creation and management

| Method | Description |
|--------|-------------|
| `CreateParticle(particleId, pos, playOnCreation, parent, ori, forceWorldRotation)` | Create a particle |
| `CreateParticleEx(particleId, pos, flags, parent, ori)` | Create with flags |
| `PlayParticle(particleId, pos, parent)` | Create and play |
| `StopParticle(particle)` | Stop |
| `DeleteParticle(particle)` | Delete |

#### Lifecycle

| Method | Description |
|--------|-------------|
| `CleanupInstance()` | Destroy the singleton |

#### Settings

`ParticleManagerSettings` — pool configuration.

`ParticleManagerSettingsFlags`:
```
NONE, FIXED_INDEX, BLOCKING, DISABLE_VIRTUAL, REUSE_OWNED
```

### ParticleSource

Particle emitter source. Proto native.

| Method | Description |
|--------|-------------|
| `Play()` / `Stop()` | Playback |
| `IsPlaying()` | Active |

### ParticleProperties

Particle properties.

`ParticlePropertiesFlags`:
```
PLAY_ON_CREATION — autostart
FORCE_WORLD_ROT — force world rotation
```

### ParticleList

Registry of particle IDs. Proto native. Contains identifier constants for all in-game particles.
