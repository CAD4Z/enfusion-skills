`4_World` — the action system (User Actions). The most common extension point for modders. Sources: `classes/useractionscomponent/`

### Class hierarchy

```
ActionBase_Basic (C++)
 └── ActionBase
      ├── ActionInstantBase           — no animation, effect in OnStart
      ├── ActionSequentialBase        — multi-stage, no animation
      └── AnimatedActionBase          — with animation and callback
           ├── ActionInteractBase     — interaction (AC_INTERACT)
           │    └── ActionInteractLoopBase
           ├── ActionSingleUseBase    — single-use (AC_SINGLE_USE)
           ├── ActionContinuousBase   — continuous (AC_CONTINUOUS)
           └── FirearmActionBase      — firearm mechanics
```

### Execution pipeline

```
[Every frame, no active action]
  ActionManagerClient.FindContextualUserActions()
   → ActionInput.UpdatePossibleActions()
    → ActionBase.Can(player, target, item, conditionMask)
        1. conditionMask check (vehicle/ladder/swimming...)
        2. Stance check (StanceMask)
        3. CCTBase.Can() — target condition
        4. CCIBase.Can() — item condition
        5. ActionCondition() — custom logic

[Player presses button]
  ActionManager.ActionStart(action, target, item)
   → SetupAction() → CreateActionData()
   → [MP] WriteToContext() → network → ReadFromContext() on server
   → [Server] Can() rechecked → AddActionJuncture() → ACK
   → [Client receives ACK] action.Start()
    → OnStart/OnStartServer/OnStartClient()
    → CreateAndSetupActionCallback() → player.StartCommand_Action()
    → ActionBaseCB.InitActionComponent() → CABase.Init()

[Every frame, action running]
  AnimatedActionBase.Do(action_data, state)
   → UA_PROCESSING: CanContinue() → CABase.Execute()
   → UA_FINISHED: End()
   → UA_CANCEL: End()

[Animation event "ActionExec"]
   → OnExecute() / OnExecuteServer() / OnExecuteClient()

[For ContinuousBase: animation loop]
   → "ActionExecStart" → OnStartAnimationLoop*()
   → "ActionExecEnd" → OnEndAnimationLoop*()
   → CABase finished → OnFinishProgress*()

[End of action]
   → OnEnd/OnEndServer/OnEndClient()
```

### States (UA_*)

| Constant | Value | Description |
|-----------|----------|----------|
| `UA_PROCESSING` | 2 | Component running |
| `UA_FINISHED` | 4 | Finished normally |
| `UA_CANCEL` | 5 | Cancelled |
| `UA_AM_PENDING` | 14 | Waiting for ACK from server |
| `UA_AM_ACCEPTED` | 15 | Server accepted |
| `UA_AM_REJECTED` | 16 | Server rejected |
| `UA_ANIM_EVENT` | 11 | "ActionExec" event |

### Action types

| Type | Category | Animation | When effect fires |
|-----|-----------|----------|-------------|
| `ActionInstantBase` | — | None | `OnStart()` |
| `ActionInteractBase` | AC_INTERACT | CMD_ACTIONMOD_PICKUP_HANDS | `OnExecute()` on ActionExec |
| `ActionSingleUseBase` | AC_SINGLE_USE | CMD_ACTIONMOD_PICKUP_HANDS | `OnExecuteServer()` on ActionExec |
| `ActionContinuousBase` | AC_CONTINUOUS | CMD_ACTIONMOD_EAT | `OnFinishProgressServer()` |
| `FirearmActionBase` | AC_SINGLE_USE | Weapon FSM | Via WeaponManager |

---

### ActionBase — key overridable methods

#### Identification

| Method | Description | Default |
|-------|----------|-------------|
| `HasTarget()` | Uses a world target | `true` |
| `IsInstant()` | Instant, no animation | `false` |
| `IsLocal()` | Client only, no sync | `false` |
| `HasProgress()` | Show progress bar | `true` |
| `UseMainItem()` | Item in hands is involved | `true` |
| `GetText()` | Tooltip text in HUD | `m_Text` |

#### Conditions

| Method | Description |
|-------|----------|
| `CreateConditionComponents()` | Set up `m_ConditionItem` and `m_ConditionTarget` |
| `ActionCondition(PlayerBase, ActionTarget, ItemBase)` | Main check (every frame) |
| `ActionConditionContinue(ActionData)` | Check during execution |
| `GetStanceMask(PlayerBase)` | Allowed stances |

#### Player state flags (condition mask)

`CanBeUsedInVehicle()`, `CanBeUsedSwimming()`, `CanBeUsedOnLadder()`, `CanBeUsedInRestrain()`, `CanBeUsedRaised()`, `CanBeUsedOnBack()`, `CanBeUsedWithBrokenLegs()`

#### Execution hooks

| Method | When |
|-------|-------|
| `OnStart/OnStartServer/OnStartClient(ActionData)` | Action start |
| `OnEnd/OnEndServer/OnEndClient(ActionData)` | Action end |
| `OnExecute/OnExecuteServer/OnExecuteClient(ActionData)` | ActionExec event |
| `OnUpdate/OnUpdateServer/OnUpdateClient(ActionData)` | Every frame |

