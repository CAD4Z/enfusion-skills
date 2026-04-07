Реестр снарядов/пуль. Определяет физику полёта и наносимый урон. Не имеет константы в скриптах — доступ через `"CfgAmmo"`.

### Ключевые свойства Bullet_Base

```cpp
class Bullet_9x19: Bullet_Base
{
    scope = 1;
    model = "\dz\weapons\projectiles\empty.p3d";

    // Связь
    casing = "FxCartridge_9mm";         // эффект гильзы
    round = "FxRound_9mm";             // эффект патрона
    spawnPileType = "Ammo_9x19";       // класс россыпи в CfgMagazines

    // Баллистика
    hit = 7;                            // базовый урон
    indirectHit = 0;                    // непрямой урон
    indirectHitRange = 0;               // радиус непрямого урона
    initSpeed = 370;                    // начальная скорость м/с
    typicalSpeed = 390;                 // типичная скорость
    airFriction = -0.0025;              // сопротивление воздуха
    caliber = 1;                        // коэффициент пробития
    deflecting = 30;                    // вероятность рикошета (градусы)
    airLock = 1;                        // звук пролёта

    // Износ ствола
    damageBarrel = 187.5;               // урон стволу за выстрел
    damageBarrelDestroyed = 187.5;      // урон разрушенному стволу

    weight = 0.0102;                    // вес пули в кг
    impactBehaviour = 0;
    hitAnimation = 1;

    // Трассер
    tracerScale = 1;
    tracerStartTime = -1;               // -1 = не трассер
    tracerEndTime = 1;

    // Система урона
    class DamageApplied
    {
        type = "Projectile";            // тип урона
        dispersion = 0;                 // разброс урона
        bleedThreshold = 1;             // порог кровотечения

        defaultDamageOverride[] =       // переопределение множителя урона
        {
            {0.85, 1}                   // {множитель, вероятность}
        };

        class Health { damage = 65; };  // урон здоровью
        class Blood  { damage = 100; }; // урон крови
        class Shock  { damage = 90; };  // урон шоку
    };

    class NoiseHit
    {
        strength = 10;                  // шум при попадании
        type = "sound";
    };
};
```

### Пример — .308 Win (винтовочный патрон)

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