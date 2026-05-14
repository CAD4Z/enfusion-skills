Inventory UI — drag&drop manager for items in the surrounding area and on the player. Sources: `gui/inventorynew/`, `gui/inventory/`, `gui/inventorymenu.c`

### Entry point

```c
class InventoryMenu extends UIScriptedMenu
```

`InventoryMenu` is a `UIScriptedMenu` wrapper (`MENU_INVENTORY`). The constructor creates `Inventory(null)`, and `Init()` mounts the root widget from `Inventory.GetMainWidget()`. Open/close — via `MissionGameplay.ShowInventory/HideInventory()` (see [mission.md](mission.md)).

`ScreenWidthType` (`NARROW`/`MEDIUM`/`WIDE`) is computed from the aspect ratio in `CheckWidth()` — it determines which layout (`*Narrow`/`*Medium`/`*Wide`/`*Xbox`) to feed `m_LayoutName` in each container.

---

### Architecture map

```
InventoryMenu (UIScriptedMenu)
  └── Inventory (LayoutHolder)             ←  root controller
        ├── ItemManager                    ←  global drag/drop state, tooltips, dropzones
        ├── ColorManager                   ←  highlight palette
        ├── VicinityItemManager (singleton) ← scan of the world around the player
        ├── LeftArea     → VicinityContainer    (nearby items)
        ├── RightArea    → PlayerContainer      (player's clothes + pockets)
        ├── HandsArea    → HandsContainer       (item in hands)
        ├── PlayerPreview → PlayerPreviewWidget (3D character model)
        └── InventoryQuickbar  → m_QuickbarWidget (slots 0-9)
```

`Inventory : LayoutHolder` is a singleton (`m_Instance`) that owns three "areas" (`LeftArea`/`RightArea`/`HandsArea`), the preview widget, and the quickbar. Each area is a `Container` holding a tree of nested `LayoutHolder`s; actual rendering of slots and cargo is delegated to `SlotsIcon`/`Icon`/`CargoContainer`.

---

### LayoutHolder

```c
class LayoutHolder extends ScriptedWidgetEventHandler
```

Base of all inventory UI elements. Holds `m_MainWidget`/`m_RootWidget`/`m_ParentWidget` and a parent reference. In the constructor, sub-widgets are created from `m_LayoutName` (a layout name from `WidgetLayoutName.*`) via `SetLayoutName()`.

| Method | Description |
|--------|-------------|
| `SetLayoutName()` | Override to choose the layout (often switches by `ScreenWidthType`/`PLATFORM_CONSOLE`) |
| `OnShow()` / `OnHide()` / `Refresh()` | Visibility and forced update |
| `IsDisplayable()` | Whether the element should be included in selection (overridden in subclasses) |
| `InspectItem(item)` | Open `MENU_INSPECT` and hide the HUD |
| `PrepareOwnedTooltip(item, x, y)` / `HideOwnedTooltip()` | Delegation to `ItemManager.PrepareTooltip` with owner marking |
| `ShowActionMenu(item)` | Context menu with debug actions (`ContextMenu`) |
| `OnSelectActionEx(item, actionId)` | `#ifdef DIAG_DEVELOPER` — execute `ActionDebug` |
| `UpdateInterval()` | Main tick (overridden in subclasses) |

---

### Areas

```
LeftArea   : Container  → m_VicinityContainer (VicinityContainer)
RightArea  : Container  → m_PlayerContainer   (PlayerContainer)
HandsArea  : Container  → HandsContainer
```

Each area catches drag&drop events on its scroller (via `WidgetEventHandler.RegisterOnDropReceived`/`RegisterOnDraggingOver`) and forwards them to its sole child container. The area layout is selected by `ScreenWidthType` (`LeftAreaXbox`/`Narrow`/`Medium`/`Wide`).

Joystick navigation: `Inventory.MoveFocusByArea(direction)` switches the active area, `MoveFocusByContainer(direction)` — within the area.

---

### Container hierarchy

