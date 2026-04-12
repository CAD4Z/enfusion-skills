## Imagesets — текстурные атласы UI

`.imageset` — текстурный атлас, определяющий именованные прямоугольные области внутри `.edds` текстуры. Используется для иконок, элементов интерфейса и других UI-график. Файлы расположены в `gui/imagesets/`.

Связанная документация:
- Исходный формат текстур (`.edds`): `@.claude/references/DayZ/Textures/edds.md`
- Использование в layout (свойство `image`): `@.claude/references/DayZ/Layouts/format.md`
- Использование в стилях (Item-слоты): `@.claude/references/DayZ/Styles/styles.md`

Формат файла — Enfusion curly-brace синтаксис (как `.layout`).

### Структура файла

```
ImageSetClass {
 Name "dayz_gui"
 RefSize 1024 1024
 Textures {
  ImageSetTextureClass { ... }
 }
 Images {
  ImageSetDefClass IconName { ... }
 }
 Groups {
  ImageSetGroupClass GroupName { ... }
 }
}
```

### ImageSetClass

Корневой элемент файла.

| Свойство | Тип | Описание |
|----------|-----|----------|
| `Name` | string | Имя imageset — используется в ссылках из layout |
| `RefSize` | `W H` | Референсный размер текстуры в пикселях |
| `Textures` | блок | Список текстур (разные уровни детализации) |
| `Images` | блок | Определения изображений |
| `Groups` | блок | Логическая группировка изображений (опционально) |

### ImageSetTextureClass

Текстура-источник. Один imageset может содержать несколько текстур для разных уровней детализации.

| Свойство | Тип | Описание |
|----------|-----|----------|
| `mpix` | int | Уровень детализации текстуры |
| `path` | string | Путь к `.edds` файлу: `"{GUID}path.edds"` |

Наблюдаемые значения `mpix`: `0`, `1`, `2`, `3`. При `mpix 0` — базовая текстура. Более высокие значения соответствуют текстурам повышенного разрешения (паттерн `@2x` в имени файла).

```
Textures {
 ImageSetTextureClass {
  mpix 0
  path "{534691EE0479871C}Gui/imagesets/dayz_gui.edds"
 }
 ImageSetTextureClass {
  mpix 1
  path "{C139E49FD0ECAF9E}Gui/imagesets/dayz_gui@2x.edds"
 }
}
```

### ImageSetDefClass

Определение одного изображения — именованная прямоугольная область на текстуре.

| Свойство | Тип | По умолчанию | Описание |
|----------|-----|-------------|----------|
| `Name` | string | — | Имя изображения (совпадает с именем класса) |
| `Pos` | `X Y` | — | Позиция левого верхнего угла (px, относительно `RefSize`) |
| `Size` | `W H` | — | Размер области (px) |
| `Flags` | int/enum | `0` | Флаги тайлинга (битовая маска) |

#### Flags

Битовая маска, управляющая тайлингом изображения:

| Бит | Значение | Имя | Описание |
|-----|----------|-----|----------|
| 0 | `1` | `ISHorizontalTile` | Горизонтальный тайлинг |
| 1 | `2` | `ISVerticalTile` | Вертикальный тайлинг |

Комбинации: `0` — без тайлинга, `3` — тайлинг в обоих направлениях. Допускается как числовая (`3`), так и именованная (`ISHorizontalTile`) запись.

```
ImageSetDefClass Gradient {
 Name "Gradient"
 Pos 0 317
 Size 75 5
 Flags ISVerticalTile
}
```

### ImageSetGroupClass

Логическая группировка изображений внутри одного imageset. Не влияет на ссылки из layout — служит для организации в редакторе.

| Свойство | Тип | Описание |
|----------|-----|----------|
| `Name` | string | Имя группы |
| `Images` | блок | Определения изображений (те же `ImageSetDefClass`) |

```
Groups {
 ImageSetGroupClass Checkbox {
  Name "Checkbox"
  Images {
   ImageSetDefClass CheckboxHover {
    Name "CheckboxHover"
    Pos 35 102
    Size 26 26
    Flags 0
   }
  }
 }
}
```

### Использование в layout

В `.layout` файлах imageset-изображения подключаются через свойство `image0` виджета `ImageWidgetClass`:

```
image0 "set:dayz_gui image:Gradient"
```

Формат: `set:<имя imageset> image:<имя изображения>`. Подробнее — `Layouts/widgets_visual.md`.
