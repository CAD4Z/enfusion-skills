Chat — display and input of messages across channels. Sources: `gui/chat/`

### Architecture

```
MissionGameplay
  ├── m_Chat : Chat                          ← display (12 lines)
  │     └── m_Lines : array<ChatLine>
  │           └── ChatLine (one widget from day_z_chat_item.layout)
  └── ChatInputMenu (MENU_CHAT_INPUT)        ← input
```

`Chat` is created in `MissionGameplay.OnInit` via `m_Chat.Init(ChatFrameWidget)`. `ChatInputMenu` is a `UIScriptedMenu` opened through `MissionGameplay.ShowChat()` (on `UAChat`).

---

### Channels

```c
CCSystem               = 1
CCAdmin                = 2
CCDirect               = 4
CCMegaphone            = 8
CCTransmitter          = 16
CCPublicAddressSystem  = 32
CCBattlEye             = 64
```

`channel == 0` — local "self" messages (singleplayer chat).

Channel filtering via `EDayZProfilesOptions`:

| Channel | Profile option |
|---------|----------------|
| `CCSystem` / `CCBattlEye` | `GAME_MESSAGES` |
| `CCAdmin` | `ADMIN_MESSAGES` |
| `CCDirect` / `CCMegaphone` / `CCTransmitter` / `CCPublicAddressSystem` | `PLAYER_MESSAGES` |

If the corresponding option is enabled, messages on this channel are not shown.

---

### Chat

```c
class Chat
```

| Field | Description |
|-------|-------------|
| `LINE_COUNT = 12` | Maximum visible lines |
| `m_RootWidget` | `ChatFrameWidget` from the HUD layout |
| `m_LineHeight` | Line height (h / LINE_COUNT) |
| `m_LastLine` | Index of the last added line (cyclic) |
| `m_Lines : array<ChatLine>` | Pool of 12 ChatLines |

| Method | Description |
|--------|-------------|
| `Init(rootWidget)` | Create a pool of `LINE_COUNT` ChatLines under `m_RootWidget` |
| `Destroy()` | Clear the pool |
| `Clear()` | Hide all lines (without removing) |
| `Add(ChatMessageEventParams)` | Accept a message, filter by channel/option, split into parts if longer than `ChatMaxUserLength`/`ChatMaxSystemLength` |
| `AddInternal(params)` | Cyclically write to `m_Lines[(m_LastLine+1) % count]` and shift positions of other lines up |

`ChatMessageEventParams` (3_Game) — `Param4<int channel, string sender, string text, string colorParam>`.

Length: system messages may be longer (`ChatMaxSystemLength`); user messages are split into chunks of `ChatMaxUserLength` via `Substring(pos, length)` in a loop.

---

### ChatLine

```c
class ChatLine
```

One widget from `gui/layouts/day_z_chat_item.layout` (`ChatItemSenderWidget` + `ChatItemTextWidget`).

#### Constants

| Constant | Value |
|----------|-------|
| `FADE_TIMEOUT` | 30s — while the line is visible |
| `FADE_OUT_DURATION` | 3s |
| `FADE_IN_DURATION` | 0.5s |
| `DEFAULT_COLOUR` | white |
| `GAME_TEXT_COLOUR` | red |
| `ADMIN_TEXT_COLOUR` | yellow |

#### Channel prefixes

| Channel | Sender prefix |
|---------|---------------|
| `CCSystem` | `(#layout_chat_game)` (if a name is present) |
| `CCAdmin` | `(#STR_MP_MASTER): ` |
| `CCTransmitter` | `(#str_radio) sender :` |
| `CCDirect` / `0` | `sender :` |

#### Method `Set(params)`

1. Reset name + text widgets
2. Switch on `params.param1` (channel) — set sender prefix and color via `SetColorByParam`
3. Write `params.param3` into `m_TextWidget`
4. `m_FadeTimer.FadeIn(rootWidget, FADE_IN_DURATION)` — fade in
5. `m_TimeoutTimer.Run(FADE_TIMEOUT, m_FadeTimer, "FadeOut", ...)` — deferred fade out

#### SetColorByParam

`params.param4` — string color name (if set by the server):

| Name | Color |
|------|-------|
| `colorStatusChannel` | `COLOR_BLUE` |
| `colorAction` | `COLOR_YELLOW` |
| `colorFriendly` | `COLOR_GREEN` |
| `colorImportant` | `COLOR_RED` |

If empty — falls back to the channel color (`GAME_TEXT_COLOUR`/`ADMIN_TEXT_COLOUR`).

---

### ChatInputMenu

```c
class ChatInputMenu extends UIScriptedMenu
```

`MENU_CHAT_INPUT`. Layout — `gui/layouts/day_z_chat_input.layout` with a single `EditBoxWidget` and a `TextWidget` for the channel name. Opened from `MissionGameplay.OnUpdate` on `UAChat` (non-console only).

| Field | Description |
|-------|-------------|
| `m_edit_box : EditBoxWidget` | Input field |
| `m_channel_text : TextWidget` | Name of the current channel |
| `m_BackInputWrapper : UAIDWrapper` | Persistent wrapper for `UAUIBack` |
| `m_close_timer : Timer` | Deferred close after Enter |

#### Lifecycle

| Method | Description |
|--------|-------------|
| `Init()` | Create layout, get `UAUIBack` wrapper, `UpdateChannel()` |
| `UseKeyboard()` | `return true` — keyboard input mode |
| `OnShow()` | `SetFocus(m_edit_box)` |
| `OnHide()` | `mission.HideChat()`, `HideVoiceLevelWidgets()` if VoN is not active |
| `OnChange(w, x, y, finished)` | On Enter: `g_Game.ChatPlayer(text)` → send over the network; for SP creates a local `ChatMessageEventParams(CCDirect, name, text, "")` and pushes it to `m_Chat.Add` immediately |
| `Update(timeslice)` | `UAUIBack.LocalPress` → `Close()` |
| `UpdateChannel()` | Fill `m_channel_text` via `GetChannelName(channel)` |
| `static GetChannelName(channel)` | `CCSystem` → "System", `CCAdmin` → "Admin", `CCDirect` → "Direct", `CCMegaphone` → "Megaphone", `CCTransmitter` → "Radio", `CCPublicAddressSystem` → "PAS" |

After sending: `m_close_timer.Run(0.1, this, "Close")` (deferred so it doesn't catch an extra keypress) and `UAPersonView.Supress()` (suppress hold-key).

---

### Display pipeline

The server sends a chat message → client receives `ChatMessageEventTypeID` event → `MissionGameplay.OnEvent`:

```c
case ChatMessageEventTypeID:
    ChatMessageEventParams chat_params = ChatMessageEventParams.Cast(params);
    m_Chat.Add(chat_params);
    break;
```

→ `Chat.Add` filters by profile options → `AddInternal` cyclically into `m_Lines`.

`ChatChannelEventTypeID` — a separate channel-change event that updates `MissionGameplay` (fade timer of the channel indicator).

See [mission.md](mission.md) — event handler.
