DayZCreature → DayZCreatureAI — общий pipeline для всех AI-управляемых существ (заражённые и животные). Промежуточный слой между EntityAI и конкретными типами.

### Иерархия

```
EntityAI
 └── DayZCreature                    — анимации, кости, мод-хуки
      └── DayZCreatureAI             — AI-агент, звуки, урон, события
           ├── DayZInfected          — заражённые (см. infected.md)
           └── DayZAnimal            — животные (см. animals.md)
```

Рядом — типовые классы:
```
EntityAIType → DayZCreatureAIType    — шаблон: AnimEvents из конфига
               ├── DayZInfectedType  — атаки, HitComponents заражённых
               └── DayZAnimalType    — (пуст)
```

---

### DayZCreature — анимационный фундамент

Наследует EntityAI. Все ключевые методы — **proto native**.

**Анимационный интерфейс** (`DayZCreatureAnimInterface`):
- `BindCommand(name)` — привязка команды анимграфа
- `BindVariableFloat/Int/Bool(name)` — привязка переменных анимграфа
- `BindTag(name)` / `BindEvent(name)` — теги и события

**Управление анимациями**:
- `SetAnimationInstanceByName(name, uuid, duration)` — смена набора анимаций
- `GetCurrentAnimationInstanceUUID()` — текущий UUID

**Смерть** (proto native):
- `StartDeath()` / `ResetDeath()` / `ResetDeathCooldown()`
- `IsDeathProcessed()` / `IsDeathConditionMet()`

**Мод-хуки CommandHandler** — три точки перехвата, одинаковые для всех существ:

| Хук | Момент | Возврат true |
|-----|--------|-------------|
| `ModCommandHandlerBefore(dt, cmdID, finished)` | До стандартной логики | Полный перехват |
| `ModCommandHandlerInside(dt, cmdID, finished)` | В середине | Прерывание |
| `ModCommandHandlerAfter(dt, cmdID, finished)` | После стандартной логики | Перехват пост-обработки |

---

### DayZCreatureAI — AI-слой

Добавляет к DayZCreature AI-агента и систему событий анимаций.

**AI-агент** (proto native):
- `GetAIAgent()` — получить AIAgent (связь с AIWorld)
- `InitAIAgent(group)` — ручная инициализация (для сущностей, созданных с `init_ai = false`)
- `DestroyAIAgent()` — уничтожить агента

**Зона урона** (proto native):
- `AddDamageSphere(bone, ammo, radius, duration, invertTeams)` — создать сферу урона на кости модели на время duration. `invertTeams` — наносить урон своим (`false` = враждебным)

**При смерти**: создаёт `COMP_TYPE_BODY_STAGING` для системы разделки (скиннинга).

**Cinematic Controller**: позволяет игроку управлять существом через input напрямую (override `ModCommandHandlerBefore`).

#### Система анимационных событий

Движок вызывает функции при наступлении событий в анимации. Регистрация в конструкторе через `RegisterAnimationEvent(eventName, functionName)`:

| Событие | Функция | Что происходит |
|---------|---------|---------------|
| `"Sound"` | `OnSoundEvent` | Воспроизведение звука + шум для AI |
| `"SoundVoice"` | `OnSoundVoiceEvent` | Голосовой звук + шум + аттенюация |
| `"Step"` | `OnStepEvent` | Звук шага по поверхности (только клиент) |
| `"Damage"` | `OnDamageEvent` | Создание DamageSphere |

Конфиг событий загружается через `DayZCreatureAIType` из `CfgVehicles → <класс> → AnimEvents`:

```
AnimEvents
 ├── Sounds    → AnimSoundEvent      (ID, SoundBuilder, NoiseParams)
 ├── SoundVoice → AnimSoundVoiceEvent (ID, SoundBuilder, NoiseParams)
 ├── Steps     → AnimStepEvent       (ID, SurfaceLookup, NoiseParams)
 └── Damages   → AnimDamageEvent     (ID → CfgDamages: bone, ammo, radius, duration)
```

Каждый звуковой/голосовой ивент может нести `NoiseParams` — на сервере автоматически генерирует шум через `NoiseSystem` с учётом погоды.

