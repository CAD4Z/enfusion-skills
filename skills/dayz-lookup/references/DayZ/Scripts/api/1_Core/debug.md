Debugging tools. Source: `proto/endebug.c`, `debug/`

### Log output

| Function | Description |
|---------|----------|
| `Print(var)` | Print any variable to console/log |
| `PrintFormat(fmt, p1..p9)` | Formatted output (`%1`, `%2`...) |
| `PrintToRPT(var)` | Write to RPT file (fflushes each time — be careful with performance) |
| `DPrint(var)` | Critical messages (debug log) |

### Errors

| Function | Description |
|---------|----------|
| `ErrorEx(msg, severity)` | Error with class/method name as prefix. `INFO` — log, `WARNING`/`ERROR` — messagebox |
| `ErrorExString(msg, out str, severity)` | Same, but saves to a string |
| `Error(msg)` | Messagebox with an error |
| `Error2(title, msg)` | Messagebox with a title |

`ErrorExSeverity`: `INFO`, `WARNING`, `ERROR`

### Stack trace

| Function | Description |
|---------|----------|
| `DumpStack()` | Print call stack to console |
| `DumpStackString(out str)` | Call stack to a string |
| `DebugBreak(condition, p1..p9)` | Breakpoint in C++ (debug environment) |

### Shape — visual debugging

Creation of debug geometry in the world.

**ShapeType:** `BBOX`, `LINE`, `SPHERE`, `CYLINDER`, `DIAMOND`, `PYRAMID`

**ShapeFlags:**

| Flag | Description |
|------|----------|
| `ONCE` | Drawn for one frame, auto-removed. Do not store the pointer |
| `WIREFRAME` | Wireframe only |
| `NOOUTLINE` | Fill only |
| `NOZBUFFER` | Do not compare z-buffer |
| `NOZWRITE` | Do not write to z-buffer |
| `TRANSP` | Semi-transparent |
| `ADDITIVE` | Additive blending (with TRANSP) |
| `DOUBLESIDE` | Two-sided |
| `VISIBLE` | Enabled by default |

**Creation:**

| Method | Description |
|-------|----------|
| `Shape.Create(type, color, flags, p1, p2)` | Basic shape |
| `Shape.CreateLines(color, flags, points[], num)` | Lines |
| `Shape.CreateTris(color, flags, points[], num)` | Triangles |
| `Shape.CreateSphere(color, flags, origin, radius)` | Sphere |
| `Shape.CreateCylinder(color, flags, origin, radius, length)` | Cylinder |
| `Shape.CreateFrustum(hAngle, vAngle, length, color, flags)` | Frustum |
| `Shape.CreateArrow(from, to, size, color, flags)` | Arrow |
| `Shape.CreateMatrix(mat[4], axisLen, arrowSize)` | Coordinate axes (RGB = XYZ) |

**Management:** `SetPosition(pos)`, `SetDirection(dir)`, `SetColor(color)`, `SetMatrix(mat[4])`, `SetFlags(flags)`, `Destroy()`

### DiagMenu — diagnostic menu

Available only in Diag/Developer builds. Allows creating menu items for debugging.

| Method | Description |
|-------|----------|
| `InitScriptDiags()` | Initialize before registration |
| `ClearScriptDiags()` | Clear all script items |
| `RegisterMenu(id, name, parent)` | Register a submenu |
| `RegisterItem(id, shortcut, name, parent, values, callback)` | Item with value selection |
| `RegisterBool(id, shortcut, name, parent, reverse, callback)` | Bool item |
| `RegisterRange(id, shortcut, name, parent, "min,max,start,step", callback)` | Range |
| `Unregister(id)` | Remove item |
| `BindCallback(id, callback)` | Bind callback |
| `GetBool(id)` / `GetValue(id)` / `GetRangeValue(id)` | Get value |
| `SetValue(id, value)` / `SetRangeValue(id, value)` | Set value |

### DebugText — on-screen text

Base class: `DebugText` with methods `GetText()`, `SetText(text)`, `SetTextColor(color)`, `SetFontSize(size)`, `SetBackgroundColor(color)`, `SetPriority(priority)`.

**DebugTextScreenSpace** — screen coordinates:

```cpp
// One-shot text (ONCE — no need to keep the reference)
DebugTextScreenSpace.Create("FPS", DebugTextFlags.ONCE, 0.1, 0.1, 20, COLOR_WHITE);

// Persistent text (keep the ref so you can remove it)
ref DebugTextScreenSpace txt = DebugTextScreenSpace.Create("Hello", 0, 0.5, 0.5);
txt.SetPosition(0.3, 0.3);
```

**DebugTextWorldSpace** — world coordinates:

```cpp
// Text in the world
DebugTextWorldSpace.Create("Here!", DebugTextFlags.ONCE, x, y, z);

// Text in world space (occluded by objects, size in meters)
DebugTextWorldSpace.CreateInWorld("Label", flags, transform, 0.5);
```

**DebugTextFlags:** `DEFAULT`, `CENTER`, `FACE_CAMERA`, `ONCE`, `IN_WORLD`, `DONT_SCALE_POS`, `DONT_SCALE`

### EnProfiler — profiler

Available in developer/diag builds. Launch: `-profile` parameter.

| Method | Description |
|-------|----------|
| `Enable(enable, immediate, sessionReset)` | Enable/disable profiling |
| `SetModule(EnProfilerModule)` | Module to analyze: `CORE`, `GAMELIB`, `GAME`, `WORLD`, `MISSION` |
| `SetFlags(flags)` | `RESET` — reset after sorting, `RECURSIVE` — all modules |
| `SetInterval(frames)` | Data update interval |
| `SortData()` | Force sort |
| `GetTimeOfClass(typename, immediate)` | Time of a class |
| `GetTimeOfFunc(func, typename, immediate)` | Time of a function |
| `GetCountOfFunc(func, typename, immediate)` | Call count of a function |
| `GetAllocationsOfClass(typename, immediate)` | Allocations of a class |
| `GetInstancesOfClass(typename, immediate)` | Current instances |
| `GetTimePerClass(out arr, count)` | Top classes by time |
| `GetTimePerFunc(out arr, count)` | Top functions by time |
| `Dump()` | Output data to log |
