Основной класс игры и управление миром. Наследование: `Game` (2_GameLib) → `CGame` → `DayZGame`. Источники: `global/game.c`, `dayzgame.c`

Глобальный экземпляр: `g_Game`. Константа: `GAME_STORAGE_VERSION = 142`.

### CGame

Расширяет `Game` из 2_GameLib. Определяет DayZ-специфичный API: конфиг, объекты, профили, сеть.

#### Lifecycle (переопределяемые)

| Метод | Когда вызывается |
|-------|------------------|
| `OnEvent(EventType eventTypeId, Param params)` | Системное событие |
| `OnAfterCreate()` | После создания экземпляра CGame |
| `OnInitialize()` → `bool` | Перед игровым циклом. `true` = инициализация в скриптах |
| `OnUpdate(bool doSim, float timeslice)` | Каждый кадр. `doSim=false` при паузе |
| `OnPostUpdate(bool doSim, float timeslice)` | После симуляции сущностей |
| `OnKeyPress(int key)` / `OnKeyRelease(int key)` | Нажатие/отпускание клавиши (DIK код) |
| `OnMouseButtonPress(int button)` / `OnMouseButtonRelease(int button)` | Клик мыши |
| `OnActivateMessage()` / `OnDeactivateMessage()` | Фокус окна (Windows) |
| `OnDeviceReset()` | Сброс графического устройства, сброс скриптовых переменных |
| `OnRPC(PlayerIdentity sender, Object target, int rpc_type, ParamsReadContext ctx)` | Входящий RPC. `target=NULL` → глобальный RPC |

#### Мир и доступ (proto native)

| Метод | Возврат | Описание |
|-------|---------|----------|
| `GetWorkspace()` | `WorkspaceWidget` | Корневой UI workspace |
| `GetLoadingWorkspace()` | `WorkspaceWidget` | Workspace загрузочного экрана |
| `GetWorld()` | `World` | Объект текущего мира |
| `GetPlayer()` | `DayZPlayer` | Локальный игрок |
| `GetPlayers(out array<Man> players)` | `void` | Список всех игроков |
| `GetUIManager()` | `UIManager` | Менеджер UI |
| `GetInput()` | `Input` | Система ввода |
| `GetSoundScene()` | `AbstractSoundScene` | Звуковая сцена |
| `GetNoiseSystem()` | `NoiseSystem` | Система шума (для ИИ) |
| `GetCurrentCameraPosition()` | `vector` | Позиция камеры |
| `GetCurrentCameraDirection()` | `vector` | Направление камеры |

#### Объекты (proto native)

| Метод | Возврат | Описание |
|-------|---------|----------|
| `CreateObject(type, pos, create_local, init_ai, create_physics)` | `Object` | Создать объект по типу |
| `CreateObjectEx(type, pos, iFlags, iRotation)` | `Object` | Создать с ECE-флагами и вращением |
| `CreateStaticObjectUsingP3D(p3d, pos, ori, scale, createLocal)` | `Object` | Создать статический объект из P3D |
| `ObjectDelete(obj)` | `void` | Удалить объект |
| `ObjectRelease(obj)` | `int` | Освободить объект |
| `ObjectModelToWorld(obj, modelPos)` | `vector` | Модельные → мировые координаты |
| `ObjectWorldToModel(obj, worldPos)` | `vector` | Мировые → модельные координаты |
| `ObjectGetSelectionPosition(obj, name)` | `vector` | Позиция именованной selection |
| `ObjectGetSelectionPositionMS(obj, name)` | `vector` | В model space |
| `ObjectGetSelectionPositionWS(obj, name)` | `vector` | В world space |
| `PreloadObject(type, distance)` | `bool` | Предзагрузить объекты типа |
| `GetObjectsAtPosition(pos, radius, out objects, out proxyCargos)` | `void` | Объекты в круге (2D) |
| `GetObjectsAtPosition3D(pos, radius, out objects, out proxyCargos)` | `void` | Объекты в сфере (3D) |
| `IsObjectAccesible(item, player)` | `bool` | Доступ к карго/аттачментам по дистанции |

#### Конфигурация (proto native)

