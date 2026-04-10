Ядро скриптовой системы. Источник: `proto/enscript.c`, `proto/proto.c`, `param.c`

### Class

Суперкорень всех классов в Enforce Script.

| Метод | Возврат | Описание |
|-------|---------|----------|
| `IsInherited(type)` | `bool` | Проверка наследования |
| `ClassName()` | `string` | Имя класса |
| `GetDebugName()` | `string` | По умолчанию = `ClassName()`, переопределяем |
| `Type()` | `typename` | typename объекта |
| `StaticType()` | `typename` | typename переменной (не объекта) |
| `ToString()` | `string` | Строковое представление |
| `Cast(from)` | `Class` | **static** — безопасный downcast, null при неудаче |
| `CastTo(out to, from)` | `bool` | **static** — downcast с проверкой |

```cpp
// Паттерн каста
Object obj = GetGame().GetPlayer();
Man player;
if (Class.CastTo(player, obj))
{
    // работаем с player
}
```

### Managed

Базовый класс для объектов управляемых ARC (Automatic Reference Counting). Наследуйте от `Managed` когда нужен подсчёт ссылок через `ref`.

### ScriptModule

Компилированный скриптовый модуль. Позволяет динамический вызов функций.

| Метод | Описание |
|-------|----------|
| `Call(inst, function, parm)` | Динамический вызов (новый поток) |
| `CallFunction(inst, function, out returnVal, parm)` | Динамический вызов (текущий поток) |
| `CallFunctionParams(inst, function, out returnVal, parms)` | То же с Param-объектом |
| `LoadScript(parent, scriptFile, listing)` | **static** — загрузить скрипт |

### EnScript

Рефлексия — динамический доступ к переменным.

| Метод | Описание |
|-------|----------|
| `GetClassVar(inst, varname, index, out result)` | Чтение переменной по имени |
| `SetClassVar(inst, varname, index, input)` | Запись переменной по имени |
| `SetVar(out var, value)` | Установить переменную из строки |
| `Watch(var, flags)` | Отладочное наблюдение за переменной |

### Param1..Param10

Шаблонные контейнеры для передачи параметров. Наследуют от `Param : Managed`. Поддерживают сериализацию.

```cpp
Param param = new Param2<float, string>(3.14, "Pi");
// param.param1 == 3.14
// param.param2 == "Pi"
```

Доступные: `Param1<T1>` ... `Param10<T1..T10>`. Все содержат публичные поля `param1`..`paramN` и методы `Serialize(ctx)` / `Deserializer(ctx)`.

### Глобальные функции

| Функция | Описание |
|---------|----------|
| `Sort(array[], num)` | Сортировка статического массива (int/float/string) |
| `reversearray(array)` | Обратить порядок |
| `copyarray(dest, src)` | Копировать массив |
| `ParseStringEx(inout input, out token)` | Токенизация строки (глобальная версия) |
| `ParseString(input, out tokens[])` | Разбор в массив токенов |
| `KillThread(owner, name)` | Убить поток |
| `ThreadFunction(owner, name, backtrace, out line)` | Текущая функция потока |
| `String(s)` | Helper для передачи string в void параметр |
| `PrintString(s)` | Helper для Print со строкой |

### Сетевые адаптеры

`PacketOutputAdapter` / `PacketInputAdapter` — сериализация для сети.

**Write:** `WriteBool`, `WriteInt`, `WriteFloat`, `WriteString`, `WriteVector`, `WriteIntAsByte` (1 байт), `WriteIntAsUByte`, `WriteIntAsHalf` (2 байта), `WriteFloatAsByte(val, min, max)`, `WriteFloatAsHalf(val, min, max)`

**Read:** аналогичные `Read*` методы.

### Link\<T\>

Обёртка-ссылка на объект: `Init(obj)`, `Ptr()`, `Release()`, `IsNull()`.

### Утилиты цвета

| Функция | Описание |
|---------|----------|
| `ARGB(a, r, g, b)` | Сборка цвета из 0-255 компонент |
| `ARGBF(fa, fr, fg, fb)` | Сборка цвета из 0.0-1.0 |
| `LerpARGB(c1, c2)` | Линейная интерполяция цветов |

### Material

| Метод | Описание |
|-------|----------|
| `SetParam(name, value)` | Установить параметр материала |
| `ResetParam(name)` | Сбросить к дефолту |
| `GetParamIndex(name)` | Индекс для быстрого доступа |
| `SetParamByIndex(index, value)` | Установить по индексу |

### Obsolete

Атрибут для пометки устаревших методов — генерирует предупреждение компилятора при использовании.

```cpp
[Obsolete("Use NewMethod instead")]
void OldMethod() {}
```
