Расширенные сущности GameLib. Условие: `COMPONENT_SYSTEM`. Источник: `entities/gamelibentities.c`

### Иерархия наследования

```
IEntity (1_Core)
└── GenericEntity
    ├── GenericWorldEntity
    │   └── WorldEntity
    ├── GenericTerrainEntity
    ├── GenericWorldLightEntity
    ├── GenericWorldFogEntity
    ├── LightEntity
    ├── BasicEntity
    │   ├── ModelEntity
    │   ├── CharacterEntity
    │   └── BasicCamera
    └── VRHandEntity
```

### GenericEntity

Наследует `IEntity`. Добавляет компонентную систему.

| Метод | Возврат | Описание |
|-------|---------|----------|
| `Show(bool show)` | — | Показать/скрыть сущность |
| `FindComponent(typename typeName)` | `GenericComponent` | Найти первый компонент по типу |
| `InsertComponent(GenericComponent component)` | — | Добавить компонент. Вызывает `OnComponentInsert` на всех компонентах, затем `EOnInit` (при маске) и `EOnActivate` |
| `RemoveComponent(GenericComponent component)` | — | Убрать компонент (без удаления). Вызывает `EOnDeactivate` и `OnComponentRemove` |
| `DeleteComponent(GenericComponent component)` | — | Убрать и удалить компонент. Дополнительно вызывает `OnDelete` |

В Workbench: `_WB_AfterWorldUpdate(float timeSlice)` — вызывается после обновления мира для выделенных сущностей (только `WORKBENCH`).

### LightEntity

Наследует `GenericEntity`. Управление источником света.

| Метод | Возврат | Описание |
|-------|---------|----------|
| `SetDiffuseColor(int color)` | — | Цвет рассеянного света |
| `GetDiffuseColor()` | `int` | Текущий цвет |
| `SetRadius(float radius)` | — | Радиус |
| `GetRadius()` | `float` | Текущий радиус |
| `SetConeAngle(float angle)` | — | Угол конуса (только `LT_SPOT`) |
| `GetConeAngle()` | `float` | Текущий угол конуса |
| `SetCastShadow(bool enable)` | — | Отбрасывание теней |
| `IsCastShadow(bool enable)` | `bool` | Отбрасывает ли тени |

### CharacterEntity

Наследует `BasicEntity`. Управляемый персонаж.

| Метод | Возврат | Описание |
|-------|---------|----------|
| `Teleport(vector transform[4])` | — | Телепортация (матрица 4x4) |
| `GetCurrentMovement()` | `CharacterMovement` | Текущий тип движения |
| `GetCurrentStance()` | `CharacterStance` | Текущая стойка |

#### CharacterMovement

`MOVEMENTTYPE_IDLE`, `MOVEMENTTYPE_WALK`, `MOVEMENTTYPE_RUN`, `MOVEMENTTYPE_SPRINT`

#### CharacterStance

`STANCE_ERECT`, `STANCE_CROUCH`, `STANCE_PRONE`, `STANCE_ERECT_RAISED`, `STANCE_CROUCH_RAISED`, `STANCE_PRONE_RAISED`

### Пустые классы-маркеры

`GenericWorldEntity`, `GenericTerrainEntity`, `GenericWorldLightEntity`, `GenericWorldFogEntity`, `BasicEntity`, `BasicCamera`, `ModelEntity`, `VRHandEntity`, `WorldEntityClass`, `WorldEntity` — без дополнительных методов, используются для типизации и фильтрации.

### Шаблонные сущности (GAME_TEMPLATE)

Примеры/шаблоны под `#ifdef GAME_TEMPLATE`, не являются частью API. Источники: `entities/script*.c`, `entities/rendertarget.c`, `entities/worldsmenu.c`.

| Класс | Описание |
|-------|----------|
| `ScriptCamera` | Free-fly камера с отладочным UI |
| `ScriptLight` | Точечный источник света |
| `ScriptModel` | Модель со статической/динамической физикой |
| `RenderTarget` | Виджет рендер-таргета для камеры |
| `WorldsMenu` | Отладочное меню выбора мира |
