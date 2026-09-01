Testing framework. Condition: `GAME_TEMPLATE`. Source: `tests/testingframework.c`

### Architecture

`TestHarness` → `TestSuite` → `TestBase`. Collection and instantiation of primitives happens after script compilation. One `TestHarness` descendant per project.

### Attributes

**`[Test("SuiteName", timeoutS, timeoutMs, sortOrder)]`** — mark a function or class as a test. `suite` — suite name, `timeoutS`/`timeoutMs` — timeout (0 = no limit), `sortOrder` — order.

**`[Step(EStage)]`** — mark a method as a test step (only in `TestBase` classes).

### EStage

Stages execute in order: `Setup` → `Main` → `TearDown`.

### Test types

**Simple test** — free function returning `TestResultBase`:
```cpp
[Test("MySuite")]
TestResultBase MyTest() { return TestBoolResult(5 > 3); }
```

**Stateful test** — a class inheriting from `TestBase`, steps via `[Step]`:
- `void` method — executes once
- `bool` method — executes every tick until `return true`

### Failure unwind

- `Setup` failure → test ends, `TearDown` **is not called**
- `Main` failure → `TearDown` runs
- `TearDown` failure → nothing happens

Timeout is reset for each step method. On timeout, a `TimeoutResult` (failure) is set.

### TestHarness

| Method | Description |
|--------|-------------|
| `Begin()` | **static** — initialize tests |
| `Run()` | **static** → `bool` — tick tests, `true` when all complete |
| `End()` | **static** — finalize |
| `Report()` | **static** → `string` — XML report |
| `Finished()` | **static** → `bool` — all tests complete |
| `GetNSuites()` | **static** → `int` — number of suites |
| `GetSuite(int handle)` | **static** → `TestSuite` |
| `ActiveSuite()` | **static** → `TestSuite` or `null` |

### TestSuite

| Method | Description |
|--------|-------------|
| `SetResult(TestResultBase res)` | Set suite result |
| `GetNTests()` | `int` — number of tests |
| `GetTest(int handle)` | `TestBase` |
| `SetEnabled(bool val)` / `IsEnabled()` | Enable/disable the suite |
| `GetName()` | `string` — class name |
| `OnInit()` | `protected` — user initialization (during `Begin`) |

### TestBase

| Method | Description |
|--------|-------------|
| `SetResult(TestResultBase res)` | Set test result |
| `GetResult()` | `TestResultBase` |
| `SetEnabled(bool val)` / `IsEnabled()` | Enable/disable the test |
| `GetName()` | `string` — name |

### TestResultBase

| Method | Description |
|--------|-------------|
| `Failure()` | `bool` — whether the result is a failure (overridable) |
| `FailureText()` | `string` — text for the JUnit-format XML report |
