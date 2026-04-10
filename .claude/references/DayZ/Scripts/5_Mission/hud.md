HUD и оверлейные виджеты поверх игрового мира. Источники: `gui/`, `gui/vehicles/`, `mission/gameplayeffectwidgets/`

### Точка входа

`MissionGameplay.OnInit()` создаёт корневой widget из `gui/layouts/day_z_hud.layout` и передаёт подпанели компонентам:

```
MissionGameplay
  ├── IngameHud         (HudPanel)          — главный HUD
  ├── HudDebug          (day_z_hud_debug.layout)  — dev-оверлей [DEVELOPER]
  ├── ActionMenu        (ActionsPanel)      — текстовое меню действий
  ├── Chat              (ChatFrameWidget)   — см. chat.md
  ├── DebugMonitor      (day_z_debug_monitor.layout) — FPS/health monitor
  ├── Watermark         — надпись на experimental сборках
  └── GameplayEffectWidgets — слои пост-эффектов (bleeding, breath, occluders)
```

Скрытие/показ всего HUD: `IngameHud.ShowHud(bool)`. Реакция на ресайз: `WindowsResizeEventTypeID` → `DestroyAllMenus() + m_Hud.OnResizeScreen()`.

---

### IngameHud

```c
class IngameHud extends Hud
```

Главный слой: stats игрока, stance, quickbar, иконки статусов/бейджей, crosshair, cursor, action icons, vehicle HUD, heat buffer, hit direction effects, walkie-talkie overlay.

#### Жизненный цикл

| Метод | Описание |
|-------|----------|
| `Init(Widget hudPanel)` | Создаёт дочерние виджеты, регистрирует `CarHud`/`BoatHud`, инициализирует `IngameHudVisibility`, запускает отложенный `InitQuickbar` через 1с |
| `OnPlayerLoaded()` | Перепривязка notifiers/badges к `PlayerBase` |
| `OnResizeScreen()` | Пересоздание на смену разрешения |
| `Update(timeslice)` | Каждый кадр: blink критических tendencies, таймеры temperature/stamina, hit-dir effects, vehicle HUD, heat buffer, player tags (PS4) |
| `InitHeatBufferUI(Man player)` | Лениво создаёт `IngameHudHeatBuffer` |

#### Stats / Notifiers / Badges

| Метод | Описание |
|-------|----------|
| `DisplayNotifier(key, tendency, status)` | Обновить иконку статуса с учётом tendency (normal/temp режим) |
| `DisplayBadge(key, value)` | Обновить иконку бейджа (poisoned/sick/encumbered/…) |
| `SetTemperature(string)` / `HideTemperature()` | Всплывающая индикация температуры на `m_TemperatureShowTime` |
| `SetStamina(value, range)` / `SetStaminaBarVisibility(bool)` | Прогресс-бар выносливости |
| `DisplayStance(stance)` / `DisplayPresence()` | Поза и уровень «presence» (шум/видимость) |
| `SetStomachState(state)` | Иконка состояния желудка |
| `UpdateBloodName()` | Текст группы крови |

#### Quickbar / HUD visibility API

Бинарные toggles для разных «слоёв»:

| Метод | Что скрывает |
|-------|--------------|
| `ShowHud(bool)` | Всё целиком |
| `ShowHudUI(bool)` | HUD кроме quickbar (через опции) |
| `ShowHudPlayer(bool)` | HUD кроме quickbar (через hotkey) |
| `ShowHudInventory(bool)` | HUD при открытии инвентаря |
| `ShowQuickbarUI(bool)` / `ShowQuickbarPlayer(bool)` / `ShowQuickBar(bool)` | Разные layers квикбара |
| `UpdateQuickbarGlobalVisibility()` | Платформозависимая видимость |
| `RefreshQuickbar(itemChanged)` | Перезагрузка содержимого |

Внутри делегирует в `IngameHudVisibility` через context-флаги.

#### Crosshair / Cursor / Actions

