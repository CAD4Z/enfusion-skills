Developer tools: ScriptConsole, SceneEditor, CameraTools. Sources: `gui/scriptconsole*.c`, `gui/sceneeditormenu*.c`, `gui/cameratools/`

All tools are `UIScriptedMenu`s on top of the regular HUD; they require `DIAG_DEVELOPER`/`DEVELOPER` builds. Opened via console commands / debug menu / diagnostic bindings (`MissionGameplay` listens to `UADebug*` inputs).

### Catalog

| Menu | ID | Layout | Purpose |
|------|-----|--------|---------|
| `ScriptConsole` | `MENU_SCRIPTCONSOLE` | `script_console/script_console.layout` | Spawning items, executing scripts, debugging the player |
| `SceneEditorMenu` | `MENU_SCENE_EDITOR` | `scene_editor/scene_editor.layout` | Editor for static scenes (objects, ruler, positions) |
| `CameraToolsMenu` | `MENU_CAMERA_TOOLS` | `camera_tools/camera_tools.layout` | Cinematic keyframe cameras |
| `HudDebug` | — | `day_z_hud_debug.layout` | Stats/modifiers overlay — see [hud.md](hud.md) |

---

### ScriptConsole

```c
class ScriptConsole extends UIScriptedMenu
```

The main dev tool. A set of tabs (`ScriptConsoleTabBase`), a hint system with tooltips on hover, shared `PluginConfigDebugProfile` for persisting state.

#### Lifecycle

| Method | Description |
|--------|-------------|
| `ScriptConsole()` | Hides HUD (`ShowHudPlayer(false)`, `ShowQuickbarPlayer(false)`), notifies `PluginItemDiagnostic.OnScriptMenuOpened(true)` |
| `Init()` | Creates the layout, registers all tabs via `RegisterTab(new ...)`, restores `m_SelectedTab` from the profile, loads hint JSON |
| `~ScriptConsole()` | Restores HUD, `EnableAllInputs(true)`, notifies the plugin |
| `RegisterTab(handler)` | Inserts into `m_TabHandlers : map<Widget, ScriptConsoleTabBase>` and `m_TabHandlersByID`, calls `handler.Init(m_Id++)` |
| `Update(timeslice)` | Hover timer → `HoverSuccess()` → `DisplayHint(GetMessage())` |

#### ScriptConsole fields

| Field | Description |
|-------|-------------|
| `m_TabHandlers : map<Widget, ref ScriptConsoleTabBase>` | Button → handler |
| `m_TabHandlersByID : map<int, ref ScriptConsoleTabBase>` | ID → handler |
| `m_SelectedHandler : ScriptConsoleTabBase` | Currently active tab |
| `m_JsonData : JsonHintsData` | Hint bindings (widget hash → text) |
| `m_MarkedEntities : static array<ref MapMarker>` | Shared set of markers on the debug map |
| `m_ConfigDebugProfile : PluginConfigDebugProfile` | Persisted state (which tab, checkboxes, presets) |

#### Tabs

Registered in `Init()` in a fixed order:

| Tab | Class | Purpose |
|-----|-------|---------|
| **Items** | `ScriptConsoleItemsTab` | Spawn items into the world/inventory/hands, categories, loot presets, draw-in-world |
| **Configs** | `ScriptConsoleConfigTab` | Hierarchical config viewer (classes + variables), dump-param |
| **EnScript** | `ScriptConsoleEnfScriptTab` | Execute EnScript on the client (`CallFunction`) |
| **EnScriptServer** | `ScriptConsoleEnfScriptServerTab` | Same, but on the server (via RPC) |
| **General** | `ScriptConsoleGeneralTab` | Debug map, teleport by coordinates, time slider, toggle diagnostics/logs, list of other players |
| **Output** | `ScriptConsoleOutputTab` | Client console logs (`Debug.ClearLogs`, auto-scroll) |
| **Vicinity** | `ScriptConsoleVicinityTab` | List of objects around the player with context menu |
| **Sounds** | `ScriptConsoleSoundsTab` | Sound event debug, spawn/play soundsets, map |
| **Weather** | `ScriptConsoleWeatherTab` | Fog/overcast/rain/wind sliders with interpolation and duration |
| **Camera** | `ScriptConsoleCameraTab` | FOV/focus/blur/DOF through `ScriptConsoleSelector` (sliders) |

