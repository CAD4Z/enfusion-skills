Main menu — all screens prior to loading into `MissionGameplay`. Sources: `gui/newui/`, `gui/titlescreenmenu.c`, `gui/startupmenu.c`

### Context

The main menu runs on top of `MissionMainMenu` (see [mission.md](mission.md)). The root menu depends on the platform:
- **PC** → `MENU_MAIN` (`MainMenu`)
- **Console** → `MENU_TITLE_SCREEN` (`TitleScreenMenu`) → after a button press → `MENU_MAIN` (`MainMenuConsole`)

`MissionMainMenu.OnInit` creates `DayZIntroScenePC`/`DayZIntroSceneXbox` (depending on platform) and opens the root menu.

---

### Menu catalog

| MENU_ID | Class | Layout | Purpose |
|---------|-------|--------|---------|
| `MENU_TITLE_SCREEN` | `TitleScreenMenu` | `xbox/day_z_title_screen.layout` | "Press A to start" splash (console) |
| `MENU_STARTUP` | `StartupMenu` | `startup.layout` | Startup splash |
| `MENU_MAIN` | `MainMenu` (PC) / `MainMenuConsole` (console) | `new_ui/main_menu.layout` / `new_ui/main_menu_console.layout` | Root menu |
| `MENU_CHARACTER` | `CharacterCreationMenu` | `new_ui/character_creation/character_creation.layout` | Character customization |
| `MENU_SERVER_BROWSER` | `ServerBrowserMenuNew` | `new_ui/server_browser/pc/...` or `xbox/...` | Server browser |
| `MENU_OPTIONS` | `OptionsMenu` | `new_ui/options/{pc,xbox,ps,msstore}/options_menu.layout` | Settings (Game/Sounds/Video/Controls) |
| `MENU_KEYBINDINGS` | `KeybindingsMenu` | `new_ui/options/{pc,msstore}/keybinding_menu.layout` | Key bindings |
| `MENU_VIDEO` | `MainMenuVideo` | — | Plays intro video |
| `MENU_TUTORIAL` | `TutorialsMenu` | — | Tutorial video list |
| `MENU_CREDITS` | `CreditsMenu` | `new_ui/credits/credits_menu.layout` | Credits |
| `MENU_XBOX_CONTROLS` | `ControlsXboxNew` | — | Controller layout |
| `MENU_LOGIN_QUEUE` / `MENU_LOGIN_TIME` | `LoginQueueBase` / `LoginTimeBase` | — | Server queue |
| `MENU_CONNECT_ERROR` | `ConnectErrorScriptModuleUI` | — | Connection errors |
| `MENU_MISSION_LOADER` | `MissionLoader` | — | Intermediate loader |

In-game menus (pause, inventory, map, …) — see [menus.md](menus.md). Dev menus — see [dev_tools.md](dev_tools.md).

---

### MainMenu (PC)

```c
class MainMenu extends UIScriptedMenu
```

Root screen on PC. Layout — `gui/layouts/new_ui/main_menu.layout`.

#### State

| Field | Description |
|-------|-------------|
| `m_Mission : MissionMainMenu` | Parent mission |
| `m_ScenePC : DayZIntroScenePC` | Intro scene with the 3D character model |
| `m_Stats : MainMenuStats` | Player statistics widget |
| `m_Video : MainMenuVideo` | Optional intro-video player |
| `m_NewsCarousel : NewsCarousel` | News and DLC carousel |
| `m_ModsSimple` / `m_ModsDetailed` / `m_ModsTooltip` | Mod list widgets |
| `m_LastFocusedButton` | Return focus on OnShow |
| `m_LastPlayedTooltip*` | Tooltip with info about the last server |

#### Buttons

`m_Play` / `m_ChooseServer` / `m_CustomizeCharacter` / `m_PlayVideo` / `m_Feedback` / `m_Tutorials` / `m_TutorialButton` / `m_MessageButton` / `m_SettingsButton` / `m_Exit` + character switcher (`m_PrevCharacter`/`m_NextCharacter`).

#### Event handling

- `OnClick(w, x, y, button)` — dispatch by widget to `EnterScriptedMenu(MENU_*)`
- `Refresh()` — update player name, mods warning, last server tooltip
- `Update(timeslice)` — animate the intro scene, fade tooltip
- `OnSizeChanged()` — recompute positions on resize

#### MainMenuStats

```c
class MainMenuStats extends ScriptedWidgetEventHandler
```

