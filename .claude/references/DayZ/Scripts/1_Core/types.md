Обёртки примитивных типов с методами. Источник: `proto/enconvert.c`

### bool

| Метод | Возврат | Описание |
|-------|---------|----------|
| `ToString()` | `string` | `"true"` / `"false"` |

`EBool` enum: `NO = 0`, `YES = 1`

### int

| Константа | Значение |
|-----------|----------|
| `int.MAX` | `2147483647` |
| `int.MIN` | `-2147483648` |

| Метод | Возврат | Описание |
|-------|---------|----------|
| `ToString()` | `string` | Строковое представление |
| `AsciiToString()` | `string` | ASCII код в символ |
| `ToStringLen(int len)` | `string` | С нулями слева: `123.ToStringLen(5)` = `"00123"` |
| `ToHex()` | `string` | В hex: `10.ToHex()` = `"0xA"` |
| `InRange(min, max)` | `bool` | Включительно, опционально `inclusive_min`, `inclusive_max` |

### float

| Константа | Описание |
|-----------|----------|
| `float.MIN` | Минимальное положительное (`FLT_MIN`) |
| `float.MAX` | Максимальное (`FLT_MAX`) |
| `float.LOWEST` | `-FLT_MAX` |

| Метод | Возврат |
|-------|---------|
| `ToString(bool simple = true)` | `string` |

### vector

Тройка `float` (x, y, z). Доступ по индексу: `v[0]`, `v[1]`, `v[2]`. Литерал: `"1 2 3"`.

| Константа | Значение |
|-----------|----------|
| `vector.Up` | `"0 1 0"` |
| `vector.Aside` | `"1 0 0"` |
| `vector.Forward` | `"0 0 1"` |
| `vector.Zero` | `"0 0 0"` |

| Метод | Возврат | Описание |
|-------|---------|----------|
| `ToString(bool beautify = true)` | `string` | `"<1, 0, 1>"` или `"1 0 1"` |
| `Normalize()` | `float` | Нормализует вектор in-place, возвращает длину |
| `Normalized()` | `vector` | Возвращает нормализованную копию |
| `Length()` | `float` | Длина (магнитуда) |
| `LengthSq()` | `float` | Квадрат длины (быстрее) |
| `Distance(v1, v2)` | `float` | **static** — расстояние между точками |
| `DistanceSq(v1, v2)` | `float` | **static** — квадрат расстояния |
| `Dot(v1, v2)` | `float` | **static** — скалярное произведение |
| `Lerp(v1, v2, t)` | `vector` | **static** — линейная интерполяция |
| `Perpend()` | `vector` | Перпендикуляр через cross с Up |
| `Direction(p1, p2)` | `vector` | **static** — направление от p1 к p2 |
| `RandomDir()` | `vector` | **static** — случайный единичный вектор 3D |
| `RandomDir2D()` | `vector` | **static** — случайный единичный вектор XZ |
| `GetRelAngles()` | `vector` | Углы в диапазоне [-180, 180] |
| `VectorToYaw()` | `float` | Yaw из вектора |
| `YawToVector(float)` | `vector` | **static** — вектор из yaw |
| `VectorToAngles()` | `vector` | В сферические координаты (yaw, pitch, roll) |
| `AnglesToVector()` | `vector` | Из сферических координат в единичный вектор |
| `RotationMatrixFromAngles(out mat[3])` | `void` | Матрица вращения из углов |
| `Multiply4(mat[4])` | `vector` | Трансформация позиции матрицей 4x4 |
| `Multiply3(mat[3])` | `vector` | Трансформация вектора матрицей 3x3 |
| `InvMultiply4(mat[4])` | `vector` | Обратная трансформация позиции |
| `InvMultiply3(mat[3])` | `vector` | Обратная трансформация вектора |
| `RotateAroundZeroDeg(vec, axis, angle)` | `vector` | **static** — вращение в градусах |
| `RotateAroundZeroRad(vec, axis, angle)` | `vector` | **static** — вращение в радианах |
| `RotateAroundPoint(point, pos, axis, cos, sin)` | `vector` | **static** — вращение вокруг точки |

