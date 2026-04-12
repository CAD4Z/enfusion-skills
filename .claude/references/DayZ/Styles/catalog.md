## Каталог стилей: dayzwidgets.styles

Полный каталог стилей из ванильного `gui/looknfeel/dayzwidgets.styles`.

Формат, Item-слоты и States — см. `@.claude/references/DayZ/Styles/styles.md`.
ImageSet-атласы, из которых берутся картинки — см. `@.claude/references/DayZ/Imagesets/imagesets.md`.

Условные обозначения: состояния без непустых Image не указаны. `*` = все 9 слотов 9-slice заполнены одним значением.

### TextWidget

| Style | Font | Color |
|-------|------|-------|
| Normal | gui/fonts/MetronBook | FFFFFFFF |
| Bold | gui/fonts/MetronBook-Bold | FFFFFFFF |
| Light | gui/fonts/MetronLight | FFFFFFFF |
| None | gui/fonts/sdf_MetronBook72 | FFFFFFFF |

### MultilineTextWidget

| Style | Font | Color |
|-------|------|-------|
| DayZNormal | gui/fonts/MetronBook | FFFFFFFF |
| DayZBold | gui/fonts/MetronBook-Bold | FFFFFFFF |
| None | gui/fonts/sdf_MetronBook72 | FFFFFFFF |

### RichTextWidget

| Style | Font | Color |
|-------|------|-------|
| DayZNormal | gui/fonts/MetronBook | FFFFFFFF |
| DayZBold | gui/fonts/MetronBook-Bold | FFFFFFFF |

### HtmlWidget

| Style | Font | ImageSet | Color |
|-------|------|----------|-------|
| DayZNormal | gui/fonts/MetronBook | ccgui_enforce | FFFFFFFF |

### MultilineEditBoxWidget

**DayZNormal** — MetronBook | ccgui_enforce | FFFFFFFF
- Normal: Highlight=ListboxHighlight
- Focus: Highlight=ListboxHighlight

**DayZBold** — MetronBook-Bold | ccgui_enforce | FFFFFFFF
- Normal: Highlight=ListboxHighlightFocus
- Focus: Highlight=ListboxHighlightFocus

### ProgressBarWidget

**Default** — (no font) | ccgui_enforce | FFFFFFFF
- Normal: Center=ProgressMenuDefaultEmpty, BarCenter=ProgressMenuDefaultFull
- Disabled: Center=ProgressMenuDefaultEmpty, BarCenter=ProgressMenuDefaultFull

**DayZLoading** — (no font) | dayz_gui | FFFFFFFF
- Normal: BarCenter=ProgressDayZFull
- Disabled: BarCenter=ProgressDayZFull

**Stamina** — MetronBook | dayz_gui | FFFFFFFF
- Normal: BarCenter=alpha_256, Center=alpha_64
- Disabled: BarCenter=alpha_64, Center/Left/Right/Top/Bottom/LeftTop/LeftBottom/RightTop/RightBottom=alpha_64

**Quantity** — MetronBook | dayz_gui | FFFFFFFF
- Normal: BarCenter=alpha_256, Center=alpha_64
- Disabled: BarCenter=quantity_empty, Center=alpha_256

**Loading** — sdf_MetronLight24 | dayz_gui | FFFFFFFF
- Normal: BarCenter=red_half, Center=alpha_32
- Disabled: BarCenter=quantity_empty, Center=alpha_256

### SimpleProgressBarWidget

**Default** — (no font) | ccgui_enforce | FFFFFFFF
- Normal: BarCenter=ProgressMenuDefaultFull

### SliderWidget

**Default** — (no font) | dayz_gui | FFFFFFFF
- Normal: 9-slice*=alpha_224, Bar 9-slice*=alpha_176
- Focus: 9-slice*=alpha_256, Bar 9-slice*=alpha_192
- Disabled: 9-slice*+Center=alpha_256, Bar 9-slice*=alpha_144

**Editor** — AmorSerifPro-Bold12 | dayz_gui | FFFFFFFF
- Normal: 9-slice=menuButton*, BarCenter=EditorPanelCenter, BarTop=EditorPanelTop

**DayZDefault** — sdf_MetronLight24 | dayz_gui | Color=10
- Normal: BarCenter=EditorPanelCenter, Center=menuButtonCenter

