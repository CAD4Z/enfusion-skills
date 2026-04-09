UI-система: менеджер, меню, виджеты. Источники: `tools/uimanager.c`, `tools/uidata.c`, `gui/`

### UIManager

Менеджер пользовательского интерфейса. Доступ: `g_Game.GetUIManager()`. Источник: `tools/uimanager.c`

#### Меню (proto native)

| Метод | Возврат | Описание |
|-------|---------|----------|
| `EnterScriptedMenu(id, parent)` | `UIScriptedMenu` | Открыть меню по ID |
| `CreateScriptedMenu(id)` | `UIScriptedMenu` | Создать меню (без показа) |
| `ShowScriptedMenu(menu, parent)` | `UIScriptedMenu` | Показать созданное меню |
| `HideScriptedMenu(menu)` | `void` | Скрыть меню |
| `GetMenu()` | `UIScriptedMenu` | Текущее активное меню |
| `IsMenuOpen(id)` | `bool` | Открыто ли меню с ID |
| `CloseAll()` | `void` | Закрыть все меню |
| `Back()` | `void` | Вернуться назад |

#### Диалоги

| Метод | Описание |
|-------|----------|
| `ShowDialog(caption, text, id, buttons, defaultBtn, dialogType, handler)` | Модальный диалог |

#### Курсор (proto native)

| Метод | Описание |
|-------|----------|
| `ShowCursor(visible)` | Показать/скрыть |
| `IsCursorVisible()` | Виден ли |

#### Экран (proto native)

| Метод | Описание |
|-------|----------|
| `ScreenFadeIn(time, color, reason)` | Fade in |
| `ScreenFadeOut(time, color, reason)` | Fade out |
| `IsScreenFadeVisible()` | В процессе |

### UIScriptedMenu

Базовый класс скриптовых меню. Наследует `UIMenuPanel`.

| Метод | Описание |
|-------|----------|
| `Init()` → `Widget` | Инициализация, возвращает корневой виджет |
| `Cleanup()` | Очистка ресурсов |
| `Update(float timeslice)` | Обновление каждый кадр |
| `Refresh()` | Обновление данных |
| `OnShow()` / `OnHide()` | Показ/скрытие |
| `SetFocus(widget)` | Установить фокус |
| `OnClick(w, x, y, button)` → `bool` | Клик по виджету |
| `OnChange(w, x, y, finished)` → `bool` | Изменение значения |
| `OnFocus(w, x, y)` → `bool` | Получение фокуса |
| `OnFocusLost(w, x, y)` → `bool` | Потеря фокуса |
| `IsHandlingPlayerDeathEvent()` → `bool` | Обрабатывает ли смерть |

### UIScriptedWindow

Базовый класс скриптовых окон. Аналогичен `UIScriptedMenu`, но для неполноэкранных окон.

### Виджеты GUI

Источник: `gui/`

#### Tabber

Навигация по вкладкам.

| Метод | Описание |
|-------|----------|
| `SelectTab(index)` | Выбрать вкладку |
| `OnClick(w, x, y, button)` | Обработка клика |

#### Spacers

Управление расположением виджетов.

| Класс | Описание |
|-------|----------|
| `SpacerBase` | Базовый spacer |
| `HorizontalSpacer` | Горизонтальное размещение |
| `VerticalSpacer` | Вертикальное размещение |
| `AutoHeightSpacer` | Автовысота |
| `HorizontalSpacerWithFixedAspect` | Фиксированные пропорции |

#### Анимации

| Класс | Описание |
|-------|----------|
| `HoverEffect` | Эффект при наведении |
| `RadialMenu` | Радиальное меню |
| `RadialProgressBar` | Круговой прогресс-бар |
| `Rotator` | Вращение |
| `Bouncer` | Отскок |

#### Контейнеры

| Класс | Описание |
|-------|----------|
| `ScrollbarContainer` | Прокручиваемый контейнер |
| `SizeToChild` | Размер по дочернему элементу |

#### Подсказки

| Класс | Описание |
|-------|----------|
| `UIHintPanel` | Панель подсказок |
| `HintPage` | Страница подсказки |

### GameplayEffectWidgets_base

Базовый класс UI-оверлеев игровых эффектов. Источник: `gameplayeffectwidgets_base.c`

| Метод | Описание |
|-------|----------|
| `IsAnyEffectRunning()` | Есть активные эффекты |
| `AreEffectsSuspended()` | Эффекты приостановлены |
| `AddActiveEffects(effects)` / `RemoveActiveEffects(effects)` | Управление |
| `StopAllEffects()` | Остановить все |
| `AddSuspendRequest(id)` / `RemoveSuspendRequest(id)` | Приостановка |
| `UpdateWidgets()` / `Update()` | Обновление |
| `OnVoiceEvent(breathing_resistance)` | Событие голоса |
| `SetBreathIntensityStamina(value)` | Интенсивность дыхания |

### EffectWidgetsTypes (ID слоёв)

```
ROOT, NONE, MASK_OCCLUDER, MASK_BREATH,
HELMET_OCCLUDER, HELMET_BREATH, MOTO_OCCLUDER, MOTO_BREATH,
COVER_FLASHBANG, NVG_OCCLUDER, PUMPKIN_OCCLUDER, EYEPATCH_OCCLUDER,
HELMET2_OCCLUDER, BLEEDING_LAYER
```

### Colors

Статические цветовые константы. Источник: `colors.c`

#### Базовые

`RED`, `GREEN`, `BLUE`, `WHITE`, `BLACK`, `YELLOW`, `ORANGE`, `PURPLE`, `CYAN`, `GRAY`, `BROWN`, `WHITEGRAY`

#### Состояние предмета

`COLOR_PRISTINE` (зелёный) → `COLOR_WORN` → `COLOR_DAMAGED` → `COLOR_BADLY_DAMAGED` → `COLOR_RUINED` (красный)

#### Влажность

`COLOR_DRENCHED` (синий) → `COLOR_SOAKING` → `COLOR_WET` → `COLOR_DAMP`

#### Температура

`COLOR_HOT` (красные градации) ↔ `COLOR_COLD` (синие градации)

#### Еда

`COLOR_RAW`, `COLOR_BAKED`, `COLOR_BOILED`, `COLOR_DRIED`, `COLOR_BURNED`, `COLOR_ROTTEN`

#### Карты

`LIVONIA`, `FROSTLINE`, `DAYZ` — палитры по картам

### FadeColors

Цвета затемнения: `WHITE`, `LIGHT_GREY`, `BLACK`, `RED`, `DARK_RED`

### Константы меню (MENU_*)

`MENU_MAIN`, `MENU_INGAME`, `MENU_INVENTORY`, `MENU_OPTIONS`, `MENU_SERVER_BROWSER`, `MENU_LOGIN_QUEUE`, `MENU_LOADING`, `MENU_RESPAWN_DIALOGUE`, `MENU_CHAT`, `MENU_MAP` и др.
