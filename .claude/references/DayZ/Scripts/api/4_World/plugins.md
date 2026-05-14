Plugin system — a service bus for game subsystems. Sources: `plugins/`

### Architecture

```
PluginBase               — plugin base class
PluginManager            — registry and lifecycle manager for all plugins
  g_Plugins              — global PluginManager singleton
```

Global access function: `GetPlugin(typename)` → `PluginBase`

### PluginBase

```
class PluginBase
```

| Method | Description |
|-------|----------|
| `OnInit()` | Initialization after creation |
| `OnUpdate(float delta_time)` | Update each frame (CALL_CATEGORY_GAMEPLAY) |
| `OnDestroy()` | Cleanup on destruction |
| `GetModuleName()` | Class name (for logging) |
| `Log(msg, label)` | Output via `Debug.Log` |

### PluginManager

Manages the lifecycle of all registered plugins.

#### Registration

```c
RegisterPlugin(className, regOnClient, regOnServer, regOnRelease=true)
RegisterPluginDiag(...)   // only with #define DIAG_DEVELOPER
RegisterPluginDebug(...)  // only when IsDebug()
```

Plugin load order (from `Init()`):

| Plugin | Client | Server | Type |
|--------|--------|--------|-----|
| `PluginHorticulture` | ✓ | ✓ | Release |
| `PluginRepairing` | ✓ | ✓ | Release |
| `PluginPlayerStatus` | ✓ | ✓ | Release |
| `PluginMessageManager` | ✓ | ✓ | Release |
| `PluginLifespan` | ✓ | ✓ | Release |
| `PluginVariables` | ✓ | ✓ | Release |
| `PluginObjectsInteractionManager` | — | ✓ | Release |
| `PluginRecipesManager` | ✓ | ✓ | Release |
| `PluginTransmissionAgents` | ✓ | ✓ | Release |
| `PluginConfigEmotesProfile` | ✓ | ✓ | Release |
| `PluginPresenceNotifier` | ✓ | — | Release |
| `PluginAdminLog` | — | ✓ | Release |
| `PluginKeyBinding` | ✓ | ✓* | Diag |
| `PluginDeveloper` | ✓ | ✓ | Diag |
| `PluginDeveloperSync` | ✓ | ✓ | Diag |
| `PluginDiagMenuClient` | ✓ | — | Diag |
| `PluginDiagMenuServer` | — | ✓ | Diag |
| `PluginInventoryDebug` | ✓ | ✓ | Debug+Diag |
| `PluginSceneManager` | ✓ | ✓ | Debug |
| `PluginDayzPlayerDebug` | ✓ | ✓ | Debug |
| `PluginCameraTools` | ✓ | ✓ | Debug |

(*NO_GUI: client only)

#### Lifecycle

```
PluginManagerInit()
  → g_Plugins = new PluginManager
  → Init()     — registers plugins
  → PluginsInit() — instance creation + OnInit()

MainOnUpdate(dt) — called every frame, updates all plugins
PluginManagerDelete() — destructor for all plugins
```

#### API

```c
PluginManager GetPluginManager()
PluginBase    GetPlugin(typename plugin_type)         // with diagnostics
PluginBase    GetPluginSafe(typename plugin_type)     // without diagnostics
bool          IsModuleExist(typename plugin_type)
bool          IsPluginManagerExists()
```

---

### PluginDeveloper

```
class PluginDeveloper extends PluginBase
```

Developer tooling: teleport, free camera, item spawning, console.

```c
static PluginDeveloper GetInstance()  // shortcut
```

#### Capabilities

| Method | Description |
|-------|----------|
| `TeleportAtCursor()` | Teleport the player under the cursor |
| `Teleport(player, pos)` | Teleport to a position |
| `SetDirection(player, dir)` | Set player heading |
| `ToggleFreeCamera()` | Toggle free camera (with teleport) |
| `ToggleFreeCameraBackPos()` | Toggle free camera (no teleport) |
| `IsEnabledFreeCamera()` | Free-camera state |
| `PrintLogClient(msg)` | Output to Script Console |
| `SendServerLogToClient(msg)` | Broadcast a server log to all clients |

#### RPC handling (only under `#ifdef DIAG_DEVELOPER`)

