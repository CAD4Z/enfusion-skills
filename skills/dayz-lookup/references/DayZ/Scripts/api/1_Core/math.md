Engine math libraries. Source: `proto/enmath.c`, `proto/enmath2d.c`, `proto/enmath3d.c`

### Math

Static class. All methods are invoked through `Math.XXX()`.

**Constants:** `PI`, `PI2` (2*PI), `PI_HALF`, `EULER`, `RAD2DEG`, `DEG2RAD`

**Random:**

| Method | Description |
|-------|----------|
| `RandomInt(min, max)` | [min, max) — max exclusive |
| `RandomIntInclusive(min, max)` | [min, max] |
| `RandomFloat(min, max)` | [min, max) |
| `RandomFloatInclusive(min, max)` | [min, max] |
| `RandomFloat01()` | [0.0, 1.0] |
| `RandomBool()` | true/false |
| `Randomize(seed)` | Set seed (-1 = time) |

**Basic:**

| Method | Description |
|-------|----------|
| `AbsFloat(f)` / `AbsInt(i)` | Absolute value |
| `SignFloat(f)` / `SignInt(i)` | Sign (-1, 0, 1) |
| `SqrFloat(f)` / `SqrInt(i)` | Square |
| `Sqrt(val)` | Square root |
| `Pow(v, power)` | Power |
| `Log2(x)` | Base-2 logarithm |
| `ModFloat(x, y)` | Remainder (toward zero) |
| `RemainderFloat(x, y)` | Remainder (toward nearest) |
| `Factorial(val)` | Factorial (max 12, otherwise overflow) |
| `Poisson(mean, occurences)` | Poisson distribution |

**Trigonometry (radians):**

`Sin`, `Cos`, `Tan`, `Asin`, `Acos`, `Atan`, `Atan2(y, x)`

**Angles:**

| Method | Description |
|-------|----------|
| `NormalizeAngle(ang)` | Normalize 0..360 |
| `DiffAngle(a1, a2)` | Angle difference |

**Rounding:**

`Round`, `Floor`, `Ceil`

**Ranges and interpolation:**

| Method | Description |
|-------|----------|
| `Clamp(value, min, max)` | Clamp to range |
| `Min(x, y)` / `Max(x, y)` | Minimum / maximum |
| `IsInRange(v, min, max)` | Check whether in [min, max] |
| `IsInRangeInt(v, min, max)` | Same for int |
| `Lerp(a, b, time)` | Linear interpolation (time 0..1) |
| `InverseLerp(a, b, value)` | Inverse interpolation |
| `Remap(inMin, inMax, outMin, outMax, value, clamped)` | Remap from one range to another |
| `SmoothCD(val, target, velocity[], smoothTime, maxVel, dt)` | Smooth damping (S-curve) |

**Wrap (cyclic clamping):**

| Method | Description |
|-------|----------|
| `WrapFloat(f, min, max)` | [min, max) |
| `WrapFloatInclusive(f, min, max)` | [min, max] |
| `WrapFloat0X(f, max)` | [0, max) |
| `WrapInt(i, min, max)` | [min, max) |

**Geometry:**

| Method | Description |
|-------|----------|
| `IsPointInCircle(center, r, point)` | Point in circle (XZ) |
| `IsPointInRectangle(min, max, point)` | Point in rectangle (XZ) |
| `AreaOfRightTriangle(s, a)` | Area of a right triangle |

### Math2D

| Method | Description |
|-------|----------|
| `IsPointInPolygonXZ(polygon, point)` | Point inside polygon (XZ) |
| `IsPointInTriangleXZ(p1, p2, p3, point)` | Point inside triangle (XZ) |
| `IsPointInPolygon(polygon, x, y)` | Point inside polygon (2D float array) |
| `TriangleWindingXZ(a, b, c)` | Winding order: `CounterClockwise`, `Clockwise`, `Invalid` |

### Math3D

**Constructor:** `Vector(x, y, z)` — global function for creating a vector.

**Intersections:**

| Method | Return | Description |
|-------|---------|----------|
| `IntersectRaySphere(start, end, center, radius)` | `float` | -1 if none, otherwise ray fraction |
| `IntersectRayBox(start, end, mins, maxs)` | `float` | -1 if none |
| `IntersectSphereBox(origin, radius, mins, maxs)` | `bool` | Sphere and AABB |
| `IntersectSphereCone(origin, r, conepos, axis, angle)` | `bool` | Sphere and cone |
| `IntersectRayCylinder(start, end, center, r, h)` | `bool` | Ray and cylinder |
| `IntersectRayPlane(start, end, normal, dist, out intersection)` | `int` | 1=behind, 2=in front, 3=intersects |
| `IntersectCylinderOBB(...)` | `bool` | Cylinder and OBB |
| `CheckBoundBox(mins1, maxs1, mins2, maxs2)` | `int` | 1 if they intersect |

**Matrices:**

| Method | Description |
|-------|----------|
| `YawPitchRollMatrix(angles, out mat[3])` | Rotation matrix from angles |
| `DirectionAndUpMatrix(dir, up, out mat[4])` | Matrix from direction and up vector |
| `MatrixMultiply4(m0[4], m1[4], out res[4])` | Multiply 4x4 matrices |
| `MatrixMultiply3(m0[3], m1[3], out res[3])` | Multiply 3x3 matrices |
| `MatrixInvMultiply4/3(...)` | Inverse multiply |
| `MatrixInverse4/3(mat)` | Invert in-place |
| `MatrixOrthogonalize4/3(mat)` | Orthogonalize |
| `MatrixIdentity4/3(out mat)` | Identity matrix |
| `ScaleMatrix(scale, out mat[3])` | Scaling matrix |
| `MatrixToAngles(mat[3])` | Matrix to angles |

**Quaternions:**

| Method | Description |
|-------|----------|
| `QuatIdentity(out q[4])` | Identity quaternion `{0,0,0,1}` |
| `QuatCopy(s[4], out d[4])` | Copy |
| `MatrixToQuat(mat[3], out q[4])` | Matrix to quaternion |
| `QuatToMatrix(q[4], out mat[3])` | Quaternion to matrix |
| `QuatToAngles(q[4])` | Quaternion to angles |
| `QuatLerp(out qout[4], q1[4], q2[4], frac)` | Linear interpolation |
| `QuatMultiply(out qout[4], q1[4], q2[4])` | Multiply quaternions |

**Miscellaneous:**

| Method | Description |
|-------|----------|
| `Curve(ECurveType, t, points)` | Curves: `CatmullRom`, `NaturalCubic`, `UniformCubic` |
| `NearestPoint(beg, end, pos)` | Nearest point on a segment |
| `AngleFromPosition(origin, dir, target)` | Angle to target from direction (rad) |
| `ConePoints(origin, len, halfAngle, offset, out left, out right)` | Points of a 2D cone |
| `BlendCartesian(sample, inPositions, outWeights)` | Blend space weights |
