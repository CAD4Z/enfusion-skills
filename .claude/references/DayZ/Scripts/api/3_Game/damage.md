Damage, bleeding, hit and noise systems. Sources: `damagesystem.c`, `bleedchancedata.c`, `hitinfo.c`, `killerdata.c`, `noise.c`, `playerconstants.c`

### DamageType

```
CLOSE_COMBAT (0), FIRE_ARM (1), EXPLOSION, STUN, CUSTOM
```

### ProcessDirectDamageFlags

```
ALL_TRANSFER, NO_ATTACHMENT_TRANSFER, NO_GLOBAL_TRANSFER, NO_TRANSFER
```

### DamageSystem

Static damage-dealing class.

#### Dealing damage (proto native)

| Method | Description |
|--------|-------------|
| `CloseCombatDamage(source, target, componentIndex, ammoType, worldPos, flags)` | Melee damage by component index |
| `CloseCombatDamageName(source, target, componentName, ammoType, worldPos, flags)` | Melee damage by component name |
| `ExplosionDamage(source, directHitObject, ammoType, worldPos, damageType)` | Explosion damage |

#### Damage zones (static)

| Method | Description |
|--------|-------------|
| `GetDamageZoneMap(entity, out zoneMap)` | Map of zones → arrays of components |
| `GetDamageZoneFromComponentName(entity, component, out zone)` | Component → zone |
| `GetComponentNamesFromDamageZone(entity, zone, out components)` | Zone → components |
| `GetDamageDisplayName(entity, zone)` | Localized zone name |
| `ResetAllZones(entity)` | Reset all health zones |

### TotalDamageResult

Result of dealing damage. Passed to `EEHitBy`.

| Method | Description |
|--------|-------------|
| `GetDamage(zoneName, healthType)` | Damage by zone and type (`"Health"`, `"Blood"`, `"Shock"`) |
| `GetHighestDamage(healthType)` | Maximum damage by type |

### BleedChanceData

Static calculation of bleeding chance. Source: `bleedchancedata.c`

| Method | Description |
|--------|-------------|
| `CalculateBleedChance(damageType, bloodDamage, bleedThreshold, out chance)` | Interpolates bleed chance (0..1) based on blood damage dealt |
| `InitBleedChanceData()` | Initialize maps |
| `InitMeleeChanceMap()` | Chances from melee weapons |
| `InitInfectedChanceMap()` | Chances from infected |

### HitInfo

Projectile hit info. Proto native.

| Method | Return | Description |
|--------|--------|-------------|
| `GetSurfaceNoiseMultiplier()` | `float` | Surface noise multiplier |
| `GetAmmoType()` | `string` | Ammo type |
| `GetPosition()` | `vector` | Hit position |
| `GetSurfaceNormal()` | `vector` | Surface normal |
| `GetSurface()` | `string` | Surface material name |
| `IsWater()` | `bool` | Hit on water |

### KillerData

Killer data. Source: `killerdata.c`

| Field | Type | Description |
|-------|------|-------------|
| `m_Killer` | `EntityAI` | Killer |
| `m_MurderWeapon` | `EntityAI` | Weapon (or fists) |
| `m_KillerHiTheBrain` | `bool` | Headshot |

### NoiseSystem

Noise system for AI perception. Access: `g_Game.GetNoiseSystem()`. Proto native.

| Method | Description |
|--------|-------------|
| `AddNoise(source, params, strengthMultiplier)` | Add noise from source |
| `AddNoisePos(source, pos, params, strengthMultiplier)` | Noise at position |
| `AddNoiseTarget(pos, lifetime, params, strengthMultiplier)` | Noise target with lifetime |

### NoiseParams

| Method | Description |
|--------|-------------|
| `Load(noiseName)` | Load from config by name |
| `LoadFromPath(noisePath)` | Load by full path |

### PlayerConstants

Static player constants. Source: `playerconstants.c`

#### Movement

| Constant | Value | Description |
|----------|-------|-------------|
| `FULL_SPRINT_DELAY_DEFAULT` | `0.5` | Delay before sprint (sec) |
| `FULL_SPRINT_DELAY_FROM_CROUCH` | `1.0` | From crouch |
| `FULL_SPRINT_DELAY_FROM_PRONE` | `2.0` | From prone |

#### Head height

| Constant | Value |
|----------|-------|
| `HEAD_HEIGHT_ERECT` | `1.6` |
| `HEAD_HEIGHT_CROUCH` | `1.05` |
| `HEAD_HEIGHT_PRONE` | `0.66` |

#### Health thresholds

`SL_HEALTH_CRITICAL(15)`, `SL_HEALTH_LOW(25)`, `SL_HEALTH_NORMAL(50)`, `SL_HEALTH_HIGH(80)`

#### Blood thresholds

`SL_BLOOD_CRITICAL`, `SL_BLOOD_LOW`, `SL_BLOOD_NORMAL`, `SL_BLOOD_HIGH`

`BLOOD_THRESHOLD_FATAL = 2500`, `BLOOD_REGEN_RATE = 0.3` (units/sec), `SALINE_BLOOD_BOOST = 3` (units/sec)

#### Body temperature

`THRESHOLD_HEAT_COMFORT_PLUS_WARNING(-0.15)`, `..._CRITICAL(-0.45)`, `..._EMPTY(-0.75)` — cold

`NORMAL_TEMP(36.0..36.5)`, `HIGH_TEMP(38.5..39.0)` — body temperature

#### Metabolism

Energy/water consumption rates: `BASAL`, `WALK`, `JOG`, `SPRINT` — for each type.

`STOMACH_ENERGY_TRANSFERRED_PER_SEC = 3`, `STOMACH_WATER_TRANSFERRED_PER_SEC = 6`

#### Foot damage

`BAREFOOT_BLEED_MODIFIER = 0.1`, `SHOES_DAMAGE_PER_STEP = 0.035`

#### Hemolytic reaction

`HEMOLYTIC_BLOOD_DRAIN_RATE = 7` (units/sec), `HEMOLYTIC_RISK_THRESHOLD = 75`, `HEMOLYTIC_REACTION_THRESHOLD = 175`
