In-game menus — all `UIScriptedMenu`s opened during gameplay. Sources: `gui/*.c`

### Registration

All menus are created by a single factory `MissionBase.CreateScriptedMenu(MENU_ID)` (see [mission.md](mission.md)). Opened via `g_Game.GetUIManager().EnterScriptedMenu(MENU_ID, parent)` (push) or `EnterScriptedMenu_Temp` (overlay).

The `MENU_*` constants are defined in 3_Game (`scripts/3_Game/constants.c`). This file is a reference for the concrete implementations opened during `MissionGameplay` (in-game). The main menu — see [mainmenu.md](mainmenu.md).

---

### Menu catalog

| MENU_ID | Class (PC) | Class (Console) | Layout | Purpose |
|---------|------------|------------------|--------|---------|
| `MENU_INGAME` | `InGameMenu` | `InGameMenuXbox` | `day_z_ingamemenu.layout` | Pause/exit/respawn/options |
| `MENU_INVENTORY` | `InventoryMenu` | (same) | `day_z_inventory.layout` | Inventory — see [inventory.md](inventory.md) |
| `MENU_INSPECT` | `InspectMenuNew` | (same) | `inventory_new/day_z_inventory_new_inspect.layout` | Item inspection (3D preview) |
| `MENU_MAP` | `MapMenu` | (same) | `day_z_map.layout` | Paper map (compass/GPS optional) |
| `MENU_NOTE` | `NoteMenu` | (same) | `day_z_inventory_note.layout` | Read/write a paper note |
| `MENU_BOOK` | `BookMenu` | (same) | `day_z_book.layout` | Read a book |
| `MENU_GESTURES` | `GesturesMenu` | (same) | `radial_menu.layout` | Radial emotes menu |
| `MENU_RADIAL_QUICKBAR` | `RadialQuickbarMenu` | (same) | `radial_menu.layout` | Radial quickbar |
| `MENU_LOGOUT` | `LogoutMenu` | (same) | `day_z_logout_dialog.layout` | Disconnect timer |
| `MENU_RESPAWN_DIALOGUE` | `RespawnDialogue` | (same) | `day_z_respawn_dialogue.layout` | Random/custom respawn selection |
| `MENU_INVITE_TIMER` | `InviteMenu` | (same) | `day_z_invite_dialog.layout` | Join-by-invite progress |
| `MENU_HELP_SCREEN` | `HelpScreen` | (same) | `day_z_help_screen.layout` | Help screen |
| `MENU_LOADING` | `LoadingMenu` | (same) | `loading.layout` | Loading screen |
| `MENU_CHAT_INPUT` | `ChatInputMenu` | (same) | — | Chat input box (see [chat.md](chat.md)) |
| `MENU_CONNECTION_DIALOGUE` | `ConnectionDialogue` | (same) | `day_z_connection_dialogue.layout` | Network input buffer overflowed |
| `MENU_WARNING_ITEMDROP` | `ItemDropWarningMenu` | (same) | `day_z_dropped_items.layout` | Warning about dropping items |
| `MENU_WARNING_TELEPORT` | `PlayerRepositionWarningMenu` | (same) | (same) | Warning about teleport |
| `MENU_WARNING_INPUTDEVICE_DISCONNECT` | `InputDeviceDisconnectWarningMenu` | (same) | — | Warning about controller disconnect |
| `MENU_EARLYACCESS` | `EarlyAccessMenu` | (same) | — | Early access splash |
| `MENU_CONTROLS_PRESET` | `PresetsMenu` | (same) | — | Controls preset selection |

Main/lobby menus (`MENU_MAIN`, `MENU_TITLE_SCREEN`, `MENU_OPTIONS`, `MENU_SERVER_BROWSER`, `MENU_CHARACTER`, …) — see [mainmenu.md](mainmenu.md).

Dev menus (`MENU_SCRIPTCONSOLE*`, `MENU_SCENE_EDITOR`, `MENU_CAMERA_TOOLS`, `MENU_LOC_ADD`) — see [dev_tools.md](dev_tools.md).

---

### Common patterns

#### Pause/Continue

Opening most in-game menus should pause the game:

