# Style system

`.styles` files define the visual appearance of widgets: font, ImageSet source for images, color, and the set of images for each state. A widget references a style through the `style` property in a layout.

Location: `gui/looknfeel/`. Editor: Workbench → Style Editor.

`.styles` apply only to widgets that inherit from `UIWidget` (see `layout-fundamentals.md`). Widgets without UIWidget — e.g. `ImageWidget`, `VideoWidget`, `FrameWidget` — have no `style` property and are not styled.

---

## 1. File format

`.styles` is an XML document. The root element is `<WidgetStyles>`, containing per-widget-type style definitions.

```xml
<WidgetStyles>
    <Widget Name="TextWidget">
        <Style Name="Normal" Font="gui/fonts/MetronBook" ImageSet="" Color="4294967295" />
    </Widget>

    <Widget Name="ButtonWidget">
        <Style Name="Default" Font="gui/fonts/MetronBook" ImageSet="dayz_gui" Color="4294967295">
            <State Name="Normal">
                <Item Name="Center" Image="menuButtonCenter" />
                <Item Name="Left" Image="" />
            </State>
            <State Name="Focus">
                <Item Name="Center" Image="alpha_128" />
            </State>
        </Style>
    </Widget>
</WidgetStyles>
```

**Structure:**

- `<Widget Name="...">` — the widget type the style applies to (`TextWidget`, `ButtonWidget`, `PanelWidget`, etc.).
- `<Style Name="...">` — a named style with `Font`, `ImageSet`, `Color` attributes. The name is referenced from a layout via `style MyStyleName`.
- `<State Name="...">` — a visual state (`Normal`, `Focus`, `Disabled`, etc.).
- `<Item Name="...">` — an image slot inside a state. `Image=""` means empty (transparent slot).

---

## 2. Style attributes

| Attribute | Description |
|-----------|-------------|
| `Name` | Style name. Referenced from a layout via the `style` property |
| `Font` | Font path (`gui/fonts/...`). Empty string — no font set |
| `ImageSet` | Name of the `.imageset` file from which Item-slot images are taken |
| `Color` | Color as an ARGB uint32 (decimal number) |

### Encoding Color

Color is the decimal representation of a 32-bit ARGB value. Each channel takes one byte: `A R G B` (alpha is the high byte).

Formula: `Color = A*16777216 + R*65536 + G*256 + B`, with each channel in `0–255`.

Equivalent to the decimal form of the hex value `0xAARRGGBB`.

Examples:

| Decimal | Hex | Description |
|---------|-----|-------------|
| `4294967295` | `0xFFFFFFFF` | White, fully opaque |
| `0` | `0x00000000` | Fully transparent |
| `4279111952` | `0xFF1A1AD0` | Dark blue, fully opaque |
| `2147483648` | `0x80000000` | Semi-transparent black (alpha 128) |

Outside Workbench, the easiest way to compute the value is to write the ARGB in hex and convert to decimal.

---

## 3. Item slots

A **slot** is a named position inside a style's state, into which an image from the connected `ImageSet` is assigned. The set of slots is **fixed by the engine** for each widget type — the modder doesn't define new slots, only fills the existing ones.

The image for a slot is set via the `Image` attribute:

```xml
<Item Name="Center" Image="frame_corner_tl" />
```

The `Image` value is the name of an entry in the `ImageSet` file specified in the style's `ImageSet` attribute. Imageset registration — `imageset-format.md`.

An **empty value** `Image=""` means a transparent slot — the image is not rendered. Used to disable parts of the appearance (e.g. keep only the center, no frame).

### Slot pattern categories

The set of slots depends on the widget type. Widgets are grouped into categories by slot structure.

**No slots** — the style sets only Font/Color, no `<Item>` sections:

`TextWidget`, `MultilineTextWidget`, `RichTextWidget`, `HtmlWidget`, `BasicGraphWidget`, `RingBufferGraphWidget`, `TimeBasedGraphWidget`, `TimeBasedGraphWithAxesWidget`.

**Highlight** (1 slot) — `Highlight`:

`MultilineEditBoxWidget`.

**CheckBox** (1 slot) — `CheckBox`:

`CheckBoxWidget`, `ThreeStateCheckboxWidget`.

**9-slice** (9 slots) — a scalable background made of 9 parts. Corner slots don't stretch, edge slots stretch along one axis, the center stretches both ways:

```
LeftTop     | Top    | RightTop
Left        | Center | Right
LeftBottom  | Bottom | RightBottom
```

Widgets: `PanelWidget`, `EditBoxWidget`, `PasswordEditBoxWidget`, `ButtonWidget`, `ScrollWidget`, `GridSpacerWidget`, `WrapSpacerWidget`.

**9-slice + Overlay** (10 slots) — standard 9-slice plus an `Overlay` layer on top:

`SmartPanelWidget`.

