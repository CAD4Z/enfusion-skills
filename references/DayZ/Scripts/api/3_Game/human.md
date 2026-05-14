Player control: input, cameras, items in hands, movement settings. Sources: `human.c`, `humanitems.c`, `humansettings.c`, `dayzplayer.c`

### HumanInputController

Player input interface. Access: `human.GetInputController()`. All methods are `proto native`.

#### Movement

| Method | Return | Description |
|--------|--------|-------------|
| `SetDisabled(state)` | `void` | Enable/disable controller |
| `GetMovement(out speed, out localDir)` | `void` | `speed`: 0=idle, 1=walk, 2=run, 3=sprint. `localDir` is normalized |
| `GetHeadingAngle()` | `float` | Camera heading angle (rad), `-PI..PI` |

#### Aiming

| Method | Return | Description |
|--------|--------|-------------|
| `GetAimChange()` | `vector` | Aim change per tick (rad) |
| `GetAimDelta(dt)` | `vector` | Aim change (rad) |
| `GetTracking()` | `vector` | Absolute tracking change (rad) |

#### Camera

| Method | Description |
|--------|-------------|
| `CameraViewChanged()` | Switch 1st/3rd person |
| `CameraIsFreeLook()` | Free look active |
| `ResetFreeLookToggle()` | Reset free look toggle |
| `CameraIsTracking()` | Tracking (IR device) |
| `Camera3rdIsRightShoulder()` | Right/left shoulder (3rd person) |

#### Stance and movement

| Method | Description |
|--------|-------------|
| `IsStanceChange()` | Stance change pressed |
| `IsJumpClimb()` | Jump/climb pressed |
| `IsWalkToggled()` | Walk toggled |

#### Melee

| Method | Description |
|--------|-------------|
| `IsMeleeEvade()` | SHIFT (evade) |
| `IsMeleeFastAttackModifier()` | SHIFT (fast/heavy attack) |
| `IsMeleeLREvade()` | 0=no, 1=left, 2=right |
| `IsMeleeWeaponAttack()` | Weapon attack modifier |

#### Weapon

| Method | Description |
|--------|-------------|
| `WeaponWasRaiseClick()` | Click before raising |
| `IsWeaponRaised()` | Weapon raised |
| `WeaponADS()` | Aim down sights mode |
| `ResetADS()` | Reset ADS |
| `IsThrowingModeChange()` / `ResetThrowingMode()` | Throwing mode change |

#### Use (Actions)

| Method | Description |
|--------|-------------|
| `IsUseButton()` / `IsUseButtonDown()` | **Deprecated** — UADefaultAction + UAFire |
| `IsUseItemButton()` / `IsUseItemButtonDown()` | UADefaultAction (use) |
| `IsAttackButton()` / `IsAttackButtonDown()` | UAFire (attack) |
| `IsSingleUse()` | Single use (not raised) |
| `IsContinuousUse()` | Continuous use |
| `IsContinuousUseStart()` / `IsContinuousUseEnd()` | Start/end of continuous use |
| `IsImmediateAction()` | Immediate action (middle button) |

#### Reload

| Method | Description |
|--------|-------------|
| `IsReloadOrMechanismSingleUse()` | R — single (1 tick) |
| `IsReloadOrMechanismContinuousUse()` | R — continuous |
| `IsReloadOrMechanismContinuousUseStart()` / `...End()` | Start/end |

#### Sight and zoom

| Method | Description |
|--------|-------------|
| `IsZoom()` / `IsZoomToggle()` / `ResetZoomToggle()` | Zoom |
| `IsSightChange()` | Sight change (in/out) |
| `IsZoomIn()` / `IsZoomOut()` | Zoom in/out |
| `IsFireModeChange()` | Fire mode change |
| `IsZeroingUp()` / `IsZeroingDown()` | Zeroing |
| `IsHoldBreath()` / `ResetHoldBreath()` | Hold breath |

#### Other

| Method | Description |
|--------|-------------|
| `IsQuickBarSlot()` | 1..10 if quickbar slot, 0 otherwise |
| `IsGestureSlot()` | **Deprecated**. 1..12 if gesture |
| `IsOtherController()` | Controlling another entity (vehicle) |

#### Override system

`HumanInputControllerOverrideType`: `DISABLED`, `ENABLED`, `ONE_FRAME`

Allows intercepting and substituting input values.

### DayZPlayerCamera

Base class for player cameras. Source: `dayzplayer.c`

#### DayZPlayerCameraResult

