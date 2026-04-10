Классы миссий — hosts всего lifecycle игры (клиент+сервер+главное меню). Источники: `mission/`

### Фабрика

```c
Mission CreateMission(string path)  // somemission.c
```

Глобальная функция выбирает конкретный класс миссии по состоянию игры:

| Условие | Класс |
|---------|-------|
| `IsMultiplayer() && IsServer()` | `MissionServer` |
| `NO_GUI` | `MissionDummy` |
| `path` содержит `NoCutscene`/`intro` | `MissionMainMenu` |
| `path == ""` | `MissionDummy` |
| иначе (клиент в игре) | `MissionGameplay` |

### Иерархия

```
MissionBaseWorld (3_Game)
  └── MissionBase                — общий базовый (клиент+сервер)
        ├── MissionServer        — серверная игровая миссия
        ├── MissionGameplay      — клиентская игровая миссия
        ├── MissionMainMenu      — клиентское главное меню
        ├── MissionBenchmark     — оффлайн-бенчмарк (extends MissionGameplay)
        └── MissionDummy         — заглушка (NO_GUI/пустой путь)
```

### Lifecycle

Последовательность вызовов на протяжении жизни миссии:

```
Конструктор (new MissionXxx)
  → OnInit()              — инициализация подсистем (HUD, menus, world data)
  → OnMissionStart()      — миссия готова, игрок может действовать
  → OnUpdate(timeslice)   — каждый кадр
  → OnEvent(type, params) — реакция на события (chat, respawn, resize)
  → OnMissionFinish()     — при выходе/смене миссии
Деструктор               — очистка
```

Вспомогательные переопределяемые методы: `OnKeyPress/Release`, `OnMouseButtonPress/Release`, `OnItemUsed`, `OnGameplayDataHandlerLoad`, `OnPlayerRespawned`.

---

### MissionBase

```c
class MissionBase extends MissionBaseWorld
```

Общая база для всех миссий. Инициализирует PluginManager, DispatcherCaller, WorldData, DynamicMusicPlayer, WidgetEventHandler, SoundSetMap. Держит фабрику всех `UIScriptedMenu` через `CreateScriptedMenu(MENU_ID)`.

#### Ключевые поля

| Поле | Описание |
|------|----------|
| `m_WidgetEventHandler` | Глобальный обработчик событий виджетов |
| `m_WorldData` | Данные текущего мира (`ChernarusPlusData`/`EnochData`/`SakhalData`/…) |
| `m_WorldLighting` | Клиентское освещение (client only) |
| `m_DynamicMusicPlayer` | Динамический музыкальный плеер (client only) |
| `m_InventoryDropCallback` | `ObjectSnapCallback` для размещения при сбросе |

#### Точки расширения

| Метод | Когда переопределять |
|-------|----------------------|
| `CreateScriptedMenu(id)` | Добавить свой `UIScriptedMenu`-класс под новый MENU_ID |
| `InitialiseWorldData()` | Зарегистрировать `WorldData` для кастомной карты |
| `InitWorldYieldDataDefaults(bank)` | Переопределить дефолты рыбалки/крафта для новых ресурсов |
| `SpawnItems()` | Серверный спаун стартовых предметов (пустая в базе) |

#### DispatcherCaller

`Dispatcher` — мост для вызовов из C++/движка в script. `MissionBase` устанавливает его в конструкторе: `SetDispatcher(new DispatcherCaller)`.

| `CallID` | Действие |
|----------|----------|
| `CALL_ID_SEND_LOG` | Вывод серверного лога через `PluginDeveloper` |
| `CALL_ID_SCR_CNSL_ADD_PRINT` | Печать строки в `ScriptConsole` |
| `CALL_ID_SCENE_EDITOR_COMMAND` | Команда в `SceneEditorMenu` |
| `CALL_ID_HIDE_INVENTORY` | Скрыть инвентарь через `MissionGameplay` |
| `CALL_ID_SCR_CNSL_GETSELECTEDITEM` | Возврат выбранного объекта из `ScriptConsoleItemsTab` |
| `CALL_ID_SCR_CNSL_HISTORY_BACK/NEXT` | Навигация по истории EnfScript-вкладки |

---

### MissionServer

```c
class MissionServer extends MissionBase
```

Серверная миссия. Хранит список игроков, обрабатывает коннект/реконнект/дисконнект, управляет респауном, спаунит стартовое снаряжение, обрабатывает корпсы и off-map артиллерию.

#### Ключевые поля

| Поле | Описание |
|------|----------|
| `m_Players` | `array<Man>` — активные игроки на сервере |
| `m_DeadPlayersArray` | `array<ref CorpseData>` — трупы в мире |
| `m_LogoutPlayers` / `m_NewLogoutPlayers` | Игроки в процессе logout'а (таймер) |
| `m_RespawnMode` | Режим респауна из `CfgGameplayHandler` |
| `m_RainProcHandler` | Обработчик сбора дождевой воды в контейнеры |
| `m_FiringPos` | Позиции off-map артиллерии (заполняется в `Init.c`) |
| `SCHEDULER_PLAYERS_PER_TICK = 5` | Сколько игроков тикают за один кадр |

