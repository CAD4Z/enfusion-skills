HUD and overlay widgets on top of the game world. Sources: `gui/`, `gui/vehicles/`, `mission/gameplayeffectwidgets/`

### Entry point

`MissionGameplay.OnInit()` creates the root widget from `gui/layouts/day_z_hud.layout` and passes sub-panels to components:

```
MissionGameplay
  ├── IngameHud         (HudPanel)          — main HUD
  ├── HudDebug          (day_z_hud_debug.layout)  — dev overlay [DEVELOPER]
  ├── ActionMenu        (ActionsPanel)      — textual action menu
  ├── Chat              (ChatFrameWidget)   — see chat.md
  ├── DebugMonitor      (day_z_debug_monitor.layout) — FPS/health monitor
  ├── Watermark         — caption on experimental builds
  └── GameplayEffectWidgets — post-effect layers (bleeding, breath, occluders)
```

Hide/show the entire HUD: `IngameHud.ShowHud(bool)`. Reaction to resize: `WindowsResizeEventTypeID` → `DestroyAllMenus() + m_Hud.OnResizeScreen()`.

---

### IngameHud

```c
class IngameHud extends Hud
```

Main layer: player stats, stance, quickbar, status/badge icons, crosshair, cursor, action icons, vehicle HUD, heat buffer, hit direction effects, walkie-talkie overlay.

#### Lifecycle

| Method | Description |
|--------|-------------|
| `Init(Widget hudPanel)` | Creates child widgets, registers `CarHud`/`BoatHud`, initializes `IngameHudVisibility`, schedules deferred `InitQuickbar` after 1s |
| `OnPlayerLoaded()` | Rebind notifiers/badges to `PlayerBase` |
| `OnResizeScreen()` | Recreate on resolution change |
| `Update(timeslice)` | Every frame: blink critical tendencies, temperature/stamina timers, hit-dir effects, vehicle HUD, heat buffer, player tags (PS4) |
| `InitHeatBufferUI(Man player)` | Lazily creates `IngameHudHeatBuffer` |

#### Stats / Notifiers / Badges

| Method | Description |
|--------|-------------|
| `DisplayNotifier(key, tendency, status)` | Update a status icon honoring tendency (normal/temp mode) |
| `DisplayBadge(key, value)` | Update a badge icon (poisoned/sick/encumbered/…) |
| `SetTemperature(string)` / `HideTemperature()` | Pop-up temperature indicator for `m_TemperatureShowTime` |
| `SetStamina(value, range)` / `SetStaminaBarVisibility(bool)` | Stamina progress bar |
| `DisplayStance(stance)` / `DisplayPresence()` | Stance and "presence" level (noise/visibility) |
| `SetStomachState(state)` | Stomach state icon |
| `UpdateBloodName()` | Blood group text |

#### Quickbar / HUD visibility API

Binary toggles for various "layers":

| Method | What it hides |
|--------|--------------|
| `ShowHud(bool)` | Everything entirely |
| `ShowHudUI(bool)` | HUD except quickbar (via options) |
| `ShowHudPlayer(bool)` | HUD except quickbar (via hotkey) |
| `ShowHudInventory(bool)` | HUD when opening the inventory |
| `ShowQuickbarUI(bool)` / `ShowQuickbarPlayer(bool)` / `ShowQuickBar(bool)` | Different quickbar layers |
| `UpdateQuickbarGlobalVisibility()` | Platform-dependent visibility |
| `RefreshQuickbar(itemChanged)` | Reload content |

Internally delegates to `IngameHudVisibility` via context flags.

#### Crosshair / Cursor / Actions

| Method | Description |
|--------|-------------|
| `SetPermanentCrossHair(bool)` | Always-on crosshair |
| `ShowCursor()` / `HideCursor()` / `SetCursorIcon(icon)` | Active interaction cursor |
| `SetCursorIconScale/Offset/Size(type, …)` | Cursor parameters |
| `ZeroingKeyPress()` | Fade in the zeroing indicator |
| `ShowVehicleInfo()` / `HideVehicleInfo()` | Open/close the vehicle HUD |
| `SpawnHitDirEffect(player, dir, intensity)` | Damage hit indicator (directional) |
| `SetConnectivityStatIcon(type, level)` | High ping / low server perf / connection lost icon |

#### Vehicle HUD (inside IngameHud)

`IngameHud` keeps `m_VehicleHudMap : map<string, ref VehicleHudBase>`. In `Init` it registers:

```
"VehicleTypeCar"  → CarHud   (gui/layouts/day_z_hud_cars.layout)
"VehicleTypeBoat" → BoatHud
```

`ShowVehicleInfo()` looks up the type via `HumanCommandVehicle`, activates `m_ActiveVehicleHUD`, `RefreshVehicleHud(timeslice)` updates it every frame.

```c
class VehicleHudBase : Managed
```

