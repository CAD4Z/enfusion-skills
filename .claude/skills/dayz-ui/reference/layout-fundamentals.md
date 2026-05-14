# Layout fundamentals

Core mechanics of DayZ `.layout` files — syntax, property-group inheritance, common widget properties, and the positioning system. Specific widgets and their type-specific properties are in `widget-catalog.md`.

`.layout` files are textual descriptions of widget hierarchies. They are edited in Workbench (GUI Editor) or by hand, and loaded from script via `CreateWidgets()`.

Location: `gui/layouts/`.

---

## 1. Syntax

```
WidgetClass WidgetName {
 property value
 property value1 value2
 "multi word property" value
 {
  ChildWidgetClass ChildName {
   property value
  }
 }
}
```

**Rules:**

- The root element is a single top-level widget.
- The widget type is written as `WidgetClass` (e.g. `FrameWidgetClass`, `TextWidgetClass`).
- The widget name is a unique identifier used for lookup via `FindAnyWidget("name")`.
- Properties are one per line: `key value`.
- Multi-word keys are quoted: `"text halign" center`.
- Child widgets go inside nested `{ }` after the parent's properties.
- Indentation is spaces (1 space per level in the game's files).

---

## 2. Inheritance hierarchy

Two parallel concepts apply here:

1. **Script-class inheritance** — the C++/Enforce class chain (declared in engine `enwidgets.c`). Determines what methods a widget exposes to script.
2. **Layout property groups** — additive sets of layout-file properties (Widget, UIWidget, Text, SpacerWidget, SimpleProgressBarWidget). The engine applies the appropriate groups based on widget type, **independently** of the script-class chain.

The two are not 1:1 — a widget can pick up the Text property group in layouts even though its script class isn't a TextWidget descendant.

### Script-class hierarchy (from engine source)

```
Widget ─── base for all widgets
├── TextWidget
│   ├── MultilineTextWidget
│   ├── RichTextWidget
│   │   └── HtmlWidget
│   └── MultilineEditBoxWidget
│
├── ImageWidget, VideoWidget
├── CanvasWidget, MapWidget
├── ItemPreviewWidget, PlayerPreviewWidget
├── RenderTargetWidget, RTTextureWidget
├── WorkspaceWidget
│
└── UIWidget
    ├── EditBoxWidget
    │   └── PasswordEditBoxWidget
    ├── ButtonWidget
    ├── CheckBoxWidget
    ├── XComboBoxWidget
    ├── SliderWidget
    ├── SimpleProgressBarWidget
    │   └── ProgressBarWidget
    ├── BaseListboxWidget
    │   └── SimpleListboxWidget
    │       └── TextListboxWidget
    └── SpacerBaseWidget
        ├── ScrollWidget
        └── SpacerWidget
            ├── GridSpacerWidget
            └── WrapSpacerWidget
```

**Key non-obvious points:**

- `TextWidget` extends `Widget` directly — it is **not** a UIWidget descendant. TextWidget has its own text-content/format API (`SetText`, `SetItalic`, `SetBold`, `SetOutline`, `SetShadow`).
- `UIWidget` exposes a separate text-styling API (`SetTextColor`, `SetTextOutline`, `SetTextShadow`, `SetTextItalic`, `SetTextBold`) that applies to UI widgets that contain text on top of a background — Button, EditBox, CheckBox, etc. These methods do **not** exist on TextWidget; for a TextWidget, the widget color (`Widget.SetColor`) is the text color.
- `EditBoxWidget` extends `UIWidget` directly — not `TextWidget`. Its text API is just `GetText()` (returns string) / `SetText(string)`.
- `MultilineEditBoxWidget` extends `TextWidget` (different lineage from `EditBoxWidget`). Its `GetText(out string)` uses an out parameter — not return — and is incompatible with `EditBoxWidget.GetText()`.
- `SliderWidget` extends `UIWidget` directly — **not** `SimpleProgressBarWidget`. Their progress-bar APIs are similar by coincidence, not inheritance.
- `ScrollWidget` extends `SpacerBaseWidget`, **not** `SpacerWidget`. ScrollWidget therefore does **not** have `SetContentAlignmentH`/`SetContentAlignmentV`.
- `PanelWidget`, `SmartPanelWidget`, `FrameWidget`, `ContentWidget`, `EmbededWidget`, `ThreeStateCheckboxWidget`, `WindowWidget` — these are engine-only widget types. They have **no script class declaration** at all; `PanelWidget.Cast(...)` does not exist. In script they are accessed only as the base `Widget`.

### Layout property groups

The properties available in `.layout` files are organized into additive groups. The set a widget receives depends on its type, not its script-class chain.

| Group | Applies to |
|-------|------------|
| `Widget` (base) | All widgets |
| `UIWidget` (style + focus navigation) | All UIWidget descendants |
| `Text` | TextWidget, MultilineTextWidget, RichTextWidget, EditBoxWidget, MultilineEditBoxWidget, HtmlWidget — both pure-text widgets (TextWidget branch) and UIWidget-text widgets (EditBoxWidget) |
| `SpacerWidget` | SpacerBaseWidget descendants — WrapSpacerWidget, GridSpacerWidget, ScrollWidget (with caveats — see ScrollWidget) |
| `SimpleProgressBarWidget` | SimpleProgressBarWidget, ProgressBarWidget, SliderWidget |

Property details for each group are in the sections below. Type-specific widget properties — in `widget-catalog.md`.

---

## 3. Widget — properties common to every widget

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `visible` | bool | `1` | Widget visibility. `0` hides the widget and its children |
| `disabled` | bool | `0` | Disables interaction |
| `clipchildren` | bool | `1` | Clip children to parent bounds |
| `inheritalpha` | bool | `0` | Inherit transparency from parent |
| `ignorepointer` | bool | `0` | Ignore mouse events |
| `ignoregloballv` | bool | `0` | Ignore global LV. Shown as "Ignore global LV" in the Workbench property inspector |
| `keepsafezone` | bool | `0` | Respect the screen safe zone (TV overscan) |
| `color` | RGBA | `255,255,255,255` | Color. In layout: `color R G B A` (0.0–1.0 per channel) |
| `scaled` | bool | `1` | Scale px values by resolution |
| `fixaspect` | enum | `none` | Aspect ratio behaviour |
| `priority` | int | `0` | Z-order (higher = on top) |
| `userID` | int | `0` | User-assigned ID for `FindAnyWidgetById()` |
| `draggable` | bool | `0` | Allow dragging |
| `scriptclass` | string | `""` | Script class name for binding. See `widget-scripting.md` |

**`fixaspect` values:**

| Value | Description |
|-------|-------------|
| `none` | No aspect ratio preservation |
| `inside` | Fit while preserving aspect (may have padding) |
| `outside` | Fill while preserving aspect (may crop) |
| `fixwidth` | Fixed width, height adjusts |
| `true` / `false` | Aliases for `inside` / `none` |

---

## 4. Positioning system

Each widget is positioned **relative to its parent** through a combination of anchor, offset (`position`), and size (`size`). The values of `position` and `size` can be specified two ways — as fractions of the parent (0.0–1.0, equivalent to 0–100%; the engine rescales to pixels at runtime) or as fixed pixels. The mode is controlled by exact-flags.

### `position` and `size`

| Property | Format | Description |
|----------|--------|-------------|
| `position` | `X Y` | Offset of the widget from the anchor point |
| `size` | `W H` | Widget size |

### Anchor

Sets the reference point inside the parent against which `position` is measured.

**Use only the `_ref` form.** Bare forms (`center`, `right`, `bottom`) are legacy and behave unpredictably:

- `center` without `_ref` is known to collapse the widget into the parent's top-left corner.
- `right` and `bottom` without `_ref` produce undefined behaviour — they may misalign or collapse the widget in non-obvious ways.

In all cases, prefer `_ref` form. Do not assume bare forms work the same way as `_ref` versions.

**`halign`** — horizontal anchor:

| Anchor | In layout | Description |
|--------|-----------|-------------|
| Left edge | *(omitted)* | Default — measured from the parent's left edge |
| Center | `center_ref` | Horizontal centering |
| Right edge | `right_ref` | Measured from the parent's right edge |

**`valign`** — vertical anchor:

| Anchor | In layout | Description |
|--------|-----------|-------------|
| Top edge | *(omitted)* | Default — measured from the parent's top edge |
| Center | `center_ref` | Vertical centering |
| Bottom edge | `bottom_ref` | Measured from the parent's bottom edge |

The left and top defaults are written by omitting the attribute. There are no `left_ref` or `top_ref` forms.

### Coordinate mode (exact-flags)

These flags switch `position` and `size` between fractions of the parent and fixed pixels. Horizontal and vertical axes are configured **independently**.

| Property | `0` (fraction of parent) | `1` (fixed pixels) |
|----------|--------------------------|---------------------|
| `hexactpos` | X position: 0.0–1.0 of parent width | X position: in pixels |
| `vexactpos` | Y position: 0.0–1.0 of parent height | Y position: in pixels |
| `hexactsize` | Width: 0.0–1.0 of parent width | Width: in pixels |
| `vexactsize` | Height: 0.0–1.0 of parent height | Height: in pixels |

The same button as fractions of the parent — 50% width of parent, centered:

```
ButtonWidgetClass btn {
 position 0.25 0.1
 size 0.5 0.08
 hexactpos 0
 vexactpos 0
 hexactsize 0
 vexactsize 0
}
```

And as fixed pixels — 200px from the left edge, 400×60px:

```
ButtonWidgetClass btn {
 position 200 50
 size 400 60
 hexactpos 1
 vexactpos 1
 hexactsize 1
 vexactsize 1
}
```

A **mixed mode** is common — for example, width as a fraction of parent (stretches with the window), height in pixels (fixed):

```
TextWidgetClass label {
 size 0.8 30
 hexactsize 0
 vexactsize 1
}
```

---

## 5. UIWidget group

Added to widgets that support styles and focus navigation: `PanelWidget`, `ButtonWidget`, `CheckBoxWidget`, `TextWidget`, `SliderWidget`, `SpacerWidget`, etc.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `style` | string | `Default` | Visual style from a `.styles` file. See `style-system.md` |
| `"no focus"` | bool | `0` | Exclude from focus navigation |
| `"next left"` | string | `""` | Widget to focus when navigating left |
| `"next right"` | string | `""` | Widget to focus when navigating right |
| `"next up"` | string | `""` | Widget to focus when navigating up |
| `"next down"` | string | `""` | Widget to focus when navigating down |

`next *` is used for gamepad/keyboard navigation — defines which widget receives focus on d-pad/arrow input.

---

## 6. Text group

Added to text widgets: `TextWidget`, `MultilineTextWidget`, `RichTextWidget`, `EditBoxWidget`.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | string | `""` | Text or localization key (`#string_key`) |
| `font` | string | `""` | Font path (e.g. `gui/fonts/sdf_MetronLight24`) |
| `"text color"` | RGBA | `255,255,255,255` | Text color |
| `"text halign"` | enum | `left` | Horizontal alignment: `left`, `center`, `right` |
| `"text valign"` | enum | `top` | Vertical alignment: `center` |
| `"text offset"` | `X Y` | `0 0` | Text offset inside the widget |
| `"exact text"` | bool | `0` | Use an exact font size |
| `"exact text size"` | int | — | Font size in pixels (when `"exact text" 1`) |
| `text_proportion` | float | — | Text proportion relative to the widget size |
| `"size to text h"` | bool | `0` | Resize widget width to text |
| `"size to text v"` | bool | `0` | Resize widget height to text |
| `"outline size"` | float | `0` | Text outline size |
| `"outline color"` | RGBA | `0,0,0,0` | Outline color |
| `"shadow size"` | float | `0` | Shadow size |
| `"shadow color"` | RGBA | — | Shadow color |
| `"shadow opacity"` | float | — | Shadow opacity |
| `"shadow offset"` | `X Y` | — | Shadow offset |
| `"text background"` | bool | `0` | Background behind the text |
| `"background color"` | RGBA | `0,0,204` | Text background color |

---

## 7. SpacerWidget group

Added to containers with automatic layout: `WrapSpacerWidget`, `GridSpacerWidget`, `ScrollWidget`.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `"Ignore invisible"` | bool | `1` | Skip hidden children when laying out |
| `Padding` | int | `2` | Inner padding (px) |
| `Margin` | int | `2` | Outer margin between children (px) |
| `"Size To Content H"` | bool | `0` | Resize width to fit content |
| `"Size To Content V"` | bool | `0` | Resize height to fit content |
| `content_halign` | enum | `left` | Horizontal content alignment: `left`, `center`, `right` |
| `content_valign` | enum | `top` | Vertical content alignment: `top`, `center`, `bottom` |

---

## 8. SimpleProgressBarWidget group

Added to progress bars and sliders: `SimpleProgressBarWidget`, `ProgressBarWidget`, `SliderWidget`.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `minimum` | float | `0` | Minimum value |
| `maximum` | float | `100` | Maximum value |
| `current` | float | `50` | Current value |
| `vertical` | bool | `0` | Vertical orientation |
| `flipped` | bool | `0` | Reverse fill direction |

---

## 9. Resource references

In layout files, widgets reference external resources — images, fonts, localization.

**Imageset images:**

```
image0 "set:dayz_gui image:icon_refresh"
```

Format: `set:<imageset_name> image:<image_name>`. Details in `imageset-format.md`.

**Direct textures:**

```
imageTexture "{D2377E3C2ECB1102}gui/textures/my_image.edds"
```

The GUID is generated on Workbench import. Details in `edds-format.md`.

**Embedded layout files:**

`EmbededWidget` embeds another layout into the current one via the `layout` property. The value is a path with a GUID prefix:

```
EmbededWidgetClass EmbededButton {
 position 38 30
 size 350 88
 hexactpos 1
 vexactpos 1
 hexactsize 1
 vexactsize 1
 scriptclass "EmbededButtonScript"
 layout "{B10E12F621E0AB2F}Gui/layouts/examples/ButtonTemplate.layout"
}
```

The embedded layout's GUID is generated on Workbench import, like for textures. `EmbededWidget` may have its own `scriptclass` — the embedded layout gets its own handler, separate from the parent's.

**Fonts:**

```
font "gui/fonts/sdf_MetronLight24"
```

**Localization keys:**

```
text "#string_key_name"
```

The `#` prefix denotes a key from `.csv` localization tables.
