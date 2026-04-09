Система сущностей движка Enfusion. Источник: `proto/enentity.c`

### IEntity

Базовый класс всех сущностей в мире. Наследует от `Managed`.

#### События (EOn*)

Переопределяйте в наследниках для получения событий. Работают только при установленной маске (`SetEventMask`).

| Метод | Когда вызывается |
|-------|------------------|
| `EOnInit(other, extra)` | После создания мира |
| `EOnFrame(other, float timeSlice)` | Каждый кадр (нужен `EntityFlags.ACTIVE`) |
| `EOnPostFrame(other, extra)` | Конец кадра / после перемещения |
| `EOnVisible(other, extra)` | Сущность видима |
| `EOnNotVisible(other, extra)` | Сущность не видима |
| `EOnTouch(other, extra)` | Касание другой сущностью |
| `EOnSimulate(other, float dt)` | Шаг физической симуляции |
| `EOnPostSimulate(other, float timeSlice)` | После шага симуляции |
| `EOnPhysicsMove(other, extra)` | Перемещение физикой |
| `EOnContact(other, Contact extra)` | Физический контакт |
| `EOnJointBreak(other, extra)` | Разрыв joint'а |
| `EOnAnimEvent(other, AnimEvent extra)` | Событие анимации |
| `EOnSoundEvent(other, SoundEvent extra)` | Событие звука |
| `EOnEnter(other, extra)` | Вход в триггер |
| `EOnLeave(other, extra)` | Выход из триггера |

#### EntityEvent (маска событий)

`TOUCH`, `VISIBLE`, `NOTVISIBLE`, `FRAME`, `POSTFRAME`, `INIT`, `JOINTBREAK`, `SIMULATE`, `POSTSIMULATE`, `PHYSICSMOVE`, `CONTACT`, `EXTRA`, `ANIMEVENT`, `SOUNDEVENT`, `PHYSICSSTEADY`, `USER`, `ENTER`, `LEAVE`, `ALL`

#### EntityFlags

| Флаг | Описание |
|------|----------|
| `VISIBLE` | Видимый, рендерится |
| `SOLID` | Коллизируемый при трейсах |
| `TRIGGER` | Не коллизируемый, но генерирует touch-события |
| `TOUCHTRIGGERS` | Взаимодействует с триггерами |
| `ACTIVE` | Активно обновляется движком (EOnFrame) |
| `STATIC` | Статичный объект, точнее но медленнее в scene-tree |
| `TRANSLUCENT` | Игнорируется при `TraceFlags.PASSTRANSLUCENT` |
| `WATER` | Только при трейсе с `TraceFlags.WATER` |
| `USER1`..`USER6` | Пользовательские флаги для фильтрации |

#### Трансформации

| Метод | Описание |
|-------|----------|
| `GetTransform(out mat[])` | Мировая матрица трансформации |
| `GetRenderTransform(out mat[4])` | Рендер-матрица |
| `GetLocalTransform(out mat[])` | Локальная матрица (в иерархии) |
| `GetTransformAxis(int axis)` | Ось матрицы (0-3) |
| `SetTransform(mat[4])` | Установить мировую матрицу |
| `GetOrigin()` | Мировая позиция |
| `SetOrigin(vec)` | Установить позицию |
| `GetLocalPosition()` | Локальная позиция |
| `GetYawPitchRoll()` | Ориентация (Yaw, Pitch, Roll) |
| `SetYawPitchRoll(angles)` | Установить ориентацию |
| `GetAngles()` / `SetAngles(angles)` | Углы вращения по осям X, Y, Z |
| `GetLocalYawPitchRoll()` / `GetLocalAngles()` | Локальные углы |
| `GetScale()` / `SetScale(float)` | Масштаб |

**Преобразование координат:**

| Метод | Описание |
|-------|----------|
| `VectorToParent(vec)` | Локальный вектор -> мировой |
| `CoordToParent(coord)` | Локальная позиция -> мировая |
| `VectorToLocal(vec)` | Мировой вектор -> локальный |
| `CoordToLocal(coord)` | Мировая позиция -> локальная |

#### Иерархия

| Метод | Описание |
|-------|----------|
| `AddChild(child, pivot, positionOnly)` | Добавить дочернюю сущность |
| `RemoveChild(child, keepTransform)` | Удалить из иерархии |
| `GetParent()` | Родитель |
| `GetChildren()` | Первый ребёнок |
| `GetSibling()` | Следующий на том же уровне |

#### Прочее

| Метод | Описание |
|-------|----------|
| `GetID()` / `SetID(id)` | Уникальный ID |
| `GetName()` / `SetName(name)` | Имя сущности |
| `GetFlags()` / `SetFlags(flags, recursive)` / `ClearFlags(...)` | Управление флагами |
| `IsFlagSet(flags)` | Проверка флага |
| `GetEventMask()` / `SetEventMask(e)` / `ClearEventMask(e)` | Маска событий |
| `SendEvent(actor, e, extra)` | Динамический вызов события |
| `GetPhysics()` | Получить Physics объект |
| `GetBounds(out mins, out maxs)` | Локальный bounding box |
| `GetWorldBounds(out mins, out maxs)` | Мировой bounding box |
| `SetObject(vobject, options)` | Установить визуальный объект |
| `GetVObject()` | Получить визуальный объект |
| `FilterNextTrace()` | Исключить из следующего трейса |
| `Update()` | Ручное обновление состояния |

### Вспомогательные классы

**BaseContainer** — доступ к данным редактора: `GetClassName()`, `GetName()`, `VarIndex(name)`, `IsVariableSet(idx)`, `Get(idx, out val)`

**IEntitySource** / **WidgetSource** — иерархия источников: `GetChildren()`, `GetSibling()`, `GetParent()`

**Attribute** / **EditorAttribute** — атрибуты для Workbench (свойства в редакторе).