Server-side-only dedicated build: Sounds/Camera tabs are disabled by the condition `!g_Game.IsDedicatedServer()`.

#### ScriptConsoleTabBase

```c
class ScriptConsoleTabBase
```

Base class for a tab. Subclasses implement the necessary overrides:

| Field | Description |
|-------|-------------|
| `m_Id : int` | Auto-incremented ID (assigned by `RegisterTab`) |
| `m_IsSelected : bool` | Active tab |
| `m_IsShiftDown : bool` | Shift state for multi-select |
| `m_ScriptConsole : ScriptConsole` | Parent |
| `m_ConfigDebugProfile : PluginConfigDebugProfile` | Persisted state |

| Override | Description |
|----------|-------------|
| `OnSelected()` | When the tab is selected |
| `OnChange(w,x,y,finished)` | EditBox/Slider changes |
| `OnClick(w,x,y,button)` | Button click |
| `OnItemSelected(w,row,column,…)` | Listbox selection |
| `OnKeyDown/OnKeyPress(w,x,y,key)` | Keyboard |
| `OnDoubleClick(w,x,y,button)` | Double click |
| `OnRPCEx(rpc_type, ctx)` | RPC hook |
| `OnMouseEnter/OnMouseLeave/OnMouseButtonDown` | Mouse events |

Helper: `AddItemToClipboard(string)`. All overrides are forwarded from `ScriptConsole.OnChange/OnClick/...` to `m_SelectedHandler`.

#### ScriptConsoleSelector

```c
class ScriptConsoleSelector extends OptionSelectorSliderSetup
```

Slider widget for numeric values in the Camera/Weather tabs. Layout `gui/layouts/new_ui/script_console_slider.layout`. Stores its parent (`m_ParentTab`) for callbacks.

#### Hint system

- Hover over any widget → `m_HoverTime` grows → on reaching the threshold `HoverSuccess()` → `DisplayHint(GetMessage())`
- Widget hash: `GetWidgetCombinedHash(w) = (w.GetName() + w.GetParent().GetName()).Hash()`
- JSON bindings are stored in `m_JsonData.WidgetHintBindings : map<int, string>`
- Edit mode: `m_HintEditMode` → shows `m_EditTooltipRoot` (layout `script_console_tooltip_edit.layout`) with an input field. On Ok → `SetHintText` saves to the map → `SaveData()` to `$mission:script_console_hints.json`
- Fallback `HINTS_PATH_DEFAULT = "scripts/data/internal/script_console_hints.json"` (read-only default)

#### Sub-dialogs

Files in `gui/scriptconsole/`:

| Class | Purpose |
|-------|---------|
| `ScriptConsoleAddPositionDialog` | Popup for adding a named position |
| `ScriptConsoleNewPresetDialog` | Create a new loot preset |
| `ScriptConsoleRenamePresetDialog` | Rename a preset |
| `ScriptConsoleUniversalInfoDialog` | Universal info popup |

All are standalone `UIScriptedMenu`s, opened from the Items tab.

Plugins accessed by ScriptConsole:

| Plugin | Purpose |
|--------|---------|
| `PluginConfigDebugProfile` | Persist custom presets/tab selection |
| `PluginConfigDebugProfileFixed` | Hardcoded fixed presets |
| `PluginDeveloper` | Spawn items, ClearInventory, teleport |
| `PluginItemDiagnostic` | Item watch window |
| `PluginLocalEnscriptHistory` | EnScript expression history (client) |
| `PluginLocalEnscriptHistoryServer` | History (server) |
| `PluginConfigViewer` | Config hierarchy for the Configs tab |
| `PluginSceneManager` | Link with SceneEditor (shared objects) |

See [4_World/plugins.md](../4_World/plugins.md) — where they live.

---

### SceneEditorMenu

```c
class SceneEditorMenu extends UIScriptedMenu
```

Editor for static modded scenes. Each "scene" is a set of `SceneObject`s with position/rotation/health/init-script. Stored in `PluginSceneManager`. Layout — `gui/layouts/scene_editor/scene_editor.layout`.

#### UI sections

