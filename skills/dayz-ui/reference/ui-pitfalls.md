# UI pitfalls

Catalog of known DayZ UI mistakes. Every entry is a reproducible problem, not theoretical. Format: symptom → cause → safe pattern → bad/good examples.

`SKILL.md` carries the invariants; this is the full catalog behind them.

---

## 1. Unpaired AddActiveInputExcludes

**Symptom:** after the menu closes, the player can't control the character — keys don't respond, the mouse doesn't work in the game world. A game restart fixes it.

**Cause:** `AddActiveInputExcludes({"menu"})` was called when opening the menu, but the matching `RemoveActiveInputExcludes` was forgotten when closing. Game input stays blocked for the rest of the session.

**Safe pattern:** Add/Remove pairing at the OnShow/OnHide level or in constructor/destructor. Never call Add without Remove.

```c
// bad — Remove forgotten
class BadMenu: UIScriptedMenu
{
    override void OnShow()
    {
        super.OnShow();
        g_Game.GetMission().AddActiveInputExcludes({"menu"});
    }
    // OnHide is missing — Remove never gets called
}

// good — Add and Remove paired
class GoodMenu: UIScriptedMenu
{
    override void OnShow()
    {
        super.OnShow();
        g_Game.GetMission().AddActiveInputExcludes({"menu"});
    }

    override void OnHide()
    {
        super.OnHide();
        g_Game.GetMission().RemoveActiveInputExcludes({"menu"});
    }
}
```

**Extra safety:** if the menu can be closed by an exception or forcibly via `Cleanup`, duplicate `RemoveActiveInputExcludes` in the destructor. An extra `Remove` without an active `Add` is safe.

---

## 2. Missing Unlink

**Symptom:** widgets remain on screen after the owning object is destroyed. Script-class destructors don't fire. Each open/close cycle drops FPS further.

**Cause:** widgets created via `CreateWidgets` are held by a strong reference in the workspace tree. Nulling the field `m_Root = null` doesn't break that reference — the widget stays in the workspace and keeps rendering.

**Safe pattern:** call `Unlink()` before nulling the reference, or in the destructor.

```c
// bad — Unlink missing
class BadHud
{
    protected Widget m_Root;

    void BadHud()
    {
        m_Root = g_Game.GetWorkspace().CreateWidgets("path.layout");
    }

    void ~BadHud()
    {
        m_Root = null;  // widget stays in the workspace tree
    }
}

// good — Unlink is called
class GoodHud
{
    protected Widget m_Root;

    void GoodHud()
    {
        m_Root = g_Game.GetWorkspace().CreateWidgets("path.layout");
    }

    void ~GoodHud()
    {
        if (m_Root) {
            m_Root.Unlink();
        }
    }
}
```

**The UIScriptedMenu root widget is an exception.** If the root widget is returned from `Init()`, the engine takes ownership and destroys it. Additional widgets created manually inside the menu still need manual `Unlink`.

---

## 3. Wrong CALL_CATEGORY for UI timers

**Symptom:** a UI timer fires at the wrong time — ticking on while a menu is open, or stalling while the UI still needs updating. Sometimes it reaches widgets that were already Unlinked.

**Cause:** `CallQueue` has three categories with different runtime semantics. Only `CALL_CATEGORY_GUI` runs whenever the client UI does. Full table — `widget-scripting.md` section 5.

**Safe pattern:** any callback that touches a widget goes on `CALL_CATEGORY_GUI`.

```c
// bad — SYSTEM is for non-UI work that also runs server-side
g_Game.GetCallQueue(CALL_CATEGORY_SYSTEM).CallLater(UpdateLabel, 100, true);

// bad — GAMEPLAY stalls while a menu is open, so ticks go irregular
g_Game.GetCallQueue(CALL_CATEGORY_GAMEPLAY).CallLater(UpdateLabel, 100, true);

// good
g_Game.GetCallQueue(CALL_CATEGORY_GUI).CallLater(UpdateLabel, 100, true);
```

---

## 4. FindAnyWidget without null check and Cast

**Symptom:** crash on the first access to a widget. The error mentions a null reference or a missing method.

**Cause:** `FindAnyWidget` returns either a base `Widget` or `null` if the widget is not found. Direct access to type-specific methods without a check and without a Cast crashes.

**Safe pattern:** Cast and check the result.

```c
// bad — no Cast, type-specific methods unavailable
Widget label = root.FindAnyWidget("TitleLabel");
label.SetText("Hello");  // SetText doesn't exist on the base Widget — runtime error

// bad — Cast done, but null not checked
TextWidget label = TextWidget.Cast(root.FindAnyWidget("TitleLabel"));
label.SetText("Hello");  // crashes if widget is missing or wrong type

// good — Cast and check
TextWidget label = TextWidget.Cast(root.FindAnyWidget("TitleLabel"));
if (label) {
    label.SetText("Hello");
}

// good — Class.CastTo with result check
TextWidget label;
if (Class.CastTo(label, root.FindAnyWidget("TitleLabel"))) {
    label.SetText("Hello");
}
```

