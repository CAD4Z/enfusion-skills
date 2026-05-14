Main game class and world management. Inheritance: `Game` (2_GameLib) → `CGame` → `DayZGame`. Sources: `global/game.c`, `dayzgame.c`

Global instance: `g_Game`. Constant: `GAME_STORAGE_VERSION = 142`.

### CGame

Extends `Game` from 2_GameLib. Defines the DayZ-specific API: config, objects, profiles, networking.

#### Lifecycle (overridable)

| Method | When invoked |
|--------|--------------|
| `OnEvent(EventType eventTypeId, Param params)` | System event |
| `OnAfterCreate()` | After CGame instance is created |
| `OnInitialize()` → `bool` | Before the game loop. `true` = initialization in scripts |
| `OnUpdate(bool doSim, float timeslice)` | Every frame. `doSim=false` when paused |
| `OnPostUpdate(bool doSim, float timeslice)` | After entity simulation |
| `OnKeyPress(int key)` / `OnKeyRelease(int key)` | Key press/release (DIK code) |
| `OnMouseButtonPress(int button)` / `OnMouseButtonRelease(int button)` | Mouse click |
| `OnActivateMessage()` / `OnDeactivateMessage()` | Window focus (Windows) |
| `OnDeviceReset()` | Graphics device reset, reset script variables |
| `OnRPC(PlayerIdentity sender, Object target, int rpc_type, ParamsReadContext ctx)` | Incoming RPC. `target=NULL` → global RPC |

#### World and access (proto native)

| Method | Return | Description |
|--------|--------|-------------|
| `GetWorkspace()` | `WorkspaceWidget` | Root UI workspace |
| `GetLoadingWorkspace()` | `WorkspaceWidget` | Loading screen workspace |
| `GetWorld()` | `World` | Current world object |
| `GetPlayer()` | `DayZPlayer` | Local player |
| `GetPlayers(out array<Man> players)` | `void` | List of all players |
| `GetUIManager()` | `UIManager` | UI manager |
| `GetInput()` | `Input` | Input system |
| `GetSoundScene()` | `AbstractSoundScene` | Sound scene |
| `GetNoiseSystem()` | `NoiseSystem` | Noise system (for AI) |
| `GetCurrentCameraPosition()` | `vector` | Camera position |
| `GetCurrentCameraDirection()` | `vector` | Camera direction |

#### Objects (proto native)

| Method | Return | Description |
|--------|--------|-------------|
| `CreateObject(type, pos, create_local, init_ai, create_physics)` | `Object` | Create object by type |
| `CreateObjectEx(type, pos, iFlags, iRotation)` | `Object` | Create with ECE flags and rotation |
| `CreateStaticObjectUsingP3D(p3d, pos, ori, scale, createLocal)` | `Object` | Create static object from P3D |
| `ObjectDelete(obj)` | `void` | Delete object |
| `ObjectRelease(obj)` | `int` | Release object |
| `ObjectModelToWorld(obj, modelPos)` | `vector` | Model → world coordinates |
| `ObjectWorldToModel(obj, worldPos)` | `vector` | World → model coordinates |
| `ObjectGetSelectionPosition(obj, name)` | `vector` | Named selection position |
| `ObjectGetSelectionPositionMS(obj, name)` | `vector` | In model space |
| `ObjectGetSelectionPositionWS(obj, name)` | `vector` | In world space |
| `PreloadObject(type, distance)` | `bool` | Preload objects of type |
| `GetObjectsAtPosition(pos, radius, out objects, out proxyCargos)` | `void` | Objects in circle (2D) |
| `GetObjectsAtPosition3D(pos, radius, out objects, out proxyCargos)` | `void` | Objects in sphere (3D) |
| `IsObjectAccesible(item, player)` | `bool` | Access to cargo/attachments by distance |

#### Configuration (proto native)

Reading values from `configFile` / `missionConfigFile`. Path: classes separated by spaces (`"CfgVehicles AK74 scope"`).

| Method | Return | Description |
|--------|--------|-------------|
| `ConfigGetText(path, out value)` | `bool` | String |
| `ConfigGetTextRaw(path, out value)` | `bool` | String without localization (`$STR_` is not expanded) |
| `ConfigGetFloat(path)` | `float` | Floating-point number |
| `ConfigGetInt(path)` | `int` | Integer |
| `ConfigGetVector(path)` | `vector` | Vector |
| `ConfigGetTextArray(path, out values)` | `void` | Array of strings |
| `ConfigGetFloatArray(path, out values)` | `void` | Array of floats |
| `ConfigGetIntArray(path, out values)` | `void` | Array of ints |
| `ConfigGetType(path)` | `int` | Type: `CT_INT`, `CT_FLOAT`, `CT_STRING`, `CT_ARRAY`, `CT_CLASS` |
| `ConfigGetChildName(path, index, out name)` | `bool` | Subclass name by index |
| `ConfigGetBaseName(path, out base_name)` | `bool` | Base class name |
| `ConfigGetChildrenCount(path)` | `int` | Number of subclasses |
| `ConfigIsExisting(path)` | `bool` | Path exists |
| `ConfigGetFullPath(path, out full_path)` | `void` | Full path (array) |

#### Players and networking (proto native)

| Method | Description |
|--------|-------------|
| `CreatePlayer(identity, name, pos, radius, spec)` | Create player (server) |
| `SelectPlayer(identity, player)` | Assign controlled object |
| `SelectSpectator(identity, spectatorObjType, position)` | Create spectator |
| `UpdateSpectatorPosition(position)` | Update network bubble position |
| `DisconnectPlayer(identity, uid)` | Kick player (server) |
| `SendLogoutTime(player, time)` | Send logout screen to client |
| `GetPlayerNetworkIDByIdentityID(id, out low, out high)` | Player ID → network ID |
| `GetObjectByNetworkId(low, high)` | Network ID → object |
| `RegisterNetworkStaticObject(object)` | Enable replication for a static object |
| `AddToReconnectCache(identity)` | Add to reconnect cache (server) |
| `RemoveFromReconnectCache(uid)` | Remove from cache |

