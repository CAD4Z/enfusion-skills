## Виджеты — текст

Все наследуют: Widget + **UIWidget** + **Text**. Группа Text описана в `format.md`.

#### TextWidgetClass

Однострочный текст. Не добавляет свойств сверх группы Text.

```
TextWidgetClass label {
 text "#main_menu_play"
 font "gui/fonts/sdf_MetronLight42"
 "text halign" center
 "text valign" center
}
```

#### MultilineTextWidgetClass

Многострочный текст. Добавляет:

| Свойство | Тип | По умолчанию | Описание |
|----------|-----|-------------|----------|
| `wrap` | bool | `0` | Перенос текста по ширине виджета |

#### RichTextWidgetClass

Текст с поддержкой встроенных изображений и форматирования. Добавляет:

| Свойство | Тип | По умолчанию | Описание |
|----------|-----|-------------|----------|
| `wrap` | bool | `0` | Перенос текста |
| `"condense whitespace"` | bool | `0` | Сжимать пробелы |
| `"strip newlines"` | bool | `0` | Удалять переносы строк |

#### EditBoxWidgetClass

Поле текстового ввода. Свойства группы Text — позволяет пользователю вводить текст.
