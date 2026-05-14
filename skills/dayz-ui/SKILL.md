---
name: dayz-ui
description: DayZ UI development — `.layout` / `.styles` / `.imageset` files, widget scripting, menus, HUD. Critical rules: Unlink, AddActiveInputExcludes pairing, CALL_CATEGORY_GUI, FindAnyWidget+Cast, scriptclass typos, CfgMods registration. Applies to both writing and reviewing UI code.
when_to_use: Activate when writing or modifying UI code — `.layout`, `.styles`, `.imageset` files, or `.c` files with widget logic (UIScriptedMenu, ScriptedWidgetEventHandler, HUD). Also on requests like "make a UI", "create a menu", "add a HUD", "add a window", "draw a UI", "make a screen", "wire a script to a widget", "handle a button click".
model: opus
paths: ["**/*.layout", "**/*.styles", "**/*.imageset"]
---

# DayZ UI

This skill covers DayZ UI formats (`.layout`, `.styles`, `.imageset`, `.edds`), the widget scripting layer, events, menus, and HUD. Applies both when writing and when reviewing UI code.

## Critical UI rules

Must-fix at review. Rationale and bad/good examples — `reference/ui-pitfalls.md`.

- `AddActiveInputExcludes` / `RemoveActiveInputExcludes` must be paired (OnShow/OnHide or constructor/destructor).
- Call `Widget.Unlink()` before nulling `m_Root` — never just `m_Root = null`.
- UI timers use `CALL_CATEGORY_GUI`. `SYSTEM` is server-aware non-UI; `GAMEPLAY` pauses with menus.
- Cast after `FindAnyWidget()` for type-specific methods. No cast available for `Frame/Content/Panel/SmartPanel/Embeded/ThreeStateCheckbox/Window` — no script class exists.
- `ShowCursor(true)` / `ShowCursor(false)` must be paired.
- `Pause()` / `Continue()` (on `Mission`) must be paired.
- Register `.styles` and `.imageset` in `CfgMods` under `class defs { class widgetStyles / class imageSets }`. Layouts don't need registration.
- `scriptclass` must reference an existing class — typos fail silently at runtime.

## Naming and file locations

Full reference — `reference/layout-fundamentals.md` and `reference/widget-scripting.md`.

**Widget names in layouts** are `PascalCase`. If a layout has a `scriptclass`, widget names can match field names in the script class for automatic binding via reflection (auto-bind). Mechanism details — `reference/widget-scripting.md`.

**File locations:**

| Type | Path |
|------|------|
| Layout | `gui/layouts/` |
| Styles | `gui/looknfeel/` |
| Imageset | `gui/imagesets/` |
| Fonts | `gui/fonts/` |
| Textures (.edds) | `gui/textures/` |

## Scripting layer — key operations

Full reference — `reference/widget-scripting.md`.

- **Create a widget from a layout** — `g_Game.GetWorkspace().CreateWidgets("path/to/file.layout")`.
- **Find a widget** — `root.FindAnyWidget("WidgetName")` plus a mandatory cast (see above).
- **Attach an event handler** — `widget.SetHandler(handlerInstance)`. Alternative — `scriptclass` in the layout.
- **Cleanup** — `m_Root.Unlink()` in the destructor or `OnHide`.
- **Visibility and state** — `Show(bool)`, `Enable(bool)`.

## Events

Full reference — `reference/widget-scripting.md`.

- **Return semantics** — `true` means "event handled, do not propagate". `false` lets the event bubble up to the parent.
- **Returning `true` without actually handling the event** breaks parent containers' logic (drag&drop, focus navigation). Return `true` only when the event is actually handled.
- **In `UIScriptedMenu`**, widget events arrive directly in the menu's methods — `SetHandler` is not needed. The menu does not extend `ScriptedWidgetEventHandler`; instead it declares its own copy of the same event method set, and the engine routes layout events into them.

## Menus and HUD

Full reference — `reference/widget-scripting.md`.

- **`UIScriptedMenu`** — for interaction with pause / cursor / input blocking. Registered in `MissionBase.CreateScriptedMenu`, opened via `g_Game.GetUIManager().EnterScriptedMenu(MENU_ID, null)`.
- **HUD** — persistent elements without input blocking. Created in the mission's `OnMissionStart`, updated in `OnUpdate` or via `g_Game.GetCallQueue(CALL_CATEGORY_GUI).CallLater(...)`.

## Styles and resources

Full reference — `reference/style-system.md`, `reference/imageset-format.md`, `reference/edds-format.md`.

- **`.styles`** define the visual appearance of widgets via Item-slots and states. Applied to a widget through the `style` property.
- **`.imageset`** — texture atlases that define named regions inside a `.edds` file. Used in layouts (`image0 "set:name image:icon"`) and in styles.
- **`.edds`** — the engine's primary texture format. Created from PNG/TGA via Workbench import. Receive a GUID on import: `{D2377E3C2ECB1102}path.edds`.

## Reference files map

| File | Contents |
|------|----------|
| `reference/layout-fundamentals.md` | `.layout` syntax, property-group inheritance, common Widget properties, positioning |
| `reference/widget-catalog.md` | All widgets — type-specific properties, key notes |
| `reference/style-system.md` | `.styles` format, Item-slot and state concepts, registration via CfgMods |
| `reference/imageset-format.md` | `.imageset` format, ImageSetClass/TextureClass/DefClass, `.edds` references via GUID, registration via CfgMods |
| `reference/edds-format.md` | `.edds` format, use in imagesets and directly in widgets |
| `reference/widget-scripting.md` | UI scripting — base API, events, UIScriptedMenu, HUD elements |
| `reference/ui-pitfalls.md` | Catalog of UI mistakes and their consequences |

## When to read which file

- Creating or editing a `.layout` file → `reference/layout-fundamentals.md`.
- Looking up a specific widget and its properties → `reference/widget-catalog.md`.
- Working with `.styles`, or "why does my widget look default" → `reference/style-system.md`.
- Hooking up an imageset, looking up `image0` or `imageTexture` properties → `reference/imageset-format.md` and `reference/edds-format.md`.
- Writing any UI code (creating menus, handling events, HUD) → `reference/widget-scripting.md`.
- Suspected input freeze, dead widgets, unexplained UI behaviour → `reference/ui-pitfalls.md`.