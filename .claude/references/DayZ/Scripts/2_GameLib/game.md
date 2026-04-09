Основной класс игрового цикла. Условие: `GAME_TEMPLATE`. Источник: `gamelib.c`

DayZ наследует: `Game` → `CGame` (3_Game) → `DayZGame` (3_Game). Глобальный экземпляр: `g_Game`.

### Game

#### Lifecycle (переопределяемые)

| Метод | Когда вызывается |
|-------|------------------|
| `OnEvent(EventType eventTypeId, Param params)` | Системное событие |
| `OnAfterInit()` | После полной инициализации Game |
| `OnUpdate(float timeslice)` | Каждый кадр (world update) |
| `OnGameStart()` → `bool` | Перед стартом игры, `true` = можно начинать |
| `OnGameEnd()` | Перед завершением игры |
| `ShowLoadingAnim()` | Создание экрана загрузки |
| `HideLoadingAnim()` | Скрытие экрана загрузки |
| `UpdateLoadingAnim(float timeslice, float progress)` | Обновление загрузки, `progress` ∈ [0, 1] |

#### Спавн и поиск (proto native)

| Метод | Возврат | Описание |
|-------|---------|----------|
| `SpawnEntity(typename typeName)` | `IEntity` | Создать сущность по типу, вызывает `EOnInit` при маске `INIT` |
| `SpawnEntityTemplate(vobject templateResource)` | `IEntity` | Создать сущность из шаблона со всеми компонентами |
| `SpawnComponentTemplate(IEntity owner, vobject templateResource)` | `GenericComponent` | Создать компонент из шаблона и вставить в сущность |
| `FindEntity(string name)` | `IEntity` | Найти сущность по имени |

#### Мир и система (proto native)

| Метод | Возврат | Описание |
|-------|---------|----------|
| `SetWorldFile(string path, bool reload)` | `bool` | Загрузить мир из .ent файла, `false` если не найден |
| `GetWorldFile()` | `string` | Путь текущего мира |
| `GetWorldEntity()` | `GenericWorldEntity` | Сущность мира (только в игре / play mode) |
| `GetWorkspace()` | `WorkspaceWidget` | Корневой UI workspace |
| `GetInputManager()` | `InputManager` | Менеджер ввода |
| `GetMenuManager()` | `MenuManager` | Менеджер меню |
| `GetTickCount()` | `int` | Счётчик тиков |

#### Управление приложением (proto native)

| Метод | Описание |
|-------|----------|
| `RequestClose()` | Запрос на выход из игры |
| `RequestReload()` | Запрос на перезагрузку игры (не работает в Workbench) |
| `GetBuildVersion()` | Версия билда |
| `GetBuildTime()` | Дата/время сборки |

### GameLibInit()

Точка входа инициализации модуля. Пустая в шаблоне, переопределяется в конкретных проектах.
