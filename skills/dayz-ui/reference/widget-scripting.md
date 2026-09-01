# Widget scripting

The script layer for DayZ UI work. Covers four topics: base widget API, layout-to-script binding, event handling, and two UI patterns — `UIScriptedMenu` for menus and HUD-level widgets.

This file is about the **applied layer**: how to write UI code. Full engine class signatures with all methods are in `widget-catalog.md`. Layout file mechanics — in `layout-fundamentals.md`.

---

## 1. Base widget API

### Creating widgets from a layout

```c
Widget root = g_Game.GetWorkspace().CreateWidgets("MyMod/gui/layouts/my_panel.layout");
```

`CreateWidgets` loads the `.layout` file, instantiates all widgets inside it, and returns the root `Widget`. If a `scriptclass` is specified for any widget in the layout, the engine creates the corresponding instance and calls `OnWidgetScriptInit`.

The optional second parameter is a parent widget to attach the new tree to:

```c
Widget root = g_Game.GetWorkspace().CreateWidgets("path.layout", parentWidget);
```

Without a parent, the tree is attached to the root workspace.

### Finding widgets

Three ways to find a widget within the tree:

```c
// By name (recursive search across the whole tree) — primary method
Widget w = root.FindAnyWidget("WidgetName");

// By dotted path
Widget w = root.FindWidget("Panel.SubPanel.Button");

// By userID (for widgets without unique names)
Widget w = root.FindAnyWidgetById(42);
```

`FindAnyWidget` returns the first widget with the given name. `FindWidget` follows an exact path. `FindAnyWidgetById` searches by the numeric `userID` set in the layout.

### Cast

`FindAnyWidget` and `FindWidget` return a base `Widget`. For type-specific methods, an explicit cast is required.

```c
TextWidget label = TextWidget.Cast(root.FindAnyWidget("Label"));
ButtonWidget btn = ButtonWidget.Cast(root.FindAnyWidget("MyButton"));
SliderWidget slider = SliderWidget.Cast(root.FindAnyWidget("VolumeSlider"));
```

The alternative is `Class.CastTo(var, val)` with result checking:

```c
TextWidget label;
if (Class.CastTo(label, root.FindAnyWidget("Label"))) {
    label.SetText("Hello");
}
```

Cast is not needed for widgets without their own script class (`FrameWidget`, `ContentWidget`, `PanelWidget`, `SmartPanelWidget`, `EmbededWidget`) — they have no API beyond the base `Widget`. See `widget-catalog.md`.

### Visibility and state

```c
widget.Show(true);           // show (recursive for children)
widget.Show(false);          // hide
widget.IsVisible();          // visibility check
widget.Enable(false);        // disable interaction
widget.Unlink();             // destroy the widget and all descendants
```

`Unlink()` is the primary way to destroy a widget created via `CreateWidgets`. Without `Unlink`, the widget remains in the workspace tree even after its reference is nulled.

### Colors

A widget's color is set as an ARGB int. The `ARGB(a, r, g, b)` helper assembles the value from four 0–255 components:

```c
widget.SetColor(ARGB(255, 255, 255, 0));  // opaque yellow
widget.SetAlpha(0.5);                      // alpha 0.0–1.0
int currentColor = widget.GetColor();
float currentAlpha = widget.GetAlpha();
```

For text, `UIWidget` has separate methods:

```c
uiWidget.SetTextColor(ARGB(255, 200, 200, 200));
```

### Positioning from code

```c
// Fractions of parent (0.0–1.0) — default behaviour
widget.SetPos(0.5, 0.5);     // parent's center
widget.SetSize(0.3, 0.1);    // 30% width, 10% height

// Fixed pixels — flags must be set
widget.SetFlags(WidgetFlags.EXACTPOS);
widget.SetFlags(WidgetFlags.EXACTSIZE);
widget.SetPos(100, 200);     // 100px, 200px
widget.SetSize(400, 60);     // 400×60 pixels
```

`SetFlags` adds flags to the existing set, `ClearFlags` removes. Axes can be configured independently: `WidgetFlags.HEXACTPOS`, `WidgetFlags.VEXACTPOS`, `WidgetFlags.HEXACTSIZE`, `WidgetFlags.VEXACTSIZE`. See `layout-fundamentals.md` for exact-flags.

