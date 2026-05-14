Gameplay configuration, mods, spawners. Sources: `cfggameplaydatajson.c`, `cfggameplayhandler.c`, `modinfo.c`, `objectspawner.c`

### CfgGameplayHandler

Static gameplay configuration manager. Loads `cfggameplay.json`. Source: `cfggameplayhandler.c`

#### Lifecycle

| Method | Description |
|--------|-------------|
| `LoadData()` | Load JSON or use default values |
| `ValidateItems()` / `InitData()` | Validation and initialization |
| `SyncDataSend(identity)` | Send config to client (server) |
| `SyncDataSendEx(identity)` | Extended send |
| `OnRPC(target, ctx)` | Receive config from server (client) |

#### Main getters (static)

**Basic settings:**

| Method | Description |
|--------|-------------|
| `GetDisablePersonalLight()` | Disable personal light |
| `GetDisableBaseDamage()` | Disable damage to bases |
| `GetDisableContainerDamage()` | Disable damage to containers |
| `GetDisableRespawnDialog()` | Disable respawn dialog |

**Stamina:**

| Method | Description |
|--------|-------------|
| `GetStaminaMax()` | Max stamina |
| `GetStaminaKgToStaminaPercentPenalty()` | kg → % stamina penalty |
| `GetStaminaMinCap()` | Minimum threshold |
| `GetSprintStaminaModifierErc/Cro()` | Sprint modifier standing/crouched |

**Shock:**

| Method | Description |
|--------|-------------|
| `GetShockRefillSpeedConscious/Unconscious()` | Shock refill speed |

**Weather:**

| Method | Description |
|--------|-------------|
| `GetWeatherParameters()` | Weather parameters |

**World:**

| Method | Description |
|--------|-------------|
| `GetLightingConfig()` | Lighting configuration |
| `GetObjectSpawnersArr()` | Array of object spawners |
| `GetEnvironmentMinTemps()` / `GetEnvironmentMaxTemps()` | Temperature ranges |

### CfgGameplayJson

Data model of the JSON config. Source: `cfggameplaydatajson.c`

#### Structure

```
CfgGameplayJson
├── version: int
├── GeneralData
│   ├── disableBaseDamage, disableContainerDamage
│   └── disableRespawnDialog
├── PlayerData
│   ├── stamina (max, penalty, minCap, sprint modifiers)
│   ├── shock (refill speeds)
│   ├── movement (timeToStrafeJog/Sprint)
│   ├── drowning (enabled)
│   └── weaponObstruction (enabled)
├── WorldData
│   ├── lighting config
│   ├── objectSpawners[]
│   ├── environmentMinTemps[], environmentMaxTemps[]
│   └── wetnessWeightModifiers[]
├── BaseBuildingData
├── UIData
├── MapData
└── VehicleData
```

Each section is a descendant of `ITEM_DataBase` with methods `ValidateServer()`, `InitServer()`.

### ModInfo

Info about a mod/DLC. Proto native. Source: `modinfo.c`

#### Data (proto native)

| Method | Return | Description |
|--------|--------|-------------|
| `GetName()` | `string` | Mod name |
| `GetAuthor()` | `string` | Author |
| `GetVersion()` | `string` | Version |
| `GetPicture()` | `string` | Main image |
| `GetLogo()` / `GetLogoSmall()` / `GetLogoOver()` | `string` | Logos |
| `GetTooltip()` | `string` | Tooltip |
| `GetOverview()` | `string` | Description |
| `GetAction()` | `string` | Action URL |
| `GetDefault()` | `bool` | Default mod |
| `GetIsDLC()` | `bool` | Is DLC |
| `GetIsOwned()` | `bool` | Whether the player owns it |
| `GoToStore()` | `void` | Open the store |

#### Static

`GetDLCImage(name)` — texture by DLC name (`"badlands"`, `"frostline"`, etc.)

### ObjectSpawnerHandler

Spawning of static objects from JSON. Source: `objectspawner.c`

| Method | Description |
|--------|-------------|
| `SpawnObjects()` | Load and spawn all objects from JSON |
| `SpawnObject(item)` | Spawn a single object |
| `ValidatePath(path)` | Validate P3D path whitelist |

#### VALID_PATHS

Whitelist for models: plants, rocks per DLC (Chernarus, Enoch, Sakhal).

#### ITEM_SpawnerObject

| Field | Type | Description |
|-------|------|-------------|
| `name` | `string` | P3D path |
| `pos[3]` | `float` | XYZ position |
| `ypr[3]` | `float` | Yaw/Pitch/Roll |
| `scale` | `float` | Scale |
| `enableCEPersistency` | `bool` | Persistence via CE |