Sub-widget with the player's lifetime stats (`STAT_PLAYTIME`, `STAT_PLAYERS_KILLED`, `STAT_INFECTED_KILLED`, `STAT_DISTANCE`, `STAT_LONGEST_SHOT`).

| Method | Description |
|--------|-------------|
| `MainMenuStats(Widget root)` | Bind to the root widget `character_stats_root` |
| `ShowStats()` / `HideStats()` | Visibility |
| `UpdateStats()` | Re-read `g_Game.GetMenuData().GetCharactersCount()` etc. |

Survival time is formatted via `FullTimeData`.

---

### MainMenuConsole

```c
class MainMenuConsole extends UIScriptedMenu
```

Console variant. Layout depends on the platform:
- `new_ui/main_menu_msstore.layout` for MS Store
- `new_ui/main_menu_console.layout` for Xbox/PS

Buttons: `m_Play`, `m_ChangeAccount`, `m_CustomizeCharacter`, `m_PlayVideo`, `m_Tutorials`, `m_Options`, `m_Controls`, `m_Exit`, `m_MessageButton`, `m_ShowFeedback` (with a QR code for feedback).

`m_NewsCarousel` is displayed via `#define ENABLE_CAROUSEL` (disabled in `BUILD_EXPERIMENTAL`). `ScreenWidthType` is computed analogously to `InventoryMenu` (see [inventory.md](inventory.md)).

---

### TitleScreenMenu

```c
class TitleScreenMenu extends UIScriptedMenu
```

Console-only "press button" splash. Layout `xbox/day_z_title_screen.layout`. In the constructor sets `g_Game.SetGameState(MAIN_MENU)` + `SetLoadState(MAIN_MENU_START)`.

`Update`: `if (UAUISelect.LocalPress())` — on Windows opens `MENU_MAIN`, on Xbox — `g_Game.GamepadCheck()` (active account selection). Hint text changes dynamically depending on platform and the current "enter" button (cross/circle on PS, A on Xbox).

---

### StartupMenu

```c
class StartupMenu extends UIScriptedMenu
```

Trivial splash from `startup.layout` with a single `TextWidget m_label`. Used as an intermediate screen during engine loading.

---

### MainMenuData

```c
class MainMenuData
```

Static helper for the main menu — cache of news, mods, and DLC. All methods are `static`.

| Method | Description |
|--------|-------------|
| `GetNewsData()` | Load or return `JsonDataNewsList` (news + DLC entries) |
| `GetNewsArticle(index)` | One article from the news |
| `LoadMods()` | Load `array<ref ModInfo>` via `g_Game.GetModInfos()` |
| `FilterDLCs(modArray)` | Separate DLCs from the mods list into `m_AllDlcsMap` |
| `CreateDLCArticles()` | Create articles for DLCs and insert them into `m_NewsData.News` |
| `GetDLCModInfoByName(dlcName)` | Look up ModInfo by short DLC name |
| `GetAllMods()` | All mods including DLCs |

---

### NewsCarousel / MainMenuNewsfeed / MainMenuPromo

Sub-widgets of the main menu (all `extends ScriptedWidgetEventHandler`):

| Class | Purpose |
|-------|---------|
| `NewsCarousel` | Scrollable carousel of news and DLC promos |
| `MainMenuNewsfeed` | Side newsfeed (PC main menu) |
| `MainMenuDlcHandlerBase` | Base handler for DLC promo banners |
| `BannerHandlerBase` | Base class for static banners |
| `MainMenuStats` | Player stats (see above) |

---

### MainMenuVideo / TutorialsMenu

`MainMenuVideo extends UIScriptedMenu` — wrapper around `VideoPlayer` (`gui/newui/videoplayer.c`) for intro/promo clips. `TutorialsMenu extends UIScriptedMenu` — list of tutorial videos, opened from the main menu.

---

### CharacterCreationMenu

```c
class CharacterCreationMenu extends UIScriptedMenu
```

Character customization. Opened via `MENU_CHARACTER`.

#### State

| Field | Description |
|-------|-------------|
| `m_Scene` | `DayZIntroScenePC` (PC) or `DayZIntroSceneXbox` (console) |
| `m_OriginalCharacterID` | For reverting changes |
| `m_CharacterRotationFrame` | Mouse rotation model widget |

#### Selectors

Each field is an `OptionSelectorMultistateCharacterMenu` (see `gui/newui/optionselector*.c`):

