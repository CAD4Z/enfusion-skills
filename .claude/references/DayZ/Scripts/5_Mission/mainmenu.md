Главное меню — все экраны до загрузки в `MissionGameplay`. Источники: `gui/newui/`, `gui/titlescreenmenu.c`, `gui/startupmenu.c`

### Контекст

Главное меню работает поверх `MissionMainMenu` (см. [mission.md](mission.md)). Корневое меню зависит от платформы:
- **PC** → `MENU_MAIN` (`MainMenu`)
- **Console** → `MENU_TITLE_SCREEN` (`TitleScreenMenu`) → после нажатия кнопки → `MENU_MAIN` (`MainMenuConsole`)

`MissionMainMenu.OnInit` создаёт `DayZIntroScenePC`/`DayZIntroSceneXbox` (в зависимости от платформы) и открывает корневое меню.

---

### Каталог menu

| MENU_ID | Класс | Layout | Назначение |
|---------|-------|--------|------------|
| `MENU_TITLE_SCREEN` | `TitleScreenMenu` | `xbox/day_z_title_screen.layout` | "Press A to start" splash (console) |
| `MENU_STARTUP` | `StartupMenu` | `startup.layout` | Startup splash |
| `MENU_MAIN` | `MainMenu` (PC) / `MainMenuConsole` (console) | `new_ui/main_menu.layout` / `new_ui/main_menu_console.layout` | Корневое меню |
| `MENU_CHARACTER` | `CharacterCreationMenu` | `new_ui/character_creation/character_creation.layout` | Кастомизация персонажа |
| `MENU_SERVER_BROWSER` | `ServerBrowserMenuNew` | `new_ui/server_browser/pc/...` или `xbox/...` | Браузер серверов |
| `MENU_OPTIONS` | `OptionsMenu` | `new_ui/options/{pc,xbox,ps,msstore}/options_menu.layout` | Настройки (Game/Sounds/Video/Controls) |
| `MENU_KEYBINDINGS` | `KeybindingsMenu` | `new_ui/options/{pc,msstore}/keybinding_menu.layout` | Настройка клавиш |
| `MENU_VIDEO` | `MainMenuVideo` | — | Plays intro video |
| `MENU_TUTORIAL` | `TutorialsMenu` | — | Список туториал-видео |
| `MENU_CREDITS` | `CreditsMenu` | `new_ui/credits/credits_menu.layout` | Титры |
| `MENU_XBOX_CONTROLS` | `ControlsXboxNew` | — | Раскладка контроллера |
| `MENU_LOGIN_QUEUE` / `MENU_LOGIN_TIME` | `LoginQueueBase` / `LoginTimeBase` | — | Очередь на сервер |
| `MENU_CONNECT_ERROR` | `ConnectErrorScriptModuleUI` | — | Ошибки коннекта |
| `MENU_MISSION_LOADER` | `MissionLoader` | — | Промежуточный лоадер |

In-game меню (пауза, инвентарь, карта, …) — см. [menus.md](menus.md). Dev меню — см. [dev_tools.md](dev_tools.md).

---

### MainMenu (PC)

```c
class MainMenu extends UIScriptedMenu
```

Корневой экран на PC. Layout — `gui/layouts/new_ui/main_menu.layout`.

#### Состояние

| Поле | Описание |
|------|----------|
| `m_Mission : MissionMainMenu` | Родительская миссия |
| `m_ScenePC : DayZIntroScenePC` | Интро-сцена с 3D-моделью персонажа |
| `m_Stats : MainMenuStats` | Виджет статистики игрока |
| `m_Video : MainMenuVideo` | Опциональный intro-video player |
| `m_NewsCarousel : NewsCarousel` | Карусель новостей и DLC |
| `m_ModsSimple` / `m_ModsDetailed` / `m_ModsTooltip` | Виджеты списка модов |
| `m_LastFocusedButton` | Возврат focus при OnShow |
| `m_LastPlayedTooltip*` | Tooltip с инфой последнего сервера |

#### Кнопки

`m_Play` / `m_ChooseServer` / `m_CustomizeCharacter` / `m_PlayVideo` / `m_Feedback` / `m_Tutorials` / `m_TutorialButton` / `m_MessageButton` / `m_SettingsButton` / `m_Exit` + character switcher (`m_PrevCharacter`/`m_NextCharacter`).

#### Обработка событий

- `OnClick(w, x, y, button)` — диспатч по widget'у на `EnterScriptedMenu(MENU_*)`
- `Refresh()` — обновить player name, mods warning, last server tooltip
- `Update(timeslice)` — анимация intro-сцены, fade tooltip'а
- `OnSizeChanged()` — пересчитать позиции при ресайзе

#### MainMenuStats

```c
class MainMenuStats extends ScriptedWidgetEventHandler
```