| Метод | Описание |
|-------|----------|
| `SetPermanentCrossHair(bool)` | Вечный crosshair |
| `ShowCursor()` / `HideCursor()` / `SetCursorIcon(icon)` | Активный курсор взаимодействия |
| `SetCursorIconScale/Offset/Size(type, …)` | Параметры курсора |
| `ZeroingKeyPress()` | Fade индикатора zeroing |
| `ShowVehicleInfo()` / `HideVehicleInfo()` | Открыть/закрыть vehicle HUD |
| `SpawnHitDirEffect(player, dir, intensity)` | Индикатор получения урона (направленный) |
| `SetConnectivityStatIcon(type, level)` | Иконка high ping / low server perf / connection lost |

#### Vehicle HUD (внутри IngameHud)

`IngameHud` держит `m_VehicleHudMap : map<string, ref VehicleHudBase>`. В `Init` регистрируются:

```
"VehicleTypeCar"  → CarHud   (gui/layouts/day_z_hud_cars.layout)
"VehicleTypeBoat" → BoatHud
```

`ShowVehicleInfo()` ищет тип по `HumanCommandVehicle`, активирует `m_ActiveVehicleHUD`, `RefreshVehicleHud(timeslice)` обновляет его раз в кадр.

```c
class VehicleHudBase : Managed
```

| Метод | Описание |
|-------|----------|
| `Init(vehicleHudPanels)` | Создать layout под этот тип |
| `ShowVehicleInfo(player)` / `HideVehicleInfo()` | При посадке/выходе |
| `ShowPanel()` / `HidePanel()` | Переключение видимости |
| `RefreshVehicleHud(timeslice)` | Обновление dial'ов |

`CarHud`: RPM pointer/dial/redline, speed pointer, gear indicators (`m_VehicleGearTable`/`m_VehicleGearTableAuto` — ручная/автоматическая КПП), температура, топливо, лампы (battery/engine/oil/handbrake/wheel).

`BoatHud`: упрощённый набор — скорость, RPM, топливо, лампы.

---

### IngameHudVisibility

```c
class IngameHudVisibility : Managed
```

Менеджер видимости групп HUD-элементов по битовым флагам контекста. Заменяет множество разрозненных `Show(bool)` вызовов.

#### EHudElement (widgets)

`LHUD_PRESENCE`, `LHUD_STANCE`, `LHUD_PLAYER`, `LHUD_VEHICLE`, `RHUD_BADGES`, `RHUD_DIVIDER`, `RHUD_NOTIFIERS`, `QUICKBAR`.

#### EHudContextFlags (rules)

| Флаг | Значение | Эффект |
|------|----------|--------|
| `HUD_DISABLE` | 1 | Отключено в опциях |
| `HUD_HIDE` | 2 | Скрыто хоткеем |
| `VEHICLE_DISABLE` | 4 | Vehicle HUD off в опциях |
| `DRIVER` | 8 | Игрок — водитель (показать veh HUD) |
| `VEHICLE` | 16 | В транспорте (спрятать left stats) |
| `MENU_OPEN` | 32 | Открыто меню |
| `NO_BADGE` | 64 | Нет бейджей (скрыть divider) |
| `QUICKBAR_DISABLE/HIDE/GLOBAL` | 128/256/512 | Layers квикбара |
| `INVENTORY_OPEN` | 1024 | Инвентарь открыт (HUD всегда видим) |
| `UNCONSCIOUS` | 2048 | Без сознания |

#### API

```c
void SetContextFlag(EHudContextFlags flag, bool state)
bool IsElementVisible(EHudElement element)
bool IsContextFlagActive(EHudContextFlags flag)
```

Установка флага автоматически пересчитывает все связанные элементы через `m_ElementLinkMap`.

---

### IngameHudHeatBuffer

```c
class IngameHudHeatBuffer
```

Индикатор «теплового буфера» (накопленное тепло от одежды). Мигает в стадиях `m_FlashingThresholds` (1: 0.002, 2: 0.332, 3: 0.662). Останавливается при `OnDeathStart`/`OnUnconsciousStart`, возобновляется при `OnUnconsciousStop`. Апдейт вызывается из `IngameHud.Update` через `CanUpdate()`.

