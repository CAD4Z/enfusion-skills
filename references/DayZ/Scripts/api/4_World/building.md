`4_World` — construction. Sources: `entities/itembase/basebuildingbase.c`, `classes/basebuilding/construction.c`

### Architecture

`BaseBuildingBase extends ItemBase` owns a `Construction` object (`m_Construction`) which manages `ConstructionPart` entries from the config.

```
BaseBuildingBase
 └── m_Construction: Construction
      └── map<string, ConstructionPart>  // keyed by part name
```

### ConstructionPart

| Field | Description |
|------|----------|
| `m_PartName` | Part name |
| `m_MainPartName` | Category (Level) |
| `m_Id` | 1–93, used for bit sync |
| `m_IsBuilt` | Whether it has been built |
| `m_IsBase` | Base part (first, used when placing) |
| `m_IsGate` | Gate |
| `m_RequiredParts` | Dependencies (must already be built) |

### Synchronization

Three `int` bitmasks (`m_SyncParts01/02/03`), supporting up to 93 parts (31 per int). `RegisterPartForSync(id)` sets the bit → `SetSynchDirty()` → the client reads the masks → `ShowConstructionPartPhysics()` / `HideConstructionPartPhysics()`.

### Configuration (CfgVehicles)

```
CfgVehicles MyFence Construction {
    Level1 {
        wall_base {
            name = "Wall Base";
            id = 1;
            is_base = 1;
            show_on_init = 0;
            required_parts[] = {};
            conflicted_parts[] = {};
            Materials {
                Material_0 { slot_name = "WoodLog"; quantity = 4; lockable = 1; }
            }
        }
    }
}
```

### Construction lifecycle

#### Building (server)

```
Construction.BuildPartServer(player, part_name, action_id)
 1. Reset damage zone health
 2. TakeMaterialsServer() — consume/lock materials
 3. → BaseBuildingBase.OnPartBuiltServer()
     ├── If base part → SetBaseState(true)
     ├── RegisterPartForSync() + SetSynchDirty()
     ├── UpdateNavmesh()
     └── UpdateVisuals()
```

#### Dismantling (server)

```
Construction.DismantlePartServer()
 1. ReceiveMaterialsServer() — return materials to the player
 2. DropNonUsableMaterialsServer() — drop the unusable ones
 3. → BaseBuildingBase.OnPartDismantledServer()
     └── If base part → DestroyConstruction() (ObjectDelete, 200ms)
```

#### Destruction (server)

```
Construction.DestroyPartServer()
 1. DestroyMaterialsServer() — remove locked materials
 2. → BaseBuildingBase.OnPartDestroyedServer()
     └── DestroyConnectedParts() — cascading destruction of dependents
```

On `EEHealthLevelChanged` → `STATE_RUINED` → automatic `DestroyPartServer()`.

### Build check (`CanBuildPart`)

All conditions:
1. Part is not built
2. `HasRequiredPart()` — all dependencies are built
3. `!HasConflictPart()` — no conflicting parts
4. `HasMaterials()` — all slots are filled
5. `!MaterialIsRuined()` — materials are not ruined
6. `CanUseToolToBuildPart()` — appropriate tool

### Materials

Materials are items in the construction's inventory slots. `lockable=1` — locked once built (cannot be removed). Repair costs `REPAIR_MATERIAL_PERCENTAGE = 0.15` (15%) of the build cost.

### Overridable BaseBuildingBase methods

| Method | Purpose |
|-------|------------|
| `GetConstructionKitType()` | Kit classname (e.g. `"FenceKit"`) |
| `OnPartBuiltServer(Man, string, int)` | Hook after build |
| `OnPartBuiltClient(string, int)` | Client — sounds |
| `OnPartDismantledServer(Man, string, int)` | Hook after dismantle |
| `OnPartDestroyedServer(Man, string, int, bool)` | Hook after destruction |
| `UpdateVisuals()` | Refresh visuals |
| `IsOpened()` | Gate state |
