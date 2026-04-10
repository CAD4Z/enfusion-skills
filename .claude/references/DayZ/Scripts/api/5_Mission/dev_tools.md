Dev-инструменты для разработчиков: ScriptConsole, SceneEditor, CameraTools. Источники: `gui/scriptconsole*.c`, `gui/sceneeditormenu*.c`, `gui/cameratools/`

Все инструменты — `UIScriptedMenu` поверх обычного HUD, требуют `DIAG_DEVELOPER`/`DEVELOPER` сборки. Открываются через консольные команды / debug menu / диагностические биндинги (`MissionGameplay` слушает `UADebug*` инпуты).

### Каталог

| Меню | ID | Layout | Назначение |
|------|-----|--------|-----------|
| `ScriptConsole` | `MENU_SCRIPTCONSOLE` | `script_console/script_console.layout` | Спавн предметов, исполнение скриптов, отладка игрока |
| `SceneEditorMenu` | `MENU_SCENE_EDITOR` | `scene_editor/scene_editor.layout` | Редактор статических сцен (объекты, ruler, положения) |
| `CameraToolsMenu` | `MENU_CAMERA_TOOLS` | `camera_tools/camera_tools.layout` | Кинематографические keyframe-камеры |
| `HudDebug` | — | `day_z_hud_debug.layout` | Оверлей статов/модификаторов — см. [hud.md](hud.md) |

---

### ScriptConsole

```c
class ScriptConsole extends UIScriptedMenu
```

Главный dev-tool. Набор вкладок (`ScriptConsoleTabBase`), hint-система с tooltip'ами по ховеру, разделяемая `PluginConfigDebugProfile` для сохранения состояния.

#### Жизненный цикл

| Метод | Описание |
|-------|----------|
| `ScriptConsole()` | Скрывает HUD (`ShowHudPlayer(false)`, `ShowQuickbarPlayer(false)`), уведомляет `PluginItemDiagnostic.OnScriptMenuOpened(true)` |
| `Init()` | Создаёт layout, регистрирует все табы через `RegisterTab(new ...)`, восстанавливает `m_SelectedTab` из профиля, загружает hint JSON |
| `~ScriptConsole()` | Восстанавливает HUD, `EnableAllInputs(true)`, уведомляет plugin |
| `RegisterTab(handler)` | Вставляет в `m_TabHandlers : map<Widget, ScriptConsoleTabBase>` и `m_TabHandlersByID`, вызывает `handler.Init(m_Id++)` |
| `Update(timeslice)` | Ховер-таймер → `HoverSuccess()` → `DisplayHint(GetMessage())` |

#### Поля ScriptConsole

| Поле | Описание |
|------|----------|
| `m_TabHandlers : map<Widget, ref ScriptConsoleTabBase>` | Кнопка → handler |
| `m_TabHandlersByID : map<int, ref ScriptConsoleTabBase>` | ID → handler |
| `m_SelectedHandler : ScriptConsoleTabBase` | Текущая активная вкладка |
| `m_JsonData : JsonHintsData` | Hint bindings (widget hash → текст) |
| `m_MarkedEntities : static array<ref MapMarker>` | Разделяемый набор маркеров на debug-карте |
| `m_ConfigDebugProfile : PluginConfigDebugProfile` | Persist состояния (какой таб, чекбоксы, пресеты) |

#### Табы

Регистрируются в `Init()` в фиксированном порядке:

