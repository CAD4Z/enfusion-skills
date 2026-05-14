# Widget catalog

Catalog of all DayZ widgets. For each widget: inheritance hierarchy, script class with method names, type-specific properties, and notable behaviour.

The base layout mechanics and common property groups (Widget, UIWidget, Text, SpacerWidget, SimpleProgressBarWidget) are described in `layout-fundamentals.md`. This file lists only **type-specific** properties — those not part of the inherited groups.

In layout files, widgets are written with a `Class` suffix (e.g., `TextWidgetClass`). In the script API — without (`TextWidget`). Section headings use the script form.

---

## Container widgets

Structural containers used for grouping and nesting. **None of them have a script class declared in scripts** — `PanelWidget.Cast(...)`, `FrameWidget.Cast(...)` etc. do not exist. In script they are accessed only as the base `Widget`.

### FrameWidget

Base container for grouping. The root element of most layout files. No type-specific properties — only the base Widget structure from `layout-fundamentals.md`.

**Layout-property groups:** Widget.
**Script class:** none — accessed via the base `Widget`. No Cast available.

### ContentWidget

Structurally identical to `FrameWidget`. No type-specific properties.

**Layout-property groups:** Widget.
**Script class:** none — accessed via the base `Widget`. No Cast available.

### PanelWidget

Container with a visual background — unlike `FrameWidget`, it can be styled via `style`. No type-specific properties; the background is set through `color` (Widget) and `style`.

**Layout-property groups:** Widget + UIWidget (style + focus navigation properties apply at layout level even though there is no PanelWidget script class extending UIWidget).
**Script class:** none — accessed via the base `Widget`. No Cast available.

### SmartPanelWidget

Panel with automatic fitting.

**Layout-property groups:** Widget + UIWidget.
**Script class:** none — accessed via the base `Widget`. No Cast available.

### EmbededWidget

Embeds another `.layout` file into the current one. Used for component reuse.

**Layout-property groups:** Widget.
**Script class:** none — accessed via the base `Widget`. No Cast available.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `layout` | string | `""` | Path to the embedded layout with a GUID prefix, e.g. `"{B10E12F621E0AB2F}Gui/layouts/examples/ButtonTemplate.layout"` |

`EmbededWidget` may have its own `scriptclass` — the embedded layout gets its own handler, separate from the parent. Details in `layout-fundamentals.md` section 9.

---

## Spacer containers

Containers with automatic child layout. All inherit the `SpacerWidget` group (see `layout-fundamentals.md`). Most script-class methods control layout and scrolling.

### WrapSpacerWidget

Lays out children in a row, wrapping to a new line at the boundary. Used for toolbars and adaptive layouts. No type-specific properties beyond SpacerWidget.

**Inherits:** `Widget → UIWidget → SpacerBaseWidget → SpacerWidget → WrapSpacerWidget`.
**Script class:** `WrapSpacerWidget` — inherits `AddChildAfter(Widget child, Widget after, bool immedUpdate = true)` from `SpacerBaseWidget`, and `GetContentAlignmentH/V`, `SetContentAlignmentH(WidgetAlignment)`, `SetContentAlignmentV(WidgetAlignment)` from `SpacerWidget`.

### GridSpacerWidget

Grid layout with a fixed number of columns and rows.

**Inherits:** `Widget → UIWidget → SpacerBaseWidget → SpacerWidget → GridSpacerWidget`.
**Script class:** `GridSpacerWidget` — inherits methods from `SpacerWidget` and `SpacerBaseWidget`.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `Columns` | int | `3` | Number of columns |
| `Rows` | int | `3` | Number of rows |

### ScrollWidget

Scrollable container with a horizontal and/or vertical scrollbar.

**Inherits:** `Widget → UIWidget → SpacerBaseWidget → ScrollWidget`. **Not** a descendant of `SpacerWidget` — therefore **does not have** `SetContentAlignmentH/V`. From `SpacerBaseWidget` it inherits `AddChildAfter`.
**Script class:** `ScrollWidget` — scrolling methods: `GetScrollbarWidth()` (float), `IsScrollbarVisible()` (bool), `GetContentWidth`, `GetContentHeight`, `GetHScrollPos`, `GetHScrollPos01`, `HScrollStep`, `HScrollToPos`, `HScrollToPos01`, `HScrollToWidget`, `GetVScrollPos`, `GetVScrollPos01`, `VScrollStep`, `VScrollToPos`, `VScrollToPos01`, `VScrollToWidget`.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `"Scrollbar H"` | bool | `0` | Horizontal scrollbar |
| `"Scrollbar V"` | bool | `0` | Vertical scrollbar |
| `"Scrollbar V Left"` | bool | `0` | Vertical scrollbar on the left side instead of the right |

