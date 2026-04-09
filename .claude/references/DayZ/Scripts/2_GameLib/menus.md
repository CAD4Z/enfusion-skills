Система меню и диалогов. Условие: `GAME_TEMPLATE`. Источник: `menumanager.c`

### DialogPriority

| Значение | Описание |
|----------|----------|
| `INFORMATIVE` | Информационное |
| `WARNING` | Предупреждение |
| `CRITICAL` | Критическое |

### DialogResult

| Значение |
|----------|
| `PENDING`, `OK`, `YES`, `NO`, `CANCEL` |

### MenuManager

Глобальный менеджер, доступен через `g_Game.GetMenuManager()`. Конструктор/деструктор `protected`.

| Метод | Возврат | Описание |
|-------|---------|----------|
| `OpenMenu(ScriptMenuPresetEnum preset, int userId, bool unique)` | `MenuBase` | Открыть меню по пресету |
| `OpenDialog(ScriptMenuPresetEnum preset, int priority, int userId, bool unique)` | `MenuBase` | Открыть диалог с приоритетом |
| `FindMenuByPreset(ScriptMenuPresetEnum preset)` | `MenuBase` | Найти открытое меню |
| `FindMenuByUserId(int userId)` | `MenuBase` | Найти по userId |
| `GetTopMenu()` | `MenuBase` | Верхнее меню в стеке |
| `IsAnyMenuOpen()` | `bool` | Есть ли открытые меню |
| `IsAnyDialogOpen()` | `bool` | Есть ли открытые диалоги |
| `CloseMenuByPreset(ScriptMenuPresetEnum preset)` | `bool` | Закрыть по пресету |
| `CloseMenuByUserId(int userId)` | `bool` | Закрыть по userId |
| `CloseMenu(MenuBase menu)` | `bool` | Закрыть конкретное меню |

### MenuBase

Базовый класс меню. Наследует `ScriptedWidgetEventHandler`. Конструктор/деструктор `protected`.

#### Proto методы

| Метод | Возврат | Описание |
|-------|---------|----------|
| `GetUserId()` | `int` | ID пользователя |
| `GetRootWidget()` | `Widget` | Корневой виджет меню |
| `BindItem(string menuItemName, func callback)` | `MenuBase` | Привязать callback к элементу меню |
| `SetLabel(string menuItemName, string text)` | `MenuBase` | Установить текст элемента |
| `GetItemWidget(string menuItemName)` | `Widget` | Получить виджет элемента |
| `GetManager()` | `MenuManager` | Менеджер-владелец |
| `Close()` | — | Закрыть меню |

#### Переопределяемые события

| Метод | Когда |
|-------|-------|
| `OnMenuInit()` | Инициализация |
| `OnMenuOpen()` | Открытие |
| `OnMenuClose()` | Закрытие |
| `OnMenuShow()` | Показ |
| `OnMenuHide()` | Скрытие |
| `OnMenuFocusGained()` | Получение фокуса |
| `OnMenuFocusLost()` | Потеря фокуса |
| `OnMenuUpdate(float tDelta)` | Обновление каждый кадр |
| `OnMenuItem(string menuItemName, bool changed, bool finished)` | Событие элемента меню |

### MenuBindAttribute

Атрибут для привязки методов к элементам меню по имени.

```cpp
[MenuBindAttribute("okButton")]
void OnOk() { Close(); }
```

### MessageBox

Простой диалог с кнопкой Ok. Наследует `MenuBase`.

### WorldEditorIngame

Только `PLATFORM_WINDOWS`. Методы: `LoadWorld(string path)` → `bool`, `SaveWorld()` → `bool`.
