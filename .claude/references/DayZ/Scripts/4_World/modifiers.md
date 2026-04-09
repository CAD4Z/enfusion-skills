`4_World` — модификаторы, агенты, симптомы. Три связанные системы: агенты (инфекция) → модификаторы (болезнь/состояние) → симптомы (проявление). Источники: `classes/playermodifiers/`, `classes/transmissionagents/`, `classes/playersymptoms/`

### Пайплайн

```
Вход агентов → Рост/Убыль в AgentPool → Порог → Активация модификатора → Симптомы
     ↑                    ↑                                    ↓
  Еда/Раны/       ImmuneSystem                         Stat-эффекты
  Воздух/Зоны      (иммунитет)                        (здоровье, вода...)
                       ↑                                    ↓
                  Антибиотики → Снижение агентов → Деактивация → Временный иммунитет
```

---

### Агенты

Базовый класс: `AgentBase`. Пул игрока: `PlayerAgentPool` (`m_AgentPool` в `PlayerBase`).

#### eAgents (битовая маска)

| Агент | Значение |
|-------|----------|
| `CHOLERA` | 1 |
| `INFLUENZA` | 2 |
| `SALMONELLA` | 4 |
| `BRAIN` | 8 |
| `FOOD_POISON` | 16 |
| `CHEMICAL_POISON` | 32 |
| `WOUND_AGENT` | 64 |
| `NERVE_AGENT` | 128 |
| `HEAVYMETAL` | 256 |

#### AgentBase — конфигурация (задаётся в `Init()`)

| Поле | Описание |
|------|----------|
| `m_Type` | `eAgents` значение |
| `m_Invasibility` | Скорость роста в секунду |
| `m_TransferabilityIn/Out` | Коэффициент передачи |
| `m_TransferabilityAirOut` | Воздушное распространение |
| `m_Digestibility` | Множитель при переваривании (по умолчанию 0.1) |
| `m_MaxCount` | Максимум в пуле |
| `m_Potency` | `EStatLevels` — порог иммунитета для роста |
| `m_DieOffSpeed` | Скорость убыли при сильном иммунитете |
| `m_AutoinfectCount` / `m_AutoinfectProbability` | Автозаражение |

#### AgentBase — переопределяемые

| Метод | Описание |
|-------|----------|
| `GetInvasibilityEx(PlayerBase)` | Динамическая скорость роста |
| `GetPotencyEx(PlayerBase)` | Динамический порог (напр. Influenza повышает при пневмонии) |
| `GetDieOffSpeedEx(PlayerBase)` | Динамическая убыль |
| `GetDrugResistance(EMedicalDrugsType, PlayerBase)` | Устойчивость к лекарству (0=нет, 1=полная) |
| `AutoinfectCheck(float deltaT, PlayerBase)` | Логика автозаражения |
| `CanAutoinfectPlayer(PlayerBase)` | Базовая проверка автозаражения |

#### PlayerAgentPool — ключевые методы

| Метод | Описание |
|-------|----------|
| `AddAgent(int id, float count)` | Добавить (учитывает временный иммунитет) |
| `DigestAgent(int id, float count)` | Добавить × digestibility |
| `RemoveAgent(int id)` | Обнулить |
| `ReduceAgent(int id, float percent)` | Процентное снижение |
| `GetSingleAgentCount(int id)` | Текущее кол-во |
| `GetAgents()` | Битовая маска присутствующих |
| `SetTemporaryResistance(int id, float seconds)` | Временный иммунитет |
| `AntibioticsAttack(float value)` | Атака антибиотиками |
| `DrugsAttack(EMedicalDrugsType, float value)` | Атака лекарством |

#### Рост агентов (`GrowAgents`, вызов из `ImmuneSystemTick`)

```
Для каждого агента в пуле:
  если potency <= immunityLevel И нет временного иммунитета → count += invasibility × deltaT
  иначе → count -= dieOffSpeed × deltaT
  clamp [0, maxCount]; при 0 — удаление из пула
```

---

### Модификаторы

Базовый класс: `ModifierBase`. Менеджер: `ModifiersManager` (в `PlayerBase.m_ModifiersManager`, сервер).

#### eModifiers — 59 значений (MDF_TEMPERATURE=1 ... MDF_CHELATION)

#### ModifierBase — конфигурация (задаётся в `Init()`)

| Поле | Описание |
|------|----------|
| `m_ID` | `eModifiers` значение (>= 1) |
| `m_TickIntervalActive` | Интервал тика при активном (по умолчанию 3с) |
| `m_TickIntervalInactive` | Интервал проверки активации (по умолчанию 3с) |
| `m_IsPersistent` | Сохраняется в БД |
| `m_SyncID` | `eModifierSyncIDs` для клиентской синхронизации (макс 32) |
| `m_TickType` | Битовая маска: `TICK=1`, `ACTIVATE_CHECK=2`, `DEACTIVATE_CHECK=4` |

#### ModifierBase — переопределяемые

| Метод | Описание |
|-------|----------|
| `Init()` | Установка m_ID, интервалов, m_SyncID |
| `ActivateCondition(PlayerBase)` | Проверка каждые `m_TickIntervalInactive` — активировать? |
| `DeactivateCondition(PlayerBase)` | Проверка каждые `m_TickIntervalActive` — деактивировать? |
| `OnActivate(PlayerBase)` | При активации |
| `OnReconnect(PlayerBase)` | При загрузке из БД |
| `OnDeactivate(PlayerBase)` | При деактивации |
| `OnTick(PlayerBase, float deltaT)` | Тик при активном состоянии |

#### Тик-цикл модификатора

