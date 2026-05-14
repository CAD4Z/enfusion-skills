# Modded classes

Full breakdown of the `modded` system in Enforce Script — the primary mechanism for extending and overriding code without modifying the original scripts. `SKILL.md` contains a summary of the key rules; this file has the detailed semantics, inheritance chains, edge cases, and the choice between approaches.

---

## 1. The modded mechanism

The `modded` keyword inserts a descendant into a class hierarchy **without changing the class name**. After that, every `new OriginalClass()` creates an instance of the modded version. Access to the original goes through `super`.

This is the central modding mechanism in DayZ: it lets you extend vanilla classes (`PlayerBase`, `MissionGameplay`, `ItemBase`) without editing the game's source.

```c
// Original (vanilla or from another mod)
class Greeter
{
    void Say()
    {
        Print("Hello original");
    }
}

// Our mod
modded class Greeter
{
    override void Say()
    {
        Print("Hello modded");
        super.Say();
    }
}

void Test()
{
    Greeter g = new Greeter();
    g.Say();
    // Hello modded
    // Hello original
}
```

The class is still called `Greeter` from the outside — no `ModdedGreeter` or similar names. Everyone working with `Greeter` is automatically working with the modded version.

---

## 2. `modded class` does NOT accept inheritance

The form `modded class Foo: Bar` is **silently ignored** by the compiler. The `: Bar` is dropped without warning, and `Foo` remains a descendant of its original.

```c
// bad — : ManBase is ignored by the compiler with no warning
modded class PlayerBase: ManBase
{
    // PlayerBase still descends from the original PlayerBase, not ManBase
    // The author misleads the reader
}

// good — no inheritance
modded class PlayerBase
{
    // ...
}
```

**Why this matters:** `modded class` isn't a new class declaration — it's an **addition to an existing hierarchy**. You can't change the parent through modded at all. If you need to fit into a different hierarchy, that's a new class via regular `class Foo: Bar`, not modded.

See also `engine-pitfalls.md` — this is one of the trickiest gotchas, because the compiler doesn't error out and the author can spend hours debugging "why isn't my modded inheriting properly".

---

## 3. modded chains and the super order

When several mods do `modded class Foo`, **each subsequent modded inherits from the previous one**, not from the original. The `super` chain runs through all modded descendants in load order.

```c
// Original
class Greeter
{
    void Say()
    {
        Print("original");
    }
}

// Mod 1 (loaded first)
modded class Greeter
{
    override void Say()
    {
        Print("mod1");
        super.Say();
    }
}

// Mod 2 (loaded second, inherits from Mod 1)
modded class Greeter
{
    override void Say()
    {
        Print("mod2");
        super.Say();
    }
}

void Test()
{
    Greeter g = new Greeter();
    g.Say();
    // mod2
    // mod1
    // original
}
```

**Practical consequences:**

- Mod load order affects the chain. This is outside any single mod's control — other mods may slot in earlier or later.
- Don't assume "my modded is a direct descendant of vanilla". Another mod may be in between.
- Don't bypass `super` to reach the original directly (e.g., trying to call a vanilla method explicitly) — that will break the chain for other mods.

---

## 4. Order of logic relative to `super`

When overriding a method through modded, the order of the `super` call is determined by the modification's intent:

**Logic BEFORE the original** — the modification gates or pre-processes:

```c
modded class Container
{
    override bool CanAccept(Item item)
    {
        if (IsBlacklisted(item)) {
            return false;   // block before the original gets to decide
        }

        return super.CanAccept(item);
    }
}
```

**Logic AFTER the original** — the modification supplements or reacts:

```c
modded class Container
{
    override void OnItemAdded(Item item)
    {
        super.OnItemAdded(item);    // original does its work first
        NotifyObservers(item);       // then we react
    }
}
```

**Replacing the original (no super)** — acceptable in rare cases when the mod fully replaces the behaviour. Use carefully: it breaks the chain for other mods.

```c
modded class Container
{
    override void DoSomething()
    {
        // Original isn't called — other mods chained after us also don't run
        DoMyVersion();
    }
}
```

**Heuristic:** when in doubt about ordering — try "call `super`, then your logic" first. It's the safest default and breaks other mods least often.

---

## 5. Access to private members of the original

A modded class can access `private` fields and methods of the original, and override `private` methods. This is an exception to the usual access rules — it applies specifically to modded.

```c
// Original
class Vault
{
    private int m_SecretValue = 42;

    private void DoInternal()
    {
        Print("internal work");
    }
}

// Mod
modded class Vault
{
    void Inspect()
    {
        Print(m_SecretValue);    // access to private field — allowed
        DoInternal();             // call to private method — allowed
    }

    override void DoInternal()    // overriding a private method — allowed
    {
        super.DoInternal();
        Print("modded extension");
    }
}
```

**When to use:**

- When you need to extend or replace internal behaviour of the original and there's no public API for it.

