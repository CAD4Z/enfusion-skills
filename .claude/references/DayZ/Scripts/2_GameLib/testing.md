Фреймворк тестирования. Условие: `GAME_TEMPLATE`. Источник: `tests/testingframework.c`

### Архитектура

`TestHarness` → `TestSuite` → `TestBase`. Сбор и инстанцирование примитивов происходит после компиляции скриптов. Один `TestHarness`-наследник на проект.

### Атрибуты

**`[Test("SuiteName", timeoutS, timeoutMs, sortOrder)]`** — пометить функцию или класс как тест. `suite` — имя набора, `timeoutS`/`timeoutMs` — таймаут (0 = без лимита), `sortOrder` — порядок.

**`[Step(EStage)]`** — пометить метод как шаг теста (только в классах `TestBase`).

### EStage

Стадии выполняются по порядку: `Setup` → `Main` → `TearDown`.

### Типы тестов

**Простой тест** — свободная функция, возвращает `TestResultBase`:
```cpp
[Test("MySuite")]
TestResultBase MyTest() { return TestBoolResult(5 > 3); }
```

**Stateful тест** — класс наследник `TestBase`, шаги через `[Step]`:
- `void` метод — выполняется однократно
- `bool` метод — выполняется каждый тик до `return true`

### Failure unwind

- `Setup` провал → тест завершается, `TearDown` **не вызывается**
- `Main` провал → запускается `TearDown`
- `TearDown` провал → ничего не происходит

Таймаут сбрасывается для каждого step-метода. При таймауте устанавливается `TimeoutResult` (failure).

### TestHarness

| Метод | Описание |
|-------|----------|
| `Begin()` | **static** — инициализация тестов |
| `Run()` | **static** → `bool` — тик тестов, `true` когда все завершены |
| `End()` | **static** — финализация |
| `Report()` | **static** → `string` — XML-отчёт |
| `Finished()` | **static** → `bool` — все тесты завершены |
| `GetNSuites()` | **static** → `int` — количество наборов |
| `GetSuite(int handle)` | **static** → `TestSuite` |
| `ActiveSuite()` | **static** → `TestSuite` или `null` |

### TestSuite

| Метод | Описание |
|-------|----------|
| `SetResult(TestResultBase res)` | Установить результат набора |
| `GetNTests()` | `int` — количество тестов |
| `GetTest(int handle)` | `TestBase` |
| `SetEnabled(bool val)` / `IsEnabled()` | Включить/выключить набор |
| `GetName()` | `string` — имя класса |
| `OnInit()` | `protected` — пользовательская инициализация (при `Begin`) |

### TestBase

| Метод | Описание |
|-------|----------|
| `SetResult(TestResultBase res)` | Установить результат теста |
| `GetResult()` | `TestResultBase` |
| `SetEnabled(bool val)` / `IsEnabled()` | Включить/выключить тест |
| `GetName()` | `string` — имя |

### TestResultBase

| Метод | Описание |
|-------|----------|
| `Failure()` | `bool` — провал ли результат (переопределяемый) |
| `FailureText()` | `string` — текст для XML-отчёта в формате JUnit |
