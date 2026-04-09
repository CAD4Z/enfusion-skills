Управление игроком: ввод, камеры, предметы в руках, настройки движения. Источники: `human.c`, `humanitems.c`, `humansettings.c`, `dayzplayer.c`

### HumanInputController

Интерфейс ввода игрока. Доступ: `human.GetInputController()`. Все методы — `proto native`.

#### Движение

| Метод | Возврат | Описание |
|-------|---------|----------|
| `SetDisabled(state)` | `void` | Вкл/выкл контроллер |
| `GetMovement(out speed, out localDir)` | `void` | `speed`: 0=idle, 1=walk, 2=run, 3=sprint. `localDir` — нормализованный |
| `GetHeadingAngle()` | `float` | Угол направления камеры (рад), `-PI..PI` |

#### Прицеливание

| Метод | Возврат | Описание |
|-------|---------|----------|
| `GetAimChange()` | `vector` | Изменение прицела за тик (рад) |
| `GetAimDelta(dt)` | `vector` | Изменение прицела (рад) |
| `GetTracking()` | `vector` | Абсолютное изменение трекинга (рад) |

#### Камера

| Метод | Описание |
|-------|----------|
| `CameraViewChanged()` | Переключение 1-е/3-е лицо |
| `CameraIsFreeLook()` | Свободный обзор активен |
| `ResetFreeLookToggle()` | Сброс переключателя свободного обзора |
| `CameraIsTracking()` | Трекинг (ИК-устройство) |
| `Camera3rdIsRightShoulder()` | Правое/левое плечо (3-е лицо) |

#### Стойка и движение

| Метод | Описание |
|-------|----------|
| `IsStanceChange()` | Нажата смена стойки |
| `IsJumpClimb()` | Нажат прыжок/подъём |
| `IsWalkToggled()` | Ходьба переключена |

#### Ближний бой

| Метод | Описание |
|-------|----------|
| `IsMeleeEvade()` | SHIFT (уклонение) |
| `IsMeleeFastAttackModifier()` | SHIFT (быстрая/тяжёлая атака) |
| `IsMeleeLREvade()` | 0=нет, 1=влево, 2=вправо |
| `IsMeleeWeaponAttack()` | Модификатор атаки оружием |

#### Оружие

| Метод | Описание |
|-------|----------|
| `WeaponWasRaiseClick()` | Клик перед поднятием |
| `IsWeaponRaised()` | Оружие поднято |
| `WeaponADS()` | Режим прицеливания |
| `ResetADS()` | Сброс ADS |
| `IsThrowingModeChange()` / `ResetThrowingMode()` | Смена режима броска |

#### Использование (Actions)

| Метод | Описание |
|-------|----------|
| `IsUseButton()` / `IsUseButtonDown()` | **Deprecated** — UADefaultAction + UAFire |
| `IsUseItemButton()` / `IsUseItemButtonDown()` | UADefaultAction (использовать) |
| `IsAttackButton()` / `IsAttackButtonDown()` | UAFire (атака) |
| `IsSingleUse()` | Одиночное использование (не поднято) |
| `IsContinuousUse()` | Длительное использование |
| `IsContinuousUseStart()` / `IsContinuousUseEnd()` | Начало/конец длительного |
| `IsImmediateAction()` | Мгновенное действие (средняя кнопка) |

#### Перезарядка

| Метод | Описание |
|-------|----------|
| `IsReloadOrMechanismSingleUse()` | R — одиночное (1 тик) |
| `IsReloadOrMechanismContinuousUse()` | R — длительное |
| `IsReloadOrMechanismContinuousUseStart()` / `...End()` | Начало/конец |

#### Прицел и зум

| Метод | Описание |
|-------|----------|
| `IsZoom()` / `IsZoomToggle()` / `ResetZoomToggle()` | Зум |
| `IsSightChange()` | Смена прицела (in/out) |
| `IsZoomIn()` / `IsZoomOut()` | Приблизить/отдалить |
| `IsFireModeChange()` | Смена режима огня |
| `IsZeroingUp()` / `IsZeroingDown()` | Пристрелка |
| `IsHoldBreath()` / `ResetHoldBreath()` | Задержка дыхания |

#### Прочее

| Метод | Описание |
|-------|----------|
| `IsQuickBarSlot()` | 1..10 если слот quickbar, 0 иначе |
| `IsGestureSlot()` | **Deprecated**. 1..12 если жест |
| `IsOtherController()` | Управляет другой сущностью (транспорт) |

#### Override-система

`HumanInputControllerOverrideType`: `DISABLED`, `ENABLED`, `ONE_FRAME`

Позволяет перехватывать и подменять значения ввода.

### DayZPlayerCamera

Базовый класс камер игрока. Источник: `dayzplayer.c`

#### DayZPlayerCameraResult

