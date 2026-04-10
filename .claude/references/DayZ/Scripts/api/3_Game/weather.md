Динамическая система погоды. Доступ: `g_Game.GetWeather()`. Источник: `weather.c`

### EWeatherPhenomenon

```
OVERCAST, FOG, RAIN, SNOWFALL,
WIND_DIRECTION, WIND_MAGNITUDE,
VOLFOG_HEIGHT_DENSITY, VOLFOG_DISTANCE_DENSITY, VOLFOG_HEIGHT_BIAS
```

### WeatherPhenomenon

Обёртка одного погодного явления. Значения в диапазоне `<0, 1>` (кроме ветра — абсолютные величины).

Typedef-алиасы: `Overcast`, `Fog`, `Rain`, `Snowfall`, `WindDirection`, `WindMagnitude`.

#### Текущее состояние (proto native)

| Метод | Возврат | Описание |
|-------|---------|----------|
| `GetType()` | `EWeatherPhenomenon` | Тип явления |
| `GetActual()` | `float` | Текущее значение |
| `GetForecast()` | `float` | Целевое значение |

#### Управление (proto native)

| Метод | Описание |
|-------|----------|
| `Set(forecast, time, minDuration)` | Установить прогноз. `time` — секунды интерполяции, `minDuration` — мин. длительность |
| `GetNextChange()` / `SetNextChange(time)` | Время до пересчёта прогноза (сек) |
| `GetLimits(out fnMin, out fnMax)` | Пределы значения |
| `SetLimits(fnMin, fnMax)` | Установить пределы (по умолчанию 0..1) |
| `GetForecastChangeLimits(out fcMin, out fcMax)` | Пределы изменения прогноза |
| `SetForecastChangeLimits(fcMin, fcMax)` | Установить пределы изменения |
| `GetForecastTimeLimits(out ftMin, out ftMax)` | Интервал пересчёта (по умолчанию 300..3600 сек) |
| `SetForecastTimeLimits(ftMin, ftMax)` | Установить интервал |

#### Callback

`OnBeforeChange(float change, float time)` → `bool` — вызывается на сервере при пересчёте прогноза. Возврат `true` = скрипт изменил состояние, `false` = стандартная логика. Делегирует в `WorldData.WeatherOnBeforeChange()`.

### Weather

Контроллер погоды. Доступ: `g_Game.GetWeather()`.

#### Явления (proto native)

| Метод | Возврат | Описание |
|-------|---------|----------|
| `GetOvercast()` | `Overcast` | Облачность |
| `GetFog()` | `Fog` | Туман |
| `GetRain()` | `Rain` | Дождь |
| `GetSnowfall()` | `Snowfall` | Снегопад |
| `GetWindDirection()` | `WindDirection` | Направление ветра (радианы, `-PI..+PI`) |
| `GetWindMagnitude()` | `WindMagnitude` | Скорость ветра (м/с) |

#### Ветер (proto native)

| Метод | Описание |
|-------|----------|
| `GetWind()` | Вектор ветра (направление × скорость) |
| `SetWind(wind)` | Установить вектор ветра |
| `GetWindSpeed()` / `SetWindSpeed(speed)` | Скорость ветра (м/с). Минимум 0.1 |
| `GetWindMaximumSpeed()` / `SetWindMaximumSpeed(maxSpeed)` | Максимальная скорость (по умолчанию 10 м/с) |
| `GetWindFunctionParams(out fnMin, out fnMax, out fnSpeed)` | Параметры функции изменения ветра |
| `SetWindFunctionParams(fnMin, fnMax, fnSpeed)` | Установить параметры |

#### Гроза и дождь (proto native)

| Метод | Описание |
|-------|----------|
| `SetStorm(density, threshold, timeOut)` | Гроза: `density` 0..1, `threshold` — порог облачности, `timeOut` — мин. пауза между молниями |
| `SuppressLightningSimulation(state)` | Вкл/выкл симуляцию молний на клиенте |
| `SetRainThresholds(tMin, tMax, tTime)` | Дождь только при облачности в `<tMin, tMax>`. `tTime` — время остановки (по умолчанию 0.6, 1.0, 30) |
| `SetSnowfallThresholds(tMin, tMax, tTime)` | Аналогично для снегопада |

#### Время и управление

| Метод | Описание |
|-------|----------|
| `GetTime()` | Серверное время с запуска (сек) |
| `GetMissionWeather()` / `SetMissionWeather(state)` | Флаг кастомной погоды миссии |
| `GetWeatherUpdateFrozen()` / `SetWeatherUpdateFrozen(state)` | Заморозка обновления погоды |

#### Конвертация (static)

| Метод | Описание |
|-------|----------|
| `WindDirectionToAngle(dir)` | Вектор направления → угол (рад) |
| `AngleToWindDirection(angle)` | Угол → вектор направления |
