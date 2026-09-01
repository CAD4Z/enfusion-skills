Main game loop class. Condition: `GAME_TEMPLATE`. Source: `gamelib.c`

DayZ inheritance: `Game` → `CGame` (3_Game) → `DayZGame` (3_Game). Global instance: `g_Game`.

### Game

#### Lifecycle (overridable)

| Method | When called |
|--------|-------------|
| `OnEvent(EventType eventTypeId, Param params)` | System event |
| `OnAfterInit()` | After full Game initialization |
| `OnUpdate(float timeslice)` | Every frame (world update) |
| `OnGameStart()` → `bool` | Before game starts, `true` = ok to start |
| `OnGameEnd()` | Before game ends |
| `ShowLoadingAnim()` | Create loading screen |
| `HideLoadingAnim()` | Hide loading screen |
| `UpdateLoadingAnim(float timeslice, float progress)` | Update loading, `progress` ∈ [0, 1] |

#### Spawn and lookup (proto native)

| Method | Return | Description |
|--------|--------|-------------|
| `SpawnEntity(typename typeName)` | `IEntity` | Create entity by type, calls `EOnInit` if `INIT` mask is set |
| `SpawnEntityTemplate(vobject templateResource)` | `IEntity` | Create entity from template with all components |
| `SpawnComponentTemplate(IEntity owner, vobject templateResource)` | `GenericComponent` | Create component from template and insert into entity |
| `FindEntity(string name)` | `IEntity` | Find entity by name |

#### World and system (proto native)

| Method | Return | Description |
|--------|--------|-------------|
| `SetWorldFile(string path, bool reload)` | `bool` | Load world from .ent file, `false` if not found |
| `GetWorldFile()` | `string` | Current world path |
| `GetWorldEntity()` | `GenericWorldEntity` | World entity (only in-game / play mode) |
| `GetWorkspace()` | `WorkspaceWidget` | Root UI workspace |
| `GetInputManager()` | `InputManager` | Input manager |
| `GetMenuManager()` | `MenuManager` | Menu manager |
| `GetTickCount()` | `int` | Tick counter |

#### Application control (proto native)

| Method | Description |
|--------|-------------|
| `RequestClose()` | Request to exit the game |
| `RequestReload()` | Request to reload the game (does not work in Workbench) |
| `GetBuildVersion()` | Build version |
| `GetBuildTime()` | Build date/time |

### GameLibInit()

Module initialization entry point. Empty in the template, overridden in specific projects.
