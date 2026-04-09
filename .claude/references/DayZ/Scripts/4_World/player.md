`4_World` — игрок. Иерархия: `ManBase` (C++) → `PlayerBase` → `PlayerBaseClient` → `SurvivorBase`. Все персонажи наследуют `SurvivorBase`. Источники: `entities/manbase/`

### Подсистемы

`PlayerBase` владеет всеми менеджерами, создаёт их в `Init()`:

| Поле | Тип | Сторона |
|------|-----|---------|
| `m_PlayerStats` | `PlayerStats` | Обе |
| `m_ModifiersManager` | `ModifiersManager` | Сервер |
| `m_NotifiersManager` | `NotifiersManager` | Сервер |
| `m_ActionManager` | `ActionManagerBase` | Обе |
| `m_BleedingManagerServer` | `BleedingSourcesManagerServer` | Сервер |
| `m_Environment` | `Environment` | Обе |
| `m_StaminaHandler` | `StaminaHandler` | Обе |
| `m_ShockHandler` | `ShockHandler` | Обе |
| `m_EmoteManager` | `EmoteManager` | Обе |
| `m_SymptomManager` | `SymptomManager` | Обе |
| `m_SoftSkillsManager` | `SoftSkillsManager` | Обе |
| `m_PlayerStomach` | `PlayerStomach` | Сервер |
| `m_AgentPool` | `PlayerAgentPool` | Сервер |

### Lifecycle

| Метод | Контекст | Когда |
|-------|----------|-------|
| `Init()` | Обе | Конструктор — создание всех подсистем |
| `OnPlayerLoaded()` | Обе | После спауна (deferred через CallQueue) — HUD, камера, окружение |
| `CommandHandler(float pDt, int pCurrentCommandID, bool pCurrentCommandFinished)` | Обе | Каждый кадр — основной тик всех систем |
| `OnCommandHandlerTick(float pDt, int pCurrentCommandID)` | Обе | Хук в конце `CommandHandler` |
| `OnScheduledTick(float deltaT)` | Обе | Таймерный тик — модификаторы, нотификаторы, окружение, кровотечение |
| `EEKilled(Object killer)` | Сервер | Смерть — лог, hive, VoN, труп |
| `EEHitBy(TotalDamageResult, int damageType, EntityAI source, int component, string dmgZone, string ammo, vector modelPos, float speedCoef)` | Обе | Попадание — шок, кровотечение, переломы |

### Tick-схема

```
CommandHandler(dt) [каждый кадр]
 ├── StaminaHandler.Update(dt)
 ├── ShockHandler.Update(dt)
 ├── InjuryHandler.Update(dt)
 └── ActionManager.Update(commandID)

OnScheduledTick(dt) [по таймеру]
 ├── ModifiersManager.OnScheduledTick(dt)
 ├── NotifiersManager.OnScheduledTick()
 ├── TransferValues.OnScheduledTick(dt)
 ├── VirtualHud.OnScheduledTick()
 ├── BleedingSourcesManager.OnTick(dt)
 └── Environment.Update(dt)
```

### EE-события предметов

| Метод | Когда |
|-------|-------|
| `EEItemAttached(EntityAI item, string slot_name)` | Предмет надет — quickbar, противогаз, NVG, волосы |
| `EEItemDetached(EntityAI item, string slot_name)` | Предмет снят |
| `EEItemIntoHands(EntityAI item)` | Предмет в руки — сброс оружия, тяжёлый предмет |
| `EEItemOutOfHands(EntityAI item)` | Предмет из рук |

### Переопределяемые проверки

| Метод | Что проверяет |
|-------|---------------|
| `CanSprint()` | Поднятое оружие, тяжёлый предмет, травма, перелом |
| `CanJump()` | Перелом, стамина, травма |
| `CanClimb(int climbType, SHumanCommandClimbResult)` | Перелом, стамина, травма |
| `CanRoll()` | Стамина, эмоут |
| `CanChangeStance(int prev, int next)` | Уровень воды |

### Состояния команд

| Метод | Когда |
|-------|-------|
| `OnCommandSwimStart/Finish()` | Плавание — блокировка инвентаря |
| `OnCommandLadderStart/Finish()` | Лестница |
| `OnCommandFallStart/Finish()` | Падение |
| `OnCommandClimbStart/Finish()` | Подъём |
| `OnCommandVehicleStart/Finish()` | Транспорт |
| `OnCommandDeathStart()` | Смерть |
| `OnUnconsciousStart/Stop(int)` | Бессознательное — HUD, VoN |

### Зоны и области

