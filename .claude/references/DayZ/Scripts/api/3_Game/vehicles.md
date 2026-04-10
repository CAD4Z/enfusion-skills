Транспортная система. Источники: `vehicles/`

### Иерархия

```
Pawn (сетевая сверка)
└── Transport (базовый транспорт)
    ├── Car (автомобили)
    ├── Helicopter (вертолёты)
    └── Boat (лодки)
```

### Transport

Базовый класс транспорта. Наследует `Pawn`.

Вспомогательные: `TransportType`, `TransportMove`, `TransportOwnerState` — для сетевой сверки.

### Car

Наследует `Transport`. Автомобили. Источник: `vehicles/car.c`

Вспомогательные: `CarType`, `CarMove`, `CarOwnerState`.

#### CarSoundCtrl

Аудио-контроллеры:

```
ENGINE, RPM, SPEED, DOORS, PLAYER
```

#### CarFluid

Жидкости:

```
FUEL, OIL, BRAKE, COOLANT, USER1, USER2, USER3, USER4
```

#### CarGearboxType

```
MANUAL, AUTOMATIC
```

#### CarGear

```
REVERSE, NEUTRAL, FIRST, SECOND, THIRD, FOURTH, FIFTH, SIXTH,
SEVENTH, EIGHTH, NINTH, TENTH, ELEVENTH, TWELFTH, THIRTEENTH,
FOURTEENTH, FIFTEENTH, SIXTEENTH
```

#### CarAutomaticGearboxMode

```
P (Park), R (Reverse), N (Neutral), D (Drive)
```

#### CarWheelWaterState

```
ON_LAND, IN_WATER, UNDER_WATER
```

### Helicopter

Наследует `Transport`. Вертолёты. Источник: `vehicles/helicopter.c`

### Boat

Наследует `Transport`. Водный транспорт. Источник: `vehicles/boat.c`
