## Layout-файлы (.layout) — формат

UI DayZ построен на `.layout` файлах — текстовых описаниях иерархии виджетов. Редактируются в Workbench (GUI Editor) или вручную. Загружаются в скриптах через `CreateWidgets()` / `CreateWidgetsFromLayout()`.

Связанная документация:
- Типы виджетов и специфичные свойства: `@.claude/references/DayZ/Layouts/.INDEX.md`
- Скриптовая привязка (`scriptclass`, `SetHandler`): `@.claude/references/DayZ/Scripts/UI/ui.md`
- Стили виджетов (свойство `style`): `@.claude/references/DayZ/Styles/styles.md`
- Imageset-атласы (свойство `image`): `@.claude/references/DayZ/Imagesets/imagesets.md`

Расположение: `gui/layouts/`

### Синтаксис

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

**Правила:**
- Корневой элемент — один виджет верхнего уровня
- Тип виджета записывается как `WidgetClass` (напр. `FrameWidgetClass`, `TextWidgetClass`)
- Имя виджета — уникальный идентификатор, используется для поиска через `FindAnyWidget("name")`
- Свойства — по одной на строку: `key value`
- Многословные ключи — в кавычках: `"text halign" center`
- Дочерние виджеты — внутри вложенных `{ }` после свойств родителя
- Отступы — пробелы (1 пробел на уровень в файлах игры)

### Иерархия наследования свойств

Каждый виджет наследует свойства от родительской группы. В Workbench группы отображаются как секции (синие заголовки).

```
Widget ─── базовые свойства всех виджетов
├── FrameWidget, ContentWidget, CanvasWidget
├── MapWidget, PlayerPreviewWidget
│
├─► UIWidget (+style, навигация фокуса)
│   ├── PanelWidget, SmartPanelWidget
│   ├── ButtonWidget (+switch, font, text_proportion)
│   ├── CheckBoxWidget (+text, checked)
│   ├── ThreeStateCheckboxWidget (+text, checked)
│   ├── XComboBoxWidget
│   │
│   ├─► Text (+text, font, цвет, outline, shadow, выравнивание)
│   │   ├── TextWidget
│   │   ├── MultilineTextWidget (+wrap)
│   │   ├── RichTextWidget (+wrap, condense whitespace, strip newlines)
│   │   └── EditBoxWidget
│   │
│   ├─► SpacerWidget (+Padding, Margin, Size To Content, content align)
│   │   ├── WrapSpacerWidget
│   │   ├── GridSpacerWidget (+Columns, Rows)
│   │   └── ScrollWidget (+Scrollbar H/V)
│   │
│   └─► SimpleProgressBarWidget (+min, max, current, vertical, flipped)
│       ├── ProgressBarWidget
│       └── SliderWidget (+step, marker thickness, fill in, draw marker, listen to input)
│
├── ImageWidget (+image, текстура, mode, mask, rotation, pivot)
├── VideoWidget (+video, mode, font, text color, outline)
├── ItemPreviewWidget (+force flip)
├── RenderTargetWidget (+camera, refresh, offset, scale)
└── RTTextureWidget (+render always, noclear, sRGB)
```

### Общие свойства (Widget)

Присутствуют у **всех** виджетов.

| Свойство | Тип | По умолчанию | Описание |
|----------|-----|-------------|----------|
| `visible` | bool | `1` | Видимость виджета. `0` скрывает вместе с детьми |
| `disabled` | bool | `0` | Отключает взаимодействие |
| `clipchildren` | bool | `1` | Обрезать дочерние виджеты по границам родителя |
| `inheritalpha` | bool | `0` | Наследовать прозрачность от родителя |
| `ignorepointer` | bool | `0` | Игнорировать события мыши |
| `ignoreglobally` | bool | `0` | Глобальное игнорирование указателя |
| `keepsafezone` | bool | `0` | Учитывать safe zone экрана (TV overscan) |
| `color` | RGBA | `255,255,255,255` | Цвет. В layout: `color R G B A` (0.0–1.0 на канал) |
| `scaled` | bool | `1` | Масштабировать px-значения под разрешение |
| `fixaspect` | enum | `none` | Сохранение пропорций |
| `priority` | int | `0` | Z-порядок отрисовки (больше = поверх) |
| `userID` | int | `0` | Пользовательский ID для `FindAnyWidgetById()` |
| `draggable` | bool | `0` | Разрешить перетаскивание |
| `scriptclass` | string | `""` | Имя скрипт-класса для привязки (`ScriptedWidgetEventHandler`) — см. `@.claude/references/DayZ/Scripts/UI/ui.md` |