### GenericListboxWidget

**Default** — MetronBook | ccgui_enforce | FFFFFFFF
- Normal: полный Listbox (все 31 слот = Listbox* варианты)
- Focus: Highlight=ListboxHighlight

### UniversalListboxWidget

**Default** — MetronBook | rover_imageset | FFFFFFFF
- Normal: LeftTop=ListboxLeftTop, TopCenter=ListboxTopCenter, RightTop/RightCenter/RightBottom=ListboxRight*Main, Center=ListboxCenter, LeftCenter=ListboxLeftCenter, BottomCenter=ListboxBottomCenter, LeftBottom=ListboxLeftBottom, ScrollBarCenter=ListboxScrollBarCenterMain, Highlight=ListboxHighlightMain
- Focus: (идентично Normal)

### ServerBrowserWidget

**Default** — MetronBook | rover_imageset | FFFFFFFF
- Normal: аналогично UniversalListboxWidget + LeftTopWithTitle=ListboxLeftTop, RightTopWithTitle=ListboxRightTopMain
- Focus: (идентично Normal)

### TextListboxWidget

**Default** — MetronBook | rover_imageset | FFFFFFFF
- Normal: аналогично UniversalListboxWidget
- Focus: (идентично Normal)

**Editor** — AmorSerifPro-Bold12 | dayz_gui | FFFFFFFF
- Normal: Center=menuButtonCenter, Highlight=editorQuadSelCenter, RightBottom=menuButtonCenter, RightCenter=editorQuadSelCenter, RightTop=ColorableBar, ScrollBarCenter=quantity_empty

**debugUI** — gui/fonts/system | rover_imageset | FFFFFFFF
- Normal: Highlight=ListboxHighlightMain, RightBottom/RightCenter/RightTop=ListboxRightCenterMain, ScrollBarCenter=ListboxScrollBarCenterMain
- Focus: Highlight=ListboxHighlightMain

**NoScrollBar** — AmorSerifPro-Bold | dayz_gui | FFFFFFFF
- Normal: RightCenter=InventoryGridEmptyRight

### CheckBoxWidget

**Default** — MetronBook | ccgui_enforce | FFFFFFFF
- Normal: CheckBox=CheckboxNormal
- Disabled: CheckBox=CheckboxDisabled
- Mark: CheckBox=MarkDone
- Highlight: CheckBox=CheckboxHover

**NewStyle** — MetronBook | dayz_gui | FFFFFFFF
- Normal: CheckBox=icon_favourite_off
- Disabled: CheckBox=icon_locked_sb
- Mark: CheckBox=icon_favourite_on
- Highlight: CheckBox=icon_favourite_off

**Editor** — MetronBook | dayz_gui | FFFFFFFF
- Normal: CheckBox=InventoryGridEmpty_
- Disabled: CheckBox=InventoryGridCenter
- Mark: CheckBox=Expand
- Highlight: CheckBox=InventoryGridEmpty_

**ServerBrowserExpand** — MetronBook | dayz_gui | FFFFFFFF
- Normal: CheckBox=icon_collapse
- Mark: CheckBox=icon_expand

### ThreeStateCheckboxWidget

**NewStyle** — MetronBook | ccgui_enforce | FFFFFFFF
- Checked: CheckBox=MarkDone
- Crossed: CheckBox=MarkFailed
- Disabled: CheckBox=CheckboxDisabled
- Empty: CheckBox=CheckboxNormal
- Highlight: CheckBox=CheckboxHover

### WindowWidget

**Default** — (no font) | dayz_gui | FFFFFFFF
- Normal/Disabled: все пусто

**rover_sim_black** — (no font) | rover_imageset | FFFFFFFF
- Normal/Disabled: 9-slice body=SimBlack*

**rover_sim_black_2** — (no font) | rover_imageset | FFFFFFFF
- Normal/Disabled: 9-slice body=SimBlack2*

**Colorable** — MetronBook | rover_imageset | FFFFFFFF
- Normal: Center=WhitePixel

**Simple** — (no font) | rover_imageset | FFFFFFFF
- Normal: 9-slice body=ButtonPushed*, 9-slice title=ButtonHighlited*

**debugUI** — gui/fonts/system | dayz_gui | FFFFFFFF
- Normal: 9-slice body=menuButton*, 9-slice title=editorQuadSel*
- Disabled: body=menuButton*(Center=iconDrops), title=editorQuadSel*

