Input system: actions, contexts, listeners. Condition: `GAME_TEMPLATE`. Source: `inputmanager.c`

### InputTrigger

Trigger modes for action listeners.

| Value | Description |
|-------|-------------|
| `UP` | Button released |
| `DOWN` | Button pressed |
| `PRESSED` | Every tick while the button is held |
| `VALUE` | Every tick with the current value |

### ActionManager

Base action manager. Supports a hierarchy (parent).

| Method | Return | Description |
|--------|--------|-------------|
| `RegisterAction(string actionName)` | `bool` | Register an action |
| `RegisterContext(string contextName)` | `bool` | Register a context |
| `LocalValue(string actionName)` | `float` | Current action value |
| `GetActionTriggered(string actionName)` | `bool` | Whether the action was triggered |
| `ActivateAction(string actionName, int duration)` | `bool` | Programmatically activate an action, `duration` ms (0 = one frame) |
| `IsActionActive(string actionName)` | `bool` | Whether the action is active |
| `ActivateContext(string contextName, int duration)` | `bool` | Activate input context |
| `IsContextActive(string contextName)` | `bool` | Whether the context is active |
| `AddActionListener(string actionName, InputTrigger trigger, func callback)` | — | Subscribe a callback to an action with a trigger |
| `SetContextDebug(string contextName, bool bDebug)` | — | Enable context debug |
| `SetParent(ActionManager parent)` | — | Set parent manager |
| `SetDebug(bool bDebug)` | — | Enable debug |

### InputManager

Inherits `ActionManager`. Global singleton, accessible via `g_Game.GetInputManager()`. Constructor/destructor are `private`.

| Method | Description |
|--------|-------------|
| `ResetAction(string actionName)` | Reset action state |
| `SetCursorPosition(int x, int y)` | Set cursor position |
| `RegisterActionManager(ActionManager pManager)` | Register a child manager |
| `UnregisterActionManager(ActionManager pManager)` | Unregister a child manager |
