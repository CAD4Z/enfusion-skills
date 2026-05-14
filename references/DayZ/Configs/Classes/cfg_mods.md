Mandatory in PBOs that add or modify scripts, inputs or skeletons. Describes the mod and specifies which script modules to attach.

### Structure

```cpp
class CfgMods
{
    class MyMod
    {
        type = "mod";                                           // required field
        dir = "MyMod";                                          // mod directory
        inputs = "mods\mymod\inputs\inputs.xml";                // (opt.) custom inputs
        skeletonDefinitions = "mods\mymod\skeleton\skel.xml";   // (opt.) custom skeletons
        dependencies[] = { "Game" };                            // (opt.) class dependencies

        // Presentation (used in vanilla DLC addons; for mods — via mod.cpp)
        name = "My Mod";
        picture = "";
        logo = "";
        author = "";
        version = "";

        class defs
        {
            // Attaching scripts to engine modules
            class engineScriptModule        // 1_Core
            {
                value = "";                 // entry point (empty = default)
                files[] = { "MyMod/scripts/1_Core" };
            };
            class gameLibScriptModule       // 2_GameLib
            {
                value = "";
                files[] = { "MyMod/scripts/2_GameLib" };
            };
            class gameScriptModule          // 3_Game
            {
                value = "";                 // can be overridden: "CreateGameMod"
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

            // Optional: custom GUI resources
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

### Script modules

Only those that the mod actually modifies are defined.

The `value` field is the name of the entry-point function. If empty, the default is used. The `files[]` field contains paths to script directories/files that are compiled together with the module's original scripts.

> Further information: `references/DayZ/Scripts/api/INDEX.md`

### Example — vanilla DLC (Sakhal/Frostline)

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