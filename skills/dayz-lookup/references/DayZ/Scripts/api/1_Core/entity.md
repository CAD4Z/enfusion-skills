Enfusion engine entity system. Source: `proto/enentity.c`

### IEntity

Base class of all entities in the world. Inherits from `Managed`.

#### Events (EOn*)

Override in subclasses to receive events. They only fire when the corresponding mask is set (`SetEventMask`).

| Method | When invoked |
|-------|------------------|
| `EOnInit(other, extra)` | After world creation |
| `EOnFrame(other, float timeSlice)` | Every frame (requires `EntityFlags.ACTIVE`) |
| `EOnPostFrame(other, extra)` | End of frame / after movement |
| `EOnVisible(other, extra)` | Entity is visible |
| `EOnNotVisible(other, extra)` | Entity is not visible |
| `EOnTouch(other, extra)` | Touched by another entity |
| `EOnSimulate(other, float dt)` | Physics simulation step |
| `EOnPostSimulate(other, float timeSlice)` | After simulation step |
| `EOnPhysicsMove(other, extra)` | Moved by physics |
| `EOnContact(other, Contact extra)` | Physical contact |
| `EOnJointBreak(other, extra)` | Joint break |
| `EOnAnimEvent(other, AnimEvent extra)` | Animation event |
| `EOnSoundEvent(other, SoundEvent extra)` | Sound event |
| `EOnEnter(other, extra)` | Enters a trigger |
| `EOnLeave(other, extra)` | Leaves a trigger |

#### EntityEvent (event mask)

`TOUCH`, `VISIBLE`, `NOTVISIBLE`, `FRAME`, `POSTFRAME`, `INIT`, `JOINTBREAK`, `SIMULATE`, `POSTSIMULATE`, `PHYSICSMOVE`, `CONTACT`, `EXTRA`, `ANIMEVENT`, `SOUNDEVENT`, `PHYSICSSTEADY`, `USER`, `ENTER`, `LEAVE`, `ALL`

#### EntityFlags

| Flag | Description |
|------|----------|
| `VISIBLE` | Visible, rendered |
| `SOLID` | Collidable in traces |
| `TRIGGER` | Not collidable, but generates touch events |
| `TOUCHTRIGGERS` | Interacts with triggers |
| `ACTIVE` | Actively updated by the engine (EOnFrame) |
| `STATIC` | Static object, more accurate but slower in scene-tree |
| `TRANSLUCENT` | Ignored with `TraceFlags.PASSTRANSLUCENT` |
| `WATER` | Only when tracing with `TraceFlags.WATER` |
| `USER1`..`USER6` | User-defined flags for filtering |

#### Transformations

| Method | Description |
|-------|----------|
| `GetTransform(out mat[])` | World transformation matrix |
| `GetRenderTransform(out mat[4])` | Render matrix |
| `GetLocalTransform(out mat[])` | Local matrix (in hierarchy) |
| `GetTransformAxis(int axis)` | Matrix axis (0-3) |
| `SetTransform(mat[4])` | Set world matrix |
| `GetOrigin()` | World position |
| `SetOrigin(vec)` | Set position |
| `GetLocalPosition()` | Local position |
| `GetYawPitchRoll()` | Orientation (Yaw, Pitch, Roll) |
| `SetYawPitchRoll(angles)` | Set orientation |
| `GetAngles()` / `SetAngles(angles)` | Rotation angles around X, Y, Z axes |
| `GetLocalYawPitchRoll()` / `GetLocalAngles()` | Local angles |
| `GetScale()` / `SetScale(float)` | Scale |

**Coordinate conversion:**

| Method | Description |
|-------|----------|
| `VectorToParent(vec)` | Local vector -> world |
| `CoordToParent(coord)` | Local position -> world |
| `VectorToLocal(vec)` | World vector -> local |
| `CoordToLocal(coord)` | World position -> local |

#### Hierarchy

| Method | Description |
|-------|----------|
| `AddChild(child, pivot, positionOnly)` | Add a child entity |
| `RemoveChild(child, keepTransform)` | Remove from hierarchy |
| `GetParent()` | Parent |
| `GetChildren()` | First child |
| `GetSibling()` | Next on the same level |

#### Miscellaneous

| Method | Description |
|-------|----------|
| `GetID()` / `SetID(id)` | Unique ID |
| `GetName()` / `SetName(name)` | Entity name |
| `GetFlags()` / `SetFlags(flags, recursive)` / `ClearFlags(...)` | Flag management |
| `IsFlagSet(flags)` | Check flag |
| `GetEventMask()` / `SetEventMask(e)` / `ClearEventMask(e)` | Event mask |
| `SendEvent(actor, e, extra)` | Dynamic event invocation |
| `GetPhysics()` | Get the Physics object |
| `GetBounds(out mins, out maxs)` | Local bounding box |
| `GetWorldBounds(out mins, out maxs)` | World bounding box |
| `SetObject(vobject, options)` | Set visual object |
| `GetVObject()` | Get visual object |
| `FilterNextTrace()` | Exclude from the next trace |
| `Update()` | Manual state update |

### Helper classes

**BaseContainer** — access to editor data: `GetClassName()`, `GetName()`, `VarIndex(name)`, `IsVariableSet(idx)`, `Get(idx, out val)`

**IEntitySource** / **WidgetSource** — source hierarchy: `GetChildren()`, `GetSibling()`, `GetParent()`

**Attribute** / **EditorAttribute** — attributes for Workbench (properties in the editor).