A typo in the widget name is a typical cause of null. Names in the layout and in `FindAnyWidget` must match **exactly**, including case.

---

## 5. Returning true without handling

**Symptom:** nested UI logic stops working — drag&drop fails, focus doesn't transfer, click events don't reach the parent menu.

**Cause:** the event handler returns `true` for **all** cases, not only the ones it handled. The event never reaches parent widgets that may implement higher-level logic.

**Safe pattern:** return `true` only when the event is genuinely handled. Otherwise — `false`, so the parent can take it.

```c
// bad — true returned always
override bool OnClick(Widget w, int x, int y, int button)
{
    if (w == m_CloseBtn) {
        Close();
    }

    return true;  // even non-CloseBtn clicks won't reach the parent
}

// good — true only on real handling
override bool OnClick(Widget w, int x, int y, int button)
{
    if (w == m_CloseBtn) {
        Close();
        return true;
    }

    return false;
}
```

Especially dangerous in hierarchies — if an intermediate widget "eats" the event, parent containers don't get it, and menu behaviour becomes unpredictable.

---

## 6. m_Root = null without Unlink

**Symptom:** combination of the two previous problems — widgets stay in the workspace, but the script class is already destroyed. Inner widgets' destructors don't fire. Memory leaks compound on every open/close.

**Cause:** nulling the reference to the root widget (`m_Root = null`) only breaks one link — between the script class and the widget. The widget itself stays in the workspace tree and keeps existing.

**Safe pattern:** always `Unlink()` **before** nulling, not instead of.

```c
// bad — null without Unlink
void Cleanup()
{
    m_Root = null;
}

// good — Unlink first, then null
void Cleanup()
{
    if (m_Root) {
        m_Root.Unlink();
        m_Root = null;
    }
}

// good — Unlink in the destructor, no need for null
void ~MyClass()
{
    if (m_Root) {
        m_Root.Unlink();
    }
    // m_Root nulls automatically when the object is destroyed
}
```

---

## 7. scriptclass with a non-existent name

**Symptom:** the widget is created in the layout, displays on screen, but doesn't react to events. Nothing in the log.

**Cause:** the layout names a class that doesn't exist — typo, or the class was renamed/deleted. The engine can't find the class and doesn't create a handler. The widget exists but is "empty" — without logic.

**Safe pattern:** ensure the class name in the layout matches the class name in the script exactly. Check on rename.

```
// bad — typo in the class name
FrameWidgetClass MyPanel {
 scriptclass "MyPnaelScript"   // typo: MyPnael instead of MyPanel
}
```

```c
// the script class is named correctly, but the layout never finds it
class MyPanelScript: ScriptedWidgetEventHandler
{
    void OnWidgetScriptInit(Widget w)
    {
        // never runs
    }
}
```

This error is caught by neither the compiler nor runtime — discovered only when the widget "doesn't work", and the cause is often searched for in code that simply never runs.

---

## 8. Unregistered styles or imagesets

**Symptom:** widgets render as Default — gray rectangles with no styling. Images don't appear — empty regions or placeholders in their place.

**Cause:** `.styles` and `.imageset` files are not loaded automatically by their existence. They must be explicitly registered in the mod's `config.cpp` via `class defs { class widgetStyles { ... }; class imageSets { ... } }`.

**Safe pattern:** when adding a new `.styles` or `.imageset` file, register it in `config.cpp` immediately.

```cpp
// bad — files exist but are not registered
class CfgMods
{
    class MyMod
    {
        dir = "MyMod";
        type = "mod";
        // class defs missing — styles and imagesets are not loaded
    };
};

// good — both resource types registered
class CfgMods
{
    class MyMod
    {
        dir = "MyMod";
        type = "mod";

        class defs
        {
            class imageSets
            {
                files[] = { "MyMod/GUI/Imagesets/MyImageSet.imageset" };
            };
            class widgetStyles
            {
                files[] = { "MyMod/GUI/Looknfeel/MyMod.styles" };
            };
        };
    };
};
```

Details — `style-system.md` and `imageset-format.md`. Layout files **don't need registration** — they are loaded by path from code via `CreateWidgets`.

---

## 9. ShowCursor without a paired hide

**Symptom:** the mouse cursor stays on screen after the menu closes. The game crosshair is hidden or conflicts with the cursor.

**Cause:** `ShowCursor(true)` was called when opening the menu, but the matching `ShowCursor(false)` was not called when closing.

**Safe pattern:** Show/Hide cursor pairing at the OnShow/OnHide level.

```c
// bad
override void OnShow()
{
    super.OnShow();
    g_Game.GetUIManager().ShowCursor(true);
}
// OnHide without ShowCursor(false)

// good
override void OnShow()
{
    super.OnShow();
    g_Game.GetUIManager().ShowCursor(true);
}

override void OnHide()
{
    super.OnHide();
    g_Game.GetUIManager().ShowCursor(false);
}
```