#### Pipeline коннекта игрока

```
ClientPrepareEvent    → OnClientPrepareEvent  (готовит hive/non-hive, выставляет pos/yaw)
                      → CfgGameplayHandler.SyncDataSendEx (шлёт конфиг клиенту)
ClientNewEvent        → OnClientNewEvent      (создаёт PlayerBase)
                      → CreateCharacter
                      → EquipCharacter        (одежда из MenuDefaultCharacterData)
                      → StartingEquipSetup    (точка расширения для стартовых предметов)
                      → InvokeOnConnect       (player.OnConnect)
ClientReadyEvent      → OnClientReadyEvent    (SelectPlayer)
ClientRespawnEvent    → OnClientRespawnEvent  (kill если unconscious/restrained)
ClientReconnectEvent  → OnClientReconnectEvent (player.OnReconnect)
ClientDisconnectedEvent → OnClientDisconnectedEvent → (через таймер) PlayerDisconnected
```

#### Точки расширения (наиболее переопределяемые)

| Метод | Для чего |
|-------|----------|
| `StartingEquipSetup(player, clothesChosen)` | Выдать стартовые предметы при спауне (init.c hook) |
| `OnClientPrepareEvent(identity, out useDB, out pos, out yaw, out preloadTimeout)` | Стартовая позиция/yaw без DB |
| `OnClientNewEvent(identity, pos, ctx)` | Полная логика создания персонажа (учитывает `PlayerSpawnHandler`) |
| `EquipCharacter(char_data)` | Экипировка по слотам, рандомизация при невалидных данных |
| `InvokeOnConnect/OnDisconnect(player, identity)` | Хуки до/после connect/disconnect |
| `HandleBody(player)` | Что делать с телом игрока при дисконнекте (kill или delete) |
| `ShouldPlayerBeKilled(player)` | Решение о kill'е бессознательного/связанного при дисконнекте |

#### Артиллерия (off-map barrage)

```c
m_PlayArty              // включить barrage (в init.c)
m_ArtyDelay             // интервал между залпами
m_MinSimultaneousStrikes/m_MaxSimultaneousStrikes
m_FiringPos             // координаты (CHERNARUS_STRIKE_POS/LIVONIA_STRIKE_POS)
```

Реализация: `RandomArtillery(deltaTime)` рассылает `RPC_SOUND_ARTILLERY` клиентам.

#### Прочее

- `UpdatePlayersStats()` — каждые 30с: `STAT_PLAYTIME`, `STAT_DISTANCE`, `PluginLifespan.UpdateLifespan`.
- `UpdateCorpseStatesServer()` — обновление стадий разложения каждые 30с.
- `TickScheduler(timeslice)` — round-robin тик `PlayerBase.OnTick()` по 5 игроков за кадр.
- `ControlPersonalLight/SyncGlobalLighting(player)` — RPC выставления света на коннекте.

---

### MissionGameplay

```c
class MissionGameplay extends MissionBase
```

Клиентская миссия «в игре». Владеет HUD, Chat, ActionMenu, InventoryMenu, GameplayEffectWidgets, всеми input excludes и обработкой горячих клавиш.

#### Ключевые поля

| Поле | Описание |
|------|----------|
| `m_HudRootWidget` | Корневой widget из `gui/layouts/day_z_hud.layout` |
| `m_Hud : IngameHud` | Главный HUD (stats/quickbar/иконки) |
| `m_HudDebug` | `HudDebug` (только `#ifdef DEVELOPER`) |
| `m_Chat : Chat` | Система чата |
| `m_ActionMenu` | Меню действий (правый нижний угол) |
| `m_InventoryMenu` | Ref на `InventoryMenu` (создаётся лениво через `InitInventory`) |
| `m_EffectWidgets : GameplayEffectWidgets` | Виджеты геймплейных эффектов |
| `m_DebugMonitor` | Debug monitor (через `CreateDebugMonitor`) |
| `m_Watermark` | Experimental watermark (`BUILD_EXPERIMENTAL`) |
| `m_LifeState` | Кэшированный `EPlayerStates` игрока |
| `m_ActiveInputExcludeGroups/m_ActiveInputRestrictions` | Стек активных input excludes |

#### Lifecycle HUD

```
OnInit() → создаёт day_z_hud.layout → передаёт подвиджеты в:
   m_Chat.Init(ChatFrameWidget)
   m_ActionMenu.Init(ActionsPanel, DefaultActionWidget)
   m_Hud.Init(HudPanel)
   Voice level widgets (Whisper/Talk/Shout)
   ChatChannel area
#ifdef DEVELOPER → m_HudDebug.Init(day_z_hud_debug.layout)

OnMissionFinish() → m_Chat.Destroy(), delete m_HudRootWidget, DestroyAllMenus()
```

#### Input excludes / restrictions

Система слоистого блока инпута для menu/inventory/map/radial:

