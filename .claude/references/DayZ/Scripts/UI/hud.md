## HUD-элементы — виджеты без меню

Для элементов, которые должны быть на экране постоянно (не в меню), используется прямое создание виджетов и привязка к игровому циклу миссии.

Связанная документация:
- Ванильный HUD (IngameHud, HudDebug): `@.claude/references/DayZ/Scripts/api/5_Mission/hud.md`
- События виджетов: `@.claude/references/DayZ/Scripts/UI/events.md`
- Базовые паттерны работы с виджетами: `@.claude/references/DayZ/Scripts/UI/ui.md`

### Создание HUD-виджета

```c
class MyHudElement : ScriptedWidgetEventHandler
{
    protected Widget m_Root;
    protected TextWidget m_Text;

    void MyHudElement()
    {
        m_Root = GetGame().GetWorkspace().CreateWidgets("MyMod/gui/layouts/my_hud.layout");
        m_Text = TextWidget.Cast(m_Root.FindAnyWidget("StatusText"));
        m_Root.SetHandler(this);
    }

    void ~MyHudElement()
    {
        if (m_Root)
            m_Root.Unlink();   // уничтожить виджет и всех детей
    }

    void Show(bool visible)
    {
        m_Root.Show(visible);
    }

    void UpdateStatus(string text)
    {
        m_Text.SetText(text);
    }
}
```

### Интеграция с MissionGameplay

HUD-элементы живут столько, сколько живёт миссия. Создаются в `OnMissionStart` / `OnInit`, обновляются в `OnUpdate`:

```c
modded class MissionGameplay
{
    protected ref MyHudElement m_MyHud;

    override void OnMissionStart()
    {
        super.OnMissionStart();
        m_MyHud = new MyHudElement();
    }

    override void OnUpdate(float timeslice)
    {
        super.OnUpdate(timeslice);
        if (m_MyHud)
        {
            PlayerBase player = PlayerBase.Cast(GetGame().GetPlayer());
            if (player)
                m_MyHud.UpdateStatus("HP: " + player.GetHealth("", ""));
        }
    }

    override void OnMissionFinish()
    {
        m_MyHud = null;   // ref — деструктор вызовется автоматически
        super.OnMissionFinish();
    }
}
```

### Покадровое обновление через CallQueue

Альтернатива `OnUpdate` — регистрация в очереди отложенных вызовов:

```c
// однократный отложенный вызов через 1 секунду
GetGame().GetCallQueue(CALL_CATEGORY_GUI).CallLater(MyFunction, 1000, false);

// регулярный вызов каждые 500мс
GetGame().GetCallQueue(CALL_CATEGORY_GUI).CallLater(MyTickFunction, 500, true);

// остановка
GetGame().GetCallQueue(CALL_CATEGORY_GUI).Remove(MyTickFunction);
```

`CALL_CATEGORY_GUI` — очередь, привязанная к UI-потоку. Для HUD-элементов всегда использовать её, а не `CALL_CATEGORY_SYSTEM`.

### Взаимодействие с ванильным HUD

HUD-элементы поверх игрового мира сосуществуют с ванильным `IngameHud` (stats, quickbar, crosshair). Скрытие ванильного HUD при открытии кастомного UI:

```c
IngameHud hud = IngameHud.Cast(GetGame().GetMission().GetHud());
if (hud)
{
    hud.ShowHudUI(false);       // всё кроме quickbar
    hud.ShowQuickbarUI(false);  // quickbar
}
```

Детали API — см. `@.claude/references/DayZ/Scripts/api/5_Mission/hud.md`.

### Различия: HUD vs Menu

| Аспект | HUD-элемент | Меню (UIScriptedMenu) |
|--------|-------------|----------------------|
| Видимость | Постоянно на экране | Открывается/закрывается |
| Блокировка ввода | Нет | Да (input excludes) |
| Пауза игры | Нет | Обычно да |
| Курсор | Игровой crosshair | Курсор мыши |
| Жизненный цикл | Миссия | EnterScriptedMenu → Close |
| События виджетов | Через `SetHandler()` | Встроены в класс меню |

HUD-элемент — для отображения информации без прерывания игры. Меню — для взаимодействия, когда нужно остановить игровой процесс.
