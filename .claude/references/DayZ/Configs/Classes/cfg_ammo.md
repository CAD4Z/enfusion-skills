Registry of projectiles/bullets. Defines flight physics and inflicted damage. Has no constant in scripts — accessed via `"CfgAmmo"`.

### Key properties of Bullet_Base

```cpp
class Bullet_9x19: Bullet_Base
{
    scope = 1;
    model = "\dz\weapons\projectiles\empty.p3d";

    // Linkage
    casing = "FxCartridge_9mm";         // casing effect
    round = "FxRound_9mm";             // round effect
    spawnPileType = "Ammo_9x19";       // loose-pile class in CfgMagazines

    // Ballistics
    hit = 7;                            // base damage
    indirectHit = 0;                    // splash damage
    indirectHitRange = 0;               // splash damage radius
    initSpeed = 370;                    // initial speed m/s
    typicalSpeed = 390;                 // typical speed
    airFriction = -0.0025;              // air resistance
    caliber = 1;                        // penetration coefficient
    deflecting = 30;                    // ricochet probability (degrees)
    airLock = 1;                        // fly-by sound

    // Barrel wear
    damageBarrel = 187.5;               // barrel damage per shot
    damageBarrelDestroyed = 187.5;      // damage to a destroyed barrel

    weight = 0.0102;                    // bullet weight in kg
    impactBehaviour = 0;
    hitAnimation = 1;

    // Tracer
    tracerScale = 1;
    tracerStartTime = -1;               // -1 = not a tracer
    tracerEndTime = 1;

    // Damage system
    class DamageApplied
    {
        type = "Projectile";            // damage type
        dispersion = 0;                 // damage spread
        bleedThreshold = 1;             // bleeding threshold

        defaultDamageOverride[] =       // damage multiplier override
        {
            {0.85, 1}                   // {multiplier, probability}
        };

        class Health { damage = 65; };  // health damage
        class Blood  { damage = 100; }; // blood damage
        class Shock  { damage = 90; };  // shock damage
    };

    class NoiseHit
    {
        strength = 10;                  // noise on hit
        type = "sound";
    };
};
```

### Example — .308 Win (rifle round)

```cpp
class Bullet_308Win: Bullet_Base
{
    scope = 1;
    casing = "FxCartridge_762";
    round = "FxRound_308Win";
    spawnPileType = "Ammo_308Win";
    hit = 12;
    initSpeed = 770;
    typicalSpeed = 940;
    airFriction = -0.001;
    caliber = 1;
    deflecting = 10;
    damageBarrel = 500;

    class DamageApplied
    {
        type = "Projectile";
        bleedThreshold = 1;
        defaultDamageOverride[] = { {0.86, 1} };
        class Health { damage = 150; };
        class Blood  { damage = 100; };
        class Shock  { damage = 150; };
    };
};
```