| Field | Type | Description |
|-------|------|-------------|
| `m_CameraTM[4]` | `vector[4]` | Camera transformation matrix |
| `m_fFovMultiplier` | `float` | FOV multiplier (1.0 = no change) |
| `m_fFovAbsolute` | `float` | Absolute FOV (-1 = use multiplier) |
| `m_iDirectBone` | `int` | Bound bone index (-1 = none) |
| `m_iDirectBoneMode` | `int` | Binding mode |
| `m_fNearPlane` | `float` | Near clipping plane |
| `m_bUpdateWhenBlendOut` | `bool` | Update during fade-out |
| `m_fIgnoreParentRoll` | `float` | Ignore parent roll (0..1) |

#### DayZPlayerCamera

| Method | Description |
|--------|-------------|
| `OnActivate(prevCamera, prevResult)` | Camera activated |
| `OnUpdate(dt, out result)` | Update (abstract) |
| `GetBaseAngles(out yaw, out pitch, out roll)` | Base angles |
| `GetAdditiveAngles(out yaw, out pitch, out roll)` | Additive angles |
| `GetCurrentYaw()` / `GetCurrentPitch()` / `GetCurrentRoll()` | Current angles |
| `IsCamera3rdRaised()` | Raised 3rd person camera |
| `CanFreeLook()` | Can free look |
| `SpawnCameraShake(strength, radius, smoothness, radius)` | Camera shake |

### HumanItemBehaviorCfg

Configuration of in-hand item behaviour. Source: `humanitems.c`

#### IK settings

Constants: `IKSETTING_AIMING`, `IKSETTING_RHAND`, `IKSETTING_LHAND`

| Method | Description |
|--------|-------------|
| `SetIK(stance, ik)` | Set IK for stance |
| `SetIKStance(stance, ik)` | IK for specific stance |
| `SetIKMelee(ik)` | IK for melee |
| `SetIKAll(ik)` | IK for all stances |

#### Fields

| Field | Description |
|-------|-------------|
| `m_StanceMask` | Mask of allowed stances |
| `m_iPerStanceMovementDefinition[6]` | Movement definition per stance |
| `m_bJumpAllowed` | Jump allowed |
| `m_bAttackLean` | Lean while attacking |

### HumanItemAccessor

Access to the item in hands. Source: `humanitems.c`

| Method | Description |
|--------|-------------|
| `OnItemInHandsChanged(instant)` | Item in hands changed |
| `ResetWeaponInHands()` | Reset weapon |
| `HideItemInHands()` / `IsItemInHandsHidden()` | Hide/check |
| `IsItemInHandsWeapon()` | Item is a weapon |
| `WeaponGetCameraPoint(out pos, out dir)` | Weapon camera point |
| `WeaponGetAimingModelDirTm(out tm[4])` | Aiming direction matrix |
| `GetItemInHandsBehaviourCfg()` | Behaviour config |

### Movement settings

Source: `humansettings.c`. Structures for fine-tuning character physics.

#### SHumanCommandMoveSettings

Ground movement: sprint, turning, sliding, leaning.

| Field | Description |
|-------|-------------|
| `m_fSprintTimeOut` | Sprint timeout |
| `m_fSprintChangeRate` | Sprint change rate |
| `m_fDirFilterTimeout` | Direction filter timeout |
| `m_fTurnAngle` / `m_fTurnTime` | Turn angle/time |
| `m_fSlidingPoseAngle` | Slide angle |
| `m_fLeaningSpeed` | Lean speed |

#### SHumanCommandSwimSettings

Swimming: alignment, speed, water level thresholds.

#### SHumanCommandClimbSettings

Climbing: character width/height, traversal heights, check distances.

### EActions (key values)

Defined in `enums/eactions.c`. Full enum with 100+ values. Key groups:

- **Basics**: `NONE`, `DRINK`, `EAT`, `BANDAGE`, `FORCE_FEED`, `GIVE_BLOOD`, `INJECT_EPINEPHRINE/MORPHINE`
- **Mechanisms**: `OPERATE`, `TOGGLE_STOPPER`, `TOGGLE_HANDGUARD`, `RELEASE_BOLT/MAGAZINE`
- **World**: `OPEN_DOOR`, `CLOSE_DOOR`, `LOCK_DOOR`, `BUILD_OVEN`, `UNPACK_BOX`
- **Bot**: `PLAYER_BOT_ATTACH/DETACH/SWAP/DROP/EQUIP`
- **Debug**: `DEBUG_AGENTS_RANGE_*`
