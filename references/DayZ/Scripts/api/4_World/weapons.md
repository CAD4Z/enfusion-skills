`4_World` — weapons. Weapon FSM, recoil, magazines, attachments. Sources: `entities/firearms/`, `classes/weapons/`, `classes/recoilbase/`

### Weapon_Base

Hierarchy: `Weapon` (C++) → `Weapon_Base`. All concrete weapons inherit from `Weapon_Base`.

#### Initialization

Constructor: flags (`m_isJammed`, `m_BayonetAttached`...), `simpleHiddenSelections` for cartridges/magazines, `InitWeaponLength()`, `InitReliability()`, then **`InitStateMachine()`**.

`InitStateMachine()` is **empty in Weapon_Base** and must be overridden. FSM states and transitions are defined there.

`EEInit()` — on the server calls `AssembleGun()` (loads ammo from storage into FSM state).

#### State and queries

| Method | Description |
|-------|----------|
| `IsCharged()` | Round in chamber |
| `IsJammed()` | Jammed |
| `IsWeaponOpen()` | Bolt open |
| `CanProcessWeaponEvents()` | FSM active |
| `IsIdle()` | FSM in a stable state |
| `GetCurrentState()` | Current `WeaponStateBase` |

#### FSM interface

| Method | Description |
|-------|----------|
| `ProcessWeaponEvent(WeaponEventBase e)` | Dispatch event → synchronization |
| `ProcessWeaponAbortEvent(WeaponEventBase e)` | Abort |
| `HasActionAbility(int action, int type)` | Whether the operation is supported |
| `GetAbilityCount()` / `GetAbility(int)` | Capability list |

#### Firing and jamming

| Method | Description |
|-------|----------|
| `EEFired(int muzzle, int mode, string ammo)` | Shot — particles, heating |
| `JamCheck(int muzzleIndex)` | Jam check (synced random) |
| `GetChanceToJam()` | Chance based on health level |
| `InitReliability(out array<float>)` | Load chances from config |

#### Creating a weapon with ammo (static)

```
Weapon_Base.CreateWeaponWithAmmo(string weaponType, string magazineType, int flags)
SpawnAmmo(string magazineType, int flags)
SpawnAttachedMagazine(string magazineType, int flags)
```

`WeaponWithAmmoFlags`: `CHAMBER`, `CHAMBER_RNG`, `CHAMBER_RNG_SPORADIC`, `QUANTITY_RNG`, `MAX_CAPACITY_MAG`

---

### Weapon FSM

HFSM: `WeaponFSM extends HFSMBase<WeaponStateBase, WeaponEventBase, WeaponActionBase, WeaponGuardBase>`.

#### WeaponStateBase

| Method | Description |
|-------|----------|
| `OnEntry(WeaponEventBase e)` | State entry |
| `OnUpdate(float dt)` | Tick |
| `OnAbort(WeaponEventBase e)` | Abort |
| `OnExit(WeaponEventBase e)` | Exit |
| `IsIdle()` | Stable state |
| `HasFSM()` | Has a nested machine |

States are nestable — a state with its own `WeaponFSM` acts as a composite.

#### WeaponStableState — base for idle states

| Method | Description |
|-------|----------|
| `HasBullet()` | Round in chamber |
| `HasMagazine()` | Magazine attached |
| `IsJammed()` | Jammed |
| `IsWeaponOpen()` | Bolt open |
| `IsRepairEnabled()` | Allow ValidateAndRepair |

`OnEntry` syncs: jammed, charged, open, animation state.

#### Defining transitions

```
m_fsm.AddTransition(new WeaponTransition(srcState, event, dstState, action, guard));
```

#### State groups

| Group | States |
|--------|-----------|
| Firing | `WeaponFire`, `WeaponFireAndChamberNext`, `WeaponFireLast` |
| Chambering | `WeaponChambering`, `WeaponChamberingLooped`, `RifleChambering` |
| Magazine | `WeaponAttachMagazine`, `WeaponDetachingMag`, `WeaponReplacingMagAndChamberNext` |
| Ejection | `WeaponEjectBullet`, `RifleEjectCasing`, `WeaponReChamber` |
| Jamming | `WeaponStateJammed`, `WeaponUnjamming` |
| Visual | `BulletShow`, `BulletHide`, `MagazineShow`, `MagazineHide` |

#### WeaponEventID

`MECHANISM`, `TRIGGER`, `TRIGGER_JAM`, `TRIGGER_AUTO_START/END`, `LOAD1_BULLET`, `CONTINUOUS_LOADBULLET_START/END`, `UNJAM`, `ATTACH_MAGAZINE`, `DETACH_MAGAZINE`, `SWAP_MAGAZINE`, `HUMANCOMMAND_ACTION_FINISHED/ABORTED`, `SET_NEXT_MUZZLE_MODE`, `ANIMATION_EVENT`

#### ValidateAndRepair

After every transition, if the current stable state has `IsRepairEnabled()=true`, it verifies that the physical state (chamber/magazine) matches the FSM's declaration. On mismatch — forced correction.

---

### Recoil (RecoilBase)

Created per shot, lives until the end of the reload cycle.

#### Parameters (set in `Init()`)

| Field | Description |
|------|----------|
| `m_MouseOffsetRangeMin/Max` | Random angle range (degrees) |
| `m_MouseOffsetDistance` | Total mouse offset |
| `m_MouseOffsetRelativeTime` | Fraction of reload time for mouse (0..1) |
| `m_HandsOffsetRelativeTime` | Fraction for hands animation |
| `m_CamOffsetRelativeTime` | Fraction for camera Z offset |
| `m_CamOffsetDistance` | Camera Z offset distance |
| `m_HandsCurvePoints` | Bezier points for hands animation |

#### Modifiers

`GetRecoilModifier(Weapon_Base)` reads `weapon.GetPropertyModifierObject().m_RecoilModifiers` → vector `(x_scale, y_scale, cam_scale)`. Suppressors/stocks modify recoil through this vector.

#### Three offset systems (each frame)

1. `ApplyMouseOffset()` — smooth cursor movement toward the target
2. `ApplyHandsOffset()` — Bezier curve for the hands
3. `ApplyCamOffset()` — camera Z-push with EaseOutBack

---

### Magazines (Magazine)

`Magazine extends InventoryItemSuper`. Alias: `Magazine_Base`.

#### Native methods (C++)

| Method | Description |
|-------|----------|
| `GetAmmoCount()` / `ServerSetAmmoCount(int)` | Current/set count |
| `ServerAcquireCartridge(out float dmg, out string type)` | Take a cartridge (server) |
| `ServerStoreCartridge(float dmg, string type)` | Insert a cartridge (server) |
| `GetCartridgeAtIndex(int, out float, out string)` | Cartridge by index |

#### Script methods

| Method | Description |
|-------|----------|
| `GetAmmoMax()` | Maximum (from the `count` config) |
| `CanAddCartridges(int count)` | Has space |
| `IsCompatiableAmmo(ItemBase)` | Compatible ammo type |
| `GetChanceToJam()` | Jam chance based on health |
| `CanBeSplit()` | Can be split (count > 1) |

---

### Weapon attachments

- `ButtstockBase` → `OnWasAttached` calls `parent.SetButtstockAttached(true)`
- `SuppressorBase` — muzzle particles, heating via `ItemBase.HasMuzzle()=true`
- `PoweredOptic_Base extends ItemBase` — battery-powered scopes (NVG)
