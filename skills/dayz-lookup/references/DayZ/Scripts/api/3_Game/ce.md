Central Economy — the loot spawn and management system. Source: `ce/`

### CentralEconomy

Core of the system (native). Accessed via `GetCEApi()`.

### ECE flags (Entity Creation)

Entity creation flags. Used in `CreateObjectEx()` and CE operations. Combined bitwise.

#### Basic

| Flag | Description |
|------|-------------|
| `ECE_SETUP` | Basic setup |
| `ECE_TRACE` | Place on surface (trace downwards) |
| `ECE_CENTER` | Center on surface |
| `ECE_UPDATEPATHGRAPH` | Update navmesh |
| `ECE_CREATEPHYSICS` | Create physics body |
| `ECE_INITAI` | Initialize AI |
| `ECE_AIRBORNE` | Airborne (no trace) |

#### Equipment

| Flag | Description |
|------|-------------|
| `ECE_EQUIP_ATTACHMENTS` | Spawn attachments |
| `ECE_EQUIP_CARGO` | Spawn loot in cargo |
| `ECE_EQUIP` | Attachments + cargo |
| `ECE_EQUIP_CONTAINER` | Container with loot |

#### Persistence

| Flag | Description |
|------|-------------|
| `ECE_NOLIFETIME` | No lifetime (doesn't despawn) |
| `ECE_NOPERSISTENCY_WORLD` | Not saved to world |
| `ECE_NOPERSISTENCY_CHAR` | Not saved on character |
| `ECE_DYNAMIC_PERSISTENCY` | Dynamic persistence |

#### Other

| Flag | Description |
|------|-------------|
| `ECE_NOSURFACEALIGN` | No alignment to surface |
| `ECE_KEEPHEIGHT` | Preserve height |

#### Presets

| Preset | Description |
|--------|-------------|
| `ECE_IN_INVENTORY` | For items in inventory |
| `ECE_PLACE_ON_SURFACE` | Place on surface |
| `ECE_OBJECT_SWAP` | Object swap |
| `ECE_FULL` | Full setup (all main flags) |

### RF flags (Rotation)

Orientation at spawn:

| Flag | Description |
|------|-------------|
| `RF_FRONT` | Face the surface |
| `RF_TOP` | Up |
| `RF_LEFT` / `RF_RIGHT` | Sideways |
| `RF_BACK` / `RF_BOTTOM` | Back / bottom |
| `RF_RANDOMROT` | Random rotation on Y axis |
| `RF_ORIGINAL` | Original orientation |
| `RF_DECORRECTION` | Correction during swap |
| `RF_DEFAULT` | Default |

### EconomyLogCategories

CE logging categories: `economy`, `respawn_queue`, `container`, `matrix`, `uniqueloot`, `map`, `underground`, `lootable`, etc.