```
SceneEditorMenu
  ├── Top bar         : Scene Manager / Settings / Save / Editor Settings / Delete Ruler
  ├── Scene Object List  (TextListboxWidget m_SlWgtLbxObjectsList)
  │     └── filter (m_SlWgtEbxFilter), Select, Focus
  ├── Config Class List  (m_ClWgtLbxClassesList — for adding new objects)
  │     └── filter (m_ClWgtEbxFilter), Add as Attachment
  ├── Properties panel
  │     ├── class name, x/y/z, direction, damage
  │     ├── "Edit Init Script" button → POPUP_ID_INIT_SCRIPT
  │     └── Attachments list (UIPropertyAttachments)
  ├── Presets panel   (shared with ScriptConsole, spawn on ground / inventory / attachment)
  └── Popups layer    (m_WgtPopupsMain) — active popups
```

#### Popup IDs

```c
POPUP_ID_SCENE_MANAGER    = 0   // scene list, load/create
POPUP_ID_SCENE_SETTINGS   = 1
POPUP_ID_SCENE_NEW        = 2
POPUP_ID_SCENE_RENAME     = 3
POPUP_ID_SCENE_DELETE     = 4
POPUP_ID_NOTIFY           = 5   // pop-up notifications
POPUP_ID_EDITOR_SETTINGS  = 6
POPUP_ID_INIT_SCRIPT      = 7   // edit an object's init script
POPUP_ID_POSITION_MANAGER = 8
POPUP_ID_PRESET_NEW       = 9
POPUP_ID_PRESET_RENAME    = 10
POPUP_ID_CONFIGS          = 11
```

All popups are subclasses of `UIPopupScript` from `gui/sceneeditormenu/uipopupscript.c`:

```c
class UIPopupScript
{
    void OnOpen(Param param);
    void OnClose();
    void Show(bool show);
    bool OnClick/OnChange(...);
    protected UIPopupScript PopupBack();   // go back to the previous one on the stack
}
```

`SceneEditorMenu` keeps `m_OpenedPopups : TIntArray` (stack) and `m_Popups : map<int, ref UIPopupScript>`. Opening via `OpenPopup(id, param)` → push + Show. `PopupBack()` → pop from the stack.

#### Pipeline

1. User selects a scene in the Scene Manager popup → `PluginSceneManager.SceneLoad(name)`
2. `PluginSceneManager` spawns objects, sends `SCENE_EDITOR_CMD_REFRESH` through `SceneEditorCommand` → `Refresh()`
3. `Refresh()` updates `m_SlObjectsList` (filtered by `m_SlWgtEbxFilter`), properties of the current object, ruler state
4. Edit → `PluginSceneManager.SceneSave()` → `SCENE_EDITOR_CMD_SAVE` → fade animation `m_NotifyWgtPanel` (via `m_NotifyFadeTimer : WidgetFadeTimer`)

#### UIPropertyAttachment

```c
class UIPropertyAttachment
```

A small widget wrapper for a single attachment of the selected object. One instance per slot. Stores a reference to the `SceneObject` + slot name, add/remove buttons.

---

### CameraToolsMenu

```c
class CameraToolsMenu extends UIScriptedMenu
```

Cinematic camera for cutscenes/trailers. Records keyframes of camera position + events (FX/actions) + actors (NPCs with clothing). Plays back a smooth curve between keyframes. Layout `gui/layouts/camera_tools/camera_tools.layout`.

#### Architecture

```
CameraToolsMenu
  ├── m_Camera1 / m_Camera2        (StaticCamera — swap buffer for interpolation)
  ├── m_Cameras : array<CTKeyframe>    (list of keyframes)
  ├── m_Events  : array<CTEvent>       (triggers on the timeline)
  ├── m_Actors  : array<CTActor>       (spawned NPCs with loadouts)
  ├── m_CameraLines : array<Param6<...>>   (recorded positions for track rendering)
  └── m_SelectedKeyframe/Event/Actor   (current selection)
```

Input mode: `AddActiveInputExcludes({"menu"})`, `DeveloperFreeCamera.EnableFreeCameraSceneEditor`, HUD is hidden via `mission.GetHud().Show(false)`. On close everything is restored.

#### Lifecycle

