Игрок: Man (3_Game) → Human (3_Game) → DayZPlayer (3_Game) → DayZPlayerImplement (4_World) → PlayerBase (4_World). Самая глубокая иерархия — игрок управляется вводом, а не AI, но взаимодействует с AI-системой как цель.

### Иерархия

```
EntityAI
 └── Man (3_Game)                     — идентичность, инвентарь, речь, TOUCHTRIGGERS
      └── Human (3_Game)              — физика, трансформы, команды, InputController
           └── DayZPlayer (3_Game)    — HeadingModel, AimingModel, CommandHandler, камера, детерминированный random
                └── DayZPlayerImplement (4_World) — реализация CommandHandler, урон, оружие, ближний бой
                     └── PlayerBase (4_World)     — геймплейная обёртка: бессознательность, стамина, ранения, quickbar
```

Рядом:
```
ManType → DayZPlayerType             — HitComponents, NoiseParams, шаблоны шума
HumanInputController                 — ввод игрока (proto native), полный аналог DayZCreatureAIInputController
AITargetCallbacksPlayer              — видимость для AI (скорость + стойка → модификатор)
DayZPlayerMeleeFightLogic_LightHeavy — боевая логика ближнего боя
```

---

### Ключевое отличие от существ

У существ (infected/animals) **native AI** управляет через `InputController.GetMindState()`, а скрипт реагирует. У игрока всё наоборот:

- **Ввод** — от HumanInputController (клавиатура/геймпад → proto native)
- **Решения** — скриптовые (CommandHandler, FightLogic, ActionManager)
- **AI-роль** — только как **цель** (AITargetCallbacksPlayer, HitComponentsForAI, NoiseSystem)

---

### Man — базовый слой

Наследует EntityAI. Добавляет:

- `GetIdentity()` — PlayerIdentity (proto native)
- `GetEntityInHands()` / `GetHumanInventory()` — инвентарь (proto native)
- `IsSoundInsideBuilding()` / `IsCameraInsideVehicle()` — аттенюация звука
- `SetFaceTexture()` / `SetFaceMaterial()` — кастомизация модели
- `SetSpeechRestricted()` — ограничение речи

`Man` устанавливает `EntityFlags.TOUCHTRIGGERS` — реагирует на триггеры в мире.

---

### Human — физика и команды

**Физика** (proto native):
- `PhysicsGetPositionWS/LS()` — позиция в мировом/локальном пространстве
- `PhysicsIsFalling(validate)` — проверка падения
- `PhysicsGetVelocity(out velocity)` — скорость контроллера
- `PhysicsSetSolid(solid)` / `PhysicsSetRagdoll(enable)` — коллизии и рэгдолл
- `CheckFreeSpace(dir, dist)` — проверка свободного пространства для коллайдера

**Выравнивание** (proto native):
- `AlignPositionWS(pos)` / `AlignDirectionWS(dir)` — плавное перемещение/поворот
- `AlignTranslationWS/LS(translation)` — смещение в мировом/локальном пространстве

**Связывание** (proto native):
- `LinkToLocalSpaceOf(child, matrix)` / `UnlinkFromLocalSpace()` — привязка к другой сущности (транспорт)

#### Команды (proto native)

14 основных команд + 4 модификатора. Каждая команда — native-состояние, управляющее анимацией и физикой:

| Команда | COMMANDID | Назначение |
|---------|-----------|-----------|
| `StartCommand_Move()` | `COMMANDID_MOVE` | Движение (idle/walk/run/sprint) |
| `StartCommand_Melee2(target, hitType, combo)` | `COMMANDID_MELEE2` | Ближний бой |
| `StartCommand_Fall(yVelocity)` | `COMMANDID_FALL` | Падение (≤0) / Прыжок (>0) |
| `StartCommand_Ladder(building, index)` | `COMMANDID_LADDER` | Лестница |
| `StartCommand_Swim()` | `COMMANDID_SWIM` | Плавание |
| `StartCommand_Vehicle(transport, pos, seat)` | `COMMANDID_VEHICLE` | Транспорт |
| `StartCommand_Climb(result, type)` | `COMMANDID_CLIMB` | Перелезание |
| `StartCommand_Death(type, dir, callback)` | `COMMANDID_DEATH` | Смерть |
| `StartCommand_Unconscious(type)` | `COMMANDID_UNCONSCIOUS` | Бессознательность |
| `StartCommand_Damage(type, dir)` | `COMMANDID_DAMAGE` | Полнотелый урон (stagger) |
| `StartCommand_Action(actionID, callback, stanceMask)` | `COMMANDID_ACTION` | Действие (полнотелое) |
| `StartCommand_Script(cmd)` | `COMMANDID_SCRIPT` | Скриптовая команда |

