Static constants. Source: `constants.c`

### Input Device

Masks and identifiers of input devices. Used for low-level input handling.

**Devices:**

| Constant | Value | Description |
|-----------|----------|----------|
| `INPUT_DEVICE_KEYBOARD` | `0x00000000` | Keyboard |
| `INPUT_DEVICE_MOUSE` | `0x00100000` | Mouse buttons |
| `INPUT_DEVICE_STICK` | `0x00200000` | Joystick |
| `INPUT_DEVICE_XINPUT` | `0x00300000` | XInput (Xbox controller) |
| `INPUT_DEVICE_TRACKIR` | `0x00400000` | TrackIR |
| `INPUT_DEVICE_GAMEPAD` | `0x00500000` | Gamepad |

**Action types:**

| Constant | Description |
|-----------|----------|
| `INPUT_ACTION_TYPE_STATE` | State (held) |
| `INPUT_ACTION_TYPE_DOWN_EVENT` | Press |
| `INPUT_ACTION_TYPE_UP_EVENT` | Release |
| `INPUT_ACTION_TYPE_SHORTCLICK_EVENT` | Short click |
| `INPUT_ACTION_TYPE_HOLD_EVENT` | Hold |
| `INPUT_ACTION_TYPE_DOUBLETAP` | Double tap |

**Masks:** `INPUT_MODULE_TYPE_MASK`, `INPUT_KEY_MASK`, `INPUT_ACTION_TYPE_MASK`, `INPUT_AXIS`, `INPUT_POV`, `INPUT_COMBO_MASK`

**Combined:** `INPUT_DEVICE_MOUSE_AXIS`, `INPUT_DEVICE_STICK_AXIS`, `INPUT_DEVICE_GAMEPAD_AXIS`

### Colors

ARGB format (0xAARRGGBB).

| Constant | Color | Value |
|-----------|------|----------|
| `COLOR_WHITE` | White | `0xFFFFFFFF` |
| `COLOR_RED` | Red | `0xFFF22613` |
| `COLOR_GREEN` | Green | `0xFF2ECC71` |
| `COLOR_BLUE` | Blue | `0xFF4B77BE` |
| `COLOR_YELLOW` | Yellow | `0xFFF7CA18` |
| `COLOR_RED_A` | Red (transparent) | `0x1fF22613` |
| `COLOR_GREEN_A` | Green (transparent) | `0x1f2ECC71` |
| `COLOR_BLUE_A` | Blue (transparent) | `0x1f4B77BE` |
| `COLOR_YELLOW_A` | Yellow (transparent) | `0x1fF7CA18` |

### Strings

`STRING_EMPTY = ""`

### Materials

Physical material identifiers. When adding new ones, don't forget to update `physics/materials.xml`.

| Constant | Value | Description |
|-----------|----------|----------|
| `MATERIAL_DEFAULT` | 0 | Default |
| `MATERIAL_METAL` | 1 | Steel |
| `MATERIAL_IRON` | 2 | Iron |
| `MATERIAL_GLASS` | 3 | Glass |
| `MATERIAL_PLASTIC` | 4 | Plastic |
| `MATERIAL_LIQUID` | 5 | Liquid, water |
| `MATERIAL_SLIME` | 6 | Slime, oil |
| `MATERIAL_BETON` | 7 | Concrete |
| `MATERIAL_RUBBER` | 8 | Rubber, linoleum |
| `MATERIAL_FLESH` | 9 | Flesh |
| `MATERIAL_GRASS` | 10 | Grass |
| `MATERIAL_WOOD` | 11 | Wood |
| `MATERIAL_SNOW` | 12 | Snow |
| `MATERIAL_SAND` | 13 | Soft sand |
| `MATERIAL_DIRT` | 14 | Soft dirt |
| `MATERIAL_GRAVEL` | 15 | Gravel |
| `MATERIAL_STONE` | 16 | Stone, rocks |
