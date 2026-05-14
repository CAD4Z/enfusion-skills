System functions: files, input, time, CLI. Source: `proto/ensystem.c`

### File I/O

Paths support prefixes: `$profile:`, `$saves:`, `$mission:`.

**FileMode:** `READ`, `WRITE`, `APPEND`

| Function | Description |
|---------|----------|
| `FileExist(name)` | Check whether a file exists |
| `OpenFile(name, mode)` | Open a file, returns `FileHandle` or 0 |
| `CloseFile(file)` | Close a file |
| `FPrint(file, var)` | Write a value |
| `FPrintln(file, var)` | Write with newline |
| `FGets(file, out str)` | Read a line, -1 = EOF |
| `ReadFile(file, array, length)` | Read raw data |
| `MakeDirectory(name)` | Create a directory |
| `DeleteFile(name)` | Delete (only `$profile:` / `$saves:`) |
| `CopyFile(src, dest)` | Copy (dest = `$profile:` / `$saves:`) |

**File search:**

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
**FindFileFlags:** `DIRECTORIES` (FS only), `ARCHIVES` (.pak only), `ALL`

### Time

| Function | Description |
|---------|----------|
| `GetHourMinuteSecond(out h, out m, out s)` | System time (local) |
| `GetYearMonthDay(out y, out m, out d)` | System date (local) |
| `GetHourMinuteSecondUTC(out h, out m, out s)` | UTC time |
| `GetYearMonthDayUTC(out y, out m, out d)` | UTC date |
| `TickCount(prev)` | CPU ticks between prev and now (performance) |

### Keyboard

`KeyState(KeyCode key)` — key state: 0 = not pressed, bit 15 = pressed, bits 0-14 = press counter.
`ClearKey(KeyCode key)` — reset state (anti-autorepeat).

**KeyCode enum:** `KC_ESCAPE`, `KC_1`..`KC_0`, `KC_A`..`KC_Z`, `KC_F1`..`KC_F12`, `KC_SPACE`, `KC_RETURN`, `KC_BACK`, `KC_TAB`, `KC_LSHIFT`/`KC_RSHIFT`, `KC_LCONTROL`/`KC_RCONTROL`, `KC_LMENU`/`KC_RMENU` (Alt), `KC_UP`/`KC_DOWN`/`KC_LEFT`/`KC_RIGHT`, `KC_INSERT`, `KC_DELETE`, `KC_HOME`, `KC_END`, `KC_NUMPAD0`..`KC_NUMPAD9`, etc.

### Mouse

| Function | Description |
|---------|----------|
| `GetMouseState(MouseState index)` | Button/axis state |
| `GetMousePos(out x, out y)` | Cursor position |
| `GetScreenSize(out x, out y)` | Screen size |

**MouseState:** `LEFT`, `RIGHT`, `MIDDLE`, `X`, `Y`, `WHEEL`

### Gamepad

| Function | Description |
|---------|----------|
| `GetGamepadButton(GamepadButton)` | Whether a button is pressed |
| `GetGamepadAxis(GamepadAxis)` | Axis value [-1000, 1000] |

**GamepadButton:** `A`, `B`, `X`, `Y`, `MENU`, `VIEW`, `PAD_UP/DOWN/LEFT/RIGHT`, `SHOULDER_LEFT/RIGHT`, `THUMB_LEFT/RIGHT`
**GamepadAxis:** `LEFT_THUMB_HORIZONTAL/VERTICAL`, `RIGHT_THUMB_HORIZONTAL/VERTICAL`, `LEFT_TRIGGER`, `RIGHT_TRIGGER`

### CLI parameters

| Function | Description |
|---------|----------|
| `GetCLIParam(name, out val)` | Get the value of a launch parameter (`-name value`) |
| `IsCLIParam(name)` | Check whether a parameter is present |

### Miscellaneous

| Function | Description |
|---------|----------|
| `GetProfileName()` | Profile name |
| `GetMachineName()` | Machine name |
| `MemoryValidation(enable)` | Memory validation (significant slowdown) |
| `MakeScreenshot(name)` | Screenshot to DDS. `$` prefix = full path |
| `GetFPS()` | Current FPS (averaged over 10 frames) |