Под-виджет с лайфтайм-статами игрока (`STAT_PLAYTIME`, `STAT_PLAYERS_KILLED`, `STAT_INFECTED_KILLED`, `STAT_DISTANCE`, `STAT_LONGEST_SHOT`).

| Метод | Описание |
|-------|----------|
| `MainMenuStats(Widget root)` | Привязка к корневому виджету `character_stats_root` |
| `ShowStats()` / `HideStats()` | Видимость |
| `UpdateStats()` | Перечитать `g_Game.GetMenuData().GetCharactersCount()` etc. |

Время выживания форматируется через `FullTimeData`.

---

### MainMenuConsole

```c
class MainMenuConsole extends UIScriptedMenu
```

Console-вариант. Layout зависит от платформы:
- `new_ui/main_menu_msstore.layout` для MS Store
- `new_ui/main_menu_console.layout` для Xbox/PS

Кнопки: `m_Play`, `m_ChangeAccount`, `m_CustomizeCharacter`, `m_PlayVideo`, `m_Tutorials`, `m_Options`, `m_Controls`, `m_Exit`, `m_MessageButton`, `m_ShowFeedback` (с QR-кодом для feedback).

`m_NewsCarousel` отображается через `#define ENABLE_CAROUSEL` (отключён в `BUILD_EXPERIMENTAL`). `ScreenWidthType` рассчитывается аналогично `InventoryMenu` (см. [inventory.md](inventory.md)).

---

### TitleScreenMenu

```c
class TitleScreenMenu extends UIScriptedMenu
```

Console-only "press button" splash. Layout `xbox/day_z_title_screen.layout`. В конструкторе ставит `g_Game.SetGameState(MAIN_MENU)` + `SetLoadState(MAIN_MENU_START)`.

`Update`: `if (UAUISelect.LocalPress())` — на Windows открывает `MENU_MAIN`, на Xbox — `g_Game.GamepadCheck()` (выбор активного аккаунта). Текст подсказки динамически меняется по платформе и текущей кнопке "enter" (cross/circle на PS, A на Xbox).

---

### StartupMenu

```c
class StartupMenu extends UIScriptedMenu
```

Тривиальный splash из `startup.layout` с одним `TextWidget m_label`. Используется как промежуточный экран при загрузке движка.

---

### MainMenuData

```c
class MainMenuData
```

Статический хелпер для главного меню — кеш новостей, модов и DLC. Все методы — `static`.

| Метод | Описание |
|-------|----------|
| `GetNewsData()` | Загрузить или вернуть `JsonDataNewsList` (новости + DLC entries) |
| `GetNewsArticle(index)` | Один article из новостей |
| `LoadMods()` | Загрузить `array<ref ModInfo>` через `g_Game.GetModInfos()` |
| `FilterDLCs(modArray)` | Отделить DLC из списка модов в `m_AllDlcsMap` |
| `CreateDLCArticles()` | Создать article'ы для DLC и вставить в `m_NewsData.News` |
| `GetDLCModInfoByName(dlcName)` | Lookup ModInfo по короткому DLC-имени |
| `GetAllMods()` | Все моды включая DLC |

---

### NewsCarousel / MainMenuNewsfeed / MainMenuPromo

Под-виджеты главного меню (все `extends ScriptedWidgetEventHandler`):

| Класс | Назначение |
|-------|------------|
| `NewsCarousel` | Прокручиваемая карусель новостей и DLC промо |
| `MainMenuNewsfeed` | Боковой newsfeed (PC main menu) |
| `MainMenuDlcHandlerBase` | Базовый handler для DLC promo баннеров |
| `BannerHandlerBase` | Базовый класс для статических баннеров |
| `MainMenuStats` | Стата игрока (см. выше) |

---

### MainMenuVideo / TutorialsMenu

`MainMenuVideo extends UIScriptedMenu` — обёртка вокруг `VideoPlayer` (`gui/newui/videoplayer.c`) для intro/promo роликов. `TutorialsMenu extends UIScriptedMenu` — список туториал-видео, открывается из main menu.

---

### CharacterCreationMenu

```c
class CharacterCreationMenu extends UIScriptedMenu
```

Кастомизация персонажа. Открывается через `MENU_CHARACTER`.

#### Состояние

| Поле | Описание |
|------|----------|
| `m_Scene` | `DayZIntroScenePC` (PC) или `DayZIntroSceneXbox` (console) |
| `m_OriginalCharacterID` | Для отмены изменений |
| `m_CharacterRotationFrame` | Виджет mouse rotation модели |

#### Селекторы

Каждое поле — `OptionSelectorMultistateCharacterMenu` (см. `gui/newui/optionselector*.c`):