**Модификаторы** — аддитивные поведения поверх основной команды:

| Модификатор | Назначение |
|-------------|-----------|
| `GetCommandModifier_Additives()` | Голова, разговор (always-on) |
| `GetCommandModifier_Weapons()` | Оружие: действия, анимации (always-on) |
| `AddCommandModifier_Action(actionID, callback)` | Аддитивное действие |
| `AddCommandModifier_Damage(type, dir)` | Лёгкий урон (аддитивный) |

**Events** — коллбеки начала/конца каждой команды:
`OnCommandMoveStart/Finish()`, `OnCommandDeathStart/Finish()`, `OnCommandVehicleStart/Finish()`, `OnStanceChange(prev, new)` и т.д.

---

### HumanInputController — ввод игрока

**Полностью proto native**. Аналог `DayZCreatureAIInputController`, но источник — ввод игрока, не AI-мозг.

**Движение**:
- `GetMovement(out speed, out localDir)` — скорость 0..3 (idle/walk/run/sprint), направление
- `GetHeadingAngle()` — направление камеры в радианах

**Прицеливание**:
- `GetAimChange()` / `GetAimDelta(dt)` — изменение прицела per-tick (радианы)
- `IsWeaponRaised()` / `WeaponADS()` — поднято ли оружие, ADS-режим

**Действия**:
- `IsUseItemButton()` / `IsAttackButton()` — действие / стрельба (по тикам)
- `IsSingleUse()` / `IsContinuousUse()` — одиночное / длительное действие (не raised)
- `IsJumpClimb()` — прыжок/перелезание
- `IsStanceChange()` — смена стойки

**Ближний бой**:
- `IsMeleeEvade()` — уклонение (SHIFT)
- `IsMeleeFastAttackModifier()` — тяжёлая атака (SHIFT зажат)
- `IsMeleeLREvade()` — лево/право уклонение (0/1/2)
- `IsMeleeWeaponAttack()` — удар оружием

**Override-методы** — скрипт может перехватить ввод:

| Override | Что перехватывает |
|----------|------------------|
| `OverrideMovementSpeed(type, value)` | Скорость |
| `OverrideMovementAngle(type, value)` | Направление |
| `OverrideAimChangeX/Y(type, value)` | Прицеливание |
| `OverrideMeleeEvade(type, value)` | Уклонение |
| `OverrideRaise(type, value)` | Поднятие оружия |
| `OverrideFreeLook(type, value)` | Свободный обзор |

`HumanInputControllerOverrideType`: `DISABLED` — вернуть контроль, `ENABLED` — постоянный перехват, `ONE_FRAME` — на один тик.

---

### DayZPlayer — логика и камера

**HeadingModel** (per tick):
- `SDayZPlayerHeadingModel` — входы: `m_iCamMode`, `m_iCurrentCommandID`. Выходы: `m_fOrientationAngle` (куда смотрит модель), `m_fHeadingAngle` (куда целится)
- Скрипт переопределяет `HeadingModel()` для модификации

**AimingModel** (per tick):
- `SDayZPlayerAimingModel` — входы: камера, текущие углы. Выходы: offset'ы камеры, рук, mouse shift
- Позволяет разделить камеру и модель (свободный обзор, отдача)

**Камера**:
- `CameraHandler(cameraMode)` — возвращает тип камеры по режиму
- `GetCurrentCamera()` / `GetCurrentCameraTransform()` — текущая камера (proto native)

**Анимационный граф** (только из CommandHandler):
- `AnimCallCommand(cmd, paramInt, paramFloat)` — вызов команды анимграфа
- `AnimSetFloat/Int/Bool(var, value)` — установка переменных

