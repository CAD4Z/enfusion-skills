Реестр оружия. Константа в скриптах: `CFG_WEAPONSPATH = "CfgWeapons"`.

### Иерархия базовых классов

```
DefaultWeapon
├── RifleCore
│   └── Rifle_Base               — все винтовки, автоматы, дробовики
│       ├── BoltActionRifle_Base
│       │   ├── BoltActionRifle_InnerMagazine_Base
│       │   └── BoltActionRifle_ExternalMagazine_Base
│       └── Shotgun_Base
├── PistolCore
│   └── Pistol_Base              — все пистолеты
└── LauncherCore                 — гранатомёты
```

### Ключевые свойства Rifle_Base

```cpp
class MyRifle: Rifle_Base
{
    scope = 2;
    displayName = "$STR_MyRifle";
    descriptionShort = "$STR_MyRifleDesc";
    model = "\mymod\rifle.p3d";

    // Слоты
    inventorySlot[] = { "Shoulder", "Melee" };
    attachments[] = { "weaponOptics", "weaponFlashlight", "suppressorImpro" };
    itemSize[] = {6, 3};

    // Баллистика
    chamberSize = 1;                        // размер каморы
    chamberedRound = "";                    // патрон по умолчанию
    magazines[] = { "Mag_MyRifle_30Rnd" };  // совместимые магазины
    chamberableFrom[] = { "Ammo_556x45" };  // совместимые россыпные патроны
    ejectType = 1;                          // тип выброса гильз

    // Физика стрельбы
    recoilModifier[] = {1, 1, 1};
    swayModifier[] = {1.1, 1.1, 0.5};
    WeaponLength = 0.8;                     // длина оружия
    barrelArmor = 400;                      // прочность ствола
    damagePerShot = 0.05;                   // износ за выстрел
    unjamTime[] = {6, 10};                  // время расклинивания (мин, макс)

    // Оптика
    discreteDistance[] = {50, 100, 200, 300};    // дистанции пристрелки
    discreteDistanceInitIndex = 1;               // начальная пристрелка

    // Режимы стрельбы
    modes[] = { "SemiAuto", "FullAuto" };
    class SemiAuto: Mode_SemiAuto
    {
        soundSetShot[] = { "MyRifle_Shot_SoundSet", "MyRifle_Tail_SoundSet" };
        reloadTime = 0.1;
        recoil = "recoil_MyRifle";
        dispersion = 0.002;                 // разброс в радианах
        magazineSlot = "magazine";
    };

    class NoiseShoot
    {
        strength = 100;                     // сила шума (дальность обнаружения AI)
        type = "shot";
    };

    class OpticsInfo: OpticsInfoRifle {};

    class DamageSystem
    {
        class GlobalHealth
        {
            class Health { hitpoints = 100; };
        };
    };

    class Reliability
    {
        ChanceToJam[] = {0, 0.001, 0.01, 0.1, 1};  // шанс заклинивания по уровню износа
    };

    class MeleeModes
    {
        class Default    { ammo = "FirearmHit_Rifle";          range = 1.2; };
        class Buttstock  { ammo = "FirearmHit_Rifle_Buttstock"; range = 1.2; };
        class Bayonet    { ammo = "FirearmHit_Rifle_Bayonet";   range = 1.8; };
    };
};
```

### Пример — пистолет (Glock19)

```cpp
class cfgWeapons
{
    class Pistol_Base;
    class Glock19_Base: Pistol_Base
    {
        scope = 0;
        weight = 1000;
        chamberSize = 1;
        magazines[] = { "Mag_Glock_15Rnd" };
        chamberableFrom[] = { "Ammo_9x19" };
        ejectType = 1;
        recoilModifier[] = {1, 1, 1};
        swayModifier[] = {1.1, 1.1, 0.5};
        WeaponLength = 0.21;

        class NoiseShoot { strength = 40; type = "shot"; };

        modes[] = { "SemiAuto" };
        class SemiAuto: Mode_SemiAuto
        {
            soundSetShot[] = { "Glock19_Shot_SoundSet", "Glock19_Tail_SoundSet" };
            reloadTime = 0.13;
            recoil = "recoil_Glock";
            dispersion = 0.003;
        };
    };
    class Glock19: Glock19_Base
    {
        scope = 2;
        displayName = "$STR_cfgWeapons_Glock190";
        model = "\dz\weapons\pistols\glock\Glock19.p3d";
        attachments[] = { "pistolOptics", "pistolFlashlight", "pistolMuzzle" };
        itemSize[] = {3, 2};
    };
};
```