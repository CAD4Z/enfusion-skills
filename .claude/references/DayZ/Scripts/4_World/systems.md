`4_World` — системы. Инвентарь, температура, ловля, рецепты, эмоуты, VirtualHud. Источники: `systems/`, `classes/recipes/`, `classes/emoteclasses/`, `classes/virtualhud/`

### Инвентарь (DayZPlayerInventory)

`DayZPlayerInventory extends HumanInventoryWithFSM`. Добавляет анимированную Hand FSM, отложенные события и серверную валидацию поверх `HumanInventory` из 3_Game.

#### Синхронизация

```
Клиент → StoreInputUserData → [сеть] → ProcessInputData
 → Валидация (дистанция src/dst, juncture lock, LocationCanMoveEntity)
 → Выполнение или juncture-ожидание
```

5 подклассов `DeferredEvent` для атомарных резервирований слотов при предиктивных операциях.

#### AttachmentsOutOfReach

Проверка доступности через memory points или LOD selections. XZ и Y проверяются независимо.

---

### Температурные источники (UniversalTemperatureSource)

`UTemperatureSource` — объект-источник тепла рядом с сущностями.

#### Как работает

`UniversalTemperatureSourceLambdaBaseImpl.Execute()`:
1. AABB box query → фильтрация по сфере
2. Сушка предметов (коэффициент обратно-пропорционален дистанции)
3. Нагрев сущностей рекурсивно через весь инвентарь/аттачменты
4. На каждом уровне учитывается `HeatPermeabilityCoef`

---

### Ловля животных (AnimalCatchingSystem)

Источники: `systems/animalcatchingsystem/`

#### Удочка

- Сигнальные циклы с Poisson-подобной вероятностью (EaseInExpo)
- Синхронизированный RNG
- Потеря крючка/наживки при промахе

#### Ловушки

- Формула Бернулли: `P = 1 - (1 - cumulative)^(1/N)` за попытку
- Чувствительность наживки по типу животного

#### Yield Items

Несут 24-элементные массивы коэффициентов по часам суток (рыболовные ставки по времени дня).

---

### Рецепты (Recipes)

Источники: `classes/recipes/`

Макс 2 ингредиента, 10 результатов. `CheckIngredientMatch` использует `IsKindOf` для проверки иерархии типов.

Массивы per-ingredient и per-result для: health, quantity, destroy, softskills флагов.

---

### Эмоуты (EmoteClasses)

Источники: `classes/emoteclasses/`

`EmoteBase` — базовый класс эмоута.

| Метод | Описание |
|-------|----------|
| `DetermineOverride(out int, out int)` | Переопределение анимации по контексту |
| `CanBeCanceledNormally()` | Можно ли отменить нормально |

Additive vs fullbody определяется через stance masks.

---

### VirtualHud

Источники: `classes/virtualhud/`

Серверная система → RPC на клиент. Сервер вычисляет битовую маску изменённых элементов.

| Элемент | Тип |
|---------|-----|
| `DELM_TDCY_*` | Tendency (стрелки) |
| `DELM_BADGE_*` | Badges (иконки) |
| `STANCE`, `BLEEDING` | Только клиент |

16 элементов, 2 INT маски. `DSLevels` → HUD коды состояний 1–5.

---

### Кровотечение (BleedingSources)

Источники: `classes/bleedingsources/`

28 зон по всем костям скелета, привязаны к слотам инвентаря (BODY, LEGS, FEET, GLOVES, HEADGEAR, MASK).

Битовая маска на игрока (`GetBleedingBits()`), макс 32 зоны. Тип `CONTAMINATED` умножает поток на `BURN_MODIFIER`. Удаление источника → бросок шанса инфекции.

---

### Заражённые зоны (ContaminatedArea)

Источники: `classes/contaminatedarea/`

Динамические зоны: симуляция времени полёта снаряда (`distance / 100 + 20с`), спаун `Grenade_ChemGas` при создании, `ShellLight` (0.15с вспышка).

---

### Эффекты (misc)

- **Flashbang**: 8с длительность, 2.5с breakpoint, PPE + отложенный звук 0.4с, день/ночь интенсивность
- **HitDirection**: позиционирование на краю экрана (sin/cos), SmoothCD сглаживание
- **Sound handlers**: stamina, hunger, thirst, injury — injury адаптирует зону по стойке и скорости

---

### Bot (тестирование)

Источники: `systems/bot/`

Инструмент разработчика. FSM-driven, управление через `EActions.PLAYER_BOT_*`. Только при `#define BOT_DEBUG`. Не присутствует в релизных билдах.
