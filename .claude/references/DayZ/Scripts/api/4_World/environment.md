`4_World` — окружение, готовка, еда. Источники: `classes/environment/`, `classes/cooking/`, `classes/foodstage/`

### Environment

Объект `Environment` — на каждого игрока (`PlayerBase.m_Environment`). Симулирует влияние среды на персонажа.

#### Что отслеживает

| Переменная | Описание |
|-----------|----------|
| `m_Rain` | 0–1 интенсивность дождя |
| `m_Snowfall` | 0–1 интенсивность снега |
| `m_Wind` | Сила ветра |
| `m_Fog` | 0–1 плотность тумана |
| `m_DayOrNight` | 0=день, 1=ночь |
| `m_EnvironmentTemperature` | Расчётная температура для позиции игрока |
| `m_WaterLevel` | Глубина погружения (0.15/0.5/1.2/1.5) |
| `m_IsUnderRoof` | Raycast вверх 25м |
| `m_IsInWater` | Контакт с жидкостью |
| `m_HeatComfort` / `m_TargetHeatComfort` | Буферизованный / целевой тепловой комфорт |
| `m_UTSAverageTemperature` | Среднее от UTemperatureSource поблизости |

#### Цикл Update(float pDelta)

Вызывается каждый тик. Два слоя:
- **Проверка крыши** — каждые `ENVIRO_TICK_ROOF_RC_CHECK` секунд
- **Основной тик** — каждые `ENVIRO_TICK_RATE` секунд:

```
1. CheckWaterContact() — m_IsInWater, m_WaterLevel
2. CollectAndSetPlayerData() — позиция, скорость, тепло
3. CollectAndSetEnvironmentData() — Weather → температура
4. GatherTemperatureSources() → ProcessTemperatureSources() — UTS
5. ProcessItemsTemperature() — нагрев/охлаждение надетых предметов
6. DetermineHeatcomfortBehavior() → ProcessHeatComfort()
7. Каждые N тиков → ProcessWetness/Dryness
```

#### Расчёт температуры (приоритет)

1. **В воде** → `WorldData.GetLiquidTypeEnviroTemperature()` − контактный модификатор
2. **В здании** → базовая + `m_TemperatureInsideBuildingsModifier`
3. **В машине** → темп + `|темп × ENVIRO_TEMPERATURE_INSIDE_VEHICLE_COEF|`
4. **Под крышей** → высота+облака+туман + ветер × `ENVIRO_TEMPERATURE_UNDERROOF_COEF`
5. **На открытом воздухе** → высота+облака+туман+ветер, поверхность из `CfgSurfaces`

#### Связь с игроком

- `m_Player.GetStatHeatComfort()` — обновляется непрерывно
- `m_Player.GetStatWet()` — 0/1 по максимальной влажности предметов
- `m_Player.SetInWater()` — из `CheckWaterContact()`
- `m_Player.SetInColdArea()` — из `SetAreaGenericColdness()`

---

### Cooking

Класс `Cooking`. Управляет процессом готовки на оборудовании (кастрюля, сковорода, палка).

#### CookingMethodType

| Метод | Значение | Условие |
|-------|----------|---------|
| `BAKING` | 1 | Есть Lard в карго, или сухой карго |
| `BOILING` | 2 | Есть жидкость (не бензин) |
| `DRYING` | 3 | Жидкость = бензин |
| `TIME` | 4 | Временная (дым) |

#### Определение метода (`GetCookingMethodWithTimeOverride`)

```
Ёмкость с жидкостью (не бензин) → BOILING (коэф 1.0)
Ёмкость с бензином → DRYING (коэф 2.0)
Есть Lard в карго → BAKING (коэф 1.0)
Другой карго → BAKING (коэф 2.0, медленнее без жира)
Пусто → NONE
```

#### Основные точки входа

| Метод | Описание |
|-------|----------|
| `CookWithEquipment(ItemBase equip, float coef)` | Готовка в ёмкости — итерация карго |
| `CookOnStick(Edible_Base item, float inc)` | Готовка на палке — всегда BAKING |
| `SmokeItem(Edible_Base item, float inc)` | Копчение — RAW→DRIED, остальное→BURNED |

#### Процесс готовки (`UpdateCookingState`)

```
1. Получить следующую стадию: item.GetNextFoodStageType(method)
2. Читать [MIN_TEMP, COOK_TIME] для следующей стадии
3. Нагревать предмет к температуре оборудования
4. Если food_temp >= food_min_temp → cooking_time += COOKING_FOOD_TIME_INC_VALUE × coef
5. Если cooking_time >= food_time_to_cook → ChangeFoodStage(new_stage), сброс таймера
```

#### Константы

| Константа | Значение |
|-----------|----------|
| `COOKING_FOOD_TIME_INC_VALUE` | 2 (время за тик) |
| `COOKING_LARD_DECREASE_COEF` | 25 (расход жира) |
| `DEFAULT_COOKING_TEMPERATURE` | 150 |
| `LIQUID_BOILING_POINT` | 150 |
| `BURNING_WARNING_THRESHOLD` | 0.75 |

---

### FoodStage

Каждый `Edible_Base` владеет экземпляром `FoodStage`.

#### FoodStageType

```
NONE=0, RAW=1, BAKED=2, BOILED=3, DRIED=4, BURNED=5, ROTTEN=6
```

#### Конфигурация (CfgVehicles)

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

| Метод | Описание |
|-------|----------|
| `GetFoodStageType()` | Текущая стадия |
| `GetNextFoodStageType(CookingMethodType)` | Следующая стадия для метода |
| `CanChangeToNewStage(CookingMethodType)` | Можно ли перейти |
| `ChangeFoodStage(FoodStageType)` | Сменить → `OnFoodStageChange()` на Edible_Base |
| `GetCookingTime()` / `SetCookingTime()` | Накопленное время готовки |

Нутриенты (статические): `GetEnergy()`, `GetWater()`, `GetToxicity()`, `GetAgents()`, `GetFullnessIndex()`, `GetNutritionalIndex()`, `GetDigestibility()`.

`Edible_Base.OnFoodStageChange(stageOld, stageNew)` — точка переопределения для моддера.