```c
void InGameMenu()
{
    // ...
    Mission mission = g_Game.GetMission();
    if (mission)
        mission.Pause();    // → MissionGameplay.Pause()
}

void ~InGameMenu()
{
    // ...
    if (mission)
        mission.Continue();
}
```

#### Input excludes

Menus that block game input register a group from `specific.xml`:

```c
g_Game.GetMission().AddActiveInputExcludes({"menu"});       // full block
g_Game.GetMission().AddActiveInputExcludes({"inventory"});  // only the required layers
g_Game.GetMission().AddActiveInputExcludes({"radialmenu"}); // radial menus
g_Game.GetMission().AddActiveInputExcludes({"map"});
g_Game.GetMission().AddActiveInputExcludes({"inspect"});
```

In the destructor `RemoveActiveInputExcludes(...)` is mandatory. See [mission.md](mission.md) — input excludes.

#### HUD hiding

Menus often hide the HUD:

```c
hud.ShowHudUI(false);       // everything except quickbar
hud.ShowQuickbarUI(false);
```

See [hud.md](hud.md) — HUD visibility API.

#### Console toolbar / Input device hooks

Any menu with console support:
1. Subscribes to `mission.GetOnInputPresetChanged()` and `GetOnInputDeviceChanged()` in `Init()`/constructor
2. In `OnInputDeviceChanged(EInputDeviceType)` switches the cursor/focus button
3. Uses `InputUtils.GetRichtextButtonIconFromInputAction(actionName, label, deviceType, scale)` for dynamic icons

---

### InGameMenu / InGameMenuXbox

`MENU_INGAME` — pause. Platform-dependent class via switch in `MissionBase.CreateScriptedMenu`:

```c
case MENU_INGAME:
    #ifdef PLATFORM_CONSOLE
        menu = new InGameMenuXbox;
    #else
        menu = new InGameMenu;
    #endif
```

#### InGameMenu (PC)

Buttons: Continue, Restart/Respawn (depends on MP/SP), Options, Exit, Feedback, Copy server info, Favorite. Plus separate `respawn_button_random/custom` if the player is dead.

| Method | Description |
|--------|-------------|
| `SetGameVersion()` | Read `g_Game.GetVersion()`, write into the `version` widget |
| `SetServerInfo()` | Populate server name/IP/port from `OnlineServices.GetCurrentServerInfo()` |
| `OnFavoriteChanged(checked)` | Toggle favorite via `OnlineServices.SetServerFavorited` |
| `CopyServerInfo()` | To clipboard — for bug reports |
| `HudShow(bool)` | Hides/shows the HUD on open/close |
| `m_HintPanel : UiHintPanel` | Hints on the pause screen |

#### InGameMenuXbox (Console)

Extended version with Xbox Live integration: player list (`PlayerListScriptedWidget`), invite, mute/unmute, gamercard, feedback QR code. Dynamic exit-button cooldown via `m_ExitButtonUpdateTimerSum`/`m_ExitOnCooldown`. Listens to `ClientData.SyncEvent_OnPlayerListUpdate` and `OnlineServices.m_PermissionsAsyncInvoker`.

| Method | Description |
|--------|-------------|
| `SyncEvent_OnRecievedPlayerList(players)` | Update `m_ServerInfoPanel` |
| `OnPermissionsUpdate(...)` | Re-check availability of mute/invite/gamercard |
| `OnInputPresetChanged()` / `OnInputDeviceChanged(...)` | Swap toolbar icons |
| `UpdateControlsElements()` | Full refresh of button hints |

---

### InspectMenuNew

```c
class InspectMenuNew extends UIScriptedMenu
```

Opened from `LayoutHolder.InspectItem(item)` (see [inventory.md](inventory.md)). The constructor calls `AddActiveInputExcludes({"inspect"})`. `Init()` creates `inventory_new/day_z_inventory_new_inspect.layout`. Starts `PPERequester_InventoryBlur` (post-process blur).

| Method | Description |
|--------|-------------|
| `SetItem(EntityAI item)` | Set the displayed item, call `UpdateItemInfo` |
| `static UpdateItemInfo(layoutRoot, item)` | Fill all info fields (name, weight, status…) |
| `OnMouseButtonDown(w, x, y, button)` | Start mouse rotation |
| `Update(timeslice)` | Handle rotation/zoom |

