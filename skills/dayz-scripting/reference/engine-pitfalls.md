# Pitfalls and segfaults

Catalog of known issues in the Enfusion engine and Enforce Script language. Every entry is a reproducible problem, not a theoretical one. Format: symptom → cause → safe pattern → bad/good examples.

`SKILL.md` contains a summary of the most dangerous ones. This is the full catalog with details.

---

## 1. Empty `#ifdef` / `#ifndef` blocks

**Symptom:** segfault during compilation or load, with no clear error message.

**Cause:** the Enforce Script preprocessor crashes on empty conditional blocks, even when the body contains only comments.

**Safe pattern:** either remove the block, or place at least one real statement inside it.

```c
// bad — crash
#ifdef FOO
    // TODO: add logic
#endif

// bad — crash, a comment doesn't count as a statement
#ifdef FOO
#endif

// good — has a real statement
#ifdef FOO
    int dummy;
#endif

// good — block removed
```

---

## 2. Complex expressions in array assignment

**Symptom:** segfault at the moment of assignment.

**Cause:** compiler bug parsing complex expressions on the right-hand side of an assignment to an array element.

**Safe pattern:** use an intermediate variable to evaluate the expression, then assign to the array.

```c
class Detector
{
    bool m_IsInside[3];

    // bad — crash
    void TestBad(int index, vector a, vector b, float distSq)
    {
        m_IsInside[index] = vector.DistanceSq(a, b) <= distSq;
    }

    // good — intermediate variable
    void TestGood(int index, vector a, vector b, float distSq)
    {
        bool isInside = vector.DistanceSq(a, b) <= distSq;
        m_IsInside[index] = isInside;
    }
}
```

Applies to static arrays and `[]` access. The same problem also occurs with `array<T>.Set()`.

---

## 3. `foreach` over a getter's return value

**Symptom:** performance drop on large collections, sometimes incorrect results.

**Cause:** the getter is called on **every iteration** of the loop, not once before it starts. If the getter does work or returns a fresh collection — that work is repeated many times.

**Safe pattern:** assign the getter's result to a local variable before the loop.

```c
class Holder
{
    autoptr TStringArray m_Items = {"A", "B", "C"};

    TStringArray GetItems()
    {
        return m_Items;
    }

    // bad — GetItems() runs on every iteration
    void IterateBad()
    {
        foreach (string item: GetItems()) {
            Print(item);
        }
    }

    // good — assigned to a local variable
    void IterateGood()
    {
        TStringArray items = GetItems();
        foreach (string item: items) {
            Print(item);
        }
    }

    // good — direct field access doesn't suffer from this
    void IterateField()
    {
        foreach (string item: m_Items) {
            Print(item);
        }
    }
}
```

---

## 4. Bitwise operators without parens

**Symptom:** the condition behaves differently from what you expected.

**Cause:** in Enforce Script (as in C/C++), comparison operators have **higher** precedence than bitwise ones. Without explicit parens, `a & b == b` parses as `a & (b == b)`.

**Safe pattern:** always wrap bitwise operations in parens when used in conditions.

```c
int flags = 5;
int mask = 4;

// bad — parses as: if (flags & (mask == mask))
// (mask == mask) is always true → flags & 1 → not what you want
if (flags & mask == mask) {
    // ...
}

// good — explicit parens
if ((flags & mask) == mask) {
    // ...
}
```

---

## 5. `switch` without an outer default-return

**Symptom:** compile error "function must return a value", even though the `default` branch obviously returns one.

**Cause:** the compiler doesn't recognize a `return` inside `default` as a guaranteed return from the function and demands another `return` after the `switch`.

**Safe pattern:** lift the `default` return out and place it after the `switch`.

```c
// bad — compile error
string Map(string input)
{
    switch (input) {
        case "A":
        case "B":
            return "X";
        default:
            return "Y";
    }
    // compiler: function must return a value
}

// good — default-return moved outside
string Map(string input)
{
    switch (input) {
        case "A":
        case "B":
            return "X";
    }

    return "Y";
}
```

---

## 6. `delete` on entities

**Symptom:** game crashes when an entity is deleted via `delete`.

**Cause:** entities are managed by the engine; deleting them from script breaks internal invariants.

**Safe pattern:** use `GetGame().ObjectDelete(entity)` for entities. For non-entity Managed objects — null the reference and let the GC do its job.

```c
// bad — crash
EntityAI item = ...;
delete item;

// good — proper API for deleting an entity
EntityAI item = ...;
GetGame().ObjectDelete(item);

// good — for an ordinary Managed object
ref MyData data = new MyData();
data = null;  // ARC will delete it once the last reference is gone
```

See `memory-refs.md` for the full breakdown of object lifecycle.

---

## 7. `int.MIN` in comparisons

**Symptom:** conditions involving the boundary value `int.MIN` behave unexpectedly.

**Cause:** `int.MIN` (`-2147483648`) is a special value — its negation doesn't fit in `int`, which breaks the arithmetic of comparisons.

