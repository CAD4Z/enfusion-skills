## UIScriptedMenu — создание меню

Основной способ создания полноэкранных UI — наследование от `UIScriptedMenu`. Класс является наследником `ScriptedWidgetEventHandler` — события виджетов обрабатываются прямо в методах меню.

Связанная документация:
- Базовый API: `@.claude/references/DayZ/Scripts/api/3_Game/ui.md`
- События виджетов: `@.claude/references/DayZ/Scripts/UI/events.md`
- Каталог ванильных меню: `@.claude/references/DayZ/Scripts/api/5_Mission/menus.md`

### Lifecycle

```
EnterScriptedMenu(MENU_ID)
    → конструктор
    → Init()              ← создать виджеты, вернуть корневой Widget
    → LockControls()      ← захват ввода
    → OnShow()            ← меню отображено
    → Update(timeslice)   ← каждый кадр (пока меню активно)
    → OnHide()            ← меню скрыто
    → UnlockControls()    ← отпустить ввод
    → Cleanup()           ← очистка ресурсов
    → деструктор
```

---

### Пошаговое создание кастомного меню

#### 1. Определить ID

В 3_Game `constants.c` или через modded:
```c
const int MENU_MY_CUSTOM = 1337;
```

#### 2. Создать класс меню

```c
class MyCustomMenu extends UIScriptedMenu
{
    protected Widget m_Root;
    protected ButtonWidget m_CloseBtn;
    protected TextWidget m_Label;

    override Widget Init()
    {
        m_Root = GetGame().GetWorkspace().CreateWidgets("MyMod/gui/layouts/my_menu.layout");
        m_CloseBtn = ButtonWidget.Cast(m_Root.FindAnyWidget("CloseButton"));
        m_Label = TextWidget.Cast(m_Root.FindAnyWidget("InfoLabel"));
        return m_Root;
    }

    override void OnShow()
    {
        super.OnShow();
        GetGame().GetMission().AddActiveInputExcludes({"menu"});
        GetGame().GetUIManager().ShowCursor(true);
    }

    override void OnHide()
    {
        super.OnHide();
        GetGame().GetMission().RemoveActiveInputExcludes({"menu"});
        GetGame().GetUIManager().ShowCursor(false);
    }

    override bool OnClick(Widget w, int x, int y, int button)
    {
        if (w == m_CloseBtn)
        {
            Close();
            return true;
        }
        return false;
    }

    override void Update(float timeslice)
    {
        super.Update(timeslice);
        // обновление каждый кадр
    }
}
```

#### 3. Зарегистрировать в фабрике

Override `MissionBase.CreateScriptedMenu`:
```c
modded class MissionBase
{
    override UIScriptedMenu CreateScriptedMenu(int id)
    {
        UIScriptedMenu menu = super.CreateScriptedMenu(id);
        if (!menu)
        {
            switch (id)
            {
                case MENU_MY_CUSTOM:
                    menu = new MyCustomMenu;
                    break;
            }
        }
        if (menu)
            menu.SetID(id);
        return menu;
    }
}
```

#### 4. Открыть / закрыть

```c
// Открыть
GetGame().GetUIManager().EnterScriptedMenu(MENU_MY_CUSTOM, null);

// Закрыть изнутри меню
Close();

// или через UIManager
GetGame().GetUIManager().Back();
```

---

### Обработка событий

События от всех виджетов layout'а приходят в меню автоматически. Первый параметр `w` — виджет-источник.

```c
override bool OnChange(Widget w, int x, int y, bool finished)
{
    if (w == m_Slider)
    {
        float val = SliderWidget.Cast(w).GetCurrent();
        m_Label.SetText(val.ToString());
        return true;
    }
    if (w == m_CheckBox)
    {
        bool checked = CheckBoxWidget.Cast(w).IsChecked();
        m_Panel.Show(checked);
        return true;
    }
    return false;
}
```

Полный список событий — см. `@.claude/references/DayZ/Scripts/UI/events.md`.

---

### Input — блокировка игрового ввода

Когда меню активно, оно должно блокировать игровой ввод чтобы клавиши не вызывали внутриигровые действия.

#### Input Excludes

Основной механизм — `AddActiveInputExcludes` / `RemoveActiveInputExcludes` на объекте Mission. Группы определены в `specific.xml`:

| Группа | Что блокирует |
|--------|---------------|
| `"menu"` | Полная блокировка игрового ввода |
| `"inventory"` | Блокировка слоёв, нужных для инвентаря |
| `"radialmenu"` | Блокировка для радиальных меню |
| `"map"` | Блокировка для карты |
| `"inspect"` | Блокировка для осмотра предмета |

```c
// При открытии (OnShow или конструктор):
GetGame().GetMission().AddActiveInputExcludes({"menu"});

// При закрытии (OnHide или деструктор) — ОБЯЗАТЕЛЬНО парно:
GetGame().GetMission().RemoveActiveInputExcludes({"menu"});
```

Несоблюдение парности = залипание ввода.

#### Курсор

```c
GetGame().GetUIManager().ShowCursor(true);   // показать (при открытии)
GetGame().GetUIManager().ShowCursor(false);  // скрыть (при закрытии)
```

#### Pause / Continue

Полноэкранные меню ставят игру на паузу:

```c
// В конструкторе или OnShow:
Mission mission = GetGame().GetMission();
if (mission)
    mission.Pause();

// В деструкторе или OnHide:
if (mission)
    mission.Continue();
```

#### Реакция на ESC / Back

Для обработки ESC/Back в меню — проверка на `IDC_CANCEL` или реакция на `UAUIBack` input action:

```c
override bool OnClick(Widget w, int x, int y, int button)
{
    if (w.GetUserID() == IDC_CANCEL)
    {
        Close();
        return true;
    }
    return false;
}
```

---

### Очистка ресурсов

При уничтожении меню всегда:
- Снять блокировку ввода: `RemoveActiveInputExcludes()`
- Вернуть курсор: `ShowCursor(false)`
- Снять паузу: `mission.Continue()`
- `Widget.Unlink()` для виджетов, созданных вручную (корневой виджет меню уничтожается автоматически)

Пропуск любого из этих шагов приводит к залипанию ввода, мёртвым виджетам или зависанию паузы.
