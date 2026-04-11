Животные: DayZAnimal (3_Game) → AnimalBase (4_World). Самая "native" ветка AI — почти всё поведение в C++, скриптовая часть тонкая.

### Иерархия

```
DayZCreatureAI
 └── DayZAnimal (3_Game)             — CommandHandler, команды, HitComponents, урон
      └── AnimalBase (4_World)       — DeathUpdate, ArrowManager, базовый класс
           ├── Animal_CanisLupus     — волк (IsDanger = true)
           ├── Animal_UrsusArctos    — медведь (IsDanger = true)
           ├── Animal_BosTaurus(F)   — корова
           ├── Animal_CervusElaphus(F) — олень
           ├── Animal_RangiferTarandus(F) — северный олень
           ├── Animal_CapraHircus(F) — коза
           ├── Animal_OvisAries(F)   — овца
           ├── Animal_SusDomesticus  — свинья
           ├── Animal_SusScrofa      — кабан
           ├── Animal_GallusGallusDomesticus(F) — курица/петух (ReplaceOnDeath)
           ├── Animal_LepusEuropaeus — заяц (ReplaceOnDeath)
           └── Animal_VulpesVulpes   — лиса (ReplaceOnDeath)
```

Суффикс `F` — женская особь (наследует мужскую без изменений или с другим DeadItem).

---

### Ключевое отличие от заражённых

У заражённых скрипт контролирует боевую логику, выбор атак, mind state реакцию. У животных **почти всё в native**:

- **Поведение** — полностью native AI. Слоты поведения (`DayZAnimalBehaviourSlot`) и действия (`DayZAnimalBehaviourAction`) — enum'ы определённые в C++
- **Решения** — native AI решает когда пугаться, охотиться, атаковать
- **Скрипт** — только CommandHandler (реактивный: смерть, урон, прыжки), HitComponents, звуки

### DayZAnimalInputController

Расширяет `DayZCreatureAIInputController`. Добавляет:

- `IsDead()` — мертво ли (proto native)
- `IsAttack()` — хочет ли AI атаковать (proto native)
- `OverrideBehaviourAction(state, action)` / `GetBehaviourAction()` — перехват действия

#### Слоты поведения (BehaviourSlot)

Определены в C++, управляются native AI:

| Слот | Контекст |
|------|---------|
| `CALM` | Спокойное состояние |
| `CALM_RESTING` | Отдых |
| `CALM_GRAZING` | Пастбище |
| `CALM_TRAVELLING` | Перемещение |
| `DRINKING` | Питьё |
| `NON_SPECIFIC_THREAT` | Неопределённая угроза |
| `SPECIFIC_THREAT` | Определённая угроза |
| `ALERTED` | Насторожённость |
| `ATTRACTED` | Привлечение |
| `PREATTRACTED` | Предварительное привлечение |
| `SCARED` | Страх (бегство) |
| `HUNTING` | Охота (хищники) |
| `EATING` | Поедание |
| `SIEGE` | Осада |
| `FIREPLACE` | Реакция на костёр |
| `ENRAGED` | Ярость |
| `ENRAGED_TARGETLOST` | Ярость, цель потеряна |
| `INTIMIDATE` | Запугивание |

#### Действия поведения (BehaviourAction)

| Действие | Описание |
|----------|---------|
| `SAFETY_INPUT` | Уход от угрозы |
| `GRAZE_WALKING/ON_SPOT_INPUT` | Пастьба |
| `RESTING_INPUT` | Отдых |
| `TRAVELING_INPUT` | Перемещение |
| `EATING/DRINKING_INPUT` | Еда/питьё |
| `CHARGING` | Атака с разбега |
| `APPROACHING/REACH_INPUT` | Приближение к цели |
| `WALKING/IDLE1-3_INPUT` | Варианты ходьбы/idle |
| `THREAT_WALK_AWAY/TO/STAY_LOOKAT/STAY` | Реакции на угрозу |

---

### CommandHandler

Значительно проще чем у заражённых — нет mind states, нет боевой логики в скрипте:

