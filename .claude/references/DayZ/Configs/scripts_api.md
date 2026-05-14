Reading configs from Enforce Script, global access — `g_Game`.
The path is built with spaces: `"CfgClass ClassName property"`.

| Method | Return | Description |
|--------|--------|-------------|
| `ConfigGetFloat(path)` | `float` | Floating-point numeric value |
| `ConfigGetInt(path)` | `int` | Integer value |
| `ConfigGetText(path, out value)` | `bool` | String value (returns success) |
| `ConfigGetVector(path)` | `vector` | Vector (x,y,z) |
| `ConfigGetTextArray(path, out values)` | `void` | String array |
| `ConfigGetTextArrayRaw(path, out values)` | `void` | String array without localization (`$STR_` is not translated) |
| `ConfigGetFloatArray(path, out values)` | `void` | float array |
| `ConfigGetIntArray(path, out values)` | `void` | int array |
| `ConfigGetType(path)` | `int` | Value type: `CT_INT`, `CT_FLOAT`, `CT_STRING`, `CT_ARRAY`, `CT_CLASS` |
| `ConfigGetChildrenCount(path)` | `int` | Number of subclasses |
| `ConfigGetChildName(path, index, out name)` | `bool` | Subclass name by index |
| `ConfigGetBaseName(path, out name)` | `bool` | Parent class name |
| `ConfigIsExisting(path)` | `bool` | Check whether the path exists |
| `ConfigGetFullPath(path, out array)` | `void` | Full inheritance chain |

Additionally for the server config:
| `ServerConfigGetInt(name)` | `int` | Value from serverDZ.cfg |

### Access through an object — Object

Relative to the specific object's class (no need to specify `CfgVehicles ClassName`):

| Method | Description |
|--------|-------------|
| `ConfigGetFloat(entry)` | float property of the object |
| `ConfigGetVector(entry)` | vector property |
| `ConfigGetBool(entry)` | bool (wrapper over ConfigGetInt == 1) |
| `ConfigGetTextArray(entry, out values)` | String array |
| `ConfigGetFloatArray(entry, out values)` | float array |
| `ConfigGetIntArray(entry, out values)` | int array |
| `ConfigIsExisting(entry)` | Existence check |

### Path constants

```cpp
const string CFG_VEHICLESPATH  = "CfgVehicles";
const string CFG_WEAPONSPATH   = "CfgWeapons";
const string CFG_MAGAZINESPATH = "CfgMagazines";
```

### Comprehensive example

```cpp
// Reading item properties by class name
string className = "AlarmClock_Green";

// float
float weight = g_Game.ConfigGetFloat("CfgVehicles " + className + " weight");

// int
int scope = g_Game.ConfigGetInt("CfgVehicles " + className + " scope");

// string
string model;
g_Game.ConfigGetText("CfgVehicles " + className + " model", model);

// string[] — string array
TStringArray slots = new TStringArray;
g_Game.ConfigGetTextArray("CfgVehicles " + className + " inventorySlot", slots);

// float[] — float array
TFloatArray size = new TFloatArray;
g_Game.ConfigGetFloatArray("CfgVehicles " + className + " itemSize", size);

// int[] — int array
TIntArray intValues = new TIntArray;
g_Game.ConfigGetIntArray("CfgVehicles " + className + " repairableWithKits", intValues);

// Check whether a property exists
bool hasAttachments = g_Game.ConfigIsExisting("CfgVehicles " + className + " attachments");

// Value type
int type = g_Game.ConfigGetType("CfgVehicles " + className + " weight");
// type == CT_FLOAT

// Iterating over subclasses
string dmgPath = "CfgVehicles " + className + " DamageSystem GlobalHealth";
int count = g_Game.ConfigGetChildrenCount(dmgPath);
for (int i = 0; i < count; i++)
{
    string childName;
    g_Game.ConfigGetChildName(dmgPath, i, childName);
    // childName == "Health"
}

// Base class name
string baseName;
g_Game.ConfigGetBaseName("CfgVehicles " + className, baseName);
// baseName == "AlarmClock_ColorBase"
```

### Reading through an object

```cpp
// When you already have a reference to an object — the path is relative
Object item = g_Game.CreateObject("AlarmClock_Green", pos);

float w = item.ConfigGetFloat("weight");
bool exists = item.ConfigIsExisting("inventorySlot");

TStringArray slotNames = new TStringArray;
item.ConfigGetTextArray("inventorySlot", slotNames);
```

### Determining the registry by class

```cpp
// An item may live in CfgVehicles, CfgWeapons or CfgMagazines
// Detection pattern:
string typeName = "Glock19";
string cfgPath;

if (g_Game.ConfigIsExisting(CFG_VEHICLESPATH + " " + typeName))
    cfgPath = CFG_VEHICLESPATH;
else if (g_Game.ConfigIsExisting(CFG_WEAPONSPATH + " " + typeName))
    cfgPath = CFG_WEAPONSPATH;
else if (g_Game.ConfigIsExisting(CFG_MAGAZINESPATH + " " + typeName))
    cfgPath = CFG_MAGAZINESPATH;

// cfgPath == "CfgWeapons"
```