| Метод | Назначение |
|-------|------------|
| `AddActiveInputExcludes(array<string>)` | Добавить группу(ы) из `specific.xml` (например `"inventory"`, `"menu"`, `"radialmenu"`, `"map"`) |
| `RemoveActiveInputExcludes(array<string>, bForceSupress)` | Снять группы |
| `AddActiveInputRestriction(int)` / `RemoveActiveInputRestriction` | Доп. скриптовые ограничения (`EInputRestrictors.INVENTORY`, `MAP`) |
| `RefreshExcludes()` | Отложенный `PerformRefreshExcludes()` (вызывается в `OnUpdate`) |
| `EnableAllInputs(bForceSupress)` | Сбросить всё |
| `IsInputExcludeActive(string)` / `IsInputRestrictionActive(int)` | Проверка |
| `IsControlDisabled()` | Любая из перечисленных блокировок активна |

#### Управление меню/паузой/инвентарём

| Метод | Что делает |
|-------|------------|
| `Pause()` / `Continue()` | Открыть/закрыть `MENU_INGAME` (пауза) |
| `IsPaused()` | `MENU_INGAME` открыт |
| `ShowInventory()` / `HideInventory()` / `DestroyInventory()` | Lifecycle инвентаря |
| `InitInventory()` | Лениво создаёт `InventoryMenu` |
| `ShowChat()` / `HideChat()` | Открыть `MENU_CHAT_INPUT` |
| `ShowVehicleInfo()` / `HideVehicleInfo()` | Проксируется в `IngameHud` |
| `CreateLogoutMenu(parent)` / `StartLogoutMenu(time)` | Logout flow |
| `CreateDebugMonitor()` / `HideDebugMonitor()` / `UpdateDebugMonitor()` | DebugMonitor lifecycle |
| `CloseAllMenus()` / `DestroyAllMenus()` | Массовые операции |

#### Обработка событий (`OnEvent`)

| Event | Действие |
|-------|----------|
| `ChatMessageEventTypeID` | Добавить сообщение в `m_Chat` |
| `ChatChannelEventTypeID` | Обновить индикатор канала (fade timer) |
| `WindowsResizeEventTypeID` | `DestroyAllMenus() + m_Hud.OnResizeScreen()` |
| `SetFreeCameraEventTypeID` | `PluginDeveloper.OnSetFreeCameraEvent` |
| `NetworkInputBufferEventTypeID` | Открыть `MENU_CONNECTION_DIALOGUE` при переполнении input buffer |

#### Горячие клавиши (OnUpdate)

Обработка в `OnUpdate` по `GetUApi().GetInputByID(UA*)`:

| Input | Действие |
|-------|----------|
| `UAGear` | Toggle инвентарь |
| `UAUIGesturesOpen` | Open/close `GesturesMenu` |
| `UAUIQuickbarRadialOpen` | Open/close `RadialQuickbarMenu` |
| `UAChat` | Open `ChatInputMenu` (non-console) |
| `UAUIQuickbarToggle` | Show/hide quickbar |
| `UAZeroingUp/Down`, `UAToggleWeapons` | `m_Hud.ZeroingKeyPress()` |
| `UANextAction/PrevAction`, `UANextActionCategory/Prev…` | Навигация в `ActionMenu` |
| `UAMapToggle` | Open `MapMenu` (если ignore ownership) |
| `UAUIMenu` | Pause |

См. [hud.md](hud.md), [menus.md](menus.md), [inventory.md](inventory.md).

---

### MissionMainMenu

```c
class MissionMainMenu extends MissionBase
```

Главное меню игры. На `OnInit` создаёт интро-сцену (`DayZIntroScenePC`/`DayZIntroSceneXbox`) и открывает корневое меню (`MENU_MAIN` на PC, `MENU_TITLE_SCREEN` на консолях).

| Поле | Описание |
|------|----------|
| `m_mainmenu` | Ref на корневое `UIScriptedMenu` |
| `m_IntroScenePC` / `m_IntroSceneXbox` | Платформенная интро-сцена |
| `m_CreditsMenu` | Ref на открытые титры (для обновления по событию input device) |
| `m_NoCutscene` | Пропустить интро (путь содержит `NoCutscene`) |

Ключевое: `OnUpdate` вызывает `m_IntroScenePC.Update()`, `Reset()` пересоздаёт сцену, `OnMenuEnter(menu_id)` кеширует ref на `CreditsMenu`. Подробности подменю — см. [mainmenu.md](mainmenu.md).

---

### MissionBenchmark

```c
class MissionBenchmark extends MissionGameplay
```

Оффлайн-бенчмарк: серия `BenchmarkLocation` (позиция + look-at + скорость камеры), по которым камера пролетает через `BenchmarkConfig`. Выводит FPS-метрики в RPT/CSV. Запускается через CLI-параметр; в геймплее не используется.

---

### MissionDummy

```c
class MissionDummy extends MissionBase
```

Пустая заглушка для `NO_GUI` сборок и пустого пути. Никакой собственной логики.