### string

| Константа | Значение |
|-----------|----------|
| `string.Empty` | `""` |

**Конвертация:**

| Метод | Возврат | Описание |
|-------|---------|----------|
| `ToInt()` | `int` | `"56"` -> `56` |
| `HexToInt()` | `int` | `"0xFF"` -> `255` |
| `ToFloat()` | `float` | `"56.6"` -> `56.6` |
| `ToVector()` | `vector` | `"1 0 1"` -> `<1,0,1>` |
| `ToAscii()` | `int` | Первый символ в ASCII код |
| `ToType()` | `typename` | Имя типа в typename |

**Работа со строкой:**

| Метод | Возврат | Описание |
|-------|---------|----------|
| `Length()` | `int` | Длина |
| `LengthUtf8()` | `int` | Кол-во UTF8 символов |
| `Hash()` | `int` | Хеш строки |
| `Get(index)` / `str[i]` | `string` | Символ по индексу |
| `Set(index, input)` / `str[i] = x` | `void` | Замена символа |
| `Insert(index, input)` | `void` | Вставка без замены |
| `Substring(start, len)` | `string` | Подстрока |
| `SubstringUtf8(start, len)` | `string` | Подстрока UTF8 |
| `IndexOf(sample)` | `int` | Первое вхождение, -1 если нет |
| `LastIndexOf(sample)` | `int` | Последнее вхождение |
| `IndexOfFrom(start, sample)` | `int` | Поиск с позиции |
| `Contains(sample)` | `bool` | Содержит подстроку |
| `Replace(sample, replace)` | `int` | Замена всех вхождений, возвращает кол-во |
| `ToLower()` | `int` | В нижний регистр in-place |
| `ToUpper()` | `int` | В верхний регистр in-place |
| `Trim()` | `string` | Убрать пробелы (копия) |
| `TrimInPlace()` | `int` | Убрать пробелы in-place |
| `Split(separator, out array)` | `void` | Разбить в массив |
| `Join(separator, tokens)` | `string` | **static** — собрать из массива |
| `Format(fmt, p1..p9)` | `string` | **static** — форматирование (`%1`, `%2`...) |
| `ParseStringEx(out token)` | `int` | Токенизация (модифицирует строку) |
| `ParseString(out tokens[])` | `int` | Разбор в статический массив |
| `ToString(var, type, name, quotes)` | `string` | **static** — любое значение в строку |

### typename

Рефлексия типов в рантайме.

| Метод | Возврат | Описание |
|-------|---------|----------|
| `Spawn()` | `Class` | Создать экземпляр динамически |
| `GetModule()` | `string` | Имя модуля (`"1_Core"`) |
| `ToString()` | `string` | Имя типа |
| `IsInherited(baseType)` | `bool` | Проверка наследования |
| `GetVariableCount()` | `int` | Кол-во переменных/enum-значений |
| `GetVariableName(idx)` | `string` | Имя переменной по индексу |
| `GetVariableType(idx)` | `typename` | Тип переменной |
| `GetVariableValue(inst, idx, out val)` | `bool` | Значение переменной |
| `EnumToString(e, value)` | `string` | **static** — enum значение в строку |
| `StringToEnum(e, name)` | `int` | **static** — строку в enum значение |

### EnumTools

Утилитарная обёртка над `typename` для работы с enum'ами.

| Метод | Описание |
|-------|----------|
| `EnumToString(e, value)` | Enum в строку |
| `StringToEnum(e, name)` | Строку в enum |
| `GetEnumSize(e)` | Кол-во значений |
| `GetEnumValue(e, idx)` | Значение по индексу |
| `GetLastEnumValue(e)` | Последнее значение |
