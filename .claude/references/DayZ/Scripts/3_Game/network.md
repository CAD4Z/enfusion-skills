Сетевое взаимодействие: RPC, сериализация, HTTP, Hive, события. Источники: `gameplay.c`, `syncevents.c`, `http/`, `hive/`

### ScriptRPC

Механизм удалённого вызова процедур. Наследует `ParamsWriteContext`. Источник: `gameplay.c`

| Метод | Описание |
|-------|----------|
| `Reset()` | Очистить буфер записи |
| `Send(target, rpc_type, guaranteed, recipient)` | Отправить. `target=NULL` → глобальный. `guaranteed=true` → TCP-подобная доставка. `recipient=NULL` → всем |

Данные пишутся через `Write(value)` (наследуется от `ParamsWriteContext`).

Приём: `CGame.OnRPC(sender, target, rpc_type, ctx)` — `ctx` это `ParamsReadContext`, читать через `ctx.Read(value)`.

#### Паттерн

```enforcescript
// Отправка (клиент)
ScriptRPC rpc = new ScriptRPC();
rpc.Write(someInt);
rpc.Write(someString);
rpc.Send(target, MY_RPC_ID, true, null);

// Приём (в OnRPC)
int val; string str;
ctx.Read(val);
ctx.Read(str);
```

### JsonSerializer

JSON-сериализация. Наследует `Serializer`. Источник: `gameplay.c`

| Метод | Описание |
|-------|----------|
| `WriteToString(variable, nice, out result)` | Объект → JSON строка. `nice=true` → форматированный |
| `ReadFromString(variable, json, out error)` | JSON строка → объект |

### Вспомогательные сетевые контексты

| Класс | Описание |
|-------|----------|
| `ScriptInputUserData` | Пользовательский ввод для сети (наследует `ParamsWriteContext`) |
| `ScriptReadWriteContext` | Двунаправленный контекст |
| `ScriptRemoteInputUserData` | Входящий ввод от удалённого клиента |
| `ScriptJunctureData` | Данные juncture |

### MeleeCombatData

Данные ближнего боя. Proto native.

| Метод | Описание |
|-------|----------|
| `GetModesCount()` | Количество режимов |
| `GetModeName(index)` | Имя режима |
| `GetAmmoTypeName(index)` | Тип боеприпаса режима |
| `GetModeRange(index)` | Дальность режима |

### Selection

Геометрическая selection. Proto native.

| Метод | Описание |
|-------|----------|
| `GetName()` | Имя selection |
| `GetVertexCount()` | Количество вершин |
| `GetLODVertexIndex(vertex)` | Индекс вершины в LOD |

### SyncEvents

Статический broadcast сетевых событий. Источник: `syncevents.c`

| Метод | Описание |
|-------|----------|
| `SendPlayerList()` | Список игроков |
| `SendEntityKilled(victim, killer, source, isHeadshot)` | Смерть сущности |
| `SendPlayerIgnatedFireplace(player, igniteType)` | Розжиг костра |

### REST API

HTTP-клиент. Источник: `http/`

#### ERestResultState

```
EREST_EMPTY, EREST_PENDING, EREST_FEEDING, EREST_SUCCESS, EREST_PROCESSED,
EREST_ERROR, EREST_ERROR_CLIENTERROR, EREST_ERROR_SERVERERROR,
EREST_ERROR_APPERROR, EREST_ERROR_TIMEOUT, EREST_ERROR_UNKNOWN
```

#### RestApi

Менеджер контекстов. Proto native.

#### RestContext

HTTP-контекст. Proto native.

| Метод | Описание |
|-------|----------|
| `GET(callback, url)` | Асинхронный GET |
| `GET_now(url, out result)` | Синхронный GET |
| `POST(callback, url, data)` | Асинхронный POST |
| `POST_now(url, data, out result)` | Синхронный POST |
| `FILE(callback, url, fileName)` | Скачать файл |
| `FILE_now(url, fileName)` | Синхронное скачивание |
| `SetHeader(headerKey)` | Установить HTTP-заголовок |
| `reset()` | Сброс контекста |

#### RestCallback

Callback для асинхронных запросов.

| Метод | Описание |
|-------|----------|
| `OnSuccess(data, dataSize)` | Успех |
| `OnError(errorCode)` | Ошибка |
| `OnTimeout()` | Таймаут |
| `OnFileCreated(fileName, dataSize)` | Файл создан |

### Hive

Система персистентности персонажей. Источник: `hive/`

#### Управление (proto native)

| Метод | Описание |
|-------|----------|
| `InitOnline(host)` | Подключение к базе |
| `InitOffline()` | Оффлайн режим |
| `InitSandbox()` | Sandbox режим |
| `IsIdleMode()` | Режим простоя |
| `SetShardID(id)` / `SetEnviroment(env)` | Конфигурация сервера |

#### Персонажи (proto native)

| Метод | Описание |
|-------|----------|
| `CharacterSave(player)` | Сохранить персонажа |
| `CharacterKill(player)` | Зафиксировать смерть |
| `CharacterExit(player)` | Зафиксировать выход |
| `CharacterIsLoginPositionChanged(player)` | Позиция изменилась с последнего входа |
| `CallUpdater()` | Вызвать обновление |

#### Глобальные функции

`CreateHive()`, `DestroyHive()`, `GetHive()` — управление синглтоном.

### ERPCs (ключевые)

Определены в `enums/erpcs.c`. Обширный enum идентификаторов RPC. Группы:

- **Отладка**: `RPC_DAYZ_FORCE_WEATHER_*`, `RPC_CFG_GAMEPLAY_SYNC`, `RPC_UNDERGROUND_*`
- **Геймплей**: `RPC_PLAYER_STAT_*`, `RPC_SYNC_EVENT_*`, `RPC_ITEM_*`
- **UI**: `RPC_USER_ACTION_MESSAGE`, `RPC_SOFT_SKILLS_*`
- **Транспорт**: `RPC_EXPLODE_EVENT`

Используется в `ScriptRPC.Send()` как `rpc_type`.
