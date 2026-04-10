Центральная экономика — система спавна и управления лутом. Источник: `ce/`

### CentralEconomy

Ядро системы (native). Доступ через `GetCEApi()`.

### ECE-флаги (Entity Creation)

Флаги создания сущностей. Используются в `CreateObjectEx()` и CE-операциях. Комбинируются побитово.

#### Базовые

| Флаг | Описание |
|------|----------|
| `ECE_SETUP` | Базовая настройка |
| `ECE_TRACE` | Поставить на поверхность (трейс вниз) |
| `ECE_CENTER` | Центрировать по поверхности |
| `ECE_UPDATEPATHGRAPH` | Обновить навмеш |
| `ECE_CREATEPHYSICS` | Создать физическое тело |
| `ECE_INITAI` | Инициализировать ИИ |
| `ECE_AIRBORNE` | В воздухе (без трейса) |

#### Экипировка

| Флаг | Описание |
|------|----------|
| `ECE_EQUIP_ATTACHMENTS` | Заспавнить аттачменты |
| `ECE_EQUIP_CARGO` | Заспавнить лут в карго |
| `ECE_EQUIP` | Аттачменты + карго |
| `ECE_EQUIP_CONTAINER` | Контейнер с лутом |

#### Персистентность

| Флаг | Описание |
|------|----------|
| `ECE_NOLIFETIME` | Без lifetime (не исчезает) |
| `ECE_NOPERSISTENCY_WORLD` | Без сохранения в мир |
| `ECE_NOPERSISTENCY_CHAR` | Без сохранения на персонажа |
| `ECE_DYNAMIC_PERSISTENCY` | Динамическая персистентность |

#### Прочие

| Флаг | Описание |
|------|----------|
| `ECE_NOSURFACEALIGN` | Без выравнивания по поверхности |
| `ECE_KEEPHEIGHT` | Сохранить высоту |

#### Пресеты

| Пресет | Описание |
|--------|----------|
| `ECE_IN_INVENTORY` | Для предметов в инвентаре |
| `ECE_PLACE_ON_SURFACE` | Разместить на поверхности |
| `ECE_OBJECT_SWAP` | Замена объекта |
| `ECE_FULL` | Полная настройка (все основные флаги) |

### RF-флаги (Rotation)

Ориентация при спавне:

| Флаг | Описание |
|------|----------|
| `RF_FRONT` | Лицом к поверхности |
| `RF_TOP` | Вверх |
| `RF_LEFT` / `RF_RIGHT` | Боком |
| `RF_BACK` / `RF_BOTTOM` | Задом / низом |
| `RF_RANDOMROT` | Случайное вращение по Y |
| `RF_ORIGINAL` | Оригинальная ориентация |
| `RF_DECORRECTION` | Коррекция при замене |
| `RF_DEFAULT` | По умолчанию |

### EconomyLogCategories

Категории логирования CE: `economy`, `respawn_queue`, `container`, `matrix`, `uniqueloot`, `map`, `underground`, `lootable` и др.