| Таб | Класс | Назначение |
|-----|-------|-----------|
| **Items** | `ScriptConsoleItemsTab` | Спавн предметов в мир/инвентарь/руки, категории, пресеты лута, draw-in-world |
| **Configs** | `ScriptConsoleConfigTab` | Иерархический config viewer (classes + variables), dump-param |
| **EnScript** | `ScriptConsoleEnfScriptTab` | Исполнение EnScript на клиенте (`CallFunction`) |
| **EnScriptServer** | `ScriptConsoleEnfScriptServerTab` | То же, но на сервере (через RPC) |
| **General** | `ScriptConsoleGeneralTab` | Debug map, teleport по координатам, time slider, toggle диагностики/логов, список других игроков |
| **Output** | `ScriptConsoleOutputTab` | Консольные логи клиента (`Debug.ClearLogs`, auto-scroll) |
| **Vicinity** | `ScriptConsoleVicinityTab` | Список объектов вокруг игрока с context menu |
| **Sounds** | `ScriptConsoleSoundsTab` | Sound event debug, spawn/play soundsets, map |
| **Weather** | `ScriptConsoleWeatherTab` | Fog/overcast/rain/wind slider'ы с interpolation и duration |
| **Camera** | `ScriptConsoleCameraTab` | FOV/focus/blur/DOF через `ScriptConsoleSelector` (slider'ы) |

Serverside-only dedicated сборка: Sounds/Camera табы отключаются условием `!g_Game.IsDedicatedServer()`.

#### ScriptConsoleTabBase

```c
class ScriptConsoleTabBase
```

Базовый класс таба. Наследники реализуют нужные override'ы:

| Поле | Описание |
|------|----------|
| `m_Id : int` | Автоинкрементный ID (присваивается `RegisterTab`) |
| `m_IsSelected : bool` | Активный таб |
| `m_IsShiftDown : bool` | Состояние shift для multi-select |
| `m_ScriptConsole : ScriptConsole` | Родитель |
| `m_ConfigDebugProfile : PluginConfigDebugProfile` | Persist состояния |

| Override | Описание |
|----------|----------|
| `OnSelected()` | При выборе таба |
| `OnChange(w,x,y,finished)` | EditBox/Slider изменение |
| `OnClick(w,x,y,button)` | Клик по кнопке |
| `OnItemSelected(w,row,column,…)` | Выбор в listbox |
| `OnKeyDown/OnKeyPress(w,x,y,key)` | Клавиатура |
| `OnDoubleClick(w,x,y,button)` | Двойной клик |
| `OnRPCEx(rpc_type, ctx)` | RPC хук |
| `OnMouseEnter/OnMouseLeave/OnMouseButtonDown` | Mouse events |

Helper: `AddItemToClipboard(string)`. Все override'ы прокидываются из `ScriptConsole.OnChange/OnClick/...` в `m_SelectedHandler`.

#### ScriptConsoleSelector

```c
class ScriptConsoleSelector extends OptionSelectorSliderSetup
```

Slider-виджет для numeric значений в Camera/Weather табах. Layout `gui/layouts/new_ui/script_console_slider.layout`. Хранит родителя (`m_ParentTab`) для callback'ов.

#### Hint-система

- Ховер над любым widget'ом → `m_HoverTime` растёт → по достижении порога `HoverSuccess()` → `DisplayHint(GetMessage())`
- Hash widget'а: `GetWidgetCombinedHash(w) = (w.GetName() + w.GetParent().GetName()).Hash()`
- JSON bindings хранятся в `m_JsonData.WidgetHintBindings : map<int, string>`
- Edit mode: `m_HintEditMode` → показ `m_EditTooltipRoot` (layout `script_console_tooltip_edit.layout`) с полем ввода. На Ok → `SetHintText` сохраняет в map → `SaveData()` в `$mission:script_console_hints.json`
- Fallback `HINTS_PATH_DEFAULT = "scripts/data/internal/script_console_hints.json"` (read-only дефолт)

#### Sub-dialogs

Файлы в `gui/scriptconsole/`:

| Класс | Назначение |
|-------|-----------|
| `ScriptConsoleAddPositionDialog` | Popup для добавления именованной позиции |
| `ScriptConsoleNewPresetDialog` | Создание нового пресета лута |
| `ScriptConsoleRenamePresetDialog` | Переименование пресета |
| `ScriptConsoleUniversalInfoDialog` | Универсальный info popup |

Все — самостоятельные `UIScriptedMenu`'ы, открываются из Items tab.

Pluginы, к которым обращается ScriptConsole:

| Plugin | Назначение |
|--------|-----------|
| `PluginConfigDebugProfile` | Persist custom пресетов/выборов таба |
| `PluginConfigDebugProfileFixed` | Захардкоженные fixed presets |
| `PluginDeveloper` | Спавн предметов, ClearInventory, teleport |
| `PluginItemDiagnostic` | Item watch window |
| `PluginLocalEnscriptHistory` | История EnScript выражений (client) |
| `PluginLocalEnscriptHistoryServer` | История (server) |
| `PluginConfigViewer` | Config hierarchy для Configs таба |
| `PluginSceneManager` | Связка со SceneEditor (shared objects) |

См. [4_World/plugins.md](../4_World/plugins.md) — где они живут.

---

### SceneEditorMenu

```c
class SceneEditorMenu extends UIScriptedMenu
```

Редактор статических мод-сцен. Каждая «сцена» — набор `SceneObject`'ов с позицией/ротацией/health/init-script. Хранятся в `PluginSceneManager`. Layout — `gui/layouts/scene_editor/scene_editor.layout`.

#### Разделы UI

```
SceneEditorMenu
  ├── Top bar         : Scene Manager / Settings / Save / Editor Settings / Delete Ruler
  ├── Scene Object List  (TextListboxWidget m_SlWgtLbxObjectsList)
  │     └── filter (m_SlWgtEbxFilter), Select, Focus
  ├── Config Class List  (m_ClWgtLbxClassesList — для добавления новых объектов)
  │     └── filter (m_ClWgtEbxFilter), Add as Attachment
  ├── Properties panel
  │     ├── class name, x/y/z, direction, damage
  │     ├── "Edit Init Script" button → POPUP_ID_INIT_SCRIPT
  │     └── Attachments list (UIPropertyAttachment'ы)
  ├── Presets panel   (ref с ScriptConsole, spawn on ground / inventory / attachment)
  └── Popups layer    (m_WgtPopupsMain) — активные popup'ы
```

#### Popup IDs

```c
POPUP_ID_SCENE_MANAGER    = 0   // список сцен, загрузка/создание
POPUP_ID_SCENE_SETTINGS   = 1
POPUP_ID_SCENE_NEW        = 2
POPUP_ID_SCENE_RENAME     = 3
POPUP_ID_SCENE_DELETE     = 4
POPUP_ID_NOTIFY           = 5   // всплывающие уведомления
POPUP_ID_EDITOR_SETTINGS  = 6
POPUP_ID_INIT_SCRIPT      = 7   // редактирование init script объекта
POPUP_ID_POSITION_MANAGER = 8
POPUP_ID_PRESET_NEW       = 9
POPUP_ID_PRESET_RENAME    = 10
POPUP_ID_CONFIGS          = 11
```

Все popup'ы — наследники `UIPopupScript` из `gui/sceneeditormenu/uipopupscript.c`:

```c
class UIPopupScript
{
    void OnOpen(Param param);
    void OnClose();
    void Show(bool show);
    bool OnClick/OnChange(...);
    protected UIPopupScript PopupBack();   // вернуться к предыдущему в стеке
}
```

`SceneEditorMenu` держит `m_OpenedPopups : TIntArray` (стек) и `m_Popups : map<int, ref UIPopupScript>`. Открытие через `OpenPopup(id, param)` → push + Show. `PopupBack()` → pop из стека.

#### Pipeline

1. User выбирает сцену в Scene Manager popup → `PluginSceneManager.SceneLoad(name)`
2. `PluginSceneManager` спавнит объекты, шлёт `SCENE_EDITOR_CMD_REFRESH` через `SceneEditorCommand` → `Refresh()`
3. `Refresh()` обновляет `m_SlObjectsList` (фильтруется по `m_SlWgtEbxFilter`), свойства текущего объекта, ruler state
4. Edit → `PluginSceneManager.SceneSave()` → `SCENE_EDITOR_CMD_SAVE` → fade animation `m_NotifyWgtPanel` (через `m_NotifyFadeTimer : WidgetFadeTimer`)

#### UIPropertyAttachment

```c
class UIPropertyAttachment
```

Мелкий widget-wrapper для одного attachment'а выбранного объекта. Один экземпляр на slot. Хранит ссылку на `SceneObject` + slot name, кнопки add/remove.

---

### CameraToolsMenu

```c
class CameraToolsMenu extends UIScriptedMenu
```

Кинематографическая камера для роликов/трейлеров. Записывает keyframe'ы позиции камеры + events (FX/actions) + actors (NPC'ы с одеждой). Воспроизводит плавную кривую между keyframe'ами. Layout `gui/layouts/camera_tools/camera_tools.layout`.

