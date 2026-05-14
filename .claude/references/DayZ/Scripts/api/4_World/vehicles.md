`4_World` — vehicles. CarScript (cars), BoatScript (boats). Sources: `entities/vehicles/`

### CarScript

Hierarchy: `Car` (C++) → `CarScript`. All cars inherit from `CarScript`.

#### State (key)

| Category | Variables |
|-----------|-----------|
| Fluids | `m_FuelAmmount`, `m_CoolantAmmount`, `m_OilAmmount`, `m_BrakeAmmount` |
| Component health | `m_EngineHealth`, `m_RadiatorHealth`, `m_FuelTankHealth`, `m_BatteryHealth`, `m_PlugHealth` (float, -1 = absent) |
| Physics | `m_MomentumPrevTick`, `m_VelocityPrevTick` |
| Damage | `m_dmgContactCoef = 0.058` — impulse→damage multiplier |

#### Simulation loop (`EOnPostSimulate`, every physics tick)

Server, every `CARS_FLUIDS_TICK`:
1. `CarPartsHealthCheck()` — refresh component health
2. Engine-stop checks: ruined, no fuel, health ≤ 0
3. `CheckVitalItem()` — spark/glow plug
4. Leaks while engine runs:
   - Radiator health < 0.5 → coolant leak
   - Tank < DAMAGED → fuel leak
   - Engine < DAMAGED → brake/oil leak
5. RPM ≥ Redline → random engine damage
6. Coolant < 0.5 → engine damage
7. Flooding: engine position underwater > `DROWN_ENGINE_THRESHOLD` → `DROWN_ENGINE_DAMAGE × dt`

#### Collision system

`OnContact(zoneName, localPos, other, Contact)` → writes to `m_ContactCache` (first contact per zone per frame).

`CheckContactCache()` (from EOnPostSimulate):
```
dmg = |impulse × m_dmgContactCoef|
crewDmgBase = |(impulse / mass) × 1000 × m_dmgContactCoef|

dmg < CARS_CONTACT_DMG_MIN → skip
dmg < CARS_CONTACT_DMG_THRESHOLD → light hit, NO_TRANSFER
dmg >= threshold → heavy hit, DamageCrew()
```

`DamageCrew(float dmg)`:
- `dmg > CARS_CONTACT_DMG_KILLCREW` → instant death
- Else: interpolated shock (50–150) and HP damage (2–100)

`m_dmgContactCoef` — override in the subclass constructor to tune sensitivity.

#### Engine start

`CheckOperationalRequirements()` → `ECarOperationalState` (bitmask):
- `RUINED` — engine/vehicle ruined
- `NO_FUEL` — out of fuel
- `NO_BATTERY` — missing/broken/dead battery
- `NO_IGNITER` — no spark plug

#### Overridable components

| Method | Description | Default |
|-------|----------|-------------|
| `IsVitalCarBattery()` | Battery required | `true` |
| `IsVitalSparkPlug()` | Spark plug required | `true` |
| `IsVitalGlowPlug()` | Glow plug required | `false` |
| `IsVitalRadiator()` | Radiator required | `true` |
| `IsVitalFuelTank()` | Fuel tank required | `true` |
| `GetBatteryConsumption()` | Battery drain per start | 15 |

#### Engine callbacks

| Method | Description |
|-------|----------|
| `OnBeforeEngineStart()` | return false = block start |
| `OnEngineStart()` | Battery drain, lights, sound |
| `OnEngineStop()` | Battery update, lights, sound |
| `OnIgnition()` | Key turn — error sounds on faults |
| `OnDriverExit(Human)` | Stop engine if not in neutral |
| `OnGearChanged(int new, int old)` | Gear change |
| `OnFluidChanged(CarFluid, float new, float old)` | Fluid change |
| `OnBrakesPressed/Released()` | Brakes |

#### Attachments

`EEItemAttached/Detached` handles: `CarBattery`, `SparkPlug`, `GlowPlug`, `CarRadiator`, reflectors. Removing the radiator → leak. Removing the battery/plug → engine stop.

#### Crew

| Method | Description |
|-------|----------|
| `MarkCrewMemberUnconscious(int idx)` | Stop if driver |
| `MarkCrewMemberDead(int idx)` | Stop if driver |
| `CanReceiveAttachment(EntityAI, int)` | Block wheels while moving |
| `CanReleaseAttachment(EntityAI)` | Block while engine running + moving |
| `OnVehicleJumpOutServer(...)` | Damage when jumping out at speed |
| `DetectFlipped(VehicleFlippedContext)` | Flip detection |

#### Lights

| Method | Description |
|-------|----------|
| `CreateFrontLight()` | Override → custom headlight class |
| `CreateRearLight()` | Override → custom taillight class |
| `UpdateLights(int gear)` | Refresh state |
| `OnBeforeLightOn()` | Battery check |
| `ToggleHeadlights()` | Toggle headlights |

#### Sound

`float OnSound(CarSoundCtrl ctrl, float oldValue)` — override to tweak sound controllers.

---

### BoatScript

Hierarchy: `Boat` (C++) → `BoatScript`.

#### Differences from CarScript

- Fuel only (no coolant, oil, brakes)
- `EBoatOperationalState`: `OK`, `RUINED`, `NO_FUEL`, `NO_IGNITER`
- No battery check in `OnBeforeEngineStart()`
- Decay system: `DecayHealthTick()` every 10s — damage `0.017` if no player within 300m or territory flag within 100m
- Splash system: tracks airtime (`m_SplashIncoming`) → sound on water contact
- 4 water effects: front, rear, left/right side
- Engine sound fade-in/fade-out

`GetVehicleType()` → `"VehicleTypeBoat"` (CarScript → `"VehicleTypeCar"`).

#### Overridable

| Method | Description |
|-------|----------|
| `GetAnimInstance()` | Animation variant |
| `GetTransportCameraDistance()` | 3rd-person camera distance |
| `GetTransportCameraOffset()` | Camera offset |
| `CrewCanGetThrough(int posIdx)` | Seat access |
| `CanReachSeatFromSeat(int, int)` | Seat-to-seat transfer |