Чтение значений из `configFile` / `missionConfigFile`. Путь: классы через пробел (`"CfgVehicles AK74 scope"`).

| Метод | Возврат | Описание |
|-------|---------|----------|
| `ConfigGetText(path, out value)` | `bool` | Строка |
| `ConfigGetTextRaw(path, out value)` | `bool` | Строка без локализации (`$STR_` не раскрываются) |
| `ConfigGetFloat(path)` | `float` | Число с плавающей точкой |
| `ConfigGetInt(path)` | `int` | Целое число |
| `ConfigGetVector(path)` | `vector` | Вектор |
| `ConfigGetTextArray(path, out values)` | `void` | Массив строк |
| `ConfigGetFloatArray(path, out values)` | `void` | Массив float |
| `ConfigGetIntArray(path, out values)` | `void` | Массив int |
| `ConfigGetType(path)` | `int` | Тип: `CT_INT`, `CT_FLOAT`, `CT_STRING`, `CT_ARRAY`, `CT_CLASS` |
| `ConfigGetChildName(path, index, out name)` | `bool` | Имя подкласса по индексу |
| `ConfigGetBaseName(path, out base_name)` | `bool` | Имя базового класса |
| `ConfigGetChildrenCount(path)` | `int` | Кол-во подклассов |
| `ConfigIsExisting(path)` | `bool` | Путь существует |
| `ConfigGetFullPath(path, out full_path)` | `void` | Полный путь (массив) |

#### Игроки и сеть (proto native)

| Метод | Описание |
|-------|----------|
| `CreatePlayer(identity, name, pos, radius, spec)` | Создать игрока (сервер) |
| `SelectPlayer(identity, player)` | Назначить управляемый объект |
| `SelectSpectator(identity, spectatorObjType, position)` | Создать наблюдателя |
| `UpdateSpectatorPosition(position)` | Обновить позицию сетевого бабла |
| `DisconnectPlayer(identity, uid)` | Кикнуть игрока (сервер) |
| `SendLogoutTime(player, time)` | Отправить экран выхода клиенту |
| `GetPlayerNetworkIDByIdentityID(id, out low, out high)` | ID игрока → network ID |
| `GetObjectByNetworkId(low, high)` | Network ID → объект |
| `RegisterNetworkStaticObject(object)` | Включить репликацию статического объекта |
| `AddToReconnectCache(identity)` | Добавить в кеш реконнекта (сервер) |
| `RemoveFromReconnectCache(uid)` | Удалить из кеша |

#### Соединение (proto native)

| Метод | Описание |
|-------|----------|
| `Connect(parent, ip, port, password)` | Подключиться к серверу |
| `ConnectLastSession(parent, selectedCharacter)` | Переподключиться |
| `DisconnectSession()` | Отключиться |
| `DisconnectSessionForce()` | Принудительное отключение |
| `GetHostAddress(out address, out port)` | Адрес сервера |
| `GetHostName()` | Имя сервера |

#### Профиль и система (proto native)

| Метод | Описание |
|-------|----------|
| `GetProfileString(name, out value)` / `SetProfileString(name, value)` | Строка профиля |
| `GetProfileStringList(name, out values)` / `SetProfileStringList(name, values)` | Массив строк профиля |
| `SaveProfile()` | Сохранить профиль на диск |
| `GetPlayerName(out name)` / `SetPlayerName(name)` | Имя игрока |
| `CommandlineGetParam(name, out value)` | Параметр командной строки |
| `CopyToClipboard(text)` / `CopyFromClipboard(out text)` | Буфер обмена |
| `StorageVersion(version)` | Установить версию хранилища |
| `LoadVersion()` / `SaveVersion()` | Текущая версия загрузки/сохранения |
| `GetTickTime()` | Время от старта игры (сек) |
| `GetDayTime()` | Игровое время суток (сервер) |
| `GetFps()` / `GetAvgFPS(n)` / `GetMinFPS(n)` / `GetMaxFPS(n)` | FPS-статистика |
| `RequestExit(code)` / `RequestRestart(code)` | Выход/рестарт |
| `IsAppActive()` | Окно в фокусе |
| `AdminLog(text)` | Запись в админ-лог |

