Dynamic weather system. Access: `g_Game.GetWeather()`. Source: `weather.c`

### EWeatherPhenomenon

```
OVERCAST, FOG, RAIN, SNOWFALL,
WIND_DIRECTION, WIND_MAGNITUDE,
VOLFOG_HEIGHT_DENSITY, VOLFOG_DISTANCE_DENSITY, VOLFOG_HEIGHT_BIAS
```

### WeatherPhenomenon

Wrapper for a single weather phenomenon. Values are in the `<0, 1>` range (except wind, which uses absolute values).

Typedef aliases: `Overcast`, `Fog`, `Rain`, `Snowfall`, `WindDirection`, `WindMagnitude`.

#### Current state (proto native)

| Method | Return | Description |
|--------|--------|-------------|
| `GetType()` | `EWeatherPhenomenon` | Phenomenon type |
| `GetActual()` | `float` | Current value |
| `GetForecast()` | `float` | Target value |

#### Control (proto native)

| Method | Description |
|--------|-------------|
| `Set(forecast, time, minDuration)` | Set forecast. `time` — seconds of interpolation, `minDuration` — minimum duration |
| `GetNextChange()` / `SetNextChange(time)` | Time until forecast recalculation (sec) |
| `GetLimits(out fnMin, out fnMax)` | Value limits |
| `SetLimits(fnMin, fnMax)` | Set limits (default 0..1) |
| `GetForecastChangeLimits(out fcMin, out fcMax)` | Forecast change limits |
| `SetForecastChangeLimits(fcMin, fcMax)` | Set change limits |
| `GetForecastTimeLimits(out ftMin, out ftMax)` | Recalculation interval (default 300..3600 sec) |
| `SetForecastTimeLimits(ftMin, ftMax)` | Set the interval |

#### Callback

`OnBeforeChange(float change, float time)` → `bool` — invoked on the server during forecast recalculation. Returns `true` if the script changed the state, `false` for standard logic. Delegates to `WorldData.WeatherOnBeforeChange()`.

### Weather

Weather controller. Access: `g_Game.GetWeather()`.

#### Phenomena (proto native)

| Method | Return | Description |
|--------|--------|-------------|
| `GetOvercast()` | `Overcast` | Cloud cover |
| `GetFog()` | `Fog` | Fog |
| `GetRain()` | `Rain` | Rain |
| `GetSnowfall()` | `Snowfall` | Snowfall |
| `GetWindDirection()` | `WindDirection` | Wind direction (radians, `-PI..+PI`) |
| `GetWindMagnitude()` | `WindMagnitude` | Wind speed (m/s) |

#### Wind (proto native)

| Method | Description |
|--------|-------------|
| `GetWind()` | Wind vector (direction × speed) |
| `SetWind(wind)` | Set wind vector |
| `GetWindSpeed()` / `SetWindSpeed(speed)` | Wind speed (m/s). Minimum 0.1 |
| `GetWindMaximumSpeed()` / `SetWindMaximumSpeed(maxSpeed)` | Max speed (default 10 m/s) |
| `GetWindFunctionParams(out fnMin, out fnMax, out fnSpeed)` | Wind change function parameters |
| `SetWindFunctionParams(fnMin, fnMax, fnSpeed)` | Set parameters |

#### Storm and rain (proto native)

| Method | Description |
|--------|-------------|
| `SetStorm(density, threshold, timeOut)` | Storm: `density` 0..1, `threshold` — overcast threshold, `timeOut` — minimum pause between lightning strikes |
| `SuppressLightningSimulation(state)` | Enable/disable lightning simulation on the client |
| `SetRainThresholds(tMin, tMax, tTime)` | Rain only when overcast is in `<tMin, tMax>`. `tTime` — stop time (default 0.6, 1.0, 30) |
| `SetSnowfallThresholds(tMin, tMax, tTime)` | Same for snowfall |

#### Time and control

| Method | Description |
|--------|-------------|
| `GetTime()` | Server time since launch (sec) |
| `GetMissionWeather()` / `SetMissionWeather(state)` | Custom mission weather flag |
| `GetWeatherUpdateFrozen()` / `SetWeatherUpdateFrozen(state)` | Freeze weather updates |

#### Conversion (static)

| Method | Description |
|--------|-------------|
| `WindDirectionToAngle(dir)` | Direction vector → angle (rad) |
| `AngleToWindDirection(angle)` | Angle → direction vector |