| RPC | Description |
|-----|----------|
| `DEV_RPC_SPAWN_ITEM_ON_GROUND` | Spawn an item on the ground |
| `DEV_RPC_SPAWN_ITEM_ON_GROUND_PATTERN_GRID` | Spawn items in a grid pattern |
| `DEV_RPC_SPAWN_ITEM_ON_CURSOR` | Spawn along the cursor direction |
| `DEV_RPC_SPAWN_ITEM_IN_INVENTORY` | Spawn into the inventory |
| `DEV_RPC_CLEAR_INV` | Clear the inventory |
| `DEV_RPC_SPAWN_PRESET` | Spawn an item preset |
| `DEV_RPC_SET_TIME` | Set game time |

`DevSpawnItemParams` = `Param7<EntityAI, string, float, float, bool, string, FindInventoryLocationType>` (target, item_name, health, quantity, special, presetName, locationType)

---

### PluginDiagMenu

```
class PluginDiagMenu extends PluginBase
```

Registers the diagnostic menu (`DiagMenu`). Only under `#ifdef DIAG_DEVELOPER`.

Split into:
- `PluginDiagMenuClient` — client only
- `PluginDiagMenuServer` — server only

#### Menu structure

```
DiagMenuIDs.SCRIPTS_MENU  ("Script")
  ├── VEHICLES          — Vehicle debug output, Crash log, Flip context
  ├── INVENTORY_MENU    — Inventory
  ├── ...               — and other submenus
  └── MODDED_MENU       — For mods (PluginDiagMenuModding)
```

#### For mods

`PluginDiagMenuModding` — a separate, isolated menu for mods that does not affect vanilla diagnostics. Mods are encouraged to use this rather than overriding vanilla files.

---

### PluginConfigHandler

```
class PluginConfigHandler extends PluginFileHandler
```

Parser/serializer for the user config file (`CFG_FILE_USER_PROFILE`). Data is represented as `array<ref CfgParam>`.

#### API

| Method | Description |
|-------|----------|
| `LoadConfigFile()` | Load the file into `m_CfgParams` |
| `SaveConfigToFile()` | Serialize `m_CfgParams` and write |
| `GetParamByName(name, type)` | Find a parameter (creates if missing) |
| `GetAllParams()` | All parameters |
| `ParamExist(name)` | Check existence |
| `RemoveParamByName(name)` | Remove a parameter |
| `RenameParam(name, new_name)` | Rename |

Supported types: `CFG_TYPE_STRING`, `CFG_TYPE_INT`, `CFG_TYPE_FLOAT`, `CFG_TYPE_BOOL`, `CFG_TYPE_ARRAY`, `CFG_TYPE_PARAM`

File format: `name=value` or `name={val1,val2}`. Parser: `ParseText(string)` — type is inferred from context.

---

### PluginLocalProfile

```
class PluginLocalProfile extends PluginFileHandler
```

Stores user settings in a profile file as several maps:

```
m_ConfigParams              : map<string, string>                     — simple values
m_ConfigParamsArray         : map<string, TStringArray>               — string arrays
m_ConfigParamsInArray       : map<string, map<string, string>>        — parameters inside a single array
m_ConfigParamsArrayInArray  : map<string, array<map<string, string>>> — array of objects
```

#### API

| Method | Description |
|-------|----------|
| `GetParameterString/Int/Float/Bool(name)` | Read with auto-create if missing |
| `SetParameterString/Int/Float/Bool(name, value, saveInFile)` | Write |
| `GetParameterArray(name)` | String array |
| `SetParameterArray(name, value)` | Write an array |
| `GetSubParameterInArrayString(param, idx, subParam)` | Element of a nested array |
| `SetSubParameterInArray(param, idx, subParam, value)` | Write into a nested array |
| `RemoveParameter(name)` / `RemoveParameterArray(name)` | Remove |
| `RenameParameter(old, new)` / `RenameParameterArray(old, new)` | Rename |
| `LoadConfigFile()` | Parse the profile file |
| `SaveConfigToFile()` | Serialize and write |

File format: `param_name = value` or `param_name = {val1,val2}` or `param_name = {{k=v},{k=v}}`.