### EditBoxWidget

**Default** — MetronBook | dayz_gui | FFFFFFFF
- Focus: Center=area_focus

**Editor** — AmorSerifPro-Bold12 | dayz_gui | FFFFFFFF
- Normal: 9-slice=menuButton*

**EditorProperty** — AmorSerifPro-Bold12 | dayz_gui | FFFFFFFF
- Normal: 9-slice=editorQuad*

**DefaultBorder** — MetronBook | dayz_gui | FFFFFFFF
- Normal: рамка без Center (editorQuad*, Left=editorQuadSelLeft)

**ServerBrowser** — sdf_MetronLight24 | dayz_gui | FFFFFFFF
- все пусто

### PasswordEditBoxWidget

Идентичен EditBoxWidget — те же 5 стилей (Default, Editor, EditorProperty, DefaultBorder, ServerBrowser) с теми же значениями.

### ButtonWidget

**Default** — MetronBook | dayz_gui | FFFFFFFF
- Pushed: Center=alpha_176
- Focus: Center=alpha_128
- Disabled: Center=alpha_64

**InventoryActionMenu** — MetronBook | dayz_gui | FFFFFFFF
- Normal: 9-slice*=editorQuadCenter
- Pushed/Highlight/Focus: Center=ActionMenuSelectCenter

**MenuDefault** — MetronBook | dayz_gui | FFFFFFFF
- Normal: Center=menuButtonCenter
- Pushed/Focus/Highlight: Center=editorQuadSelCenter
- Disabled: Center=editorQuadCenter

**Editor** — Metron-Bold14 | dayz_gui | FFFFFFFF
- Normal: 9-slice=menuButton*
- Focus: 9-slice=EditorPanel*
- Pushed: 9-slice=editorQuadSel*

**MainMenu** — MetronBook | dayz_gui | FFFFFFFF
- Pushed/Focus/Highlight: Center=menuButtonCenter

**ServerBrowserCollapse** — MetronBook22 | dayz_gui | FFFFFFFF
- Focus: Center=editorQuadSelCenter

**OldStyle** — MetronBook | dayz_gui | FFFFFFFF
- Normal: Center=editorQuadCenter
- Highlight: Center=editorQuadSelCenter
- Focus: Center=editorQuadCenter

**DayZDefaultButton** — sdf_MetronBook24 | dayz_gui | FFFFFFFF
- Normal: Bottom=DayZDefaultPanelBottom, Center=DayZDefaultPanelCorner, Left=DayZDefaultPanelLeft, Right=DayZDefaultPanelRight, Top=DayZDefaultPanelTop
- Highlight: Center=EditorPanelCenter
- Focus/Pushed: Center=editorQuadSelCenter

**DayZDefaultButtonNoBorder** — sdf_MetronBook24 | dayz_gui | FFFFFFFF
- Normal: Center=DayZDefaultPanelCorner
- Highlight: Center=EditorPanelCenter
- Focus/Pushed: Center=editorQuadSelCenter
- Disabled: Center=editorQuadCenter

**Empty** — AmorSerifPro-Bold | rover_imageset | FFFFFFFF
- все пусто

**Colorable** — AmorSerifPro-Bold | rover_imageset | Color=0
- Normal/Pushed/Focus/Highlight/Disabled: Center=WhitePixel

**EmptyHighlight** — AmorSerifPro-Bold | rover_imageset | FFFFFFFF
- Focus: Center=WhitePixel
- Pushed: Center=BottonPushed
- Disabled: Center=BottonPushed2

**DayZDefaultButtonBottom** — AmorSerifPro-Bold | dayz_gui | Color=0
- Focus: Bottom=DayZDefaultPanelBottom, Center=DayZDefaultPanelCorner, Left=DayZDefaultPanelLeft, Right=DayZDefaultPanelRight
- Pushed: Bottom=DayZDefaultPanelBottom, Center=DayZDefaultPanelCorner
- Disabled: 9-slice*=area_7

**DayZDefaultButtonSides** — AmorSerifPro-Bold | dayz_gui | Color=0
- Focus/Pushed: Center=DayZDefaultPanelCorner, Left=DayZDefaultPanelLeft, Right=DayZDefaultPanelRight

