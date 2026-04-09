Компонентная система и температурный источник. Источники: `tools/component.c`, `systems/temperature/`

### Component

Базовый класс компонентов сущностей. Источник: `tools/component.c`

#### Типы компонентов

| Константа | Значение | Описание |
|-----------|----------|----------|
| `COMP_TYPE_ENTITY_DEBUG` | `0` | Отладка сущности |
| `COMP_TYPE_ENERGY_MANAGER` | `1` | Энергетическая система |
| `COMP_TYPE_BODY_STAGING` | `2` | Стадии разделки тела |
| `COMP_TYPE_ANIMAL_BLEEDING` | `3` | Кровотечение животных |

#### Lifecycle

| Метод | Описание |
|-------|----------|
| `SetParentEntityAI(parent)` | Привязка к сущности |
| `Event_OnAwake()` | Пробуждение |
| `Event_OnInit()` | Инициализация |
| `Event_OnFrame(entity, timeslice)` | Обновление каждый кадр |

#### Использование

```enforcescript
// Создание через EntityAI
entity.CreateComponent(COMP_TYPE_ENERGY_MANAGER);
ComponentEnergyManager em = entity.GetComponent(COMP_TYPE_ENERGY_MANAGER);
```

### ComponentEnergyManager

Управление электрической энергией предметов. Сетевая синхронизация: `m_IsSwichedOn`, `m_CanWork`, `m_IsPlugged`, `m_Energy`.

#### Ключевые методы

| Метод | Описание |
|-------|----------|
| `SwitchOn()` / `SwitchOff()` | Включить/выключить |
| `CanWork()` | Может ли работать |
| `GetEnergy()` / `SetEnergy(value)` | Текущий заряд |
| `HasEnoughStoredEnergy()` | Достаточно энергии |
| `GetEnergyMax()` | Максимальная ёмкость |
| `GetEnergyUsage()` | Расход в секунду |
| `IsPlugged()` | Подключён к источнику |
| `PlugThisInto(source)` / `UnplugThis()` | Подключение/отключение |
| `GetEnergySource()` | Источник энергии |
| `ConsumeEnergy(amount)` | Потребить |
| `AddEnergy(amount)` | Добавить |
| `IsWorking()` | Работает сейчас |
| `SetDebugPlugs(enable)` | Отладочный режим |

### ComponentBodyStaging

Стадии разделки тел (животных/игроков).

### ComponentAnimalBleeding

Кровотечение животных.

### ComponentsBank

Внутренний реестр компонентов сущности. Создаётся лениво при первом `GetComponent()`.

| Метод | Описание |
|-------|----------|
| `GetComponent(comp_type, extended)` | Получить/создать компонент |
| `DeleteComponent(comp_type)` | Удалить |
| `IsComponentAlreadyExist(comp_type)` | Проверка |

---

## UniversalTemperatureSource

Универсальный источник температуры. Источник: `systems/temperature/`

Система расчёта температуры для костров, печей, транспорта и любых нагревающих/охлаждающих объектов.

### UniversalTemperatureSource

| Метод | Описание |
|-------|----------|
| `SetActive(state)` | Активировать/деактивировать |
| `IsActive()` | Активен |
| `GetTemperature()` | Текущая температура |
| `Update(settings)` | Обновить расчёт |

### UniversalTemperatureSourceLambdaBase

Лямбда-функция расчёта температуры. Переопределяется для кастомной логики нагрева/охлаждения.

### TemperatureAccessManager

Менеджер доступа к температурным данным. Центральный узел обновления температур.

### TemperatureAccessComponent

Компонент привязки к EntityAI. Создаётся автоматически для сущностей с `CanHaveTemperature() == true`.

### TemperatureData

Контейнер температурных данных.

| Поле | Описание |
|------|----------|
| `m_Value` | Текущая температура |
| `m_Min` / `m_Max` | Пределы |
| `m_FreezeThreshold` / `m_ThawThreshold` | Пороги замерзания/оттаивания |
| `m_FreezeTime` / `m_ThawTime` | Время замерзания/оттаивания |
| `m_HeatPermeabilityCoef` | Коэффициент теплопроницаемости |
