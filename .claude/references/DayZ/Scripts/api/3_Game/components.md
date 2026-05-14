Component system and temperature source. Sources: `tools/component.c`, `systems/temperature/`

### Component

Base class for entity components. Source: `tools/component.c`

#### Component types

| Constant | Value | Description |
|----------|-------|-------------|
| `COMP_TYPE_ENTITY_DEBUG` | `0` | Entity debug |
| `COMP_TYPE_ENERGY_MANAGER` | `1` | Energy system |
| `COMP_TYPE_BODY_STAGING` | `2` | Body staging (skinning) stages |
| `COMP_TYPE_ANIMAL_BLEEDING` | `3` | Animal bleeding |

#### Lifecycle

| Method | Description |
|--------|-------------|
| `SetParentEntityAI(parent)` | Bind to entity |
| `Event_OnAwake()` | Awake |
| `Event_OnInit()` | Initialization |
| `Event_OnFrame(entity, timeslice)` | Per-frame update |

#### Usage

```enforcescript
// Creating through EntityAI
entity.CreateComponent(COMP_TYPE_ENERGY_MANAGER);
ComponentEnergyManager em = entity.GetComponent(COMP_TYPE_ENERGY_MANAGER);
```

### ComponentEnergyManager

Manages electrical energy of items. Network synchronization: `m_IsSwichedOn`, `m_CanWork`, `m_IsPlugged`, `m_Energy`.

#### Key methods

| Method | Description |
|--------|-------------|
| `SwitchOn()` / `SwitchOff()` | Turn on/off |
| `CanWork()` | Whether it can work |
| `GetEnergy()` / `SetEnergy(value)` | Current charge |
| `HasEnoughStoredEnergy()` | Enough energy |
| `GetEnergyMax()` | Maximum capacity |
| `GetEnergyUsage()` | Consumption per second |
| `IsPlugged()` | Plugged into a source |
| `PlugThisInto(source)` / `UnplugThis()` | Plug in / unplug |
| `GetEnergySource()` | Energy source |
| `ConsumeEnergy(amount)` | Consume |
| `AddEnergy(amount)` | Add |
| `IsWorking()` | Currently working |
| `SetDebugPlugs(enable)` | Debug mode |

### ComponentBodyStaging

Body staging (skinning) stages for animals/players.

### ComponentAnimalBleeding

Animal bleeding.

### ComponentsBank

Internal entity component registry. Created lazily on the first `GetComponent()`.

| Method | Description |
|--------|-------------|
| `GetComponent(comp_type, extended)` | Get/create component |
| `DeleteComponent(comp_type)` | Delete |
| `IsComponentAlreadyExist(comp_type)` | Check |

---

## UniversalTemperatureSource

Universal temperature source. Source: `systems/temperature/`

Temperature calculation system for campfires, ovens, vehicles, and any heating/cooling objects.

### UniversalTemperatureSource

| Method | Description |
|--------|-------------|
| `SetActive(state)` | Activate/deactivate |
| `IsActive()` | Active |
| `GetTemperature()` | Current temperature |
| `Update(settings)` | Update calculation |

### UniversalTemperatureSourceLambdaBase

Lambda function for temperature calculation. Overridden for custom heating/cooling logic.

### TemperatureAccessManager

Manager of access to temperature data. Central hub for temperature updates.

### TemperatureAccessComponent

EntityAI binding component. Created automatically for entities with `CanHaveTemperature() == true`.

### TemperatureData

Container of temperature data.

| Field | Description |
|-------|-------------|
| `m_Value` | Current temperature |
| `m_Min` / `m_Max` | Limits |
| `m_FreezeThreshold` / `m_ThawThreshold` | Freezing/thawing thresholds |
| `m_FreezeTime` / `m_ThawTime` | Freezing/thawing duration |
| `m_HeatPermeabilityCoef` | Heat permeability coefficient |
