Система искусственного интеллекта: навмеш, группы, агенты. Источники: `ai/`

### AIWorld

Мир ИИ и навигационная сетка. Доступ: `g_Game.GetWorld().GetAIWorld()`. Proto native.

#### Группы

| Метод | Описание |
|-------|----------|
| `CreateGroup()` | Создать группу |
| `CreateDefaultGroup()` | Группа по умолчанию |
| `DeleteGroup(group)` | Удалить группу |

#### Навигация

| Метод | Описание |
|-------|----------|
| `FindPath(start, end, filter, out path)` | Найти путь по навмешу |
| `RaycastNavMesh(start, end, filter, out hitPos)` | Рейкаст по навмешу |
| `SampleNavmeshPosition(pos, maxDist, filter, out result)` | Ближайшая точка на навмеше |

### AIAgent

Индивидуальный ИИ-агент. Proto native.

| Метод | Описание |
|-------|----------|
| `SetKeepInIdle(state)` | Удерживать в idle-состоянии |
| `GetGroup()` | Получить группу |

### AIGroup

Группа агентов. Proto native.

### AIGroupBehaviour

Поведение группы.

### PGFilter

Фильтр для навигационных запросов. Источник: `ai/`

| Метод | Описание |
|-------|----------|
| `GetIncludeFlags()` / `GetExcludeFlags()` / `GetExlusiveFlags()` | Получить флаги |
| `SetFlags(include, exclude, exclusive)` | Установить флаги |
| `SetCost(areaType, cost)` | Стоимость прохода по типу зоны |

### PGPolyFlags

Флаги полигонов навмеша (битовая маска):

```
NONE, WALK, DISABLED, DOOR, INSIDE, SWIM, SWIM_SEA, LADDER,
JUMP_OVER, JUMP_DOWN, CLIMB, CRAWL, CROUCH, UNREACHABLE, ALL, SPECIAL
```

### PGAreaType

Типы зон навмеша:

```
NONE, TERRAIN,
WATER_DEEP, WATER_SHALLOW, WATER_SHORE,
OBJECTS_NOFFCON, OBJECTS_FFCON,
DOOR_OPENED, DOOR_CLOSED,
LADDER, CRAWL, CROUCH,
FENCE_WALL, JUMP
```