---

## 2. Layout and Script

There are three mechanisms for attaching a script to widgets in a layout:

1. **`scriptclass` in layout** — declarative, the engine creates the handler when loading the layout.
2. **`SetHandler` from code** — programmatic, the modder creates the handler and binds it.
3. **Auto-bind of class fields** through reflection — automatic assignment of widgets to fields by name match.

### scriptclass in layout

In a `.layout` file, the `scriptclass` property names a class the engine instantiates when loading the layout. After creating the instance, the engine calls `OnWidgetScriptInit(Widget w)`, passing a reference to the widget.

Layout:

```
FrameWidgetClass MyPanel {
 scriptclass "MyPanelScript"
 size 1 1
 {
  TextWidgetClass Title {
   text "Hello"
  }
 }
}
```

Script:

```c
class MyPanelScript: ScriptedWidgetEventHandler
{
    protected Widget m_Root;
    protected TextWidget m_Title;

    void OnWidgetScriptInit(Widget w)
    {
        m_Root = w;
        m_Root.SetHandler(this);
        m_Title = TextWidget.Cast(m_Root.FindAnyWidget("Title"));
    }

    override bool OnClick(Widget w, int x, int y, int button)
    {
        if (w == m_Title) {
            return true;
        }

        return false;
    }
}
```

`scriptclass` suits **reusable components** — the widget acts as a black box, with all logic encapsulated in the script class.

### SetHandler from code

The alternative is to attach an event handler to a widget programmatically, without a `scriptclass` in the layout:

```c
class MyHandler: ScriptedWidgetEventHandler
{
    override bool OnMouseEnter(Widget w, int x, int y)
    {
        w.SetColor(ARGB(255, 255, 255, 0));
        return true;
    }

    override bool OnMouseLeave(Widget w, Widget enterW, int x, int y)
    {
        w.SetColor(ARGB(255, 255, 255, 255));
        return true;
    }
}

// in initialization:
Widget panel = root.FindAnyWidget("MyPanel");
panel.SetHandler(new MyHandler());
```

`SetHandler` suits cases where the handler logic is set in code rather than in a layout — for example, a shared handler for a group of widgets, or one that needs constructor parameters.

`SetHandler` installs the handler on a single widget. Events from the widget's children bubble up the hierarchy until they meet a handler that returns `true`. See the events section below.

### Auto-bind of fields through reflection

If a `.layout` specifies a `scriptclass`, the engine, when initializing the script class, walks through child widgets and **automatically assigns them to same-named fields** in the class. Matching is by widget name (`WidgetName` in the layout) and field name in the script.

Layout:

```
FrameWidgetClass MyPanel {
 scriptclass "AutoBindExample"
 {
  TextWidgetClass TitleLabel {
   text "Welcome"
  }
  ButtonWidgetClass SubmitButton {
   style "Default"
  }
 }
}
```

Script:

```c
class AutoBindExample: ScriptedWidgetEventHandler
{
    protected TextWidget TitleLabel;     // name matches the widget
    protected ButtonWidget SubmitButton; // name matches the widget

    void OnWidgetScriptInit(Widget w)
    {
        // TitleLabel and SubmitButton are already populated by the engine
        TitleLabel.SetText("Hello, world");
    }
}
```

Field and widget names must **match exactly** — no `m_` prefix, no case differences. If a field is declared with a prefix (e.g., `m_TitleLabel`), the engine won't find it and won't populate it.

Auto-bind removes the need to write `FindAnyWidget` + `Cast` for every widget. The downside: fields don't carry the `m_` prefix, which conflicts with the general naming style for private/protected members. It's a tradeoff between convenience and consistency.

### reference parameters from ScriptParamsClass

A layout can pass named parameters to the script class via a `ScriptParamsClass` block. In the script, a parameter is declared with the `reference` modifier, and the engine fills it with the value from the layout.

Layout:

```
EmbededWidgetClass MyButton {
 scriptclass "ConfigurableButtonScript"
 {
  ScriptParamsClass {
   Caption "Submit"
   MaxWidth 200
   IconName "icon_check"
  }
 }
}
```

Script:

```c
class ConfigurableButtonScript: ScriptedWidgetEventHandler
{
    reference string Caption;
    reference int MaxWidth;
    reference string IconName;

    void OnWidgetScriptInit(Widget w)
    {
        // Caption == "Submit", MaxWidth == 200, IconName == "icon_check"
    }
}
```

Use case — customizing reusable components from the layout. The same script class can work with different parameters without code changes.

---

## 3. Events

`ScriptedWidgetEventHandler` is the base class for widget event handlers. Bound via `Widget.SetHandler()` or `scriptclass` in a layout.

In subclasses, only the needed events are overridden — the rest are simply not implemented.

### Return semantics

All event methods return `bool`:

- `true` — event was **handled**, do not propagate further up the hierarchy.
- `false` — pass through, the event bubbles up to the parent widget.

```c
override bool OnClick(Widget w, int x, int y, int button)
{
    if (w == m_CloseBtn) {
        Close();
        return true;     // close click handled
    }

    return false;        // pass other clicks through
}
```

Returning `true` without actually handling the event breaks parent logic — for instance, drag&drop won't work if an intermediate handler "ate" the event. Return `true` only when the event is genuinely handled.

### Full event list

#### Mouse

| Method | When fired |
|--------|-----------|
| `OnClick(Widget w, int x, int y, int button)` | Click (press+release). `button`: 0=LMB, 1=RMB, 2=MMB |
| `OnDoubleClick(Widget w, int x, int y, int button)` | Double click |
| `OnMouseButtonDown(Widget w, int x, int y, int button)` | Mouse button pressed |
| `OnMouseButtonUp(Widget w, int x, int y, int button)` | Mouse button released |
| `OnMouseWheel(Widget w, int x, int y, int wheel)` | Wheel. `wheel` > 0 — up, < 0 — down |
| `OnMouseEnter(Widget w, int x, int y)` | Cursor entered the widget area |
| `OnMouseLeave(Widget w, Widget enterW, int x, int y)` | Cursor left the area. `enterW` — the widget the cursor moved to |

#### Focus and selection

| Method | When fired |
|--------|-----------|
| `OnFocus(Widget w, int x, int y)` | Widget got focus |
| `OnFocusLost(Widget w, int x, int y)` | Widget lost focus |
| `OnSelect(Widget w, int x, int y)` | Item selection (specific to lists) |
| `OnItemSelected(Widget w, int x, int y, int row, int column, int oldRow, int oldColumn)` | List/table item selection with position |

#### Keyboard and gamepad

| Method | When fired |
|--------|-----------|
| `OnKeyDown(Widget w, int x, int y, int key)` | Key pressed. `key` — KeyCode |
| `OnKeyUp(Widget w, int x, int y, int key)` | Key released |
| `OnKeyPress(Widget w, int x, int y, int key)` | Key pressed (with repeat) |
| `OnController(Widget w, int control, int value)` | Gamepad event. `control` — one of `ControlID` |

#### Drag & Drop

The widget must have `draggable 1` in the layout.

| Method | When fired |
|--------|-----------|
| `OnDrag(Widget w, int x, int y)` | Drag started |
| `OnDragging(Widget w, int x, int y, Widget reciever)` | Dragging in progress. `reciever` — widget under cursor |
| `OnDraggingOver(Widget w, int x, int y, Widget reciever)` | Dragged widget is over `reciever` |
| `OnDrop(Widget w, int x, int y, Widget reciever)` | Released. `w` — what was dropped, `reciever` — where |
| `OnDropReceived(Widget w, int x, int y, Widget reciever)` | Widget `w` accepted the drop from `reciever` |

#### Change and structure

| Method | When fired |
|--------|-----------|
| `OnChange(Widget w, int x, int y, bool finished)` | Widget value changed (EditBox, Slider, CheckBox). `finished` — input completed |
| `OnResize(Widget w, int x, int y)` | Widget resized |
| `OnChildAdd(Widget w, Widget child)` | Child added |
| `OnChildRemove(Widget w, Widget child)` | Child removed |
| `OnUpdate(Widget w)` | Called on `Widget.Update()` |

