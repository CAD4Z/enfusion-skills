Статические константы. Источник: `constants.c`

### Input Device

Маски и идентификаторы устройств ввода. Используются для низкоуровневой работы с вводом.

**Устройства:**

| Константа | Значение | Описание |
|-----------|----------|----------|
| `INPUT_DEVICE_KEYBOARD` | `0x00000000` | Клавиатура |
| `INPUT_DEVICE_MOUSE` | `0x00100000` | Кнопки мыши |
| `INPUT_DEVICE_STICK` | `0x00200000` | Джойстик |
| `INPUT_DEVICE_XINPUT` | `0x00300000` | XInput (Xbox контроллер) |
| `INPUT_DEVICE_TRACKIR` | `0x00400000` | TrackIR |
| `INPUT_DEVICE_GAMEPAD` | `0x00500000` | Геймпад |

**Типы действий:**

| Константа | Описание |
|-----------|----------|
| `INPUT_ACTION_TYPE_STATE` | Состояние (зажата) |
| `INPUT_ACTION_TYPE_DOWN_EVENT` | Нажатие |
| `INPUT_ACTION_TYPE_UP_EVENT` | Отпускание |
| `INPUT_ACTION_TYPE_SHORTCLICK_EVENT` | Короткий клик |
| `INPUT_ACTION_TYPE_HOLD_EVENT` | Удержание |
| `INPUT_ACTION_TYPE_DOUBLETAP` | Двойное нажатие |

**Маски:** `INPUT_MODULE_TYPE_MASK`, `INPUT_KEY_MASK`, `INPUT_ACTION_TYPE_MASK`, `INPUT_AXIS`, `INPUT_POV`, `INPUT_COMBO_MASK`

**Комбинированные:** `INPUT_DEVICE_MOUSE_AXIS`, `INPUT_DEVICE_STICK_AXIS`, `INPUT_DEVICE_GAMEPAD_AXIS`

### Цвета

ARGB формат (0xAARRGGBB).

| Константа | Цвет | Значение |
|-----------|------|----------|
| `COLOR_WHITE` | Белый | `0xFFFFFFFF` |
| `COLOR_RED` | Красный | `0xFFF22613` |
| `COLOR_GREEN` | Зелёный | `0xFF2ECC71` |
| `COLOR_BLUE` | Синий | `0xFF4B77BE` |
| `COLOR_YELLOW` | Жёлтый | `0xFFF7CA18` |
| `COLOR_RED_A` | Красный (прозрачный) | `0x1fF22613` |
| `COLOR_GREEN_A` | Зелёный (прозрачный) | `0x1f2ECC71` |
| `COLOR_BLUE_A` | Синий (прозрачный) | `0x1f4B77BE` |
| `COLOR_YELLOW_A` | Жёлтый (прозрачный) | `0x1fF7CA18` |

### Строки

`STRING_EMPTY = ""`

### Материалы

Идентификаторы физических материалов. При добавлении новых — не забудь обновить `physics/materials.xml`.

| Константа | Значение | Описание |
|-----------|----------|----------|
| `MATERIAL_DEFAULT` | 0 | По умолчанию |
| `MATERIAL_METAL` | 1 | Сталь |
| `MATERIAL_IRON` | 2 | Железо |
| `MATERIAL_GLASS` | 3 | Стекло |
| `MATERIAL_PLASTIC` | 4 | Пластик |
| `MATERIAL_LIQUID` | 5 | Жидкость, вода |
| `MATERIAL_SLIME` | 6 | Слизь, масло |
| `MATERIAL_BETON` | 7 | Бетон |
| `MATERIAL_RUBBER` | 8 | Резина, линолеум |
| `MATERIAL_FLESH` | 9 | Плоть |
| `MATERIAL_GRASS` | 10 | Трава |
| `MATERIAL_WOOD` | 11 | Дерево |
| `MATERIAL_SNOW` | 12 | Снег |
| `MATERIAL_SAND` | 13 | Мягкий песок |
| `MATERIAL_DIRT` | 14 | Мягкая грязь |
| `MATERIAL_GRAVEL` | 15 | Гравий |
| `MATERIAL_STONE` | 16 | Камень, скалы |