---

### HudDebug

```c
class HudDebug extends Hud
```

Dev-оверлей `#ifdef DEVELOPER`. Контейнер «окон» (`HudDebugWinBase`), зарегистрированных в `Init` из widget'ов `day_z_hud_debug.layout`.

| HUD_WIN_* | Окно |
|-----------|------|
| `CHAR_STATS` | Статы персонажа (hydration, energy, blood, heat, …) |
| `CHAR_MODIFIERS` | Активные модификаторы |
| `CHAR_AGENTS` | Агенты (бактерии/вирусы) |
| `CHAR_DEBUG` | Отладочные значения |
| `CHAR_LEVELS` | Уровни статов |
| `CHAR_STOMACH` | Содержимое желудка |
| `VERSION` | Версия билда |
| `TEMPERATURE` | Температура тела/окружения |
| `HEALTH` | Здоровье по зонам |
| `HORTICULTURE` | Состояние растений |

Видимость каждого окна хранится в `PluginConfigDebugProfile` → `RefreshByLocalProfile()`. Update всех видимых окон по таймеру раз в секунду.

---

### DebugMonitor

```c
class DebugMonitor
```

Отдельный monitor поверх HUD (`gui/layouts/debug/day_z_debug_monitor.layout`). Включается через `g_Game.SetDebugMonitorEnabled` (серверный параметр `enableDebugMonitor`). Создаётся через `MissionGameplay.CreateDebugMonitor()`, обновляется из `MissionGameplay.UpdateDebugMonitor()`.

Отображает: версию, health, blood, last damage source, map tile (A1/A2/…), позицию (копирование в clipboard по `UAUICopyDebugMonitorPos`), FPS (current/min/max/avg с цветовой градацией по платформе).

---

### ItemActionsWidget

Правый нижний виджет с подсказками действий. Управляется через `widget script` (`ScriptedWidgetEventHandler`), самообновляется раз в кадр через `CALL_CATEGORY_GUI` update queue. Считывает `ActionManagerClient` игрока, показывает `Interact`/`ContinuousInteract`/`Single`/`Continuous` action'ы в hands, управляет fade по `m_FadeTimer`. Иконки кнопок подставляются через `InputUtils.GetRichtextButtonIconFromInputAction` под текущее устройство ввода.

---

### ActionMenu

```c
class ActionMenu
```

Текстовое меню перебираемых действий (ниже ItemActionsWidget). Работает только `#ifdef DIAG_DEVELOPER` (новый AT selection). Инициализируется в `MissionGameplay.OnInit` с виджетами `ActionsPanel` и `DefaultActionWidget`. `NextAction/PrevAction/NextActionCategory/PrevActionCategory` → `player.GetActionManager().Select*`. Автоскрытие через `HIDE_MENU_TIME = 5s`.

---

### Crosshair / Action targets cursor

| Класс | Роль |
|-------|------|
| `CrossHairSelector` | Хэндлер widget'а из XML, переключает набор crosshair'ов (`set<ref CrossHair>`) по состоянию игрока/оружия. Обновляется в `PostUpdateQueue(CALL_CATEGORY_GUI)` |
| `ProjectedCrosshair` | Вспомогательный crosshair для weapon debug (`DiagMenuIDs.WEAPON_DEBUG`) |
| `ActionTargetsCursor` | Cursor action target + tooltip справа. Кеширует object через `ATCCachedObject`. Учитывает PPE vision obstructions (burlap sack, flashbang) |
| `ContinuousActionProgress` | Круговой прогресс-бар вокруг cursor'а для continuous actions. Подавляется если активен `HUD_HIDE_FLAGS` |

---

### Map markers / Object follower

