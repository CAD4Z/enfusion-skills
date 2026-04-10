Математические библиотеки движка. Источник: `proto/enmath.c`, `proto/enmath2d.c`, `proto/enmath3d.c`

### Math

Статический класс. Все методы вызываются через `Math.XXX()`.

**Константы:** `PI`, `PI2` (2*PI), `PI_HALF`, `EULER`, `RAD2DEG`, `DEG2RAD`

**Рандом:**

| Метод | Описание |
|-------|----------|
| `RandomInt(min, max)` | [min, max) — max исключён |
| `RandomIntInclusive(min, max)` | [min, max] |
| `RandomFloat(min, max)` | [min, max) |
| `RandomFloatInclusive(min, max)` | [min, max] |
| `RandomFloat01()` | [0.0, 1.0] |
| `RandomBool()` | true/false |
| `Randomize(seed)` | Установить seed (-1 = время) |

**Базовые:**

| Метод | Описание |
|-------|----------|
| `AbsFloat(f)` / `AbsInt(i)` | Модуль |
| `SignFloat(f)` / `SignInt(i)` | Знак (-1, 0, 1) |
| `SqrFloat(f)` / `SqrInt(i)` | Квадрат |
| `Sqrt(val)` | Квадратный корень |
| `Pow(v, power)` | Степень |
| `Log2(x)` | Логарифм по основанию 2 |
| `ModFloat(x, y)` | Остаток (к нулю) |
| `RemainderFloat(x, y)` | Остаток (к ближайшему) |
| `Factorial(val)` | Факториал (max 12, иначе overflow) |
| `Poisson(mean, occurences)` | Распределение Пуассона |

**Тригонометрия (радианы):**

`Sin`, `Cos`, `Tan`, `Asin`, `Acos`, `Atan`, `Atan2(y, x)`

**Углы:**

| Метод | Описание |
|-------|----------|
| `NormalizeAngle(ang)` | Нормализация 0..360 |
| `DiffAngle(a1, a2)` | Разница углов |

**Округление:**

`Round`, `Floor`, `Ceil`

**Диапазоны и интерполяция:**

| Метод | Описание |
|-------|----------|
| `Clamp(value, min, max)` | Ограничение диапазоном |
| `Min(x, y)` / `Max(x, y)` | Минимум / максимум |
| `IsInRange(v, min, max)` | Проверка попадания [min, max] |
| `IsInRangeInt(v, min, max)` | То же для int |
| `Lerp(a, b, time)` | Линейная интерполяция (time 0..1) |
| `InverseLerp(a, b, value)` | Обратная интерполяция |
| `Remap(inMin, inMax, outMin, outMax, value, clamped)` | Перемаппинг из одного диапазона в другой |
| `SmoothCD(val, target, velocity[], smoothTime, maxVel, dt)` | Плавное сглаживание (S-кривая) |

**Wrap (циклическое ограничение):**

| Метод | Описание |
|-------|----------|
| `WrapFloat(f, min, max)` | [min, max) |
| `WrapFloatInclusive(f, min, max)` | [min, max] |
| `WrapFloat0X(f, max)` | [0, max) |
| `WrapInt(i, min, max)` | [min, max) |

**Геометрия:**

| Метод | Описание |
|-------|----------|
| `IsPointInCircle(center, r, point)` | Точка в круге (XZ) |
| `IsPointInRectangle(min, max, point)` | Точка в прямоугольнике (XZ) |
| `AreaOfRightTriangle(s, a)` | Площадь прямоугольного треугольника |

### Math2D

| Метод | Описание |
|-------|----------|
| `IsPointInPolygonXZ(polygon, point)` | Точка внутри полигона (XZ) |
| `IsPointInTriangleXZ(p1, p2, p3, point)` | Точка внутри треугольника (XZ) |
| `IsPointInPolygon(polygon, x, y)` | Точка внутри полигона (2D float массив) |
| `TriangleWindingXZ(a, b, c)` | Направление обхода: `CounterClockwise`, `Clockwise`, `Invalid` |

### Math3D

**Конструктор:** `Vector(x, y, z)` — глобальная функция создания vector.

**Пересечения:**

| Метод | Возврат | Описание |
|-------|---------|----------|
| `IntersectRaySphere(start, end, center, radius)` | `float` | -1 если нет, иначе фракция луча |
| `IntersectRayBox(start, end, mins, maxs)` | `float` | -1 если нет |
| `IntersectSphereBox(origin, radius, mins, maxs)` | `bool` | Сфера и AABB |
| `IntersectSphereCone(origin, r, conepos, axis, angle)` | `bool` | Сфера и конус |
| `IntersectRayCylinder(start, end, center, r, h)` | `bool` | Луч и цилиндр |
| `IntersectRayPlane(start, end, normal, dist, out intersection)` | `int` | 1=за, 2=перед, 3=пересечение |
| `IntersectCylinderOBB(...)` | `bool` | Цилиндр и OBB |
| `CheckBoundBox(mins1, maxs1, mins2, maxs2)` | `int` | 1 если пересекаются |

**Матрицы:**

| Метод | Описание |
|-------|----------|
| `YawPitchRollMatrix(angles, out mat[3])` | Матрица вращения из углов |
| `DirectionAndUpMatrix(dir, up, out mat[4])` | Матрица из направления и up-вектора |
| `MatrixMultiply4(m0[4], m1[4], out res[4])` | Умножение матриц 4x4 |
| `MatrixMultiply3(m0[3], m1[3], out res[3])` | Умножение матриц 3x3 |
| `MatrixInvMultiply4/3(...)` | Обратное умножение |
| `MatrixInverse4/3(mat)` | Инверсия in-place |
| `MatrixOrthogonalize4/3(mat)` | Ортогонализация |
| `MatrixIdentity4/3(out mat)` | Единичная матрица |
| `ScaleMatrix(scale, out mat[3])` | Матрица масштабирования |
| `MatrixToAngles(mat[3])` | Матрица в углы |

**Кватернионы:**

| Метод | Описание |
|-------|----------|
| `QuatIdentity(out q[4])` | Единичный кватернион `{0,0,0,1}` |
| `QuatCopy(s[4], out d[4])` | Копирование |
| `MatrixToQuat(mat[3], out q[4])` | Матрица в кватернион |
| `QuatToMatrix(q[4], out mat[3])` | Кватернион в матрицу |
| `QuatToAngles(q[4])` | Кватернион в углы |
| `QuatLerp(out qout[4], q1[4], q2[4], frac)` | Линейная интерполяция |
| `QuatMultiply(out qout[4], q1[4], q2[4])` | Умножение кватернионов |

**Прочее:**

| Метод | Описание |
|-------|----------|
| `Curve(ECurveType, t, points)` | Кривые: `CatmullRom`, `NaturalCubic`, `UniformCubic` |
| `NearestPoint(beg, end, pos)` | Ближайшая точка на отрезке |
| `AngleFromPosition(origin, dir, target)` | Угол на цель от направления (рад) |
| `ConePoints(origin, len, halfAngle, offset, out left, out right)` | Точки 2D конуса |
| `BlendCartesian(sample, inPositions, outWeights)` | Веса blend space |
