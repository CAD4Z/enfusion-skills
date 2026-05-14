A mandatory class in every `config.cpp`. Registers the PBO in the engine's addon system and defines load dependencies.

### Structure

```cpp
class CfgPatches
{
    class MyAddonName           // unique addon name
    {
        units[] = {};           // entity classes (CfgVehicles) declared in this PBO
        weapons[] = {};         // weapon classes (CfgWeapons) declared in this PBO
        requiredVersion = 0.1;  // minimum engine version
        requiredAddons[] =      // dependencies — names of other CfgPatches
        {
            "DZ_Data"           // this addon loads BEFORE the current one
        };
    };
};
```

### Key fields

| Field | Type | Description |
|-------|------|-------------|
| `units[]` | string[] | Names of classes from CfgVehicles that this PBO declares |
| `weapons[]` | string[] | Names of classes from CfgWeapons that this PBO declares |
| `requiredVersion` | float | Minimum engine version |
| `requiredAddons[]` | string[] | Names of CfgPatches addons that this PBO depends on. Defines load order — all dependencies are loaded first |

### Example

```cpp
class CfgPatches
{
    class DZ_Example
    {
        units[] = { "Knife" };
        weapons[] = { "Glock19" };
        requiredVersion = 0.1;
        requiredAddons[] =
        {
            "DZ_Data",
            "DZ_Weapons_Melee",
            "DZ_Pistols"
        };
    };
};
```