| Field | Selector |
|-------|----------|
| Name | `m_NameSelector : OptionSelectorEditbox` |
| Gender | `m_GenderSelector` |
| Skin | `m_SkinSelector` |
| Top | `m_TopSelector` |
| Bottom | `m_BottomSelector` |
| Shoes | `m_ShoesSelector` |

`m_MultiOptionSelectors : map<Widget, OptionSelectorMultistateCharacterMenu>` — for shared click-via-widget logic. Save/apply through `m_Scene.GetIntroCharacter()` and `MenuDefaultCharacterData`.

---

### ServerBrowserMenuNew

```c
class ServerBrowserMenuNew extends UIScriptedMenu
```

Server browser. Layout — `new_ui/server_browser/{pc,xbox}/server_browser.layout`.

#### Structure

```
ServerBrowserMenuNew
  └── TabberUI (m_Tabber)
        ├── m_FavoritesTab    (FAVORITE)
        ├── m_OfficialTab     (OFFICIAL)
        ├── m_CommunityTab    (COMMUNITY)
        └── m_LANTab          (LAN, PC only)
```

Each tab is a `ServerBrowserTab` (or a subclass):

```
ServerBrowserTab : ScriptedWidgetEventHandler
  ├── ServerBrowserTabPc                      (PC tab)
  │     └── ServerBrowserFavoritesTabPc
  └── ServerBrowserTabConsole                 (console tab)
        ├── ServerBrowserTabConsolePages      (with pagination)
        │     └── ServerBrowserFavoritesTabConsolePages
```

#### Constants

```c
const int MAX_FAVORITES = 25;
#ifdef PLATFORM_CONSOLE
    const int SERVER_BROWSER_PAGE_SIZE = 22;
#else
    const int SERVER_BROWSER_PAGE_SIZE = 5;
#endif
```

#### Sub-widgets

| Class | Role |
|-------|------|
| `ServerBrowserEntry` | One row in the server list |
| `ServerBrowserDetailsContainer` | Side panel with details of the selected server |
| `ServerBrowserFilterContainer` | Filters (population, hardcore, …) |

#### Pipeline

1. `OnlineServices.m_ServersAsyncInvoker.Insert(OnLoadServersAsync)` — subscription
2. `ServerBrowserTab.RefreshList()` — request to OnlineServices
3. `OnLoadServersAsync(GetServersResult)` — entries are populated
4. `OnLoadServerModsAsync` — load the list of mods for the selected server

`PPERequester_ServerBrowserBlur` — post-process blur of the background.

---

### OptionsMenu

```c
class OptionsMenu extends UIScriptedMenu
```

Layout — `new_ui/options/{pc,xbox,ps,msstore}/options_menu.layout`.

#### Structure

```
OptionsMenu
  └── TabberUI (m_Tabber)
        ├── m_GameTab     (OptionsMenuGame)
        ├── m_SoundsTab   (OptionsMenuSounds)
        ├── m_VideoTab    (OptionsMenuVideo)        — absent on Xbox
        └── m_ControlsTab (OptionsMenuControls)
```

`m_Options : GameOptions` — backing store for all options (see 3_Game `gameoptions.c`).

#### Buttons

| Button | Action |
|--------|--------|
| `m_Apply` | `m_Options.Apply()` |
| `m_Reset` (undo) | `m_Options.Revert()` |
| `m_Defaults` | `m_Options.Default()` (per tab or all) |
| `m_Back` | `Close()` with a confirmation dialog if there are unsaved changes |

`m_ModalLock` blocks input during dialogs. `m_CanApplyOrReset` tracks whether there are unsaved changes.

#### Tab classes

Each tab `extends ScriptedWidgetEventHandler` with constructor `(parentWidget, detailsWidget, options, parentMenu)`:

| Class | Contains |
|-------|----------|
| `OptionsMenuGame` | Quickbar visibility, language, HUD, blood/violence filters |
| `OptionsMenuSounds` | Volume sliders, voice chat |
| `OptionsMenuVideo` | Resolution, FPS limit, graphics quality |
| `OptionsMenuControls` | Mouse sensitivity, controller layout, link to KeybindingsMenu |

`DependentOptions` (`gui/newui/options/dependentoptions.c`) — system for conditional option visibility.

#### MS Store specifics

`#ifdef PLATFORM_MSSTORE` — adds separate `m_GamepadControls` and `m_KeyboardBindings` buttons (two layouts).

---

### KeybindingsMenu

```c
class KeybindingsMenu extends UIScriptedMenu
```

Full-featured binding editor. Layout — `new_ui/options/{pc,msstore}/keybinding_menu.layout`.

