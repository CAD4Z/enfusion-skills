Компонентная система GameLib. Условие: `COMPONENT_SYSTEM`. Источник: `components/gamelibcomponents.c`

### IEntityComponentSource

`typedef int[] IEntityComponentSource` — наследует `BaseContainer`. Источник данных компонента (из шаблона/редактора).

### TouchEvent

| Значение | Описание |
|----------|----------|
| `ON_ENTER` | Вход в зону касания |
| `ON_STAY` | Нахождение в зоне |
| `ON_EXIT` | Выход из зоны |

### GenericComponent

Базовый класс всех компонентов. Наследует `Managed`. Конструктор `protected`.

| Метод | Возврат | Описание |
|-------|---------|----------|
| `GetEventMask()` | `int` | Текущая маска событий |
| `SetEventMask(IEntity owner, int mask)` | `int` | Добавить биты к маске. Возвращает результат OR. **Не вызывать в конструкторе** — использовать `OnComponentInsert` |
| `ClearEventMask(IEntity owner, int mask)` | `int` | Убрать биты из маски. Возвращает очищенные биты |
| `Activate(IEntity owner)` | — | Активировать, вызовет `EOnActivate` |
| `Deactivate(IEntity owner)` | — | Деактивировать, вызовет `EOnDeactivate` |
| `IsActive()` | `bool` | Активен ли компонент |

### ScriptComponent

Наследует `GenericComponent`. Родитель всех скриптовых компонентов.

#### Жизненный цикл

1. **Конструктор** — создание компонента
2. **`OnComponentInsert(owner, other)`** — компонент добавлен в сущность. Последнее событие в Workbench edit mode
3. **`EOnInit(owner, extra)`** — после вставки всех компонентов (нужна маска `EV_INIT`)
4. **`EOnActivate(owner)`** — если сущность `TFL_ACTIVE` и компонент активен (по умолчанию — активен)
5. **`EOn*` события** — по маске событий (см. `1_Core/entity.md` — `EntityEvent`)
6. **`EOnDeactivate(owner)`** — при `Deactivate()` или удалении
7. **`OnComponentRemove(owner, other)`** — компонент удалён из сущности
8. **`OnDelete(owner)`** — сущность уничтожается

#### Уникальные методы (не дублируют IEntity)

| Метод | Описание |
|-------|----------|
| `EOnActivate(IEntity owner)` | Компонент активирован |
| `EOnDeactivate(IEntity owner)` | Компонент деактивирован |
| `OnComponentInsert(IEntity owner, ScriptComponent other)` | Другой компонент добавлен в ту же сущность |
| `OnComponentRemove(IEntity owner, ScriptComponent other)` | Другой компонент удалён из сущности |
| `OnDelete(IEntity owner)` | Сущность/компонент уничтожается |

Остальные `EOn*` события (Frame, Touch, Simulate, Contact и т.д.) аналогичны `IEntity` — см. `@.claude/references/DayZ/Scripts/api/1_Core/entity.md`.

### GenericComponentClass

| Метод | Описание |
|-------|----------|
| `DependsOn(typename otherClass, TypeID otherTypeID)` | Объявить зависимость от другого типа компонента |

### BaseSoundComponent

Наследует `GenericComponent`. Управление звуковыми событиями и сигналами.

| Метод | Возврат | Описание |
|-------|---------|----------|
| `GetEventNames(out array<string> events)` | `int` | Список звуковых событий |
| `GetSignalNames(out array<string> signals)` | `int` | Список сигналов |
| `GetSignalIndex(string name)` | `int` | Индекс сигнала по имени |
| `SetSignalValueName(string signal, float value)` | — | Установить значение сигнала по имени |
| `SetSignalValue(int index, float value)` | — | Установить значение по индексу |
| `Play(string name)` | `SoundHandle` | Воспроизвести звуковое событие |
| `Update()` | `SoundHandle` | Воспроизвести по триггерам |
| `Terminate(SoundHandle handle)` | — | Остановить звук |
| `IsPlayed(SoundHandle handle)` | `bool` | Воспроизводится ли |
| `IsHandleValid(SoundHandle handle)` | `bool` | Валиден ли хэндл |
| `SetTransform(vector[] transf)` | — | Позиция источника звука |
| `SetDebug(bool value)` | — | Режим отладки |

`SoundHandle` — `typedef int[]`.