3D model — `ItemPreviewWidget`, reads `item.GetViewIndex()`. Supports X/Y rotation and scale via mouse drag/wheel.

---

### MapMenu

```c
class MapMenu extends UIScriptedMenu
```

Paper map. Opened via `UAMapToggle` if the player owns a map (or the `ignoreMapOwnership` parameter).

#### State

| Field | Description |
|-------|-------------|
| `m_MapWidgetInstance : MapWidget` | The map widget itself (engine-side) |
| `m_HasCompass` / `m_HasGPS` | Additional tools in the player's inventory |
| `m_MapMenuHandler : MapHandler` | Handler for clicks/drag (see `gui/maphandler.c`) |
| `m_MapNavigationBehaviour` | Pan/zoom behavior |
| `m_GPSMarker` / `m_GPSMarkerArrow` | Player position icon (if GPS is present) |
| `m_ToolsCompassBase`/`Arrow`/`Azimuth` | Compass UI (if a compass is present) |
| `m_ToolsScale*` | Scale ruler |

#### Behavior

- Starting position/zoom via `player.GetLastMapInfo()` or `CfgWorlds %1 centerPosition`
- Position is saved via `player.SetLastMapInfo(scale, pos)` on close
- Compass: `azimuth = -m_MapWidgetInstance.GetMapRotation() % 360`
- GPS: `m_GPSMarker.SetPos(...)` is updated in `Update()` from `player.GetPosition()`
- World markers — static registry `MapMarkerTypes` (see [hud.md](hud.md))

---

### NoteMenu

```c
class NoteMenu extends UIScriptedMenu
```

Read/write a paper note.

| Method | Description |
|--------|-------------|
| `InitNoteRead(text)` | Read-only, shows `HtmlWidget` |
| `InitNoteWrite(paper, pen, text)` | Edit mode with `MultilineEditBoxWidget`, reads `pen.ConfigGetString("writingColor")` |
| `OnClick → IDC_OK` | Sends `RPC_WRITE_NOTE_CLIENT` with text sanitized via `MiscGameplayFunctions.SanitizeString` |

The constructor/destructor hides/shows the HUD UI. Supports `UAUIBack` for closing.

---

### BookMenu

Reading a multi-page book (`day_z_book.layout`). Simple next/prev page navigation.

---

### GesturesMenu

```c
class GesturesMenu extends UIScriptedMenu
```

Radial emote menu with five categories + a console category:

```c
enum GestureCategories
{
    CATEGORIES, CATEGORY_1, CATEGORY_2, CATEGORY_3, CATEGORY_4, CATEGORY_5,
    CONSOLE_GESTURES
}
```

Each emote is a `GestureMenuItem(id, name, category)`, referencing an `EmoteBase` via `player.GetEmoteManager().GetNameEmoteMap()`. Shows the bound key via `InputUtils.GetComboButtonNamesFromInput(emoteClass.GetInputActionName(), MOUSE_AND_KEYBOARD)`.

| Method | Description |
|--------|-------------|
| `static OpenMenu(parent)` / `CloseMenu()` | Open `MENU_GESTURES` |
| `SwitchCategory(int)` | Switch the page |
| `PerformGesture(id)` | Via `player.GetEmoteManager().CreateEmoteCBFromMenu(id)` |

`AddActiveInputExcludes({"radialmenu"})` in the constructor.

---

### RadialQuickbarMenu

```c
class RadialQuickbarMenu extends UIScriptedMenu
```

Radial quickbar for assigning an item to a hotkey slot.

| Field | Description |
|-------|-------------|
| `static instance` | Singleton |
| `static m_ItemToAssign : EntityAI` | Item to place into the slot (if opened from drag) |
| `m_CurrentCategory : int` | Current category (`RadialQuickbarCategory.DEFAULT`) |
| `m_Items : array<RadialQuickbarItem>` | Quickbar slots as radial elements |

