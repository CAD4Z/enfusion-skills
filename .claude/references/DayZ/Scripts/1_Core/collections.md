Шаблонные коллекции. Источник: `proto/enscript.c`

### array\<T\>

Динамический массив. Литерал: `{1, 2, 3}`. Поддерживает `foreach`.

| Метод | Возврат | Описание |
|-------|---------|----------|
| `Count()` | `int` | Кол-во элементов, O(1) |
| `Clear()` | `void` | Очистить (память не освобождается) |
| `Get(n)` / `arr[n]` | `T` | Элемент по индексу |
| `Set(n, value)` | `void` | Установить элемент |
| `Insert(value)` | `int` | Добавить в конец, возвращает позицию |
| `InsertAt(value, index)` | `int` | Вставить на позицию (сдвиг вправо) |
| `InsertAll(from)` | `void` | Добавить все элементы из другого массива |
| `Find(value)` | `int` | Индекс первого вхождения, -1 если нет |
| `Remove(index)` | `void` | Удалить (заменяет последним, **НЕ сохраняет порядок**) |
| `RemoveOrdered(index)` | `void` | Удалить с сохранением порядка (медленнее) |
| `RemoveItem(value)` | `void` | Найти и удалить (ordered) |
| `RemoveItemUnOrdered(value)` | `void` | Найти и удалить (fast, unordered) |
| `Resize(newSize)` | `void` | Изменить размер |
| `Reserve(newSize)` | `void` | Зарезервировать память |
| `Sort(reverse = false)` | `void` | Сортировка |
| `Copy(from)` | `int` | Копировать содержимое |
| `Swap(other)` | `void` | Обменять содержимое с другим массивом |
| `IsValidIndex(index)` | `bool` | Проверка валидности индекса |
| `GetRandomIndex()` | `int` | Случайный индекс |
| `GetRandomElement()` | `T` | Случайный элемент |
| `SwapItems(i1, i2)` | `void` | Поменять два элемента местами |
| `ShuffleArray()` | `void` | Перемешать |
| `Invert()` | `void` | Обратить порядок |
| `DifferentAtPosition(other)` | `int` | Индекс первого различия |
| `Debug()` | `void` | Вывод в лог |

**Готовые typedef'ы:** `TStringArray`, `TFloatArray`, `TIntArray`, `TBoolArray`, `TVectorArray`, `TTypenameArray`

### set\<T\>

Упорядоченное множество (без дубликатов по умолчанию не проверяет — это ручная ответственность). API аналогичен `array`, но `Remove` всегда ordered.

| Метод | Возврат | Описание |
|-------|---------|----------|
| `Count()` | `int` | Кол-во элементов |
| `Clear()` | `void` | Очистить |
| `Get(n)` / `s[n]` | `T` | Элемент по индексу |
| `Insert(value)` | `int` | Добавить |
| `InsertAt(value, index)` | `int` | Вставить на позицию |
| `Find(value)` | `int` | Поиск |
| `Remove(index)` | `void` | Удалить (ordered) |
| `RemoveItem(value)` | `void` | Найти и удалить |
| `RemoveItems(other)` | `void` | Удалить все из другого set |
| `InsertSet(other)` | `void` | Добавить все из другого set |

**Typedef'ы:** `TStringSet`, `TFloatSet`, `TIntSet`, `TTypenameSet`

### map\<TKey, TValue\>

Хеш-таблица.

| Метод | Возврат | Описание |
|-------|---------|----------|
| `Count()` | `int` | Кол-во элементов |
| `Clear()` | `void` | Очистить |
| `Get(key)` | `TValue` | Значение по ключу |
| `Find(key, out val)` | `bool` | Поиск с проверкой существования |
| `Set(key, value)` | `void` | Установить (создаёт если нет) |
| `Insert(key, value)` | `bool` | Вставить новый элемент |
| `Remove(key)` | `void` | Удалить по ключу |
| `Contains(key)` | `bool` | Проверка наличия |
| `GetElement(index)` | `TValue` | Значение по позиции, O(n) |
| `GetKey(index)` | `TKey` | Ключ по позиции, O(n) |
| `RemoveElement(index)` | `void` | Удалить по позиции, O(n) |
| `GetKeyArray()` | `array<TKey>` | Массив всех ключей |
| `GetValueArray()` | `array<TValue>` | Массив всех значений |
| `ReplaceKey(old, new)` | `bool` | Заменить ключ |
| `GetKeyByValue(value)` | `TKey` | Ключ по значению (первый найденный) |

**Итератор:** `Begin()`, `End()`, `Next(it)`, `GetIteratorKey(it)`, `GetIteratorElement(it)`

**Typedef'ы:** комбинации `int/string/Class/Managed/typename` x `float/int/string/Class/Managed/typename/vector` — например `TStringIntMap`, `TIntFloatMap` и т.д.
