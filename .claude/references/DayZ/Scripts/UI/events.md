## ScriptedWidgetEventHandler — события виджетов

Базовый класс обработчика событий виджетов. Привязывается через `Widget.SetHandler(handler)` или через `scriptclass` в layout (см. `@.claude/references/DayZ/Scripts/UI/ui.md`).

Все методы возвращают `bool`:
- `true` = событие обработано (не передаётся дальше по иерархии)
- `false` = пропустить (событие поднимется к родителю)

Override в наследниках только те методы, которые нужны.

### Мышь

| Метод | Когда срабатывает |
|-------|-------------------|
| `OnClick(Widget w, int x, int y, int button)` | Клик (нажатие+отпускание). `button`: 0=ЛКМ, 1=ПКМ, 2=СКМ |
| `OnDoubleClick(Widget w, int x, int y, int button)` | Двойной клик |
| `OnMouseButtonDown(Widget w, int x, int y, int button)` | Кнопка мыши нажата |
| `OnMouseButtonUp(Widget w, int x, int y, int button)` | Кнопка мыши отпущена |
| `OnMouseWheel(Widget w, int x, int y, int wheel)` | Колёсико. `wheel` > 0 = вверх, < 0 = вниз |
| `OnMouseEnter(Widget w, int x, int y)` | Курсор вошёл в область виджета |
| `OnMouseLeave(Widget w, Widget enterW, int x, int y)` | Курсор покинул область. `enterW` = виджет, в который перешёл курсор |

### Фокус

| Метод | Когда срабатывает |
|-------|-------------------|
| `OnFocus(Widget w, int x, int y)` | Виджет получил фокус (клик мыши или gamepad-навигация) |
| `OnFocusLost(Widget w, int x, int y)` | Виджет потерял фокус |
| `OnSelect(Widget w, int x, int y)` | Выбор элемента (специфично для списков) |
| `OnItemSelected(Widget w, int x, int y, int row, int column, int oldRow, int oldColumn)` | Выбор элемента в таблице/списке с позицией |

### Клавиатура и геймпад

| Метод | Когда срабатывает |
|-------|-------------------|
| `OnKeyDown(Widget w, int x, int y, int key)` | Клавиша нажата. `key` — код клавиши (KeyCode) |
| `OnKeyUp(Widget w, int x, int y, int key)` | Клавиша отпущена |
| `OnKeyPress(Widget w, int x, int y, int key)` | Клавиша нажата (с учётом repeat) |
| `OnController(Widget w, int control, int value)` | Событие геймпада |

### Drag & Drop

Для работы drag виджет должен иметь `draggable 1` в layout.

| Метод | Когда срабатывает |
|-------|-------------------|
| `OnDrag(Widget w, int x, int y)` | Начало перетаскивания виджета |
| `OnDragging(Widget w, int x, int y, Widget reciever)` | Процесс перетаскивания. `w` = перетаскиваемый, `reciever` = виджет под курсором |
| `OnDraggingOver(Widget w, int x, int y, Widget reciever)` | Перетаскиваемый виджет находится над `reciever` |
| `OnDrop(Widget w, int x, int y, Widget reciever)` | Отпускание. `w` = что бросили, `reciever` = куда |
| `OnDropReceived(Widget w, int x, int y, Widget reciever)` | Виджет `w` принял drop от `reciever` |

### Изменение и структура

| Метод | Когда срабатывает |
|-------|-------------------|
| `OnChange(Widget w, int x, int y, bool finished)` | Значение виджета изменилось (EditBox, Slider, CheckBox). `finished` = true при завершении ввода |
| `OnResize(Widget w, int x, int y)` | Размер виджета изменился |
| `OnChildAdd(Widget w, Widget child)` | Добавлен дочерний виджет |
| `OnChildRemove(Widget w, Widget child)` | Удалён дочерний виджет |
| `OnUpdate(Widget w)` | Вызывается при `Widget.Update()` |

### Системные

| Метод | Когда срабатывает |
|-------|-------------------|
| `OnModalResult(Widget w, int x, int y, int code, int result)` | Результат модального диалога |
| `OnEvent(EventType eventType, Widget target, int parameter0, int parameter1)` | Общее системное событие (resize экрана и др.) |

---

### Пример — типичный обработчик

```c
class MyHandler : ScriptedWidgetEventHandler
{
    override bool OnMouseEnter(Widget w, int x, int y)
    {
        w.SetColor(ARGB(255, 255, 255, 0));
        return true;
    }

    override bool OnClick(Widget w, int x, int y, int button)
    {
        if (button == 0)   // ЛКМ
        {
            Print("Clicked: " + w.GetName());
            return true;
        }
        return false;
    }

    override bool OnChange(Widget w, int x, int y, bool finished)
    {
        SliderWidget slider = SliderWidget.Cast(w);
        if (slider && finished)
        {
            Print("Slider final value: " + slider.GetCurrent());
        }
        return true;
    }
}
```

### Обработка событий в UIScriptedMenu

Класс `UIScriptedMenu` сам является наследником `ScriptedWidgetEventHandler` — override методов событий производится напрямую в меню, события от всех виджетов layout'а приходят автоматически. Первый параметр `w` — виджет-источник. См. `@.claude/references/DayZ/Scripts/UI/menus.md`.
