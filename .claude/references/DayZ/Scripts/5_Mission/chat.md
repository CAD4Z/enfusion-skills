Чат — отображение и ввод сообщений по каналам. Источники: `gui/chat/`

### Архитектура

```
MissionGameplay
  ├── m_Chat : Chat                          ← дисплей (12 строк)
  │     └── m_Lines : array<ChatLine>
  │           └── ChatLine (один widget из day_z_chat_item.layout)
  └── ChatInputMenu (MENU_CHAT_INPUT)        ← ввод
```

`Chat` создаётся в `MissionGameplay.OnInit` через `m_Chat.Init(ChatFrameWidget)`. `ChatInputMenu` — `UIScriptedMenu`, открывается через `MissionGameplay.ShowChat()` (по `UAChat`).

---

### Каналы

```c
CCSystem               = 1
CCAdmin                = 2
CCDirect               = 4
CCMegaphone            = 8
CCTransmitter          = 16
CCPublicAddressSystem  = 32
CCBattlEye             = 64
```

`channel == 0` — локальные сообщения "себе" (singleplayer chat).

Filter по каналам через `EDayZProfilesOptions`:

| Канал | Profile option |
|-------|----------------|
| `CCSystem` / `CCBattlEye` | `GAME_MESSAGES` |
| `CCAdmin` | `ADMIN_MESSAGES` |
| `CCDirect` / `CCMegaphone` / `CCTransmitter` / `CCPublicAddressSystem` | `PLAYER_MESSAGES` |

Если соответствующая опция включена — сообщения этого канала не показываются.

---

### Chat

```c
class Chat
```

| Поле | Описание |
|------|----------|
| `LINE_COUNT = 12` | Максимум видимых строк |
| `m_RootWidget` | `ChatFrameWidget` из HUD layout'а |
| `m_LineHeight` | Высота строки (h / LINE_COUNT) |
| `m_LastLine` | Индекс последней добавленной (cyclic) |
| `m_Lines : array<ChatLine>` | Пул из 12 ChatLine'ов |

| Метод | Описание |
|-------|----------|
| `Init(rootWidget)` | Создать пул из `LINE_COUNT` ChatLine'ов под `m_RootWidget` |
| `Destroy()` | Очистить пул |
| `Clear()` | Скрыть все строки (без удаления) |
| `Add(ChatMessageEventParams)` | Принять сообщение, отфильтровать по каналу/опции, разбить на части если длиннее `ChatMaxUserLength`/`ChatMaxSystemLength` |
| `AddInternal(params)` | Циклически записать в `m_Lines[(m_LastLine+1) % count]` и сдвинуть позиции остальных строк вверх |

`ChatMessageEventParams` (3_Game) — `Param4<int channel, string sender, string text, string colorParam>`.

Длина: системные сообщения могут быть длиннее (`ChatMaxSystemLength`), пользовательские режутся на куски по `ChatMaxUserLength` через `Substring(pos, length)` в цикле.

---

### ChatLine

```c
class ChatLine
```

Один widget из `gui/layouts/day_z_chat_item.layout` (`ChatItemSenderWidget` + `ChatItemTextWidget`).

#### Константы

| Константа | Значение |
|-----------|----------|
| `FADE_TIMEOUT` | 30s — пока строка видима |
| `FADE_OUT_DURATION` | 3s |
| `FADE_IN_DURATION` | 0.5s |
| `DEFAULT_COLOUR` | белый |
| `GAME_TEXT_COLOUR` | красный |
| `ADMIN_TEXT_COLOUR` | жёлтый |

#### Префиксы по каналам

| Канал | Префикс sender |
|-------|----------------|
| `CCSystem` | `(#layout_chat_game)` (если есть имя) |
| `CCAdmin` | `(#STR_MP_MASTER): ` |
| `CCTransmitter` | `(#str_radio) sender :` |
| `CCDirect` / `0` | `sender :` |

#### Method `Set(params)`

1. Reset name + text widgets
2. Switch по `params.param1` (channel) — установить sender prefix и цвет через `SetColorByParam`
3. Записать `params.param3` в `m_TextWidget`
4. `m_FadeTimer.FadeIn(rootWidget, FADE_IN_DURATION)` — fade in
5. `m_TimeoutTimer.Run(FADE_TIMEOUT, m_FadeTimer, "FadeOut", ...)` — отложенный fade out

#### SetColorByParam

`params.param4` — строковое имя цвета (если задано сервером):

| Имя | Цвет |
|-----|------|
| `colorStatusChannel` | `COLOR_BLUE` |
| `colorAction` | `COLOR_YELLOW` |
| `colorFriendly` | `COLOR_GREEN` |
| `colorImportant` | `COLOR_RED` |

Если пусто — fallback на цвет канала (`GAME_TEXT_COLOUR`/`ADMIN_TEXT_COLOUR`).

---

### ChatInputMenu

```c
class ChatInputMenu extends UIScriptedMenu
```

`MENU_CHAT_INPUT`. Layout — `gui/layouts/day_z_chat_input.layout` с одним `EditBoxWidget` и `TextWidget` названия канала. Открывается из `MissionGameplay.OnUpdate` по `UAChat` (только non-console).

| Поле | Описание |
|------|----------|
| `m_edit_box : EditBoxWidget` | Поле ввода |
| `m_channel_text : TextWidget` | Имя текущего канала |
| `m_BackInputWrapper : UAIDWrapper` | Persistent wrapper для `UAUIBack` |
| `m_close_timer : Timer` | Отложенное закрытие после Enter |

#### Lifecycle

| Метод | Описание |
|-------|----------|
| `Init()` | Создать layout, получить `UAUIBack` wrapper, `UpdateChannel()` |
| `UseKeyboard()` | `return true` — режим клавиатурного ввода |
| `OnShow()` | `SetFocus(m_edit_box)` |
| `OnHide()` | `mission.HideChat()`, `HideVoiceLevelWidgets()` если VoN не активен |
| `OnChange(w, x, y, finished)` | На Enter: `g_Game.ChatPlayer(text)` → отправка через сеть; для SP создаёт локальный `ChatMessageEventParams(CCDirect, name, text, "")` и кладёт в `m_Chat.Add` сразу |
| `Update(timeslice)` | `UAUIBack.LocalPress` → `Close()` |
| `UpdateChannel()` | Заполнить `m_channel_text` через `GetChannelName(channel)` |
| `static GetChannelName(channel)` | `CCSystem` → "System", `CCAdmin` → "Admin", `CCDirect` → "Direct", `CCMegaphone` → "Megaphone", `CCTransmitter` → "Radio", `CCPublicAddressSystem` → "PAS" |

После отправки: `m_close_timer.Run(0.1, this, "Close")` (отложено чтобы не схватить лишний keypress) и `UAPersonView.Supress()` (подавить hold-key).

---

### Pipeline отображения

Сервер шлёт chat сообщение → клиент получает событие `ChatMessageEventTypeID` → `MissionGameplay.OnEvent`:

```c
case ChatMessageEventTypeID:
    ChatMessageEventParams chat_params = ChatMessageEventParams.Cast(params);
    m_Chat.Add(chat_params);
    break;
```

→ `Chat.Add` фильтрует по profile options → `AddInternal` циклически в `m_Lines`.

`ChatChannelEventTypeID` — отдельное событие смены канала, обновляет `MissionGameplay` (fade timer индикатора канала).

См. [mission.md](mission.md) — событийный handler.