**Safe pattern:** don't use `int.MIN` directly in comparisons. If you need to check "minimum possible" — use `int.MIN + 1` as the lower bound, or an explicit sentinel.

```c
// bad — `1 < int.MIN` returns true
if (1 < int.MIN) {
    // executes
}

// bad — same problem with the literal
if (1 < -2147483647) {
    // executes
}

// good — use a valid range
if (value > int.MIN + 1) {
    // ...
}
```

In code dealing with boundary integers, check the range explicitly via `>=` from `int.MIN`, not via `<` or `>` against `int.MIN` itself.

---

## 8. `IsClient()` / `IsServer()` during loading

**Symptom:** client code runs on the server (or vice versa) during mod initialization.

**Cause:** during game loading, `IsClient()` returns `false` on the client, and `IsServer()` returns `true` — both lie until loading completes.

**Safe pattern:** in init/load code, use `g_Game.IsDedicatedServer()`. After loading, `IsClient()` / `IsServer()` work correctly.

```c
// bad — in init code
void Init()
{
    if (GetGame().IsClient()) {
        InitClientStuff();   // won't run on the client
    }
    if (GetGame().IsServer()) {
        InitServerStuff();   // will run on the client too
    }
}

// good — reliable check
void Init()
{
    if (!g_Game.IsDedicatedServer()) {
        InitClientStuff();
    }
    if (g_Game.IsDedicatedServer()) {
        InitServerStuff();
    }
}
```

See `SKILL.md` section "Client-server" for the general rule.

---

## 9. Unhelpful compiler error locations

**Symptom:** a compile error points at the wrong file or line — usually at the end of some other `.c` file unrelated to the actual error.

**Cause:** for certain classes of errors (undefined classes from unloaded addons, variable name conflicts), the compiler reports the location of the **last successfully parsed file at EOF**, not the actual error site.

**What to do:**

- If the location looks suspicious — search for the class/variable name from the error text **across the entire project**, not just in the indicated file.
- Verify that all required addons are loaded and available at compile time.
- Look for name collisions across files — variables/classes with the same name in different scopes.

This isn't a bug you can "fix" with a code pattern — it's a quirk of the compiler that you need to know about and account for when debugging.

---

## 10. Logs and crash dumps

**Symptom:** confusion when investigating what happened — exception or actual crash.

**Cause:** files named `crash_<date>_<time>.log` are called "crash", but they contain **exceptions**, not actual crashes. Real segfaults produce different crash dumps (platform-specific: minidump on Windows, core dump on Linux).

**What to do:**

- When investigating an issue, check both kinds of logs.
- If `crash_*.log` has content — that's an exception; you can read the stack trace and message.
- If the process died without a `crash_*.log` entry — look for a platform-level crash dump.

---

## 11. `g_Game.SurfaceIsPond/Sea`, `SurfaceRoadY`, `GetObjectsAtPosition`

**Symptom:** performance drop when these APIs are called frequently.

**Cause:** these methods are inefficiently implemented for their stated purposes and are not meant for hot-path use.

**Safe alternatives:**

- For water checks — `g_Game.GetWaterDepth(pos) <= 0` instead of `SurfaceIsPond` / `SurfaceIsSea`.
- For surface y-coordinate — `g_Game.SurfaceY(x, z)` (faster than `SurfaceRoadY`).
- For finding objects — static class arrays, triggers, `GetScene` methods — all faster than `GetObjectsAtPosition` / `GetObjectsAtPosition3D`.

```c
// bad — slow
bool isInWater = g_Game.SurfaceIsPond(pos) || g_Game.SurfaceIsSea(pos);

// good
bool isInWater = g_Game.GetWaterDepth(pos) <= 0;
```

```c
// bad — slow
void GetSurfaceAt(float x, float z, out vector pos)
{
    float y = g_Game.SurfaceRoadY(x, z);
    pos = Vector(x, y, z);
}

// good
vector GetSurfacePosition(float x, float z)
{
    return Vector(x, g_Game.SurfaceY(x, z), z);
}
```

---

## 12. `proto native` vs script methods

**Symptom:** code slowdown, especially in hot paths with frequent small calls.

**Cause:** calling a `proto native` function from script has overhead due to crossing the script/native boundary. For **simple** operations (e.g., returning a global), a script implementation can be **faster**.

**Heuristic:**

- `proto native` is justified when the native implementation does **expensive work** (heavy computations, complex structures, engine-side index lookups).
- For **simple** operations (getters, trivial checks), a script implementation without the boundary overhead is faster.

This is why `proto native CGame GetGame()` was replaced with `DayZGame GetGame() { return g_Game; }` in modern DayZ — the script version with direct global access is faster than a proto native call.

In your own code:

- Don't wrap trivial operations in proto native "for performance" — the boundary overhead eats the benefit.
- Don't try to rewrite proto native methods doing heavy work as script "for performance" — it will be slower.