```
Tick(deltaT):
  Неактивен + ACTIVATE_CHECK:
    накопить время → если > m_TickIntervalInactive:
      ActivateCondition()? → ActivateRequest()
  Активен:
    накопить время → если > m_TickIntervalActive:
      DEACTIVATE_CHECK + DeactivateCondition()? → Deactivate()
      иначе → OnTick(player, deltaT)
```

#### Условия vs Болезни

**Условия** (`modifiers/conditions/`): активируются от состояния игрока (статы, внешние события). Не вызывают `IncreaseDiseaseCount()`. Примеры: `BleedingCheckMdfr`, `WetMdfr`, `FeverMdfr`, `TremorMdfr`.

**Болезни** (`modifiers/diseases/`): активируются от порога агента. Два порога — активация (выше) и деактивация (ниже, гистерезис). Вызывают `IncreaseDiseaseCount()` / `DecreaseDiseaseCount()`. Примеры: `CommonColdMdfr`, `InfluenzaMdfr`, `CholeraMdfr`.

Многостадийные: `WoundInfection` (Stage1/2), `Contamination` (Stage1/2/3), `HeavyMetal` (Phase1/2/3) — отдельные классы с разными порогами.

#### ModifiersManager API

| Метод | Описание |
|-------|----------|
| `ActivateModifier(int id, bool triggerEvent)` | Принудительная активация |
| `DeactivateModifier(int id, bool triggerEvent)` | Принудительная деактивация |
| `IsModifierActive(eModifiers id)` | Проверка |
| `SetModifierLock(int id, bool state)` | Блокировка (не деактивируется) |

---

### Симптомы

Базовый класс: `SymptomBase`. Менеджер: `SymptomManager` (в `PlayerBase.m_SymptomManager`).

#### SymptomTypes

| Тип | Описание |
|-----|----------|
| `PRIMARY (0)` | Полнотелые анимации, очередь с приоритетом, макс 5 |
| `SECONDARY (1)` | Аддитивные эффекты, параллельно, без приоритета |

#### SymptomIDs

`SYMPTOM_COUGH`, `SYMPTOM_VOMIT`, `SYMPTOM_BLINDNESS`, `SYMPTOM_BULLET_HIT`, `SYMPTOM_BLEEDING_SOURCE`, `SYMPTOM_BLOODLOSS`, `SYMPTOM_SNEEZE`, `SYMPTOM_FEVERBLUR`, `SYMPTOM_LAUGHTER`, `SYMPTOM_UNCONSCIOUS`, `SYMPTOM_FREEZE`, `SYMPTOM_FREEZE_RATTLE`, `SYMPTOM_HOT`, `SYMPTOM_PAIN_LIGHT`, `SYMPTOM_PAIN_HEAVY`, `SYMPTOM_HAND_SHIVER`, `SYMPTOM_DEAFNESS_COMPLETE`, `SYMPTOM_HMP_SEVERE`, `SYMPTOM_GASP`

#### SymptomBase — конфигурация (`OnInit()`)

| Поле | Описание |
|------|----------|
| `m_SymptomType` | PRIMARY / SECONDARY |
| `m_Priority` | Приоритет в очереди primary (выше = срочнее) |
| `m_ID` | `SymptomIDs` |
| `m_MaxCount` | Макс. одновременных экземпляров (-1 = без лимита) |
| `m_DestroyOnAnimFinish` | Автоуничтожение после анимации |
| `m_SyncToClient` | Синхронизация через RPC |
| `m_IsPersistent` | Сохранение в БД |

#### SymptomBase — переопределяемые

| Метод | Описание |
|-------|----------|
| `OnInit()` | Настройка параметров |
| `CanActivate()` | Сервер: можно ли запустить сейчас? |
| `OnGetActivatedServer/Client(PlayerBase)` | При активации |
| `OnGetDeactivatedServer/Client(PlayerBase)` | При деактивации |
| `OnUpdateServer/Client(PlayerBase, float dt)` | Каждый кадр |
| `SpawnAnimMetaObject()` | Вернуть `SmptAnimMetaFB` (fullbody) или `SmptAnimMetaADD` (additive) |
| `IsSyncToRemotes()` | Видимость для других игроков |
| `AllowInUnconscious()` | Разрешить в бессознательном |

#### Очереди SymptomManager

- **Primary**: упорядочена по приоритету, макс 5. Активен один — первый с `CanActivate()=true`. Низший удаляется при переполнении.
- **Secondary**: все работают параллельно, без ограничения.

#### SymptomManager API

| Метод | Описание |
|-------|----------|
| `QueueUpPrimarySymptom(int id)` | Добавить primary по приоритету |
| `QueueUpSecondarySymptomEx(int id)` | Добавить secondary |
| `RemoveSecondarySymptom(int id)` | Удалить первый совпавший |
| `RequestSymptomExit(int uid)` | Запросить завершение |

---

### Пример: цепочка Influenza

```
1. Холод → InfluenzaAgent.AutoinfectCheck() → AddAgent(INFLUENZA, 610)
2. GrowAgents: invasibility=0.33/с, potency=MEDIUM → рост если иммунитет ≤ MEDIUM
3. count ≥ 100 → CommonColdMdfr активируется → чихание
4. count ≥ 600 → InfluenzaMdfr активируется → кашель, diseaseCount++
5. FeverMdfr видит MDF_INFLUENZA → SYMPTOM_FEVERBLUR + SYMPTOM_HOT
6. count ≥ 1150 → PneumoniaMdfr → потеря здоровья, SYMPTOM_GASP
7. InfluenzaAgent.GetPotencyEx: при пневмонии → potency=GREAT (сложнее побороть)
8. Антибиотики → DrugsAttack → снижение count → деактивация → 300с иммунитет
```