Аттенюация: если существо и игрок находятся по разные стороны стены здания (или игрок в машине), звук переключается на `WaveKind.WAVEATTALWAYS` (приглушённый).

---

### DayZCreatureAIInputController — управление от AI

**Полностью proto native**. Это интерфейс между native AI-мозгом и скриптовой логикой. AI (C++) управляет существом, скрипт может перехватить через Override-методы.

| Параметр | Override | Get |
|----------|---------|-----|
| Скорость движения | `OverrideMovementSpeed(state, speed)` | `GetMovementSpeed()` |
| Скорость поворота | `OverrideTurnSpeed(state, speed)` | `GetTurnSpeed()` |
| Направление | `OverrideHeading(state, heading)` | `GetHeading()` |
| Прыжок | `OverrideJump(state, type, height)` | `IsJump()`, `GetJumpType()`, `GetJumpHeight()` |
| Взгляд | `OverrideLookAt(state, direction)` | `IsLookAtEnabled()`, `GetLookAtDirectionWS()` |
| Уровень тревоги | `OverrideAlertLevel(state, alerted, level, inLevel)` | `GetAlertLevel()`, `IsAlerted()` |
| Слот поведения | `OverrideBehaviourSlot(state, slot)` | `GetBehaviourSlot()` |

Паттерн Override: `state=true` — скрипт берёт контроль, `state=false` — возврат управления AI.

---

### CommandHandler — центральный цикл

Каждый тик движок вызывает `CommandHandler(dt, currentCommandID, currentCommandFinished)`. Это **главная точка принятия решений** для существа.

Общая структура (одинакова для животных и заражённых):

```
1. ModCommandHandlerBefore() → return true = мод перехватил
2. HandleDeath() → если мёртв, остаться в Death
3. Если currentCommandFinished → StartCommand_Move() (возврат к движению)
4. ModCommandHandlerInside()
5. HandleDamageHit() → обработка полученного урона
6. Специфичная логика (атаки, vault, mind state...)
7. ModCommandHandlerAfter()
```

**Команды** — proto native состояния, управляющие анимацией и физикой:

Животные (`DayZAnimalConstants`):
`COMMANDID_MOVE`, `COMMANDID_JUMP`, `COMMANDID_DEATH`, `COMMANDID_HIT`, `COMMANDID_ATTACK`, `COMMANDID_SCRIPT`

Заражённые (`DayZInfectedConstants`):
`COMMANDID_MOVE`, `COMMANDID_VAULT`, `COMMANDID_DEATH`, `COMMANDID_HIT`, `COMMANDID_ATTACK`, `COMMANDID_CRAWL`, `COMMANDID_SCRIPT`

`StartCommand_*()` — переключение на новую команду (proto native). Текущая команда прерывается, новая запускается. При завершении команды `currentCommandFinished = true`, и CommandHandler решает что делать дальше (обычно `StartCommand_Move()`).

---

### DayZAnimalCommandScript — скриптовые команды

Полностью скриптовое поведение для случаев, когда native-команд недостаточно. **Non-managed** — после передачи в CommandHandler управляется C++.

Два этапа per-tick:
1. **PrePhys** — задать трансформацию до физики (`PrePhys_SetTranslation/Rotation` в локальном пространстве)
2. **PostPhys** — скорректировать после физики (`PostPhys_SetPosition/Rotation` в мировом пространстве)

`SetFlagFinished(true)` — завершить скриптовую команду, CommandHandler получит `currentCommandFinished = true`.

---

### Обработка урона

Общий паттерн для всех существ:

1. `EEHitBy()` — получение урона от движка
2. Подсчёт `type` и `direction` удара (`ComputeDamageHitParams`)
3. `QueueDamageHit(type, direction)` — сохранить для следующего тика
4. В `CommandHandler` → `HandleDamageHit()` → `StartCommand_Hit(type, direction)`

Направление удара: угол между направлением существа и вектором к источнику урона → front (±20°) / left / right. Дополнительный offset по зоне попадания (голова, грудь, другое).
