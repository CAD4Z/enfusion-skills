Система ввода: действия, контексты, слушатели. Условие: `GAME_TEMPLATE`. Источник: `inputmanager.c`

### InputTrigger

Режимы срабатывания слушателей действий.

| Значение | Описание |
|----------|----------|
| `UP` | Кнопка отпущена |
| `DOWN` | Кнопка нажата |
| `PRESSED` | Каждый тик пока кнопка зажата |
| `VALUE` | Каждый тик с текущим значением |

### ActionManager

Базовый менеджер действий. Поддерживает иерархию (parent).

| Метод | Возврат | Описание |
|-------|---------|----------|
| `RegisterAction(string actionName)` | `bool` | Зарегистрировать действие |
| `RegisterContext(string contextName)` | `bool` | Зарегистрировать контекст |
| `LocalValue(string actionName)` | `float` | Текущее значение действия |
| `GetActionTriggered(string actionName)` | `bool` | Было ли действие активировано |
| `ActivateAction(string actionName, int duration)` | `bool` | Программно активировать действие, `duration` мс (0 = один кадр) |
| `IsActionActive(string actionName)` | `bool` | Активно ли действие |
| `ActivateContext(string contextName, int duration)` | `bool` | Активировать контекст ввода |
| `IsContextActive(string contextName)` | `bool` | Активен ли контекст |
| `AddActionListener(string actionName, InputTrigger trigger, func callback)` | — | Подписать callback на действие с триггером |
| `SetContextDebug(string contextName, bool bDebug)` | — | Включить отладку контекста |
| `SetParent(ActionManager parent)` | — | Установить родительский менеджер |
| `SetDebug(bool bDebug)` | — | Включить отладку |

### InputManager

Наследует `ActionManager`. Глобальный синглтон, доступен через `g_Game.GetInputManager()`. Конструктор/деструктор `private`.

| Метод | Описание |
|-------|----------|
| `ResetAction(string actionName)` | Сбросить состояние действия |
| `SetCursorPosition(int x, int y)` | Установить позицию курсора |
| `RegisterActionManager(ActionManager pManager)` | Зарегистрировать дочерний менеджер |
| `UnregisterActionManager(ActionManager pManager)` | Отключить дочерний менеджер |
