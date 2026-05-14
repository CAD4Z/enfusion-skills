UI widget system. Source: `proto/enwidgets.c`

Widgets are loaded from `.layout` files via `WorkspaceWidget.CreateWidgets()` or created programmatically via `CreateWidget()`.

### Widget — base class

All widgets inherit from `Widget : Managed`.

**Hierarchy and lookup:**

| Method | Description |
|-------|----------|
| `GetParent()` | Parent widget |
| `GetChildren()` | First child |
| `GetSibling()` | Next on the same level |
| `AddChild(child)` | Add a child |
| `RemoveChild(child)` | Remove a child |
| `FindWidget("path.to.widget")` | Find by path |
| `FindAnyWidget("name")` | Find by name (recursive) |
| `FindAnyWidgetById(user_id)` | Find by userID |
| `Unlink()` | Destroy the widget and all of its children |

**Properties:**

| Method | Description |
|-------|----------|
| `GetName()` / `SetName(name)` | Name |
| `GetTypeName()` | Type name |
| `Show(show, immedUpdate)` | Show/hide |
| `IsVisible()` / `IsVisibleHierarchy()` | Visibility |
| `Enable(enable)` | Enable/disable |
| `SetPos(x, y)` / `GetPos(out x, out y)` | Position (relative) |
| `SetSize(w, h)` / `GetSize(out w, out h)` | Size (relative) |
| `SetScreenPos(x, y)` / `GetScreenPos(out x, out y)` | Screen position |
| `SetScreenSize(w, h)` / `GetScreenSize(out w, out h)` | Screen size |
| `SetColor(color)` / `GetColor()` | Color (ARGB int) |
| `SetAlpha(alpha)` / `GetAlpha()` | Transparency (0.0-1.0) |
| `SetRotation(roll, pitch, yaw)` / `GetRotation()` | Rotation |
| `GetFlags()` / `SetFlags(flags)` / `ClearFlags(flags)` | Flags |
| `GetSort()` / `SetSort(sort)` | Z-order |
| `SetUserData(data)` / `GetUserData(out data)` | User data |
| `SetUserID(id)` / `GetUserID()` | User ID |
| `SetHandler(handler)` | Event handler (`ScriptedWidgetEventHandler`) |
| `Update()` | Force update |
| `TranslateString(stringId)` | **static** — translate a localization string |

**WidgetFlags:** `VISIBLE`, `BLEND`, `ADDITIVE`, `SOURCEALPHA`, `STRETCH`, `CENTER`, `VCENTER`, `EXACTPOS`, `EXACTSIZE`, `HEXACTSIZE`, `VEXACTSIZE`, `NOFILTER`, `RALIGN`, `FLIPU`, `FLIPV`, `CUSTOMUV`, `IGNOREPOINTER`, `DISABLED`, `NOFOCUS`, `CLIPCHILDREN`, `DRAGGABLE`

### Widget types

**TextWidget** — single-line text:
`SetText(text)`, `SetTextFormat(fmt, p1..p9)`, `GetTextSize(out sx, out sy)`, `SetOutline(size, argb)`, `SetShadow(size, argb, opacity, offX, offY)`, `SetBold(bool)`, `SetItalic(bool)`, `SetTextExactSize(size)`, `SetTextProportion(val)`

**MultilineTextWidget** — multi-line text. Inherits from TextWidget.

**RichTextWidget** — text with images:
`GetContentHeight()`, `GetContentOffset()`, `SetContentOffset(offset)`, `GetNumLines()`, `GetLineWidth(line)`, `ElideText(line, maxWidth, str)`

**ImageWidget** — image:
`LoadImageFile(num, name, noCache)`, `SetImage(num)`, `GetImage()`, `GetImageSize(image, out sx, out sy)`, `SetUV(uv[4][2])`, `LoadMaskTexture(resource)`, `SetMaskProgress(value)`, `SetMaskTransitionWidth(value)`

**ButtonWidget** — button:
`GetState()`, `SetState(state)`, `SetText(text)`, `GetText(out text)`

**EditBoxWidget** — input field:
`GetText()`, `SetText(str)`

**CheckBoxWidget** — checkbox:
`IsChecked()`, `SetChecked(checked)`, `SetText(str)`

**SliderWidget** — slider:
`SetMinMax(min, max)`, `GetCurrent()`, `SetCurrent(val)`, `GetStep()`, `SetStep(step)`

**SimpleProgressBarWidget** / **ProgressBarWidget** — progress bar:
`GetMin()`, `GetMax()`, `GetCurrent()`, `SetCurrent(val)`

**XComboBoxWidget** — dropdown:
`AddItem(item)`, `ClearAll()`, `SetItem(idx, value)`, `RemoveItem(idx)`, `GetNumItems()`, `SetCurrentItem(n)`, `GetCurrentItem()`

**TextListboxWidget** — table:
`AddItem(text, data, column, row)`, `SetItem(pos, text, data, column)`, `GetItemText(row, col, out text)`, `GetItemData(row, col, out data)`, `GetNumItems()`, `SelectRow(row)`, `GetSelectedRow()`, `ClearItems()`

**ScrollWidget** — scrolling:
`GetVScrollPos()`, `VScrollToPos(pos)`, `VScrollToWidget(child)`, `GetHScrollPos()`, `HScrollStep(steps)`, `GetContentHeight()`, `GetContentWidth()`

**CanvasWidget** — drawing:
`DrawLine(x1, y1, x2, y2, width, color)`, `Clear()`

**RenderTargetWidget** — render-to-texture:
`SetRefresh(period, offset)`, `SetResolutionScale(x, y)`

**VideoWidget** — video player:
`Load(name, looping, startTime)`, `Unload()`, `Play()`, `Pause()`, `Stop()`, `SetTime(time, preload)`, `GetTime()`, `GetTotalTime()`, `IsPlaying()`, `GetState()`, `SetLooping(bool)`, `SetCallback(VideoCallback, fn)`

**SpacerWidget** / **GridSpacerWidget** / **WrapSpacerWidget** — layout containers.

**WorkspaceWidget** — root widget:
`CreateWidget(type, left, top, w, h, flags, color, sort, parent)`, `CreateWidgets(layout, parent)`

### Global functions

| Function | Description |
|---------|----------|
| `GetWidgetUnderCursor()` | Widget under the cursor |
| `GetDragWidget()` | Currently dragged widget |
| `CancelWidgetDragging()` | Cancel dragging |

### ScriptedWidgetEventHandler

Base handler class. Set via `widget.SetHandler(handler)`. Override event methods (OnClick, OnMouseEnter, OnChange, etc.) in a subclass.