| Поле | Селектор |
|------|----------|
| Name | `m_NameSelector : OptionSelectorEditbox` |
| Gender | `m_GenderSelector` |
| Skin | `m_SkinSelector` |
| Top | `m_TopSelector` |
| Bottom | `m_BottomSelector` |
| Shoes | `m_ShoesSelector` |

`m_MultiOptionSelectors : map<Widget, OptionSelectorMultistateCharacterMenu>` — для общей логики click-через-widget. Сохранение/применение через `m_Scene.GetIntroCharacter()` и `MenuDefaultCharacterData`.

---

### ServerBrowserMenuNew

```c
class ServerBrowserMenuNew extends UIScriptedMenu
```

Браузер серверов. Layout — `new_ui/server_browser/{pc,xbox}/server_browser.layout`.

#### Структура

```
ServerBrowserMenuNew
  └── TabberUI (m_Tabber)
        ├── m_FavoritesTab    (FAVORITE)
        ├── m_OfficialTab     (OFFICIAL)
        ├── m_CommunityTab    (COMMUNITY)
        └── m_LANTab          (LAN, только PC)
```

Каждый таб — `ServerBrowserTab` (или его наследник):

```
ServerBrowserTab : ScriptedWidgetEventHandler
  ├── ServerBrowserTabPc                      (PC tab)
  │     └── ServerBrowserFavoritesTabPc
  └── ServerBrowserTabConsole                 (console tab)
        ├── ServerBrowserTabConsolePages      (с пагинацией)
        │     └── ServerBrowserFavoritesTabConsolePages
```

#### Константы

```c
const int MAX_FAVORITES = 25;
#ifdef PLATFORM_CONSOLE
    const int SERVER_BROWSER_PAGE_SIZE = 22;
#else
    const int SERVER_BROWSER_PAGE_SIZE = 5;
#endif
```

#### Под-виджеты

| Класс | Роль |
|-------|------|
| `ServerBrowserEntry` | Одна строка в списке серверов |
| `ServerBrowserDetailsContainer` | Боковая панель деталей выбранного сервера |
| `ServerBrowserFilterContainer` | Фильтры (population, hardcore, …) |

#### Pipeline

1. `OnlineServices.m_ServersAsyncInvoker.Insert(OnLoadServersAsync)` — подписка
2. `ServerBrowserTab.RefreshList()` — запрос к OnlineServices
3. `OnLoadServersAsync(GetServersResult)` — заполнение entries
4. `OnLoadServerModsAsync` — догрузка списка модов выбранного сервера

`PPERequester_ServerBrowserBlur` — постпроцесс blur заднего фона.

---

### OptionsMenu

```c
class OptionsMenu extends UIScriptedMenu
```

Layout — `new_ui/options/{pc,xbox,ps,msstore}/options_menu.layout`.

#### Структура

```
OptionsMenu
  └── TabberUI (m_Tabber)
        ├── m_GameTab     (OptionsMenuGame)
        ├── m_SoundsTab   (OptionsMenuSounds)
        ├── m_VideoTab    (OptionsMenuVideo)        — нет на Xbox
        └── m_ControlsTab (OptionsMenuControls)
```

`m_Options : GameOptions` — backing store для всех опций (см. 3_Game `gameoptions.c`).

#### Buttons

| Кнопка | Действие |
|--------|----------|
| `m_Apply` | `m_Options.Apply()` |
| `m_Reset` (undo) | `m_Options.Revert()` |
| `m_Defaults` | `m_Options.Default()` (per tab или all) |
| `m_Back` | `Close()` с диалогом подтверждения если есть unsaved |

`m_ModalLock` блокирует ввод во время диалогов. `m_CanApplyOrReset` отслеживает наличие unsaved changes.

#### Tab-классы

Каждый tab — `extends ScriptedWidgetEventHandler` с конструктором `(parentWidget, detailsWidget, options, parentMenu)`:

| Класс | Содержит |
|-------|----------|
| `OptionsMenuGame` | Quickbar visibility, language, HUD, blood/violence filters |
| `OptionsMenuSounds` | Volume sliders, voice chat |
| `OptionsMenuVideo` | Resolution, FPS limit, graphics quality |
| `OptionsMenuControls` | Mouse sensitivity, controller layout, link to KeybindingsMenu |

`DependentOptions` (`gui/newui/options/dependentoptions.c`) — система видимости опций по условию.

#### MS Store специфика

`#ifdef PLATFORM_MSSTORE` — добавляет отдельные кнопки `m_GamepadControls` и `m_KeyboardBindings` (две раскладки).

---

### KeybindingsMenu

```c
class KeybindingsMenu extends UIScriptedMenu
```

Полноценный редактор биндингов. Layout — `new_ui/options/{pc,msstore}/keybinding_menu.layout`.

#### Структура

