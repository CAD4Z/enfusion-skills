Registry of magazines and loose rounds. Script constant: `CFG_MAGAZINESPATH = "CfgMagazines"`.

### Hierarchy

```
DefaultMagazine
└── Magazine_Base            — all magazines
    └── Ammunition_Base      — loose rounds
```

### Key properties of Magazine_Base

```cpp
class MyMag: Magazine_Base
{
    scope = 2;
    displayName = "$STR_MyMag";
    model = "\mymod\mag.p3d";

    inventorySlot[] = { "magazine", "magazine2", "magazine3" };
    itemSize[] = {1, 2};
    weight = 113;
    weightPerQuantityUnit = 8;          // weight of one round in grams

    count = 30;                         // magazine capacity
    ammo = "Bullet_556x45";            // bullet class from CfgAmmo (what flies out)
    ammoItems[] = { "Ammo_556x45" };   // loose-round class from CfgMagazines (what it's loaded with)
    tracersEvery = 0;                   // every Nth round is a tracer (0 = none)

    manipulationDamage = 0.05;          // damage from manual handling

    class Reliability
    {
        ChanceToJam[] = {0, 0.001, 0.01, 0.05, 1};
    };
};
```

### Ammunition_Base — loose rounds

```cpp
class Ammo_9x19: Ammunition_Base
{
    scope = 2;
    displayName = "$STR_Ammo_9x19";
    model = "\dz\weapons\ammunition\9x19_LooseRounds.p3d";

    itemSize[] = {1, 1};
    weight = 8;
    count = 25;                         // max count in a stack
    ammo = "Bullet_9x19";              // bullet class from CfgAmmo

    canBeSplit = 1;                     // stack can be split
    destroyOnEmpty = 1;                 // remove when 0 rounds
    varQuantityDestroyOnMin = 1;
};
```

### Linkage between magazines, weapons and bullets

```
CfgWeapons::Glock19
    magazines[] → "Mag_Glock_15Rnd"      (CfgMagazines — magazine)
    chamberableFrom[] → "Ammo_9x19"      (CfgMagazines — loose rounds)

CfgMagazines::Mag_Glock_15Rnd
    ammo → "Bullet_9x19"                 (CfgAmmo — what flies out of the barrel)
    ammoItems[] → "Ammo_9x19"            (CfgMagazines — what it's loaded with)

CfgMagazines::Ammo_9x19
    ammo → "Bullet_9x19"                 (CfgAmmo — what flies out)

CfgAmmo::Bullet_9x19                     — bullet physics, damage
```