**Детерминированный random** — `Random()`, `RandomRange(range)`, `Random01()` — только из CommandHandler. Синхронизирован между клиентом и сервером для prediction.

**Melee** (proto native):
- `ProcessMeleeHit(weapon, mode, target, component, hitPos)` — обработка попадания ближнего боя
- `GetMeleeCombatData()` — данные текущего ближнего боя

---

### CommandHandler — DayZPlayerImplement

Полный цикл per-tick (упрощённо):

```
CommandHandler(dt, currentCommandID, currentCommandFinished)
 1. EvaluateDamageHit()                → подготовка hit-анимации (до Jump)
 2. super.CommandHandler()             → DayZPlayer (пустой, для переопределения)
 3. ModCommandHandlerBefore()          → мод-перехват
 4. HandleADS()                        → логика прицеливания
 5. HandleWeapons()                    → стрельба, перезарядка
 6. HandleView()                       → переключение камер
 7. HandleDeath()                      → StartCommand_Death
 8. Vehicle: swim check при выходе     → StartCommand_Swim
 9. Если currentCommandFinished:
    - Из Unconscious в Vehicle         → StartCommand_Vehicle
    - PhysicsIsFalling                 → StartCommand_Fall
    - Was swimming                     → StartCommand_Swim
    - Default                          → StartCommand_Move
10. ModCommandHandlerInside()
11. Vehicle gear change                → AddCommandModifier_Action
12. Swimming handling                  → CheckSwimmingStart
13. Ladder / Climb                     → специфичная логика
14. Fall handling                      → FallDamage + noise при приземлении
15. ProcessJumpOrClimb()               → прыжок / перелезание
16. VoN noise                          → AddNoise по voice level
17. HandleDamageHit()                  → StartCommand_Damage / AddCommandModifier_Damage
18. Unconsciousness                    → StartCommand_Unconscious / WakeUp
19. QuickBar                           → OnQuickBarSingleUse / ContinuousUse
20. Melee (FightLogic)                 → HandleFightLogic
21. ModCommandHandlerAfter()
```

Затем PlayerBase добавляет:
- Broken legs, hold breath, weapon/emote/stamina/injury/shock managers update
- Map handling, drowning, stamina sprint limits

---

### Система урона (EEHitBy)

При попадании в игрока:

1. **Shock tracking**: запоминает `m_LastShockHitTime`, `m_UnconRefillModifier` из конфига ammo
2. **Специальные боеприпасы**: FlashGrenade → полное истощение стамины
3. **Кровотечение**: `BleedingManagerServer.ProcessHit()` — отдельная система от существ
4. **Shock → Health**: если `transferShockToDamage = 1` → конверсия + урон по зоне
5. **Сломанные ноги**: здоровье ноги/стопы ≤1 → активация модификатора `MDF_BROKEN_LEGS`
6. **Спецснаряд** (`Bullet_CupidsBolt`): полное восстановление всех зон, сброс модификаторов

#### Hit-анимация (EvaluateDamageHitAnimation)

Логика отличается от существ — зависит от типа урона:

| Тип урона | Fullbody условие |
|-----------|-----------------|
| CLOSE_COMBAT | `hitAnimation = 1` в конфиге ammo + не блокирует. От infected — только light |
| FIRE_ARM | `impactBehaviour = 1` + (fireDmg > 80 или shockDmg > 40) + Torso/Head |
| EXPLOSION | Нет fullbody |

**Throttling**: минимум `HIT_INTERVAL_MIN` (0.3с) между полнотелыми hit-анимациями.

**Fullbody vs Additive**: fullbody → `StartCommand_Damage()` (прерывает текущую команду), additive → `AddCommandModifier_Damage()` (поверх текущей команды).

---

### Ближний бой (MeleeFightLogic)

`DayZPlayerMeleeFightLogic_LightHeavy` — вся логика в скрипте:

**Типы атак** (`EMeleeHitType`):
- `LIGHT` / `HEAVY` — обычные удары (SHIFT = Heavy)
- `WPN_HIT` / `WPN_STAB` / `WPN_HIT_BUTTSTOCK` — удары оружием (штык / приклад)
- Sprint attack — только на полном спринте (>0.5с в спринте, скорость >2.99)

