The main entity registry. Contains **all** game objects: items, clothing, structures, vehicles, animals, players, zones. Script constant: `CFG_VEHICLESPATH = "CfgVehicles"`.

### Base class hierarchy

```
All                              — root of all entities
├── AllVehicles                  — vehicles, living creatures
│   └── Man                      — characters
│       ├── Man_Base
│       │   ├── DZ_LightAI       — zombies, AI
│       │   └── SurvivorBase     — player
│       └── DZ_LightAI_old
├── Static                       — static objects
│   ├── Building
│   │   ├── Strategic
│   │   │   └── FlagCarrierCore
│   │   └── NonStrategic
│   │       └── NonStrategic_Base
│   ├── House                    — buildings (destructible)
│   │   ├── HouseNoDestruct      — indestructible
│   │   │   └── EffectArea       — effect zones
│   │   ├── HouseHighCost
│   │   └── Ruins
│   └── Inventory_Base           — all pickable items
│       ├── Clothing_Base        — clothing
│       ├── Container_Base       — containers
│       ├── Edible_Base          — food/drink
│       │   └── Bottle_Base
│       ├── Powered_Base         — items with power
│       │   └── Switchable_Base  — switchable
│       ├── ExplosivesBase       — explosives
│       │   └── Grenade_Base
│       ├── Trap_Base            — traps
│       ├── FishingRod_Base      — fishing rods
│       ├── Book_Base            — books
│       ├── Box_Base             — boxes
│       └── ItemOptics           — optics
```

Vehicles are defined separately:
```
Car (engine class)
└── CarScript                    — base script class for vehicles
    ├── OffroadHatchback
    ├── Hatchback_02
    └── ...
```

### scope — class visibility

| Value | Description |
|-------|-------------|
| `0` | Base/abstract class — cannot be spawned, not visible in editors |
| `1` | Internal — used by the engine but not spawned directly |
| `2` | Public — can be spawned, visible in editors |

### Key properties of Inventory_Base

```cpp
class MyItem: Inventory_Base
{
    scope = 2;                          // 0/1/2 — visibility
    displayName = "$STR_MyItem";        // localized name
    descriptionShort = "$STR_MyDesc";   // short description
    model = "\mymod\item.p3d";          // path to the model

    // Inventory
    itemSize[] = {2, 3};                // size in slots (width, height)
    weight = 1000;                      // weight in grams
    inventorySlot[] = { "Shoulder" };   // which slots it fits into
    attachments[] = {};                 // attachment slots on the item
    storageCategory = 1;                // storage category
    itemInfo[] = {};                    // item tags

    // Visuals
    hiddenSelections[] = { "camo" };                    // named areas for texture replacement
    hiddenSelectionsTextures[] = { "path\tex_co.paa" }; // textures for those areas

    // Physics
    simulation = "inventoryItem";       // simulation type
    physLayer = "item_small";           // physical layer
    absorbency = 0;                     // moisture absorbency
    heatIsolation = 0;                  // heat insulation
    fragility = 0.1;                    // fragility
    soundImpactType = "default";        // impact sound

    // State variables
    varWetInit = 0;                     // initial wetness
    varTemperatureInit = 0;             // initial temperature
    spawnDamageRange[] = {0, 0.6};      // damage range on spawn

    // Repair
    repairableWithKits[] = {0};         // repair kit types (0=none)
    repairCosts[] = {0};                // repair cost

    // Damage system
    class DamageSystem
    {
        class GlobalHealth
        {
            class Health
            {
                hitpoints = 100;        // max HP
                healthLevels[] =        // visual condition levels
                {                       // {threshold, {materials}}
                    {1.0, {}},          // Pristine
                    {0.7, {}},          // Worn
                    {0.5, {}},          // Damaged
                    {0.3, {}},          // Badly Damaged
                    {0.0, {}}           // Ruined
                };
            };
        };
    };

    // Protection (for clothing)
    class Protection
    {
        biological = 0;
        chemical = 0;
    };

    // Melee
    isMeleeWeapon = 1;
    class MeleeModes
    {
        class Default
        {
            ammo = "MeleeFist";         // class from CfgAmmo
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

### Clothing_Base — clothing

Inherits from `Inventory_Base`, adds:

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
        class GlobalArmor               // armor — absent on ordinary items
        {
            class Projectile
            {
                class Health { damage = 1; };   // multiplier (1 = no protection)
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

### Example — complete item (AlarmClock)

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