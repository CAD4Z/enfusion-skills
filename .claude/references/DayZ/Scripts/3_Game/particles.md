Система партиклов. Источники: `particles/`

### ParticleManager

Синглтон-менеджер пула партиклов. Источник: `particles/particlemanager.c`

#### Создание и управление

| Метод | Описание |
|-------|----------|
| `CreateParticle(particleId, pos, playOnCreation, parent, ori, forceWorldRotation)` | Создать партикл |
| `CreateParticleEx(particleId, pos, flags, parent, ori)` | Создать с флагами |
| `PlayParticle(particleId, pos, parent)` | Создать и запустить |
| `StopParticle(particle)` | Остановить |
| `DeleteParticle(particle)` | Удалить |

#### Lifecycle

| Метод | Описание |
|-------|----------|
| `CleanupInstance()` | Уничтожить синглтон |

#### Настройки

`ParticleManagerSettings` — конфигурация пула.

`ParticleManagerSettingsFlags`:
```
NONE, FIXED_INDEX, BLOCKING, DISABLE_VIRTUAL, REUSE_OWNED
```

### ParticleSource

Источник-эмиттер партиклов. Proto native.

| Метод | Описание |
|-------|----------|
| `Play()` / `Stop()` | Воспроизведение |
| `IsPlaying()` | Активен |

### ParticleProperties

Свойства партикла.

`ParticlePropertiesFlags`:
```
PLAY_ON_CREATION — автозапуск
FORCE_WORLD_ROT — принудительно мировое вращение
```

### ParticleList

Реестр ID партиклов. Proto native. Содержит константы-идентификаторы всех партиклов в игре.
