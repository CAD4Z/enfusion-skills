Система эффектов и пост-обработка. Источники: `effect.c`, `effectmanager.c`, `effects/`, `ppemanager/`

### EffectType

```
NONE, SOUND, PARTICLE
```

### Effect

Базовый класс эффектов. Managed. Источник: `effect.c`

| Метод | Описание |
|-------|----------|
| `Start()` / `Stop()` | Запуск/остановка |
| `IsPlaying()` | Воспроизводится |
| `GetEffectType()` | Тип (`SOUND` / `PARTICLE`) |
| `SetParent(parent)` / `GetParent()` | Родительская сущность |
| `SetLocalPosition(pos)` / `SetLocalOrientation(ori)` | Локальная позиция/ориентация |
| `SetAttachmentPivotIdx(idx)` | Индекс pivot-точки привязки |
| `SetAutodestroy(state)` | Автоудаление после остановки |
| `ValidateStart()` | Хук валидации перед стартом |
| `IsRegistered()` / `GetID()` | Регистрация в SEffectManager |

#### События (ScriptInvoker)

`Event_OnStarted`, `Event_OnStopped`, `Event_OnEffectStarted`, `Event_OnEffectEnded`

### EffectParticle

Наследует `Effect`. Обёртка партикла. Источник: `effects/effectparticle.c`

| Метод | Описание |
|-------|----------|
| `GetParticle()` | Объект `Particle` |
| `SetOrientation(ori)` | Ориентация |

### EffectSound

Наследует `Effect`. Обёртка звука. Источник: `effects/effectsound.c`

| Метод | Описание |
|-------|----------|
| `FadeIn(seconds)` / `FadeOut(seconds)` | Плавное нарастание/затухание |
| `SetVolume(vol)` / `SetPitch(pitch)` | Громкость / высота тона |

### SEffectManager

Статический глобальный менеджер эффектов. Источник: `effectmanager.c`

#### Управление эффектами

| Метод | Описание |
|-------|----------|
| `PlayInWorld(effect, pos)` | Воспроизвести в мире |
| `PlayOnObject(effect, obj, local_pos, local_ori, force_rotation)` | На объекте |
| `Stop(effect_id)` | Остановить по ID |
| `EffectRegister(effect)` / `EffectUnregister(effect)` | Регистрация |

#### Звуковые ярлыки

| Метод | Описание |
|-------|----------|
| `CreateSound(soundSet, pos, ...)` | Создать EffectSound |
| `PlaySound(soundSet, pos, ...)` | Создать и воспроизвести |
| `PlaySoundParams(params, pos, ...)` | С SoundParams |

#### Система

| Метод | Описание |
|-------|----------|
| `Init()` / `InitServer()` / `Cleanup()` | Lifecycle |
| `Event_OnFrameUpdate` | Invoker обновления каждый кадр |

### Bullet Impact эффекты

Система эффектов попаданий. Источник: `effects/generated/`. Каждый эффект — наследник `BulletImpactBase`.

Ключевые: `Hit_MeatBones`, `Hit_Metal`, `Hit_Wood`, `Hit_Concrete`, `Hit_Glass`, `Hit_Water`, `Hit_Dirt`, `Hit_Sand`, `Hit_Foliage`, `Hit_Grass`, `Hit_Plastic`, `Hit_Rubber`, `Hit_Ice`, `Hit_Snow`, `Hit_Textile`, `Hit_Plaster`

### Специальные эффекты

| Класс | Описание |
|-------|----------|
| `BleedingSource` | Визуализация кровотечения |
| `BloodSplatter` | Брызги крови |
| `Vomit` / `VomitBlood` | Рвота |
| `BreathVapourLight/Medium/Heavy` | Пар изо рта |
| `SwarmingFlies` | Мухи |
| `VehicleSmoke` / `EngineSmoke` / `ExhaustSmoke` | Дым транспорта |
| `GeneratorSmoke` | Дым генератора |
| `LandmineExplosion` | Взрыв мины |

---

## PPEManager (система пост-обработки)

Централизованное управление пост-процессингом. Источник: `ppemanager/`

### Архитектура

