`4_World` — systems. Inventory, temperature, catching, recipes, emotes, VirtualHud. Sources: `systems/`, `classes/recipes/`, `classes/emoteclasses/`, `classes/virtualhud/`

### Inventory (DayZPlayerInventory)

`DayZPlayerInventory extends HumanInventoryWithFSM`. Adds an animated Hand FSM, deferred events, and server-side validation on top of `HumanInventory` from 3_Game.

#### Synchronization

```
Client → StoreInputUserData → [network] → ProcessInputData
 → Validation (src/dst distance, juncture lock, LocationCanMoveEntity)
 → Execute or juncture wait
```

Five `DeferredEvent` subclasses for atomic slot reservations during predictive operations.

#### AttachmentsOutOfReach

Reach validation via memory points or LOD selections. XZ and Y are checked independently.

---

### Temperature sources (UniversalTemperatureSource)

`UTemperatureSource` — a heat-source object near entities.

#### How it works

`UniversalTemperatureSourceLambdaBaseImpl.Execute()`:
1. AABB box query → filter by sphere
2. Dry items (coefficient inversely proportional to distance)
3. Heat entities recursively through the full inventory/attachments
4. `HeatPermeabilityCoef` is applied at every level

---

### Animal catching (AnimalCatchingSystem)

Sources: `systems/animalcatchingsystem/`

#### Fishing rod

- Signaling cycles with Poisson-like probability (EaseInExpo)
- Synchronized RNG
- Hook/bait loss on miss

#### Traps

- Bernoulli formula: `P = 1 - (1 - cumulative)^(1/N)` per attempt
- Bait sensitivity per animal type

#### Yield Items

Carry 24-element arrays of coefficients by hour of day (time-of-day fishing rates).

---

### Recipes

Sources: `classes/recipes/`

Max 2 ingredients, 10 results. `CheckIngredientMatch` uses `IsKindOf` to walk the type hierarchy.

Per-ingredient and per-result arrays for: health, quantity, destroy, softskills flags.

---

### Emotes (EmoteClasses)

Sources: `classes/emoteclasses/`

`EmoteBase` — emote base class.

| Method | Description |
|-------|----------|
| `DetermineOverride(out int, out int)` | Override the animation based on context |
| `CanBeCanceledNormally()` | Whether it can be cancelled normally |

Additive vs fullbody is determined via stance masks.

---

### VirtualHud

Sources: `classes/virtualhud/`

Server-side system → RPC to client. The server computes a bitmask of changed elements.

| Element | Type |
|---------|-----|
| `DELM_TDCY_*` | Tendency (arrows) |
| `DELM_BADGE_*` | Badges (icons) |
| `STANCE`, `BLEEDING` | Client only |

16 elements, 2 INT masks. `DSLevels` → HUD state codes 1–5.

---

### Bleeding (BleedingSources)

Sources: `classes/bleedingsources/`

28 zones across all skeleton bones, bound to inventory slots (BODY, LEGS, FEET, GLOVES, HEADGEAR, MASK).

Per-player bitmask (`GetBleedingBits()`), max 32 zones. `CONTAMINATED` type multiplies flow by `BURN_MODIFIER`. Removing a source → infection chance roll.

---

### Contaminated areas (ContaminatedArea)

Sources: `classes/contaminatedarea/`

Dynamic zones: projectile flight-time simulation (`distance / 100 + 20s`), spawn `Grenade_ChemGas` on creation, `ShellLight` (0.15s flash).

---

### Effects (misc)

- **Flashbang**: 8s duration, 2.5s breakpoint, PPE + delayed sound 0.4s, day/night intensity
- **HitDirection**: positioning along the screen edge (sin/cos), SmoothCD smoothing
- **Sound handlers**: stamina, hunger, thirst, injury — injury adapts the zone based on stance and speed

---

### Bot (testing)

Sources: `systems/bot/`

Developer tool. FSM-driven, controlled via `EActions.PLAYER_BOT_*`. Only with `#define BOT_DEBUG`. Not present in release builds.
