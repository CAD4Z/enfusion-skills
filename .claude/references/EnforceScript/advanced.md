### Enum

Перечисления — набор именованных целочисленных констант.

- Имеют тип `int`
- Значение можно задать явно, иначе вычисляется автоматически (предыдущее + 1)
- Enum может наследоваться от другого enum (нумерация продолжается)
- Имя enum как тип ведёт себя как обычный `int` (без проверки допустимых значений)

```cpp
enum MyEnumBase
{
    Alfa = 5,   // 5
    Beta,       // 6
    Gamma       // 7
}

enum MyEnum: MyEnumBase
{
    Blue,       // 8 (продолжает от 7)
    Yellow,     // 9
    Green = 20, // 20
    Orange      // 21
}

void Test()
{
    int a = MyEnum.Beta;     // 6
    MyEnum b = MyEnum.Green; // 20
    int c = b;               // 20
}
```

### Templates (дженерики)

Шаблонные классы позволяют работать с обобщёнными типами. Поддерживается любое количество generic-параметров.

```cpp
class Item<Class T>
{
    T m_Data;

    void Item(T data)
    {
        m_Data = data;
    }

    void SetData(T data) { m_Data = data; }
    T GetData() { return m_Data; }
}

void Method()
{
    Item<string> strItem = new Item<string>("Hello!");
    Item<int> intItem = new Item<int>(72);
    strItem.PrintData(); // "m_Data = 'Hello!'"
    intItem.PrintData(); // "m_Data = 72"
}
```

### typedef

Определение псевдонимов типов. Встроенные typedef для массивов:

| Псевдоним | Раскрытие |
|-----------|-----------|
| `TStringArray` | `array<string>` |
| `TFloatArray` | `array<float>` |
| `TIntArray` | `array<int>` |
| `TClassArray` | `array<class>` |
| `TVectorArray` | `array<vector>` |

### Modded — система моддинга скриптов

Ключевое слово `modded` позволяет внедрить наследника в иерархию классов **без изменения оригинальных скриптов**.

**Принцип работы:**
- `modded class` ведёт себя как наследник оригинала
- При создании `new OriginalClass()` будет создан экземпляр modded-версии
- Доступ к оригиналу через `super`
- При нескольких модах каждый следующий `modded class` наследуется от предыдущего

```cpp
// Оригинальный класс (vanilla)
class ModMe
{
    void Say() { Print("Hello original"); }
}

// Мод 1
modded class ModMe
{
    override void Say()
    {
        Print("Hello modded One");
        super.Say();
    }
}

// Мод 2
modded class ModMe  // наследуется от мода 1, а не от оригинала
{
    override void Say()
    {
        Print("Hello modded Two");
        super.Say();
    }
}

void Test()
{
    ModMe a = new ModMe();
    a.Say();
    // Выведет: "Hello modded Two", "Hello modded One", "Hello original"
}
```

**Modded-константы** — последний загруженный мод переопределяет значение:
```cpp
class BaseTest { const int CONST_BASE = 4; }
class TestConst: BaseTest { const int CONST_TEST = 5; }

modded class TestConst
{
    const int CONST_BASE = 1; // переопределяет родительскую
    const int CONST_TEST = 2; // переопределяет свою
    const int CONST_MOD = 3;  // новая константа
}
```

**Доступ к private-членам** — modded class может обращаться к `private` членам оригинала и переопределять `private` методы:
```cpp
class VanillaClass
{
    private bool imPrivate = false;
    private void DoSomething() { Print("Vanilla"); }
}

modded class VanillaClass
{
    void AccessPvt()
    {
        Print(imPrivate);   // доступ к private-переменной
        DoSomething();      // вызов private-метода
    }

    override void DoSomething() // переопределение private-метода
    {
        super.DoSomething();
        Print("Modded");
    }
}
```