#### Juncture (proto native, сервер)

Механизм блокировки предметов при сетевых операциях.

| Метод | Описание |
|-------|----------|
| `AddInventoryJuncture(player, item, dst, test_dst_occupancy, timeout_ms)` | Создать блокировку |
| `HasInventoryJunctureItem(item)` | Предмет заблокирован (любой игрок) |
| `HasInventoryJuncture(player, item)` | Предмет заблокирован конкретным игроком |
| `HasInventoryJunctureDestination(player, dst)` | Место назначения заблокировано |
| `AddActionJuncture(player, item, timeout_ms)` | Блокировка для действия |
| `ExtendActionJuncture(player, item, timeout_ms)` | Продлить блокировку |
| `ClearJuncture(player, item)` | Снять блокировку |

### DayZGame

Наследует `CGame`. Управляет состояниями загрузки, модальными экранами, профилями DayZ.

#### Состояния

```
DayZGameState: UNDEFINED, MAIN_MENU, JOINING, IN_GAME, CONNECTING
DayZLoadState: UNDEFINED, MAIN_MENU_START, MAIN_MENU_CONTROLLER_SELECT,
               MAIN_MENU_USER_SELECT, JOIN_START, JOIN_CONTROLLER_SELECT,
               JOIN_USER_SELECT, MISSION_START, MISSION_USER_SELECT
```

#### Коллизии снарядов

| Класс | Описание |
|-------|----------|
| `ProjectileStoppedInfo` | Базовый: `GetSource()`, `GetPos()`, `GetInVelocity()`, `GetAmmoType()`, `GetProjectileDamage()` |
| `CollisionInfoBase` | + `GetSurfNormal()` |
| `ObjectCollisionInfo` | + `GetHitObj()`, `GetHitObjPos()`, `GetHitObjRot()`, `GetComponentIndex()` |
| `TerrainCollisionInfo` | + `GetIsWater()` |

#### CrashSoundSets

Статический реестр звуков столкновений по хешу.

| Метод | Описание |
|-------|----------|
| `RegisterSoundSet(sound_set)` | Зарегистрировать звуковой набор |
| `GetSoundSetByHash(hash)` | Получить по хешу |

### World

Управление игровым миром. Доступ: `g_Game.GetWorld()`. Источник: `global/world.c`

#### Время и дата (proto native)

| Метод | Описание |
|-------|----------|
| `GetDate(out y, out m, out d, out h, out min)` | Текущая игровая дата |
| `SetDate(y, m, d, h, min)` | Установить дату |
| `SetTimeMultiplier(mult)` | Множитель скорости времени |

#### География (proto native)

| Метод | Возврат | Описание |
|-------|---------|----------|
| `GetLatitude()` | `float` | Широта (для расчёта солнца) |
| `GetLongitude()` | `float` | Долгота |
| `GetMoonIntensity()` | `float` | Интенсивность луны |
| `GetSunOrMoon()` | `float` | 0 = луна, 1 = солнце |
| `IsNight()` | `bool` | Ночь |

#### Видимость (proto native)

| Метод | Описание |
|-------|----------|
| `SetPreferredViewDistance(dist)` | Предпочтительная дальность |
| `SetViewDistance(dist)` | Дальность прорисовки |
| `SetObjectViewDistance(dist)` | Дальность объектов |
| `GetEyeAccom()` | Текущая адаптация глаз |
| `SetEyeAccom(value)` | Установить адаптацию |

#### Навигация (proto native)

| Метод | Описание |
|-------|----------|
| `GetAIWorld()` | Объект `AIWorld` |
| `UpdatePathgraphDoorByAnimationSourceName(building, animSource)` | Обновить навмеш для двери |
| `MarkObjectForPathgraphUpdate(object)` | Пометить объект для пересчёта навмеша |

#### Звук и материалы (proto native)

| Метод | Описание |
|-------|----------|
| `GetMaterial(materialName)` | Получить материал |
| `CheckSoundObstruction(source, pos1, pos2, geometry)` | Проверить звуковое препятствие |

#### Игроки (proto native)

| Метод | Описание |
|-------|----------|
| `GetPlayerList(out array)` | Список игроков |
