---
name: dayz-scripting
description: Conventions and critical rules for DayZ Enforce Script. Applies to both writing and reviewing code.
when_to_use: Activate before writing or modifying .c files. Do not activate during planning or architectural discussions.
model: opus
paths: ["**/*.c"]
---

# DayZ Scripting

This skill is the single source of truth for DayZ mod development rules. Applies both when writing and when reviewing code.

## Critical language prohibitions

These rules must never be broken. Any violation is a Critical finding at review.

- **Ternary operator is forbidden** (language limitation, not a stylistic choice).
- **Multi-line statements are forbidden** — function signatures, calls, argument lists, and field declarations with attributes must stay on a single line.
- **`ref` only on class fields.** Never in parameters, local variables, return types, or typedefs. Misuse causes reference-counting errors and crashes.
- **Do not use `delete`.** Always null the reference and let the garbage collector clean up. `delete` on entities crashes. See `reference/memory-refs.md`.
- **`modded class` does not inherit.** Writing `modded class Foo: Bar` is silently ignored by the compiler — the `: Bar` part is dropped, and `Foo` remains a descendant of the original. See `reference/modded-classes.md`.

## Code style — key rules

Full code style — `reference/code-style.md`.

**Braces:**
- Allman (brace on a new line) — for `class` and function/method signatures.
- K&R (brace on the same line) — for control flow inside function bodies (`if`, `for`, `while`, `foreach`, `switch`).
- Braces `{}` are always required. One-liners like `if (x) y;` and `if (x) { y; }` are forbidden — minimum three lines.

**Indentation:** 4 spaces, no tabs.

**One statement per line.** Never split signatures, calls, parameter lists, or field declarations across lines.

**Naming:**

| Category | Style | Example |
|----------|-------|---------|
| Classes, structs | `PascalCase` | `AnimBuilder`, `CompassMarker` |
| Methods, functions | `PascalCase` | `GetRoot`, `CancelAllAnims` |
| Private/protected fields | `m_PascalCase` | `m_Root`, `m_AnimHandles` |
| Static fields | `s_PascalCase` | `s_Instance` |
| Public fields | `PascalCase` | `WorldPos`, `MaxItems` |
| Widget fields (auto-bind by `name=` from layout) | `PascalCase` | `CpBg`, `TitleLabel` |
| Parameters, local variables | `camelCase` | `int count`, `Widget parent` |
| Enum type | `PascalCase` | `AnimProperty` |
| Enum values | `UPPER_SNAKE_CASE` | `AnimProperty.ALPHA` |
| Global/module constants | `UPPER_SNAKE_CASE` | `COMPASS_FADE_END_PX` |

If the project adopts a module prefix for classes and constants (e.g., `UIB_AnimBuilder`, `UIB_COMPASS_FADE_END_PX`), follow it. This is a project-level decision, not a universal rule.

**Comments:**
- Single-line `//` is the primary format.
- Doc-blocks `/** */` with doxygen tags (`@brief`, `@param`, `@note`) are allowed for documenting classes and public APIs.
- Inline `/* */` blocks are **forbidden** (the doc-block exception above is the only exception).
- Language is English. In code, identifiers, and string literals.

**`override` is mandatory** when overriding parent methods.

## Memory and references

Full reference — `reference/memory-refs.md`.

- **`ref`** — only on class fields (see Critical prohibitions above).
- **`autoptr`** — for local owning variables with auto-cleanup at end of scope.
- **`delete`** — not used; null the reference instead.
- **All entities in `3_Game/` and above** are automatically Managed — no need to inherit from `Managed` explicitly.

## Modded classes

Full reference — `reference/modded-classes.md`.

- `modded class Foo` — automatically inherits from the original `Foo`.
- The `super` chain runs through all modded descendants in load order.
- **Do not add `: Parent`** to a `modded class` — silently ignored by the compiler with no warning.
- Order of `super.Method()` calls is determined by the modification's intent (before or after your own logic).
- Access to `private` members of the original from a `modded class` is allowed.

## Null-safety and casting

Full reference — `reference/language-rules.md`.

- **`notnull`** in parameters — required where null is invalid input. Removes the need to check inside the function.
- **Always check the result** of `Cast`, `FindAnyWidget`, `GetGame().GetPlayer()`, and other calls that can return null. If null is a valid input to your function, handle it; if null indicates a caller error, prefer an early return.
- **Cast via `Class.CastTo(var, val)`** is the primary form. `Foo.Cast(bar)` is acceptable when assigning without an immediate check. C-style casts `(Foo)bar` are forbidden.

## Client-server

- In **init/load code** — always use `g_Game.IsDedicatedServer()` (or its negation for client). `IsClient()` and `IsServer()` lie during loading.
- In **runtime code** (after load) — `IsClient()` / `IsServer()` are acceptable.
- Singleplayer is used only as a debug environment — no special support is needed in production code.

## Global access

- **`g_Game` directly** — the only correct way to access it.
- **Do not use `GetGame()`.** It's a proto native function with overhead; direct access to the global variable is always faster.
- **Do not introduce new globals.** Use static fields on classes or the singleton pattern on the class itself.

## Collections

- **Shorthand initialization `array<T> = {}`** is the primary form.
- `new array<T>` — for cases where the array is created in a `ref` field via assignment.
- Array contents live as long as the array's owner does (the `ref` / `autoptr` rules extend to collections).

## Reference files map

| File | Contents |
|------|----------|
| `reference/code-style.md` | Full code style — braces, indentation, alignment, doxygen, section dividers |
| `reference/language-rules.md` | Applied language rules — `notnull`, `out` / `inout`, `foreach` gotchas, switch, bitwise operators, boundary values |
| `reference/memory-refs.md` | `Managed`, ARC, `ref` vs `autoptr`, valid cases for `delete`, object lifecycle |
| `reference/modded-classes.md` | The modded mechanism, super chains, private access, modded constants, when to choose modded vs regular inheritance |
| `reference/engine-pitfalls.md` | Catalog of known engine issues with bad/good examples |

## When to read which file

- Any work with `modded class` → `reference/modded-classes.md`.
- Any use of `ref`, `autoptr`, `new`, `delete`, or anything touching object lifecycle → `reference/memory-refs.md`.
- Style disputes or non-standard formatting cases → `reference/code-style.md`.
- Suspected segfault, unexpected compiler behavior, or unexplained runtime crash → `reference/engine-pitfalls.md`.
- Working with language constructs (switch, foreach, out parameters, null semantics) → `reference/language-rules.md`.