**Инициация атаки** зависит от стойки:
- `STANCEIDX_RAISEDERECT` → обычный удар (light/heavy) + финишеры
- `STANCEIDX_RAISEDPRONE` → пинок лёжа
- `STANCEIDX_ERECT` + sprint → sprint attack

**Combo**: в `COMMANDID_MELEE2` если `IsInComboRange()` → продолжение серии

**Блокировка и уклонение** (только `STANCEIDX_RAISEDERECT`):
- Уклонение: `IsMeleeLREvade()` → `StartMeleeEvadeA(±90°)`, тратит стамину
- Блок: `IsInBlock()` → уменьшает/обнуляет входящий урон от infected

---

### AI-взаимодействие — игрок как цель

#### HitComponents

Определены в `DayZPlayerType`:

| Зона | Вес | Вероятность |
|------|-----|------------|
| dmgZone_leftArm | 50 | ~20.4% |
| dmgZone_torso | 65 | ~26.5% |
| dmgZone_rightArm | 50 | ~20.4% |
| dmgZone_leftLeg | 40 | ~16.3% |
| dmgZone_rightLeg | 40 | ~16.3% |

Default: `dmgZone_torso`. Head закомментирован (`// TMP comment out`). Finisher-зоны: `Head`.

#### AITargetCallbacksPlayer — видимость

Определяет насколько хорошо AI видит игрока:

**GetVisionPointPositionWS** — точка, которую AI пытается увидеть:
- Infected с `MINDSTATE_ALERTED+` → голова игрока
- Иначе → грудь (Spine3) или fallback `pos + "0 1 0"`

**GetMaxVisionRangeModifier** — модификатор дальности обнаружения:
- Формула: `(speedCoef + stanceCoef) / 2`
- Скорость: `IDLE` / `WALK` / `RUN` (коэффициенты из PlayerConstants)
- Стойка: `STANDING` / `CROUCH` / `PRONE`
- Crouch+run → WALK (для видимости), Prone+любое → WALK
- Стойка снижает эффективную скорость для расчёта видимости

#### Шум (NoiseSystem)

Игрок генерирует шум в нескольких ситуациях:

| Источник | NoiseParams | Множитель |
|----------|-------------|-----------|
| Шаги | Stand/Crouch/Prone | `GetNoiseMultiplier(player) * weatherReduction` |
| Приземление (>0.5м) | LandLight / LandHeavy | `weatherReduction` |
| Голосовой чат | Whisper/Talk/Shout | `weatherReduction` (каждую 1с) |
| Звуковые события | AnimEvent.NoiseParams | `weatherReduction` |

`NoiseAIEvaluate.GetNoiseMultiplier(player)` — учитывает скорость, обувь, поверхность (подробнее в `@.claude/references/DayZ/Scripts/AI/infrastructure.md`).

---

### Бессознательность

Управляется через `m_ShouldBeUnconscious` (сервер устанавливает через SyncJuncture):

**Вход**: `StartCommand_Unconscious(0)` — когда `m_ShouldBeUnconscious = true` и текущая команда не Death/Fall/vehicle transition.

**В состоянии**: `OnUnconsciousUpdate(dt, lastCommandBefore)` — может начать плавать если в воде.

**Выход**: `WakeUp(wakeUpStance)` — минимум через 2с (`m_UnconsciousTime > 2`). Стойка: prone, кроме плавания и транспорта.

**Из транспорта**: запоминает `m_TransportCache` → при выходе из бессознательности возвращается в транспорт.

---

### Смерть

`HandleDeath()` в DayZPlayerImplement:

1. Определение типа анимации: `DEATH_DEFAULT` → `GetTypeOfDeath(commandID)`, или `DEATH_FAST` если ammo имеет `doPhxImpulse`
2. Если в транспорте: `CrewDeath(seat)` или `CrewGetOut(seat)`, `MarkCrewMemberDead(seat)`
3. Если водитель: `Possess(this)` — возвращает контроль мёртвому игроку чтобы другие могли использовать транспорт
4. `StartCommand_Death(type, dir, callback)` — с учётом `keepInLocalSpace` для транспорта