**DayZDefaultButtonTop** — AmorSerifPro-Bold | dayz_gui | Color=0
- Focus: Center=DayZDefaultPanelCorner, Left=DayZDefaultPanelLeft, Right=DayZDefaultPanelRight, Top=DayZDefaultPanelTop
- Pushed: Center=DayZDefaultPanelCorner, Top=DayZDefaultPanelTop
- Disabled: 9-slice*=area_7

**DayZDefaultButtonAll** — AmorSerifPro-Bold | dayz_gui | Color=0
- Focus/Pushed: Bottom=DayZDefaultPanelBottom, Center=DayZDefaultPanelCorner, Left=DayZDefaultPanelLeft, Right=DayZDefaultPanelRight, Top=DayZDefaultPanelTop
- Disabled: 9-slice*=alpha_128

**DayZInventoryButtonAll** — AmorSerifPro-Bold | dayz_gui | Color=0
- Normal: Bottom=InventoryButtonBottom, Center=InventoryButtonCenter, Left=InventoryButtonLeft, Right=InventoryButtonRight, Top=InventoryButtonTop

**DayZInventoryButtonTop** — AmorSerifPro-Bold | dayz_gui | Color=0
- Normal: Center=InventoryButtonCenter, Left=InventoryButtonLeft, Right=InventoryButtonRight, Top=InventoryButtonTop

**DayZInventoryButtonBottom** — AmorSerifPro-Bold | dayz_gui | Color=0
- Normal: Bottom=InventoryButtonBottom, Center=InventoryButtonCenter, Left=InventoryButtonLeft, Right=InventoryButtonRight

**DayZInventoryButtonRight** — AmorSerifPro-Bold | dayz_gui | Color=0
- Normal: Bottom=UIPanelHorizontalBottom, Center=UIPanelHorizontalCenter, Right=UIPanelHorizontalRight, Top=UIPanelHorizontalTop

**DayZInventoryButtonLeft** — AmorSerifPro-Bold | dayz_gui | Color=0
- Normal: Bottom=UIPanelHorizontalBottom, Center=UIPanelHorizontalCenter, Left=UIPanelHorizontalLeft, Top=UIPanelHorizontalTop

**DayZDefaultButton_DisabledState** — AmorSerifPro-Bold | dayz_additional_gui_unique | Color=0
- Normal/Disabled: 9-slice=ButtonDisabled_Default*
- Focus/Highlight: 9-slice=ButtonDisabled_Highlight*
- Pushed: 9-slice=ButtonDisabled_Disabled*

### XComboBoxWidget

**Default** — MetronBook | rover_imageset | FFFFFFFF
- Normal: LeftTop/RightTop/Right/RightBottom/LeftBottom/Left=XComboBlank, ArrowLeft=ArrowLeft, ArrowRight=ArrowRight
- Disabled: 9-slice*=XComboBlank, ArrowLeft=ArrowLeftBlack, ArrowRight=ArrowRightBlack
- Focus/Highlight: LeftTop/LeftBottom/Left=XComboLeft, Top/Bottom/Center=ButtonOver2, RightTop/Right/RightBottom=XComboRight, ArrowLeft=ArrowLeft, ArrowRight=ArrowRight

**debugUI** — gui/fonts/system | ccgui_enforce | FFFFFFFF
- Normal/Disabled/Focus/Highlight: ArrowLeft=XComboArrowLeft, ArrowRight=XComboArrowRight

### PanelWidget

**blank** — (no font) | dayz_gui | FFFFFFFF
- все пусто

**editor_quad** — (no font) | dayz_gui | FFFFFFFF
- Normal: рамка без Center (editorQuad*)

**editor_selection** — (no font) | dayz_gui | FFFFFFFF
- Normal: 9-slice=editorQuadSel*

**rover_sim_colorable** — (no font) | rover_imageset | FFFFFFFF
- Normal/Disabled: 9-slice*=WhitePixel

**rover_sim_blackbox** — (no font) | rover_imageset | FFFFFFFF
- Normal/Disabled: 9-slice*=BlackPixel

**rover_sim_black** — (no font) | rover_imageset | FFFFFFFF
- Normal/Disabled: 9-slice=SimBlack*

**rover_sim_black_2** — (no font) | rover_imageset | FFFFFFFF
- Normal/Disabled: 9-slice=SimBlack2*

