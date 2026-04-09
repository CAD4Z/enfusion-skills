Обязателен в PBO, которые добавляют или модифицируют скрипты, инпуты или скелеты. Описывает мод и указывает, какие скриптовые модули подключать.

### Структура

```cpp
class CfgMods
{
    class MyMod
    {
        type = "mod";                                           // обязательное поле
        dir = "MyMod";                                          // директория мода
        inputs = "mods\mymod\inputs\inputs.xml";                // (опц.) кастомные инпуты
        skeletonDefinitions = "mods\mymod\skeleton\skel.xml";   // (опц.) кастомные скелеты
        dependencies[] = { "Game" };                            // (опц.) зависимости классов

        // Презентация (используется в ванильных DLC-аддонах, для модов — через mod.cpp)
        name = "My Mod";
        picture = "";
        logo = "";
        author = "";
        version = "";

        class defs
        {
            // Подключение скриптов к модулям движка
            class engineScriptModule        // 1_Core
            {
                value = "";                 // точка входа (пусто = дефолтная)
                files[] = { "MyMod/scripts/1_Core" };
            };
            class gameLibScriptModule       // 2_GameLib
            {
                value = "";
                files[] = { "MyMod/scripts/2_GameLib" };
            };
            class gameScriptModule          // 3_Game
            {
                value = "";                 // можно переопределить: "CreateGameMod"
                files[] = { "MyMod/scripts/3_Game" };
            };
            class worldScriptModule         // 4_World
            {
                value = "";
                files[] = { "MyMod/scripts/4_World" };
            };
            class missionScriptModule       // 5_Mission
            {
                value = "";
                files[] = { "MyMod/scripts/5_Mission" };
            };

            // Опционально: кастомные GUI ресурсы
            class imageSets
            {
                files[] = { "MyMod/gui/imagesets/mod.imageset" };
            };
            class widgetStyles
            {
                files[] = { "MyMod/gui/looknfeel/mod.styles" };
            };
        };
    };
};
```

### Скриптовые модули

Определяются только те, которые мод фактически модифицирует.

Поле `value` — имя функции точки входа. Если пусто — используется дефолтная. Поле `files[]` — пути к директориям/файлам скриптов, которые компилируются вместе с оригинальными скриптами модуля.

> Доп. информация: `@.claude/references/DayZ/Scripts/.INDEX.md`

### Пример — ванильный DLC (Sakhal/Frostline)

```cpp
class CfgMods
{
    class sakhal
    {
        type = "mod";
        dir = "sakhal";
        appId = 2968040;
        name = "$STR_dlc_frostline_name";
        class defs
        {
            class worldScriptModule
            {
                value = "";
                files[] = { "DZ/data_sakhal/scripts/4_World" };
            };
        };
    };
};
```