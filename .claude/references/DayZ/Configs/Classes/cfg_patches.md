Обязательный класс в каждом `config.cpp`. Регистрирует PBO в системе аддонов движка и определяет зависимости загрузки.

### Структура

```cpp
class CfgPatches
{
    class MyAddonName           // уникальное имя аддона
    {
        units[] = {};           // классы сущностей (CfgVehicles), объявленных в этом PBO
        weapons[] = {};         // классы оружия (CfgWeapons), объявленных в этом PBO
        requiredVersion = 0.1;  // минимальная версия движка
        requiredAddons[] =      // зависимости — имена других CfgPatches
        {
            "DZ_Data"           // этот аддон загрузится ДО текущего
        };
    };
};
```

### Ключевые поля

| Поле | Тип | Описание |
|------|-----|----------|
| `units[]` | string[] | Имена классов из CfgVehicles, которые объявляет этот PBO |
| `weapons[]` | string[] | Имена классов из CfgWeapons, которые объявляет этот PBO |
| `requiredVersion` | float | Минимальная версия движка |
| `requiredAddons[]` | string[] | Имена CfgPatches-аддонов, от которых зависит этот PBO. Определяет порядок загрузки — все зависимости загружаются первыми |

### Пример

```cpp
class CfgPatches
{
    class DZ_Example
    {
        units[] = { "Knife" };
        weapons[] = { "Glock19" };
        requiredVersion = 0.1;
        requiredAddons[] =
        {
            "DZ_Data",
            "DZ_Weapons_Melee",
            "DZ_Pistols"
        };
    };
};
```