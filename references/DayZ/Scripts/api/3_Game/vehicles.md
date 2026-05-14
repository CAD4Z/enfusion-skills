Vehicle system. Sources: `vehicles/`

### Hierarchy

```
Pawn (network reconciliation)
└── Transport (base transport)
    ├── Car (cars)
    ├── Helicopter (helicopters)
    └── Boat (boats)
```

### Transport

Base transport class. Inherits `Pawn`.

Helpers: `TransportType`, `TransportMove`, `TransportOwnerState` — for network reconciliation.

### Car

Inherits `Transport`. Cars. Source: `vehicles/car.c`

Helpers: `CarType`, `CarMove`, `CarOwnerState`.

#### CarSoundCtrl

Audio controllers:

```
ENGINE, RPM, SPEED, DOORS, PLAYER
```

#### CarFluid

Fluids:

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

Inherits `Transport`. Helicopters. Source: `vehicles/helicopter.c`

### Boat

Inherits `Transport`. Watercraft. Source: `vehicles/boat.c`
