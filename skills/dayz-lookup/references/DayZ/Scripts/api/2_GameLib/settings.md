Settings system with UI. Condition: `GAME_TEMPLATE`. Source: `settings.c`

### Settings

Base settings class. Constructor/destructor are `private`. All methods are `static`.

| Method | When |
|--------|------|
| `OnChange(string variableName)` | A specific variable changed |
| `OnAnyChange()` | Any change |
| `OnLoad()` | Settings loaded |
| `OnSave()` | Saved |
| `OnReset()` | Reset to defaults |
| `OnRevert()` | Changes reverted |
| `OnApply()` | Changes applied |

### GameSettings

Inherits `Settings`. Example of using attributes for settings:

```cpp
class GameSettings: Settings
{
    [Attribute("false", "checkbox", "Is debug mode enabled")]
    static bool Debug;

    override static void OnAnyChange()
    {
        g_Game.SetDebug(Debug);
    }
}
```

Fields with `[Attribute]` are automatically displayed in `SettingsMenu`.

### SettingsMenu

Inherits `MenuBase`. UI for editing settings.

| Method | Description |
|--------|-------------|
| `AddSettings(typename settingsClass)` | Add a settings class to the menu |
| `Save()` | Save |
| `Reset()` | Reset |
| `Revert()` | Revert |
| `Apply()` | Apply |
| `Back()` | Back |
