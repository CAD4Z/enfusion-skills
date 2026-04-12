## Скриптовая UI-система — введение и связь Layout↔Script

UI DayZ строится на связке: `.layout` файл (структура виджетов) + Enforce Script (логика и события). Движок Enfusion предоставляет два механизма привязки скрипта к виджетам: `scriptclass` в layout и `SetHandler()` из кода.

### Связанная документация

**Структура UI:**
- Формат layout: `@.claude/references/DayZ/Layouts/format.md`
- Типы виджетов: `@.claude/references/DayZ/Layouts/.INDEX.md`
- Стили: `@.claude/references/DayZ/Styles/styles.md`
- Imagesets: `@.claude/references/DayZ/Imagesets/imagesets.md`

**Скриптовая часть:**
- `@.claude/references/DayZ/Scripts/UI/events.md` — ScriptedWidgetEventHandler, все события
- `@.claude/references/DayZ/Scripts/UI/menus.md` — создание меню (UIScriptedMenu)
- `@.claude/references/DayZ/Scripts/UI/hud.md` — HUD-элементы без меню

**API-справочники:**
- Widget API: `@.claude/references/DayZ/Scripts/api/1_Core/widgets.md`
- UIManager / UIScriptedMenu API: `@.claude/references/DayZ/Scripts/api/3_Game/ui.md`
- Реализации меню: `@.claude/references/DayZ/Scripts/api/5_Mission/menus.md`
- HUD: `@.claude/references/DayZ/Scripts/api/5_Mission/hud.md`

---

### scriptclass — декларативная привязка

В `.layout` файле свойство `scriptclass` указывает имя класса, который движок инстанцирует при загрузке layout. После создания движок вызывает `OnWidgetScriptInit(Widget w)` на экземпляре класса.

Layout:
```
FrameWidgetClass MyPanel {
 scriptclass "MyPanelScript"
 size 1 1
 {
  TextWidgetClass Title {
   text "Hello"
  }
 }
}
```

Script:
```c
class MyPanelScript : ScriptedWidgetEventHandler
{
    protected Widget m_Root;
    protected TextWidget m_Title;

    void OnWidgetScriptInit(Widget w)
    {
        m_Root = w;
        m_Root.SetHandler(this);
        m_Title = TextWidget.Cast(m_Root.FindAnyWidget("Title"));
    }

    override bool OnClick(Widget w, int x, int y, int button)
    {
        if (w == m_Title)
        {
            // обработка клика
            return true;
        }
        return false;
    }
}
```

### Параметры из layout

Поля с модификатором `reference` автоматически заполняются из `ScriptParamsClass`:

Layout:
```
EmbededWidgetClass MyWidget {
 scriptclass "MyWidgetScript"
 {
  ScriptParamsClass {
   Caption "Кнопка"
   MaxWidth 200
  }
 }
}
```

Script:
```c
class MyWidgetScript
{
    reference string Caption;
    reference int MaxWidth;

    void OnWidgetScriptInit(Widget w)
    {
        // Caption == "Кнопка", MaxWidth == 200
    }
}
```

### SetHandler() — программная привязка

Альтернативный способ — привязать обработчик событий к виджету из кода:

```c
class MyHandler : ScriptedWidgetEventHandler
{
    override bool OnMouseEnter(Widget w, int x, int y)
    {
        w.SetColor(ARGB(255, 255, 255, 0));
        return true;
    }

    override bool OnMouseLeave(Widget w, Widget enterW, int x, int y)
    {
        w.SetColor(ARGB(255, 255, 255, 255));
        return true;
    }
}

// где-то в инициализации:
Widget panel = root.FindAnyWidget("MyPanel");
panel.SetHandler(new MyHandler());
```

### Загрузка layout из кода

```c
// Создать виджеты из layout, добавить как дочерние к parent
Widget root = GetGame().GetWorkspace().CreateWidgets("gui/layouts/my_panel.layout", parentWidget);

// Поиск виджетов внутри загруженного дерева
TextWidget title = TextWidget.Cast(root.FindAnyWidget("Title"));
ButtonWidget btn = ButtonWidget.Cast(root.FindAnyWidget("MyButton"));
```

---

### Базовые паттерны

#### Поиск виджетов

```c
// По имени (рекурсивно в дереве) — основной способ
Widget w = root.FindAnyWidget("WidgetName");

// По пути (через точку)
Widget w = root.FindWidget("Panel.SubPanel.Button");

// По userID (для виджетов без уникальных имён)
Widget w = root.FindAnyWidgetById(42);

// Приведение типа — ОБЯЗАТЕЛЬНО для специфичных методов
TextWidget text = TextWidget.Cast(root.FindAnyWidget("Label"));
ButtonWidget btn = ButtonWidget.Cast(root.FindAnyWidget("MyBtn"));
```

`FindAnyWidget` возвращает `Widget` — для вызова методов конкретного типа (`SetText`, `IsChecked` и т.д.) требуется `Cast`.

#### Цвета

Цвет задаётся как ARGB int. Утилита:
```c
int color = ARGB(alpha, red, green, blue);   // каждый канал 0-255
widget.SetColor(color);
widget.SetAlpha(0.5);                         // 0.0-1.0
```

Палитра готовых констант — см. `@.claude/references/DayZ/Scripts/api/3_Game/ui.md` → Colors.

#### Позиционирование из кода

```c
// Относительные координаты (0.0–1.0 от родителя) — по умолчанию
widget.SetPos(0.5, 0.5);     // центр родителя
widget.SetSize(0.3, 0.1);    // 30% ширины, 10% высоты

// Абсолютные пиксели — нужно установить флаги
widget.SetFlags(WidgetFlags.EXACTPOS);
widget.SetFlags(WidgetFlags.EXACTSIZE);
widget.SetPos(100, 200);     // 100px, 200px
widget.SetSize(400, 60);     // 400x60 px
```

#### Видимость и активность

```c
widget.Show(true);             // показать/скрыть (рекурсивно для детей)
widget.IsVisible();
widget.Enable(false);          // отключить взаимодействие
widget.Unlink();               // уничтожить виджет и всех детей
```