```
Container : LayoutHolder
  ├── ClosableContainer            (header with a close button)
  │     ├── ContainerWithCargo
  │     ├── ContainerWithCargoAndAttachments
  │     │     └── ContainerWithElectricManager
  │     ├── HandsContainer         (specialization for hands)
  │     └── AttachmentCategoriesRow
  ├── CollapsibleContainer         (collapsible/expandable header)
  │     ├── PlayerContainer        (right — clothing+pockets)
  │     ├── VicinityContainer      (left — world)
  │     ├── ZombieContainer        (zombie corpse in the surroundings)
  │     └── AttachmentCategoriesContainer
  ├── IconsContainer               (flat grid of icons)
  ├── SlotsContainer               (fixed slots)
  ├── AttachmentsGroupContainer
  │     └── AttachmentsWrapper
  ├── HandsArea/LeftArea/RightArea (see above)
  ├── HandsPreview                 (preview of the item in hands)
  ├── CargoContainer               (cargo grid of one container)
  ├── VicinitySlotsContainer
  └── AttachmentCategoriesSlotsContainer
```

`Container` holds `m_Body : array<LayoutHolder>` (all children) and `m_OpenedContainers : array<LayoutHolder>` (currently visible, for focus traversal). `m_ActiveIndex` is the currently selected child container. `m_FocusedContainer` is the last one navigated to.

Nesting ordering: constants `SORT_ATTACHMENTS_OWN = 1`, `SORT_CARGO_OWN = 2`, `SORT_ATTACHMENTS_NEXT_OFFSET = 2`, `SORT_CARGO_NEXT_OFFSET = 3` — for recursive layout of "attachments → cargo → attachments of nested item".

---

### Atomic elements (containeditems)

| Class | Layout variants | Role |
|-------|-----------------|------|
| `Icon : LayoutHolder` | `IconXbox/Narrow/Medium/Wide` | One item in a cargo grid (image + quantity + temperature) |
| `SlotsIcon : LayoutHolder` | (no layout, root passed in externally) | One attachment slot (with a ghost icon when empty) |
| `CargoContainer : Container` | `CargoContainerXbox/Narrow/Medium/Wide` | Grid of `Icon`s for one cargo container |
| `CargoContainerRow : LayoutHolder` | `CargoContainerRowXbox/Narrow/Medium/Wide` | One row of `CargoContainer` (lazy-init for virtualization) |
| `SlotsContainer : Container` | `InventorySlotsContainerXbox/...` | Group of `SlotsIcon`s |
| `HandsPreview : Container` | `HandsPreview` | Preview of the item in hands |

Headers (`gui/inventorynew/containeditems/headers/`) — container headers: `ClosableHeader` (with a button), plus variants for player/vicinity/attachments.

---

### ItemManager

```c
class ItemManager
```

Global singleton for drag&drop state and tooltips. Created in `Inventory.Inventory()` via `new ItemManager(GetMainWidget())`.

#### State

| Field | Purpose |
|-------|---------|
| `m_DraggedItem` / `m_DraggedIcon` | The currently dragged item and its icon widget |
| `m_HoveredItem` | Item under the cursor |
| `m_SelectedItem` / `m_SelectedContainer` / `m_SelectedIcon` | Gamepad focus (console) |
| `m_TooltipWidget` / `m_TooltipSlotWidget` / `m_TooltipCategoryWidget` | Three separate tooltip layouts |
| `m_LeftDropzone` / `m_CenterDropzone` / `m_RightDropzone` | Zone highlight while dragging |
| `m_DefautOpenStates` / `m_DefautHeaderOpenStates` | Saved collapse state for containers (by type name) |
| `m_HandsDefaultOpenState` | Whether the hands header is collapsed by default |
| `m_ItemMicromanagmentMode` | Fine-grained stack splitting mode |

#### API

