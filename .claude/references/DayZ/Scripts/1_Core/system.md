Системные функции: файлы, ввод, время, CLI. Источник: `proto/ensystem.c`

### Файловый ввод-вывод

Пути поддерживают префиксы: `$profile:`, `$saves:`, `$mission:`.

**FileMode:** `READ`, `WRITE`, `APPEND`

| Функция | Описание |
|---------|----------|
| `FileExist(name)` | Проверка существования файла |
| `OpenFile(name, mode)` | Открыть файл, возвращает `FileHandle` или 0 |
| `CloseFile(file)` | Закрыть файл |
| `FPrint(file, var)` | Записать значение |
| `FPrintln(file, var)` | Записать с переводом строки |
| `FGets(file, out str)` | Прочитать строку, -1 = EOF |
| `ReadFile(file, array, length)` | Чтение сырых данных |
| `MakeDirectory(name)` | Создать директорию |
| `DeleteFile(name)` | Удалить (только `$profile:` / `$saves:`) |
| `CopyFile(src, dest)` | Копировать (dest = `$profile:` / `$saves:`) |

**Поиск файлов:**

```cpp
string fileName;
FileAttr attr;
FindFileHandle h = FindFile("$profile:*.txt", fileName, attr, FindFileFlags.ALL);
if (h)
{
    // fileName - первый найденный
    while (FindNextFile(h, fileName, attr))
    {
        // следующие файлы
    }
    CloseFindFile(h);
}
```

**FileAttr:** `DIRECTORY`, `HIDDEN`, `READONLY`, `INVALID`
**FindFileFlags:** `DIRECTORIES` (только FS), `ARCHIVES` (только .pak), `ALL`

### Время

| Функция | Описание |
|---------|----------|
| `GetHourMinuteSecond(out h, out m, out s)` | Системное время (локальное) |
| `GetYearMonthDay(out y, out m, out d)` | Системная дата (локальная) |
| `GetHourMinuteSecondUTC(out h, out m, out s)` | Время UTC |
| `GetYearMonthDayUTC(out y, out m, out d)` | Дата UTC |
| `TickCount(prev)` | CPU тики между prev и now (перфоманс) |

### Клавиатура

`KeyState(KeyCode key)` — состояние клавиши: 0 = не нажата, бит 15 = нажата, биты 0-14 = счётчик нажатий.
`ClearKey(KeyCode key)` — сбросить состояние (анти-автоповтор).

**KeyCode enum:** `KC_ESCAPE`, `KC_1`..`KC_0`, `KC_A`..`KC_Z`, `KC_F1`..`KC_F12`, `KC_SPACE`, `KC_RETURN`, `KC_BACK`, `KC_TAB`, `KC_LSHIFT`/`KC_RSHIFT`, `KC_LCONTROL`/`KC_RCONTROL`, `KC_LMENU`/`KC_RMENU` (Alt), `KC_UP`/`KC_DOWN`/`KC_LEFT`/`KC_RIGHT`, `KC_INSERT`, `KC_DELETE`, `KC_HOME`, `KC_END`, `KC_NUMPAD0`..`KC_NUMPAD9` и др.

### Мышь

| Функция | Описание |
|---------|----------|
| `GetMouseState(MouseState index)` | Состояние кнопки/оси |
| `GetMousePos(out x, out y)` | Позиция курсора |
| `GetScreenSize(out x, out y)` | Размер экрана |

**MouseState:** `LEFT`, `RIGHT`, `MIDDLE`, `X`, `Y`, `WHEEL`

### Геймпад

| Функция | Описание |
|---------|----------|
| `GetGamepadButton(GamepadButton)` | Нажата ли кнопка |
| `GetGamepadAxis(GamepadAxis)` | Значение оси [-1000, 1000] |

**GamepadButton:** `A`, `B`, `X`, `Y`, `MENU`, `VIEW`, `PAD_UP/DOWN/LEFT/RIGHT`, `SHOULDER_LEFT/RIGHT`, `THUMB_LEFT/RIGHT`
**GamepadAxis:** `LEFT_THUMB_HORIZONTAL/VERTICAL`, `RIGHT_THUMB_HORIZONTAL/VERTICAL`, `LEFT_TRIGGER`, `RIGHT_TRIGGER`

### CLI параметры

| Функция | Описание |
|---------|----------|
| `GetCLIParam(name, out val)` | Получить значение параметра запуска (`-name value`) |
| `IsCLIParam(name)` | Проверить наличие параметра |

### Прочее

| Функция | Описание |
|---------|----------|
| `GetProfileName()` | Имя профиля |
| `GetMachineName()` | Имя машины |
| `MemoryValidation(enable)` | Валидация памяти (сильное замедление) |
| `MakeScreenshot(name)` | Скриншот в DDS. Префикс `$` = полный путь |
| `GetFPS()` | Текущий FPS (среднее за 10 кадров) |
