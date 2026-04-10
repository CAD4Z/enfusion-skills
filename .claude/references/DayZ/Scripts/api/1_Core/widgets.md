UI система виджетов. Источник: `proto/enwidgets.c`

Виджеты загружаются из `.layout` файлов через `WorkspaceWidget.CreateWidgets()` или создаются программно через `CreateWidget()`.

### Widget — базовый класс

Все виджеты наследуют от `Widget : Managed`.

**Иерархия и поиск:**

| Метод | Описание |
|-------|----------|
| `GetParent()` | Родительский виджет |
| `GetChildren()` | Первый дочерний |
| `GetSibling()` | Следующий на том же уровне |
| `AddChild(child)` | Добавить дочерний |
| `RemoveChild(child)` | Удалить дочерний |
| `FindWidget("path.to.widget")` | Найти по пути |
| `FindAnyWidget("name")` | Найти по имени (рекурсивно) |
| `FindAnyWidgetById(user_id)` | Найти по userID |
| `Unlink()` | Уничтожить виджет и всех детей |

**Свойства:**

| Метод | Описание |
|-------|----------|
| `GetName()` / `SetName(name)` | Имя |
| `GetTypeName()` | Имя типа |
| `Show(show, immedUpdate)` | Показать/скрыть |
| `IsVisible()` / `IsVisibleHierarchy()` | Видимость |
| `Enable(enable)` | Включить/выключить |
| `SetPos(x, y)` / `GetPos(out x, out y)` | Позиция (относительная) |
| `SetSize(w, h)` / `GetSize(out w, out h)` | Размер (относительный) |
| `SetScreenPos(x, y)` / `GetScreenPos(out x, out y)` | Экранная позиция |
| `SetScreenSize(w, h)` / `GetScreenSize(out w, out h)` | Экранный размер |
| `SetColor(color)` / `GetColor()` | Цвет (ARGB int) |
| `SetAlpha(alpha)` / `GetAlpha()` | Прозрачность (0.0-1.0) |
| `SetRotation(roll, pitch, yaw)` / `GetRotation()` | Вращение |
| `GetFlags()` / `SetFlags(flags)` / `ClearFlags(flags)` | Флаги |
| `GetSort()` / `SetSort(sort)` | Z-порядок |
| `SetUserData(data)` / `GetUserData(out data)` | Пользовательские данные |
| `SetUserID(id)` / `GetUserID()` | Пользовательский ID |
| `SetHandler(handler)` | Обработчик событий (`ScriptedWidgetEventHandler`) |
| `Update()` | Принудительное обновление |
| `TranslateString(stringId)` | **static** — перевод строки локализации |

**WidgetFlags:** `VISIBLE`, `BLEND`, `ADDITIVE`, `SOURCEALPHA`, `STRETCH`, `CENTER`, `VCENTER`, `EXACTPOS`, `EXACTSIZE`, `HEXACTSIZE`, `VEXACTSIZE`, `NOFILTER`, `RALIGN`, `FLIPU`, `FLIPV`, `CUSTOMUV`, `IGNOREPOINTER`, `DISABLED`, `NOFOCUS`, `CLIPCHILDREN`, `DRAGGABLE`

### Типы виджетов

**TextWidget** — однострочный текст:
`SetText(text)`, `SetTextFormat(fmt, p1..p9)`, `GetTextSize(out sx, out sy)`, `SetOutline(size, argb)`, `SetShadow(size, argb, opacity, offX, offY)`, `SetBold(bool)`, `SetItalic(bool)`, `SetTextExactSize(size)`, `SetTextProportion(val)`

**MultilineTextWidget** — многострочный текст. Наследует TextWidget.

**RichTextWidget** — текст с изображениями:
`GetContentHeight()`, `GetContentOffset()`, `SetContentOffset(offset)`, `GetNumLines()`, `GetLineWidth(line)`, `ElideText(line, maxWidth, str)`

**ImageWidget** — изображение:
`LoadImageFile(num, name, noCache)`, `SetImage(num)`, `GetImage()`, `GetImageSize(image, out sx, out sy)`, `SetUV(uv[4][2])`, `LoadMaskTexture(resource)`, `SetMaskProgress(value)`, `SetMaskTransitionWidth(value)`

**ButtonWidget** — кнопка:
`GetState()`, `SetState(state)`, `SetText(text)`, `GetText(out text)`

**EditBoxWidget** — поле ввода:
`GetText()`, `SetText(str)`

**CheckBoxWidget** — флажок:
`IsChecked()`, `SetChecked(checked)`, `SetText(str)`

**SliderWidget** — ползунок:
`SetMinMax(min, max)`, `GetCurrent()`, `SetCurrent(val)`, `GetStep()`, `SetStep(step)`

**SimpleProgressBarWidget** / **ProgressBarWidget** — прогресс-бар:
`GetMin()`, `GetMax()`, `GetCurrent()`, `SetCurrent(val)`

**XComboBoxWidget** — выпадающий список:
`AddItem(item)`, `ClearAll()`, `SetItem(idx, value)`, `RemoveItem(idx)`, `GetNumItems()`, `SetCurrentItem(n)`, `GetCurrentItem()`

**TextListboxWidget** — таблица:
`AddItem(text, data, column, row)`, `SetItem(pos, text, data, column)`, `GetItemText(row, col, out text)`, `GetItemData(row, col, out data)`, `GetNumItems()`, `SelectRow(row)`, `GetSelectedRow()`, `ClearItems()`

**ScrollWidget** — прокрутка:
`GetVScrollPos()`, `VScrollToPos(pos)`, `VScrollToWidget(child)`, `GetHScrollPos()`, `HScrollStep(steps)`, `GetContentHeight()`, `GetContentWidth()`

**CanvasWidget** — рисование:
`DrawLine(x1, y1, x2, y2, width, color)`, `Clear()`

**RenderTargetWidget** — рендер в текстуру:
`SetRefresh(period, offset)`, `SetResolutionScale(x, y)`

**VideoWidget** — видеоплеер:
`Load(name, looping, startTime)`, `Unload()`, `Play()`, `Pause()`, `Stop()`, `SetTime(time, preload)`, `GetTime()`, `GetTotalTime()`, `IsPlaying()`, `GetState()`, `SetLooping(bool)`, `SetCallback(VideoCallback, fn)`

**SpacerWidget** / **GridSpacerWidget** / **WrapSpacerWidget** — лейаут-контейнеры.

**WorkspaceWidget** — корневой виджет:
`CreateWidget(type, left, top, w, h, flags, color, sort, parent)`, `CreateWidgets(layout, parent)`

### Глобальные функции

| Функция | Описание |
|---------|----------|
| `GetWidgetUnderCursor()` | Виджет под курсором |
| `GetDragWidget()` | Текущий перетаскиваемый виджет |
| `CancelWidgetDragging()` | Отменить перетаскивание |

### ScriptedWidgetEventHandler

Базовый класс обработчика. Устанавливается через `widget.SetHandler(handler)`. Переопределяйте методы событий (OnClick, OnMouseEnter, OnChange и т.п.) в наследнике.
