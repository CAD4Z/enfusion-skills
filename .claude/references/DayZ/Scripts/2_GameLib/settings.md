Система настроек с UI. Условие: `GAME_TEMPLATE`. Источник: `settings.c`

### Settings

Базовый класс настроек. Конструктор/деструктор `private`. Все методы `static`.

| Метод | Когда |
|-------|-------|
| `OnChange(string variableName)` | Изменение конкретной переменной |
| `OnAnyChange()` | Любое изменение |
| `OnLoad()` | Загрузка настроек |
| `OnSave()` | Сохранение |
| `OnReset()` | Сброс к значениям по умолчанию |
| `OnRevert()` | Откат изменений |
| `OnApply()` | Применение изменений |

### GameSettings

Наследует `Settings`. Пример использования атрибутов для настроек:

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

Поля с `[Attribute]` автоматически отображаются в `SettingsMenu`.

### SettingsMenu

Наследует `MenuBase`. UI для редактирования настроек.

| Метод | Описание |
|-------|----------|
| `AddSettings(typename settingsClass)` | Добавить класс настроек в меню |
| `Save()` | Сохранить |
| `Reset()` | Сбросить |
| `Revert()` | Откатить |
| `Apply()` | Применить |
| `Back()` | Назад |