| Поле | Тип | Описание |
|------|-----|----------|
| `m_CameraTM[4]` | `vector[4]` | Матрица трансформации камеры |
| `m_fFovMultiplier` | `float` | Множитель FOV (1.0 = без изменений) |
| `m_fFovAbsolute` | `float` | Абсолютный FOV (-1 = использовать множитель) |
| `m_iDirectBone` | `int` | Индекс кости привязки (-1 = нет) |
| `m_iDirectBoneMode` | `int` | Режим привязки |
| `m_fNearPlane` | `float` | Ближняя плоскость отсечения |
| `m_bUpdateWhenBlendOut` | `bool` | Обновлять при fade-out |
| `m_fIgnoreParentRoll` | `float` | Игнорировать крен родителя (0..1) |

#### DayZPlayerCamera

| Метод | Описание |
|-------|----------|
| `OnActivate(prevCamera, prevResult)` | Камера активирована |
| `OnUpdate(dt, out result)` | Обновление (абстрактный) |
| `GetBaseAngles(out yaw, out pitch, out roll)` | Базовые углы |
| `GetAdditiveAngles(out yaw, out pitch, out roll)` | Аддитивные углы |
| `GetCurrentYaw()` / `GetCurrentPitch()` / `GetCurrentRoll()` | Текущие углы |
| `IsCamera3rdRaised()` | Поднятая камера 3-го лица |
| `CanFreeLook()` | Может свободно осматриваться |
| `SpawnCameraShake(strength, radius, smoothness, radius)` | Тряска камеры |

### HumanItemBehaviorCfg

Конфигурация поведения предметов в руках. Источник: `humanitems.c`

#### IK-настройки

Константы: `IKSETTING_AIMING`, `IKSETTING_RHAND`, `IKSETTING_LHAND`

| Метод | Описание |
|-------|----------|
| `SetIK(stance, ik)` | Установить IK для стойки |
| `SetIKStance(stance, ik)` | IK для конкретной стойки |
| `SetIKMelee(ik)` | IK для ближнего боя |
| `SetIKAll(ik)` | IK для всех стоек |

#### Поля

| Поле | Описание |
|------|----------|
| `m_StanceMask` | Маска разрешённых стоек |
| `m_iPerStanceMovementDefinition[6]` | Определение движения для каждой стойки |
| `m_bJumpAllowed` | Прыжок разрешён |
| `m_bAttackLean` | Наклон при атаке |

### HumanItemAccessor

Доступ к предмету в руках. Источник: `humanitems.c`

| Метод | Описание |
|-------|----------|
| `OnItemInHandsChanged(instant)` | Предмет в руках изменился |
| `ResetWeaponInHands()` | Сброс оружия |
| `HideItemInHands()` / `IsItemInHandsHidden()` | Скрыть/проверить |
| `IsItemInHandsWeapon()` | Предмет — оружие |
| `WeaponGetCameraPoint(out pos, out dir)` | Точка камеры оружия |
| `WeaponGetAimingModelDirTm(out tm[4])` | Матрица направления прицеливания |
| `GetItemInHandsBehaviourCfg()` | Конфигурация поведения |

### Настройки движения

Источник: `humansettings.c`. Структуры тонкой настройки физики персонажа.

#### SHumanCommandMoveSettings

Наземное движение: спринт, повороты, скольжение, наклон.

| Поле | Описание |
|------|----------|
| `m_fSprintTimeOut` | Таймаут спринта |
| `m_fSprintChangeRate` | Скорость изменения спринта |
| `m_fDirFilterTimeout` | Таймаут фильтра направления |
| `m_fTurnAngle` / `m_fTurnTime` | Угол/время поворота |
| `m_fSlidingPoseAngle` | Угол скольжения |
| `m_fLeaningSpeed` | Скорость наклона |

#### SHumanCommandSwimSettings

Плавание: выравнивание, скорость, пороги уровня воды.

#### SHumanCommandClimbSettings

Лазание: ширина/высота персонажа, высоты прохода, расстояния проверки.

### EActions (ключевые значения)

Определены в `enums/eactions.c`. Полный enum с 100+ значениями. Ключевые группы:

- **Базовые**: `NONE`, `DRINK`, `EAT`, `BANDAGE`, `FORCE_FEED`, `GIVE_BLOOD`, `INJECT_EPINEPHRINE/MORPHINE`
- **Механизмы**: `OPERATE`, `TOGGLE_STOPPER`, `TOGGLE_HANDGUARD`, `RELEASE_BOLT/MAGAZINE`
- **Мир**: `OPEN_DOOR`, `CLOSE_DOOR`, `LOCK_DOOR`, `BUILD_OVEN`, `UNPACK_BOX`
- **Бот**: `PLAYER_BOT_ATTACH/DETACH/SWAP/DROP/EQUIP`
- **Отладка**: `DEBUG_AGENTS_RANGE_*`