**When NOT to use:**

- When a public or protected equivalent exists. Reaching into private signals a fragile contract — private internals can change without warning in a new version of the original.
- When patching through private is a "dirty workaround" of normal design. Better to ask the original's developers for a protected extension point.

---

## 6. Modded constants and value overrides

A modded class can override values of constants from the original. The last-loaded mod wins.

```c
// Original
class Config
{
    const int MAX_SLOTS = 4;
}

// Mod 1
modded class Config
{
    const int MAX_SLOTS = 8;
}

// Mod 2 (loaded after Mod 1)
modded class Config
{
    const int MAX_SLOTS = 12;   // resulting value at runtime
}

void Test()
{
    Print(Config.MAX_SLOTS);    // 12
}
```

A modded class can also **add new constants** that didn't exist on the original:

```c
modded class Config
{
    const int MAX_SLOTS = 12;
    const int NEW_MOD_CONSTANT = 99;   // new constant
}
```

**Caution with mod constants:** values depend on load order. If multiple mods override the same constant, the final value is determined by whoever loaded last. This is outside any single mod's control.

---

## 7. When modded, when regular inheritance

This is the key design fork — getting it right saves a lot of debugging.

### Use `modded class Foo` when:

- You need to change the behaviour of an **existing** class that **is already created** in game or other-mod code.
- You want every `new Foo()` in someone else's code to automatically use your version.
- The goal is to patch, extend, intercept, or override.

Examples: `modded class PlayerBase`, `modded class MissionGameplay`, `modded class ItemBase`.

### Use regular `class Foo: Bar` when:

- You're creating a **new** class that didn't exist in the hierarchy.
- You want to keep your entity clearly separate from vanilla (e.g., a custom item, a custom UI window).
- You don't need to intercept `new Bar()` — you control where `Foo` is created.

Examples: `class CustomMarker: Marker`, `class HudPanel: ScriptedWidgetEventHandler`.

### Comparison

| | `modded class Foo` | `class CustomFoo: Foo` |
|---|---|---|
| Name in code | `Foo` (same) | `CustomFoo` (new) |
| `new Foo()` uses | your version | the original |
| `new CustomFoo()` uses | — | your version |
| Changes behaviour of existing instances | yes | no |
| Mod/vanilla boundary clarity | blurred | explicit |

### Antipattern: modded where inheritance is needed

```c
// bad — modded for a new conceptually separate class
modded class Marker
{
    // I want my own custom marker, but through modded every marker in the game becomes mine
    // That's not what's needed — other markers should stay original
}

// good — inheritance for a new class
class CustomMarker: Marker
{
    // Only my markers, originals stay as they were
}
```

### Antipattern: inheritance where modded is needed

```c
// bad — inheritance to intercept an existing class
class MyPlayer: PlayerBase
{
    // The game creates PlayerBase directly, not MyPlayer
    // This code never runs for actual players
}

// good — modded to intercept
modded class PlayerBase
{
    // Every player in the game now uses this code
}
```

---

## 8. Constructors in a modded class

A modded class **doesn't declare its constructor as `modded`** — it just overrides the existing constructor of the original. The behaviour is the same as for methods: your logic plus `super` to call the original constructor.

```c
// Original
class Service
{
    string m_Name;

    void Service(string name)
    {
        m_Name = name;
        Print("Service created: " + name);
    }
}

// Mod
modded class Service
{
    int m_ExtraField;

    void Service(string name)
    {
        super.Service(name);    // call to the original constructor
        m_ExtraField = 0;
        Print("Modded extension initialized");
    }
}
```

**Important:** the modded constructor's signature **must match** the original's. You can't add new parameters to the constructor through modded — it breaks the object's creation contract.

If you need extra data, initialize it through a separate setup method called after `new`.

---

## 9. Fields in a modded class

A modded class can add new fields to the original. They exist only in the modded version — original code knows nothing about them.

```c
modded class PlayerBase
{
    int m_Stamina;
    ref array<ref Buff> m_ActiveBuffs;

    void PlayerBase()
    {
        super.PlayerBase();
        m_Stamina = 100;
        m_ActiveBuffs = {};
    }
}
```

**Compatibility with other mods** — collisions are possible if another mod adds a field with the same name. Whether to use a module prefix on new fields in modded classes is a project-level decision, not a universal rule. See `code-style.md` section 5 on naming.

---

## 10. When modded doesn't work

Not everything in DayZ can be modified through `modded`:

- **`proto native` methods** — implemented in C++, can't be overridden from script. But you can override **wrappers** on the script side if they exist.
- **Final classes** — some engine classes are marked as non-moddable. Attempting `modded` results in a compile error.
- **Engine data structures** (e.g., low-level engine classes) — not meant for modding.

If `modded class Foo` produces a compile error "cannot mod this class", that's a signal you need a different approach (hooks via events, indirection through another class, etc.).