#### System

| Method | When fired |
|--------|-----------|
| `OnModalResult(Widget w, int x, int y, int code, int result)` | Modal dialog result |
| `OnEvent(EventType eventType, Widget target, int parameter0, int parameter1)` | General system event (screen resize, etc.) |

### Events in UIScriptedMenu

`UIScriptedMenu` does **not** extend `ScriptedWidgetEventHandler`. Its actual chain is `Managed → UIMenuPanel → UIScriptedMenu`. Instead, it **declares its own copy** of the same event method set (`OnClick`, `OnMouseEnter`, etc., with identical signatures). The engine routes layout-widget events directly into these methods, so no `SetHandler` is needed. The first parameter `w` is the source widget:

```c
class MyMenu: UIScriptedMenu
{
    override bool OnClick(Widget w, int x, int y, int button)
    {
        if (w == m_CloseBtn) {
            Close();
            return true;
        }

        return false;
    }
}
```

---

## 4. UIScriptedMenu

The primary way to create fullscreen UI is to inherit from `UIScriptedMenu`. A menu pauses the game, blocks game input, and shows the cursor.

### Lifecycle

```
EnterScriptedMenu(MENU_ID)
    → constructor
    → Init()              ← create widgets, return the root Widget
    → LockControls()      ← capture input
    → OnShow()            ← menu shown
    → Update(timeslice)   ← every frame (while menu is active)
    → OnHide()            ← menu hidden
    → UnlockControls()    ← release input
    → Cleanup()           ← cleanup
    → destructor
```

### Steps to create a menu

#### 1. Define an ID

In `3_Game/constants.c` or via modded:

```c
const int MENU_MY_CUSTOM = 1337;
```

#### 2. Create the menu class

```c
class MyCustomMenu: UIScriptedMenu
{
    protected Widget m_Root;
    protected ButtonWidget m_CloseBtn;
    protected TextWidget m_Label;

    override Widget Init()
    {
        m_Root = g_Game.GetWorkspace().CreateWidgets("MyMod/gui/layouts/my_menu.layout");
        m_CloseBtn = ButtonWidget.Cast(m_Root.FindAnyWidget("CloseButton"));
        m_Label = TextWidget.Cast(m_Root.FindAnyWidget("InfoLabel"));

        return m_Root;
    }

    override void OnShow()
    {
        super.OnShow();
        g_Game.GetMission().AddActiveInputExcludes({"menu"});
        g_Game.GetUIManager().ShowCursor(true);
    }

    override void OnHide()
    {
        super.OnHide();
        g_Game.GetMission().RemoveActiveInputExcludes({"menu"});
        g_Game.GetUIManager().ShowCursor(false);
    }

    override bool OnClick(Widget w, int x, int y, int button)
    {
        if (w == m_CloseBtn) {
            Close();
            return true;
        }

        return false;
    }

    override void Update(float timeslice)
    {
        super.Update(timeslice);
    }
}
```

#### 3. Register in the factory

Override `MissionBase.CreateScriptedMenu`:

```c
modded class MissionBase
{
    override UIScriptedMenu CreateScriptedMenu(int id)
    {
        UIScriptedMenu menu = super.CreateScriptedMenu(id);
        if (!menu) {
            switch (id) {
                case MENU_MY_CUSTOM:
                    menu = new MyCustomMenu;
                    break;
            }
        }
        if (menu) {
            menu.SetID(id);
        }

        return menu;
    }
}
```

#### 4. Open and close

```c
// open
g_Game.GetUIManager().EnterScriptedMenu(MENU_MY_CUSTOM, null);

// close from inside the menu
Close();

// or via UIManager
g_Game.GetUIManager().Back();
```

### Input Excludes — blocking game input

When a menu is active, it must block game input so keys don't trigger in-game actions. The primary mechanism is `AddActiveInputExcludes` / `RemoveActiveInputExcludes` on the `Mission` object.

Groups are defined in `specific.xml`:

