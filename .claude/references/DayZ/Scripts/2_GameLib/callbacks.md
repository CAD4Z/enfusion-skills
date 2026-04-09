Система отложенных вызовов и callback'ов. Условие: `GAME_TEMPLATE`. Источник: `tools.c`

Активно используются в 3_Game и выше (20+ файлов). Три класса: очередь вызовов, список подписчиков, одиночный вызов.

### ScriptCallQueue

Очередь "ленивых" вызовов — выполняются не сразу, а при следующем `Tick()`. Основное применение — UI и отложенная логика.

| Метод | Описание |
|-------|----------|
| `Tick(float timeslice)` | Выполнить готовые вызовы. Вызывать каждый кадр из `OnUpdate` |
| `Call(func fn, ...)` | Добавить вызов, выполнится на следующем `Tick` |
| `CallByName(Class obj, string fnName, Param params)` | Вызов по имени метода |
| `CallLater(func fn, int delay, bool repeat, ...)` | Отложенный вызов: `delay` мс, `repeat` = повторять |
| `CallLaterByName(Class obj, string fnName, int delay, bool repeat, Param params)` | Отложенный по имени |
| `Remove(func fn)` | Удалить вызов из очереди |
| `RemoveByName(Class obj, string fnName)` | Удалить по имени |
| `GetRemainingTime(func fn)` | `int` — мс до выполнения |
| `GetRemainingTimeByName(Class obj, string fnName)` | `int` — мс до выполнения по имени |
| `Clear()` | Очистить всю очередь |

Все методы `Call*` принимают до 9 аргументов (`param1`..`param9`), аргументы хранятся в памяти до выполнения/удаления.

### ScriptInvoker

Список callback'ов (паттерн Observer). Вызов `Invoke` исполняет все зарегистрированные функции.

| Метод | Описание |
|-------|----------|
| `Invoke(...)` | Вызвать все подписанные методы (до 9 аргументов) |
| `Insert(func fn, int flags)` | Подписать метод. Флаги: `EScriptInvokerInsertFlags` |
| `Remove(func fn, int flags)` | Отписать метод. Флаги: `EScriptInvokerRemoveFlags` |
| `Count(func fn)` | `int` — сколько раз fn присутствует |
| `Clear()` | Удалить все подписки |

#### EScriptInvokerInsertFlags

| Флаг | Описание |
|------|----------|
| `NONE` | Добавляется после текущего цикла Invoke |
| `IMMEDIATE` | **(по умолчанию)** Добавляется сразу, вызовется в текущем Invoke. Внимание: может вызвать бесконечную цепочку Insert |
| `UNIQUE` | Только одна подписка на instance+method. VME при повторном добавлении |

#### EScriptInvokerRemoveFlags

| Флаг | Описание |
|------|----------|
| `NONE` | Удалить только последнюю вставку |
| `ALL` | **(по умолчанию)** Удалить все вхождения |

### ScriptCaller

Хранит одну валидную ссылку на функцию. Создаётся через фабрику.

| Метод | Описание |
|-------|----------|
| `Create(func fn)` | **static** — создать ScriptCaller |
| `Init(func fn)` | Заменить зарегистрированную функцию |
| `Invoke(...)` | Вызвать (до 9 аргументов) |
| `IsValid()` | `bool` — валидна ли ссылка |
| `Equals(ScriptCaller other)` | `bool` — сравнение по instance+method (не по адресу объекта) |

Конструктор `private` — использовать только `ScriptCaller.Create()`.