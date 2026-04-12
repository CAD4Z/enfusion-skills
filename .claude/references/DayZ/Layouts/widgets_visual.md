## Виджеты — визуальные и рендеринг

Наследование свойств описано в `format.md`.

### Изображения

#### ImageWidgetClass

Отображение изображений и текстур. Наследует: Widget (без UIWidget).

| Свойство | Тип | По умолчанию | Описание |
|----------|-----|-------------|----------|
| `image0` | string | `""` | Изображение из imageset: `"set:name image:icon"` |
| `imageTexture` | string | `""` | Прямой путь к текстуре: `"{GUID}path.edds"` |
| `mode` | enum | `opaque` | Режим: `opaque`, `blend`, `additive` |
| `"src alpha"` | bool | `0` | Использовать альфа-канал источника |
| `"clamp mode"` | enum | `invalid` | Повтор: `invalid`, `wrap`, `clamp`, `border` |
| `"stretch mode"` | enum | `invalid` | Растяжение: `invalid`, `none`, `stretch_w_h`, `fit_w_center` |
| `"flip u"` | bool | `0` | Отразить по горизонтали |
| `"flip v"` | bool | `0` | Отразить по вертикали |
| `filter` | bool | `1` | Фильтрация (сглаживание) |
| `nocache` | bool | `0` | Не кэшировать текстуру |
| `rotation` | vector | `0,0,0` | Вращение (roll, pitch, yaw) |
| `pivot` | vector | `0.5,0.5` | Точка вращения (0–1) |
| `Mask` | string | `""` | Путь к текстуре маски |
| `"Transition width"` | float | `0.1` | Ширина перехода маски |
| `Progress` | float | `1.0` | Прогресс маски (0.0–1.0) |

```
ImageWidgetClass logo {
 image0 "set:dayz_gui image:DayZLogo"
 mode additive
 "src alpha" 1
}
```

#### VideoWidgetClass

Воспроизведение видео. Наследует: Widget (без UIWidget).

| Свойство | Тип | По умолчанию | Описание |
|----------|-----|-------------|----------|
| `video` | string | `""` | Путь к видеофайлу |
| `mode` | enum | `opaque` | Режим отрисовки (как у ImageWidget) |
| `"src alpha"` | bool | `0` | Альфа-канал |
| `"clamp mode"` | enum | `invalid` | Режим повтора |
| `"stretch mode"` | enum | `none` | Режим растяжения |
| `"flip u"` / `"flip v"` | bool | `0` | Отразить |
| `filter` | bool | `1` | Фильтрация |
| `font` | string | `""` | Шрифт субтитров |
| `"text color"` | RGBA | `255,255,255,255` | Цвет текста |
| `"outline size"` | float | `0` | Обводка текста |
| `"outline color"` | RGBA | `0,0,0,0` | Цвет обводки |
| `"text offset"` | `X Y` | `0,0` | Смещение текста |
| `"text background"` | bool | `0` | Фон за текстом |
| `"background color"` | RGBA | `0,0,0,204` | Цвет фона |

---

### 3D-превью

#### ItemPreviewWidgetClass

Превью предмета (3D-модель). Наследует: Widget.

| Свойство | Тип | По умолчанию | Описание |
|----------|-----|-------------|----------|
| `"force flip enable"` | bool | `0` | Разрешить принудительное отзеркаливание |
| `"force flip"` | bool | `0` | Отзеркалить модель |

#### PlayerPreviewWidgetClass

Превью персонажа. Наследует: Widget. Управляется из скриптов, без layout-свойств.

---

### Рендеринг

#### RenderTargetWidgetClass

Рендер-таргет — отображает результат рендеринга камеры. Наследует: Widget.

| Свойство | Тип | По умолчанию | Описание |
|----------|-----|-------------|----------|
| `camera` | int | `0` | Индекс камеры |
| `refresh` | int | `0` | Частота обновления |
| `offset` | int | `-1` | Смещение буфера |
| `xscale` | float | `1` | Масштаб по X |
| `yscale` | float | `1` | Масштаб по Y |
| `filter` | bool | `0` | Фильтрация |

#### RTTextureWidgetClass

Рендер-текстура. Наследует: Widget.

| Свойство | Тип | По умолчанию | Описание |
|----------|-----|-------------|----------|
| `"render always"` | bool | `0` | Рендерить каждый кадр |
| `noclear` | bool | `0` | Не очищать буфер |
| `sRGB` | bool | `0` | sRGB цветовое пространство |

---

### Прочие

#### CanvasWidgetClass

Программное рисование (линии, прямоугольники). Наследует: Widget. Без layout-свойств — рисование через `DrawLine()`, `Clear()`.

#### MapWidgetClass

Виджет карты. Наследует: Widget. Управляется из скриптов.