**InventoryPanel** — (no font) | dayz_gui | FFFFFFFF
- Normal/Disabled: Center=InventoryGridCenter

**ColorablePanel** — MetronBook | dayz_gui | FFFFFFFF
- все пусто

**EditorPanel** — AmorSerifPro-Bold12 | dayz_gui | FFFFFFFF
- Normal: 9-slice=EditorPanel*

**editor_quad_dark** — AmorSerifPro-Bold12 | dayz_gui | FFFFFFFF
- Normal: 9-slice=menuButton*

**dashed** — AmorSerifPro-Bold12 | dayz_gui | FFFFFFFF
- Normal: 9-slice=dashed*

**Outline** — AmorSerifPro-Bold12 | dayz_gui | FFFFFFFF
- Normal: 9-slice=editorQuad*

**DayZDefaultPanel** — AmorSerifPro-Bold | dayz_gui | FFFFFFFF
- Normal: Bottom=DayZDefaultPanelBottom, Center=DayZDefaultPanelCorner, Left=DayZDefaultPanelLeft, Right=DayZDefaultPanelRight, Top=DayZDefaultPanelTop

**DayZDefaultPanelLeft** — AmorSerifPro-Bold | dayz_gui | FFFFFFFF
- Normal: как DayZDefaultPanel, но Right=DayZDefaultPanelCorner

**DayZDefaultPanelRight** — AmorSerifPro-Bold | dayz_gui | FFFFFFFF
- Normal: как DayZDefaultPanel, но Left=DayZDefaultPanelCorner

**DayZDefaultPanelTop** — AmorSerifPro-Bold | dayz_gui | FFFFFFFF
- Normal: как DayZDefaultPanel, но Bottom=DayZDefaultPanelCorner

**DayZDefaultPanelBottom** — AmorSerifPro-Bold | dayz_gui | FFFFFFFF
- Normal: как DayZDefaultPanel, но Top=DayZDefaultPanelCorner

**DayZDefaultPanelSides** — AmorSerifPro-Bold | dayz_gui | Color=11
- Normal: Center=DayZDefaultPanelCorner, Left=DayZDefaultPanelLeft, Right=DayZDefaultPanelRight

**ToolbarWidget** — AmorSerifPro-Bold | toolbar | Color=0
- Normal: Center=pixel, Top=top

**UIDefaultPanel** — AmorSerifPro-Bold | dayz_gui | Color=14
- Normal: Bottom=UIPanelHorizontalLeft, Center=UIPanelHorizontalCenter, Left=UIPanelHorizontalLeft, Right=UIPanelHorizontalRight, Top=UIPanelHorizontalTop

### SmartPanelWidget

**blank** — (no font) | dayz_gui | FFFFFFFF
- все пусто

**DayZDefaultPanel** — AmorSerifPro-Bold | dayz_gui | FFFFFFFF
- Normal: Bottom=DayZDefaultPanelBottom, Center/Overlay/LeftTop/RightTop/RightBottom=DayZDefaultPanelCorner, Left=DayZDefaultPanelLeft, LeftBottom=DayZDefaultPanelBottom, Right=DayZDefaultPanelRight, Top=DayZDefaultPanelTop
- Disabled: Center/Overlay=DayZDefaultPanelCorner

**DayZDefaultPanelLeft** — AmorSerifPro-Bold | dayz_gui | FFFFFFFF
- Normal: как DayZDefaultPanel, но Right/LeftBottom/LeftTop/RightBottom/RightTop=DayZDefaultPanelCorner
- Disabled: Center/Overlay=DayZDefaultPanelCorner

**DayZDefaultPanelRight** — AmorSerifPro-Bold | dayz_gui | FFFFFFFF
- Normal: как DayZDefaultPanelLeft, но Left=DayZDefaultPanelCorner, Right=DayZDefaultPanelRight
- Disabled: Center/Overlay=DayZDefaultPanelCorner

**DayZDefaultPanelTop** — AmorSerifPro-Bold | dayz_gui | FFFFFFFF
- Normal: Bottom/LeftBottom/RightBottom=DayZDefaultPanelCorner, остальное как DayZDefaultPanel
- Disabled: Center/Overlay=DayZDefaultPanelCorner

