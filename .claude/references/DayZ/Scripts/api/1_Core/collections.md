Template collections. Source: `proto/enscript.c`

### array\<T\>

Dynamic array. Literal: `{1, 2, 3}`. Supports `foreach`.

| Method | Return | Description |
|-------|---------|----------|
| `Count()` | `int` | Number of elements, O(1) |
| `Clear()` | `void` | Clear (memory is not freed) |
| `Get(n)` / `arr[n]` | `T` | Element by index |
| `Set(n, value)` | `void` | Set element |
| `Insert(value)` | `int` | Add to end, returns position |
| `InsertAt(value, index)` | `int` | Insert at position (shifts right) |
| `InsertAll(from)` | `void` | Add all elements from another array |
| `Find(value)` | `int` | Index of first occurrence, -1 if none |
| `Remove(index)` | `void` | Remove (replaces with last, **does NOT preserve order**) |
| `RemoveOrdered(index)` | `void` | Remove preserving order (slower) |
| `RemoveItem(value)` | `void` | Find and remove (ordered) |
| `RemoveItemUnOrdered(value)` | `void` | Find and remove (fast, unordered) |
| `Resize(newSize)` | `void` | Resize |
| `Reserve(newSize)` | `void` | Reserve memory |
| `Sort(reverse = false)` | `void` | Sort |
| `Copy(from)` | `int` | Copy contents |
| `Swap(other)` | `void` | Swap contents with another array |
| `IsValidIndex(index)` | `bool` | Check index validity |
| `GetRandomIndex()` | `int` | Random index |
| `GetRandomElement()` | `T` | Random element |
| `SwapItems(i1, i2)` | `void` | Swap two elements |
| `ShuffleArray()` | `void` | Shuffle |
| `Invert()` | `void` | Reverse order |
| `DifferentAtPosition(other)` | `int` | Index of first difference |
| `Debug()` | `void` | Output to log |

**Predefined typedefs:** `TStringArray`, `TFloatArray`, `TIntArray`, `TBoolArray`, `TVectorArray`, `TTypenameArray`

### set\<T\>

Ordered set (does not check for duplicates by default — that's a manual responsibility). API is similar to `array`, but `Remove` is always ordered.

| Method | Return | Description |
|-------|---------|----------|
| `Count()` | `int` | Number of elements |
| `Clear()` | `void` | Clear |
| `Get(n)` / `s[n]` | `T` | Element by index |
| `Insert(value)` | `int` | Add |
| `InsertAt(value, index)` | `int` | Insert at position |
| `Find(value)` | `int` | Search |
| `Remove(index)` | `void` | Remove (ordered) |
| `RemoveItem(value)` | `void` | Find and remove |
| `RemoveItems(other)` | `void` | Remove all from another set |
| `InsertSet(other)` | `void` | Add all from another set |

**Typedefs:** `TStringSet`, `TFloatSet`, `TIntSet`, `TTypenameSet`

### map\<TKey, TValue\>

Hash table.

| Method | Return | Description |
|-------|---------|----------|
| `Count()` | `int` | Number of elements |
| `Clear()` | `void` | Clear |
| `Get(key)` | `TValue` | Value by key |
| `Find(key, out val)` | `bool` | Search with existence check |
| `Set(key, value)` | `void` | Set (creates if absent) |
| `Insert(key, value)` | `bool` | Insert new element |
| `Remove(key)` | `void` | Remove by key |
| `Contains(key)` | `bool` | Check presence |
| `GetElement(index)` | `TValue` | Value by position, O(n) |
| `GetKey(index)` | `TKey` | Key by position, O(n) |
| `RemoveElement(index)` | `void` | Remove by position, O(n) |
| `GetKeyArray()` | `array<TKey>` | Array of all keys |
| `GetValueArray()` | `array<TValue>` | Array of all values |
| `ReplaceKey(old, new)` | `bool` | Replace key |
| `GetKeyByValue(value)` | `TKey` | Key by value (first found) |

**Iterator:** `Begin()`, `End()`, `Next(it)`, `GetIteratorKey(it)`, `GetIteratorElement(it)`

**Typedefs:** combinations of `int/string/Class/Managed/typename` x `float/int/string/Class/Managed/typename/vector` — for example `TStringIntMap`, `TIntFloatMap`, etc.