**fixaspect — значения:**

| Значение | Описание |
|----------|----------|
| `none` | Без сохранения пропорций |
| `inside` | Вписать с сохранением пропорций (могут быть поля) |
| `outside` | Заполнить с сохранением пропорций (может обрезаться) |
| `fixwidth` | Фиксировать ширину, высота подстраивается |
| `true` / `false` | Алиасы для `inside` / `none` |

### Система позиционирования

Каждый виджет позиционируется **относительно родителя** через комбинацию привязки (align), режима координат (exact) и смещения (position/size).

#### Привязка (halign / valign)

Определяет точку привязки виджета внутри родителя.

**halign** — горизонтальная привязка:

| Значение | В layout-файле | Описание |
|----------|---------------|----------|
| Левый край | *(не указывается)* | По умолчанию — от левого края родителя |
| Центр | `center_ref` | Центрирование по горизонтали |
| Правый край | `right_ref` | От правого края родителя |

**valign** — вертикальная привязка:

| Значение | В layout-файле | Описание |
|----------|---------------|----------|
| Верхний край | *(не указывается)* | По умолчанию — от верхнего края |
| Центр | `center_ref` | Центрирование по вертикали |
| Нижний край | `bottom_ref` | От нижнего края родителя |

> В layout-файлах также встречаются значения без суффикса `_ref` (`center`, `right`, `left`, `top`, `bottom`).

#### Режим координат (exact-флаги)

Переключают интерпретацию `position` и `size` между относительным и абсолютным режимами. Горизонтальная и вертикальная оси настраиваются **независимо**.

| Свойство | `0` (относительный) | `1` (абсолютный) |
|----------|---------------------|-------------------|
| `hexactpos` | X позиция: 0.0–1.0 от ширины родителя | X позиция: в пикселях |
| `vexactpos` | Y позиция: 0.0–1.0 от высоты родителя | Y позиция: в пикселях |
| `hexactsize` | Ширина: 0.0–1.0 от ширины родителя | Ширина: в пикселях |
| `vexactsize` | Высота: 0.0–1.0 от высоты родителя | Высота: в пикселях |

**Пример — одна и та же кнопка в двух стилях:**

```
-- Относительные координаты: 50% ширины родителя, по центру
ButtonWidgetClass btn {
 position 0.25 0.1
 size 0.5 0.08
 hexactpos 0
 vexactpos 0
 hexactsize 0
 vexactsize 0
}

-- Абсолютные пиксели: 200px от левого края, 400x60px
ButtonWidgetClass btn {
 position 200 50
 size 400 60
 hexactpos 1
 vexactpos 1
 hexactsize 1
 vexactsize 1
}
```

Часто используется **смешанный режим** — например, ширина относительная (растягивается с окном), а высота абсолютная (фиксированная):

```
TextWidgetClass label {
 size 0.8 30
 hexactsize 0
 vexactsize 1
}
```

#### position / size

| Свойство | Формат | Описание |
|----------|--------|----------|
| `position` | `X Y` | Смещение от точки привязки |
| `size` | `W H` | Размер виджета |

Интерпретация значений зависит от exact-флагов (см. выше).

### Группа UIWidget

Добавляется к виджетам, поддерживающим стили и фокусную навигацию: `PanelWidget`, `ButtonWidget`, `CheckBoxWidget`, `TextWidget`, `SliderWidget`, `SpacerWidget` и др.

| Свойство | Тип | По умолчанию | Описание |
|----------|-----|-------------|----------|
| `style` | string | `Default` | Визуальный стиль из `.styles` файла |
| `"no focus"` | bool | `0` | Исключить из навигации фокуса |
| `"next left"` | string | `""` | Имя виджета при навигации влево |
| `"next right"` | string | `""` | Имя виджета при навигации вправо |
| `"next up"` | string | `""` | Имя виджета при навигации вверх |
| `"next down"` | string | `""` | Имя виджета при навигации вниз |

