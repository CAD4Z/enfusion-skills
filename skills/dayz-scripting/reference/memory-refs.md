# Memory and references

Full breakdown of memory and reference handling in Enforce Script. `SKILL.md` contains a summary of the key rules; this file has the detailed semantics, rationale, and edge cases.

---

## 1. Managed classes and automatic memory management

Enforce Script does not have a tracing garbage collector in the sense of languages like Java or C#, but it does have **automatic reference counting** (ARC) for classes inheriting from `Managed`. Every regular reference to a Managed object is counted — when the last one disappears, the object is deleted automatically.

**All entities in DayZ** inherit from `Managed` through a chain of base classes. Anything in `3_Game/` and above is automatically Managed — no need to inherit from `Managed` explicitly.

For **non-Managed classes** (created in `1_Core/` or `2_GameLib/`), reference counting does not apply — memory management is manual. In practice, in most mods, everything the modder writes is already Managed by default.

```c
// Managed automatically — no explicit declaration needed
class Anim
{
    // ...
}

// Explicit inheritance from Managed — for non-game layers
class LowLevelHelper: Managed
{
    // ...
}
```

---

## 2. Strong and weak references

In Enforce Script, all references split into **strong** (`ref`) and **weak** (no modifier).

| Type | Behaviour |
|------|-----------|
| **Strong** (`ref`) | Increments the reference count, keeps the object alive |
| **Weak** (default) | Points to the object but does not increment the count |

By default, **strong** references in:
- Local variables inside functions.
- Function arguments.
- Function return values.

Class fields are **weak** by default. To make a field hold a strong reference, an explicit `ref` is required:

```c
class Parent
{
    ref Child m_Child;     // strong — keeps Child alive as long as Parent lives
}

class Child
{
    Parent m_Parent;       // weak — does not keep Parent alive
}
```

**Single-owner principle:** there should be **one strong reference** per Managed object, held by its owner. This rules out reference cycles and gives a predictable destruction order.

```c
// bad — two strong references to the same object
class BadOwner
{
    ref MyData m_Primary;
    ref MyData m_Secondary;

    void BadOwner()
    {
        MyData data = new MyData();
        m_Primary = data;
        m_Secondary = data;   // second strong reference
    }
}

// good — one strong, one weak
class GoodOwner
{
    ref MyData m_Primary;     // owns
    MyData m_WeakRef;          // observes only

    void GoodOwner()
    {
        m_Primary = new MyData();
        m_WeakRef = m_Primary;
    }
}
```

---

## 3. Key rule: `ref` only on class fields

This is the critical rule whose violation breaks reference counting and leads to crashes.

**`ref` is allowed in:**
- Class fields (private, protected, public).
- Template type parameters (`array<ref T>`, `map<int, ref T>`).

**`ref` is NOT allowed in:**
- Function parameters.
- Function return types.
- Local variables.
- `typedef`s.

```c
class Owner
{
    // good — ref on a field
    ref MyData m_Data;
    ref array<ref MyData> m_Items;

    // good — template parameter
    void Foo(ref MyData data)   // BAD! function parameter
    {
        // ...
    }
}

// bad — ref in parameter
void ProcessBad(ref MyData data)
{
    // ...
}

// good — parameter without ref
void ProcessGood(MyData data)
{
    // ...
}

// bad — ref in local variable
void MakeBad()
{
    ref MyData data = new MyData();   // BAD
}

// good — no ref, locals are strong by default
void MakeGood()
{
    MyData data = new MyData();
}

// bad — ref in return type
ref MyData CreateBad()
{
    ref MyData result = new MyData();
    return result;
}

// good — no ref
MyData CreateGood()
{
    MyData result = new MyData();
    return result;
}

// bad — ref in typedef
typedef ref MyData MyDataRef;

// good — no ref
typedef MyData MyDataRef;
```

**Never use `new ref T()`** — `ref` modifies a variable or field, not the object being created:

```c
// bad
ref MyData data = new ref MyData();

// good
ref MyData data = new MyData();
```

**Why it works this way:**
- Locals and parameters are **already strong** — adding `ref` is meaningless and harmful.
- In return values, `ref` interferes with the temporary reference handling during the return — this causes either premature deletion or a leak.
- In `typedef`, `ref` introduces implicit strong references in places where the author of the using code doesn't expect them.

---

## 4. `ref` with arrays

Arrays are objects, and the `ref` rules apply to both the arrays themselves and their contents.

```c
class Holder
{
    array<MyData> m_A;                 // weak ref to array (array deleted by ARC immediately)
    ref array<MyData> m_B;             // strong ref to array, array holds weak references
    ref array<ref MyData> m_C;         // strong ref to array, array holds strong references
}
```

**What to choose:**

- **`array<T>` without `ref` on a field** — when the array is created and owned elsewhere, and this field merely observes. Rare case.
- **`ref array<T>`** — when the array belongs to this class but the elements belong to someone else (just references).
- **`ref array<ref T>`** — when the array belongs to this class and holds onto its elements. The most common case for collections of owned objects.

Example of the last case — an array of animations managed by a manager:

```c
class AnimManager
{
    ref array<ref Anim> m_Anims;       // array owns the animations

    void AnimManager()
    {
        m_Anims = {};
    }

    void AddAnim(Anim a)
    {
        m_Anims.Insert(a);              // array now holds a strong reference to a
    }
}
```

---

## 5. `autoptr` — RAII semantics

`autoptr` is a modifier that ties an object's lifetime to the variable's scope. When the variable leaves the scope, the object is automatically deleted.

```c
void Process()
{
    autoptr MyData data = new MyData();
    // ... work with data ...
}   // data is automatically deleted here
```

**When to use `autoptr`:**

- **Local owning variables** — the object is created in the function, used only inside it, never escapes.
- **Fields that should live exactly as long as the owner does** — an alternative to `ref` with more explicit ownership semantics.

**When NOT to use `autoptr`:**

- If a reference to the object escapes the scope (passed somewhere, returned from the function, stored in another field). Once the scope ends, the object will be deleted, and the surviving references become invalid.

```c
// good — autoptr for a local owner
void DoWork()
{
    autoptr Helper h = new Helper();
    h.Run();
}   // h is deleted here, no external references remain

// bad — autoptr with the reference escaping
void RegisterBad()
{
    autoptr Helper h = new Helper();
    g_HelperRegistry.Add(h);    // a reference to h escapes into the registry
}   // h is deleted here — the registry holds a dangling reference

// good — regular local (strong by default), the registry holds the reference
void RegisterGood()
{
    Helper h = new Helper();
    g_HelperRegistry.Add(h);    // registry holds h, the object lives while it's there
}
```

---

## 6. `ref` vs `autoptr` — choosing

They solve similar problems in different ways:

| | `ref` | `autoptr` |
|---|-------|-----------|
| Reference type | Counted strong | Scope-bound |
| Deletion | When the last reference disappears | When the variable leaves the scope |
| Applies to | Class fields | Local variables and fields |
| Semantics | "I hold this" | "This lives for exactly my lifetime" |

**In this project:**

- **`ref`** — for class members. The primary mechanism.
- **`autoptr`** — for local owning variables that need auto-cleanup at end of scope.

**Don't combine the two** on the same variable. `ref autoptr` or `autoptr ref` is syntactically possible in rare cases but semantically redundant and confusing. Pick one.

---

## 7. `delete` — position

`delete` forcefully destroys an object **ignoring** the reference count. This can leave dangling references elsewhere in the code, leading to crashes or incorrect behaviour.

**Rule: do not use `delete`. Always null the reference and let ARC do its job.**

```c
// bad
ref MyData m_Data = new MyData();
delete m_Data;

// good
ref MyData m_Data = new MyData();
m_Data = null;   // ARC will delete once the last reference is gone
```