| Method | Description |
|--------|-------------|
| `CameraToolsMenu()` | Creates `m_Camera1`/`m_Camera2` through `g_Game.CreateObject("staticcamera", ...)`, opens the free camera |
| `~CameraToolsMenu()` | `Stop()` playback, hides the cursor, removes input excludes, `SaveData()`, restores the HUD |
| `Init()` | Creates the layout, binds all widgets (m_AddKeyframe/Event/Actor, m_Play/Stop/Save/Load, m_CopyButton/ApplyButton/CameraEditbox, …) |
| `OnShow()` / `OnHide()` | Toggle input excludes (if playback isn't running) |

#### Operations

| Button | Action |
|--------|--------|
| Add Keyframe | Insert a `CTKeyframe` with the current freecam position, FOV, DOF, pin, interp time |
| Save/Delete Keyframe | Persist changes to the current keyframe |
| Snap to Keyframe | Teleport the camera to the selected one |
| Add Event | `CTEvent` at the current timeline time |
| Add Actor | `CTActor` (NPC) from `m_ActorTypeWidget`, hands item from `m_ActorItemTypeWidget` |
| Play/Stop | Interpolate `m_Camera1` → `m_Camera2` along the keyframe path, trigger events |
| Save/Load | Via `CTSaveStructure` → `$profile:/CameraTools` (field `m_CameraToolsDataPath`) |

#### CT* wrappers (helpers)

| Class | Parent | Layout | Description |
|-------|--------|--------|-------------|
| `CTKeyframe` | `ScriptedWidgetEventHandler` | `camera_tools/keyframe_entry.layout` | One row in the keyframes list (index, interp time, FOV, DOF, pin) |
| `CTEvent` | `ScriptedWidgetEventHandler` | `camera_tools/event_entry.layout` | One row in events — event type + parameters |
| `CTActor` | `CTObjectFollower` | `camera_tools/actor_entry.layout` | Spawned actor bound to an object in the world |
| `CTObjectFollower` | `ScriptedWidgetEventHandler` | — | Base class with follow logic (object → widget row) |
| `CTSaveStructure` | — | — | POD for JSON serialization of scenes (keyframes/events/actors) |

#### Interpolation types

`m_InterpTypeCombo` / `m_InterpTypeSpeedCombo` — dropdowns with options (Linear, Cubic, Bezier, …). The value is stored in the keyframe and affects the `Update()` loop that interpolates position between `m_Camera1` and `m_Camera2`.

---

### HudDebug (#ifdef DEVELOPER)

Overlay of debug windows on top of the game. Not a standalone menu — lives inside `MissionGameplay` and renders on top of the HUD. See [hud.md](hud.md) section **HudDebug**.

Windows: `HUD_WIN_CHAR_STATS`, `HUD_WIN_CHAR_MODIFIERS`, `HUD_WIN_CHAR_AGENTS`, `HUD_WIN_CHAR_DEBUG`, `HUD_WIN_CHAR_LEVELS`, `HUD_WIN_CHAR_STOMACH`, `HUD_WIN_VERSION`, `HUD_WIN_TEMPERATURE`, `HUD_WIN_HEALTH`, `HUD_WIN_HORTICULTURE`. Visibility is toggled from `ScriptConsoleGeneralTab` (`m_HudDCharStats` and friends) → `PluginConfigDebugProfile` → `HudDebug.RefreshByLocalProfile()`.

---

### Typical debug flow

1. Open `ScriptConsole` (console command / debug binding)
2. Items tab → pick an item → Spawn in Hands / On Ground / In Inventory
3. General tab → enable the required HudDebug windows (Char Stats, Health, …)
4. EnScript tab → execute arbitrary code on the client (or EnScriptServer on the server)
5. Configs tab → inspect config parameters of the selected class
6. Vicinity tab → get a list of nearby objects, watch a specific one

All state (which tab, checkboxes, presets) lives in `PluginConfigDebugProfile` and is saved between sessions.

---

### Extension

- **New ScriptConsole tab**: subclass `ScriptConsoleTabBase`, register in `ScriptConsole.Init()` via `RegisterTab(new MyTab(root, this, button))`. The button must exist in the layout.
- **New SceneEditor popup**: subclass `UIPopupScript`, add to `m_Popups` in `Init()`, declare a new `POPUP_ID_*` constant.
- **Hint for a widget**: hover in edit mode (Shift?) → enter text → Ok. Saved into `$mission:script_console_hints.json`.
