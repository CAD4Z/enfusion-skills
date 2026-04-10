Препроцессорные дефайны (задаются C++ стороной). Источник: `defines.c`

Используются в `#ifdef` / `#ifndef` блоках для условной компиляции.

### Версия и режимы

| Define | Описание |
|--------|----------|
| `DAYZ_X_XX` | Версия игры (напр. `DAYZ_1_16`) |
| `BULDOZER` | Режим Buldozer |
| `WORKBENCH` | Компиляция для Workbench |

### Билды

Один из `DEVELOPER` / `RELEASE` всегда активен.

| Define | Описание |
|--------|----------|
| `DIAG` | Диагностический билд |
| `DEVELOPER` | Девелоперский билд |
| `RELEASE` | Релизный билд |
| `DIAG_DEVELOPER` | `DIAG \|\| DEVELOPER` |
| `BUILD_EXPERIMENTAL` | Экспериментальный билд |

### Сервер

Определены только когда `CGame.IsDedicatedServer == true`.

| Define | Описание |
|--------|----------|
| `SERVER` | Выделенный сервер (предпочитай над `IsDedicatedServer()`) |
| `SERVER_FOR_WINDOWS` | Сервер для Windows клиентов (определён и на Linux серверах) |
| `SERVER_FOR_X1` | Сервер для Xbox |
| `SERVER_FOR_PS4` | Сервер для PlayStation |
| `SERVER_FOR_CONSOLE` | `SERVER_FOR_X1 \|\| SERVER_FOR_PS4` |
| `NO_GUI` | Нет GUI (серверный билд) |
| `NO_GUI_INGAME` | Нет внутриигрового GUI |

### Платформа

| Define | Описание |
|--------|----------|
| `PLATFORM_WINDOWS` | Windows |
| `PLATFORM_LINUX` | Linux |
| `PLATFORM_XBOX` | Xbox |
| `PLATFORM_PS4` | PlayStation |
| `PLATFORM_MSSTORE` | Microsoft Store |
| `PLATFORM_CONSOLE` | `XBOX \|\| PS4 \|\| MSSTORE` |

### Логирование

Управляется через параметры запуска.

| Define | Параметр | Описание |
|--------|----------|----------|
| `ENABLE_LOGGING` | `-doScriptLogs=1` | Включить скриптовое логирование |
| `LOG_TO_FILE` | `-logToFile=1` | Лог в файл (default: 1 internal, 0 retail) |
| `LOG_TO_SCRIPT` | `-logToScript=1` | Лог в скрипт (default: 1 internal, 0 retail) |
| `LOG_TO_RPT` | `-logToRpt=1` | Лог в RPT (default: 0) |

### Feature flags

| Define | Описание |
|--------|----------|
| `FEATURE_CURSOR` | WIP: предотвращение перехвата курсора игрой |
| `FEATURE_NETWORK_RECONCILIATION` | WIP: новая сетевая реконсиляция игроков |

### Пример использования

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