| Method | Description |
|--------|-------------|
| `SetDraggedItem(item)` / `SetDraggedIcon(icon)` / `SetIsDragging(bool)` | Start/end drag |
| `SetSelectedItem/Ex(item, container, widget, icon)` | Gamepad focus |
| `PrepareTooltip(item, x, y)` / `ShowTooltip()` / `HideTooltip()` | Item tooltip (deferred by `TOOLTIP_DELAY`) |
| `PrepareSlotsTooltip(name, desc, x, y)` / `ShowTooltipSlot()` / `HideTooltipSlot()` | Tooltip for an empty slot |
| `ShowSourceDropzone(item)` / `HideDropzones()` | Highlight valid drop zones |
| `SetTemperature(item, w)` / `SetIconTemperature(item, w)` | Color the icon by `ObjectTemperatureState` |
| `SetDefaultOpenState(type, bool)` / `GetDefaultOpenState(type)` | Per-type collapse state (saved via `Serialize*`) |
| `EvaluateContainerDragabilityDefault(entity)` | Default predicate for draggability |

`TOOLTIP_DELAY` = 0.25s on PC, 1.5s on console. Tooltips are created from `gui/layouts/inventory_new/day_z_inventory_new_tooltip*.layout`.

---

### VicinityItemManager

```c
class VicinityItemManager
```

Singleton (`s_Instance`), scans the world around the player for the left area. Update every `UPDATE_FREQUENCY = 0.25s`. Distances:

| Constant | Value | Purpose |
|----------|-------|---------|
| `VICINITY_DISTANCE` | 0.5 | Base collection radius |
| `VICINITY_ACTOR_DISTANCE` | 2.0 | Radius for actors (players/zombies) |
| `VICINITY_LARGE_ACTOR_DISTANCE` | 3.0 | For large actors |
| `VICINITY_CONE_DISTANCE` | 2.0 | Depth of the cone check |
| `VICINITY_CONE_ANGLE` | 30° | Cone angle |
| `OBJECT_OBSTRUCTION_WEIGHT` | 10000g | Minimum weight to block visibility |
| `CONE_HEIGHT_MIN/MAX` | -0.5/3.0 | Vertical bounds of the cone |

| Method | Description |
|--------|-------------|
| `GetInstance()` | Singleton accessor |
| `RefreshVicinityItems()` | Full recompute of `m_VicinityItems`/`m_VicinityCargos` |
| `Update(deltaTime)` | Tick with throttle by `UPDATE_FREQUENCY` |
| `AddVicinityItems(object)` | Add a found entity (with distance check) |
| `AddVicinityCargos(cargo)` | Add a cargo container |
| `IsObstructed(object)` | Visibility blocking check by weight + raycast |
| `CanIgnoreDistanceCheck(entity)` | Exceptions for large objects |

---

### InventoryQuickbar

```c
class InventoryQuickbar extends InventoryGridController
```

Hotbar 0-9. Lives both in `Inventory` (inside the inventory menu) and in `IngameHud` (see [hud.md](hud.md)). Wrapper over `InventoryGrid` (3_Game widget). Size is taken from `player.GetQuickBarSize()`.

| Method | Description |
|--------|-------------|
| `UpdateItems(quickbarGridWidget)` | Re-read `player.GetQuickBarEntity(i)` into `m_Items` |
| `Remove(item)` | Remove from the shortcut |
| `OnItemDrag/Drop/DropReceived(grid, w, row, col)` | Drag&drop hooks |
| `GetQuickbarItemColor(grid, item)` | Highlight: H_GOOD (in-hand+can-store), H_BAD, I_BAD |
| `CanAddItemInHandToInventory()` | Hand↔quickbar swap check |

After any modification calls `InventoryMenu.RefreshQuickbar()`.

---

### ColorManager

```c
class ColorManager
```

Palette for drop-zone highlights and tooltip states. Singleton (`m_Instance`).

| Constant | ARGB | Purpose |
|----------|------|---------|
| `BASE_COLOR` | 10/255/255/255 | Default |
| `ITEM_BACKGROUND_COLOR` | 50/255/255/255 | Icon backdrop |
| `RED_COLOR` / `GREEN_COLOR` | 150/255/1/1, 150/1/255/1 | Forbidden / allowed |
| `SWAP_COLOR` / `FSWAP_COLOR` | sky-blue / dark blue | Swap, force-swap |
| `COMBINE_COLOR` | 150/255/165/0 | Combine |
| `COLOR_NORMAL/HIGHLIGHT/SELECTED/DISABLED_TEXT/PANEL` | — | Standard list states |

