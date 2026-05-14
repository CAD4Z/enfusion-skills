`4_World` — environment, cooking, food. Sources: `classes/environment/`, `classes/cooking/`, `classes/foodstage/`

### Environment

The `Environment` object exists per player (`PlayerBase.m_Environment`). It simulates how the surroundings affect the character.

#### What it tracks

| Variable | Description |
|-----------|----------|
| `m_Rain` | 0–1 rain intensity |
| `m_Snowfall` | 0–1 snowfall intensity |
| `m_Wind` | Wind strength |
| `m_Fog` | 0–1 fog density |
| `m_DayOrNight` | 0=day, 1=night |
| `m_EnvironmentTemperature` | Computed temperature for the player's position |
| `m_WaterLevel` | Submersion depth (0.15/0.5/1.2/1.5) |
| `m_IsUnderRoof` | Upward raycast 25m |
| `m_IsInWater` | In contact with liquid |
| `m_HeatComfort` / `m_TargetHeatComfort` | Buffered / target heat comfort |
| `m_UTSAverageTemperature` | Average of nearby UTemperatureSource entries |

#### Update(float pDelta) loop

Called every tick. Two layers:
- **Roof check** — every `ENVIRO_TICK_ROOF_RC_CHECK` seconds
- **Main tick** — every `ENVIRO_TICK_RATE` seconds:

```
1. CheckWaterContact() — m_IsInWater, m_WaterLevel
2. CollectAndSetPlayerData() — position, speed, heat
3. CollectAndSetEnvironmentData() — Weather → temperature
4. GatherTemperatureSources() → ProcessTemperatureSources() — UTS
5. ProcessItemsTemperature() — heat/cool worn items
6. DetermineHeatcomfortBehavior() → ProcessHeatComfort()
7. Every N ticks → ProcessWetness/Dryness
```

#### Temperature calculation (priority)

1. **In water** → `WorldData.GetLiquidTypeEnviroTemperature()` − contact modifier
2. **In building** → base + `m_TemperatureInsideBuildingsModifier`
3. **In vehicle** → temp + `|temp × ENVIRO_TEMPERATURE_INSIDE_VEHICLE_COEF|`
4. **Under roof** → altitude+clouds+fog + wind × `ENVIRO_TEMPERATURE_UNDERROOF_COEF`
5. **In the open** → altitude+clouds+fog+wind, surface from `CfgSurfaces`

#### Player linkage

- `m_Player.GetStatHeatComfort()` — continuously updated
- `m_Player.GetStatWet()` — 0/1 based on the max wetness of worn items
- `m_Player.SetInWater()` — from `CheckWaterContact()`
- `m_Player.SetInColdArea()` — from `SetAreaGenericColdness()`

---

### Cooking

The `Cooking` class manages cooking on equipment (pot, pan, stick).

#### CookingMethodType

| Method | Value | Condition |
|-------|----------|---------|
| `BAKING` | 1 | Lard in cargo, or dry cargo |
| `BOILING` | 2 | Liquid present (not gasoline) |
| `DRYING` | 3 | Liquid is gasoline |
| `TIME` | 4 | Time-based (smoke) |

#### Method detection (`GetCookingMethodWithTimeOverride`)

```
Container with liquid (not gasoline) → BOILING (coef 1.0)
Container with gasoline → DRYING (coef 2.0)
Lard in cargo → BAKING (coef 1.0)
Other cargo → BAKING (coef 2.0, slower without lard)
Empty → NONE
```

#### Main entry points

| Method | Description |
|-------|----------|
| `CookWithEquipment(ItemBase equip, float coef)` | Cook in a container — iterate cargo |
| `CookOnStick(Edible_Base item, float inc)` | Cook on a stick — always BAKING |
| `SmokeItem(Edible_Base item, float inc)` | Smoking — RAW→DRIED, others→BURNED |

#### Cooking process (`UpdateCookingState`)

```
1. Get the next stage: item.GetNextFoodStageType(method)
2. Read [MIN_TEMP, COOK_TIME] for the next stage
3. Heat the item toward the equipment's temperature
4. If food_temp >= food_min_temp → cooking_time += COOKING_FOOD_TIME_INC_VALUE × coef
5. If cooking_time >= food_time_to_cook → ChangeFoodStage(new_stage), reset timer
```

#### Constants

| Constant | Value |
|-----------|----------|
| `COOKING_FOOD_TIME_INC_VALUE` | 2 (time per tick) |
| `COOKING_LARD_DECREASE_COEF` | 25 (lard consumption) |
| `DEFAULT_COOKING_TEMPERATURE` | 150 |
| `LIQUID_BOILING_POINT` | 150 |
| `BURNING_WARNING_THRESHOLD` | 0.75 |

---

### FoodStage

Each `Edible_Base` owns a `FoodStage` instance.

#### FoodStageType

```
NONE=0, RAW=1, BAKED=2, BOILED=3, DRIED=4, BURNED=5, ROTTEN=6
```

#### Configuration (CfgVehicles)

```
CfgVehicles MyFood Food {
    FoodStages {
        Raw {
            visual_properties[] = {...};
            nutrition_properties[] = {fullness, energy, water, nutrition, toxicity, agents, digestibility, agentsPerDigest};
            cooking_properties[] = {min_temp, cook_time};
        }
    }
    FoodStageTransitions {
        Raw {
            Baking { transition_to = "Baked"; cooking_method = 1; }
            Boiling { transition_to = "Boiled"; cooking_method = 2; }
        }
    }
}
```

#### FoodStage API

| Method | Description |
|-------|----------|
| `GetFoodStageType()` | Current stage |
| `GetNextFoodStageType(CookingMethodType)` | Next stage for the method |
| `CanChangeToNewStage(CookingMethodType)` | Whether a transition is possible |
| `ChangeFoodStage(FoodStageType)` | Change stage → `OnFoodStageChange()` on Edible_Base |
| `GetCookingTime()` / `SetCookingTime()` | Accumulated cooking time |

Nutrients (static): `GetEnergy()`, `GetWater()`, `GetToxicity()`, `GetAgents()`, `GetFullnessIndex()`, `GetNutritionalIndex()`, `GetDigestibility()`.

`Edible_Base.OnFoodStageChange(stageOld, stageNew)` — the override point for modders.
