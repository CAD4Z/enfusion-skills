Deferred call and callback system. Condition: `GAME_TEMPLATE`. Source: `tools.c`

Heavily used in 3_Game and above (20+ files). Three classes: call queue, subscriber list, single call.

### ScriptCallQueue

Queue of "lazy" calls — executed not immediately, but on the next `Tick()`. Primarily used for UI and deferred logic.

| Method | Description |
|--------|-------------|
| `Tick(float timeslice)` | Execute pending calls. Call every frame from `OnUpdate` |
| `Call(func fn, ...)` | Add a call, will execute on the next `Tick` |
| `CallByName(Class obj, string fnName, Param params)` | Call by method name |
| `CallLater(func fn, int delay, bool repeat, ...)` | Deferred call: `delay` ms, `repeat` = repeat |
| `CallLaterByName(Class obj, string fnName, int delay, bool repeat, Param params)` | Deferred call by name |
| `Remove(func fn)` | Remove call from queue |
| `RemoveByName(Class obj, string fnName)` | Remove by name |
| `GetRemainingTime(func fn)` | `int` — ms until execution |
| `GetRemainingTimeByName(Class obj, string fnName)` | `int` — ms until execution, by name |
| `Clear()` | Clear the entire queue |

All `Call*` methods accept up to 9 arguments (`param1`..`param9`); arguments are kept in memory until execution/removal.

### ScriptInvoker

Callback list (Observer pattern). Calling `Invoke` runs all registered functions.

| Method | Description |
|--------|-------------|
| `Invoke(...)` | Call all subscribed methods (up to 9 arguments) |
| `Insert(func fn, int flags)` | Subscribe a method. Flags: `EScriptInvokerInsertFlags` |
| `Remove(func fn, int flags)` | Unsubscribe a method. Flags: `EScriptInvokerRemoveFlags` |
| `Count(func fn)` | `int` — how many times fn is present |
| `Clear()` | Remove all subscriptions |

#### EScriptInvokerInsertFlags

| Flag | Description |
|------|-------------|
| `NONE` | Added after the current Invoke cycle |
| `IMMEDIATE` | **(default)** Added immediately, will be called in the current Invoke. Warning: may cause an infinite chain of Inserts |
| `UNIQUE` | Only one subscription per instance+method. VME on repeated insertion |

#### EScriptInvokerRemoveFlags

| Flag | Description |
|------|-------------|
| `NONE` | Remove only the last insertion |
| `ALL` | **(default)** Remove all occurrences |

### ScriptCaller

Holds a single valid function reference. Created via factory.

| Method | Description |
|--------|-------------|
| `Create(func fn)` | **static** — create a ScriptCaller |
| `Init(func fn)` | Replace the registered function |
| `Invoke(...)` | Call (up to 9 arguments) |
| `IsValid()` | `bool` — whether the reference is valid |
| `Equals(ScriptCaller other)` | `bool` — comparison by instance+method (not by object address) |

Constructor is `private` — use only `ScriptCaller.Create()`.
