Чтение конфигов из Enforce Script, глобальный доступ — `GetGame()`. 
Путь формируется через пробелы: `"CfgКласс ИмяКласса свойство"`.

| Метод | Возврат | Описание |
|-------|---------|----------|
| `ConfigGetFloat(path)` | `float` | Числовое значение с плавающей точкой |
| `ConfigGetInt(path)` | `int` | Целочисленное значение |
| `ConfigGetText(path, out value)` | `bool` | Строковое значение (возвращает успех) |
| `ConfigGetVector(path)` | `vector` | Вектор (x,y,z) |
| `ConfigGetTextArray(path, out values)` | `void` | Массив строк |
| `ConfigGetTextArrayRaw(path, out values)` | `void` | Массив строк без локализации (`$STR_` не переводятся) |
| `ConfigGetFloatArray(path, out values)` | `void` | Массив float |
| `ConfigGetIntArray(path, out values)` | `void` | Массив int |
| `ConfigGetType(path)` | `int` | Тип значения: `CT_INT`, `CT_FLOAT`, `CT_STRING`, `CT_ARRAY`, `CT_CLASS` |
| `ConfigGetChildrenCount(path)` | `int` | Количество подклассов |
| `ConfigGetChildName(path, index, out name)` | `bool` | Имя подкласса по индексу |
| `ConfigGetBaseName(path, out name)` | `bool` | Имя родительского класса |
| `ConfigIsExisting(path)` | `bool` | Проверка существования пути |
| `ConfigGetFullPath(path, out array)` | `void` | Полная цепочка наследования |

Дополнительно для серверного конфига:
| `ServerConfigGetInt(name)` | `int` | Значение из serverDZ.cfg |

### Доступ через объект — Object

Относительно класса конкретного объекта (не нужно указывать `CfgVehicles ClassName`):

| Метод | Описание |
|-------|----------|
| `ConfigGetFloat(entry)` | float-свойство объекта |
| `ConfigGetVector(entry)` | vector-свойство |
| `ConfigGetBool(entry)` | bool (обёртка над ConfigGetInt == 1) |
| `ConfigGetTextArray(entry, out values)` | Массив строк |
| `ConfigGetFloatArray(entry, out values)` | Массив float |
| `ConfigGetIntArray(entry, out values)` | Массив int |
| `ConfigIsExisting(entry)` | Проверка существования |

### Константы путей

```cpp
const string CFG_VEHICLESPATH  = "CfgVehicles";
const string CFG_WEAPONSPATH   = "CfgWeapons";
const string CFG_MAGAZINESPATH = "CfgMagazines";
```

### Комплексный пример

```cpp
// Чтение свойств предмета по имени класса
string className = "AlarmClock_Green";

// float
float weight = GetGame().ConfigGetFloat("CfgVehicles " + className + " weight");

// int
int scope = GetGame().ConfigGetInt("CfgVehicles " + className + " scope");

// string
string model;
GetGame().ConfigGetText("CfgVehicles " + className + " model", model);

// string[] — массив строк
TStringArray slots = new TStringArray;
GetGame().ConfigGetTextArray("CfgVehicles " + className + " inventorySlot", slots);

// float[] — массив float
TFloatArray size = new TFloatArray;
GetGame().ConfigGetFloatArray("CfgVehicles " + className + " itemSize", size);

// int[] — массив int
TIntArray intValues = new TIntArray;
GetGame().ConfigGetIntArray("CfgVehicles " + className + " repairableWithKits", intValues);

// Проверка существования свойства
bool hasAttachments = GetGame().ConfigIsExisting("CfgVehicles " + className + " attachments");

// Тип значения
int type = GetGame().ConfigGetType("CfgVehicles " + className + " weight");
// type == CT_FLOAT

// Обход подклассов
string dmgPath = "CfgVehicles " + className + " DamageSystem GlobalHealth";
int count = GetGame().ConfigGetChildrenCount(dmgPath);
for (int i = 0; i < count; i++)
{
    string childName;
    GetGame().ConfigGetChildName(dmgPath, i, childName);
    // childName == "Health"
}

// Имя базового класса
string baseName;
GetGame().ConfigGetBaseName("CfgVehicles " + className, baseName);
// baseName == "AlarmClock_ColorBase"
```

### Чтение через объект

```cpp
// Когда уже есть ссылка на объект — путь относительный
Object item = GetGame().CreateObject("AlarmClock_Green", pos);

float w = item.ConfigGetFloat("weight");
bool exists = item.ConfigIsExisting("inventorySlot");

TStringArray slotNames = new TStringArray;
item.ConfigGetTextArray("inventorySlot", slotNames);
```

### Определение реестра по классу

```cpp
// Предмет может быть в CfgVehicles, CfgWeapons или CfgMagazines
// Паттерн определения:
string typeName = "Glock19";
string cfgPath;

if (GetGame().ConfigIsExisting(CFG_VEHICLESPATH + " " + typeName))
    cfgPath = CFG_VEHICLESPATH;
else if (GetGame().ConfigIsExisting(CFG_WEAPONSPATH + " " + typeName))
    cfgPath = CFG_WEAPONSPATH;
else if (GetGame().ConfigIsExisting(CFG_MAGAZINESPATH + " " + typeName))
    cfgPath = CFG_MAGAZINESPATH;

// cfgPath == "CfgWeapons"
```