| Group | What it blocks |
|-------|----------------|
| `"menu"` | Full game input lockdown |
| `"inventory"` | Layers needed for inventory |
| `"radialmenu"` | Radial menus |
| `"map"` | Map |
| `"inspect"` | Item inspection |

Usage:

```c
// on opening (OnShow or constructor):
g_Game.GetMission().AddActiveInputExcludes({"menu"});

// on closing (OnHide or destructor) — must be paired:
g_Game.GetMission().RemoveActiveInputExcludes({"menu"});
```

**Signatures** (declared on the base `Mission` class):

- `void AddActiveInputExcludes(array<string> excludes)`
- `void RemoveActiveInputExcludes(array<string> excludes, bool bForceSupress = false)`

The optional `bForceSupress` on `Remove` forces input release through the suppression path. Vanilla `MissionGameplay` uses it when batch-clearing excludes during menu transitions (e.g. `RemoveActiveInputExcludes({"menu"}, bForceSupress)`).

Consequences of leaving these unpaired — `ui-pitfalls.md` sections 1, 9, and 10.

### Cursor

```c
g_Game.GetUIManager().ShowCursor(true);   // show (on opening)
g_Game.GetUIManager().ShowCursor(false);  // hide (on closing)
```

### Game pause

Fullscreen menus typically pause the game:

```c
// in the constructor or OnShow:
Mission mission = g_Game.GetMission();
if (mission) {
    mission.Pause();
}

// in the destructor or OnHide:
if (mission) {
    mission.Continue();
}
```

### Reacting to ESC / Back

To handle ESC/Back in a menu — check for `IDC_CANCEL` or react to the `UAUIBack` input action:

```c
override bool OnClick(Widget w, int x, int y, int button)
{
    if (w.GetUserID() == IDC_CANCEL) {
        Close();
        return true;
    }

    return false;
}
```

### Cleanup

When destroying a menu, always:

- Release input lockdown: `RemoveActiveInputExcludes()`.
- Restore the cursor: `ShowCursor(false)`.
- Resume the game: `mission.Continue()`.
- Call `Widget.Unlink()` for manually-created widgets (the menu's root widget is destroyed automatically).

Skipping any step results in input freeze, dead widgets, or stuck pause.

### UIMenuPanel base API

`UIScriptedMenu` extends `UIMenuPanel` (`Managed → UIMenuPanel → UIScriptedMenu`). Methods available from the base:

| Method | Purpose |
|--------|---------|
| `EnterScriptedMenu(int id)` | Open a child menu and chain it under this one. Returns the created `UIScriptedMenu`. |
| `Close()` | Safely close this menu. Can be called from inside the menu. |
| `Refresh()` | Generic refresh hook — no-op by default; override to repopulate widgets after data changes. |
| `GetID()` | Returns the menu's `MENU_*` ID. |
| `GetSubMenu()` / `GetParentMenu()` / `GetVisibleMenu()` | Navigate the menu chain. |
| `SetSubMenu(UIMenuPanel)` / `SetParentMenu(UIMenuPanel)` | Manually wire menu chain. |
| `DestroySubmenu()` | Close and destroy the chained child. |
| `IsAnyMenuVisible()` / `IsVisible()` / `IsClosing()` | State checks. |
| `CanClose()` / `CanCloseOnEscape()` | Pre-close gate — override to block closing under conditions. |
| `UseMouse()` / `UseKeyboard()` / `UseGamepad()` | Override to declare which input devices the menu accepts. |

### Global UI functions

Engine-level globals from `enwidgets.c` for cursor, focus and modal control:

| Function | Purpose |
|----------|---------|
| `SetActiveWindow(Widget w, bool resetFocus)` | Set the active window — required for keyboard/gamepad input routing. With `resetFocus = true`, focuses the first focusable child. |
| `SetFocus(Widget w)` | Move keyboard focus to a specific widget. |
| `GetFocus()` | Returns the currently-focused widget. |
| `SetModal(Widget w)` | Mark a widget as modal — blocks input to others. |
| `SetCursorWidget(Widget cursor)` | Set a custom cursor widget. |
| `ShowCursorWidget(bool show)` | Direct mouse cursor visibility (low-level — distinct from `UIManager.ShowCursor`). |
| `LoadWidgetImageSet(string filename)` | Runtime load of an `.imageset`. Normally loaded via CfgMods. |
| `LoadWidgetStyles(string filename)` | Runtime load of a `.styles` file. Normally loaded via CfgMods. |
| `SetWidgetWorld(RenderTargetWidget w, IEntity wrldEntity, int camera)` | Attach a world camera to a `RenderTargetWidget`. |
| `GetWidgetUnderCursor()` | Return the widget currently under the mouse cursor. |
| `GetDragWidget()` | Return the widget currently being dragged. |
| `CancelWidgetDragging()` | Force-cancel an in-progress drag. |

---

## 5. HUD elements

For UI that should be on screen permanently (not in a menu), use direct widget creation tied to the mission lifecycle. HUD elements don't block input or pause the game.

### Creating a HUD widget

```c
class MyHudElement: ScriptedWidgetEventHandler
{
    protected Widget m_Root;
    protected TextWidget m_Text;

    void MyHudElement()
    {
        m_Root = g_Game.GetWorkspace().CreateWidgets("MyMod/gui/layouts/my_hud.layout");
        m_Text = TextWidget.Cast(m_Root.FindAnyWidget("StatusText"));
        m_Root.SetHandler(this);
    }

    void ~MyHudElement()
    {
        if (m_Root) {
            m_Root.Unlink();
        }
    }

    void Show(bool visible)
    {
        m_Root.Show(visible);
    }

    void UpdateStatus(string text)
    {
        m_Text.SetText(text);
    }
}
```

### Integration with MissionGameplay

HUD elements live as long as the mission does. Created in `OnMissionStart` / `OnInit`, updated in `OnUpdate`:

```c
modded class MissionGameplay
{
    protected ref MyHudElement m_MyHud;

    override void OnMissionStart()
    {
        super.OnMissionStart();
        m_MyHud = new MyHudElement();
    }

    override void OnUpdate(float timeslice)
    {
        super.OnUpdate(timeslice);
        if (m_MyHud) {
            PlayerBase player = PlayerBase.Cast(g_Game.GetPlayer());
            if (player) {
                m_MyHud.UpdateStatus("HP: " + player.GetHealth("", ""));
            }
        }
    }

    override void OnMissionFinish()
    {
        m_MyHud = null;
        super.OnMissionFinish();
    }
}
```

When `m_MyHud = null` is assigned, ARC destroys the object and calls the destructor, which performs `Unlink()`.

### Per-frame updates via CallQueue

An alternative to `OnUpdate` is registering with the deferred call queue:

```c
// one-shot deferred call after 1 second
g_Game.GetCallQueue(CALL_CATEGORY_GUI).CallLater(MyFunction, 1000, false);

// recurring call every 500ms
g_Game.GetCallQueue(CALL_CATEGORY_GUI).CallLater(MyTickFunction, 500, true);

// stop
g_Game.GetCallQueue(CALL_CATEGORY_GUI).Remove(MyTickFunction);
```

### CALL_CATEGORY constants

Three categories exist (`P:/scripts/3_game/tools/tools.c`):

| Constant | Value | Engine comment | Use case |
|----------|-------|----------------|----------|
| `CALL_CATEGORY_SYSTEM` | `0` | Runs always | System-level work that must run on both client and server, regardless of game state. |
| `CALL_CATEGORY_GUI` | `1` | Runs always (on client) | UI logic — runs continuously on the client even if a menu is open. The standard choice for HUD/menu callbacks. |
| `CALL_CATEGORY_GAMEPLAY` | `2` | Runs unless ingame menu is opened | Gameplay-time logic that should pause when a menu is open. |

### Coexistence with vanilla HUD

HUD elements over the game world coexist with the vanilla `IngameHud` (stats, quickbar, crosshair). Hiding the vanilla HUD when opening custom UI:

```c
IngameHud hud = IngameHud.Cast(g_Game.GetMission().GetHud());
if (hud) {
    hud.ShowHudUI(false);       // everything except quickbar
    hud.ShowQuickbarUI(false);  // quickbar
}
```