**Special case: entities.** Never use `delete` on entity objects — it is a **guaranteed crash**. For entities, use `GetGame().ObjectDelete(entity)`:

```c
EntityAI item = ...;

// bad — crash
delete item;

// good
GetGame().ObjectDelete(item);
```

See also `engine-pitfalls.md` item 6.

---

## 8. Object lifecycle — typical scenarios

### Local object in a function

Strong by default, deleted on scope exit:

```c
void Process()
{
    MyData data = new MyData();
    data.DoStuff();
}   // data is deleted here — last strong reference is gone
```

### Object passed onward

If the object needs to be passed out — don't use `autoptr` locally:

```c
MyData CreateData()
{
    MyData data = new MyData();
    return data;   // returned, the next holder will own
}

void Caller()
{
    MyData data = CreateData();    // Caller now owns
    g_Registry.Add(data);          // or passes onward
}
```

### Object on a class field

Strong reference via `ref`, lives as long as the owner does:

```c
class Owner
{
    ref MyData m_Data;

    void Owner()
    {
        m_Data = new MyData();
    }
}   // m_Data is deleted automatically when Owner is deleted
```

### Releasing a field before owner deletion

Null the reference — ARC deletes the object:

```c
class Owner
{
    ref MyData m_Data;

    void Reset()
    {
        m_Data = null;
        // if no other references existed — the object is deleted right now
    }
}
```

### Forced entity deletion

Only via the game API:

```c
void RemoveItem(EntityAI item)
{
    if (item) {
        GetGame().ObjectDelete(item);
    }
}
```

---

## 9. Constructor and destructor

- The constructor — a function with the class name, called on `new`.
- The destructor — `~ClassName()`, called on object destruction (ARC, explicit nulling of the last reference, scope exit with `autoptr`).
- A class can have one constructor and one destructor.
- The constructor can take parameters; the destructor cannot.
- Both return `void`.
- If the constructor takes no parameters, parentheses on `new` can be omitted.

```c
class Resource
{
    void Resource()
    {
        Print("Created");
    }

    void ~Resource()
    {
        Print("Destroyed");
    }
}

class NamedResource
{
    string m_Name;

    void NamedResource(string name)
    {
        m_Name = name;
    }

    void ~NamedResource()
    {
        Print("Destroyed: " + m_Name);
    }
}

void Method()
{
    Resource a = new Resource;                 // no parens — no parameters
    NamedResource b = new NamedResource("X");  // with parens — has a parameter
}
```

The destructor can do cleanup logic — unsubscribe from events, stop timers, release resources. **Don't call `delete` from the destructor** — ARC handles it. Nulling references inside the destructor isn't necessary either; once the destructor returns, all `ref` fields are released by the runtime anyway.

---

## 10. Reference cycles

ARC cannot detect cycles — if object A holds a strong reference to B and B holds a strong reference to A, neither will be deleted, even when no external references exist.

**Defence against cycles — weak references in the reverse direction:**

```c
class Parent
{
    ref Child m_Child;     // strong — Parent owns Child
}

class Child
{
    Parent m_Parent;       // weak — Child observes only
}
```

When designing ownership, follow the hierarchy: **the parent holds a strong reference to the child, the child holds only a weak one to the parent.** This is the natural pattern in DayZ modding because the entity tree works exactly this way.

---

## 11. Keyword summary

| Keyword | Description |
|---------|-------------|
| `new` | Create an instance |
| `delete` | **Do not use.** Forced deletion, ignores ARC |
| `null` | Null value (no object). The way to release a reference |
| `this` | Reference to the current instance |
| `super` | Access to the base class |
| `ref` | Strong reference (only on class fields) |
| `autoptr` | Scope-bound (auto-cleanup at end of scope) |
| `Managed` | Base class for ARC. In `3_Game+` it's implicit |
