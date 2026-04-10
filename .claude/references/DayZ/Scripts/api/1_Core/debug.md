Инструменты отладки. Источник: `proto/endebug.c`, `debug/`

### Вывод в лог

| Функция | Описание |
|---------|----------|
| `Print(var)` | Вывод любой переменной в консоль/лог |
| `PrintFormat(fmt, p1..p9)` | Форматированный вывод (`%1`, `%2`...) |
| `PrintToRPT(var)` | Запись в RPT файл (fflush каждый раз — осторожно с производительностью) |
| `DPrint(var)` | Критические сообщения (debug log) |

### Ошибки

| Функция | Описание |
|---------|----------|
| `ErrorEx(msg, severity)` | Ошибка с именем класса/метода в префиксе. `INFO` — лог, `WARNING`/`ERROR` — messagebox |
| `ErrorExString(msg, out str, severity)` | То же, но сохраняет в строку |
| `Error(msg)` | Messagebox с ошибкой |
| `Error2(title, msg)` | Messagebox с заголовком |

`ErrorExSeverity`: `INFO`, `WARNING`, `ERROR`

### Stack trace

| Функция | Описание |
|---------|----------|
| `DumpStack()` | Вывод стека вызовов в консоль |
| `DumpStackString(out str)` | Стек вызовов в строку |
| `DebugBreak(condition, p1..p9)` | Breakpoint в C++ (debug environment) |

### Shape — визуальная отладка

Создание debug-геометрии в мире.

**ShapeType:** `BBOX`, `LINE`, `SPHERE`, `CYLINDER`, `DIAMOND`, `PYRAMID`

**ShapeFlags:**

| Флаг | Описание |
|------|----------|
| `ONCE` | Рисуется один кадр, автоудаление. Не сохраняйте указатель |
| `WIREFRAME` | Только каркас |
| `NOOUTLINE` | Только заливка |
| `NOZBUFFER` | Не сравнивать z-buffer |
| `NOZWRITE` | Не записывать в z-buffer |
| `TRANSP` | Полупрозрачный |
| `ADDITIVE` | Аддитивное смешивание (с TRANSP) |
| `DOUBLESIDE` | Двусторонний |
| `VISIBLE` | По умолчанию включён |

**Создание:**

| Метод | Описание |
|-------|----------|
| `Shape.Create(type, color, flags, p1, p2)` | Базовая фигура |
| `Shape.CreateLines(color, flags, points[], num)` | Линии |
| `Shape.CreateTris(color, flags, points[], num)` | Треугольники |
| `Shape.CreateSphere(color, flags, origin, radius)` | Сфера |
| `Shape.CreateCylinder(color, flags, origin, radius, length)` | Цилиндр |
| `Shape.CreateFrustum(hAngle, vAngle, length, color, flags)` | Фрустум |
| `Shape.CreateArrow(from, to, size, color, flags)` | Стрелка |
| `Shape.CreateMatrix(mat[4], axisLen, arrowSize)` | Оси координат (RGB = XYZ) |

**Управление:** `SetPosition(pos)`, `SetDirection(dir)`, `SetColor(color)`, `SetMatrix(mat[4])`, `SetFlags(flags)`, `Destroy()`

### DiagMenu — диагностическое меню

Доступно только в Diag/Developer билдах. Позволяет создавать пункты меню для отладки.

| Метод | Описание |
|-------|----------|
| `InitScriptDiags()` | Инициализировать перед регистрацией |
| `ClearScriptDiags()` | Очистить все скриптовые пункты |
| `RegisterMenu(id, name, parent)` | Зарегистрировать подменю |
| `RegisterItem(id, shortcut, name, parent, values, callback)` | Пункт с выбором значений |
| `RegisterBool(id, shortcut, name, parent, reverse, callback)` | Bool пункт |
| `RegisterRange(id, shortcut, name, parent, "min,max,start,step", callback)` | Диапазон |
| `Unregister(id)` | Удалить пункт |
| `BindCallback(id, callback)` | Привязать callback |
| `GetBool(id)` / `GetValue(id)` / `GetRangeValue(id)` | Получить значение |
| `SetValue(id, value)` / `SetRangeValue(id, value)` | Установить значение |

### DebugText — текст на экране

Базовый класс: `DebugText` с методами `GetText()`, `SetText(text)`, `SetTextColor(color)`, `SetFontSize(size)`, `SetBackgroundColor(color)`, `SetPriority(priority)`.

**DebugTextScreenSpace** — экранные координаты:

```cpp
// Одноразовый текст (ONCE — не нужно хранить ссылку)
DebugTextScreenSpace.Create("FPS", DebugTextFlags.ONCE, 0.1, 0.1, 20, COLOR_WHITE);

// Постоянный текст (сохрани ref для удаления)
ref DebugTextScreenSpace txt = DebugTextScreenSpace.Create("Hello", 0, 0.5, 0.5);
txt.SetPosition(0.3, 0.3);
```

**DebugTextWorldSpace** — мировые координаты:

```cpp
// Текст в мире
DebugTextWorldSpace.Create("Here!", DebugTextFlags.ONCE, x, y, z);

// Текст в мировом пространстве (окклюзируется объектами, размер в метрах)
DebugTextWorldSpace.CreateInWorld("Label", flags, transform, 0.5);
```

**DebugTextFlags:** `DEFAULT`, `CENTER`, `FACE_CAMERA`, `ONCE`, `IN_WORLD`, `DONT_SCALE_POS`, `DONT_SCALE`

### EnProfiler — профайлер

Доступен в developer/diag билдах. Запуск: параметр `-profile`.

| Метод | Описание |
|-------|----------|
| `Enable(enable, immediate, sessionReset)` | Вкл/выкл профилирования |
| `SetModule(EnProfilerModule)` | Модуль для анализа: `CORE`, `GAMELIB`, `GAME`, `WORLD`, `MISSION` |
| `SetFlags(flags)` | `RESET` — сброс после сортировки, `RECURSIVE` — все модули |
| `SetInterval(frames)` | Интервал обновления данных |
| `SortData()` | Принудительная сортировка |
| `GetTimeOfClass(typename, immediate)` | Время класса |
| `GetTimeOfFunc(func, typename, immediate)` | Время функции |
| `GetCountOfFunc(func, typename, immediate)` | Кол-во вызовов функции |
| `GetAllocationsOfClass(typename, immediate)` | Аллокации класса |
| `GetInstancesOfClass(typename, immediate)` | Текущие инстансы |
| `GetTimePerClass(out arr, count)` | Топ классов по времени |
| `GetTimePerFunc(out arr, count)` | Топ функций по времени |
| `Dump()` | Вывод данных в лог |