---

## 10. Pause without a paired Continue

**Symptom:** the game stays paused after the menu closes. Time doesn't advance, NPCs don't move, events don't fire.

**Cause:** `mission.Pause()` was called when opening the menu, but the matching `mission.Continue()` was not called.

**Safe pattern:** Pause/Continue pairing. The pair must be at the same level — both in OnShow/OnHide, or both in constructor/destructor.

```c
// bad
void MyMenu()
{
    g_Game.GetMission().Pause();
}
void ~MyMenu()
{
    // Continue forgotten — game stays paused
}

// good
void MyMenu()
{
    g_Game.GetMission().Pause();
}
void ~MyMenu()
{
    Mission mission = g_Game.GetMission();
    if (mission) {
        mission.Continue();
    }
}
```

The `if (mission)` check in the destructor matters — `MissionGameplay` may already be destroyed if the menu outlives the mission's end.

---

## 11. _ref vs bare halign/valign

**Symptom:** the widget positions somewhere other than the layout specifies. Often — collapses to the parent's top-left corner.

**Cause:** the layout uses bare forms `halign center` or `valign bottom` without the `_ref` suffix. The bare form is legacy and behaves unpredictably. Known case: `center` without `_ref` collapses the widget to (0,0). `right`, `bottom` without `_ref` — undefined behaviour.

**Safe pattern:** always use the `_ref` form (`center_ref`, `right_ref`, `bottom_ref`). For the left and top edges, just omit the attribute — `left_ref` and `top_ref` don't exist.

```
-- bad
PanelWidgetClass MyPanel {
 halign center
 valign bottom
}

-- good
PanelWidgetClass MyPanel {
 halign center_ref
 valign bottom_ref
}
```

Details — `layout-fundamentals.md` section 4.

---

## 12. Auto-bind doesn't work with m_ prefix

**Symptom:** in a script class with a `scriptclass` binding, fields for widgets stay null after `OnWidgetScriptInit`. Direct access to them crashes.

**Cause:** auto-bind matches widget names in the layout to field names in the script **exactly**, with no prefix handling. Field `m_TitleLabel` doesn't match widget `TitleLabel`.

**Safe pattern:** for auto-bind fields, don't use the `m_` prefix. This is one of the exceptions to the general naming style. If a prefix is required (for consistency with the rest of the code) — use `FindAnyWidget` + `Cast` explicitly.

```c
// bad — m_ prefix breaks auto-bind
class MyPanel: ScriptedWidgetEventHandler
{
    protected TextWidget m_TitleLabel;  // never gets found

    void OnWidgetScriptInit(Widget w)
    {
        m_TitleLabel.SetText("Hello");  // crash: m_TitleLabel == null
    }
}

// good — field name matches widget name
class MyPanel: ScriptedWidgetEventHandler
{
    protected TextWidget TitleLabel;

    void OnWidgetScriptInit(Widget w)
    {
        TitleLabel.SetText("Hello");
    }
}

// alternative — m_ prefix with explicit FindAnyWidget+Cast
class MyPanel: ScriptedWidgetEventHandler
{
    protected TextWidget m_TitleLabel;

    void OnWidgetScriptInit(Widget w)
    {
        m_TitleLabel = TextWidget.Cast(w.FindAnyWidget("TitleLabel"));
    }
}
```

Details on auto-bind — `widget-scripting.md` section 2.

---

## 13. Repeating CallLater without a matching Remove

**Symptom:** after a menu or HUD element is closed, the log fills with null-access errors, or a counter keeps advancing for something no longer on screen. Opening and closing repeatedly multiplies the effect — two opens, two callbacks running.

**Cause:** `CallLater(fn, ms, true)` registers a **repeating** callback on the call queue. The queue holds it independently of the widget that started it, so destroying the owner does not stop it. On the next tick it runs against a destroyed object.

**Safe pattern:** every repeating `CallLater` has a `Remove` on the teardown path, at the same level as the call that started it.

```c
// bad — registered, never removed
class BadHud
{
    void BadHud()
    {
        g_Game.GetCallQueue(CALL_CATEGORY_GUI).CallLater(Tick, 100, true);
    }

    void ~BadHud()
    {
        // the queue still holds Tick
    }
}

// good — paired
class GoodHud
{
    void GoodHud()
    {
        g_Game.GetCallQueue(CALL_CATEGORY_GUI).CallLater(Tick, 100, true);
    }

    void ~GoodHud()
    {
        g_Game.GetCallQueue(CALL_CATEGORY_GUI).Remove(Tick);
    }
}
```

`Remove` takes the same function reference and the same category the call was registered under. A one-shot `CallLater(fn, ms, false)` needs no removal once it has fired, but still needs one where the owner can die before the delay elapses.