---

## Text widgets

All inherit the `Text` group (see `layout-fundamentals.md`).

### TextWidget

Single-line text. No type-specific properties beyond the Text group.

**Inherits:** `Widget → TextWidget` (script-class chain — **does not** extend UIWidget). Layout-property groups: Widget + Text. Visual style is applied via `style` even though there is no UIWidget in the chain — TextWidget styles only set Font/Color, no Item slots.
**Script class:** `TextWidget` — methods: `SetText(string text, bool immedUpdate = true)`, `SetTextSpacing`, `SetTextExactSize`, `SetTextOffset`, `SetOutline`, `GetOutlineSize`, `GetOutlineColor`, `SetShadow`, `GetShadowSize`, `GetShadowColor`, `GetShadowOpacity`, `GetShadowOffset(out float sx, out float sy)`, `SetItalic`, `GetItalic`, `SetBold`, `GetBold`, `GetTextSize(out int sx, out int sy)`, `SetTextFormat(string text, void p1=NULL, ..., void p9=NULL)` (printf-style), `GetTextProportion`, `SetTextProportion`.

For `TextWidget`, the **widget color is the text color** — use `Widget.SetColor(...)`, not `UIWidget.SetTextColor(...)` (which doesn't exist on TextWidget).

### MultilineTextWidget

Multi-line text with wrapping by widget width.

**Inherits:** `Widget → TextWidget → MultilineTextWidget`. Layout-property groups: Widget + Text.
**Script class:** `MultilineTextWidget` — inherits from `TextWidget`, adds: `SetLineBreakingOverride(int mode)` — returns `float` (engine quirk).

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `wrap` | bool | `0` | Wrap text by widget width |

### RichTextWidget

Text with support for inline images and HTML-like markup.

**Inherits:** `Widget → TextWidget → RichTextWidget`. Layout-property groups: Widget + Text.
**Script class:** `RichTextWidget` — inherits from `TextWidget`, adds: `GetContentHeight()`, `GetContentOffset()`, `SetContentOffset(float offset, bool snapToLine = false)`, `ElideText(int line, float maxWidth, string str)`, `GetNumLines()`, `SetLinesVisibility(int lineFrom, int lineTo, bool visible)`, `GetLineWidth(int line)`, `SetLineBreakingOverride(int mode)` — returns `float` (engine quirk).

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `wrap` | bool | `0` | Wrap text |
| `"condense whitespace"` | bool | `0` | Collapse whitespace |
| `"strip newlines"` | bool | `0` | Remove line breaks |

**HTML-like markup.** Text passed to `RichTextWidget` (via `SetText` or the `text` attribute in layout) supports formatting tags. Tags can be nested.

| Tag | Purpose | Attributes |
|-----|---------|-----------|
| `<br />` | Line break | — |
| `<p>` | Paragraph with alignment | `align`: `left`, `center`, `right` |
| `<image>` | Image from an imageset | `set`, `name`, `scale` |
| `<b>` | Bold text | — |
| `<i>` | Italic text | — |
| `<color>` | Text color | `hex` (format `0xAARRGGBB`) or `rgba` (`R,G,B,A` comma-separated) |
| `<outline>` | Text outline | `color` (RGBA), `size` |
| `<shadow>` | Text shadow | `color` (RGBA), `size`, `offset` (`X,Y`), `opacity` |

`<image>` loads the image from a connected imageset. The `scale` attribute is a size multiplier. Imageset registration — `imageset-format.md`.

`<color>` accepts two alternative attributes:

```
<color hex="0xFFFF6600">orange text</color>
<color rgba="255,102,0,255">orange text</color>
```

Combined example:

```
<p align="center"><b>Welcome,</b> <color hex="0xFFFF6600">survivor</color>.<br /><i>Your journey begins here.</i></p>
```

### EditBoxWidget

Single-line text input field.

**Inherits:** `Widget → UIWidget → EditBoxWidget`. Script-class chain goes through UIWidget directly — **not** through TextWidget. Layout-property groups: Widget + UIWidget + Text (the Text property group is applied at layout level despite the absence of TextWidget in the chain).
**Script class:** `EditBoxWidget` — methods: `proto string GetText()` (returns the value), `proto native void SetText(string str)` (no `immedUpdate` parameter).

### MultilineEditBoxWidget

Multi-line edit field. **Not** a descendant of `EditBoxWidget` — inherits from `TextWidget`, which makes its API differ from a regular `EditBoxWidget`.

**Inherits:** `Widget → TextWidget → MultilineEditBoxWidget`. Layout-property groups: Widget + Text.
**Script class:** `MultilineEditBoxWidget` — methods: `GetLinesCount`, `GetCarriageLine`, `GetCarriagePos`, `proto void GetText(out string text)` (out parameter, not return — incompatible with `EditBoxWidget.GetText()`), `SetLine(int line, string text)`, `proto void GetLine(int line, out string text)`. Scrolling — through wrapping in a `ScrollWidget`.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `lines` | int | — | Number of lines |
| `"limit visible"` | bool | — | Limit visible area |

**Note:** `MultilineEditBoxWidget` and `EditBoxWidget` cannot be unified through a common cast — the script-class chains diverge (`Widget → TextWidget → MultilineEditBoxWidget` vs `Widget → UIWidget → EditBoxWidget`), and the `GetText` signatures are incompatible.

### PasswordEditBoxWidget

Input field with character masking. Descendant of `EditBoxWidget`. Masking is purely visual — the actual input is accessible via `GetText`.

**Inherits:** `Widget → UIWidget → EditBoxWidget → PasswordEditBoxWidget`.
**Script class:** `PasswordEditBoxWidget` — inherits from `EditBoxWidget`, adds: `SetHideText(bool hide)`.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `"hide text"` | bool | `1` | Initial masking state |

---

## Controls

Interactive elements. All inherit UIWidget.

### ButtonWidget

Button with text. The script API exposes `SetText` — text can be changed from code.

**Inherits:** `Widget → UIWidget → ButtonWidget`. Layout-property groups: Widget + UIWidget + Text (the Text group is applied at layout level even though TextWidget is not in the chain).
**Script class:** `ButtonWidget` — methods: `GetState()` (bool), `SetState(bool state)`, `SetText(string text)` (no `immedUpdate` parameter), `proto void GetText(out string text)` (out parameter, **not** return — incompatible with `EditBoxWidget.GetText()`), `SetTextOffset(float xoffset, float yoffset)`, `SetTextHorizontalAlignment(int align)` (`ALIGN_CENTER` / `ALIGN_LEFT` / `ALIGN_RIGHT`), `SetTextVerticalAlignment(int align)` (`ALIGN_CENTER` / `ALIGN_TOP` / `ALIGN_BOTTOM`), `GetTextProportion`, `SetTextProportion`.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text_proportion` | float | — | Text proportion relative to button height |
| `font` | string | — | Button text font |
| `switch` | enum | `normal` | Behaviour: `normal` (press) or `once` (toggle) |

### CheckBoxWidget

Two-state checkbox.

**Inherits:** `Widget → UIWidget → CheckBoxWidget`.
**Script class:** `CheckBoxWidget` — methods: `SetText(string str)` (no `immedUpdate`), `IsChecked()` (bool), `SetChecked(bool checked)`.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | string | `""` | Text next to the checkbox |
| `checked` | bool | `0` | Initial state |

### ThreeStateCheckboxWidget

Three-state checkbox: `none`, `check`, `crossed`.

**Inherits:** Widget + UIWidget
**Script class:** whether a dedicated class exists is not confirmed in the API; for most operations the base methods suffice.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | string | `""` | Text |
| `checked` | enum | `none` | State: `none`, `check`, `crossed` |

### XComboBoxWidget

Dropdown list. Items are added programmatically via `AddItem`.

**Inherits:** Widget + UIWidget
**Script class:** `XComboBoxWidget` — methods: `AddItem`, `ClearAll`, `SetItem`, `RemoveItem`, `GetNumItems`, `SetCurrentItem`, `GetCurrentItem`.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | string | `""` | Default text |

### SimpleProgressBarWidget

Simple progress bar without visual customization. Inherits the `SimpleProgressBarWidget` layout-property group (see `layout-fundamentals.md`).

**Inherits:** `Widget → UIWidget → SimpleProgressBarWidget`. Layout-property groups: Widget + UIWidget + SimpleProgressBarWidget.
**Script class:** `SimpleProgressBarWidget` — methods: `GetMin()` (float), `GetMax()` (float), `GetCurrent()` (float), `SetCurrent(float curr)`.

### ProgressBarWidget

Stylable progress bar. API-identical to `SimpleProgressBarWidget` but supports customization through `style`.

**Inherits:** `Widget → UIWidget → SimpleProgressBarWidget → ProgressBarWidget`.
**Script class:** `ProgressBarWidget` — inherits from `SimpleProgressBarWidget`, no additional methods.

### SliderWidget

Slider control. Supports step, marker, and reaction to user input.

**Inherits:** `Widget → UIWidget → SliderWidget`. **Not** a descendant of `SimpleProgressBarWidget` — its progress-bar-like API is parallel, not inherited. Layout-property groups: Widget + UIWidget + SimpleProgressBarWidget (the property group is applied at layout level).
**Script class:** `SliderWidget` — methods: `SetMinMax(float minimum, float maximum)`, `GetMin()` (float), `GetMax()` (float), `GetCurrent()` (float), `SetCurrent(float curr)`, `GetStep()` (float), `SetStep(float step)`.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `step` | float | `1` | Value step |
| `"marker thickness"` | float | `0.1` | Marker thickness (fraction of size) |
| `"fill in"` | bool | `1` | Fill bar up to the marker |
| `"draw marker"` | bool | `0` | Draw the marker |
| `"listen to input"` | bool | `0` | React to user input |

---

## Visual widgets

### ImageWidget

Image display. Source — an imageset (via `image0`) or a direct texture (via `imageTexture`). Supports masks, rotation, tiling.

**Inherits:** Widget (no UIWidget — no style or focus navigation)
**Script class:** `ImageWidget` — methods: `LoadImageFile`, `SetImageTexture`, `GetImageSize`, `SetImage`, `GetImage`, `SetUV`, `LoadMaskTexture`, `GetMaskProgress`, `SetMaskProgress`, `GetMaskTransitionWidth`, `SetMaskTransitionWidth`.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `image0` | string | `""` | Image from imageset: `"set:name image:icon"` |
| `imageTexture` | string | `""` | Direct texture path: `"{GUID}path.edds"` |
| `mode` | enum | `opaque` | Render mode: `opaque`, `blend`, `additive` |
| `"src alpha"` | bool | `0` | Use the source's alpha channel |
| `"clamp mode"` | enum | `invalid` | Repeat: `invalid`, `wrap`, `clamp`, `border` |
| `"stretch mode"` | enum | `invalid` | Stretching: `invalid`, `none`, `stretch_w_h`, `fit_w_center` |
| `"flip u"` | bool | `0` | Horizontal flip |
| `"flip v"` | bool | `0` | Vertical flip |
| `filter` | bool | `1` | Filtering (smoothing) |
| `nocache` | bool | `0` | Don't cache the texture |
| `rotation` | vector | `0,0,0` | Rotation (roll, pitch, yaw) |
| `pivot` | vector | `0.5,0.5` | Pivot point (0–1) |
| `Mask` | string | `""` | Mask texture path |
| `"Transition width"` | float | `0.1` | Mask transition width |
| `Progress` | float | `1.0` | Mask progress (0.0–1.0) |

### VideoWidget

Video playback. Supports subtitles and event callbacks (load, play, pause, end, error).

**Inherits:** Widget (no UIWidget)
**Script class:** `VideoWidget` — methods: `Load`, `Unload`, `Play`, `Pause`, `Stop`, `SetTime`, `GetTime`, `GetTotalTime`, `SetLooping`, `IsLooping`, `IsPlaying`, `GetState`, `DisableSubtitles`, `IsSubtitlesDisabled`, `SetCallback`. Also legacy `Play(VideoCommand cmd)` and `LoadVideo(string name, int soundScene)` — do not use in new code.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `video` | string | `""` | Video file path |
| `mode` | enum | `opaque` | Render mode |
| `"src alpha"` | bool | `0` | Alpha channel |
| `"clamp mode"` | enum | `invalid` | Repeat mode |
| `"stretch mode"` | enum | `none` | Stretch mode |
| `"flip u"` / `"flip v"` | bool | `0` | Flip |
| `filter` | bool | `1` | Filtering |
| `font` | string | `""` | Subtitle font |
| `"text color"` | RGBA | `255,255,255,255` | Subtitle text color |
| `"outline size"` | float | `0` | Text outline |
| `"outline color"` | RGBA | `0,0,0,0` | Outline color |
| `"text offset"` | `X Y` | `0,0` | Subtitle offset |
| `"text background"` | bool | `0` | Background behind subtitles |
| `"background color"` | RGBA | `0,0,0,204` | Background color |

---

## Render targets

### RenderTargetWidget

Displays the result of camera rendering in real time.

**Inherits:** Widget
**Script class:** `RenderTargetWidget` — methods: `SetRefresh`, `SetResolutionScale`. Camera binding — through the global function `SetWidgetWorld(RenderTargetWidget w, IEntity wrldEntity, int camera)`.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `camera` | int | `0` | Camera index |
| `refresh` | int | `0` | Refresh rate (period; > 1 means render every nth frame) |
| `offset` | int | `-1` | Buffer offset |
| `xscale` | float | `1` | Scale X |
| `yscale` | float | `1` | Scale Y |
| `filter` | bool | `0` | Filtering |

### RTTextureWidget

Render texture — can be used as a source for other widgets via `ImageWidget.SetImageTexture()`.

**Inherits:** Widget
**Script class:** `RTTextureWidget` — no additional methods (inherits from `Widget`).

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `"render always"` | bool | `0` | Render every frame |
| `noclear` | bool | `0` | Don't clear the buffer |
| `sRGB` | bool | `0` | sRGB color space |

---

## 3D previews

3D widgets for model previewing. Have a similar API for controlling model orientation and position.

### ItemPreviewWidget

3D item model preview.

**Inherits:** Widget
**Script class:** `ItemPreviewWidget` — methods: `SetItem`, `GetItem`, `GetView`, `SetView`, `SetModelOrientation`, `GetModelOrientation`, `SetModelPosition`, `GetModelPosition`, `SetForceFlipEnable`, `SetForceFlip`.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `"force flip enable"` | bool | `0` | Allow forced flipping |
| `"force flip"` | bool | `0` | Flip the model |

`SetView(int viewIndex)` switches between saved boundingbox parameters of the model (0 — primary, 1+ — additional angles from the model config).

### PlayerPreviewWidget

3D character model preview. Controlled only from script — no layout properties.

**Inherits:** Widget
**Script class:** `PlayerPreviewWidget` — methods: `UpdateItemInHands`, `SetPlayer`, `GetDummyPlayer`, `Refresh`, `SetModelOrientation`, `GetModelOrientation`, `SetModelPosition`, `GetModelPosition`.

---

## Misc

### CanvasWidget

Programmatic line drawing. Used for overlays, diagrams, debug visualization.

**Inherits:** Widget
**Script class:** `CanvasWidget` — methods: `DrawLine`, `Clear`. No layout properties — drawing is fully script-driven.

### MapWidget

Map widget. Displays the world map with the ability to add custom markers.

**Inherits:** Widget
**Script class:** `MapWidget` — methods: `ClearUserMarks`, `AddUserMark`, `GetMapPos`, `SetMapPos`, `GetScale`, `SetScale`, `GetContourInterval`, `GetCellSize`, `MapToScreen`, `ScreenToMap`. No layout properties — controlled from script.

### HtmlWidget

Text with HTML markup. Descendant of `RichTextWidget`. Loads an HTML file via `LoadFile`.

**Inherits:** Widget + UIWidget + Text (via `RichTextWidget`)
**Script class:** `HtmlWidget` — methods: `LoadFile`. The rest are inherited from `RichTextWidget` and `TextWidget`.

Rarely encountered in vanilla layout files.

---

## System widgets

Widgets used by the engine or rarely applied in modding. Listed for completeness — detailed analysis is expected later.

### WindowWidget

Internal system window with a title bar. Rarely used in modding.

### BaseListboxWidget / SimpleListboxWidget / TextListboxWidget / GenericListboxWidget

The engine's list hierarchy. `TextListboxWidget` — for tabular lists with columns. Used in system menus (server browser, etc.). API: `ClearItems`, `GetNumItems`, `SelectRow`, `GetSelectedRow`, `RemoveRow`, `EnsureVisible`. `TextListboxWidget` additionally has `AddItem`, `SetItem`, `GetItemText`, `GetItemData`, `SetItemColor`.

### ConsoleWidget

Internal console widget. Not used in modding.

### WorkspaceWidget

Root workspace widget. Created by the engine, not by modders. Has special methods `CreateWidget(WidgetType type, ...)` and `CreateWidgets(string layout, ...)` — the latter is the way to create a widget tree from a layout file in script.
