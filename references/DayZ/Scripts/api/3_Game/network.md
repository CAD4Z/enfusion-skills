Network communication: RPC, serialization, HTTP, Hive, events. Sources: `gameplay.c`, `syncevents.c`, `http/`, `hive/`

### ScriptRPC

Remote procedure call mechanism. Inherits `ParamsWriteContext`. Source: `gameplay.c`

| Method | Description |
|--------|-------------|
| `Reset()` | Clear write buffer |
| `Send(target, rpc_type, guaranteed, recipient)` | Send. `target=NULL` → global. `guaranteed=true` → TCP-like delivery. `recipient=NULL` → to all |

Data is written via `Write(value)` (inherited from `ParamsWriteContext`).

Receiving: `CGame.OnRPC(sender, target, rpc_type, ctx)` — `ctx` is a `ParamsReadContext`, read via `ctx.Read(value)`.

#### Pattern

```enforcescript
// Sending (client)
ScriptRPC rpc = new ScriptRPC();
rpc.Write(someInt);
rpc.Write(someString);
rpc.Send(target, MY_RPC_ID, true, null);

// Receiving (in OnRPC)
int val; string str;
ctx.Read(val);
ctx.Read(str);
```

### JsonSerializer

JSON serialization. Inherits `Serializer`. Source: `gameplay.c`

| Method | Description |
|--------|-------------|
| `WriteToString(variable, nice, out result)` | Object → JSON string. `nice=true` → formatted |
| `ReadFromString(variable, json, out error)` | JSON string → object |

### Auxiliary network contexts

| Class | Description |
|-------|-------------|
| `ScriptInputUserData` | User input for the network (inherits `ParamsWriteContext`) |
| `ScriptReadWriteContext` | Bidirectional context |
| `ScriptRemoteInputUserData` | Incoming input from a remote client |
| `ScriptJunctureData` | Juncture data |

### MeleeCombatData

Melee combat data. Proto native.

| Method | Description |
|--------|-------------|
| `GetModesCount()` | Number of modes |
| `GetModeName(index)` | Mode name |
| `GetAmmoTypeName(index)` | Mode's ammo type |
| `GetModeRange(index)` | Mode range |

### Selection

Geometric selection. Proto native.

| Method | Description |
|--------|-------------|
| `GetName()` | Selection name |
| `GetVertexCount()` | Number of vertices |
| `GetLODVertexIndex(vertex)` | Vertex index in LOD |

### SyncEvents

Static broadcast of network events. Source: `syncevents.c`

| Method | Description |
|--------|-------------|
| `SendPlayerList()` | Player list |
| `SendEntityKilled(victim, killer, source, isHeadshot)` | Entity death |
| `SendPlayerIgnatedFireplace(player, igniteType)` | Fire ignition |

### REST API

HTTP client. Source: `http/`

#### ERestResultState

```
EREST_EMPTY, EREST_PENDING, EREST_FEEDING, EREST_SUCCESS, EREST_PROCESSED,
EREST_ERROR, EREST_ERROR_CLIENTERROR, EREST_ERROR_SERVERERROR,
EREST_ERROR_APPERROR, EREST_ERROR_TIMEOUT, EREST_ERROR_UNKNOWN
```

#### RestApi

Context manager. Proto native.

#### RestContext

HTTP context. Proto native.

| Method | Description |
|--------|-------------|
| `GET(callback, url)` | Async GET |
| `GET_now(url, out result)` | Sync GET |
| `POST(callback, url, data)` | Async POST |
| `POST_now(url, data, out result)` | Sync POST |
| `FILE(callback, url, fileName)` | Download a file |
| `FILE_now(url, fileName)` | Sync download |
| `SetHeader(headerKey)` | Set HTTP header |
| `reset()` | Reset context |

#### RestCallback

Callback for asynchronous requests.

| Method | Description |
|--------|-------------|
| `OnSuccess(data, dataSize)` | Success |
| `OnError(errorCode)` | Error |
| `OnTimeout()` | Timeout |
| `OnFileCreated(fileName, dataSize)` | File created |

### Hive

Character persistence system. Source: `hive/`

#### Management (proto native)

| Method | Description |
|--------|-------------|
| `InitOnline(host)` | Connect to database |
| `InitOffline()` | Offline mode |
| `InitSandbox()` | Sandbox mode |
| `IsIdleMode()` | Idle mode |
| `SetShardID(id)` / `SetEnviroment(env)` | Server configuration |

#### Characters (proto native)

| Method | Description |
|--------|-------------|
| `CharacterSave(player)` | Save character |
| `CharacterKill(player)` | Record death |
| `CharacterExit(player)` | Record exit |
| `CharacterIsLoginPositionChanged(player)` | Position changed since last login |
| `CallUpdater()` | Call updater |

#### Global functions

`CreateHive()`, `DestroyHive()`, `GetHive()` — singleton management.

### ERPCs (key entries)

Defined in `enums/erpcs.c`. Extensive enum of RPC identifiers. Groups:

- **Debug**: `RPC_DAYZ_FORCE_WEATHER_*`, `RPC_CFG_GAMEPLAY_SYNC`, `RPC_UNDERGROUND_*`
- **Gameplay**: `RPC_PLAYER_STAT_*`, `RPC_SYNC_EVENT_*`, `RPC_ITEM_*`
- **UI**: `RPC_USER_ACTION_MESSAGE`, `RPC_SOFT_SKILLS_*`
- **Vehicles**: `RPC_EXPLODE_EVENT`

Used in `ScriptRPC.Send()` as `rpc_type`.