`SetColor(w, color)` — color the `Cursor` widget (sibling or child). `GetItemColor(item)` returns the temperature color from `ObjectTemperatureState.GetStateData(temperature).m_Color`.

---

### Combination flags

```c
class InventoryCombinationFlags     // what can be done with a pair (this, dragged)
class InventoryManipulationFlags    // what can be done with a single item
```

Bit masks returned by `GetCombinationFlags(EntityAI other)` / `GetManipulationFlags()` on `ItemBase`. Used by the Inventory UI to draw the correct highlight (see ColorManager) and hints.

| InventoryCombinationFlags | Value |
|---------------------------|-------|
| `ADD_AS_ATTACHMENT` / `ADD_AS_CARGO` | 1 / 2 |
| `SWAP` / `FSWAP` | 4 / 8 |
| `CRAFT` / `RECIPE_HANDS` / `RECIPE_ANYWHERE` | 16 / 256 / 1024 |
| `ACTIONS` / `PERFORM_ACTION` / `SET_ACTION` | 32 / 2048 / 32768 |
| `SWAP_MAGAZINE` / `LOAD_CHAMBER` / `DETACH_MAGAZINE` / `ATTACH_MAGAZINE` | 64 / 4096 / 8192 / 16384 |
| `TAKE_TO_HANDS` | 128 |
| `COMBINE_QUANTITY2` | 512 |

`InventoryManipulationFlags` — a simplified set for single-item operations (`DROP=32`, `TAKE_TO_HANDS=16`, `COMBINE_QUANTITY=512`, …).

---

### SplitItemUtils

Static helper for split/take operations (used on `Ctrl+drag`).

```c
static void TakeOrSplitToInventory(player, target, item)
static void TakeOrSplitToInventoryLocation(player, dst)
```

If it fits entirely (`stack_max >= quantity`) — `PredictiveTakeToDst`; otherwise `SplitIntoStackMaxClient`.

---

### PlayerPreview

3D model widget in the top right. Holds `PlayerPreviewWidget`, handles mouse drag (rotation) and wheel (scale). `RefreshPlayerPreview()` recreates the preview (called when clothing changes).

---

### Console specifics

`#ifdef PLATFORM_CONSOLE` — a separate set of widgets:
- `m_TopConsoleToolbarVicinity/Hands/Equipment` — `LB`/`RB` icons for switching areas
- `m_BottomConsoleToolbar` + `ContextToolbarText` — dynamic rich-text with actions (via `InputUtils.GetRichtextButtonIconFromInputAction`)
- `ConsoleActionToolbarMask` enum — bit flags for available actions (`TO_HANDS_SWAP_VICINITY`, `EQUIP`, `SPLIT`, `OPEN_CLOSE_CONTAINER`, `MICROMANAGMENT`, `QUICKSLOT`, `COMBINE`)
- `UpdateConsoleToolbar()` rebuilds text from the current `m_SelectedItem` + `m_SelectedContainer`
- `m_InvInputWrappers` + `InventoryMovementButtonTickHandler(timeslice)` — D-pad repeat logic (`BT_REPEAT_DELAY = 0.35s`, `BT_REPEAT_TIME = 0.09s`)

`Inventory.MoveFocusByArea(direction)` / `MoveFocusByContainer(direction)` traverse the tree by focus, `MoveGridCursor(direction)` — within the grid of the active area.

---

### Extension

To add a new container type:

1. Subclass `Container` or `ClosableContainer`/`CollapsibleContainer`.
2. In `SetLayoutName()` specify a name from `WidgetLayoutName` (declared in 3_Game).
3. Override `IsDisplayable()`, `UpdateInterval()`, drag/drop callbacks (`DraggingOver`/`OnDropReceived*`).
4. Register widget event handlers via `WidgetEventHandler.GetInstance().RegisterOn*`.
5. If the container represents an EntityAI — subscribe to `GetOnItemAttached/Detached` via the `Attachments` helper (`gui/inventorynew/attachments.c`).

To modify the behavior of a single item's slots — override `EntityAI.CanDisplayAttachmentSlot(slotId)` / `CanDisplayCargo()` (see [items.md](../4_World/items.md)).
