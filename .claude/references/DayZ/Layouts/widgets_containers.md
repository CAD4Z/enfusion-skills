## Виджеты — контейнеры

Наследование свойств и групп описано в `format.md`.

### Базовые контейнеры

#### FrameWidgetClass

Базовый контейнер. Только свойства Widget. Используется как корневой элемент layout-файлов и как структурная обёртка.

```
FrameWidgetClass root {
 size 1 1
 hexactsize 0
 vexactsize 0
}
```

#### ContentWidgetClass

Аналогичен FrameWidget. Только свойства Widget.

#### PanelWidgetClass

Контейнер с визуальным фоном. Наследует: Widget + **UIWidget**.

Не добавляет собственных свойств — использует `style` и `color` для оформления фона.

```
PanelWidgetClass background {
 color 0 0 0 0.549
 style DayZDefaultPanel
}
```

#### SmartPanelWidgetClass

Панель с автоматической подгонкой. Наследует: Widget + **UIWidget**. Не добавляет свойств сверх UIWidget.

---

### Spacer-контейнеры

Все наследуют: Widget + **UIWidget** + **SpacerWidget**.

#### WrapSpacerWidgetClass

Автоматически располагает дочерние элементы с переносом на новую строку. Не добавляет свойств сверх SpacerWidget.

```
WrapSpacerWidgetClass toolbar {
 Padding 8
 Margin 0
 "Size To Content H" 1
 "Size To Content V" 1
 content_halign center
 content_valign bottom
}
```

#### GridSpacerWidgetClass

Раскладка сеткой. Наследует SpacerWidget +

| Свойство | Тип | По умолчанию | Описание |
|----------|-----|-------------|----------|
| `Columns` | int | `3` | Количество столбцов |
| `Rows` | int | `3` | Количество строк |

```
GridSpacerWidgetClass stats {
 Columns 1
 Rows 5
 Padding 4
 Margin 6
 "Size To Content V" 1
}
```

#### ScrollWidgetClass

Прокручиваемый контейнер. Наследует SpacerWidget (только `"Ignore invisible"`) +

| Свойство | Тип | По умолчанию | Описание |
|----------|-----|-------------|----------|
| `"Scrollbar H"` | bool | `0` | Горизонтальная полоса прокрутки |
| `"Scrollbar V"` | bool | `0` | Вертикальная полоса прокрутки |
| `"Scrollbar V Left"` | bool | `0` | Полоса прокрутки слева |
