Система плагинов — сервисная шина для игровых подсистем. Источники: `plugins/`

### Архитектура

```
PluginBase               — базовый класс плагина
PluginManager            — реестр и lifecycle менеджер всех плагинов
  g_Plugins              — глобальный синглтон PluginManager
```

Глобальная функция доступа: `GetPlugin(typename)` → `PluginBase`

### PluginBase

```
class PluginBase
```

| Метод | Описание |
|-------|----------|
| `OnInit()` | Инициализация после создания |
| `OnUpdate(float delta_time)` | Обновление каждый кадр (CALL_CATEGORY_GAMEPLAY) |
| `OnDestroy()` | Очистка при удалении |
| `GetModuleName()` | Имя класса (для логирования) |
| `Log(msg, label)` | Вывод через `Debug.Log` |

### PluginManager

Управляет lifecycle всех зарегистрированных плагинов.

#### Регистрация

```c
RegisterPlugin(className, regOnClient, regOnServer, regOnRelease=true)
RegisterPluginDiag(...)   // только при #define DIAG_DEVELOPER
RegisterPluginDebug(...)  // только при IsDebug()
```

Порядок загрузки плагинов (из `Init()`):

| Плагин | Client | Server | Тип |
|--------|--------|--------|-----|
| `PluginHorticulture` | ✓ | ✓ | Release |
| `PluginRepairing` | ✓ | ✓ | Release |
| `PluginPlayerStatus` | ✓ | ✓ | Release |
| `PluginMessageManager` | ✓ | ✓ | Release |
| `PluginLifespan` | ✓ | ✓ | Release |
| `PluginVariables` | ✓ | ✓ | Release |
| `PluginObjectsInteractionManager` | — | ✓ | Release |
| `PluginRecipesManager` | ✓ | ✓ | Release |
| `PluginTransmissionAgents` | ✓ | ✓ | Release |
| `PluginConfigEmotesProfile` | ✓ | ✓ | Release |
| `PluginPresenceNotifier` | ✓ | — | Release |
| `PluginAdminLog` | — | ✓ | Release |
| `PluginKeyBinding` | ✓ | ✓* | Diag |
| `PluginDeveloper` | ✓ | ✓ | Diag |
| `PluginDeveloperSync` | ✓ | ✓ | Diag |
| `PluginDiagMenuClient` | ✓ | — | Diag |
| `PluginDiagMenuServer` | — | ✓ | Diag |
| `PluginInventoryDebug` | ✓ | ✓ | Debug+Diag |
| `PluginSceneManager` | ✓ | ✓ | Debug |
| `PluginDayzPlayerDebug` | ✓ | ✓ | Debug |
| `PluginCameraTools` | ✓ | ✓ | Debug |

(*NO_GUI: только client)

#### Lifecycle

```
PluginManagerInit()
  → g_Plugins = new PluginManager
  → Init()     — регистрация плагинов
  → PluginsInit() — создание экземпляров + OnInit()

MainOnUpdate(dt) — вызывается каждый кадр, обновляет все плагины
PluginManagerDelete() — деструктор всех плагинов
```

#### API

```c
PluginManager GetPluginManager()
PluginBase    GetPlugin(typename plugin_type)         // с диагностикой
PluginBase    GetPluginSafe(typename plugin_type)     // без диагностики
bool          IsModuleExist(typename plugin_type)
bool          IsPluginManagerExists()
```

---

### PluginDeveloper

```
class PluginDeveloper extends PluginBase
```

Инструменты разработчика: телепортация, свободная камера, спаун предметов, консоль.

```c
static PluginDeveloper GetInstance()  // shortcut
```

#### Возможности

| Метод | Описание |
|-------|----------|
| `TeleportAtCursor()` | Телепорт игрока под курсор |
| `Teleport(player, pos)` | Телепорт в заданную позицию |
| `SetDirection(player, dir)` | Установить направление игрока |
| `ToggleFreeCamera()` | Переключить свободную камеру (с телепортом) |
| `ToggleFreeCameraBackPos()` | Переключить свободную камеру (без телепорта) |
| `IsEnabledFreeCamera()` | Состояние свободной камеры |
| `PrintLogClient(msg)` | Вывод в Script Console |
| `SendServerLogToClient(msg)` | Трансляция серверного лога всем клиентам |

#### RPC-обработка (только `#ifdef DIAG_DEVELOPER`)