| Method | Description |
|--------|-------------|
| `static OpenMenu(parent)` | Via `g_Game.GetUIManager().EnterScriptedMenu(MENU_RADIAL_QUICKBAR, parent)` |
| `static CloseMenu()` | `Back()` |
| `static SetItemToAssign(item)` / `GetItemToAssign()` | Used for the drag→radial flow from inventory |

`AddActiveInputExcludes({"radialmenu"})` in the constructor.

---

### LogoutMenu

```c
class LogoutMenu extends UIScriptedMenu
```

Disconnect timer (`MissionGameplay.StartLogoutMenu(time)`).

| Field | Description |
|-------|-------------|
| `m_iTime` | Remaining seconds |
| `m_FullTime : FullTimeData` | Time formatting helper |
| `m_bLogoutNow` / `m_bCancel` | Immediate exit / cancel buttons |

In the constructor: `g_Game.SetKeyboardHandle(this)`; the destructor resets it + `Cancel()` on irregular close. If the player is not restrained/unconscious — `player.GetEmoteManager().SetClientLoggingOut(true)` (sits down).

---

### RespawnDialogue

```c
class RespawnDialogue extends UIScriptedMenu
```

Dialog for choosing random/custom respawn after death.

| Constant | Purpose |
|----------|---------|
| `ID_RESPAWN_RANDOM = 102` | Random point |
| `ID_RESPAWN_CUSTOM = 101` | Pick on the map (if supported) |

In `Update`: auto-closes if `playerAlive && !IsUnconscious()`. `OnMouseEnter` shows the `m_DetailsRoot` tooltip with `#main_menu_respawn_random_tooltip`. `RequestRespawn(bool random)` — RPC to the server.

---

### InviteMenu

15-second timer in invite-join mode. The constructor puts the player into the SITA emote via `player.GetEmoteManager().CreateEmoteCBFromMenu(EmoteConstants.ID_EMOTE_SITA)` with `EmoteLauncher.FORCE_DIFFERENT`. Hides HUD UI and quickbar, adds `"menu"` to excludes.

---

### WarningMenuBase

```c
class WarningMenuBase : UIScriptedMenu
```

Base for warning popups. In the constructor/destructor sets/removes `"menu"` excludes and hides the HUD. `Init()` creates `day_z_dropped_items.layout`. Overriding `GetText()` returns the text.

| Subclass | Purpose |
|----------|---------|
| `ItemDropWarningMenu` | "Items will be dropped on exit" |
| `PlayerRepositionWarningMenu` | "The player will be moved" |

`InputDeviceDisconnectWarningMenu` is a separate class (extends `UIScriptedMenu` directly), for the controller-disconnect warning.

---

### LoadingMenu

```c
class LoadingMenu extends UIScriptedMenu
```

Minimal loading screen: `TextWidget m_label`, `ProgressBarWidget m_progressBar`, `ImageWidget m_image` with a random background via `GetRandomLoadingBackground()`. On Xbox experimental builds it shows a `notification_root` widget.

---

### ConnectionDialogue

`MENU_CONNECTION_DIALOGUE` — dialog opened on `NetworkInputBufferEventTypeID` (input buffer overflow). Opened from `MissionGameplay.OnEvent`. Shows `MultilineTextWidget m_Description` and a Disconnect button. Cannot be closed except through disconnect.

---

### EarlyAccessMenu / HelpScreen

`EarlyAccessMenu` — splash for experimental builds. `HelpScreen` — static help screen `day_z_help_screen.layout`. Both are trivial.

---

### PresetsMenu

`MENU_CONTROLS_PRESET` — selection of a controls preset (for KeybindingsMenu). Populated from `g_Game.GetInput().GetProfilesCount()`. Simple list select.

---

### Extension

To add a custom menu:

1. Define a new `MENU_*` ID in 3_Game `constants.c`
2. Create a class `extends UIScriptedMenu`
3. Override `Init()` — create layoutRoot from your layout
4. In `MissionBase.CreateScriptedMenu` (via a mod-mission override) add `case MENU_MY: menu = new MyMenu; break;`
5. Open via `g_Game.GetUIManager().EnterScriptedMenu(MENU_MY, parent_menu)`
6. Don't forget Pause/Continue, input excludes, HUD hide, unsubscribing in the destructor

See [mission.md](mission.md) for lifecycle overview and input excludes API.
