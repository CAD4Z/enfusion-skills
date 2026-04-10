Система урона, кровотечений, попаданий и шума. Источники: `damagesystem.c`, `bleedchancedata.c`, `hitinfo.c`, `killerdata.c`, `noise.c`, `playerconstants.c`

### DamageType

```
CLOSE_COMBAT (0), FIRE_ARM (1), EXPLOSION, STUN, CUSTOM
```

### ProcessDirectDamageFlags

```
ALL_TRANSFER, NO_ATTACHMENT_TRANSFER, NO_GLOBAL_TRANSFER, NO_TRANSFER
```

### DamageSystem

Статический класс нанесения урона.

#### Нанесение (proto native)

| Метод | Описание |
|-------|----------|
| `CloseCombatDamage(source, target, componentIndex, ammoType, worldPos, flags)` | Ближний бой по индексу компонента |
| `CloseCombatDamageName(source, target, componentName, ammoType, worldPos, flags)` | Ближний бой по имени компонента |
| `ExplosionDamage(source, directHitObject, ammoType, worldPos, damageType)` | Взрывной урон |

#### Зоны урона (static)

| Метод | Описание |
|-------|----------|
| `GetDamageZoneMap(entity, out zoneMap)` | Карта зон → массивы компонентов |
| `GetDamageZoneFromComponentName(entity, component, out zone)` | Компонент → зона |
| `GetComponentNamesFromDamageZone(entity, zone, out components)` | Зона → компоненты |
| `GetDamageDisplayName(entity, zone)` | Локализованное имя зоны |
| `ResetAllZones(entity)` | Сбросить все зоны здоровья |

### TotalDamageResult

Результат нанесения урона. Передаётся в `EEHitBy`.

| Метод | Описание |
|-------|----------|
| `GetDamage(zoneName, healthType)` | Урон по зоне и типу (`"Health"`, `"Blood"`, `"Shock"`) |
| `GetHighestDamage(healthType)` | Максимальный урон по типу |

### BleedChanceData

Статический расчёт вероятности кровотечения. Источник: `bleedchancedata.c`

| Метод | Описание |
|-------|----------|
| `CalculateBleedChance(damageType, bloodDamage, bleedThreshold, out chance)` | Интерполирует шанс кровотечения (0..1) по нанесённому урону крови |
| `InitBleedChanceData()` | Инициализация карт |
| `InitMeleeChanceMap()` | Шансы от оружия ближнего боя |
| `InitInfectedChanceMap()` | Шансы от заражённых |

### HitInfo

Информация о попадании снаряда. Proto native.

| Метод | Возврат | Описание |
|-------|---------|----------|
| `GetSurfaceNoiseMultiplier()` | `float` | Множитель шума поверхности |
| `GetAmmoType()` | `string` | Тип боеприпаса |
| `GetPosition()` | `vector` | Точка попадания |
| `GetSurfaceNormal()` | `vector` | Нормаль поверхности |
| `GetSurface()` | `string` | Имя материала поверхности |
| `IsWater()` | `bool` | Попадание в воду |

### KillerData

Данные об убийце. Источник: `killerdata.c`

| Поле | Тип | Описание |
|------|-----|----------|
| `m_Killer` | `EntityAI` | Убийца |
| `m_MurderWeapon` | `EntityAI` | Оружие (или кулаки) |
| `m_KillerHiTheBrain` | `bool` | Выстрел в голову |

### NoiseSystem

Система шума для ИИ-восприятия. Доступ: `g_Game.GetNoiseSystem()`. Proto native.

| Метод | Описание |
|-------|----------|
| `AddNoise(source, params, strengthMultiplier)` | Добавить шум от источника |
| `AddNoisePos(source, pos, params, strengthMultiplier)` | Шум на позиции |
| `AddNoiseTarget(pos, lifetime, params, strengthMultiplier)` | Шум-цель с временем жизни |

### NoiseParams

| Метод | Описание |
|-------|----------|
| `Load(noiseName)` | Загрузить из конфига по имени |
| `LoadFromPath(noisePath)` | Загрузить по полному пути |

### PlayerConstants

Статические константы игрока. Источник: `playerconstants.c`

#### Движение

| Константа | Значение | Описание |
|-----------|----------|----------|
| `FULL_SPRINT_DELAY_DEFAULT` | `0.5` | Задержка перед спринтом (сек) |
| `FULL_SPRINT_DELAY_FROM_CROUCH` | `1.0` | Из приседа |
| `FULL_SPRINT_DELAY_FROM_PRONE` | `2.0` | Из лежачего |

#### Высота головы

| Константа | Значение |
|-----------|----------|
| `HEAD_HEIGHT_ERECT` | `1.6` |
| `HEAD_HEIGHT_CROUCH` | `1.05` |
| `HEAD_HEIGHT_PRONE` | `0.66` |

#### Пороги здоровья

`SL_HEALTH_CRITICAL(15)`, `SL_HEALTH_LOW(25)`, `SL_HEALTH_NORMAL(50)`, `SL_HEALTH_HIGH(80)`

#### Пороги крови

`SL_BLOOD_CRITICAL`, `SL_BLOOD_LOW`, `SL_BLOOD_NORMAL`, `SL_BLOOD_HIGH`

`BLOOD_THRESHOLD_FATAL = 2500`, `BLOOD_REGEN_RATE = 0.3` (ед/сек), `SALINE_BLOOD_BOOST = 3` (ед/сек)

#### Температура тела

`THRESHOLD_HEAT_COMFORT_PLUS_WARNING(-0.15)`, `..._CRITICAL(-0.45)`, `..._EMPTY(-0.75)` — холод

`NORMAL_TEMP(36.0..36.5)`, `HIGH_TEMP(38.5..39.0)` — температура тела

#### Метаболизм

Скорости расхода энергии/воды: `BASAL`, `WALK`, `JOG`, `SPRINT` — для каждого типа.

`STOMACH_ENERGY_TRANSFERRED_PER_SEC = 3`, `STOMACH_WATER_TRANSFERRED_PER_SEC = 6`

#### Урон ногам

`BAREFOOT_BLEED_MODIFIER = 0.1`, `SHOES_DAMAGE_PER_STEP = 0.035`

#### Гемолитическая реакция

`HEMOLYTIC_BLOOD_DRAIN_RATE = 7` (ед/сек), `HEMOLYTIC_RISK_THRESHOLD = 75`, `HEMOLYTIC_REACTION_THRESHOLD = 175`
