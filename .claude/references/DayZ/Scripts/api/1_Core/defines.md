Preprocessor defines (set by the C++ side). Source: `defines.c`

Used in `#ifdef` / `#ifndef` blocks for conditional compilation.

### Version and modes

| Define | Description |
|--------|----------|
| `DAYZ_X_XX` | Game version (e.g. `DAYZ_1_16`) |
| `BULDOZER` | Buldozer mode |
| `WORKBENCH` | Compilation for Workbench |

### Builds

One of `DEVELOPER` / `RELEASE` is always active.

| Define | Description |
|--------|----------|
| `DIAG` | Diagnostic build |
| `DEVELOPER` | Developer build |
| `RELEASE` | Release build |
| `DIAG_DEVELOPER` | `DIAG \|\| DEVELOPER` |
| `BUILD_EXPERIMENTAL` | Experimental build |

### Server

Defined only when `CGame.IsDedicatedServer == true`.

| Define | Description |
|--------|----------|
| `SERVER` | Dedicated server (prefer over `IsDedicatedServer()`) |
| `SERVER_FOR_WINDOWS` | Server for Windows clients (defined on Linux servers too) |
| `SERVER_FOR_X1` | Server for Xbox |
| `SERVER_FOR_PS4` | Server for PlayStation |
| `SERVER_FOR_CONSOLE` | `SERVER_FOR_X1 \|\| SERVER_FOR_PS4` |
| `NO_GUI` | No GUI (server build) |
| `NO_GUI_INGAME` | No in-game GUI |

### Platform

| Define | Description |
|--------|----------|
| `PLATFORM_WINDOWS` | Windows |
| `PLATFORM_LINUX` | Linux |
| `PLATFORM_XBOX` | Xbox |
| `PLATFORM_PS4` | PlayStation |
| `PLATFORM_MSSTORE` | Microsoft Store |
| `PLATFORM_CONSOLE` | `XBOX \|\| PS4 \|\| MSSTORE` |

### Logging

Controlled via launch parameters.

| Define | Parameter | Description |
|--------|----------|----------|
| `ENABLE_LOGGING` | `-doScriptLogs=1` | Enable script logging |
| `LOG_TO_FILE` | `-logToFile=1` | Log to file (default: 1 internal, 0 retail) |
| `LOG_TO_SCRIPT` | `-logToScript=1` | Log to script (default: 1 internal, 0 retail) |
| `LOG_TO_RPT` | `-logToRpt=1` | Log to RPT (default: 0) |

### Feature flags

| Define | Description |
|--------|----------|
| `FEATURE_CURSOR` | WIP: prevents the game from capturing the cursor |
| `FEATURE_NETWORK_RECONCILIATION` | WIP: new network reconciliation for players |

### Usage example

```cpp
#ifdef SERVER
    // код только для выделенного сервера
#endif

#ifdef DIAG_DEVELOPER
    // отладочный код, не попадёт в релиз
#endif

#ifdef PLATFORM_CONSOLE
    // адаптация UI для консолей
#endif
```
