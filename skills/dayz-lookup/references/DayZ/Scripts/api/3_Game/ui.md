UI system: manager, menus, widgets. Sources: `tools/uimanager.c`, `tools/uidata.c`, `gui/`

### UIManager

User interface manager. Access: `g_Game.GetUIManager()`. Source: `tools/uimanager.c`

#### Menus (proto native)

| Method | Return | Description |
|--------|--------|-------------|
| `EnterScriptedMenu(id, parent)` | `UIScriptedMenu` | Open menu by ID |
| `CreateScriptedMenu(id)` | `UIScriptedMenu` | Create menu (without showing) |
| `ShowScriptedMenu(menu, parent)` | `UIScriptedMenu` | Show a created menu |
| `HideScriptedMenu(menu)` | `void` | Hide menu |
| `GetMenu()` | `UIScriptedMenu` | Currently active menu |
| `IsMenuOpen(id)` | `bool` | Whether menu with ID is open |
| `CloseAll()` | `void` | Close all menus |
| `Back()` | `void` | Go back |

#### Dialogs

| Method | Description |
|--------|-------------|
| `ShowDialog(caption, text, id, buttons, defaultBtn, dialogType, handler)` | Modal dialog |

#### Cursor (proto native)

| Method | Description |
|--------|-------------|
| `ShowCursor(visible)` | Show/hide |
| `IsCursorVisible()` | Is visible |

#### Screen (proto native)

| Method | Description |
|--------|-------------|
| `ScreenFadeIn(time, color, reason)` | Fade in |
| `ScreenFadeOut(time, color, reason)` | Fade out |
| `IsScreenFadeVisible()` | In progress |

### UIScriptedMenu

Base class for scripted menus. Inherits `UIMenuPanel`.

| Method | Description |
|--------|-------------|
| `Init()` → `Widget` | Initialization, returns the root widget |
| `Cleanup()` | Resource cleanup |
| `Update(float timeslice)` | Per-frame update |
| `Refresh()` | Data refresh |
| `OnShow()` / `OnHide()` | Show/hide |
| `SetFocus(widget)` | Set focus |
| `OnClick(w, x, y, button)` → `bool` | Widget click |
| `OnChange(w, x, y, finished)` → `bool` | Value change |
| `OnFocus(w, x, y)` → `bool` | Gained focus |
| `OnFocusLost(w, x, y)` → `bool` | Lost focus |
| `IsHandlingPlayerDeathEvent()` → `bool` | Handles death event |

### UIScriptedWindow

Base class for scripted windows. Similar to `UIScriptedMenu`, but for non-fullscreen windows.

### GUI widgets

Source: `gui/`

#### Tabber

Tab navigation.

| Method | Description |
|--------|-------------|
| `SelectTab(index)` | Select a tab |
| `OnClick(w, x, y, button)` | Handle click |

#### Spacers

Widget layout management.

| Class | Description |
|-------|-------------|
| `SpacerBase` | Base spacer |
| `HorizontalSpacer` | Horizontal layout |
| `VerticalSpacer` | Vertical layout |
| `AutoHeightSpacer` | Auto height |
| `HorizontalSpacerWithFixedAspect` | Fixed aspect ratio |

#### Animations

| Class | Description |
|-------|-------------|
| `HoverEffect` | Hover effect |
| `RadialMenu` | Radial menu |
| `RadialProgressBar` | Circular progress bar |
| `Rotator` | Rotation |
| `Bouncer` | Bounce |

#### Containers

| Class | Description |
|-------|-------------|
| `ScrollbarContainer` | Scrollable container |
| `SizeToChild` | Size based on child |

#### Hints

| Class | Description |
|-------|-------------|
| `UIHintPanel` | Hint panel |
| `HintPage` | Hint page |

### GameplayEffectWidgets_base

Base class for UI overlays of gameplay effects. Source: `gameplayeffectwidgets_base.c`

| Method | Description |
|--------|-------------|
| `IsAnyEffectRunning()` | Active effects exist |
| `AreEffectsSuspended()` | Effects suspended |
| `AddActiveEffects(effects)` / `RemoveActiveEffects(effects)` | Management |
| `StopAllEffects()` | Stop all |
| `AddSuspendRequest(id)` / `RemoveSuspendRequest(id)` | Suspension |
| `UpdateWidgets()` / `Update()` | Update |
| `OnVoiceEvent(breathing_resistance)` | Voice event |
| `SetBreathIntensityStamina(value)` | Breath intensity |

### EffectWidgetsTypes (layer IDs)

```
ROOT, NONE, MASK_OCCLUDER, MASK_BREATH,
HELMET_OCCLUDER, HELMET_BREATH, MOTO_OCCLUDER, MOTO_BREATH,
COVER_FLASHBANG, NVG_OCCLUDER, PUMPKIN_OCCLUDER, EYEPATCH_OCCLUDER,
HELMET2_OCCLUDER, BLEEDING_LAYER
```

### Colors

Static color constants. Source: `colors.c`

#### Basic

`RED`, `GREEN`, `BLUE`, `WHITE`, `BLACK`, `YELLOW`, `ORANGE`, `PURPLE`, `CYAN`, `GRAY`, `BROWN`, `WHITEGRAY`

#### Item state

`COLOR_PRISTINE` (green) → `COLOR_WORN` → `COLOR_DAMAGED` → `COLOR_BADLY_DAMAGED` → `COLOR_RUINED` (red)

#### Wetness

`COLOR_DRENCHED` (blue) → `COLOR_SOAKING` → `COLOR_WET` → `COLOR_DAMP`

#### Temperature

`COLOR_HOT` (red gradients) ↔ `COLOR_COLD` (blue gradients)

#### Food

`COLOR_RAW`, `COLOR_BAKED`, `COLOR_BOILED`, `COLOR_DRIED`, `COLOR_BURNED`, `COLOR_ROTTEN`

#### Maps

`LIVONIA`, `FROSTLINE`, `DAYZ` — per-map palettes

### FadeColors

Fade colors: `WHITE`, `LIGHT_GREY`, `BLACK`, `RED`, `DARK_RED`

### Menu constants (MENU_*)

`MENU_MAIN`, `MENU_INGAME`, `MENU_INVENTORY`, `MENU_OPTIONS`, `MENU_SERVER_BROWSER`, `MENU_LOGIN_QUEUE`, `MENU_LOADING`, `MENU_RESPAWN_DIALOGUE`, `MENU_CHAT`, `MENU_MAP`, etc.