#### Connection (proto native)

| Method | Description |
|--------|-------------|
| `Connect(parent, ip, port, password)` | Connect to a server |
| `ConnectLastSession(parent, selectedCharacter)` | Reconnect |
| `DisconnectSession()` | Disconnect |
| `DisconnectSessionForce()` | Force disconnect |
| `GetHostAddress(out address, out port)` | Server address |
| `GetHostName()` | Server name |

#### Profile and system (proto native)

| Method | Description |
|--------|-------------|
| `GetProfileString(name, out value)` / `SetProfileString(name, value)` | Profile string |
| `GetProfileStringList(name, out values)` / `SetProfileStringList(name, values)` | Profile string array |
| `SaveProfile()` | Save profile to disk |
| `GetPlayerName(out name)` / `SetPlayerName(name)` | Player name |
| `CommandlineGetParam(name, out value)` | Command-line parameter |
| `CopyToClipboard(text)` / `CopyFromClipboard(out text)` | Clipboard |
| `StorageVersion(version)` | Set storage version |
| `LoadVersion()` / `SaveVersion()` | Current load/save version |
| `GetTickTime()` | Time since game start (sec) |
| `GetDayTime()` | In-game time of day (server) |
| `GetFps()` / `GetAvgFPS(n)` / `GetMinFPS(n)` / `GetMaxFPS(n)` | FPS stats |
| `RequestExit(code)` / `RequestRestart(code)` | Exit/restart |
| `IsAppActive()` | Window is focused |
| `AdminLog(text)` | Write to admin log |

#### Juncture (proto native, server)

Mechanism for locking items during network operations.

| Method | Description |
|--------|-------------|
| `AddInventoryJuncture(player, item, dst, test_dst_occupancy, timeout_ms)` | Create lock |
| `HasInventoryJunctureItem(item)` | Item is locked (any player) |
| `HasInventoryJuncture(player, item)` | Item is locked by a specific player |
| `HasInventoryJunctureDestination(player, dst)` | Destination is locked |
| `AddActionJuncture(player, item, timeout_ms)` | Lock for an action |
| `ExtendActionJuncture(player, item, timeout_ms)` | Extend the lock |
| `ClearJuncture(player, item)` | Release the lock |

### DayZGame

Inherits `CGame`. Manages loading states, modal screens, DayZ profiles.

#### States

```
DayZGameState: UNDEFINED, MAIN_MENU, JOINING, IN_GAME, CONNECTING
DayZLoadState: UNDEFINED, MAIN_MENU_START, MAIN_MENU_CONTROLLER_SELECT,
               MAIN_MENU_USER_SELECT, JOIN_START, JOIN_CONTROLLER_SELECT,
               JOIN_USER_SELECT, MISSION_START, MISSION_USER_SELECT
```

#### Projectile collisions

| Class | Description |
|-------|-------------|
| `ProjectileStoppedInfo` | Base: `GetSource()`, `GetPos()`, `GetInVelocity()`, `GetAmmoType()`, `GetProjectileDamage()` |
| `CollisionInfoBase` | + `GetSurfNormal()` |
| `ObjectCollisionInfo` | + `GetHitObj()`, `GetHitObjPos()`, `GetHitObjRot()`, `GetComponentIndex()` |
| `TerrainCollisionInfo` | + `GetIsWater()` |

#### CrashSoundSets

Static registry of collision sounds by hash.

| Method | Description |
|--------|-------------|
| `RegisterSoundSet(sound_set)` | Register a sound set |
| `GetSoundSetByHash(hash)` | Get by hash |

### World

Game world management. Access: `g_Game.GetWorld()`. Source: `global/world.c`

#### Time and date (proto native)

| Method | Description |
|--------|-------------|
| `GetDate(out y, out m, out d, out h, out min)` | Current in-game date |
| `SetDate(y, m, d, h, min)` | Set the date |
| `SetTimeMultiplier(mult)` | Time speed multiplier |

#### Geography (proto native)

| Method | Return | Description |
|--------|--------|-------------|
| `GetLatitude()` | `float` | Latitude (for sun calculation) |
| `GetLongitude()` | `float` | Longitude |
| `GetMoonIntensity()` | `float` | Moon intensity |
| `GetSunOrMoon()` | `float` | 0 = moon, 1 = sun |
| `IsNight()` | `bool` | Night |

#### Visibility (proto native)

| Method | Description |
|--------|-------------|
| `SetPreferredViewDistance(dist)` | Preferred view distance |
| `SetViewDistance(dist)` | Render distance |
| `SetObjectViewDistance(dist)` | Object distance |
| `GetEyeAccom()` | Current eye accommodation |
| `SetEyeAccom(value)` | Set accommodation |

#### Navigation (proto native)

| Method | Description |
|--------|-------------|
| `GetAIWorld()` | `AIWorld` object |
| `UpdatePathgraphDoorByAnimationSourceName(building, animSource)` | Update navmesh for a door |
| `MarkObjectForPathgraphUpdate(object)` | Mark an object for navmesh recalculation |

#### Sound and materials (proto native)

| Method | Description |
|--------|-------------|
| `GetMaterial(materialName)` | Get a material |
| `CheckSoundObstruction(source, pos1, pos2, geometry)` | Check sound obstruction |

#### Players (proto native)

| Method | Description |
|--------|-------------|
| `GetPlayerList(out array)` | List of players |