#### Extra ContinuousBase hooks

| Method | When |
|-------|-------|
| `OnStartAnimationLoopServer/Client(ActionData)` | Animation loop start |
| `OnEndAnimationLoopServer/Client(ActionData)` | Animation loop end |
| `OnFinishProgressServer/Client(ActionData)` | Component finished |

#### Synchronization

| Method | Description |
|-------|----------|
| `CreateActionData()` | Return a custom ActionData subclass |
| `WriteToContext(ctx, ActionData)` | Serialize → server |
| `ReadFromContext(ctx, out ActionReciveData)` | Deserialize on server |
| `HandleReciveData(ActionReciveData, ActionData)` | Apply data |

---

### Action components (CABase)

Define the **duration and completion logic** of an action. Created in `ActionBaseCB::CreateActionComponent()`.

```
CABase
 ├── CAInteract / CASingleUse      — instant completion
 ├── CAContinuousTime               — finish after N seconds
 ├── CAContinuousRepeat             — repeat every N seconds
 ├── CAContinuousQuantity           — consume item quantity
 │    ├── CAContinuousQuantityEdible
 │    ├── CAContinuousQuantityLiquidTransfer
 │    └── ...
 ├── CAContinuousFill / Empty       — liquids
 ├── CAContinuousMineRock/Wood      — mining
 ├── CAContinuousCraft              — crafting
 └── ...
```

#### CABase API

| Method | Description |
|-------|----------|
| `Setup(ActionData)` | Initialization at start |
| `Execute(ActionData)` | Every frame → `UA_PROCESSING` / `UA_FINISHED` / `UA_CANCEL` |
| `Cancel(ActionData)` | Cancellation by the player |
| `GetProgress()` | 0..1 for the progress bar |

#### Main components

| Component | Constructor | Logic |
|-----------|-------------|--------|
| `CAContinuousTime(float sec)` | Time to completion | `elapsed >= total` → FINISHED |
| `CAContinuousRepeat(float sec)` | Cycle time | Reset after each cycle, runs forever |
| `CAContinuousQuantity(float per_sec)` | Consumption per second | `spent >= item.quantity` → FINISHED |

---

### Item conditions (CCI)

| Class | Can() condition | CanContinue() |
|-------|---------------|---------------|
| `CCINone` | Always true | Always true |
| `CCIDummy` | item != null | + item in hands |
| `CCINonRuined` | Not null, not ruined | + in hands |
| `CCINotEmpty` | Not null, quantity > 0 | + in hands |
| `CCINotRuinedAndEmpty` | Not ruined, quantity > 0 | + in hands |
| `CCINotPresent` | item == null | Can() |

### Target conditions (CCT)

| Class | Condition | Distance measured from |
|-------|---------|-------------|
| `CCTNone` | Always true | — |
| `CCTObject(dist)` | Object, not a player, not ruined | Object position |
| `CCTCursor(dist)` | Object/parent, not ruined | Cursor position |
| `CCTNonRuined(dist)` | Not Man, not ruined | Player root |
| `CCTMan(dist, alive)` | Target is Man, not self, facing target | Object position |
| `CCTSelf` | Player alive | — |
| `CCTSurface(dist)` | No object (ground) | Cursor position |
| `CCTWaterSurface(dist)` | Water surface | Player position |

Distance is checked from `player.GetPosition()` and from the head position — stance does not break the check.

---

### Registration and binding

#### Registering an action

```
modded class ActionConstructor
{
    override void RegisterActions(TTypenameArray actions)
    {
        super.RegisterActions(actions);
        actions.Insert(MyAction);
    }
}
```

#### Binding to an item

```
modded class MyItem : ItemBase
{
    override void SetActions()
    {
        super.SetActions();
        AddAction(MyAction);
    }
}
```

#### Binding to the player (self-target)

```
modded class PlayerBase
{
    override void SetActions(out TInputActionMap map)
    {
        super.SetActions(map);
        AddAction(MyAction, map);
    }
}
```

---

### Example: creating a ContinuousAction

```
class MyActionCB : ActionContinuousBaseCB
{
    override void CreateActionComponent()
    {
        m_ActionData.m_ActionComponent = new CAContinuousTime(UATimeSpent.DEFAULT);
    }
}

class MyAction : ActionContinuousBase
{
    void MyAction()
    {
        m_CallbackClass   = MyActionCB;
        m_CommandUID      = DayZPlayerConstants.CMD_ACTIONMOD_EAT;
        m_Text            = "My Action";
        m_StanceMask      = DayZPlayerConstants.STANCEMASK_ERECT | DayZPlayerConstants.STANCEMASK_CROUCH;
    }

    override void CreateConditionComponents()
    {
        m_ConditionItem   = new CCINonRuined();
        m_ConditionTarget = new CCTObject(UAMaxDistances.DEFAULT);
    }

    override bool ActionCondition(PlayerBase player, ActionTarget target, ItemBase item)
    {
        return item && item.GetQuantity() > 0;
    }

    override void OnFinishProgressServer(ActionData action_data)
    {
        action_data.m_MainItem.AddQuantity(-10);
    }
}
```
