Inventory UI — drag&drop менеджер предметов окружающей зоны и игрока. Источники: `gui/inventorynew/`, `gui/inventory/`, `gui/inventorymenu.c`

### Точка входа

```c
class InventoryMenu extends UIScriptedMenu
```

`InventoryMenu` — `UIScriptedMenu` обёртка (`MENU_INVENTORY`). В конструкторе создаёт `Inventory(null)`, в `Init()` подвешивает корневой widget из `Inventory.GetMainWidget()`. Открытие/закрытие — через `MissionGameplay.ShowInventory/HideInventory()` (см. [mission.md](mission.md)).

`ScreenWidthType` (`NARROW`/`MEDIUM`/`WIDE`) рассчитывается из соотношения сторон в `CheckWidth()` — определяет какой layout (`*Narrow`/`*Medium`/`*Wide`/`*Xbox`) подсунуть `m_LayoutName` в каждом контейнере.

---

### Архитектурная карта

```
InventoryMenu (UIScriptedMenu)
  └── Inventory (LayoutHolder)             ←  корневой контроллер
        ├── ItemManager                    ←  глобальное состояние drag/drop, tooltips, dropzones
        ├── ColorManager                   ←  палитра подсветки
        ├── VicinityItemManager (singleton) ← скан мира вокруг игрока
        ├── LeftArea     → VicinityContainer    (предметы рядом)
        ├── RightArea    → PlayerContainer      (одежда + карманы игрока)
        ├── HandsArea    → HandsContainer       (предмет в руках)
        ├── PlayerPreview → PlayerPreviewWidget (3D-модель персонажа)
        └── InventoryQuickbar  → m_QuickbarWidget (slots 0-9)
```

`Inventory : LayoutHolder` — singleton (`m_Instance`), владеет тремя «зонами» (`LeftArea`/`RightArea`/`HandsArea`), preview-виджетом и квикбаром. Каждая зона — `Container`, держит дерево вложенных `LayoutHolder`'ов; реальный рендер слотов и cargo делегирован `SlotsIcon`/`Icon`/`CargoContainer`.

---

### LayoutHolder

```c
class LayoutHolder extends ScriptedWidgetEventHandler
```

