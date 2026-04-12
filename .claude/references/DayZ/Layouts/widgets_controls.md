## Виджеты — элементы управления

Наследование свойств и групп описано в `format.md`.

### Кнопки и выбор

Все наследуют: Widget + **UIWidget**.

#### ButtonWidgetClass

Кнопка. Добавляет:

| Свойство | Тип | По умолчанию | Описание |
|----------|-----|-------------|----------|
| `text_proportion` | float | — | Пропорция текста к размеру кнопки |
| `font` | string | — | Шрифт текста кнопки |
| `switch` | enum | `normal` | Поведение: `normal` (нажатие), `once` (переключатель) |

```
ButtonWidgetClass play {
 style DayZDefaultButton
 "no focus" 0
 "next up" "choose_server"
 "next down" "next_character"
 switch normal
}
```

#### CheckBoxWidgetClass

Флажок. Добавляет:

| Свойство | Тип | По умолчанию | Описание |
|----------|-----|-------------|----------|
| `text` | string | `""` | Текст рядом с флажком |
| `checked` | bool | `0` | Начальное состояние |

#### ThreeStateCheckboxWidgetClass

Трёхпозиционный флажок. Добавляет:

| Свойство | Тип | По умолчанию | Описание |
|----------|-----|-------------|----------|
| `text` | string | `""` | Текст |
| `checked` | enum | `none` | Состояние: `none`, `check`, `crossed` |

#### XComboBoxWidgetClass

Выпадающий список. Добавляет:

| Свойство | Тип | По умолчанию | Описание |
|----------|-----|-------------|----------|
| `text` | string | `""` | Текст по умолчанию |

Элементы списка добавляются программно через `AddItem()`.

---

### Прогресс и слайдеры

#### SimpleProgressBarWidgetClass

Простой прогресс-бар. Наследует: Widget + **UIWidget** + **SimpleProgressBarWidget**. Не добавляет собственных свойств.

#### ProgressBarWidgetClass

Стилизуемый прогресс-бар. Наследует: Widget + **UIWidget** + **SimpleProgressBarWidget**. Не добавляет собственных свойств, но поддерживает `style` для визуального оформления.

#### SliderWidgetClass

Ползунок. Наследует SimpleProgressBarWidget +

| Свойство | Тип | По умолчанию | Описание |
|----------|-----|-------------|----------|
| `step` | float | `1` | Шаг изменения значения |
| `"marker thickness"` | float | `0.1` | Толщина маркера (доля от размера) |
| `"fill in"` | bool | `1` | Заполнение полосы до маркера |
| `"draw marker"` | bool | `0` | Отображать маркер |
| `"listen to input"` | bool | `0` | Реагировать на пользовательский ввод |
