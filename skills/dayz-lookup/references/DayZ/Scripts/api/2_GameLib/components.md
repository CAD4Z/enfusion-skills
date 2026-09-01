GameLib component system. Condition: `COMPONENT_SYSTEM`. Source: `components/gamelibcomponents.c`

### IEntityComponentSource

`typedef int[] IEntityComponentSource` — inherits `BaseContainer`. Component data source (from template/editor).

### TouchEvent

| Value | Description |
|-------|-------------|
| `ON_ENTER` | Entering the touch zone |
| `ON_STAY` | Staying inside the zone |
| `ON_EXIT` | Exiting the zone |

### GenericComponent

Base class of all components. Inherits `Managed`. Constructor is `protected`.

| Method | Return | Description |
|--------|--------|-------------|
| `GetEventMask()` | `int` | Current event mask |
| `SetEventMask(IEntity owner, int mask)` | `int` | Add bits to the mask. Returns the OR result. **Do not call in the constructor** — use `OnComponentInsert` |
| `ClearEventMask(IEntity owner, int mask)` | `int` | Remove bits from the mask. Returns the cleared bits |
| `Activate(IEntity owner)` | — | Activate, will call `EOnActivate` |
| `Deactivate(IEntity owner)` | — | Deactivate, will call `EOnDeactivate` |
| `IsActive()` | `bool` | Whether the component is active |

### ScriptComponent

Inherits `GenericComponent`. Parent of all script components.

#### Lifecycle

1. **Constructor** — component creation
2. **`OnComponentInsert(owner, other)`** — component added to entity. Last event in Workbench edit mode
3. **`EOnInit(owner, extra)`** — after all components are inserted (requires `EV_INIT` mask)
4. **`EOnActivate(owner)`** — if entity is `TFL_ACTIVE` and component is active (active by default)
5. **`EOn*` events** — by event mask (see `../1_Core/entity.md` — `EntityEvent`)
6. **`EOnDeactivate(owner)`** — on `Deactivate()` or removal
7. **`OnComponentRemove(owner, other)`** — component removed from entity
8. **`OnDelete(owner)`** — entity is being destroyed

#### Unique methods (not duplicates of IEntity)

| Method | Description |
|--------|-------------|
| `EOnActivate(IEntity owner)` | Component activated |
| `EOnDeactivate(IEntity owner)` | Component deactivated |
| `OnComponentInsert(IEntity owner, ScriptComponent other)` | Another component added to the same entity |
| `OnComponentRemove(IEntity owner, ScriptComponent other)` | Another component removed from the entity |
| `OnDelete(IEntity owner)` | Entity/component is being destroyed |

The remaining `EOn*` events (Frame, Touch, Simulate, Contact, etc.) are analogous to `IEntity` — see `../1_Core/entity.md`.

### GenericComponentClass

| Method | Description |
|--------|-------------|
| `DependsOn(typename otherClass, TypeID otherTypeID)` | Declare a dependency on another component type |

### BaseSoundComponent

Inherits `GenericComponent`. Manages sound events and signals.

| Method | Return | Description |
|--------|--------|-------------|
| `GetEventNames(out array<string> events)` | `int` | List of sound events |
| `GetSignalNames(out array<string> signals)` | `int` | List of signals |
| `GetSignalIndex(string name)` | `int` | Signal index by name |
| `SetSignalValueName(string signal, float value)` | — | Set signal value by name |
| `SetSignalValue(int index, float value)` | — | Set value by index |
| `Play(string name)` | `SoundHandle` | Play a sound event |
| `Update()` | `SoundHandle` | Play via triggers |
| `Terminate(SoundHandle handle)` | — | Stop the sound |
| `IsPlayed(SoundHandle handle)` | `bool` | Whether it is playing |
| `IsHandleValid(SoundHandle handle)` | `bool` | Whether the handle is valid |
| `SetTransform(vector[] transf)` | — | Sound source position |
| `SetDebug(bool value)` | — | Debug mode |

`SoundHandle` — `typedef int[]`.
