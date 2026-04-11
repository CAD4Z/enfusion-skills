Заражённые (зомби): DayZInfected (3_Game) → ZombieBase (4_World). Наиболее скриптовая ветка AI — большая часть боевой логики и поведения доступна в скриптах.

### Иерархия

```
DayZCreatureAI
 └── DayZInfected (3_Game)          — proto native команды, InputController, урон
      └── ZombieBase (4_World)      — CommandHandler, боевая логика, mind states, звук
           ├── ZombieMaleBase       — мужские модели
           └── ZombieFemaleBase     — женские модели
               └── конкретные классы (ZmbM_CitizenASkinny, ZmbF_Doctor, ...)
```

Рядом:
```
DayZCreatureAIType → DayZInfectedType — таблица атак, HitComponents, выбор атаки
DayZCreatureAIInputController → DayZInfectedInputController — MindState, цель (native)
```

---

### Mind States — состояния сознания

Определяются **native AI** и читаются через `DayZInfectedInputController.GetMindState()`. Скрипт не устанавливает их напрямую — AI реагирует на шум и видимость, скрипт только читает и реагирует.

| Состояние | Значение | Поведение |
|-----------|----------|-----------|
| `MINDSTATE_CALM` | 0 | Idle, бродит. IdleState = 0 |
| `MINDSTATE_DISTURBED` | 1 | Насторожён, осматривается. IdleState = 1 |
| `MINDSTATE_ALERTED` | 2 | Тревога (звук в infrastructure.md) |
| `MINDSTATE_CHASE` | 3 | Преследование цели. IdleState = 2 |
| `MINDSTATE_FIGHT` | 4 | Ближний бой |

При смене mind state — сброс cooldown атаки и `SetSynchDirty()` для синхронизации на клиент.

---

### DayZInfectedInputController

Расширяет `DayZCreatureAIInputController` (см. creatures.md). Дополнительно:

- `GetMindState()` — текущее состояние (proto native, от AI-мозга)
- `GetTargetEntity()` — текущая цель AI (proto native)
- `IsVault()` / `GetVaultHeight()` — нужен ли vault (аналог Jump)

Всё управление существом — от native AI. Скрипт читает через Get-методы и реагирует в CommandHandler.

---

### CommandHandler — полный цикл

```
CommandHandler(dt, currentCommandID, currentCommandFinished)
 1. ModCommandHandlerBefore()        → полный перехват
 2. HandleDeath()                    → StartCommand_Death(type, direction)
 3. HandleMove() / HandleOrientation() → синхронизация скорости и yaw
 4. Если команда завершена           → StartCommand_Move() с StanceVariation
 5. ModCommandHandlerInside()
 6. HandleCrawlTransition()          → StartCommand_Crawl(type)
 7. HandleDamageHit()                → StartCommand_Hit(heavy, type, direction)
 8. HandleVault()                    → StartCommand_Vault(type)
 9. HandleMindStateChange()          → смена idle-анимации
10. FightLogic()                     → ChaseAttackLogic / FightAttackLogic
11. ModCommandHandlerAfter()
```

#### Синхронизация (HandleMove / HandleOrientation)

**Скорость** (`m_MovementSpeed`): синхронизируется при изменении >= 0.9 от последнего значения. Диапазон: -1..3.

**Ориентация** (`m_OrientationSynced`): квантизованный yaw (0–359°). Синхронизируется каждые **2 секунды** или при отклонении >30° от последнего синхронизированного значения. Минимальный порог обновления — 5°.

---

### Боевая система

#### Таблица атак (DayZInfectedType)

Атаки зарегистрированы в `DayZInfectedType.RegisterAttacks()`. Два группы:

**CHASE** — атаки на бегу (дальняя дистанция):
- Дистанция 2.4м, только center pitch, cooldown 0.3–0.4с

**FIGHT** — ближний бой (ближняя дистанция):
- Дистанция 1.4–1.7м, три pitch (up/center/down)
- Light и Heavy варианты
- Cooldown 0.1–0.6с, вероятность 0.4–0.9

Каждая атака: `{Distance, Pitch, Type, Subtype, AmmoType, IsHeavy, Cooldown, Probability}`

AmmoType берётся из конфига: `CfgVehicles → <class> → AttackActions → AttackShort/AttackLong/AttackRun → ammoType`

#### Выбор атаки (ChooseAttack)

Utility-функция: `ComputeAttackUtility(attack, distance, pitch, random)`
1. Pitch не совпадает → 0
2. Цель дальше чем дистанция атаки → 0
3. `utilityDistance = (1 - (attackDist - targetDist) / 10) * 100` — ближайшая атака приоритетнее
4. `utilityProbability = (1 - (attackProb - random)) * 10` — случайный фактор
5. Побеждает атака с максимальной суммарной utility

#### Pitch — выбор высоты атаки

`GetAttackPitch(target)`: сравнивает Y-позицию головы зомби (pos + 1.8м) с `DefaultHitPosition` цели. Разница <0.3м → center (0), зомби выше → down (-1), ниже → up (1).

