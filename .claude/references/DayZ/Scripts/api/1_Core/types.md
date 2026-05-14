Wrappers around primitive types with methods. Source: `proto/enconvert.c`

### bool

| Method | Return | Description |
|-------|---------|----------|
| `ToString()` | `string` | `"true"` / `"false"` |

`EBool` enum: `NO = 0`, `YES = 1`

### int

| Constant | Value |
|-----------|----------|
| `int.MAX` | `2147483647` |
| `int.MIN` | `-2147483648` |

| Method | Return | Description |
|-------|---------|----------|
| `ToString()` | `string` | String representation |
| `AsciiToString()` | `string` | ASCII code to character |
| `ToStringLen(int len)` | `string` | Left-padded with zeros: `123.ToStringLen(5)` = `"00123"` |
| `ToHex()` | `string` | In hex: `10.ToHex()` = `"0xA"` |
| `InRange(min, max)` | `bool` | Inclusive, optionally `inclusive_min`, `inclusive_max` |

### float

| Constant | Description |
|-----------|----------|
| `float.MIN` | Smallest positive (`FLT_MIN`) |
| `float.MAX` | Maximum (`FLT_MAX`) |
| `float.LOWEST` | `-FLT_MAX` |

| Method | Return |
|-------|---------|
| `ToString(bool simple = true)` | `string` |

### vector

Triple of `float` (x, y, z). Indexed access: `v[0]`, `v[1]`, `v[2]`. Literal: `"1 2 3"`.

| Constant | Value |
|-----------|----------|
| `vector.Up` | `"0 1 0"` |
| `vector.Aside` | `"1 0 0"` |
| `vector.Forward` | `"0 0 1"` |
| `vector.Zero` | `"0 0 0"` |

| Method | Return | Description |
|-------|---------|----------|
| `ToString(bool beautify = true)` | `string` | `"<1, 0, 1>"` or `"1 0 1"` |
| `Normalize()` | `float` | Normalizes the vector in-place, returns length |
| `Normalized()` | `vector` | Returns a normalized copy |
| `Length()` | `float` | Length (magnitude) |
| `LengthSq()` | `float` | Squared length (faster) |
| `Distance(v1, v2)` | `float` | **static** — distance between points |
| `DistanceSq(v1, v2)` | `float` | **static** — squared distance |
| `Dot(v1, v2)` | `float` | **static** — dot product |
| `Lerp(v1, v2, t)` | `vector` | **static** — linear interpolation |
| `Perpend()` | `vector` | Perpendicular via cross with Up |
| `Direction(p1, p2)` | `vector` | **static** — direction from p1 to p2 |
| `RandomDir()` | `vector` | **static** — random 3D unit vector |
| `RandomDir2D()` | `vector` | **static** — random XZ unit vector |
| `GetRelAngles()` | `vector` | Angles in the range [-180, 180] |
| `VectorToYaw()` | `float` | Yaw from vector |
| `YawToVector(float)` | `vector` | **static** — vector from yaw |
| `VectorToAngles()` | `vector` | To spherical coordinates (yaw, pitch, roll) |
| `AnglesToVector()` | `vector` | From spherical coordinates to a unit vector |
| `RotationMatrixFromAngles(out mat[3])` | `void` | Rotation matrix from angles |
| `Multiply4(mat[4])` | `vector` | Transform a position with a 4x4 matrix |
| `Multiply3(mat[3])` | `vector` | Transform a vector with a 3x3 matrix |
| `InvMultiply4(mat[4])` | `vector` | Inverse position transform |
| `InvMultiply3(mat[3])` | `vector` | Inverse vector transform |
| `RotateAroundZeroDeg(vec, axis, angle)` | `vector` | **static** — rotation in degrees |
| `RotateAroundZeroRad(vec, axis, angle)` | `vector` | **static** — rotation in radians |
| `RotateAroundPoint(point, pos, axis, cos, sin)` | `vector` | **static** — rotation around a point |

### string

| Constant | Value |
|-----------|----------|
| `string.Empty` | `""` |

**Conversion:**

| Method | Return | Description |
|-------|---------|----------|
| `ToInt()` | `int` | `"56"` -> `56` |
| `HexToInt()` | `int` | `"0xFF"` -> `255` |
| `ToFloat()` | `float` | `"56.6"` -> `56.6` |
| `ToVector()` | `vector` | `"1 0 1"` -> `<1,0,1>` |
| `ToAscii()` | `int` | First character to ASCII code |
| `ToType()` | `typename` | Type name to typename |

**String manipulation:**

| Method | Return | Description |
|-------|---------|----------|
| `Length()` | `int` | Length |
| `LengthUtf8()` | `int` | Number of UTF8 characters |
| `Hash()` | `int` | String hash |
| `Get(index)` / `str[i]` | `string` | Character by index |
| `Set(index, input)` / `str[i] = x` | `void` | Replace a character |
| `Insert(index, input)` | `void` | Insert without replacement |
| `Substring(start, len)` | `string` | Substring |
| `SubstringUtf8(start, len)` | `string` | UTF8 substring |
| `IndexOf(sample)` | `int` | First occurrence, -1 if none |
| `LastIndexOf(sample)` | `int` | Last occurrence |
| `IndexOfFrom(start, sample)` | `int` | Search from a position |
| `Contains(sample)` | `bool` | Contains substring |
| `Replace(sample, replace)` | `int` | Replace all occurrences, returns count |
| `ToLower()` | `int` | To lowercase in-place |
| `ToUpper()` | `int` | To uppercase in-place |
| `Trim()` | `string` | Strip whitespace (copy) |
| `TrimInPlace()` | `int` | Strip whitespace in-place |
| `Split(separator, out array)` | `void` | Split into an array |
| `Join(separator, tokens)` | `string` | **static** — join from an array |
| `Format(fmt, p1..p9)` | `string` | **static** — formatting (`%1`, `%2`...) |
| `ParseStringEx(out token)` | `int` | Tokenization (modifies the string) |
| `ParseString(out tokens[])` | `int` | Parse into a static array |
| `ToString(var, type, name, quotes)` | `string` | **static** — any value to string |

### typename

Runtime type reflection.

| Method | Return | Description |
|-------|---------|----------|
| `Spawn()` | `Class` | Dynamically create an instance |
| `GetModule()` | `string` | Module name (`"1_Core"`) |
| `ToString()` | `string` | Type name |
| `IsInherited(baseType)` | `bool` | Inheritance check |
| `GetVariableCount()` | `int` | Number of variables / enum values |
| `GetVariableName(idx)` | `string` | Variable name by index |
| `GetVariableType(idx)` | `typename` | Variable type |
| `GetVariableValue(inst, idx, out val)` | `bool` | Variable value |
| `EnumToString(e, value)` | `string` | **static** — enum value to string |
| `StringToEnum(e, name)` | `int` | **static** — string to enum value |

### EnumTools

Utility wrapper over `typename` for working with enums.

| Method | Description |
|-------|----------|
| `EnumToString(e, value)` | Enum to string |
| `StringToEnum(e, name)` | String to enum |
| `GetEnumSize(e)` | Number of values |
| `GetEnumValue(e, idx)` | Value by index |
| `GetLastEnumValue(e)` | Last value |
