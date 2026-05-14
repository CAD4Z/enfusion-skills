Artificial intelligence system: navmesh, groups, agents. Sources: `ai/`

### AIWorld

AI world and navigation mesh. Access: `g_Game.GetWorld().GetAIWorld()`. Proto native.

#### Groups

| Method | Description |
|--------|-------------|
| `CreateGroup()` | Create a group |
| `CreateDefaultGroup()` | Default group |
| `DeleteGroup(group)` | Delete a group |

#### Navigation

| Method | Description |
|--------|-------------|
| `FindPath(start, end, filter, out path)` | Find a path on the navmesh |
| `RaycastNavMesh(start, end, filter, out hitPos)` | Raycast on the navmesh |
| `SampleNavmeshPosition(pos, maxDist, filter, out result)` | Nearest point on the navmesh |

### AIAgent

Individual AI agent. Proto native.

| Method | Description |
|--------|-------------|
| `SetKeepInIdle(state)` | Keep in idle state |
| `GetGroup()` | Get the group |

### AIGroup

Group of agents. Proto native.

### AIGroupBehaviour

Group behaviour.

### PGFilter

Filter for navigation queries. Source: `ai/`

| Method | Description |
|--------|-------------|
| `GetIncludeFlags()` / `GetExcludeFlags()` / `GetExlusiveFlags()` | Get flags |
| `SetFlags(include, exclude, exclusive)` | Set flags |
| `SetCost(areaType, cost)` | Traversal cost by area type |

### PGPolyFlags

Navmesh polygon flags (bitmask):

```
NONE, WALK, DISABLED, DOOR, INSIDE, SWIM, SWIM_SEA, LADDER,
JUMP_OVER, JUMP_DOWN, CLIMB, CRAWL, CROUCH, UNREACHABLE, ALL, SPECIAL
```

### PGAreaType

Navmesh area types:

```
NONE, TERRAIN,
WATER_DEEP, WATER_SHALLOW, WATER_SHORE,
OBJECTS_NOFFCON, OBJECTS_FFCON,
DOOR_OPENED, DOOR_CLOSED,
LADDER, CRAWL, CROUCH,
FENCE_WALL, JUMP
```
