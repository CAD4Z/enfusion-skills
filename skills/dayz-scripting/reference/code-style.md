# Code style

Full code style for `.c` files. `SKILL.md` carries the compressed contract; this file settles what it leaves open.

---

## 1. Block braces

**Allman** (brace on a new line) — for `class` and function/method signatures:

```c
class AnimBuilder
{
    void Build()
    {
        // ...
    }
}
```

**K&R** (brace on the same line) — for all control flow constructs inside function bodies: `if`, `else`, `else if`, `for`, `while`, `foreach`, `switch`:

```c
if (condition) {
    DoStuff();
}
else {
    DoOther();
}

foreach (Widget w: m_Widgets) {
    w.Show(true);
}
```

`else` and `else if` go on a new line after the previous block's closing brace, never on the same line (`} else {` is forbidden).

## 2. Braces are always required

Control flow constructs with a single-statement body **must** have curly braces. One-liners are forbidden — minimum three lines:

```c
// bad
if (!m_Root) return;
if (!m_Root) { return; }

// good
if (!m_Root) {
    return;
}
```

Applies to all control flow constructs, including every `else if` branch.

## 3. One statement per line

Never split across multiple lines:

- function and method signatures (a long parameter list stays on one line);
- function and method calls;
- argument lists;
- field declarations with attributes.

```c
// good — long signature on one line
AnimBuilder Rotation(float fromX, float fromY, float fromZ, float toX, float toY, float toZ)
{
    // ...
}

// good — long call on one line
PrintFormat("[Anim] launch widget=%1 prop=%2 dur=%3 loop=%4", w.GetName(), p, d, loop);

// good — attribute and declaration on one line
[NonSerialized()] protected ref array<ref SubRecord> m_Subs;
```

Blank lines **inside** function bodies are allowed and encouraged for grouping logic. Blank lines **between** method declarations within a class are allowed and encouraged for visual separation.

## 4. Blank line before `return`

A blank line is placed before `return` if it is the **final statement of the function in the outermost scope of the body** and there is code preceding it:

```c
// good — final return, blank line required
bool IsReady()
{
    if (!m_Root) {
        return false;
    }
    Finalize();

    return true;
}
```

For guard returns at the start of a function and returns inside nested blocks, the blank line is **not required**:

```c
void Foo()
{
    if (!valid) {
        return;   // guard — no blank line above
    }

    DoStuff();

    return;
}

Anim Find(int id)
{
    foreach (Anim a: m_Anims) {
        if (a.GetId() == id) {
            return a;   // nested — no blank line above
        }
    }

    return null;
}
```

## 5. Naming

| Category | Style | Example |
|----------|-------|---------|
| Classes, structs | `PascalCase` | `AnimBuilder`, `CompassMarker` |
| Methods, functions | `PascalCase` | `GetRoot`, `CancelAllAnims` |
| Private/protected fields | `m_PascalCase` | `m_Root`, `m_AnimHandles`, `m_OwnsRoot` |
| Static fields | `s_PascalCase` | `s_Instance`, `s_TickBuffer` |
| Public fields | `PascalCase` | `WorldPos`, `MaxItems` |
| Widget fields (auto-bind by `name=` from `.layout`) | `PascalCase` | `CpBg`, `TitleLabel`, `SubmitButton` |
| Parameters, local variables | `camelCase` | `int count`, `Widget parent`, `float angleDelta` |
| Enum type | `PascalCase` | `AnimProperty` |
| Enum values | `UPPER_SNAKE_CASE` | `AnimProperty.ALPHA` |
| Global/module constants | `UPPER_SNAKE_CASE` | `COMPASS_FADE_END_PX` |

**The `m_` prefix** applies only to private and protected fields of classes. After the prefix — PascalCase: `m_Subs`, `m_AnimHandles`, `m_TickBuffer`.

**The `s_` prefix** applies only to static fields of classes. After the prefix — PascalCase: `s_Subs`, `s_AnimHandles`, `s_TickBuffer`.

**Widget fields** are named to match the `name=` of the corresponding widget in the `.layout` file — auto-bind resolves them by name through reflection. Both the field and the `name=` are written in `PascalCase`.

**Module prefix** — if the project adopts a module prefix (e.g., `UIB_` for UIBeans), it applies to classes, enum types, global/module constants, and optionally to public API names. This is a project-level decision, not a universal rule. Within a project, follow the adopted scheme.

## 6. Column alignment

