# Language conventions

Applied rules for using language constructs in Enforce Script — the patterns and the reasoning behind them.

This file is **about applying the language correctly**, not about working around bugs. The catalog of known issues is in `engine-pitfalls.md`. Memory and reference semantics are in `memory-refs.md`. The modded mechanism is in `modded-classes.md`.

---

## 1. `notnull` in parameters

`notnull` is a parameter modifier guaranteeing that null will not be passed. If something tries to — the compiler/runtime complains, and no check is needed inside the function.

```c
void Inspect(notnull EntityAI entity)
{
    // entity is guaranteed non-null — no check needed
    Print(entity.GetType());
}
```

**When to apply:**

- Internal helper methods where null shouldn't logically arrive.
- Methods where null indicates a caller's bug — better to fail fast and explicitly.
- Property getters and setters.

**When NOT to apply:**

- Public API methods where null is a valid input (e.g., `SetTarget(null)` to clear).
- Methods processing the result of a search (`FindAnyWidget` can return null — let the method decide what to do).
- Engine entry points (callbacks, events) — the engine may pass null in unexpected situations.

**Principle:** `notnull` propagates the non-null guarantee from the caller deeper. This eliminates duplicated checks:

```c
// bad — check duplicated in every method
bool HasInventory(EntityAI entity)
{
    if (entity == null) {
        return false;
    }

    return entity.GetInventory() != null;
}

bool IsArmed(EntityAI entity)
{
    if (entity == null) {
        return false;
    }
    // ...
}

// good — null-check once at the call site, then guaranteed
void DoSomething()
{
    EntityAI entity = FindEntity();
    if (!entity) {
        return;
    }

    Process(entity);
}

void Process(notnull EntityAI entity)
{
    if (HasInventory(entity)) {
        // ...
    }
}

bool HasInventory(notnull EntityAI entity)
{
    return entity.GetInventory() != null;
}
```

---

## 2. Null checks — where and why

Place null checks where you **know what to do with null**. Don't add "defensive" checks that silently return `false` or `0`.

```c
// bad — the check doesn't know what to do with null
bool IsWearingSunglasses(EntityAI entity)
{
    if (entity == null) {
        return false;   // what does this mean? "not wearing" or "doesn't exist"?
    }
    // ...
}

// good — the check is at the point where you can react meaningfully
void UpdateUI()
{
    EntityAI player = GetPlayer();
    if (!player) {
        Log("No player");
        return;
    }

    bool sunglasses = IsWearingSunglasses(player);
    UpdateSunglassesIcon(sunglasses);
}

bool IsWearingSunglasses(notnull EntityAI entity)
{
    // entity is guaranteed non-null
    GameInventory inv = entity.GetInventory();
    if (!inv) {
        // null here has a concrete meaning — no inventory, so nothing is worn
        return false;
    }
    // ...
}
```

**Heuristic:** a null check should **do something** — log, early-return with a meaningful value, fall back to a default. If the only response to null is "silently return false" — better to use `notnull` and force the caller to check.

**Don't add redundant checks.** If null is logically impossible in the context — don't check. An extra check is noise that masks real bugs.

```c
// bad — players always have an inventory; the check is redundant
bool IsArmed(notnull PlayerBase player)
{
    GameInventory inv = player.GetInventory();
    if (!inv) {
        return false;   // if a player has no inventory, that's a serious problem, not "unarmed"
    }
    // ...
}
```

---

## 3. Casting

The primary form is `Class.CastTo(var, val)`. The secondary form is `Foo.Cast(bar)`. C-style casts `(Foo)bar` are forbidden.

### `Class.CastTo` — primary

Combines type cast and result check in one expression:

```c
PlayerBase player;
if (Class.CastTo(player, g_Game.GetPlayer())) {
    player.DoStuff();
}
```