| Method | Description |
|--------|-------------|
| `Init(vehicleHudPanels)` | Create the layout for this type |
| `ShowVehicleInfo(player)` / `HideVehicleInfo()` | On boarding/disembark |
| `ShowPanel()` / `HidePanel()` | Toggle visibility |
| `RefreshVehicleHud(timeslice)` | Update dials |

`CarHud`: RPM pointer/dial/redline, speed pointer, gear indicators (`m_VehicleGearTable`/`m_VehicleGearTableAuto` — manual/automatic transmission), temperature, fuel, lamps (battery/engine/oil/handbrake/wheel).

`BoatHud`: simplified set — speed, RPM, fuel, lamps.

---

### IngameHudVisibility

```c
class IngameHudVisibility : Managed
```

Manager for HUD element group visibility via context bit flags. Replaces a sprawling set of disjoint `Show(bool)` calls.

#### EHudElement (widgets)

`LHUD_PRESENCE`, `LHUD_STANCE`, `LHUD_PLAYER`, `LHUD_VEHICLE`, `RHUD_BADGES`, `RHUD_DIVIDER`, `RHUD_NOTIFIERS`, `QUICKBAR`.

#### EHudContextFlags (rules)

| Flag | Value | Effect |
|------|-------|--------|
| `HUD_DISABLE` | 1 | Disabled in options |
| `HUD_HIDE` | 2 | Hidden by hotkey |
| `VEHICLE_DISABLE` | 4 | Vehicle HUD off in options |
| `DRIVER` | 8 | Player is the driver (show veh HUD) |
| `VEHICLE` | 16 | In a vehicle (hide left stats) |
| `MENU_OPEN` | 32 | A menu is open |
| `NO_BADGE` | 64 | No badges (hide divider) |
| `QUICKBAR_DISABLE/HIDE/GLOBAL` | 128/256/512 | Quickbar layers |
| `INVENTORY_OPEN` | 1024 | Inventory open (HUD always visible) |
| `UNCONSCIOUS` | 2048 | Unconscious |

#### API

```c
void SetContextFlag(EHudContextFlags flag, bool state)
bool IsElementVisible(EHudElement element)
bool IsContextFlagActive(EHudContextFlags flag)
```

Setting a flag automatically recalculates all linked elements via `m_ElementLinkMap`.

---

### IngameHudHeatBuffer

```c
class IngameHudHeatBuffer
```

"Heat buffer" indicator (heat accumulated from clothing). Blinks in stages from `m_FlashingThresholds` (1: 0.002, 2: 0.332, 3: 0.662). Stopped on `OnDeathStart`/`OnUnconsciousStart`, resumed on `OnUnconsciousStop`. Update is called from `IngameHud.Update` via `CanUpdate()`.

---

### HudDebug

```c
class HudDebug extends Hud
```

Dev overlay `#ifdef DEVELOPER`. Container of "windows" (`HudDebugWinBase`), registered in `Init` from widgets in `day_z_hud_debug.layout`.

| HUD_WIN_* | Window |
|-----------|--------|
| `CHAR_STATS` | Character stats (hydration, energy, blood, heat, …) |
| `CHAR_MODIFIERS` | Active modifiers |
| `CHAR_AGENTS` | Agents (bacteria/viruses) |
| `CHAR_DEBUG` | Debug values |
| `CHAR_LEVELS` | Stat levels |
| `CHAR_STOMACH` | Stomach contents |
| `VERSION` | Build version |
| `TEMPERATURE` | Body/environment temperature |
| `HEALTH` | Health by zones |
| `HORTICULTURE` | Plant state |

Visibility of each window is stored in `PluginConfigDebugProfile` → `RefreshByLocalProfile()`. Updates of all visible windows on a one-second timer.

---

### DebugMonitor

```c
class DebugMonitor
```

Separate monitor on top of the HUD (`gui/layouts/debug/day_z_debug_monitor.layout`). Enabled via `g_Game.SetDebugMonitorEnabled` (server parameter `enableDebugMonitor`). Created via `MissionGameplay.CreateDebugMonitor()`, updated from `MissionGameplay.UpdateDebugMonitor()`.

Displays: version, health, blood, last damage source, map tile (A1/A2/…), position (copy to clipboard via `UAUICopyDebugMonitorPos`), FPS (current/min/max/avg with platform-dependent color grading).

---

### ItemActionsWidget

Bottom-right widget with action hints. Driven by a `widget script` (`ScriptedWidgetEventHandler`), self-updates every frame through the `CALL_CATEGORY_GUI` update queue. Reads the player's `ActionManagerClient`, displays `Interact`/`ContinuousInteract`/`Single`/`Continuous` actions in hands, manages fade via `m_FadeTimer`. Button icons are substituted via `InputUtils.GetRichtextButtonIconFromInputAction` to match the current input device.

---

### ActionMenu

```c
class ActionMenu
```

Textual menu of cyclable actions (below ItemActionsWidget). Only active `#ifdef DIAG_DEVELOPER` (new AT selection). Initialized in `MissionGameplay.OnInit` with widgets `ActionsPanel` and `DefaultActionWidget`. `NextAction/PrevAction/NextActionCategory/PrevActionCategory` → `player.GetActionManager().Select*`. Auto-hides via `HIDE_MENU_TIME = 5s`.