| Метод | Сторона | Назначение |
|-------|---------|------------|
| `OnContaminatedAreaEnterServer()` | Сервер | Активирует `MDF_AREAEXPOSURE` |
| `OnContaminatedAreaExitServer()` | Сервер | Деактивирует `MDF_AREAEXPOSURE` |
| `OnPlayerIsNowInsideEffectAreaBeginServer/Client()` | Обе | Вход в зону эффекта |
| `OnPlayerIsNowInsideEffectAreaEndServer/Client()` | Обе | Выход из зоны эффекта |

### ScriptInvokers

```
GetOnUnconsciousStart()   // подписка: игрок теряет сознание
GetOnUnconsciousStop()    // подписка: игрок приходит в себя
```

### Действия

```
SetActions(out TInputActionMap map)             // переопределить для добавления действий на игроке-контроллере
SetActionsRemoteTarget(out TInputActionMap map) // действия на игроке-цели
```

### Персистентность

`OnStoreSave/OnStoreLoad` сохраняют: stats, modifiers, agents, symptoms, bleeding, stomach, broken legs, arrows. Версионирование через `GAME_STORAGE_VERSION`.

### PlayerStats

Контейнер статов. Версионирование через PCO: `PlayerStatsPCO_current` extends `PlayerStatsPCO_v115`.

| Стат | Тип | Диапазон | Начальное | Sync |
|------|-----|----------|-----------|------|
| `HEATCOMFORT` | float | -1..1 | 0 | Нет |
| `TREMOR` | float | 0..1 | 0 | Нет |
| `WET` | int | 0..1 | 0 | Нет |
| `ENERGY` | float | 0..max | 600 | Нет |
| `WATER` | float | 0..max | 600 | Нет |
| `DIET` | float | 0..5000 | 2500 | Нет |
| `STAMINA` | float | 0..max | 100 | Нет |
| `SPECIALTY` | float | -1..1 | 0 | Нет |
| `BLOODTYPE` | int | 0..128 | random | Нет |
| `TOXICITY` | float | 0..100 | 0 | Нет |
| `HEATBUFFER` | float | -30..30 | 0 | Да |

`Blood` и `Health` — не PlayerStats, а зоны `DamageSystem`: `GetHealth("", "Blood")`.

#### PlayerStat API

| Метод | Описание |
|-------|----------|
| `Set(T value)` | Установить (clamp); RPC на клиент если synced |
| `Add(T value)` | Set(current + value) |
| `Get()` | Текущее значение |
| `GetNormalized()` | 0..1 |

#### Уровни статов

`EStatLevels`: `GREAT, HIGH, MEDIUM, LOW, CRITICAL`

```
GetStatLevelHealth/Blood/Energy/Water/Toxicity()  // уровень конкретного стата
GetImmunityLevel()     // композитный из energy+water+health+blood
GetImmunity()          // 0..1
```

### Notifiers

Система уведомлений HUD. Сервер. `NotifiersManager` тикает round-robin — один нотификатор за вызов.

| Нотификатор | ID | Что отслеживает |
|-------------|----|----|
| `HealthNotfr` | NTF_HEALTHY | Health |
| `HungerNotfr` | NTF_HUNGRY | Energy |
| `ThirstNotfr` | NTF_THIRSTY | Water |
| `BloodNotfr` | NTF_BLOOD | Blood |
| `WarmthNotfr` | NTF_WARMTH | HeatComfort (SMA) |
| `WetnessNotfr` | NTF_WETNESS | Wet |
| `SickNotfr` | NTF_SICK | Болезни |
| `FeverNotfr` | NTF_FEVERISH | Лихорадка |
| `BleedingNotfr` | NTF_BLEEDISH | Кровотечение |
| `HeartbeatNotfr` | NTF_HEARTBEAT | Blood (пульс) |
| `FracturedLegNotfr` | NTF_FRACTURE | Перелом |

#### NotifierBase API

| Метод | Описание |
|-------|----------|
| `GetNotifierType()` | Вернуть `eNotifiers` ID |
| `GetObservedValue()` | Текущее значение отслеживаемого стата |
| `OnTick(int currentTime)` | Основной тик — запись, badge, tendency |
| `DisplayBadge()` / `HideBadge()` | Иконка на VirtualHud |
| `DisplayTendency(float delta)` | Стрелка тенденции |
| `SetActive(bool)` | Вкл/выкл |

Тенденция рассчитывается через циклический буфер (30 значений), усреднение → `TENDENCY_STABLE / INC_LOW/MED/HIGH / DEC_LOW/MED/HIGH`.
