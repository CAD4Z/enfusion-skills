AI infrastructure: navigation, groups, sensing. The foundation on which all AI entities operate.

The entire infrastructure is **proto native**. Scripts only call and configure it — all processing happens in C++.

### Navigation (NavMesh)

The world uses a precomputed navigation mesh (NavMesh). Access: `g_Game.GetWorld().GetAIWorld()`.

#### Navmesh queries

Three operations, each accepting a `PGFilter` for polygon filtering:

- **FindPath(from, to, filter, out waypoints)** — path search. Returns an array of waypoints including the start and end positions
- **RaycastNavMesh(from, to, filter, out hitPos, out hitNormal)** — ray along the navmesh. `true` = the ray hit an edge
- **SampleNavmeshPosition(pos, maxDist, filter, out result)** — the closest point on the navmesh within the radius

#### PGFilter — polygon filter

Defines which navmesh polygons are available for search. Three flag sets:

- **Include** — polygons with these flags are considered
- **Exclude** — polygons with these flags are excluded
- **Exclusive** — only polygons with these flags (takes priority over include)

`SetCost(areaType, cost)` — traversal cost for a zone type. Affects route selection during pathfinding.

#### PGPolyFlags — polygon capabilities

A bitmask describing what can be done on the polygon:

| Flag | Purpose |
|------|---------|
| `WALK` | Normal movement (ground, roads) |
| `DOOR` | Passage through doors |
| `INSIDE` | Inside buildings |
| `SWIM` / `SWIM_SEA` | Swimming (fresh / sea water) |
| `LADDER` | Ladders |
| `JUMP_OVER` / `JUMP_DOWN` | Jumping over / jumping down |
| `CLIMB` | Climbing |
| `CRAWL` / `CROUCH` | Crawling / crouched |
| `DISABLED` | Disabled polygon |
| `UNREACHABLE` | Unreachable |
| `JUMP` | Composite: `JUMP_OVER | JUMP_DOWN` |
| `SPECIAL` | Composite: `JUMP | CLIMB | CRAWL | CROUCH` |

#### PGAreaType — navmesh zone types

Define the surface type for cost calculation:

`TERRAIN`, `WATER` / `WATER_DEEP` / `WATER_SEA` / `WATER_SEA_DEEP`, `OBJECTS` / `OBJECTS_NOFFCON`, `BUILDING`, `ROADWAY` / `ROADWAY_BUILDING`, `TREE`, `DOOR_OPENED` / `DOOR_CLOSED`, `LADDER`, `CRAWL`, `CROUCH`, `FENCE_WALL`, `JUMP`

---

### Groups (AIWorld → AIGroup → AIAgent)

A three-tier hierarchy for managing AI entities.

**AIWorld** — a singleton, manages all groups. Group creation:
- `CreateGroup(templateName)` — group with behavior from a template
- `CreateDefaultGroup()` — group without behavior

Important: **empty groups are automatically deleted on the next frame**. Group management is the responsibility of AIWorld (`DeleteGroup()` destroys the group along with all of its agents).

**AIGroup** — agent container. `AddAgent()` / `RemoveAgent()` for manual roster management. `GetBehaviour()` — get the group's behavior.

**AIAgent** — an individual agent. Minimal script interface:
- `SetKeepInIdle(bool)` — keep in idle state
- `GetGroup()` — current group

#### Infected group behavior

`BehaviourGroupInfectedPack` — the only implemented group behavior. Patrols along waypoints:

- `SetWaypoints(params[], startIndex, forward, loop)` — set the route. Each waypoint: position + radius
- `loop=true` — loop, `loop=false` — patrol (back and forth)
- `SetCurrentWaypoint(index)` — forcibly change the current waypoint

---

### AIBehaviour — behavior system

A two-tier architecture, fully native:

**AIBehaviourHLData** — behavior template, parsed from config:
- `ParseBehaviourSlot(name)` — register a behavior slot ("Calm", "Attracted", "Disturbed", "Alerted")
- `ParseAlertLevel(name)` — register an alert level
- `ReadParamValue(name, default)` — read a parameter from the config

**AIBehaviourHL** — runtime behavior, ticked every frame:
- `Simulate(timeDelta)` — called by the engine every frame
- `OnDamage(damage, source)` — reaction to taking damage
- `OnAnimationEvent(nameCrc)` — reaction to an animation event
- `SetNextBehaviour(crc)` / `SwitchToNextBehaviour()` — switching between behavior slots

Example: `AIBehaviourHLZombie2` defines slots Calm/Attracted/Disturbed/Alerted and the parameters `damageToCrawl`, `crawlProbability`.

---

### Sensing — how the AI perceives the world

Two systems: noise (hearing) and visibility (sight). Both run **server-side only**.

#### NoiseSystem — noise

Global system (`g_Game.GetNoiseSystem()`). Noise sources call one of three methods:

| Method | Purpose |
|--------|---------|
| `AddNoise(entity, params, multiplier)` | Noise from an entity at its position |
| `AddNoisePos(entity, pos, params, multiplier)` | Noise from an entity at the specified position |
| `AddNoiseTarget(pos, lifetime, params, multiplier)` | Visual "ping" — the AI "sees" the point for `lifetime` seconds |

`NoiseParams` are loaded from configs (`NoiseParams.Load("cfgPath")`). The config defines the base strength and range of the noise.

**Resulting multiplier formula (for the player):**

```
noise = (shoesCoef + surfaceCoef * 0.25) / 1.25 * speedCoef * weatherReduction
```

Speed multipliers (`PlayerConstants`):

| State | Multiplier |
|-------|-----------|
| Idle | 0 |
| Walk | 0.4 |
| Crouch run | 0.6 |
| Run | 0.8 |
| Sprint | 1.0 |
| Roll (prone) | 2.0 |

Shoe multipliers:

| Footwear | Multiplier |
|----------|-----------|
| Barefoot | 0.45 |
| Sneakers | 0.6 |
| Boots | 0.85 |

Surface: value from the surface config (`GetSurfaceNoise()`), weighted with a coefficient of 0.25.

**Weather** reduces noise: rain up to −50% (`RAIN_NOISE_REDUCTION_WEIGHT = 0.5`), snowfall up to −25% (`SNOWFALL_NOISE_REDUCTION_WEIGHT = 0.25`). The maximum of the two reductions is used; they are not summed.

**Noise sources** besides footsteps: doors, fences, vehicles, grenades, fireplaces, alarm clocks, road flares, flare guns, traps, gunshots. Each loads its own `NoiseParams` from config.

#### AITargetCallbacks — visibility

The system through which targets (primarily the player) report their visibility to the AI. Registration: `EntityAI.SetAITargetCallbacks()`.

**AITargetCallbacksPlayer** — the implementation for the player:

**Vision point** (`GetVisionPointPositionWS`): depends on the observing zombie's mind state:
- ALERTED and above → the player's head
- CALM → chest (bone `Spine3`)
- Fallback → position + 1m up

**Vision modifier** (`GetMaxVisionRangeModifier`): the average of speed and stance coefficients:

| State | Multiplier |
|-------|-----------|
| Standing | 1.5 |
| Crouch | 0.6 |
| Prone | 0.15 |
| Run/Sprint | 1.0 |
| Walk | 0.66 |
| Standing still | 0.3 |

Final modifier: `(speedCoef + stanceCoef) / 2`. Example: running while standing = `(1.0 + 1.5) / 2 = 1.25`, walking while prone = `(0.66 + 0.15) / 2 = 0.405`.

Stance affects how speed is interpreted: running while crouched counts as a walk, sprinting while crouched as `CROUCH_RUN`, any movement while prone as a walk.