#### Structure

```
KeybindingsMenu
  ├── TabberUI (m_Tabber)             — categories (Movement / Combat / Inventory / ...)
  ├── m_PresetSelector : OptionSelectorMultistate  — preset selection
  └── m_GroupsContainer : KeybindingsContainer
        └── KeybindingsGroup (one per category)
              └── KeybindingElement / KeybindingElementNew (one action)
```

#### Constants

```c
MODAL_ID_BACK = 1337
MODAL_ID_DEFAULT = 100               // reset the current tab
MODAL_ID_DEFAULT_ALL = 101           // reset all tabs
MODAL_ID_PRESET_CHANGE = 200
```

#### Fields

| Field | Description |
|-------|-------------|
| `m_CurrentSettingKeyIndex` / `m_CurrentSettingAlternateKeyIndex` | Primary/alt indices when rebinding |
| `m_OriginalPresetIndex` / `m_TargetPresetIndex` | For revert when changing a preset |
| `m_SetKeybinds : array<int>` | Accumulated list of changed binds |

#### Buttons

`m_Apply`, `m_Back`, `m_Undo`, `m_Defaults`, `m_HardReset` (full reset of all tabs).

#### Binding pipeline

1. The player clicks `KeybindingElement` → input capture
2. `g_Game.SetKeyboardHandle(this)` routes keyboard events to the menu
3. `OnKeyPress(key)` — write into `m_CurrentSettingKey*Index`
4. Confirm/cancel → `Input.SetActionKey(action, deviceType, keyIndex, value)`
5. Apply → `Input.SaveActionsConfig()`

---

### CreditsMenu

```c
class CreditsMenu extends UIScriptedMenu
```

Layout — `new_ui/credits/credits_menu.layout`. Scrolling credits from JSON.

| Constant | Value |
|----------|-------|
| `MENU_FADEIN_TIME` | 2.0s |
| `LOGO_FADEIN_TIME` | 1.0s |
| `CREDIT_SCROLL_SPEED` | 200 px/s (relative to 1080p) |

`m_CreditsData : JsonDataCredits` — list of sections. `m_CreditsEntries : array<CreditsElement>` — populated from `LoadDataAsync` via game script call. Widgets:
- `m_Logo : ImageWidget` — logo fade-in
- `m_Scroller : ScrollWidget` — main scroll
- `m_Content : WrapSpacerWidget` — content

`Update(timeslice)` increments the scroll by `m_ScrollIncrement` (scaled by screen height / 1080).

---

### Mods menu (in-main)

Widgets for the mod list on the main menu (`gui/newui/modsmenu/`):

| Class | Role |
|-------|------|
| `ModsMenuSimple` | Brief list (shown on the main menu) |
| `ModsMenuSimpleEntry` | One row |
| `ModsMenuDetailed` | Full list with details |
| `ModsMenuDetailedEntry` | Full row with description |
| `ModsMenuTooltip` | Tooltip on hover |

All `extends ScriptedWidgetEventHandler`. Data is taken from `MainMenuData.GetAllMods()`.

---

### OptionSelector framework

Generic UI components for options (`gui/newui/optionselector*.c`):

| Class | Purpose |
|-------|---------|
| `OptionSelectorBase` | Base, hover/focus state |
| `OptionSelectorMultistate` | Carousel `[ < value > ]` |
| `OptionSelectorSlider` | Numeric value slider |
| `OptionSelectorSliderSetup` | Slider with stepped setup parameters |
| `OptionSelectorEditbox` | Text field |
| `OptionSelectorLevelMarker` | Discrete levels (low/medium/high) |
| `DropdownPrefab` | Dropdown |
| `TabberPrefab` (`gui/newui/tabberprefab/`) | Tab controller |

Used in OptionsMenu, KeybindingsMenu, CharacterCreationMenu.

---

### Extension

To add a screen to the main menu:

1. Subclass `UIScriptedMenu`, override `Init()` (create layoutRoot)
2. In `MissionBase.CreateScriptedMenu` (via a mod-mission override) add `case MENU_MY: menu = new MyMenu;`
3. Open via `g_Game.GetUIManager().EnterScriptedMenu(MENU_MY, m_mainmenu)`
4. To integrate with the scene — get `m_Scene` via `MissionMainMenu.GetIntroScenePC/Xbox()`
5. For platform-dependent layouts use a `#ifdef PLATFORM_*` switch

See [mission.md](mission.md) — `MissionMainMenu.Reset()` recreates the scene and the root menu.
