Script system core. Source: `proto/enscript.c`, `proto/proto.c`, `param.c`

### Class

Super-root of all classes in Enforce Script.

| Method | Return | Description |
|-------|---------|----------|
| `IsInherited(type)` | `bool` | Inheritance check |
| `ClassName()` | `string` | Class name |
| `GetDebugName()` | `string` | By default = `ClassName()`, can be overridden |
| `Type()` | `typename` | typename of the object |
| `StaticType()` | `typename` | typename of the variable (not the object) |
| `ToString()` | `string` | String representation |
| `Cast(from)` | `Class` | **static** — safe downcast, null on failure |
| `CastTo(out to, from)` | `bool` | **static** — downcast with check |

```cpp
// Cast pattern
Object obj = g_Game.GetPlayer();
Man player;
if (Class.CastTo(player, obj))
{
    // work with player
}
```

### Managed

Base class for objects managed by ARC (Automatic Reference Counting). Inherit from `Managed` when reference counting via `ref` is needed.

### ScriptModule

A compiled script module. Allows dynamic function invocation.

| Method | Description |
|-------|----------|
| `Call(inst, function, parm)` | Dynamic invocation (new thread) |
| `CallFunction(inst, function, out returnVal, parm)` | Dynamic invocation (current thread) |
| `CallFunctionParams(inst, function, out returnVal, parms)` | Same with a Param object |
| `LoadScript(parent, scriptFile, listing)` | **static** — load a script |

### EnScript

Reflection — dynamic access to variables.

| Method | Description |
|-------|----------|
| `GetClassVar(inst, varname, index, out result)` | Read a variable by name |
| `SetClassVar(inst, varname, index, input)` | Write a variable by name |
| `SetVar(out var, value)` | Set a variable from a string |
| `Watch(var, flags)` | Debug watch on a variable |

### Param1..Param10

Template containers for passing parameters. Inherit from `Param : Managed`. Support serialization.

```cpp
Param param = new Param2<float, string>(3.14, "Pi");
// param.param1 == 3.14
// param.param2 == "Pi"
```

Available: `Param1<T1>` ... `Param10<T1..T10>`. All contain public fields `param1`..`paramN` and methods `Serialize(ctx)` / `Deserializer(ctx)`.

### Global functions

| Function | Description |
|---------|----------|
| `Sort(array[], num)` | Sort a static array (int/float/string) |
| `reversearray(array)` | Reverse order |
| `copyarray(dest, src)` | Copy an array |
| `ParseStringEx(inout input, out token)` | String tokenization (global version) |
| `ParseString(input, out tokens[])` | Parse into an array of tokens |
| `KillThread(owner, name)` | Kill a thread |
| `ThreadFunction(owner, name, backtrace, out line)` | Current thread function |
| `String(s)` | Helper for passing a string as a void parameter |
| `PrintString(s)` | Helper for Print with a string |

### Network adapters

`PacketOutputAdapter` / `PacketInputAdapter` — network serialization.

**Write:** `WriteBool`, `WriteInt`, `WriteFloat`, `WriteString`, `WriteVector`, `WriteIntAsByte` (1 byte), `WriteIntAsUByte`, `WriteIntAsHalf` (2 bytes), `WriteFloatAsByte(val, min, max)`, `WriteFloatAsHalf(val, min, max)`

**Read:** corresponding `Read*` methods.

### Link\<T\>

Wrapper reference to an object: `Init(obj)`, `Ptr()`, `Release()`, `IsNull()`.

### Color utilities

| Function | Description |
|---------|----------|
| `ARGB(a, r, g, b)` | Compose a color from 0-255 components |
| `ARGBF(fa, fr, fg, fb)` | Compose a color from 0.0-1.0 |
| `LerpARGB(c1, c2)` | Linear interpolation of colors |

### Material

| Method | Description |
|-------|----------|
| `SetParam(name, value)` | Set a material parameter |
| `ResetParam(name)` | Reset to default |
| `GetParamIndex(name)` | Index for fast access |
| `SetParamByIndex(index, value)` | Set by index |

### Obsolete

Attribute for marking deprecated methods — generates a compiler warning when used.

```cpp
[Obsolete("Use NewMethod instead")]
void OldMethod() {}
```