База всех элементов inventory UI. Хранит `m_MainWidget`/`m_RootWidget`/`m_ParentWidget` и parent reference. В конструкторе через `SetLayoutName()` подвиджеты создаются из `m_LayoutName` (имя layout'а из `WidgetLayoutName.*`).

| Метод | Описание |
|-------|----------|
| `SetLayoutName()` | Override для выбора layout (часто переключает по `ScreenWidthType`/`PLATFORM_CONSOLE`) |
| `OnShow()` / `OnHide()` / `Refresh()` | Видимость и принудительный update |
| `IsDisplayable()` | Должен ли элемент попасть в выборку (override в наследниках) |
| `InspectItem(item)` | Открыть `MENU_INSPECT` и спрятать HUD |
| `PrepareOwnedTooltip(item, x, y)` / `HideOwnedTooltip()` | Делегация в `ItemManager.PrepareTooltip` с пометкой владельца |
| `ShowActionMenu(item)` | Контекстное меню с debug actions (`ContextMenu`) |
| `OnSelectActionEx(item, actionId)` | `#ifdef DIAG_DEVELOPER` — выполнить `ActionDebug` |
| `UpdateInterval()` | Главный tick (override в наследниках) |

---

### Зоны (areas)

```
LeftArea   : Container  → m_VicinityContainer (VicinityContainer)
RightArea  : Container  → m_PlayerContainer   (PlayerContainer)
HandsArea  : Container  → HandsContainer
```

Каждая зона ловит drag&drop события на свой scroller (через `WidgetEventHandler.RegisterOnDropReceived`/`RegisterOnDraggingOver`), пересылает их единственному дочернему контейнеру. Layout зоны выбирается по `ScreenWidthType` (`LeftAreaXbox`/`Narrow`/`Medium`/`Wide`).

Навигация джойстиком: `Inventory.MoveFocusByArea(direction)` переключает активную зону, `MoveFocusByContainer(direction)` — внутри зоны.

---

### Иерархия контейнеров

```
Container : LayoutHolder
  ├── ClosableContainer            (header с кнопкой закрытия)
  │     ├── ContainerWithCargo
  │     ├── ContainerWithCargoAndAttachments
  │     │     └── ContainerWithElectricManager
  │     ├── HandsContainer         (специализация под руки)
  │     └── AttachmentCategoriesRow
  ├── CollapsibleContainer         (свёрнутый/развёрнутый header)
  │     ├── PlayerContainer        (правый — одежда+карманы)
  │     ├── VicinityContainer      (левый — мир)
  │     ├── ZombieContainer        (труп зомби в окружении)
  │     └── AttachmentCategoriesContainer
  ├── IconsContainer               (плоская сетка иконок)
  ├── SlotsContainer               (фиксированные слоты)
  ├── AttachmentsGroupContainer
  │     └── AttachmentsWrapper
  ├── HandsArea/LeftArea/RightArea (см. выше)
  ├── HandsPreview                 (preview предмета в руках)
  ├── CargoContainer               (грузовая сетка одного контейнера)
  ├── VicinitySlotsContainer
  └── AttachmentCategoriesSlotsContainer
```

`Container` хранит `m_Body : array<LayoutHolder>` (все дочерние) и `m_OpenedContainers : array<LayoutHolder>` (видимые сейчас, для focus traversal). `m_ActiveIndex` — текущий выделенный дочерний контейнер. `m_FocusedContainer` — последний навигированный.

Сортировка вложенности: константы `SORT_ATTACHMENTS_OWN = 1`, `SORT_CARGO_OWN = 2`, `SORT_ATTACHMENTS_NEXT_OFFSET = 2`, `SORT_CARGO_NEXT_OFFSET = 3` — для рекурсивного раскладывания «attachments → cargo → attachments вложенного».

---

### Атомарные элементы (containeditems)

| Класс | Layout-варианты | Роль |
|-------|-----------------|------|
| `Icon : LayoutHolder` | `IconXbox/Narrow/Medium/Wide` | Один предмет в cargo grid (картинка + quantity + temperature) |
| `SlotsIcon : LayoutHolder` | (без layout, root передаётся снаружи) | Один слот аттачмента (с ghost иконкой при пустоте) |
| `CargoContainer : Container` | `CargoContainerXbox/Narrow/Medium/Wide` | Сетка `Icon`'ов одного контейнера cargo |
| `CargoContainerRow : LayoutHolder` | `CargoContainerRowXbox/Narrow/Medium/Wide` | Одна строка `CargoContainer` (lazy-init для виртуализации) |
| `SlotsContainer : Container` | `InventorySlotsContainerXbox/...` | Группа `SlotsIcon`'ов |
| `HandsPreview : Container` | `HandsPreview` | Превью предмета в руках |

Headers (`gui/inventorynew/containeditems/headers/`) — заголовки контейнеров: `ClosableHeader` (с кнопкой), плюс варианты для player/vicinity/attachments.

---

### ItemManager

```c
class ItemManager
```

Глобальный singleton drag&drop состояния и tooltips. Создаётся в `Inventory.Inventory()` через `new ItemManager(GetMainWidget())`.

#### Состояние

| Поле | Назначение |
|------|------------|
| `m_DraggedItem` / `m_DraggedIcon` | Текущий перетаскиваемый предмет и его icon-виджет |
| `m_HoveredItem` | Под курсором |
| `m_SelectedItem` / `m_SelectedContainer` / `m_SelectedIcon` | Геймпад-фокус (console) |
| `m_TooltipWidget` / `m_TooltipSlotWidget` / `m_TooltipCategoryWidget` | Три отдельных layout'а tooltip'ов |
| `m_LeftDropzone` / `m_CenterDropzone` / `m_RightDropzone` | Подсветка зон при drag |
| `m_DefautOpenStates` / `m_DefautHeaderOpenStates` | Сохранённые свернутости контейнеров (по type-name) |
| `m_HandsDefaultOpenState` | Свёрнут ли header рук по умолчанию |
| `m_ItemMicromanagmentMode` | Режим точечного дробления стека |

#### API

| Метод | Описание |
|-------|----------|
| `SetDraggedItem(item)` / `SetDraggedIcon(icon)` / `SetIsDragging(bool)` | Начать/закончить drag |
| `SetSelectedItem/Ex(item, container, widget, icon)` | Геймпад-фокус |
| `PrepareTooltip(item, x, y)` / `ShowTooltip()` / `HideTooltip()` | Tooltip предмета (отложенный по `TOOLTIP_DELAY`) |
| `PrepareSlotsTooltip(name, desc, x, y)` / `ShowTooltipSlot()` / `HideTooltipSlot()` | Tooltip пустого слота |
| `ShowSourceDropzone(item)` / `HideDropzones()` | Подсветка валидных drop-зон |
| `SetTemperature(item, w)` / `SetIconTemperature(item, w)` | Раскрасить иконку по `ObjectTemperatureState` |
| `SetDefaultOpenState(type, bool)` / `GetDefaultOpenState(type)` | Per-type свёрнутость (сохраняется через `Serialize*`) |
| `EvaluateContainerDragabilityDefault(entity)` | Default-предикат для draggability |

`TOOLTIP_DELAY` = 0.25s на PC, 1.5s на консоли. Tooltip создаётся через `gui/layouts/inventory_new/day_z_inventory_new_tooltip*.layout`.

---

### VicinityItemManager

```c
class VicinityItemManager
```

Singleton (`s_Instance`), скан мира вокруг игрока для левой зоны. Update раз в `UPDATE_FREQUENCY = 0.25s`. Дистанции:

| Константа | Значение | Назначение |
|-----------|----------|------------|
| `VICINITY_DISTANCE` | 0.5 | Базовый радиус сбора |
| `VICINITY_ACTOR_DISTANCE` | 2.0 | Радиус для актёров (игроки/зомби) |
| `VICINITY_LARGE_ACTOR_DISTANCE` | 3.0 | Для крупных актёров |
| `VICINITY_CONE_DISTANCE` | 2.0 | Глубина cone-проверки |
| `VICINITY_CONE_ANGLE` | 30° | Угол конуса |
| `OBJECT_OBSTRUCTION_WEIGHT` | 10000g | Минимальный вес для блокировки видимости |
| `CONE_HEIGHT_MIN/MAX` | -0.5/3.0 | Вертикальные границы конуса |

| Метод | Описание |
|-------|----------|
| `GetInstance()` | Singleton accessor |
| `RefreshVicinityItems()` | Полное пересчитывание `m_VicinityItems`/`m_VicinityCargos` |
| `Update(deltaTime)` | Тик с throttle по `UPDATE_FREQUENCY` |
| `AddVicinityItems(object)` | Добавить найденную сущность (с distance check) |
| `AddVicinityCargos(cargo)` | Добавить cargo контейнер |
| `IsObstructed(object)` | Проверка перекрытия по weight + raycast |
| `CanIgnoreDistanceCheck(entity)` | Исключения для крупных объектов |

---

### InventoryQuickbar

```c
class InventoryQuickbar extends InventoryGridController
```

Hotbar 0-9. Живёт и в `Inventory` (внутри inventory menu), и в `IngameHud` (см. [hud.md](hud.md)). Обёртка над `InventoryGrid` (3_Game widget). Размер берётся из `player.GetQuickBarSize()`.

| Метод | Описание |
|-------|----------|
| `UpdateItems(quickbarGridWidget)` | Перечитать `player.GetQuickBarEntity(i)` в `m_Items` |
| `Remove(item)` | Снять с шортката |
| `OnItemDrag/Drop/DropReceived(grid, w, row, col)` | Drag&drop hooks |
| `GetQuickbarItemColor(grid, item)` | Подсветка: H_GOOD (in-hand+can-store), H_BAD, I_BAD |
| `CanAddItemInHandToInventory()` | Проверка свопа hand↔quickbar |

После любой модификации вызывает `InventoryMenu.RefreshQuickbar()`.

---

### ColorManager

```c
class ColorManager
```

Палитра подсветки drop-зон и tooltip-состояний. Singleton (`m_Instance`).

| Константа | ARGB | Назначение |
|-----------|------|------------|
| `BASE_COLOR` | 10/255/255/255 | Дефолт |
| `ITEM_BACKGROUND_COLOR` | 50/255/255/255 | Подложка иконки |
| `RED_COLOR` / `GREEN_COLOR` | 150/255/1/1, 150/1/255/1 | Запрещено / разрешено |
| `SWAP_COLOR` / `FSWAP_COLOR` | sky-blue / dark blue | Swap, force-swap |
| `COMBINE_COLOR` | 150/255/165/0 | Combine |
| `COLOR_NORMAL/HIGHLIGHT/SELECTED/DISABLED_TEXT/PANEL` | — | Стандартные состояния списков |

`SetColor(w, color)` — раскрасить виджет `Cursor` (соседний или дочерний). `GetItemColor(item)` отдаёт цвет температуры из `ObjectTemperatureState.GetStateData(temperature).m_Color`.

---

### Combination flags

```c
class InventoryCombinationFlags     // что можно сделать с парой (this, dragged)
class InventoryManipulationFlags    // что можно сделать с одиночным item
```

Битовые маски, возвращаемые `GetCombinationFlags(EntityAI other)` / `GetManipulationFlags()` на `ItemBase`. Используются Inventory UI чтобы отрисовать правильную подсветку (см. ColorManager) и hint'ы.

| InventoryCombinationFlags | Значение |
|---------------------------|----------|
| `ADD_AS_ATTACHMENT` / `ADD_AS_CARGO` | 1 / 2 |
| `SWAP` / `FSWAP` | 4 / 8 |
| `CRAFT` / `RECIPE_HANDS` / `RECIPE_ANYWHERE` | 16 / 256 / 1024 |
| `ACTIONS` / `PERFORM_ACTION` / `SET_ACTION` | 32 / 2048 / 32768 |
| `SWAP_MAGAZINE` / `LOAD_CHAMBER` / `DETACH_MAGAZINE` / `ATTACH_MAGAZINE` | 64 / 4096 / 8192 / 16384 |
| `TAKE_TO_HANDS` | 128 |
| `COMBINE_QUANTITY2` | 512 |

`InventoryManipulationFlags` — упрощённый набор для одиночных операций (`DROP=32`, `TAKE_TO_HANDS=16`, `COMBINE_QUANTITY=512`, …).

---

### SplitItemUtils

Статический хелпер для split/take операций (используется при `Ctrl+drag`).

```c
static void TakeOrSplitToInventory(player, target, item)
static void TakeOrSplitToInventoryLocation(player, dst)
```

Если влезает целиком (`stack_max >= quantity`) — `PredictiveTakeToDst`, иначе `SplitIntoStackMaxClient`.

---

### PlayerPreview

Виджет 3D-модели справа сверху. Хранит `PlayerPreviewWidget`, обрабатывает mouse drag (rotation) и wheel (scale). `RefreshPlayerPreview()` пересоздаёт preview (вызывается при изменении одежды).

---

### Console специфика

`#ifdef PLATFORM_CONSOLE` — отдельный набор виджетов:
- `m_TopConsoleToolbarVicinity/Hands/Equipment` — иконки `LB`/`RB` для переключения зон
- `m_BottomConsoleToolbar` + `ContextToolbarText` — динамический rich-text с действиями (через `InputUtils.GetRichtextButtonIconFromInputAction`)
- `ConsoleActionToolbarMask` enum — битовые флаги доступных действий (`TO_HANDS_SWAP_VICINITY`, `EQUIP`, `SPLIT`, `OPEN_CLOSE_CONTAINER`, `MICROMANAGMENT`, `QUICKSLOT`, `COMBINE`)
- `UpdateConsoleToolbar()` пересобирает текст по текущему `m_SelectedItem` + `m_SelectedContainer`
- `m_InvInputWrappers` + `InventoryMovementButtonTickHandler(timeslice)` — repeat-логика D-pad (`BT_REPEAT_DELAY = 0.35s`, `BT_REPEAT_TIME = 0.09s`)

`Inventory.MoveFocusByArea(direction)` / `MoveFocusByContainer(direction)` обходят дерево фокусом, `MoveGridCursor(direction)` — внутри grid'а активной зоны.

---

### Расширение

Чтобы добавить новый тип контейнера:

1. Наследоваться от `Container` или `ClosableContainer`/`CollapsibleContainer`.
2. В `SetLayoutName()` указать имя из `WidgetLayoutName` (объявить в 3_Game).
3. Override `IsDisplayable()`, `UpdateInterval()`, drag/drop коллбэки (`DraggingOver`/`OnDropReceived*`).
4. Зарегистрировать widget event handlers через `WidgetEventHandler.GetInstance().RegisterOn*`.
5. Если контейнер представляет EntityAI — подписаться на `GetOnItemAttached/Detached` через `Attachments` хелпер (`gui/inventorynew/attachments.c`).

Для модификации поведения слотов одного предмета — переопределить `EntityAI.CanDisplayAttachmentSlot(slotId)` / `CanDisplayCargo()` (см. [items.md](../4_World/items.md)).
