Mission classes — hosts of the entire game lifecycle (client+server+main menu). Sources: `mission/`

### Factory

```c
Mission CreateMission(string path)  // somemission.c
```

The global function chooses a concrete mission class based on the game state:

| Condition | Class |
|-----------|-------|
| `IsMultiplayer() && IsServer()` | `MissionServer` |
| `NO_GUI` | `MissionDummy` |
| `path` contains `NoCutscene`/`intro` | `MissionMainMenu` |
| `path == ""` | `MissionDummy` |
| otherwise (client in game) | `MissionGameplay` |

### Hierarchy

```
MissionBaseWorld (3_Game)
  └── MissionBase                — common base (client+server)
        ├── MissionServer        — server game mission
        ├── MissionGameplay      — client game mission
        ├── MissionMainMenu      — client main menu
        ├── MissionBenchmark     — offline benchmark (extends MissionGameplay)
        └── MissionDummy         — stub (NO_GUI/empty path)
```

### Lifecycle

Sequence of calls over the mission's lifetime:

```
Constructor (new MissionXxx)
  → OnInit()              — initialize subsystems (HUD, menus, world data)
  → OnMissionStart()      — mission is ready, the player may act
  → OnUpdate(timeslice)   — every frame
  → OnEvent(type, params) — react to events (chat, respawn, resize)
  → OnMissionFinish()     — on exit/mission change
Destructor               — cleanup
```

Auxiliary overridable methods: `OnKeyPress/Release`, `OnMouseButtonPress/Release`, `OnItemUsed`, `OnGameplayDataHandlerLoad`, `OnPlayerRespawned`.

---

### MissionBase

```c
class MissionBase extends MissionBaseWorld
```

Common base for all missions. Initializes PluginManager, DispatcherCaller, WorldData, DynamicMusicPlayer, WidgetEventHandler, SoundSetMap. Holds the factory for all `UIScriptedMenu`s via `CreateScriptedMenu(MENU_ID)`.

#### Key fields

| Field | Description |
|-------|-------------|
| `m_WidgetEventHandler` | Global widget event handler |
| `m_WorldData` | Data for the current world (`ChernarusPlusData`/`EnochData`/`SakhalData`/…) |
| `m_WorldLighting` | Client lighting (client only) |
| `m_DynamicMusicPlayer` | Dynamic music player (client only) |
| `m_InventoryDropCallback` | `ObjectSnapCallback` for placement on drop |

#### Extension points

| Method | When to override |
|--------|------------------|
| `CreateScriptedMenu(id)` | Add your own `UIScriptedMenu` class under a new MENU_ID |
| `InitialiseWorldData()` | Register `WorldData` for a custom map |
| `InitWorldYieldDataDefaults(bank)` | Override defaults for fishing/crafting for new resources |
| `SpawnItems()` | Server-side spawn of starting items (empty in base) |

#### DispatcherCaller

`Dispatcher` — bridge for calls from C++/engine into script. `MissionBase` sets it in the constructor: `SetDispatcher(new DispatcherCaller)`.

| `CallID` | Action |
|----------|--------|
| `CALL_ID_SEND_LOG` | Print the server log via `PluginDeveloper` |
| `CALL_ID_SCR_CNSL_ADD_PRINT` | Print a string to `ScriptConsole` |
| `CALL_ID_SCENE_EDITOR_COMMAND` | Command into `SceneEditorMenu` |
| `CALL_ID_HIDE_INVENTORY` | Hide the inventory via `MissionGameplay` |
| `CALL_ID_SCR_CNSL_GETSELECTEDITEM` | Return the selected object from `ScriptConsoleItemsTab` |
| `CALL_ID_SCR_CNSL_HISTORY_BACK/NEXT` | Navigate the EnfScript tab history |

---

### MissionServer

```c
class MissionServer extends MissionBase
```

Server mission. Maintains the player list, handles connect/reconnect/disconnect, manages respawn, spawns starting equipment, processes corpses and off-map artillery.

#### Key fields

| Field | Description |
|-------|-------------|
| `m_Players` | `array<Man>` — active players on the server |
| `m_DeadPlayersArray` | `array<ref CorpseData>` — corpses in the world |
| `m_LogoutPlayers` / `m_NewLogoutPlayers` | Players currently logging out (timer) |
| `m_RespawnMode` | Respawn mode from `CfgGameplayHandler` |
| `m_RainProcHandler` | Handler for collecting rainwater into containers |
| `m_FiringPos` | Positions of off-map artillery (filled in `Init.c`) |
| `SCHEDULER_PLAYERS_PER_TICK = 5` | How many players tick per frame |

#### Player connect pipeline