`MapMarkerTypes` — статический реестр иконок для локаций на карте (`eMapMarkerTypes`: `BORDER_CROSS`, `BROADLEAF`, `CAMP`, `FACTORY`, `FIR`, `FIREDEP`, `GOVOFFICE`, `HILL`, `MONUMENT`, `PALM`, `POLICE`, `STATION`, `STORE`, `TOURISM`, `TRANSMITTER`, `TSHELTER`, `TSIGN`, `VIEWPOINT`, `VINEYARD`, `WATERPUMP`). Инициализируется в `MissionGameplay.OnInit` через `MapMarkerTypes.Init()`.

`ObjectFollower` — widget, следующий за `Object` в экранных координатах (используется для маркеров и меток).

---

### InventoryQuickbar

Hotbar 0-9 слотов живёт в `IngameHud` (`m_Quickbar`), инициализируется через отложенный `InitQuickbar()` из `IngameHud.Init`. Управление видимостью через `IngameHudVisibility` (`EHudElement.QUICKBAR`, флаги `QUICKBAR_*`). Подробности UI контейнера — см. [inventory.md](inventory.md) раздел Quickbar.

---

### GameplayEffectWidgets

```c
class GameplayEffectWidgets extends GameplayEffectWidgets_base
```

Хост оверлейных эффектов поверх экрана. Инстанс в `MissionGameplay.m_EffectWidgets`, доступ через `GetMission().GetEffectWidgets()`. Основной входной API — `AddActiveEffects(array<int>)` / `RemoveActiveEffects(array<int>)`.

#### Registered layouts

В `InitLayouts`:
- `gui/layouts/gameplay/CameraEffects.layout` — occluders, breath, flashbang cover
- `gui/layouts/gameplay/BleedingEffects.layout` — слой индикаторов кровотечения

#### Widget sets (EffectWidgetsTypes)

| Группа | Типы |
|--------|------|
| **Breath** | `MASK_BREATH`, `HELMET_BREATH`, `MOTO_BREATH` — делят `WIDGETSET_BREATH` |
| **Occluders** | `MASK_OCCLUDER`, `HELMET_OCCLUDER`, `HELMET2_OCCLUDER`, `MOTO_OCCLUDER`, `NVG_OCCLUDER`, `PUMPKIN_OCCLUDER` (alias `NVG_OCCLUDER`), `EYEPATCH_OCCLUDER` |
| **Cover** | `COVER_FLASHBANG` |
| **Bleeding** | `BLEEDING_LAYER` (специализированный обработчик через `GameplayEffectsDataBleeding`) |

#### API

| Метод | Описание |
|-------|----------|
| `AddActiveEffects(effects)` | Активировать список ID |
| `RemoveActiveEffects(effects)` | Деактивировать |
| `StopAllEffects()` | Выключить все |
| `IsAnyEffectRunning()` | Есть ли активные |
| `AddSuspendRequest(request_id)` / `RemoveSuspendRequest` / `ClearSuspendRequests` / `GetSuspendRequestCount` | Приостановка отрисовки (не удаляя) |
| `UpdateWidgets(type, timeSlice, p, handle)` | Апдейт конкретного типа/handle |
| `Update(timeSlice)` | Общий tick (вызывает breath, прогресс, bleeding) |
| `SetBreathIntensityStamina(cap, current)` | Интенсивность breath по выносливости |
| `OnVoiceEvent(breathing_resistance)` | Hook голосового чата |
| `RegisterGameplayEffectData(id, p)` | Регистрация данных для effect ID |

Metadata-классы: `GameplayEffectsData` (base) → `GameplayEffectsDataImage` (для ImageWidget с оригинальными цветами) → `GameplayEffectsDataBleeding` (специализация). Тип данных определяется через `m_IDToTypeMap : map<int,typename>`.

#### BleedingIndicator

```c
class BleedingIndicator extends Managed
```

Один wrapper на bleeding source. Хранит severity (`LOW`/`MEDIUM`/`HIGH`), probability array, spawn timings, активные drops (`BleedingIndicatorDropData`). Управляется из `GameplayEffectsDataBleeding` (переопределяет `Update` родителя) — добавляет/удаляет `BleedingIndicator` при изменении `BleedingSourcesManagerRemote`.
