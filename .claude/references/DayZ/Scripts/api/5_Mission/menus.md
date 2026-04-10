In-game меню — все `UIScriptedMenu`'ы открываемые во время игры. Источники: `gui/*.c`

### Регистрация

Все меню создаются единственной фабрикой `MissionBase.CreateScriptedMenu(MENU_ID)` (см. [mission.md](mission.md)). Открываются через `g_Game.GetUIManager().EnterScriptedMenu(MENU_ID, parent)` (push) или `EnterScriptedMenu_Temp` (overlay).

`MENU_*` константы определены в 3_Game (`scripts/3_Game/constants.c`). Этот файл — справочник по концретным реализациям, открываемым во время `MissionGameplay` (in-game). Главное меню — см. [mainmenu.md](mainmenu.md).

---

### Каталог menu

| MENU_ID | Класс (PC) | Класс (Console) | Layout | Назначение |
|---------|------------|------------------|--------|------------|
| `MENU_INGAME` | `InGameMenu` | `InGameMenuXbox` | `day_z_ingamemenu.layout` | Пауза/выход/respawn/options |
| `MENU_INVENTORY` | `InventoryMenu` | (тот же) | `day_z_inventory.layout` | Инвентарь — см. [inventory.md](inventory.md) |
| `MENU_INSPECT` | `InspectMenuNew` | (тот же) | `inventory_new/day_z_inventory_new_inspect.layout` | Осмотр предмета (3D-preview) |
| `MENU_MAP` | `MapMenu` | (тот же) | `day_z_map.layout` | Бумажная карта (compass/GPS опционально) |
| `MENU_NOTE` | `NoteMenu` | (тот же) | `day_z_inventory_note.layout` | Чтение/запись бумажной заметки |
| `MENU_BOOK` | `BookMenu` | (тот же) | `day_z_book.layout` | Чтение книги |
| `MENU_GESTURES` | `GesturesMenu` | (тот же) | `radial_menu.layout` | Радиальное меню эмоутов |
| `MENU_RADIAL_QUICKBAR` | `RadialQuickbarMenu` | (тот же) | `radial_menu.layout` | Радиальный quickbar |
| `MENU_LOGOUT` | `LogoutMenu` | (тот же) | `day_z_logout_dialog.layout` | Таймер дисконнекта |
| `MENU_RESPAWN_DIALOGUE` | `RespawnDialogue` | (тот же) | `day_z_respawn_dialogue.layout` | Выбор respawn random/custom |
| `MENU_INVITE_TIMER` | `InviteMenu` | (тот же) | `day_z_invite_dialog.layout` | Прогресс присоединения по invite |
| `MENU_HELP_SCREEN` | `HelpScreen` | (тот же) | `day_z_help_screen.layout` | Экран помощи |
| `MENU_LOADING` | `LoadingMenu` | (тот же) | `loading.layout` | Загрузочный экран |
| `MENU_CHAT_INPUT` | `ChatInputMenu` | (тот же) | — | Поле ввода чата (см. [chat.md](chat.md)) |
| `MENU_CONNECTION_DIALOGUE` | `ConnectionDialogue` | (тот же) | `day_z_connection_dialogue.layout` | Сетевой буфер переполнен |
| `MENU_WARNING_ITEMDROP` | `ItemDropWarningMenu` | (тот же) | `day_z_dropped_items.layout` | Warning о сбросе предметов |
| `MENU_WARNING_TELEPORT` | `PlayerRepositionWarningMenu` | (тот же) | (тот же) | Warning о телепорте |
| `MENU_WARNING_INPUTDEVICE_DISCONNECT` | `InputDeviceDisconnectWarningMenu` | (тот же) | — | Warning об отключении контроллера |
| `MENU_EARLYACCESS` | `EarlyAccessMenu` | (тот же) | — | Early access splash |
| `MENU_CONTROLS_PRESET` | `PresetsMenu` | (тот же) | — | Выбор пресета управления |

Главные/lobby меню (`MENU_MAIN`, `MENU_TITLE_SCREEN`, `MENU_OPTIONS`, `MENU_SERVER_BROWSER`, `MENU_CHARACTER`, …) — см. [mainmenu.md](mainmenu.md).

Dev меню (`MENU_SCRIPTCONSOLE*`, `MENU_SCENE_EDITOR`, `MENU_CAMERA_TOOLS`, `MENU_LOC_ADD`) — см. [dev_tools.md](dev_tools.md).

---

### Общие паттерны

#### Pause/Continue

