Физическая система. Источник: `proto/enphysics.c`, `physics/`

### Physics — обёртка физического тела

Получается через `IEntity.GetPhysics()`. Два типа: static (коллизия) и dynamic (rigid body).

**Константы:** `Physics.KMH2MS`, `Physics.MS2KMH`, `Physics.STANDARD_GRAVITY` (9.81), `Physics.VGravity` ("0 -9.81 0")

**Создание тел (static):**

| Метод | Описание |
|-------|----------|
| `Physics.CreateStatic(ent, layerMask)` | Из геометрии VObject |
| `Physics.CreateStaticEx(ent, geoms[])` | Из кастомных геометрий |
| `Physics.CreateDynamic(ent, mass, layerMask)` | Динамическое из VObject |
| `Physics.CreateDynamicEx(ent, centerOfMass, mass, geoms[])` | Динамическое из кастомных |
| `Physics.CreateGhostEx(ent, geoms[])` | Ghost (триггер) |

```cpp
PhysicsGeom geom = PhysicsGeom.CreateBox("1 1 1");
PhysicsGeomDef geoms[] = {PhysicsGeomDef("", geom, "material/default", 0xffffffff)};
Physics.CreateStaticEx(this, geoms);
```

**Состояние:**

| Метод | Описание |
|-------|----------|
| `Destroy()` | Уничтожить тело |
| `IsActive()` | Симулируется ли (не спит) |
| `IsDynamic()` | Динамическое ли |
| `IsKinematic()` | Кинематическое ли (анимированное) |
| `SetActive(ActiveState)` | Изменить состояние активации |
| `ChangeSimulationState(SimulationState)` | Изменить состояние симуляции |
| `EnableGravity(enable)` | Вкл/выкл гравитацию |
| `EnableCCD(maxMotion, sphereRadius)` | Continuous Collision Detection (-1 = выкл) |

**Динамика:**

| Метод | Описание |
|-------|----------|
| `GetVelocity()` / `SetVelocity(vel)` | Линейная скорость |
| `GetAngularVelocity()` / `SetAngularVelocity(vel)` | Угловая скорость |
| `GetMass()` / `SetMass(mass)` | Масса |
| `GetCenterOfMass()` | Смещение центра масс |
| `ApplyImpulse(impulse)` | Импульс (в центре) |
| `ApplyImpulseAt(pos, impulse)` | Импульс в точке (мировые координаты) |
| `ApplyForce(force)` | Постоянная сила |
| `ApplyForceAt(pos, force)` | Сила в точке |
| `ApplyTorque(torque)` | Крутящий момент |
| `ClearForces()` | Сбросить все силы |
| `GetTotalForce()` / `GetTotalTorque()` | Текущие суммарные силы |
| `SetDamping(linear, angular)` | Демпфирование |
| `SetSleepingTreshold(linear, angular)` | Порог засыпания |
| `SetLinearFactor(vec)` | Масштаб осей (0 = заблокировать ось, для 2D физики) |
| `SetTargetMatrix(mat[4], timeslice)` | Целевая трансформация (кинематика) |
| `SetInertiaTensorV(v)` | Тензор инерции (диагональ) |

**Слои взаимодействия:**

| Метод | Описание |
|-------|----------|
| `SetInteractionLayer(mask)` / `GetInteractionLayer()` | Маска слоёв тела |
| `SetGeomInteractionLayer(idx, mask)` / `GetGeomInteractionLayer(idx)` | Маска слоёв геометрии |

**Геометрии:**

| Метод | Описание |
|-------|----------|
| `GetNumGeoms()` | Кол-во геометрий |
| `GetGeom(name)` | Найти по имени (возвращает индекс) |
| `AddGeom(name, geom, frame[4], material, layer)` | Добавить геометрию |
| `GetGeomWorldPosition(idx)` / `GetGeomPosition(idx)` | Позиция геометрии |
| `GetGeomWorldTransform(idx, out mat[4])` | Мировая трансформация |

