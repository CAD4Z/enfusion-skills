## Styles-файлы (.styles) — визуальные стили виджетов

Файлы `.styles` определяют визуальное оформление UI-виджетов: шрифт, imageset, цвет и изображения для каждого состояния. Виджет ссылается на стиль через свойство `style` в `.layout` файле.

Связанная документация:
- Layout-система (свойство `style` виджета): `@.claude/references/DayZ/Layouts/format.md`
- ImageSet-атласы (источник Item-слотов): `@.claude/references/DayZ/Imagesets/imagesets.md`
- Каталог ванильных стилей `dayzwidgets.styles`: `@.claude/references/DayZ/Styles/catalog.md`
- Подключение в модах через `CfgMods.files[]`: `@.claude/references/DayZ/Configs/Classes/cfg_mods.md`

Расположение: `gui/looknfeel/*.styles`
Редактор: Workbench → Style Editor

### Формат (XML)

```xml
<WidgetStyles>
    <!-- Стиль без состояний (только шрифт/цвет) -->
    <Widget Name="TextWidget">
        <Style Name="Normal" Font="gui/fonts/MetronBook" ImageSet="" Color="4294967295" />
    </Widget>

    <!-- Стиль с состояниями и Item-слотами -->
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

**Структура:**
- `<Widget Name>` — тип виджета, к которому применяется стиль
- `<Style>` — именованный стиль с атрибутами Font, ImageSet, Color
- `<State>` — визуальное состояние (Normal, Focus, Disabled и т.д.)
- `<Item>` — слот изображения из ImageSet. `Image=""` = пусто (прозрачно)

**Атрибуты Style:**

| Атрибут | Описание |
|---------|----------|
| `Name` | Имя стиля. Указывается в layout: `style MyStyleName` |
| `Font` | Путь к шрифту (`gui/fonts/...`). Пустая строка = шрифт не задан |
| `ImageSet` | Имя imageset-файла для Item-слотов |
| `Color` | Цвет в формате ARGB uint32 (десятичное число) |

**Кодирование Color:**

| Значение | Hex | Описание |
|----------|-----|----------|
| `4294967295` | `0xFFFFFFFF` | Белый, полностью непрозрачный (по умолчанию) |
| `0` | `0x00000000` | Прозрачный чёрный |
| `17` | `0x00000011` | Почти прозрачный |
| `16` | `0x00000010` | Почти прозрачный |
| `20` | `0x00000014` | Почти прозрачный |

Формула: `Color = A*16777216 + R*65536 + G*256 + B` (ARGB, каждый канал 0–255).

### Item-слоты (паттерны)

Набор слотов фиксирован движком для каждого типа виджета. Изображения в слотах берутся из ImageSet стиля.

**Без слотов** — только Font/Color, без Item:
TextWidget, MultilineTextWidget, RichTextWidget, HtmlWidget, BasicGraphWidget, RingBufferGraphWidget, TimeBasedGraphWidget, TimeBasedGraphWithAxesWidget

**Highlight** (1 слот):
MultilineEditBoxWidget — `Highlight`

**CheckBox** (1 слот):
CheckBoxWidget, ThreeStateCheckboxWidget — `CheckBox`

**9-slice** (9 слотов) — масштабируемый фон из 9 частей:
```
LeftTop     | Top    | RightTop
Left        | Center | Right
LeftBottom  | Bottom | RightBottom
```
Виджеты: PanelWidget, EditBoxWidget, PasswordEditBoxWidget, ButtonWidget, ScrollWidget, GridSpacerWidget, WrapSpacerWidget

**9-slice + Overlay** (10 слотов) — 9-slice + слой поверх:
SmartPanelWidget — стандартный 9-slice + `Overlay`

**9-slice + Arrows** (11 слотов):
XComboBoxWidget — стандартный 9-slice + `ArrowLeft`, `ArrowRight`

**Body 9-slice + Title 9-slice** (18 слотов) — два 9-slice блока:
WindowWidget — стандартный 9-slice (тело) + `TitleLeftTop, TitleTop, TitleRightTop, TitleRight, TitleRightBottom, TitleBottom, TitleLeftBottom, TitleCenter, TitleLeft` (заголовок)

**Body 9-slice + Bar 9-slice** (18 слотов) — фон + полоса заполнения:
ProgressBarWidget, SimpleProgressBarWidget, SliderWidget — стандартный 9-slice (фон) + `BarLeftTop, BarTop, BarRightTop, BarRight, BarRightBottom, BarBottom, BarLeftBottom, BarCenter, BarLeft` (полоса)

**Listbox** (31 слот) — Header 9-slice + Title + Body + Scroll + Separators:
GenericListboxWidget, UniversalListboxWidget, ServerBrowserWidget, TextListboxWidget
```
Header: HeaderLeftTop, HeaderTopCenter, HeaderRightTop, HeaderRightCenter,
        HeaderRightBottom, HeaderBottomCenter, HeaderLeftBottom, HeaderLeftCenter, HeaderCenter
Title:  TitleLeftCenter, TitleCenter, TitleCenterSeparator, TitleRightCenter
With:   LeftTopWithTitle, RightTopWithTitle
Body:   LeftTop, TopCenter, RightTop, RightCenter, Center, LeftCenter,
        RightBottom, BottomCenter, LeftBottom
Scroll: ScrollBarTop, ScrollBarCenter, ScrollBarBottom
Extra:  TopSeparator, BottomSeparator, Separator, Highlight
```

### Состояния (States)

Набор состояний зависит от типа виджета:

| States | Виджеты |
|--------|---------|
| — (нет) | TextWidget, MultilineTextWidget, RichTextWidget, HtmlWidget |
| Normal | GraphWidgets |
| Normal, Disabled | PanelWidget, SmartPanelWidget, ScrollWidget, GridSpacerWidget, WrapSpacerWidget, ProgressBarWidget, SimpleProgressBarWidget, WindowWidget |
| Normal, Focus | MultilineEditBoxWidget |
| Normal, Focus, Disabled | EditBoxWidget, PasswordEditBoxWidget, SliderWidget |
| Normal, Disabled, Focus | GenericListboxWidget, UniversalListboxWidget, ServerBrowserWidget, TextListboxWidget |
| Normal, Disabled, Mark, Highlight | CheckBoxWidget |
| Checked, Crossed, Disabled, Empty, Highlight | ThreeStateCheckboxWidget |
| Normal, Disabled, Focus, Highlight | XComboBoxWidget |
| Normal, Pushed, Highlight, Focus, Disabled | ButtonWidget |

---

Полный каталог ванильных стилей (все значения из `dayzwidgets.styles`) — см. `@.claude/references/DayZ/Styles/catalog.md`.
