Реестр магазинов и россыпных патронов. Константа в скриптах: `CFG_MAGAZINESPATH = "CfgMagazines"`.

### Иерархия

```
DefaultMagazine
└── Magazine_Base            — все магазины
    └── Ammunition_Base      — россыпные патроны
```

### Ключевые свойства Magazine_Base

```cpp
class MyMag: Magazine_Base
{
    scope = 2;
    displayName = "$STR_MyMag";
    model = "\mymod\mag.p3d";

    inventorySlot[] = { "magazine", "magazine2", "magazine3" };
    itemSize[] = {1, 2};
    weight = 113;
    weightPerQuantityUnit = 8;          // вес одного патрона в граммах

    count = 30;                         // ёмкость магазина
    ammo = "Bullet_556x45";            // класс пули из CfgAmmo (что вылетает)
    ammoItems[] = { "Ammo_556x45" };   // класс россыпных патронов из CfgMagazines (чем снаряжается)
    tracersEvery = 0;                   // каждый N-й патрон трассер (0 = нет)

    manipulationDamage = 0.05;          // урон при ручных манипуляциях

    class Reliability
    {
        ChanceToJam[] = {0, 0.001, 0.01, 0.05, 1};
    };
};
```

### Ammunition_Base — россыпные патроны

```cpp
class Ammo_9x19: Ammunition_Base
{
    scope = 2;
    displayName = "$STR_Ammo_9x19";
    model = "\dz\weapons\ammunition\9x19_LooseRounds.p3d";

    itemSize[] = {1, 1};
    weight = 8;
    count = 25;                         // макс. кол-во в стаке
    ammo = "Bullet_9x19";              // класс пули из CfgAmmo

    canBeSplit = 1;                     // можно разделять стак
    destroyOnEmpty = 1;                 // удалять при 0 патронов
    varQuantityDestroyOnMin = 1;
};
```

### Связь магазинов с оружием и пулями

```
CfgWeapons::Glock19
    magazines[] → "Mag_Glock_15Rnd"      (CfgMagazines — магазин)
    chamberableFrom[] → "Ammo_9x19"      (CfgMagazines — россыпь)

CfgMagazines::Mag_Glock_15Rnd
    ammo → "Bullet_9x19"                 (CfgAmmo — что вылетает из ствола)
    ammoItems[] → "Ammo_9x19"            (CfgMagazines — чем снаряжается)

CfgMagazines::Ammo_9x19
    ammo → "Bullet_9x19"                 (CfgAmmo — что вылетает)

CfgAmmo::Bullet_9x19                     — физика пули, урон
```