#### Архитектура

```
CameraToolsMenu
  ├── m_Camera1 / m_Camera2        (StaticCamera — swap buffer для интерполяции)
  ├── m_Cameras : array<CTKeyframe>    (список keyframe'ов)
  ├── m_Events  : array<CTEvent>       (триггеры на таймлайне)
  ├── m_Actors  : array<CTActor>       (spawned NPC с loadout'ами)
  ├── m_CameraLines : array<Param6<...>>   (записанные положения для render'а трека)
  └── m_SelectedKeyframe/Event/Actor   (текущее выбранное)
```

Входной режим: `AddActiveInputExcludes({"menu"})`, `DeveloperFreeCamera.EnableFreeCameraSceneEditor`, HUD скрывается через `mission.GetHud().Show(false)`. При закрытии всё возвращается.

#### Жизненный цикл

| Метод | Описание |
|-------|----------|
| `CameraToolsMenu()` | Создаёт `m_Camera1`/`m_Camera2` через `g_Game.CreateObject("staticcamera", ...)`, открывает free camera |
| `~CameraToolsMenu()` | `Stop()` проигрывания, скрывает cursor, убирает input excludes, `SaveData()`, возвращает HUD |
| `Init()` | Создаёт layout, привязывает все widget'ы (m_AddKeyframe/Event/Actor, m_Play/Stop/Save/Load, m_CopyButton/ApplyButton/CameraEditbox, …) |
| `OnShow()` / `OnHide()` | Toggle input excludes (если не идёт проигрывание) |