| RPC | Описание |
|-----|----------|
| `DEV_RPC_SPAWN_ITEM_ON_GROUND` | Спаун предмета на земле |
| `DEV_RPC_SPAWN_ITEM_ON_GROUND_PATTERN_GRID` | Спаун предметов сеткой |
| `DEV_RPC_SPAWN_ITEM_ON_CURSOR` | Спаун по направлению курсора |
| `DEV_RPC_SPAWN_ITEM_IN_INVENTORY` | Спаун в инвентарь |
| `DEV_RPC_CLEAR_INV` | Очистить инвентарь |
| `DEV_RPC_SPAWN_PRESET` | Спаун пресета предметов |
| `DEV_RPC_SET_TIME` | Установить игровое время |

`DevSpawnItemParams` = `Param7<EntityAI, string, float, float, bool, string, FindInventoryLocationType>` (target, item_name, health, quantity, special, presetName, locationType)

---

### PluginDiagMenu

```
class PluginDiagMenu extends PluginBase
```

Регистрирует диагностическое меню (`DiagMenu`). Только `#ifdef DIAG_DEVELOPER`.

Разделяется на:
- `PluginDiagMenuClient` — только клиент
- `PluginDiagMenuServer` — только сервер

#### Структура меню

```
DiagMenuIDs.SCRIPTS_MENU  ("Script")
  ├── VEHICLES          — Vehicle debug output, Crash log, Flip context
  ├── INVENTORY_MENU    — Инвентарь
  ├── ...               — и другие подменю
  └── MODDED_MENU       — Для модов (PluginDiagMenuModding)
```

#### Для модов

`PluginDiagMenuModding` — отдельное изолированное меню для модов, не затрагивает vanilla диаги. Модов рекомендуется использовать именно его, не переопределяя vanilla файлы.

---

### PluginConfigHandler

```
class PluginConfigHandler extends PluginFileHandler
```

Парсер/сериализатор файла конфигурации пользователя (`CFG_FILE_USER_PROFILE`). Данные представлены как `array<ref CfgParam>`.

#### API

| Метод | Описание |
|-------|----------|
| `LoadConfigFile()` | Загрузить файл в `m_CfgParams` |
| `SaveConfigToFile()` | Сериализовать `m_CfgParams` и сохранить |
| `GetParamByName(name, type)` | Найти параметр (создаёт если нет) |
| `GetAllParams()` | Все параметры |
| `ParamExist(name)` | Проверить существование |
| `RemoveParamByName(name)` | Удалить параметр |
| `RenameParam(name, new_name)` | Переименовать |

Поддерживаемые типы: `CFG_TYPE_STRING`, `CFG_TYPE_INT`, `CFG_TYPE_FLOAT`, `CFG_TYPE_BOOL`, `CFG_TYPE_ARRAY`, `CFG_TYPE_PARAM`

Формат файла: `name=value` или `name={val1,val2}`. Парсер: `ParseText(string)` — определяет тип по контексту.

---

### PluginLocalProfile

```
class PluginLocalProfile extends PluginFileHandler
```

Хранит пользовательские настройки в файле профиля в виде нескольких карт:

```
m_ConfigParams              : map<string, string>                     — простые значения
m_ConfigParamsArray         : map<string, TStringArray>               — массивы строк
m_ConfigParamsInArray       : map<string, map<string, string>>        — параметры внутри одного массива
m_ConfigParamsArrayInArray  : map<string, array<map<string, string>>> — массив объектов
```

#### API

| Метод | Описание |
|-------|----------|
| `GetParameterString/Int/Float/Bool(name)` | Чтение с автосозданием при отсутствии |
| `SetParameterString/Int/Float/Bool(name, value, saveInFile)` | Запись |
| `GetParameterArray(name)` | Массив строк |
| `SetParameterArray(name, value)` | Запись массива |
| `GetSubParameterInArrayString(param, idx, subParam)` | Элемент вложенного массива |
| `SetSubParameterInArray(param, idx, subParam, value)` | Запись во вложенный массив |
| `RemoveParameter(name)` / `RemoveParameterArray(name)` | Удаление |
| `RenameParameter(old, new)` / `RenameParameterArray(old, new)` | Переименование |
| `LoadConfigFile()` | Парсинг файла профиля |
| `SaveConfigToFile()` | Сериализация и сохранение |

Формат файла: `param_name = value` или `param_name = {val1,val2}` или `param_name = {{k=v},{k=v}}`.