Открытие большинства in-game меню должно поставить игру на паузу:

```c
void InGameMenu()
{
    // ...
    Mission mission = g_Game.GetMission();
    if (mission)
        mission.Pause();    // → MissionGameplay.Pause()
}

void ~InGameMenu()
{
    // ...
    if (mission)
        mission.Continue();
}
```

#### Input excludes

Меню которые блокируют игровой ввод регистрируют группу из `specific.xml`:

```c
g_Game.GetMission().AddActiveInputExcludes({"menu"});       // полное блокирование
g_Game.GetMission().AddActiveInputExcludes({"inventory"});  // только нужные слои
g_Game.GetMission().AddActiveInputExcludes({"radialmenu"}); // радиальные меню
g_Game.GetMission().AddActiveInputExcludes({"map"});
g_Game.GetMission().AddActiveInputExcludes({"inspect"});
```

В деструкторе обязательно `RemoveActiveInputExcludes(...)`. См. [mission.md](mission.md) — input excludes.

#### HUD скрытие

Меню часто прячут HUD:

```c
hud.ShowHudUI(false);       // всё кроме quickbar
hud.ShowQuickbarUI(false);
```

См. [hud.md](hud.md) — HUD visibility API.

#### Console toolbar / Input device hooks

Любое меню с консольной поддержкой:
1. Подписывается на `mission.GetOnInputPresetChanged()` и `GetOnInputDeviceChanged()` в `Init()`/конструкторе
2. В `OnInputDeviceChanged(EInputDeviceType)` переключает курсор/фокус кнопки
3. Использует `InputUtils.GetRichtextButtonIconFromInputAction(actionName, label, deviceType, scale)` для динамических иконок

---

### InGameMenu / InGameMenuXbox

`MENU_INGAME` — пауза. Платформозависимый класс через switch в `MissionBase.CreateScriptedMenu`:

```c
case MENU_INGAME:
    #ifdef PLATFORM_CONSOLE
        menu = new InGameMenuXbox;
    #else
        menu = new InGameMenu;
    #endif
```

#### InGameMenu (PC)

Кнопки: Continue, Restart/Respawn (зависит от MP/SP), Options, Exit, Feedback, Copy server info, Favorite. Плюс отдельные `respawn_button_random/custom` если игрок мёртв.

| Метод | Описание |
|-------|----------|
| `SetGameVersion()` | Прочитать `g_Game.GetVersion()`, написать в `version` widget |
| `SetServerInfo()` | Заполнить server name/IP/port из `OnlineServices.GetCurrentServerInfo()` |
| `OnFavoriteChanged(checked)` | Toggle favorite через `OnlineServices.SetServerFavorited` |
| `CopyServerInfo()` | В буфер обмена — для bug reports |
| `HudShow(bool)` | Прячет/показывает HUD при открытии/закрытии |
| `m_HintPanel : UiHintPanel` | Подсказки на экране паузы |

#### InGameMenuXbox (Console)

Расширенный вариант с интеграцией Xbox Live: список игроков (`PlayerListScriptedWidget`), invite, mute/unmute, gamercard, feedback QR-код. Динамика exit-button cooldown через `m_ExitButtonUpdateTimerSum`/`m_ExitOnCooldown`. Слушает `ClientData.SyncEvent_OnPlayerListUpdate` и `OnlineServices.m_PermissionsAsyncInvoker`.

| Метод | Описание |
|-------|----------|
| `SyncEvent_OnRecievedPlayerList(players)` | Обновить `m_ServerInfoPanel` |
| `OnPermissionsUpdate(...)` | Перепроверить доступность mute/invite/gamercard |
| `OnInputPresetChanged()` / `OnInputDeviceChanged(...)` | Сменить иконки toolbar |
| `UpdateControlsElements()` | Полное обновление button hints |

---

### InspectMenuNew

```c
class InspectMenuNew extends UIScriptedMenu
```

Открывается из `LayoutHolder.InspectItem(item)` (см. [inventory.md](inventory.md)). В конструкторе ставит `AddActiveInputExcludes({"inspect"})`. В `Init()` создаёт `inventory_new/day_z_inventory_new_inspect.layout`. Запускает `PPERequester_InventoryBlur` (постпроцесс blur).

| Метод | Описание |
|-------|----------|
| `SetItem(EntityAI item)` | Установить отображаемый предмет, вызвать `UpdateItemInfo` |
| `static UpdateItemInfo(layoutRoot, item)` | Заполнить все info-поля (название, weight, status…) |
| `OnMouseButtonDown(w, x, y, button)` | Начало вращения мышью |
| `Update(timeslice)` | Обработка вращения/zoom |