```
CommandHandler(dt, currentCommandID, currentCommandFinished)
 1. ModCommandHandlerBefore()   → перехват мода
 2. HandleDeath()               → StartCommand_Death(type, direction)
 3. Если команда завершена:
    - Если был Attack → SignalAIAttackEnded()
    - StartCommand_Move()
 4. ModCommandHandlerInside()
 5. HandleDamageHit()           → StartCommand_Hit(type, direction)
 6. Если COMMANDID_MOVE:
    - IsJump() → StartCommand_Jump()
    - IsAttack() → StartCommand_Attack() + SignalAIAttackStarted()
 7. ModCommandHandlerAfter()
```

**Сигналы атаки**: `SignalAIAttackStarted()` / `SignalAIAttackEnded()` — proto native уведомления для AI-мозга о начале/конце атаки. Позволяют native AI координировать атаки с анимациями.

### Команды (proto native)

| Команда | Назначение |
|---------|-----------|
| `StartCommand_Move()` | Обычное движение |
| `StartCommand_Jump()` | Прыжок |
| `StartCommand_Attack()` | Атака |
| `StartCommand_Death(type, dir)` | Смерть |
| `StartCommand_Hit(type, dir)` | Реакция на попадание |
| `StartCommand_Script(cmd)` | Скриптовая команда |

---

### Смерть

Два механизма в зависимости от типа животного:

**Крупные** (корова, олень, медведь, волк, коза, овца, свинья, кабан):
- Остаются в мире как труп
- `CanBeSkinned() = true` (если не заморожены) → можно разделать
- `AnimalBase.DeathUpdate()` → создаёт dead-объект, переносит свойства через `MiscGameplayFunctions.TransferItemProperties()`, устанавливает полное здоровье

**Мелкие** (курица, заяц, лиса):
- `ReplaceOnDeath() = true` → заменяются на предмет (DeadRooster, DeadChicken_*, DeadRabbit, DeadFox)
- `CanBeSkinned() = false` — разделка только через предмет
- `KeepHealthOnReplace() = false` — предмет создаётся с полным здоровьем

---

### IsDanger — хищники vs добыча

`IsDanger()` определяет роль в пищевой цепи:

| `IsDanger() = true` | `IsDanger() = false` |
|---------------------|---------------------|
| Волк (CanisLupus) | Все остальные |
| Медведь (UrsusArctos) | |

Используется ловушками (`TrapBase`) для определения звуков захвата/освобождения.

---

### HitComponents — зоны попадания по видам

Все животные переопределяют `RegisterHitComponentsForAI()`. Default: `Zone_Chest`, position: `Pelvis`.

**Хищники** (волк, медведь): низкий вес головы (2–25), высокий вес ног (70–75).

**Травоядные** (олень, коза, овца, северный олень): голова 2–4, шея 55–65, грудь 50, ноги 70.

**Домашний скот** (корова, свинья, кабан): живот 15–25, шея 55–65, грудь 50, ноги 70.

**Мелкие** (курица, заяц, лиса): голова 1–20, грудь/спина 70, ноги 5.

---

### Обработка урона

Общий pipeline из `DayZAnimal.EEHitBy()`:

1. **Shock → Health**: если `transferShockToDamage = 1` → конверсия с множителем `NL_DAMAGE_CLOSECOMBAT/FIREARM_CONVERSION_ANIMALS`
2. **Кровотечение**: `ComponentAnimalBleeding.CreateWound()` — отдельный компонент для животных
3. **Hit-анимация**: `ComputeDamageHitParams()` → `QueueDamageHit(type, direction)`

Расчёт направления: угол между направлением животного и вектором к источнику → front (±20°) / left / right. Дополнительный offset по зоне: Head (+4), грудь/шея (+8), остальное (+12).

---

### Звуки

Система анимационных событий наследуется от `DayZCreatureAI` (см. creatures.md). Конфиг из `CfgVehicles → AnimEvents`.

**Ловушки**: каждый вид определяет `CaptureSound()` / `ReleaseSound()` — звуки при попадании в ловушку и освобождении.

---

### Cinematic Controller

Наследуется от `DayZCreatureAI`. Позволяет игроку управлять животным через Override-методы InputController. Через `ModCommandHandlerBefore()` перехватывает ввод игрока и транслирует в движение, повороты, слоты поведения. При низкой скорости (<0.5) автоматически повышает alert level для перехода к более активным анимациям.