#### Логика Chase vs Fight

**ChaseAttackLogic** (MINDSTATE_CHASE):
1. Получить цель из InputController
2. Пропустить если цель в машине
3. `CanAttackToPosition()` — proto native проверка достижимости
4. `ChooseAttack(CHASE, distance, pitch)`
5. `GetMeleeTarget()` — проверка конуса 20° вокруг направления зомби
6. Если цель в конусе → `StartCommand_Attack(target, type, subtype)`

**FightAttackLogic** (MINDSTATE_FIGHT):
- Аналогично, но конус шире (30°), плюс **cooldown** между атаками (`m_AttackCooldownTime`)
- Cooldown уменьшается с множителем `GameConstants.AI_ATTACKSPEED`

#### Нанесение урона

При `WasHit()` в команде атаки:
1. Проверка дистанции до цели ≤ `m_Distance²`
2. Если игрок блокирует (`IsInBlock()`) и смотрит на зомби (±`AI_MAX_BLOCKABLE_ANGLE`):
   - Heavy атака → наносится как `"MeleeZombie"` (уменьшенный урон)
   - Light атака → `"Dummy_Light"` (нулевой урон, только анимация)
3. Иначе → полный урон `m_AmmoType`

Урон применяется через `DamageSystem.CloseCombatDamageName()`, зона попадания — `GetHitComponentForAI()`.

#### HitComponents — зоны попадания зомби

Определены в `DayZInfectedType.RegisterHitComponentsForAI()` с весами:

| Зона | Вес | Вероятность |
|------|-----|------------|
| Head | 2 | ~0.7% |
| LeftArm | 50 | ~18.7% |
| Torso | 65 | ~24.3% |
| RightArm | 50 | ~18.7% |
| LeftLeg | 50 | ~18.7% |
| RightLeg | 50 | ~18.7% |

Default: `Torso`. Finisher-зоны: Head, Neck, Torso.

---

### Получение урона (EEHitBy)

При попадании в зомби:

1. **Shock → Health конверсия**: если ammo имеет `transferShockToDamage = 1`, Shock конвертируется в Health (множитель `NL_DAMAGE_CLOSECOMBAT/FIREARM_CONVERSION_INFECTED`)
2. **Спецзоны** (`HandleSpecialZoneDamage`): урон ≥74 по ногам → здоровье ноги = 0 (калечит). Торс/Голова → `m_HeavyHitOverride = true`
3. **Если мёртв** → `EvaluateDeathAnimation()`: выбор анимации смерти, физический импульс если `doPhxImpulse` в ammo. Фиксация killer data, headshot detection
4. **Если жив**: проверка перехода в ползание (нога уничтожена), иначе — оценка hit-анимации

#### Stun-система

`HandleDamageHit()` решает, будет ли зомби stunned:
- Throttling: минимум 0.3с между hit-анимациями
- Вероятность стана: `random(0–100) ≤ SHOCK_TO_STUN_MULTIPLIER(2.82) * shockDamage`
- Heavy hit или Calm/Disturbed состояние → гарантированный стан

---

### Crawl — переход в ползание

Необратимый переход при уничтожении ноги:
1. `EvaluateCrawlTransitionAnimation()` — проверяет здоровье LeftLeg/RightLeg = 0
2. Тип анимации: 0/2 = левая/правая нога, +1 если удар спереди
3. `StartCommand_Crawl(type)` → `m_IsCrawling = true`
4. После перехода зомби остаётся в `CommandMove`, но `m_IsCrawling` синхронизирован

---

### Vault

Высота определяет тип:
| Высота | Тип |
|--------|-----|
| ≤ 0.6м | 0 |
| ≤ 1.1м | 1 |
| ≤ 1.6м | 2 |
| > 1.6м | 3 |

После приземления (`WasLand()`) — 2с таймер перед завершением vault-команды.

---

### Backstab (финишер)

`SetBeingBackstabbed(backstabType)`:
1. `GetAIAgent().SetKeepInIdle(true)` — AI отключается
2. Выбор анимации: BACKSTAB / NECKSTAB / DEFAULT
3. `m_FinisherInProgress = true` → `CanBeTargetedByAI()` вернёт false для атакующего

`OnRecoverFromDeath()` — если backstab не удался:
1. `SetKeepInIdle(false)` — AI включается обратно
2. `m_FinisherInProgress = false`

---

### Звуковой автомат (клиент)

`HandleSoundEvents()` — вызывается при `OnVariablesSynchronized()`. Зависит от синхронизированного `m_MindState`:

| MindState | Звуковое событие |
|-----------|-----------------|
| CALM | `MINDSTATE_CALM_MOVE` |
| ALERTED | `MINDSTATE_ALERTED_MOVE` |
| DISTURBED | `MINDSTATE_DISTURBED_IDLE` |
| CHASE | `MINDSTATE_CHASE_MOVE` |
| FIGHT | Stop |

Голосовые анимационные события (`OnSoundVoiceEvent`) прерывают state-звук, затем он восстанавливается.
