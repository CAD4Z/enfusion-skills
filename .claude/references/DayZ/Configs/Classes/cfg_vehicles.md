Основной реестр сущностей. Содержит **все** игровые объекты: предметы, одежду, строения, транспорт, животных, игроков, зоны. Константа в скриптах: `CFG_VEHICLESPATH = "CfgVehicles"`.

### Иерархия базовых классов

```
All                              — корень всех сущностей
├── AllVehicles                  — транспорт, живые существа
│   └── Man                      — персонажи
│       ├── Man_Base
│       │   ├── DZ_LightAI       — зомби, AI
│       │   └── SurvivorBase     — игрок
│       └── DZ_LightAI_old
├── Static                       — статичные объекты
│   ├── Building
│   │   ├── Strategic
│   │   │   └── FlagCarrierCore
│   │   └── NonStrategic
│   │       └── NonStrategic_Base
│   ├── House                    — здания (разрушаемые)
│   │   ├── HouseNoDestruct      — неразрушаемые
│   │   │   └── EffectArea       — зоны эффектов
│   │   ├── HouseHighCost
│   │   └── Ruins
│   └── Inventory_Base           — все подбираемые предметы
│       ├── Clothing_Base        — одежда
│       ├── Container_Base       — контейнеры
│       ├── Edible_Base          — еда/питьё
│       │   └── Bottle_Base
│       ├── Powered_Base         — предметы с питанием
│       │   └── Switchable_Base  — включаемые
│       ├── ExplosivesBase       — взрывчатка
│       │   └── Grenade_Base
│       ├── Trap_Base            — ловушки
│       ├── FishingRod_Base      — удочки
│       ├── Book_Base            — книги
│       ├── Box_Base             — коробки
│       └── ItemOptics           — оптика
```

Транспорт определяется отдельно:
```
Car (движковый класс)
└── CarScript                    — базовый скриптовый класс транспорта
    ├── OffroadHatchback
    ├── Hatchback_02
    └── ...
```

### scope — видимость класса

| Значение | Описание |
|----------|----------|
| `0` | Базовый/абстрактный класс — нельзя заспавнить, не виден в редакторах |
| `1` | Внутренний — используется движком, но не спавнится напрямую |
| `2` | Публичный — можно заспавнить, виден в редакторах |

### Ключевые свойства Inventory_Base

```cpp
class MyItem: Inventory_Base
{
    scope = 2;                          // 0/1/2 — видимость
    displayName = "$STR_MyItem";        // локализованное имя
    descriptionShort = "$STR_MyDesc";   // краткое описание
    model = "\mymod\item.p3d";          // путь к модели

    // Инвентарь
    itemSize[] = {2, 3};                // размер в слотах (ширина, высота)
    weight = 1000;                      // вес в граммах
    inventorySlot[] = { "Shoulder" };   // в какие слоты помещается
    attachments[] = {};                 // слоты аттачментов на предмете
    storageCategory = 1;                // категория хранения
    itemInfo[] = {};                    // теги предмета

    // Визуал
    hiddenSelections[] = { "camo" };                    // именованные области для замены текстур
    hiddenSelectionsTextures[] = { "path\tex_co.paa" }; // текстуры для этих областей

    // Физика
    simulation = "inventoryItem";       // тип симуляции
    physLayer = "item_small";           // физический слой
    absorbency = 0;                     // впитываемость влаги
    heatIsolation = 0;                  // теплоизоляция
    fragility = 0.1;                    // хрупкость
    soundImpactType = "default";        // звук удара

    // Переменные состояния
    varWetInit = 0;                     // начальная влажность
    varTemperatureInit = 0;             // начальная температура
    spawnDamageRange[] = {0, 0.6};      // диапазон урона при спавне

    // Ремонт
    repairableWithKits[] = {0};         // типы ремкомплектов (0=нет)
    repairCosts[] = {0};                // стоимость ремонта

    // Система урона
    class DamageSystem
    {
        class GlobalHealth
        {
            class Health
            {
                hitpoints = 100;        // макс. HP
                healthLevels[] =        // визуальные уровни состояния
                {                       // {порог, {материалы}}
                    {1.0, {}},          // Pristine
                    {0.7, {}},          // Worn
                    {0.5, {}},          // Damaged
                    {0.3, {}},          // Badly Damaged
                    {0.0, {}}           // Ruined
                };
            };
        };
    };

    // Защита (для одежды)
    class Protection
    {
        biological = 0;
        chemical = 0;
    };

    // Ближний бой
    isMeleeWeapon = 1;
    class MeleeModes
    {
        class Default
        {
            ammo = "MeleeFist";         // класс из CfgAmmo
            range = 1;
        };
        class Heavy
        {
            ammo = "MeleeFist_Heavy";
            range = 1;
        };
    };
};
```

### Clothing_Base — одежда

Наследуется от `Inventory_Base`, добавляет:

```cpp
class MyShirt: Clothing_Base
{
    scope = 2;
    simulation = "clothing";
    itemInfo[] = { "Clothing" };
    visibilityModifier = 1;
    soundVoiceType = "none";

    class DamageSystem
    {
        class GlobalHealth { /* ... */ };
        class GlobalArmor               // броня — отсутствует у обычных предметов
        {
            class Projectile
            {
                class Health { damage = 1; };   // множитель (1 = нет защиты)
                class Blood  { damage = 1; };
                class Shock  { damage = 1; };
            };
            class Melee
            {
                class Health { damage = 1; };
                class Blood  { damage = 1; };
                class Shock  { damage = 1; };
            };
            class FragGrenade { /* ... */ };
        };
    };
};
```

### Пример — полный предмет (AlarmClock)

```cpp
class CfgVehicles
{
    class Inventory_Base;
    class AlarmClock_ColorBase: Inventory_Base
    {
        scope = 0;
        displayName = "$STR_CfgVehicles_AlarmClock0";
        descriptionShort = "$STR_CfgVehicles_AlarmClock1";
        model = "\dz\gear\tools\AlarmClock.p3d";
        isMeleeWeapon = 1;
        itemSize[] = {2, 2};
        weight = 250;
        inventorySlot[] = { "TriggerAlarmClock" };
        soundImpactType = "metal";
        hiddenSelections[] = { "camo" };
        hiddenSelectionsTextures[] = { "dz\gear\tools\data\alarmclock_blue_co.paa" };

        class AnimationSources
        {
            class ClockAlarm
            {
                source = "user";
                initPhase = 0;
                animPeriod = 5;
            };
        };
        class NoiseAlarmClock
        {
            strength = 200;
            type = "sound";
        };
        class DamageSystem
        {
            class GlobalHealth
            {
                class Health
                {
                    hitpoints = 50;
                    healthLevels[] =
                    {
                        {1.0, {"lensglass_ca.paa", "alarmclock_glass.rvmat", "alarmclock.rvmat"}},
                        {0.7, {}},
                        {0.5, {"lensglass_damage_ca.paa", "alarmclock_glass_damage.rvmat"}},
                        {0.3, {}},
                        {0.0, {"alarmclock_destruct.rvmat"}}
                    };
                };
            };
        };
    };
};
```