```
ClientPrepareEvent    → OnClientPrepareEvent  (prepares hive/non-hive, sets pos/yaw)
                      → CfgGameplayHandler.SyncDataSendEx (sends config to the client)
ClientNewEvent        → OnClientNewEvent      (creates PlayerBase)
                      → CreateCharacter
                      → EquipCharacter        (clothing from MenuDefaultCharacterData)
                      → StartingEquipSetup    (extension point for starting items)
                      → InvokeOnConnect       (player.OnConnect)
ClientReadyEvent      → OnClientReadyEvent    (SelectPlayer)
ClientRespawnEvent    → OnClientRespawnEvent  (kill if unconscious/restrained)
ClientReconnectEvent  → OnClientReconnectEvent (player.OnReconnect)
ClientDisconnectedEvent → OnClientDisconnectedEvent → (via timer) PlayerDisconnected
```

#### Extension points (most commonly overridden)

| Method | What for |
|--------|----------|
| `StartingEquipSetup(player, clothesChosen)` | Give starting items on spawn (init.c hook) |
| `OnClientPrepareEvent(identity, out useDB, out pos, out yaw, out preloadTimeout)` | Starting position/yaw without DB |
| `OnClientNewEvent(identity, pos, ctx)` | Full character creation logic (honors `PlayerSpawnHandler`) |
| `EquipCharacter(char_data)` | Equip per slot, randomize on invalid data |
| `InvokeOnConnect/OnDisconnect(player, identity)` | Hooks before/after connect/disconnect |
| `HandleBody(player)` | What to do with the player's body on disconnect (kill or delete) |
| `ShouldPlayerBeKilled(player)` | Decision to kill an unconscious/restrained player on disconnect |

#### Artillery (off-map barrage)

```c
m_PlayArty              // enable barrage (in init.c)
m_ArtyDelay             // interval between volleys
m_MinSimultaneousStrikes/m_MaxSimultaneousStrikes
m_FiringPos             // coordinates (CHERNARUS_STRIKE_POS/LIVONIA_STRIKE_POS)
```

Implementation: `RandomArtillery(deltaTime)` broadcasts `RPC_SOUND_ARTILLERY` to clients.

#### Miscellaneous

- `UpdatePlayersStats()` — every 30s: `STAT_PLAYTIME`, `STAT_DISTANCE`, `PluginLifespan.UpdateLifespan`.
- `UpdateCorpseStatesServer()` — decay-stage updates every 30s.
- `TickScheduler(timeslice)` — round-robin tick of `PlayerBase.OnTick()` for 5 players per frame.
- `ControlPersonalLight/SyncGlobalLighting(player)` — RPC to set lighting on connect.

---

### MissionGameplay

```c
class MissionGameplay extends MissionBase
```

Client "in-game" mission. Owns the HUD, Chat, ActionMenu, InventoryMenu, GameplayEffectWidgets, all input excludes, and hotkey handling.

#### Key fields

| Field | Description |
|-------|-------------|
| `m_HudRootWidget` | Root widget from `gui/layouts/day_z_hud.layout` |
| `m_Hud : IngameHud` | Main HUD (stats/quickbar/icons) |
| `m_HudDebug` | `HudDebug` (only `#ifdef DEVELOPER`) |
| `m_Chat : Chat` | Chat system |
| `m_ActionMenu` | Action menu (bottom-right corner) |
| `m_InventoryMenu` | Ref to `InventoryMenu` (lazily created via `InitInventory`) |
| `m_EffectWidgets : GameplayEffectWidgets` | Gameplay effect widgets |
| `m_DebugMonitor` | Debug monitor (via `CreateDebugMonitor`) |
| `m_Watermark` | Experimental watermark (`BUILD_EXPERIMENTAL`) |
| `m_LifeState` | Cached player `EPlayerStates` |
| `m_ActiveInputExcludeGroups/m_ActiveInputRestrictions` | Stack of active input excludes |

#### HUD lifecycle

```
OnInit() → creates day_z_hud.layout → passes sub-widgets to:
   m_Chat.Init(ChatFrameWidget)
   m_ActionMenu.Init(ActionsPanel, DefaultActionWidget)
   m_Hud.Init(HudPanel)
   Voice level widgets (Whisper/Talk/Shout)
   ChatChannel area
#ifdef DEVELOPER → m_HudDebug.Init(day_z_hud_debug.layout)

OnMissionFinish() → m_Chat.Destroy(), delete m_HudRootWidget, DestroyAllMenus()
```

#### Input excludes / restrictions

Layered input-blocking system for menu/inventory/map/radial:

