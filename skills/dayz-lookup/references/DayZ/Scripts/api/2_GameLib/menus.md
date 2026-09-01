Menu and dialog system. Condition: `GAME_TEMPLATE`. Source: `menumanager.c`

### DialogPriority

| Value | Description |
|-------|-------------|
| `INFORMATIVE` | Informational |
| `WARNING` | Warning |
| `CRITICAL` | Critical |

### DialogResult

| Value |
|-------|
| `PENDING`, `OK`, `YES`, `NO`, `CANCEL` |

### MenuManager

Global manager, accessible via `g_Game.GetMenuManager()`. Constructor/destructor are `protected`.

| Method | Return | Description |
|--------|--------|-------------|
| `OpenMenu(ScriptMenuPresetEnum preset, int userId, bool unique)` | `MenuBase` | Open a menu by preset |
| `OpenDialog(ScriptMenuPresetEnum preset, int priority, int userId, bool unique)` | `MenuBase` | Open a dialog with priority |
| `FindMenuByPreset(ScriptMenuPresetEnum preset)` | `MenuBase` | Find an open menu |
| `FindMenuByUserId(int userId)` | `MenuBase` | Find by userId |
| `GetTopMenu()` | `MenuBase` | Top menu in the stack |
| `IsAnyMenuOpen()` | `bool` | Whether any menus are open |
| `IsAnyDialogOpen()` | `bool` | Whether any dialogs are open |
| `CloseMenuByPreset(ScriptMenuPresetEnum preset)` | `bool` | Close by preset |
| `CloseMenuByUserId(int userId)` | `bool` | Close by userId |
| `CloseMenu(MenuBase menu)` | `bool` | Close a specific menu |

### MenuBase

Base menu class. Inherits `ScriptedWidgetEventHandler`. Constructor/destructor are `protected`.

#### Proto methods

| Method | Return | Description |
|--------|--------|-------------|
| `GetUserId()` | `int` | User ID |
| `GetRootWidget()` | `Widget` | Root menu widget |
| `BindItem(string menuItemName, func callback)` | `MenuBase` | Bind callback to a menu item |
| `SetLabel(string menuItemName, string text)` | `MenuBase` | Set item text |
| `GetItemWidget(string menuItemName)` | `Widget` | Get item widget |
| `GetManager()` | `MenuManager` | Owning manager |
| `Close()` | — | Close the menu |

#### Overridable events

| Method | When |
|--------|------|
| `OnMenuInit()` | Initialization |
| `OnMenuOpen()` | Opening |
| `OnMenuClose()` | Closing |
| `OnMenuShow()` | Showing |
| `OnMenuHide()` | Hiding |
| `OnMenuFocusGained()` | Focus gained |
| `OnMenuFocusLost()` | Focus lost |
| `OnMenuUpdate(float tDelta)` | Update every frame |
| `OnMenuItem(string menuItemName, bool changed, bool finished)` | Menu item event |

### MenuBindAttribute

Attribute for binding methods to menu items by name.

```cpp
[MenuBindAttribute("okButton")]
void OnOk() { Close(); }
```

### MessageBox

Simple dialog with an Ok button. Inherits `MenuBase`.

### WorldEditorIngame

Only `PLATFORM_WINDOWS`. Methods: `LoadWorld(string path)` → `bool`, `SaveWorld()` → `bool`.