3D-модель — `ItemPreviewWidget`, читается `item.GetViewIndex()`. Поддерживает rotation X/Y и scale через mouse drag/wheel.

---

### MapMenu

```c
class MapMenu extends UIScriptedMenu
```

Бумажная карта. Открывается через `UAMapToggle` если игрок владеет картой (или `ignoreMapOwnership` параметр).

#### Состояние

| Поле | Описание |
|------|----------|
| `m_MapWidgetInstance : MapWidget` | Сам widget карты (engine-side) |
| `m_HasCompass` / `m_HasGPS` | Доп. инструменты в инвентаре игрока |
| `m_MapMenuHandler : MapHandler` | Обработчик кликов/drag (см. `gui/maphandler.c`) |
| `m_MapNavigationBehaviour` | Pan/zoom поведение |
| `m_GPSMarker` / `m_GPSMarkerArrow` | Иконка позиции игрока (если есть GPS) |
| `m_ToolsCompassBase`/`Arrow`/`Azimuth` | Compass UI (если есть компас) |
| `m_ToolsScale*` | Масштабная линейка |

#### Поведение

- Стартовая позиция/масштаб через `player.GetLastMapInfo()` или `CfgWorlds %1 centerPosition`
- Сохранение позиции через `player.SetLastMapInfo(scale, pos)` при закрытии
- Compass: `azimuth = -m_MapWidgetInstance.GetMapRotation() % 360`
- GPS: `m_GPSMarker.SetPos(...)` обновляется в `Update()` от `player.GetPosition()`
- Маркеры мира — статический реестр `MapMarkerTypes` (см. [hud.md](hud.md))

---

### NoteMenu

```c
class NoteMenu extends UIScriptedMenu
```

Чтение/запись бумажной заметки.

| Метод | Описание |
|-------|----------|
| `InitNoteRead(text)` | Read-only, показывает `HtmlWidget` |
| `InitNoteWrite(paper, pen, text)` | Edit-mode с `MultilineEditBoxWidget`, читает `pen.ConfigGetString("writingColor")` |
| `OnClick → IDC_OK` | Шлёт `RPC_WRITE_NOTE_CLIENT` с санитизированным текстом через `MiscGameplayFunctions.SanitizeString` |

В конструкторе/деструкторе прячет/показывает HUD UI. Поддерживает `UAUIBack` для закрытия.

---

### BookMenu

Чтение многостраничной книги (`day_z_book.layout`). Простая навигация next/prev page.

---

### GesturesMenu

```c
class GesturesMenu extends UIScriptedMenu
```

Радиальное меню эмоутов с пятью категориями + console-категория:

```c
enum GestureCategories
{
    CATEGORIES, CATEGORY_1, CATEGORY_2, CATEGORY_3, CATEGORY_4, CATEGORY_5,
    CONSOLE_GESTURES
}
```

Каждый эмоут — `GestureMenuItem(id, name, category)`, ссылается на `EmoteBase` через `player.GetEmoteManager().GetNameEmoteMap()`. Показывает забинденную клавишу через `InputUtils.GetComboButtonNamesFromInput(emoteClass.GetInputActionName(), MOUSE_AND_KEYBOARD)`.

| Метод | Описание |
|-------|----------|
| `static OpenMenu(parent)` / `CloseMenu()` | Открыть `MENU_GESTURES` |
| `SwitchCategory(int)` | Переключить страницу |
| `PerformGesture(id)` | Через `player.GetEmoteManager().CreateEmoteCBFromMenu(id)` |

`AddActiveInputExcludes({"radialmenu"})` в конструкторе.

---

### RadialQuickbarMenu

```c
class RadialQuickbarMenu extends UIScriptedMenu
```

Радиальный quickbar для назначения предмета в hotkey-слот.

| Поле | Описание |
|------|----------|
| `static instance` | Singleton |
| `static m_ItemToAssign : EntityAI` | Предмет, который ставится в слот (если открыто из drag) |
| `m_CurrentCategory : int` | Текущая категория (`RadialQuickbarCategory.DEFAULT`) |
| `m_Items : array<RadialQuickbarItem>` | Слоты квикбара как radial-элементы |