```
KeybindingsMenu
  ├── TabberUI (m_Tabber)             — категории (Movement / Combat / Inventory / ...)
  ├── m_PresetSelector : OptionSelectorMultistate  — выбор пресета
  └── m_GroupsContainer : KeybindingsContainer
        └── KeybindingsGroup (по одной на категорию)
              └── KeybindingElement / KeybindingElementNew (одно действие)
```

#### Константы

```c
MODAL_ID_BACK = 1337
MODAL_ID_DEFAULT = 100               // reset текущего таба
MODAL_ID_DEFAULT_ALL = 101           // reset всех табов
MODAL_ID_PRESET_CHANGE = 200
```

#### Поля

| Поле | Описание |
|------|----------|
| `m_CurrentSettingKeyIndex` / `m_CurrentSettingAlternateKeyIndex` | Индексы primary/alt при ребиндинге |
| `m_OriginalPresetIndex` / `m_TargetPresetIndex` | Для отмены при смене пресета |
| `m_SetKeybinds : array<int>` | Накопленный список изменённых биндов |

#### Кнопки

`m_Apply`, `m_Back`, `m_Undo`, `m_Defaults`, `m_HardReset` (полный сброс всех табов).

#### Pipeline binding

1. Игрок кликает `KeybindingElement` → захват ввода
2. `g_Game.SetKeyboardHandle(this)` направляет события клавиатуры в меню
3. `OnKeyPress(key)` — записать в `m_CurrentSettingKey*Index`
4. Confirm/cancel → `Input.SetActionKey(action, deviceType, keyIndex, value)`
5. Apply → `Input.SaveActionsConfig()`

---

### CreditsMenu

```c
class CreditsMenu extends UIScriptedMenu
```

Layout — `new_ui/credits/credits_menu.layout`. Прокручиваемые титры из JSON.

| Константа | Значение |
|-----------|----------|
| `MENU_FADEIN_TIME` | 2.0s |
| `LOGO_FADEIN_TIME` | 1.0s |
| `CREDIT_SCROLL_SPEED` | 200 px/s (relative to 1080p) |

`m_CreditsData : JsonDataCredits` — список секций. `m_CreditsEntries : array<CreditsElement>` — заполняется из `LoadDataAsync` через game script call. Виджеты:
- `m_Logo : ImageWidget` — fade-in лого
- `m_Scroller : ScrollWidget` — основной scroll
- `m_Content : WrapSpacerWidget` — контент

`Update(timeslice)` инкрементирует scroll по `m_ScrollIncrement` (масштабируется по высоте экрана / 1080).

---

### Mods menu (in-main)

Виджеты списка модов на главном меню (`gui/newui/modsmenu/`):

| Класс | Роль |
|-------|------|
| `ModsMenuSimple` | Краткий список (показывается на main menu) |
| `ModsMenuSimpleEntry` | Одна строка |
| `ModsMenuDetailed` | Полный список с подробностями |
| `ModsMenuDetailedEntry` | Полная строка с описанием |
| `ModsMenuTooltip` | Tooltip при hover |

Все — `extends ScriptedWidgetEventHandler`. Данные берутся из `MainMenuData.GetAllMods()`.

---

### OptionSelector framework

Универсальные UI-компоненты для опций (`gui/newui/optionselector*.c`):

| Класс | Назначение |
|-------|------------|
| `OptionSelectorBase` | База, hover/focus state |
| `OptionSelectorMultistate` | Карусель `[ < value > ]` |
| `OptionSelectorSlider` | Слайдер числового значения |
| `OptionSelectorSliderSetup` | Слайдер с шагами setup-параметров |
| `OptionSelectorEditbox` | Текстовое поле |
| `OptionSelectorLevelMarker` | Дискретные уровни (low/medium/high) |
| `DropdownPrefab` | Выпадающий список |
| `TabberPrefab` (`gui/newui/tabberprefab/`) | Контроллер табов |

Используются в OptionsMenu, KeybindingsMenu, CharacterCreationMenu.

---

### Расширение

Чтобы добавить экран в главное меню:

1. Унаследоваться от `UIScriptedMenu`, override `Init()` (создать layoutRoot)
2. В `MissionBase.CreateScriptedMenu` (через mod-mission override) добавить `case MENU_MY: menu = new MyMenu;`
3. Открывать через `g_Game.GetUIManager().EnterScriptedMenu(MENU_MY, m_mainmenu)`
4. Для интеграции со сценой — получить `m_Scene` через `MissionMainMenu.GetIntroScenePC/Xbox()`
5. Для платформо-зависимых layout'ов использовать `#ifdef PLATFORM_*` switch

См. [mission.md](mission.md) — `MissionMainMenu.Reset()` пересоздаёт сцену и корневое меню.