#### Операции

| Кнопка | Действие |
|--------|----------|
| Add Keyframe | Вставить `CTKeyframe` с текущей позицией freecam, FOV, DOF, pin, interp time |
| Save/Delete Keyframe | Persist изменений текущего keyframe |
| Snap to Keyframe | Телепортировать camera на выбранный |
| Add Event | `CTEvent` на текущем времени таймлайна |
| Add Actor | `CTActor` (NPC) по `m_ActorTypeWidget`, hands item по `m_ActorItemTypeWidget` |
| Play/Stop | Интерполяция `m_Camera1` → `m_Camera2` по пути keyframe'ов, триггер events |
| Save/Load | Через `CTSaveStructure` → `$profile:/CameraTools` (поле `m_CameraToolsDataPath`) |

#### CT*-wrapper'ы (helpers)

| Класс | Родитель | Layout | Описание |
|-------|----------|--------|----------|
| `CTKeyframe` | `ScriptedWidgetEventHandler` | `camera_tools/keyframe_entry.layout` | Одна строка списка keyframe'ов (index, interp time, FOV, DOF, pin) |
| `CTEvent` | `ScriptedWidgetEventHandler` | `camera_tools/event_entry.layout` | Одна строка events — тип события + параметры |
| `CTActor` | `CTObjectFollower` | `camera_tools/actor_entry.layout` | Spawned actor с привязкой к object'у в мире |
| `CTObjectFollower` | `ScriptedWidgetEventHandler` | — | Базовый класс с follow логикой (object → widget row) |
| `CTSaveStructure` | — | — | POD для JSON сериализации сцен (keyframes/events/actors) |

#### Interpolation types

`m_InterpTypeCombo` / `m_InterpTypeSpeedCombo` — выпадающие списки с вариантами (Linear, Cubic, Bezier, …). Значение хранится в keyframe, влияет на `Update()` цикл интерполяции позиции между `m_Camera1` и `m_Camera2`.

---

### HudDebug (#ifdef DEVELOPER)

Оверлей отладочных окон поверх игры. Не отдельное меню — живёт внутри `MissionGameplay` и рисуется поверх HUD. См. [hud.md](hud.md) раздел **HudDebug**.

Окна: `HUD_WIN_CHAR_STATS`, `HUD_WIN_CHAR_MODIFIERS`, `HUD_WIN_CHAR_AGENTS`, `HUD_WIN_CHAR_DEBUG`, `HUD_WIN_CHAR_LEVELS`, `HUD_WIN_CHAR_STOMACH`, `HUD_WIN_VERSION`, `HUD_WIN_TEMPERATURE`, `HUD_WIN_HEALTH`, `HUD_WIN_HORTICULTURE`. Видимость переключается из `ScriptConsoleGeneralTab` (`m_HudDCharStats` и друзья) → `PluginConfigDebugProfile` → `HudDebug.RefreshByLocalProfile()`.

---

### Типичный flow отладки

1. Открыть `ScriptConsole` (консольная команда / debug binding)
2. Items tab → выбрать вещь → Spawn in Hands / On Ground / In Inventory
3. General tab → включить нужные HudDebug окна (Char Stats, Health, …)
4. EnScript tab → выполнить произвольный код на клиенте (или EnScriptServer на сервере)
5. Configs tab → посмотреть параметры конфига выбранного класса
6. Vicinity tab → получить список объектов рядом, watch конкретный

Всё состояние (какой таб, чекбоксы, пресеты) живёт в `PluginConfigDebugProfile` и сохраняется между сессиями.

---

### Расширение

- **Новый таб ScriptConsole**: наследник `ScriptConsoleTabBase`, зарегистрировать в `ScriptConsole.Init()` через `RegisterTab(new MyTab(root, this, button))`. Кнопка должна быть в layout'е.
- **Новый popup SceneEditor**: наследник `UIPopupScript`, добавить в `m_Popups` в `Init()`, новый `POPUP_ID_*` константа.
- **Hint для widget'а**: hover в edit-mode (Shift?) → ввести текст → Ok. Сохранится в `$mission:script_console_hints.json`.