| Метод | Описание |
|-------|----------|
| `static OpenMenu(parent)` | Через `g_Game.GetUIManager().EnterScriptedMenu(MENU_RADIAL_QUICKBAR, parent)` |
| `static CloseMenu()` | `Back()` |
| `static SetItemToAssign(item)` / `GetItemToAssign()` | Используется для drag→radial flow из инвентаря |

`AddActiveInputExcludes({"radialmenu"})` в конструкторе.

---

### LogoutMenu

```c
class LogoutMenu extends UIScriptedMenu
```

Таймер дисконнекта (`MissionGameplay.StartLogoutMenu(time)`).

| Поле | Описание |
|------|----------|
| `m_iTime` | Оставшиеся секунды |
| `m_FullTime : FullTimeData` | Помощник форматирования времени |
| `m_bLogoutNow` / `m_bCancel` | Кнопки немедленного выхода/отмены |

В конструкторе: `g_Game.SetKeyboardHandle(this)`, в деструкторе сбрасывает + `Cancel()` если irregular close. Если игрок не restrained/unconscious — `player.GetEmoteManager().SetClientLoggingOut(true)` (садится).

---

### RespawnDialogue

```c
class RespawnDialogue extends UIScriptedMenu
```

Диалог выбора random/custom respawn после смерти.

| Константа | Назначение |
|-----------|------------|
| `ID_RESPAWN_RANDOM = 102` | Случайная точка |
| `ID_RESPAWN_CUSTOM = 101` | Выбор по карте (если поддерживается) |

В `Update`: автозакрытие если `playerAlive && !IsUnconscious()`. `OnMouseEnter` показывает `m_DetailsRoot` tooltip с `#main_menu_respawn_random_tooltip`. `RequestRespawn(bool random)` — RPC к серверу.

---

### InviteMenu

15-секундный таймер в режиме invite-присоединения. В конструкторе ставит игрока в эмоут SITA через `player.GetEmoteManager().CreateEmoteCBFromMenu(EmoteConstants.ID_EMOTE_SITA)` с `EmoteLauncher.FORCE_DIFFERENT`. Прячет HUD UI и quickbar, добавляет `"menu"` в excludes.

---

### WarningMenuBase

```c
class WarningMenuBase : UIScriptedMenu
```

База для warning popup'ов. В конструкторе/деструкторе ставит/снимает `"menu"` excludes и прячет HUD. `Init()` создаёт `day_z_dropped_items.layout`. Override `GetText()` возвращает текст.

| Наследник | Назначение |
|-----------|------------|
| `ItemDropWarningMenu` | "Предметы будут сброшены при выходе" |
| `PlayerRepositionWarningMenu` | "Игрок будет перемещён" |

`InputDeviceDisconnectWarningMenu` — отдельный класс (extends `UIScriptedMenu` напрямую), для warning об отключении контроллера.

---

### LoadingMenu

```c
class LoadingMenu extends UIScriptedMenu
```

Минималистичный экран загрузки: `TextWidget m_label`, `ProgressBarWidget m_progressBar`, `ImageWidget m_image` со случайным фоном через `GetRandomLoadingBackground()`. На Xbox experimental сборках показывает `notification_root` widget.

---

### ConnectionDialogue

`MENU_CONNECTION_DIALOGUE` — диалог при `NetworkInputBufferEventTypeID` (буфер ввода переполнен). Открывается из `MissionGameplay.OnEvent`. Показывает `MultilineTextWidget m_Description` и кнопку Disconnect. Не может быть закрыто кроме как через disconnect.

---

### EarlyAccessMenu / HelpScreen

`EarlyAccessMenu` — splash для experimental builds. `HelpScreen` — статический экран справки `day_z_help_screen.layout`. Оба тривиальны.

---

### PresetsMenu

`MENU_CONTROLS_PRESET` — выбор пресета управления (для KeybindingsMenu). Заполняется из `g_Game.GetInput().GetProfilesCount()`. Простой list-select.

---

### Расширение

Чтобы добавить кастомное меню:

1. Определить новый `MENU_*` ID в 3_Game `constants.c`
2. Создать класс `extends UIScriptedMenu`
3. Override `Init()` — создать layoutRoot из своего layout
4. В `MissionBase.CreateScriptedMenu` (через override mod-mission) добавить `case MENU_MY: menu = new MyMenu; break;`
5. Открывать через `g_Game.GetUIManager().EnterScriptedMenu(MENU_MY, parent_menu)`
6. Не забыть Pause/Continue, input excludes, HUD hide, отписки в деструкторе

См. [mission.md](mission.md) для overview lifecycle и input excludes API.