---

### Crosshair / Action targets cursor

| Class | Role |
|-------|------|
| `CrossHairSelector` | Handler for the widget from XML, switches the crosshair set (`set<ref CrossHair>`) based on player/weapon state. Updates via `PostUpdateQueue(CALL_CATEGORY_GUI)` |
| `ProjectedCrosshair` | Auxiliary crosshair for weapon debug (`DiagMenuIDs.WEAPON_DEBUG`) |
| `ActionTargetsCursor` | Cursor of the action target + tooltip on the right. Caches the object via `ATCCachedObject`. Honors PPE vision obstructions (burlap sack, flashbang) |
| `ContinuousActionProgress` | Circular progress bar around the cursor for continuous actions. Suppressed if `HUD_HIDE_FLAGS` are active |

---

### Map markers / Object follower

`MapMarkerTypes` — static registry of icons for map locations (`eMapMarkerTypes`: `BORDER_CROSS`, `BROADLEAF`, `CAMP`, `FACTORY`, `FIR`, `FIREDEP`, `GOVOFFICE`, `HILL`, `MONUMENT`, `PALM`, `POLICE`, `STATION`, `STORE`, `TOURISM`, `TRANSMITTER`, `TSHELTER`, `TSIGN`, `VIEWPOINT`, `VINEYARD`, `WATERPUMP`). Initialized in `MissionGameplay.OnInit` via `MapMarkerTypes.Init()`.

`ObjectFollower` — widget that follows an `Object` in screen coordinates (used for markers and labels).

---

### InventoryQuickbar

Hotbar 0-9 slots lives in `IngameHud` (`m_Quickbar`), initialized via a deferred `InitQuickbar()` from `IngameHud.Init`. Visibility is controlled by `IngameHudVisibility` (`EHudElement.QUICKBAR`, flags `QUICKBAR_*`). For details of the container UI — see [inventory.md](inventory.md) Quickbar section.

---

### GameplayEffectWidgets

```c
class GameplayEffectWidgets extends GameplayEffectWidgets_base
```

Host for overlay effects on top of the screen. Instance in `MissionGameplay.m_EffectWidgets`, accessible via `GetMission().GetEffectWidgets()`. Main entry API — `AddActiveEffects(array<int>)` / `RemoveActiveEffects(array<int>)`.

#### Registered layouts

In `InitLayouts`:
- `gui/layouts/gameplay/CameraEffects.layout` — occluders, breath, flashbang cover
- `gui/layouts/gameplay/BleedingEffects.layout` — bleeding indicator layer

#### Widget sets (EffectWidgetsTypes)

| Group | Types |
|-------|-------|
| **Breath** | `MASK_BREATH`, `HELMET_BREATH`, `MOTO_BREATH` — share `WIDGETSET_BREATH` |
| **Occluders** | `MASK_OCCLUDER`, `HELMET_OCCLUDER`, `HELMET2_OCCLUDER`, `MOTO_OCCLUDER`, `NVG_OCCLUDER`, `PUMPKIN_OCCLUDER` (alias `NVG_OCCLUDER`), `EYEPATCH_OCCLUDER` |
| **Cover** | `COVER_FLASHBANG` |
| **Bleeding** | `BLEEDING_LAYER` (specialized handler via `GameplayEffectsDataBleeding`) |

#### API

| Method | Description |
|--------|-------------|
| `AddActiveEffects(effects)` | Activate the listed IDs |
| `RemoveActiveEffects(effects)` | Deactivate |
| `StopAllEffects()` | Turn everything off |
| `IsAnyEffectRunning()` | Whether anything is active |
| `AddSuspendRequest(request_id)` / `RemoveSuspendRequest` / `ClearSuspendRequests` / `GetSuspendRequestCount` | Suspend drawing (without removing) |
| `UpdateWidgets(type, timeSlice, p, handle)` | Update a specific type/handle |
| `Update(timeSlice)` | Common tick (calls breath, progress, bleeding) |
| `SetBreathIntensityStamina(cap, current)` | Breath intensity from stamina |
| `OnVoiceEvent(breathing_resistance)` | Voice chat hook |
| `RegisterGameplayEffectData(id, p)` | Register data for an effect ID |

Metadata classes: `GameplayEffectsData` (base) → `GameplayEffectsDataImage` (for ImageWidget with original colors) → `GameplayEffectsDataBleeding` (specialization). Data type is resolved via `m_IDToTypeMap : map<int,typename>`.

#### BleedingIndicator

```c
class BleedingIndicator extends Managed
```

One wrapper per bleeding source. Stores severity (`LOW`/`MEDIUM`/`HIGH`), probability array, spawn timings, active drops (`BleedingIndicatorDropData`). Managed by `GameplayEffectsDataBleeding` (overrides the parent's `Update`) — adds/removes `BleedingIndicator` when `BleedingSourcesManagerRemote` changes.