Навигация (`next *`) используется для gamepad/keyboard — задаёт какой виджет получит фокус при нажатии d-pad/стрелок.

### Группа Text

Добавляется к текстовым виджетам: `TextWidget`, `MultilineTextWidget`, `RichTextWidget`, `EditBoxWidget`.

| Свойство | Тип | По умолчанию | Описание |
|----------|-----|-------------|----------|
| `text` | string | `""` | Текст или ключ локализации (`#string_key`) |
| `font` | string | `""` | Путь к шрифту (`gui/fonts/sdf_MetronLight24`) |
| `"text color"` | RGBA | `255,255,255,255` | Цвет текста |
| `"text halign"` | enum | `left` | Горизонтальное выравнивание: `left`, `center`, `right` |
| `"text valign"` | enum | `top` | Вертикальное выравнивание: `center` |
| `"text offset"` | `X Y` | `0 0` | Смещение текста внутри виджета |
| `"exact text"` | bool | `0` | Использовать точный размер шрифта |
| `"exact text size"` | int | — | Размер шрифта в пикселях (при `"exact text" 1`) |
| `text_proportion` | float | — | Пропорция текста относительно размера виджета |
| `"size to text h"` | bool | `0` | Подогнать ширину виджета под текст |
| `"size to text v"` | bool | `0` | Подогнать высоту виджета под текст |
| `"outline size"` | float | `0` | Размер обводки текста |
| `"outline color"` | RGBA | `0,0,0,0` | Цвет обводки |
| `"shadow size"` | float | `0` | Размер тени |
| `"shadow color"` | RGBA | — | Цвет тени |
| `"shadow opacity"` | float | — | Непрозрачность тени |
| `"shadow offset"` | `X Y` | — | Смещение тени |
| `"text background"` | bool | `0` | Фон за текстом |
| `"background color"` | RGBA | `0,0,204` | Цвет фона текста |

### Группа SpacerWidget

Добавляется к контейнерам с автоматической раскладкой: `WrapSpacerWidget`, `GridSpacerWidget`, `ScrollWidget`.

| Свойство | Тип | По умолчанию | Описание |
|----------|-----|-------------|----------|
| `"Ignore invisible"` | bool | `1` | Не учитывать скрытые дочерние элементы в раскладке |
| `Padding` | int | `2` | Внутренний отступ (px) |
| `Margin` | int | `2` | Внешний отступ между дочерними элементами (px) |
| `"Size To Content H"` | bool | `0` | Подогнать ширину под содержимое |
| `"Size To Content V"` | bool | `0` | Подогнать высоту под содержимое |
| `content_halign` | enum | `left` | Горизонтальное выравнивание содержимого: `left`, `center`, `right` |
| `content_valign` | enum | `top` | Вертикальное выравнивание содержимого: `top`, `center`, `bottom` |

### Группа SimpleProgressBarWidget

Добавляется к прогресс-барам и слайдерам: `SimpleProgressBarWidget`, `ProgressBarWidget`, `SliderWidget`.

| Свойство | Тип | По умолчанию | Описание |
|----------|-----|-------------|----------|
| `minimum` | float | `0` | Минимальное значение |
| `maximum` | float | `100` | Максимальное значение |
| `current` | float | `50` | Текущее значение |
| `vertical` | bool | `0` | Вертикальная ориентация |
| `flipped` | bool | `0` | Инвертировать направление заполнения |

### Ссылки на ресурсы в layout-файлах

**Изображения из imageset:**
```
image0 "set:dayz_gui image:icon_refresh"
```
Формат: `set:<имя_imageset> image:<имя_изображения>`

**Текстуры напрямую:**
```
imageTexture "{GUID}path/to/texture.edds"
```

**Шрифты:**
```
font "gui/fonts/sdf_MetronLight24"
```

**Ключи локализации:**
```
text "#string_key_name"
```
Префикс `#` указывает на ключ из `.csv` таблиц локализации.