Returns `true` on a successful cast. `player` is assigned only on success (on failure it stays `null` or its previous value — don't rely on this; only access the variable inside the `if`).

### `Foo.Cast` — for deferred checks

When the cast and the use are separated — for example, when the cast is decoupled from usage:

```c
PlayerBase player = PlayerBase.Cast(entity);
// ... other logic ...
if (player) {
    player.DoStuff();
}
```

Also useful in expressions where `Class.CastTo` is awkward syntactically — for example, in a return:

```c
PlayerBase GetCurrentPlayer()
{
    return PlayerBase.Cast(g_Game.GetPlayer());
}
```

### Forbidden: C-style cast

```c
// bad — C-style cast
PlayerBase player = (PlayerBase)entity;

// good — Class.CastTo or Foo.Cast
PlayerBase player;
if (Class.CastTo(player, entity)) {
    // ...
}
```

C-style cast performs no runtime check and allows casting between incompatible types. It's a source of subtle bugs.

### Cast and null-safety

The result of `Cast` can always be null — the cast might have failed. This is a valid case for a null check even on `notnull` parameters:

```c
void HandleEntity(notnull EntityAI entity)
{
    PlayerBase player = PlayerBase.Cast(entity);
    if (player) {
        // entity is a PlayerBase
        player.DoPlayerStuff();
    }
    else {
        // entity is something else
        // ...
    }
}
```

---

## 4. `out` and `inout` parameters

In Enforce Script, parameters are passed by value by default (for primitives and vector/string) or by reference (for objects). The `out` and `inout` modifiers change this behaviour.

### `out` — return a value via parameter

An `out` parameter is passed by reference, and changes inside the function escape outwards:

```c
void GetValues(out int a, out int b, int c)
{
    a = 11;   // changes the caller's variable
    b = 12;   // changes the caller's variable
    c = 13;   // does NOT change — regular by-value parameter
}

void Caller()
{
    int x, y, z;
    GetValues(x, y, z);
    // x = 11, y = 12, z = 0 (z stayed at default)
}
```

**When to apply:**

- Returning multiple values from a function (instead of building a wrapper struct).
- Optional return — the function can return a value via `out`, but sometimes the caller doesn't need it.

**When NOT to apply:**

- If returning a single value — prefer `return`. It's more explicit and readable.
- If the function already returns something via `return` — adding `out` makes it harder to follow.

### `inout` — bidirectional parameter

`inout` means "the function reads the current value and may modify it":

```c
void Increment(inout int counter)
{
    counter = counter + 1;
}

void Caller()
{
    int x = 5;
    Increment(x);
    // x = 6
}
```

Used less often than `out` — typically for accumulators or iterative modifiers.

### Semantics for different types

- **Primitives** (`int`, `float`, `bool`) — without modifier, by value; with `out`/`inout`, by reference.
- **`string`** — without modifier, **by value** (strings behave like primitives); with `out`/`inout`, by reference.
- **`vector`** — without modifier, **by value**; with `out`/`inout`, by reference.
- **Objects** — always passed by reference (it's a reference to the object). `out`/`inout` controls whether the reference itself can be reassigned.

```c
void ChangeData(MyData data)
{
    data.SomeField = 99;       // changes the field on the object (same reference)
    data = new MyData();       // does NOT affect the caller — local reassignment
}

void ChangeData2(out MyData data)
{
    data = new MyData();       // DOES change the caller's reference
}
```

---

## 5. `foreach` with index and map

Standard foreach over values:

```c
foreach (int v: m_Numbers) {
    Print(v);
}
```

With index (for arrays) or key (for maps):

```c
// array with index
foreach (int i, string val: m_Strings) {
    Print("[" + i + "] = " + val);
}

// map with key and value
foreach (string key, int value: m_Map) {
    Print(key + " = " + value);
}
```

The key type in `map<K, V>` determines the type of the first foreach parameter. The value type determines the second.

**Don't use `foreach` over a getter's return value** — the getter is called on every iteration. See `engine-pitfalls.md` item 3.

---

## 6. `switch` — supported types and quirks

`switch` supports integers, constants, and strings:

```c
switch (input) {
    case "open":
        OpenDoor();
        break;
    case "close":
        CloseDoor();
        break;
    default:
        Print("unknown command");
        break;
}
```

**Fall-through via multiple case labels** — allowed and often useful:

```c
switch (state) {
    case STATE_IDLE:
    case STATE_WAITING:
        DoNothing();
        break;
    case STATE_ACTIVE:
        DoWork();
        break;
}
```

**`break` is mandatory** in every branch, except for intentional fall-through (a case with no body falling through to the next).

**`default` goes last.** Placing `default` in the middle is syntactically possible but confuses the reader.

**Switch with returns** — has a compiler quirk; see `engine-pitfalls.md` item 5.

---

## 7. Index operator overloading

A class can implement index access via `[]` through `Set` and `Get` methods. Multiple overloads are allowed without type conflicts.

```c
class Grid
{
    int m_Cells[100];

    void Set(int index, int value)
    {
        m_Cells[index] = value;
    }

    int Get(int index)
    {
        return m_Cells[index];
    }
}

void Test()
{
    Grid g = new Grid();
    g[5] = 42;       // calls Set(5, 42)
    int v = g[5];    // calls Get(5), v == 42
}
```

For multiple index types:

```c
class Lookup
{
    int Get(int index)
    {
        // ...
    }

    int Get(string key)
    {
        // ...
    }

    void Set(int index, int value)
    {
        // ...
    }

    void Set(string key, int value)
    {
        // ...
    }
}
```

**When to use:**

- The class is conceptually a collection or map.
- Index access reads more naturally than a named method.

**When NOT to use:**

- If the class has multiple distinct "indexable" things — e.g., both an item list and a metadata list. Prefer explicit `GetItem(i)`, `GetMeta(i)`.
- If index access hides expensive logic. `g[5]` implies a fast lookup — if a network request or a complex search hides behind it, prefer an explicit method with a clear name.

---

## 8. `super` and `this`

`this` is a reference to the current instance. `super` accesses the same-named method on the base class.

`this` is usually omitted, except to disambiguate:

```c
class Foo
{
    int m_Value;

    void SetValue(int value)
    {
        m_Value = value;       // typically like this
        this.m_Value = value;  // valid but redundant

        // this is needed if a parameter and a field share a name
        // (in practice, prefer renaming, but if there's no choice)
    }
}
```

`super` is required when calling a base-class method from an override:

```c
class Child: Parent
{
    override void DoStuff()
    {
        super.DoStuff();    // call to the original
        // additional logic
    }
}
```

Without `super`, you get a recursive call into the same method — an infinite loop.

In modded classes, `super` reaches the previous level in the modded chain, not directly the original. See `modded-classes.md` section 3.

---

## 9. `auto` — type inference

`auto` infers the variable's type from the right-hand side at compile time:

```c
auto x = 5;                       // int
auto y = 1.0;                     // float
auto p = new MyData();            // MyData
auto items = new array<string>;   // array<string>
```

**When to apply:**

- When the type is obvious from the right-hand side (`new ClassName`, a literal).
- Long generic types where explicit declaration duplicates the code.

**When NOT to apply:**

- When the type isn't obvious from context — explicit declaration helps the reader.
- In public APIs — explicit types are preferred for documenting clarity.

---

## 10. Global access

The main DayZ global is `g_Game`. **`g_Game` directly** is the only correct way to access it. **Don't use `GetGame()`** — it's a proto native function with overhead; direct access is always faster.

```c
// bad
GetGame().GetPlayer();
GetGame().GetWorld().GetCurrentTime();

// good
g_Game.GetPlayer();
g_Game.GetWorld().GetCurrentTime();
```

**Don't introduce new globals.** Use static fields on classes or the singleton pattern on the class itself:

```c
// bad — global function and a separate class
class Manager { }
Manager GetManager() { return new Manager(); }

// good — singleton on the class
class Manager
{
    private static ref Manager s_Instance;

    static Manager GetInstance()
    {
        if (!s_Instance) {
            s_Instance = new Manager();
        }

        return s_Instance;
    }

    private void Manager() {}
}
```

---

## 11. Direct field access vs getters

If a field is public and has no extra logic on read — access it **directly**, without a wrapping getter:

```c
class Settings
{
    int MaxItems;

    // bad — pointless getter with no logic
    int GetMaxItems()
    {
        return MaxItems;
    }
}

void Caller()
{
    // bad — accessing through a getter
    int max = settings.GetMaxItems();

    // good — direct access
    int max = settings.MaxItems;
}
```

**A getter is justified only when:**

- The field needs to be private/protected, and the getter is the sole access point.
- The read requires logic (validation, lazy init, formatting).
- The value is computed, not stored.

```c
class Counter
{
    private int m_Value;

    int GetValue()
    {
        return m_Value;   // justified getter — field is private
    }

    int GetDoubled()
    {
        return m_Value * 2;   // justified getter — computed value
    }
}
```

---

## 12. Constructors with default parameters

Constructor parameters can have default values:

```c
class Marker
{
    string m_Label;
    int m_Color;

    void Marker(string label = "", int color = 0xFFFFFFFF)
    {
        m_Label = label;
        m_Color = color;
    }
}

void Test()
{
    Marker a = new Marker();                  // defaults: "", 0xFFFFFFFF
    Marker b = new Marker("Home");            // label = "Home", color = default
    Marker c = new Marker("Spawn", 0xFF0000FF); // both explicit
}
```

**When to apply:**

- Most usage takes the same values, and explicit specification would be noise.

**When NOT to apply:**

- If the default isn't obvious — better to require an explicit argument. Magic defaults lead to bugs.
- If different parameter combinations require different logic — prefer overloading or several named constructors via static factories.

---

## 13. Function overloading

Function overloading by parameter type is standard:

```c
class Builder
{
    void Add(int value)
    {
        // ...
    }

    void Add(string value)
    {
        // ...
    }

    void Add(MyData value)
    {
        // ...
    }
}
```

Overloading by parameter count also works, but if the only difference is the count, default parameters are usually better (see section 12).

**Don't overload functions doing conceptually different things.** If `Add(int)` adds to a collection while `Add(string)` sends to a server — those are two different functions with different names.