| Method | Purpose |
|--------|---------|
| `AddActiveInputExcludes(array<string>)` | Add group(s) from `specific.xml` (e.g., `"inventory"`, `"menu"`, `"radialmenu"`, `"map"`) |
| `RemoveActiveInputExcludes(array<string>, bForceSupress)` | Remove groups |
| `AddActiveInputRestriction(int)` / `RemoveActiveInputRestriction` | Additional script-side restrictions (`EInputRestrictors.INVENTORY`, `MAP`) |
| `RefreshExcludes()` | Deferred `PerformRefreshExcludes()` (called in `OnUpdate`) |
| `EnableAllInputs(bForceSupress)` | Reset everything |
| `IsInputExcludeActive(string)` / `IsInputRestrictionActive(int)` | Checks |
| `IsControlDisabled()` | Any of the listed blocks active |

#### Menu/pause/inventory management

| Method | What it does |
|--------|--------------|
| `Pause()` / `Continue()` | Open/close `MENU_INGAME` (pause) |
| `IsPaused()` | `MENU_INGAME` is open |
| `ShowInventory()` / `HideInventory()` / `DestroyInventory()` | Inventory lifecycle |
| `InitInventory()` | Lazily creates `InventoryMenu` |
| `ShowChat()` / `HideChat()` | Open `MENU_CHAT_INPUT` |
| `ShowVehicleInfo()` / `HideVehicleInfo()` | Proxied to `IngameHud` |
| `CreateLogoutMenu(parent)` / `StartLogoutMenu(time)` | Logout flow |
| `CreateDebugMonitor()` / `HideDebugMonitor()` / `UpdateDebugMonitor()` | DebugMonitor lifecycle |
| `CloseAllMenus()` / `DestroyAllMenus()` | Bulk operations |

#### Event handling (`OnEvent`)

| Event | Action |
|-------|--------|
| `ChatMessageEventTypeID` | Add a message into `m_Chat` |
| `ChatChannelEventTypeID` | Update the channel indicator (fade timer) |
| `WindowsResizeEventTypeID` | `DestroyAllMenus() + m_Hud.OnResizeScreen()` |
| `SetFreeCameraEventTypeID` | `PluginDeveloper.OnSetFreeCameraEvent` |
| `NetworkInputBufferEventTypeID` | Open `MENU_CONNECTION_DIALOGUE` on input buffer overflow |

#### Hotkeys (OnUpdate)

Processing in `OnUpdate` via `GetUApi().GetInputByID(UA*)`:

| Input | Action |
|-------|--------|
| `UAGear` | Toggle inventory |
| `UAUIGesturesOpen` | Open/close `GesturesMenu` |
| `UAUIQuickbarRadialOpen` | Open/close `RadialQuickbarMenu` |
| `UAChat` | Open `ChatInputMenu` (non-console) |
| `UAUIQuickbarToggle` | Show/hide quickbar |
| `UAZeroingUp/Down`, `UAToggleWeapons` | `m_Hud.ZeroingKeyPress()` |
| `UANextAction/PrevAction`, `UANextActionCategory/Prev…` | Navigation in `ActionMenu` |
| `UAMapToggle` | Open `MapMenu` (if ignore ownership) |
| `UAUIMenu` | Pause |

See [hud.md](hud.md), [menus.md](menus.md), [inventory.md](inventory.md).

---

### MissionMainMenu

```c
class MissionMainMenu extends MissionBase
```

Game main menu. On `OnInit` creates the intro scene (`DayZIntroScenePC`/`DayZIntroSceneXbox`) and opens the root menu (`MENU_MAIN` on PC, `MENU_TITLE_SCREEN` on consoles).

| Field | Description |
|-------|-------------|
| `m_mainmenu` | Ref to the root `UIScriptedMenu` |
| `m_IntroScenePC` / `m_IntroSceneXbox` | Platform-specific intro scene |
| `m_CreditsMenu` | Ref to open credits (for updating on input-device event) |
| `m_NoCutscene` | Skip intro (path contains `NoCutscene`) |

Key points: `OnUpdate` calls `m_IntroScenePC.Update()`, `Reset()` recreates the scene, `OnMenuEnter(menu_id)` caches the ref to `CreditsMenu`. Submenu details — see [mainmenu.md](mainmenu.md).

---

### MissionBenchmark

```c
class MissionBenchmark extends MissionGameplay
```

Offline benchmark: a series of `BenchmarkLocation`s (position + look-at + camera speed) through which the camera flies via `BenchmarkConfig`. Outputs FPS metrics to RPT/CSV. Launched via CLI parameter; not used in gameplay.

---

### MissionDummy

```c
class MissionDummy extends MissionBase
```

Empty stub for `NO_GUI` builds and empty path. No logic of its own.
