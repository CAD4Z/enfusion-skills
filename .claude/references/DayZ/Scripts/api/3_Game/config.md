Конфигурация геймплея, моды, спавнеры. Источники: `cfggameplaydatajson.c`, `cfggameplayhandler.c`, `modinfo.c`, `objectspawner.c`

### CfgGameplayHandler

Статический менеджер конфигурации геймплея. Загружает `cfggameplay.json`. Источник: `cfggameplayhandler.c`

#### Lifecycle

| Метод | Описание |
|-------|----------|
| `LoadData()` | Загрузить JSON или использовать значения по умолчанию |
| `ValidateItems()` / `InitData()` | Валидация и инициализация |
| `SyncDataSend(identity)` | Отправить конфиг клиенту (сервер) |
| `SyncDataSendEx(identity)` | Расширенная отправка |
| `OnRPC(target, ctx)` | Приём конфига от сервера (клиент) |

#### Основные геттеры (static)

**Базовые настройки:**

| Метод | Описание |
|-------|----------|
| `GetDisablePersonalLight()` | Отключить персональный свет |
| `GetDisableBaseDamage()` | Отключить урон базам |
| `GetDisableContainerDamage()` | Отключить урон контейнерам |
| `GetDisableRespawnDialog()` | Отключить диалог респавна |

**Выносливость:**

| Метод | Описание |
|-------|----------|
| `GetStaminaMax()` | Максимальная выносливость |
| `GetStaminaKgToStaminaPercentPenalty()` | Штраф кг → % выносливости |
| `GetStaminaMinCap()` | Минимальный порог |
| `GetSprintStaminaModifierErc/Cro()` | Модификатор спринта стоя/присед |

**Шок:**

| Метод | Описание |
|-------|----------|
| `GetShockRefillSpeedConscious/Unconscious()` | Скорость восстановления шока |

**Погода:**

| Метод | Описание |
|-------|----------|
| `GetWeatherParameters()` | Параметры погоды |

**Мир:**

| Метод | Описание |
|-------|----------|
| `GetLightingConfig()` | Конфигурация освещения |
| `GetObjectSpawnersArr()` | Массив спавнеров объектов |
| `GetEnvironmentMinTemps()` / `GetEnvironmentMaxTemps()` | Температурные диапазоны |

### CfgGameplayJson

Модель данных JSON-конфигурации. Источник: `cfggameplaydatajson.c`

#### Структура

```
CfgGameplayJson
├── version: int
├── GeneralData
│   ├── disableBaseDamage, disableContainerDamage
│   └── disableRespawnDialog
├── PlayerData
│   ├── stamina (max, penalty, minCap, sprint modifiers)
│   ├── shock (refill speeds)
│   ├── movement (timeToStrafeJog/Sprint)
│   ├── drowning (enabled)
│   └── weaponObstruction (enabled)
├── WorldData
│   ├── lighting config
│   ├── objectSpawners[]
│   ├── environmentMinTemps[], environmentMaxTemps[]
│   └── wetnessWeightModifiers[]
├── BaseBuildingData
├── UIData
├── MapData
└── VehicleData
```

Каждая секция — наследник `ITEM_DataBase` с методами `ValidateServer()`, `InitServer()`.

### ModInfo

Информация о моде/DLC. Proto native. Источник: `modinfo.c`

#### Данные (proto native)

| Метод | Возврат | Описание |
|-------|---------|----------|
| `GetName()` | `string` | Имя мода |
| `GetAuthor()` | `string` | Автор |
| `GetVersion()` | `string` | Версия |
| `GetPicture()` | `string` | Основное изображение |
| `GetLogo()` / `GetLogoSmall()` / `GetLogoOver()` | `string` | Логотипы |
| `GetTooltip()` | `string` | Подсказка |
| `GetOverview()` | `string` | Описание |
| `GetAction()` | `string` | URL действия |
| `GetDefault()` | `bool` | Мод по умолчанию |
| `GetIsDLC()` | `bool` | Это DLC |
| `GetIsOwned()` | `bool` | Владеет ли игрок |
| `GoToStore()` | `void` | Открыть магазин |

#### Static

`GetDLCImage(name)` — текстура по имени DLC (`"badlands"`, `"frostline"` и др.)

### ObjectSpawnerHandler

Спавн статических объектов из JSON. Источник: `objectspawner.c`

| Метод | Описание |
|-------|----------|
| `SpawnObjects()` | Загрузить и заспавнить все объекты из JSON |
| `SpawnObject(item)` | Заспавнить один объект |
| `ValidatePath(path)` | Проверить whitelist путей P3D |

#### VALID_PATHS

Whitelist для моделей: растения, камни по DLC (Chernarus, Enoch, Sakhal).

#### ITEM_SpawnerObject

| Поле | Тип | Описание |
|------|-----|----------|
| `name` | `string` | Путь к P3D |
| `pos[3]` | `float` | Позиция XYZ |
| `ypr[3]` | `float` | Yaw/Pitch/Roll |
| `scale` | `float` | Масштаб |
| `enableCEPersistency` | `bool` | Персистентность через CE |