```
PPEManager (синглтон)
├── PPEClassBase (материальный класс — один тип эффекта)
│   └── PPEMatClassParameter* (параметры: float, int, bool, color, vector, texture)
└── PPERequesterBase (реквестер — запрашивает эффект)
    └── PPERequestData (данные запроса)
```

**Поток**: реквестер → вызывает `SetTargetValueFloat/Color/...` на параметрах материального класса → PPEManager агрегирует все запросы и применяет результат.

### PPEManagerStatic

| Метод | Описание |
|-------|----------|
| `GetPPEManager()` | Получить синглтон |
| `CreateManagerStatic()` / `DestroyManagerStatic()` | Lifecycle |

### PPERequesterBase

Базовый класс реквестера. Каждый реквестер — один визуальный эффект.

| Метод | Описание |
|-------|----------|
| `Start(settings)` / `Stop(settings)` | Запуск/остановка |
| `SetTargetValueFloat(matIdx, paramIdx, value, priority, op)` | Float-параметр |
| `SetTargetValueColor(matIdx, paramIdx, color, priority, op)` | Цвет (vector4) |
| `SetTargetValueBool(matIdx, paramIdx, value, priority, op)` | Bool |
| `SetTargetValueInt(matIdx, paramIdx, value, priority, op)` | Int |

### Типы параметров

| Класс | Тип данных |
|-------|-----------|
| `PPEMatClassParameterFloat` | `float` |
| `PPEMatClassParameterInt` | `int` |
| `PPEMatClassParameterBool` | `bool` |
| `PPEMatClassParameterColor` | `vector` (RGBA) |
| `PPEMatClassParameterVector` | `vector` |
| `PPEMatClassParameterTexture` | Ресурс текстуры |

### Ключевые реквестеры

| Класс | Эффект |
|-------|--------|
| `PPERPain` | Боль |
| `PPERBloodLoss` | Потеря крови (виньетка) |
| `PPERHealthHit` | Вспышка при попадании |
| `PPERCameraNV` | Ночное видение (зелёный тинт) |
| `PPERCameraADS_OPT` | Зум при прицеливании |
| `PPERBurlapsack` | Мешок на голове |
| `PPERContaminated` | Заражение (размытие) |
| `PPERDrowningEffect` | Утопление |
| `PPERUnconEffects` | Бессознательное состояние |
| `PPERFever` | Лихорадка |
| `PPERShockHit` | Шок |
| `PPERFlashbangEffects` | Светошумовая граната |
| `PPERDeathDarkening` | Затемнение при смерти |
| `PPERTunnel` | Туннельное зрение |
| `PPERGlasses` | Очки |

Остальные: `PPERControlsBlur`, `PPERInventoryBlur`, `PPERFeedbackBlur`, `PPERLatencyBlur`, `PPERTutorial`, `PPERUndergroundAcco`, `PPERSpooky`, `PPERIntroChromaBB`, `PPERHMPGhosts`, `PPERHMPLevel3`, `PPERServerBrowser`, `PPERMenuEffects`, `PPERControllerDisconnectBlur`

### Материальные классы (PPEClassBase)

| Класс | Эффект |
|-------|--------|
| `PPEDepthOfField` / `PPEDOF` | Глубина резкости |
| `PPEChromAber` | Хроматическая аберрация |
| `PPERadialBlur` | Радиальное размытие |
| `PPEDynamicBlur` | Динамическое размытие |
| `PPEGaussFilter` | Размытие по Гауссу |
| `PPERotBlur` | Ротационное размытие |
| `PPEColorGrading` | Цветокоррекция |
| `PPEColors` | Цветовые настройки |
| `PPEGlow` | Свечение (bloom) |
| `PPEFilmGrain` | Зернистость плёнки |
| `PPEGodRays` | Лучи света |
| `PPERain` | Дождь на экране |
| `PPESnowfall` | Снег на экране |
| `PPEUnderWater` | Подводное искажение |
| `PPEWetDistort` | Искажение влаги |
| `PPEDistort` | Общее искажение |
| `PPEGhost` | Призрачные блики |
| `PPESunMask` | Маска солнца |

Anti-aliasing: `PPESMAA`, `PPEFXAA`, `PPEMedian`

Native: `PPEExposureNative`, `PPEEyeAccomodationNative`, `PPELightIntensityParamsNative`