**9-slice + Arrows** (11 slots) — standard 9-slice plus `ArrowLeft`, `ArrowRight`:

`XComboBoxWidget`.

**Body 9-slice + Title 9-slice** (18 slots) — two 9-slice blocks: main background (the standard 9 slots) plus a title bar:

```
TitleLeftTop, TitleTop, TitleRightTop
TitleLeft,    TitleCenter, TitleRight
TitleLeftBottom, TitleBottom, TitleRightBottom
```

Widgets: `WindowWidget`.

**Body 9-slice + Bar 9-slice** (18 slots) — background (the standard 9 slots) plus a fill bar:

```
BarLeftTop, BarTop, BarRightTop
BarLeft,    BarCenter, BarRight
BarLeftBottom, BarBottom, BarRightBottom
```

Widgets: `ProgressBarWidget`, `SimpleProgressBarWidget`, `SliderWidget`.

**Listbox** (31 slots) — a complex set for tabular lists: header (9-slice), title block, body (9-slice), scroll, separators, highlight:

```
Header:    HeaderLeftTop, HeaderTopCenter, HeaderRightTop, HeaderRightCenter,
           HeaderRightBottom, HeaderBottomCenter, HeaderLeftBottom, HeaderLeftCenter, HeaderCenter
Title:     TitleLeftCenter, TitleCenter, TitleCenterSeparator, TitleRightCenter
With:      LeftTopWithTitle, RightTopWithTitle
Body:      LeftTop, TopCenter, RightTop, RightCenter, Center, LeftCenter,
           RightBottom, BottomCenter, LeftBottom
Scroll:    ScrollBarTop, ScrollBarCenter, ScrollBarBottom
Extra:     TopSeparator, BottomSeparator, Separator, Highlight
```

Widgets: `GenericListboxWidget`, `UniversalListboxWidget`, `ServerBrowserWidget`, `TextListboxWidget`.

For specific slot names in other categories, refer to `gui/looknfeel/dayzwidgets.styles` or the Workbench Style Editor — both expose the full list of slots available for each widget type.

---

## 4. States

A **state** is a visual mode of a widget (normal, focused, disabled, etc.). Each state contains its own set of `<Item>` slots. When the widget's state changes, the engine switches to the corresponding image set.

The set of states is **fixed for each widget type**. If a state from the widget's set is not defined in the style, `Normal` is used as a fallback.

### Available states by widget type

| States | Widgets |
|--------|---------|
| — (no states) | `TextWidget`, `MultilineTextWidget`, `RichTextWidget`, `HtmlWidget` |
| `Normal` | Graph widgets |
| `Normal`, `Disabled` | `PanelWidget`, `SmartPanelWidget`, `ScrollWidget`, `GridSpacerWidget`, `WrapSpacerWidget`, `ProgressBarWidget`, `SimpleProgressBarWidget`, `WindowWidget` |
| `Normal`, `Focus` | `MultilineEditBoxWidget` |
| `Normal`, `Focus`, `Disabled` | `EditBoxWidget`, `PasswordEditBoxWidget`, `SliderWidget` |
| `Normal`, `Disabled`, `Focus` | `GenericListboxWidget`, `UniversalListboxWidget`, `ServerBrowserWidget`, `TextListboxWidget` |
| `Normal`, `Disabled`, `Mark`, `Highlight` | `CheckBoxWidget` |
| `Checked`, `Crossed`, `Disabled`, `Empty`, `Highlight` | `ThreeStateCheckboxWidget` |
| `Normal`, `Disabled`, `Focus`, `Highlight` | `XComboBoxWidget` |
| `Normal`, `Pushed`, `Highlight`, `Focus`, `Disabled` | `ButtonWidget` |

---

## 5. Registration via CfgMods

For the engine to load a `.styles` file, it must be registered in the mod's `config.cpp` via the `class defs { class widgetStyles { ... } }` section:

```cpp
class CfgMods
{
    class MyMod
    {
        dir = "MyMod";
        type = "mod";

        class defs
        {
            class widgetStyles
            {
                files[] =
                {
                    "MyMod/GUI/Looknfeel/MyMod.styles"
                };
            };
        };
    };
};
```

Without registration, the `.styles` file is not loaded by the engine — widgets that reference styles from it render as Default.

Multiple `.styles` files can be registered in a single `widgetStyles` section — the order in `files[]` determines load order.

---

## 6. Applying a style to a widget

In a layout file, a style is applied via the `style` property (part of the UIWidget group):

```
ButtonWidgetClass MyButton {
 style "MyButtonStyle"
 size 200 50
 hexactsize 1
 vexactsize 1
}
```

The style name must match the `Name` attribute of a `<Style>` inside a `.styles` file. If no matching style is found, the widget gets the Default appearance.

When multiple `.styles` files contain a style with the same name for the same widget type, the last loaded one wins — the order is determined by the `files[]` array in `CfgMods`.
