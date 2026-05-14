Sound system and dynamic music. Sources: `sound.c`, `systems/dynamicmusicplayer/`

### WaveKind

Sound categories:

```
WAVEEFFECT, WAVEEFFECTEX, WAVESPEECH, WAVEMUSIC, WAVESPEECHEX,
WAVEENVIRONMENT, WAVEENVIRONMENTEX, WAVEWEAPONS, WAVEWEAPONSEX,
WAVEATTALWAYS, WAVEUI
```

### AbstractSoundScene

Main sound scene. Access: `g_Game.GetSoundScene()`. Proto native.

#### Playback

| Method | Return | Description |
|--------|--------|-------------|
| `Play2D(soundObject, builder)` | `AbstractWave` | Play 2D |
| `Play3D(soundObject, builder)` | `AbstractWave` | Play 3D |
| `BuildSoundObject(builder)` | `SoundObject` | Build object from builder |

#### Volume

| Method | Description |
|--------|-------------|
| `GetRadioVolume()` / `SetRadioVolume(vol)` | Radio |
| `GetSpeechExVolume()` / `SetSpeechExVolume(vol)` | Speech |
| `GetMusicVolume()` / `SetMusicVolume(vol)` | Music |
| `GetSoundVolume()` / `SetSoundVolume(vol)` | Sounds |
| `GetVOIPVolume()` / `SetVOIPVolume(vol)` | Voice chat |
| `GetSilenceThreshold()` / `SetSilenceThreshold(val)` | Silence threshold |
| `GetAudioLevel()` | Current level |

### SoundParams

Sound parameters. Proto native.

| Method | Description |
|--------|-------------|
| `Load(name)` | Load by name |
| `IsValid()` | Validity |
| `GetName()` | Name |

### SoundObjectBuilder

Sound object configurator. Proto native.

| Method | Description |
|--------|-------------|
| `Initialize(soundParams)` | Initialize from SoundParams |
| `AddEnvSoundVariables(position)` | Add environment variables for position |
| `AddVariable(name, value)` | Add a variable |

### SoundObject

Sound object instance. Proto native.

| Method | Description |
|--------|-------------|
| `SetParent(entity, pivot)` / `GetParent()` | Bind to entity |
| `SetPosition(pos)` / `GetPosition()` | Position |
| `SetSpeed(vel)` / `GetSpeed()` | Velocity (for Doppler) |
| `SetOcclusionObstruction(occlusion, obstruction)` | Occlusion and obstruction |
| `SetKind(WaveKind)` | Category |

### AbstractWave

Playback control. Proto native.

#### Playback

| Method | Description |
|--------|-------------|
| `Play()` / `Stop()` / `Restart()` | Control |
| `Loop(enable)` | Looping |
| `GetLength()` | Duration |
| `GetCurrPosition()` | Current position |
| `Skip(seconds)` | Skip |

#### Volume and frequency

| Method | Description |
|--------|-------------|
| `GetVolume()` / `SetVolume(vol)` | Volume |
| `SetVolumeRelative(vol)` | Relative volume |
| `GetFrequency()` / `SetFrequency(freq)` | Frequency |
| `SetFadeInFactor(factor)` / `SetFadeOutFactor(factor)` | Fade factors |
| `SetDoppler(enable)` | Doppler effect |

#### Position

| Method | Description |
|--------|-------------|
| `SetPosition(pos, velocity)` | World position and velocity |
| `IsHeaderLoaded()` | Header loaded |

#### Events (ScriptInvoker)

`Event_OnSoundWaveStarted`, `Event_OnSoundWaveStopped`, `Event_OnSoundWaveLoaded`, `Event_OnSoundWaveHeaderLoaded`, `Event_OnSoundWaveEnded`

### SoundControllerAction

```
None, Limit, Overwrite
```

### Playback pattern

```enforcescript
SoundParams params = new SoundParams("MySound_SoundSet");
SoundObjectBuilder builder = new SoundObjectBuilder(params);
builder.AddEnvSoundVariables(position);
SoundObject soundObj = g_Game.GetSoundScene().BuildSoundObject(builder);
soundObj.SetPosition(position);
AbstractWave wave = g_Game.GetSoundScene().Play3D(soundObj, builder);
wave.SetVolume(0.8);
wave.Loop(true);
```

### DynamicMusicPlayer

Dynamic music system. Source: `systems/dynamicmusicplayer/`

Manages background music depending on the gameplay situation (combat, night, location).

#### Categories (EDynamicMusicPlayerCategory)

Define the playback context: time of day, biome, situation.

#### Per-map registries

| Class | Map |
|-------|-----|
| `DynamicMusicPlayerRegistryChernarus` | Chernarus |
| `DynamicMusicPlayerRegistryEnoch` | Livonia |
| `DynamicMusicPlayerRegistrySakhal` | Sakhal |

Each registry contains arrays of tracks bound to categories and map zones.
