Extended GameLib entities. Condition: `COMPONENT_SYSTEM`. Source: `entities/gamelibentities.c`

### Inheritance hierarchy

```
IEntity (1_Core)
└── GenericEntity
    ├── GenericWorldEntity
    │   └── WorldEntity
    ├── GenericTerrainEntity
    ├── GenericWorldLightEntity
    ├── GenericWorldFogEntity
    ├── LightEntity
    ├── BasicEntity
    │   ├── ModelEntity
    │   ├── CharacterEntity
    │   └── BasicCamera
    └── VRHandEntity
```

### GenericEntity

Inherits `IEntity`. Adds the component system.

| Method | Return | Description |
|--------|--------|-------------|
| `Show(bool show)` | — | Show/hide the entity |
| `FindComponent(typename typeName)` | `GenericComponent` | Find the first component by type |
| `InsertComponent(GenericComponent component)` | — | Add a component. Calls `OnComponentInsert` on all components, then `EOnInit` (if masked) and `EOnActivate` |
| `RemoveComponent(GenericComponent component)` | — | Remove the component (without deletion). Calls `EOnDeactivate` and `OnComponentRemove` |
| `DeleteComponent(GenericComponent component)` | — | Remove and delete the component. Additionally calls `OnDelete` |

In Workbench: `_WB_AfterWorldUpdate(float timeSlice)` — called after world update for selected entities (only `WORKBENCH`).

### LightEntity

Inherits `GenericEntity`. Manages a light source.

| Method | Return | Description |
|--------|--------|-------------|
| `SetDiffuseColor(int color)` | — | Diffuse light color |
| `GetDiffuseColor()` | `int` | Current color |
| `SetRadius(float radius)` | — | Radius |
| `GetRadius()` | `float` | Current radius |
| `SetConeAngle(float angle)` | — | Cone angle (only `LT_SPOT`) |
| `GetConeAngle()` | `float` | Current cone angle |
| `SetCastShadow(bool enable)` | — | Shadow casting |
| `IsCastShadow(bool enable)` | `bool` | Whether it casts shadows |

### CharacterEntity

Inherits `BasicEntity`. A controllable character.

| Method | Return | Description |
|--------|--------|-------------|
| `Teleport(vector transform[4])` | — | Teleport (4x4 matrix) |
| `GetCurrentMovement()` | `CharacterMovement` | Current movement type |
| `GetCurrentStance()` | `CharacterStance` | Current stance |

#### CharacterMovement

`MOVEMENTTYPE_IDLE`, `MOVEMENTTYPE_WALK`, `MOVEMENTTYPE_RUN`, `MOVEMENTTYPE_SPRINT`

#### CharacterStance

`STANCE_ERECT`, `STANCE_CROUCH`, `STANCE_PRONE`, `STANCE_ERECT_RAISED`, `STANCE_CROUCH_RAISED`, `STANCE_PRONE_RAISED`

### Empty marker classes

`GenericWorldEntity`, `GenericTerrainEntity`, `GenericWorldLightEntity`, `GenericWorldFogEntity`, `BasicEntity`, `BasicCamera`, `ModelEntity`, `VRHandEntity`, `WorldEntityClass`, `WorldEntity` — no additional methods, used for typing and filtering.

### Template entities (GAME_TEMPLATE)

Examples/templates under `#ifdef GAME_TEMPLATE`, not part of the API. Sources: `entities/script*.c`, `entities/rendertarget.c`, `entities/worldsmenu.c`.

| Class | Description |
|-------|-------------|
| `ScriptCamera` | Free-fly camera with debug UI |
| `ScriptLight` | Point light source |
| `ScriptModel` | Model with static/dynamic physics |
| `RenderTarget` | Render-target widget for the camera |
| `WorldsMenu` | Debug world-selection menu |
