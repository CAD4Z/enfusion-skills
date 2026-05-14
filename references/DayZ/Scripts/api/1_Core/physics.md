Physics system. Source: `proto/enphysics.c`, `physics/`

### Physics — physical body wrapper

Obtained via `IEntity.GetPhysics()`. Two types: static (collision) and dynamic (rigid body).

**Constants:** `Physics.KMH2MS`, `Physics.MS2KMH`, `Physics.STANDARD_GRAVITY` (9.81), `Physics.VGravity` ("0 -9.81 0")

**Creating bodies (static):**

| Method | Description |
|-------|----------|
| `Physics.CreateStatic(ent, layerMask)` | From VObject geometry |
| `Physics.CreateStaticEx(ent, geoms[])` | From custom geometries |
| `Physics.CreateDynamic(ent, mass, layerMask)` | Dynamic from VObject |
| `Physics.CreateDynamicEx(ent, centerOfMass, mass, geoms[])` | Dynamic from custom ones |
| `Physics.CreateGhostEx(ent, geoms[])` | Ghost (trigger) |

```cpp
PhysicsGeom geom = PhysicsGeom.CreateBox("1 1 1");
PhysicsGeomDef geoms[] = {PhysicsGeomDef("", geom, "material/default", 0xffffffff)};
Physics.CreateStaticEx(this, geoms);
```

**State:**

| Method | Description |
|-------|----------|
| `Destroy()` | Destroy the body |
| `IsActive()` | Whether simulated (not sleeping) |
| `IsDynamic()` | Whether dynamic |
| `IsKinematic()` | Whether kinematic (animated) |
| `SetActive(ActiveState)` | Change activation state |
| `ChangeSimulationState(SimulationState)` | Change simulation state |
| `EnableGravity(enable)` | Enable/disable gravity |
| `EnableCCD(maxMotion, sphereRadius)` | Continuous Collision Detection (-1 = off) |

**Dynamics:**

| Method | Description |
|-------|----------|
| `GetVelocity()` / `SetVelocity(vel)` | Linear velocity |
| `GetAngularVelocity()` / `SetAngularVelocity(vel)` | Angular velocity |
| `GetMass()` / `SetMass(mass)` | Mass |
| `GetCenterOfMass()` | Center of mass offset |
| `ApplyImpulse(impulse)` | Impulse (at the center) |
| `ApplyImpulseAt(pos, impulse)` | Impulse at a point (world coordinates) |
| `ApplyForce(force)` | Continuous force |
| `ApplyForceAt(pos, force)` | Force at a point |
| `ApplyTorque(torque)` | Torque |
| `ClearForces()` | Clear all forces |
| `GetTotalForce()` / `GetTotalTorque()` | Current total forces |
| `SetDamping(linear, angular)` | Damping |
| `SetSleepingTreshold(linear, angular)` | Sleep threshold |
| `SetLinearFactor(vec)` | Axis scale (0 = lock axis, for 2D physics) |
| `SetTargetMatrix(mat[4], timeslice)` | Target transform (kinematic) |
| `SetInertiaTensorV(v)` | Inertia tensor (diagonal) |

**Interaction layers:**

| Method | Description |
|-------|----------|
| `SetInteractionLayer(mask)` / `GetInteractionLayer()` | Body layer mask |
| `SetGeomInteractionLayer(idx, mask)` / `GetGeomInteractionLayer(idx)` | Geometry layer mask |

**Geometries:**

| Method | Description |
|-------|----------|
| `GetNumGeoms()` | Number of geometries |
| `GetGeom(name)` | Find by name (returns index) |
| `AddGeom(name, geom, frame[4], material, layer)` | Add geometry |
| `GetGeomWorldPosition(idx)` / `GetGeomPosition(idx)` | Geometry position |
| `GetGeomWorldTransform(idx, out mat[4])` | World transform |

### PhysicsGeom — geometric shapes

| Method | Description |
|-------|----------|
| `PhysicsGeom.CreateBox(size)` | Box |
| `PhysicsGeom.CreateSphere(radius)` | Sphere |
| `PhysicsGeom.CreateCapsule(radius, height)` | Capsule |
| `PhysicsGeom.CreateCylinder(radius, height)` | Cylinder |
| `PhysicsGeom.CreateTriMesh(verts[], inds[], nVerts, nInds)` | Arbitrary mesh |
| `geom.Destroy()` | Destroy |

### PhysicsGeomDef — element descriptor

```cpp
class PhysicsGeomDef: Managed
{
    string Name;
    dGeom Geometry;
    vector Frame[4];       // local transform
    int ParentNode = -1;   // bone (-1 = none)
    string MaterialName;   // material
    int LayerMask;         // layer bitmask
}
```

### PhysicsJoint — body connections

Creation via `PhysicsJoint.CreateXXX(ent1, ent2, ..., disableCollisions, breakThreshold)`. `breakThreshold = -1` = unbreakable.

| Type | Description |
|-----|----------|
| `CreateHinge(ent1, ent2, point1, axis1, point2, axis2, ...)` | Hinge (1 rotation axis) |
| `CreateHinge2(ent1, ent2, mat1[4], mat2[4], ...)` | Hinge via matrices (axis = Z) |
| `CreateBallSocket(ent1, ent2, point1, point2, ...)` | Ball socket |
| `CreateFixed(ent1, ent2, point1, point2, ...)` | Rigid connection |
| `CreateConeTwist(ent1, ent2, mat1[4], mat2[4], ...)` | Cone twist (twist=X, swings=Y,Z) |
| `CreateSlider(ent1, ent2, mat1[4], mat2[4], ...)` | Slider (axis=X) |
| `Create6DOF(ent1, ent2, mat1[4], mat2[4], ...)` | 6 degrees of freedom |
| `Create6DOFSpring(ent1, ent2, mat1[4], mat2[4], ...)` | 6DOF with springs |

**Joint configuration:**

- `PhysicsHingeJoint`: `SetLimits(low, high, softness, bias, relaxation)`, `SetAxis(axis)`, `SetMotorTargetAngle(angle, dt, maxImpulse)`
- `PhysicsConeTwistJoint`: `SetLimits(swing1, swing2, twist, softness, bias, relaxation)`
- `PhysicsSliderJoint`: `SetLinearLimits(lo, hi)`, `SetAngularLimits(lo, hi)`, `SetLinearMotor(velocity, force)`
- `Physics6DOFJoint`: `SetLinearLimits(lower, upper)`, `SetAngularLimits(lower, upper)`, `SetLimit(axis, lo, hi)`
- `Physics6DOFSpringJoint`: + `SetSpring(axis, stiffness, damping)` (-1/-1 = off)

**Joint parameters** (softness, biasFactor, relaxationFactor):
- softness 0.8-1.0: % of free movement within the limit
- biasFactor ~0.3: force resisting limit violation
- relaxationFactor ~1.0: resistance to velocities violating the limit

### World physics global functions

| Function | Description |
|---------|----------|
| `dGetGravity(worldEnt)` / `dSetGravity(worldEnt, g)` | World gravity |
| `dSetTimeSlice(worldEnt, dt)` | Simulation step (default 1/40) |
| `GetVelocity(ent)` / `SetVelocity(ent, vel)` | Entity velocity |
| `dBodyCollisionBlock(ent1, ent2)` | Disable collisions between a pair |
| `dBodyCreateStaticEx/DynamicEx/GhostEx(...)` | Legacy body creation |
