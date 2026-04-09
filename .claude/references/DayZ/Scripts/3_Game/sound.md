Звуковая система и динамическая музыка. Источники: `sound.c`, `systems/dynamicmusicplayer/`

### WaveKind

Категории звуков:

```
WAVEEFFECT, WAVEEFFECTEX, WAVESPEECH, WAVEMUSIC, WAVESPEECHEX,
WAVEENVIRONMENT, WAVEENVIRONMENTEX, WAVEWEAPONS, WAVEWEAPONSEX,
WAVEATTALWAYS, WAVEUI
```

### AbstractSoundScene

Главная звуковая сцена. Доступ: `g_Game.GetSoundScene()`. Proto native.

#### Воспроизведение

| Метод | Возврат | Описание |
|-------|---------|----------|
| `Play2D(soundObject, builder)` | `AbstractWave` | Воспроизвести 2D |
| `Play3D(soundObject, builder)` | `AbstractWave` | Воспроизвести 3D |
| `BuildSoundObject(builder)` | `SoundObject` | Создать объект из builder |

#### Громкость

| Метод | Описание |
|-------|----------|
| `GetRadioVolume()` / `SetRadioVolume(vol)` | Радио |
| `GetSpeechExVolume()` / `SetSpeechExVolume(vol)` | Речь |
| `GetMusicVolume()` / `SetMusicVolume(vol)` | Музыка |
| `GetSoundVolume()` / `SetSoundVolume(vol)` | Звуки |
| `GetVOIPVolume()` / `SetVOIPVolume(vol)` | Голосовой чат |
| `GetSilenceThreshold()` / `SetSilenceThreshold(val)` | Порог тишины |
| `GetAudioLevel()` | Текущий уровень |

### SoundParams

Параметры звука. Proto native.

| Метод | Описание |
|-------|----------|
| `Load(name)` | Загрузить по имени |
| `IsValid()` | Валидность |
| `GetName()` | Имя |

### SoundObjectBuilder

Конфигуратор звукового объекта. Proto native.

| Метод | Описание |
|-------|----------|
| `Initialize(soundParams)` | Инициализация из SoundParams |
| `AddEnvSoundVariables(position)` | Добавить переменные окружения для позиции |
| `AddVariable(name, value)` | Добавить переменную |

### SoundObject

Экземпляр звукового объекта. Proto native.

| Метод | Описание |
|-------|----------|
| `SetParent(entity, pivot)` / `GetParent()` | Привязка к сущности |
| `SetPosition(pos)` / `GetPosition()` | Позиция |
| `SetSpeed(vel)` / `GetSpeed()` | Скорость (для Doppler) |
| `SetOcclusionObstruction(occlusion, obstruction)` | Окклюзия и препятствия |
| `SetKind(WaveKind)` | Категория |

### AbstractWave

Управление воспроизведением. Proto native.

#### Воспроизведение

| Метод | Описание |
|-------|----------|
| `Play()` / `Stop()` / `Restart()` | Управление |
| `Loop(enable)` | Зацикливание |
| `GetLength()` | Длительность |
| `GetCurrPosition()` | Текущая позиция |
| `Skip(seconds)` | Пропустить |

#### Громкость и частота

| Метод | Описание |
|-------|----------|
| `GetVolume()` / `SetVolume(vol)` | Громкость |
| `SetVolumeRelative(vol)` | Относительная громкость |
| `GetFrequency()` / `SetFrequency(freq)` | Частота |
| `SetFadeInFactor(factor)` / `SetFadeOutFactor(factor)` | Факторы fade |
| `SetDoppler(enable)` | Эффект Допплера |

#### Позиция

| Метод | Описание |
|-------|----------|
| `SetPosition(pos, velocity)` | Мировая позиция и скорость |
| `IsHeaderLoaded()` | Заголовок загружен |

#### События (ScriptInvoker)

`Event_OnSoundWaveStarted`, `Event_OnSoundWaveStopped`, `Event_OnSoundWaveLoaded`, `Event_OnSoundWaveHeaderLoaded`, `Event_OnSoundWaveEnded`

### SoundControllerAction

```
None, Limit, Overwrite
```

### Паттерн воспроизведения

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

Система динамической музыки. Источник: `systems/dynamicmusicplayer/`

Управляет фоновой музыкой в зависимости от игровой ситуации (бой, ночь, местоположение).

#### Категории (EDynamicMusicPlayerCategory)

Определяют контекст воспроизведения: время суток, биом, ситуация.

#### Реестры по картам

| Класс | Карта |
|-------|-------|
| `DynamicMusicPlayerRegistryChernarus` | Черноруссия |
| `DynamicMusicPlayerRegistryEnoch` | Ливония |
| `DynamicMusicPlayerRegistrySakhal` | Сахаль |

Каждый реестр содержит массивы треков, привязанных к категориям и зонам карты.