Groups of consecutive field declarations or assignments are aligned by column — type, name, `=`. A group is a sequence of lines without a separating blank line and without code of a different kind in between.

```c
// field declarations — align by type and name
[NonSerialized()] Widget           m_Widget;
[NonSerialized()] Base             m_Owner;

AnimProperty m_Property = AnimProperty.NONE;
bool         m_HasExplicitFrom;
float        sv1, sv2, sv3;
float        ev1, ev2, ev3;

// assignments — align by =
m_Property        = AnimProperty.POSITION;
m_HasExplicitFrom = true;
sv1               = fromX;
sv2               = fromY;
```

If alignment isn't visible from a single line of an assignment in the current file's style — match it.

## 7. `[NonSerialized()]` inline

The `[NonSerialized()]` attribute is written **on the same line** as the field declaration, aligned to the common column with neighbouring fields in the group:

```c
[NonSerialized()] protected Widget                       m_Root;
[NonSerialized()] protected bool                         m_Initialized;
[NonSerialized()] protected bool                         m_OwnsRoot;
[NonSerialized()] protected ref array<ref SubRecord>     m_Subs;
[NonSerialized()] protected ref array<ref AnimHandle>    m_AnimHandles;
```

Never break the attribute onto a separate line.

## 8. Comments

**Single-line `//`** is the primary format for all kinds of comments in code.

**Doc blocks `/** */`** with doxygen tags are allowed for documenting classes and public APIs:

```c
/**
 * @brief Animation builder for widget property tweens
 * @note Each builder is single-use — call Launch() once
 */
class AnimBuilder
{
    /**
     * @brief Set rotation tween from current to target Euler angles
     * @param fromX Starting X angle in degrees
     * @param toX Target X angle in degrees
     */
    AnimBuilder Rotation(float fromX, float fromY, float fromZ, float toX, float toY, float toZ)
    {
        // ...
    }
}
```

**Inline `/* */` blocks are forbidden** (the doc-block exception above is the only exception).

**Sentence case, no trailing period** in short single-line comments:

```c
// Camera-yaw-driven compass strip — top-level HUD for the whole mission
```

**Language is English.** In comments, identifiers, and any string literals in code.

### Two roles of comments

**1. Doc header** — above a class or method declaration. Explains intent and hidden invariants. Written only when this isn't obvious from the name and signature. Can be either in `//` form or in `/** */` form with doxygen tags:

```c
// Opt-in to GUI update queue. Default: no ticks, zero cost.
// MUST return a constant value for the lifetime of the instance — the result
// is captured in ctor (Insert) and dtor (Remove); a changing return would
// leak a tick subscription or fail to remove it
bool IsUpdated()
{
    return false;
}
```

The doxygen format is preferred for public APIs, especially when documentation generation is in use.

**2. Inline-why** — inside a method body, above a non-trivial line or block. Explains **why**, not what. Used only when the code contains a non-obvious decision — an edge case, a hack, a performance trade-off:

```c
// Re-entrance-safe: snapshot active anims before ticking so OnComplete
// callbacks that cancel/start animations don't corrupt the iteration
foreach (Anim a: m_TickBuffer) {
    // ...
}
```

### When NOT to write a comment

- Getters/setters whose name precisely describes what happens: `GetRoot`, `SetVisible`.
- Trivial constructors/destructors with no side effects.
- Obvious lines of code — don't restate what the code does if the names are self-describing.

Don't leave comments like "Returns the root widget" or "Clears the list" — they rot and add no information. Absence of a comment is better than a noisy one.

## 9. Indentation

4 spaces, no tabs. One indent per nesting level.

## 10. Other

- `#ifdef DIAG_DEVELOPER` blocks follow the same rules — braces, indentation, alignment.
- `ref` / `autoptr` go directly before the type: `ref array<ref Anim>`.

## 11. Localization

Any string a player can read goes through a localization key, not a literal. Keys are `#STR_` plus a module prefix, defined in the mod's `.csv` tables and resolved by the engine at display time.

```c
// bad — literal reaches the screen
m_Label.SetText("Compass calibrated");

// good — key
m_Label.SetText("#STR_UIB_COMPASS_CALIBRATED");
```

```
-- in a layout, the same rule applies to `text`
text "#STR_UIB_COMPASS_TITLE"
```

This is the one exception to "string literals are English" in section 8: that rule governs internal strings — log lines, class names, config values, debug output — which stay literal English and never take a key. The split is by audience, not by language: if a player sees it, it is a key.