**DayZDefaultPanelBottom** — AmorSerifPro-Bold | dayz_gui | FFFFFFFF
- Normal: Top/LeftTop/RightTop=DayZDefaultPanelCorner, Bottom=DayZDefaultPanelBottom, остальное как DayZDefaultPanel
- Disabled: Center/Overlay=DayZDefaultPanelCorner

### ScrollWidget

**blank** — (no font) | dayz_gui | FFFFFFFF
- все пусто

**dashed** — AmorSerifPro-Bold12 | dayz_gui | FFFFFFFF
- Normal: 9-slice=dashed*

**Colorable** — AmorSerifPro-Bold58 | dayz_gui | Color=0
- Normal: Center=DayZDefaultPanelCorner

### GridSpacerWidget

**Colorable** — AmorSerifPro-Bold | rover_imageset | Color=0
- Normal/Disabled: 9-slice*=WhitePixel

**dashed** — AmorSerifPro-Bold12 | dayz_gui | FFFFFFFF
- Normal: 9-slice=dashed*

**DayZDefaultPanel** — AmorSerifPro-Bold | dayz_gui | FFFFFFFF
- Normal: Bottom/LeftBottom=DayZDefaultPanelBottom, Center/LeftTop/RightBottom/RightTop=DayZDefaultPanelCorner, Left=DayZDefaultPanelLeft, Right=DayZDefaultPanelRight, Top=DayZDefaultPanelTop
- Disabled: Center=DayZDefaultPanelCorner

**DayZDefaultPanelLeft/Right/Top/Bottom** — AmorSerifPro-Bold | dayz_gui | FFFFFFFF
- Варианты: открытая сторона заменена на DayZDefaultPanelCorner (аналогично PanelWidget)
- Disabled: Center=DayZDefaultPanelCorner

**DayZDefaultPanelSides** — AmorSerifPro-Bold | dayz_gui | Color=11
- Normal: Center=DayZDefaultPanelCorner, Left=DayZDefaultPanelLeft, Right=DayZDefaultPanelRight

**outline** — AmorSerifPro-Bold | dayz_gui | Color=0
- Normal: 9-slice=editorQuad*

**Empty** — AmorSerifPro-Bold | ccgui_enforce | Color=0
- все пусто

### WrapSpacerWidget

**Colorable** — AmorSerifPro-Bold | rover_imageset | Color=0
- Normal/Disabled: 9-slice*=WhitePixel

**dashed** — AmorSerifPro-Bold12 | dayz_gui | FFFFFFFF
- Normal: 9-slice=dashed*

**Outline** — AmorSerifPro-Bold12 | dayz_gui | FFFFFFFF
- Normal: 9-slice=editorQuad*

**OutlineFilled** — AmorSerifPro-Bold12 | dayz_gui | FFFFFFFF
- Normal: 9-slice рамка=DayZDefaultPanelCorner, Center=EditorPanelCenter

**DayZDefaultPanel/Left/Right/Top/Bottom** — AmorSerifPro-Bold | dayz_gui | FFFFFFFF
- Аналогично GridSpacerWidget: те же паттерны DayZDefaultPanel*

**DayZDefaultPanelSides** — AmorSerifPro-Bold | dayz_gui | Color=11
- Normal: Center=DayZDefaultPanelCorner, Left=DayZDefaultPanelLeft, Right=DayZDefaultPanelRight

**Empty** — AmorSerifPro-Bold | dayz_gui | Color=0
- все пусто

### GraphWidgets

BasicGraphWidget, RingBufferGraphWidget, TimeBasedGraphWidget — AmorSerifPro-Bold12 | ccgui_enforce | FFFFFFFF
TimeBasedGraphWithAxesWidget — Metron | ccgui_enforce | FFFFFFFF
Все имеют единственный стиль `Default` без непустых Item.

---

### Используемые ImageSet-файлы

| ImageSet | Назначение |
|----------|-----------|
| `ccgui_enforce` | Базовые элементы движка (листбоксы, чекбоксы, прогресс-бары) |
| `dayz_gui` | Основной UI DayZ (кнопки, панели, иконки, альфа-текстуры) |
| `rover_imageset` | Системные элементы (листбоксы Main-варианты, SimBlack, WhitePixel) |
| `dayz_additional_gui_unique` | Дополнительные уникальные элементы (ButtonDisabled_*) |
| `toolbar` | Панель инструментов редактора |