### PhysicsGeom — геометрические формы

| Метод | Описание |
|-------|----------|
| `PhysicsGeom.CreateBox(size)` | Бокс |
| `PhysicsGeom.CreateSphere(radius)` | Сфера |
| `PhysicsGeom.CreateCapsule(radius, height)` | Капсула |
| `PhysicsGeom.CreateCylinder(radius, height)` | Цилиндр |
| `PhysicsGeom.CreateTriMesh(verts[], inds[], nVerts, nInds)` | Произвольный меш |
| `geom.Destroy()` | Уничтожить |

### PhysicsGeomDef — описание элемента

```cpp
class PhysicsGeomDef: Managed
{
    string Name;
    dGeom Geometry;
    vector Frame[4];       // локальная трансформация
    int ParentNode = -1;   // кость (-1 = нет)
    string MaterialName;   // материал
    int LayerMask;         // битовая маска слоёв
}
```

### PhysicsJoint — соединения тел

Создание через `PhysicsJoint.CreateXXX(ent1, ent2, ..., disableCollisions, breakThreshold)`. `breakThreshold = -1` = неразрушимый.

| Тип | Описание |
|-----|----------|
| `CreateHinge(ent1, ent2, point1, axis1, point2, axis2, ...)` | Петля (1 ось вращения) |
| `CreateHinge2(ent1, ent2, mat1[4], mat2[4], ...)` | Петля через матрицы (ось = Z) |
| `CreateBallSocket(ent1, ent2, point1, point2, ...)` | Шаровой шарнир |
| `CreateFixed(ent1, ent2, point1, point2, ...)` | Жёсткое соединение |
| `CreateConeTwist(ent1, ent2, mat1[4], mat2[4], ...)` | Конусное (twist=X, swings=Y,Z) |
| `CreateSlider(ent1, ent2, mat1[4], mat2[4], ...)` | Слайдер (ось=X) |
| `Create6DOF(ent1, ent2, mat1[4], mat2[4], ...)` | 6 степеней свободы |
| `Create6DOFSpring(ent1, ent2, mat1[4], mat2[4], ...)` | 6DOF с пружинами |

**Настройка joints:**

- `PhysicsHingeJoint`: `SetLimits(low, high, softness, bias, relaxation)`, `SetAxis(axis)`, `SetMotorTargetAngle(angle, dt, maxImpulse)`
- `PhysicsConeTwistJoint`: `SetLimits(swing1, swing2, twist, softness, bias, relaxation)`
- `PhysicsSliderJoint`: `SetLinearLimits(lo, hi)`, `SetAngularLimits(lo, hi)`, `SetLinearMotor(velocity, force)`
- `Physics6DOFJoint`: `SetLinearLimits(lower, upper)`, `SetAngularLimits(lower, upper)`, `SetLimit(axis, lo, hi)`
- `Physics6DOFSpringJoint`: + `SetSpring(axis, stiffness, damping)` (-1/-1 = выкл)

**Параметры joints** (softness, biasFactor, relaxationFactor):
- softness 0.8-1.0: % свободного движения в пределах лимита
- biasFactor ~0.3: сила сопротивления нарушению лимита
- relaxationFactor ~1.0: сопротивление скоростям, нарушающим лимит

### Глобальные функции физики мира

| Функция | Описание |
|---------|----------|
| `dGetGravity(worldEnt)` / `dSetGravity(worldEnt, g)` | Гравитация мира |
| `dSetTimeSlice(worldEnt, dt)` | Шаг симуляции (default 1/40) |
| `GetVelocity(ent)` / `SetVelocity(ent, vel)` | Скорость сущности |
| `dBodyCollisionBlock(ent1, ent2)` | Отключить коллизии между парой |
| `dBodyCreateStaticEx/DynamicEx/GhostEx(...)` | Legacy создание тел |
