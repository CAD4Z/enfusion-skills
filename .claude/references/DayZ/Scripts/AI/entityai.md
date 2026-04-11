EntityAI — базовый класс всех интерактивных сущностей. Наследует `Entity` (1_Core). От него наследуются предметы, существа, транспорт и игрок.

Файл: `3_game/entities/entityai.c` (~4600 строк). Описывает не AI-поведение, а **общий фундамент для всех сущностей**, включая тех, которые управляются AI.

### Иерархия наследования

```
Entity (1_Core, proto native)
 └── EntityAI (3_Game)
      ├── DayZCreature → DayZCreatureAI → DayZInfected / DayZAnimal
      ├── Man → DayZPlayer → DayZPlayerImplement
      ├── InventoryItem
      ├── Transport
      └── AdvancedCommunication
```

Типовые проверки: `IsMan()`, `IsAnimal()`, `IsZombie()`, `IsWeapon()`, `IsMagazine()`, `IsTransport()` — все возвращают `false` по умолчанию, переопределяются в наследниках.

---

### Жизненный цикл

#### Инициализация

```
Конструктор EntityAI()
 ├── Создание EnergyManager (если есть в конфиге)
 ├── Регистрация сетевых переменных
 ├── InitDamageZoneMapping() — маппинг зон урона из конфига
 ├── InitItemVariables() — температурные параметры из конфига
 └── CallLater(DeferredInit, 34ms) — отложенная инициализация
      └── m_Initialized = true

EEInit() — после создания сущности движком
 ├── Инициализация инвентаря
 ├── MaxLifetimeRefreshCalc()
 └── InitTemperature() (сервер)
```

`DeferredInit()` — вызывается через 34мс после конструктора. Нужен для операций, которые требуют полной инициализации сущности в мире.

#### CE (Central Economy) события

- `EEOnCECreate()` — сущность создана системой центральной экономики
- `AfterStoreLoad()` — загружена из БД (после загрузки всех дочерних сущностей)
- `EEOnAfterLoad()` — восстановление связей (например, электроподключения)

#### Удаление

- `EEDelete(parent)` — прямо перед удалением. Оповещает инвентарь и EnergyManager
- `EEKilled(killer)` — при смерти. Вызывает `DeathUpdate()` через 250мс если `ReplaceOnDeath() == true`
- `DeathUpdate()` — создаёт мёртвый объект (`GetDeadItemName()`), переносит ориентацию, удаляет оригинал

#### Персистентность

- `OnStoreSave(ctx)` — сохранение в БД. Записывает состояние EnergyManager и переменные
- `OnStoreLoad(ctx, version)` — загрузка из БД. `version` — для обратной совместимости
- `GetPersistentID(out b1, b2, b3, b4)` — уникальный ID, переживает рестарт сервера

---

### Система урона и зоны попадания

#### Зоны урона (Damage Zones)

`InitDamageZoneMapping()` при инициализации строит карту зон из конфига (`DamageSystem.GetDamageZoneMap()`). Каждая зона — именованная область модели с собственным здоровьем.

`EEHealthLevelChanged(oldLevel, newLevel, zone)` — ключевой callback при смене уровня здоровья. При достижении `STATE_RUINED`:
- Уведомляет родителя (`OnAttachmentRuined`)
- Если `zone` пуст (глобальное здоровье) — `OnDamageDestroyed()`
- Запускает DestructionBehaviour если настроен

#### HitComponents для AI

Механизм, через который AI выбирает **куда целиться**:

- `GetHitComponentForAI()` — взвешенный случайный выбор зоны. По умолчанию — ошибка (нужно переопределить)
- `GetDefaultHitComponent()` — зона по умолчанию
- `GetDefaultHitPosition()` — позиция по умолчанию
- `GetSuitableFinisherHitComponents()` — зоны для финишера (backstab)

Каждый наследник реализует свою логику: у DayZInfected зоны берутся из `DayZInfectedType`, у DayZAnimal — через `RegisterHitComponentsForAI()` с весами.

#### AI Targeting

`CanBeTargetedByAI(EntityAI ai)` — может ли AI атаковать эту сущность:
- `false` если AI в процессе backstab
- `false` если физическое тело неактивно (и не Man)
- `false` если `IsDamageDestroyed()`

`SetAITargetCallbacks(callbacks)` — proto native. Регистрирует callbacks видимости/позиции для AI-системы (см. infrastructure.md).

---

### Сетевая синхронизация

#### Регистрация переменных

Вызывается в конструкторе. Переменные синхронизируются автоматически при изменении:

- `RegisterNetSyncVariableBool(name)` — bool
- `RegisterNetSyncVariableBoolSignal(name)` — bool-сигнал (автоматически сбрасывается в false после отправки)
- `RegisterNetSyncVariableInt(name, min, max)` — int с квантизацией
- `RegisterNetSyncVariableFloat(name, min, max, precision)` — float с квантизацией
- `RegisterNetSyncVariableObject(name)` — ссылка на объект (по network ID)

`SetSynchDirty()` — пометить объект для синхронизации. `OnVariablesSynchronized()` — callback на клиенте при получении данных.

Квантизация: при указании min/max значения сжимаются для экономии трафика. `precision` — количество знаков после запятой.

---

### Иерархия и инвентарь

- `GetHierarchyRoot()` — корень иерархии (proto native)
- `GetHierarchyRootPlayer()` — корень как Man (proto native)
- `GetHierarchyParent()` — прямой родитель (proto native)

События инвентаря (вызываются на **родителе**):
- `EEItemAttached(item, slot)` / `EEItemDetached(item, slot)` — аттачменты
- `EECargoIn(item)` / `EECargoOut(item)` — карго
- `EEItemLocationChanged(oldLoc, newLoc)` — любое перемещение

Система exclusion-масок: при аттаче проверяет совместимость слотов (например, шлем + очки).

---

### Компоненты

Ленивая система через `ComponentsBank`:

- `CreateComponent(type)` — создать компонент (создаёт банк если нужно)
- `HasComponent(type)` / `GetComponent(type)` — проверка/получение
- Компоненты получают события: `Event_OnItemAttached`, `Event_OnItemDetached`, `Event_OnFrame`

Основные типы: `COMP_TYPE_ENERGY_MANAGER`, `COMP_TYPE_BODY_STAGING`, `COMP_TYPE_ETITY_DEBUG`.

---

### Ключевые подсистемы (кратко)

**Температура**: параметры из конфига (`varTemperatureInit/Min/Max`, `varTemperatureFreezePoint/ThawPoint`). Синхронизируется по сети. Заморозка/разморозка с прогрессом. Живые организмы (`IsMan/IsAnimal/IsZombie && IsAlive`) саморегулируют температуру.

**Вес**: dirty-флаг система. `SetWeightDirty()` при любом изменении содержимого. Пересчёт рекурсивный по иерархии.

**Lifetime (CE)**: `SetLifetime()` / `GetLifetime()` — оставшееся время жизни в секундах. `IncreaseLifetimeUp()` — сброс таймера вверх по иерархии (взаимодействие с предметом продлевает жизнь контейнера).
