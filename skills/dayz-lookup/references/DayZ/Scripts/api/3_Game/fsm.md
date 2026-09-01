Finite state machines (FSM). Sources: `systems/fsm/`

### Architecture

```
FSMBase<StateClass, EventClass, TransitionClass>
├── HFSMBase (hierarchical FSM)
└── OFSMBase (object FSM)
```

FSM is a generic template with typed states, events, and transitions.

### FSMTransition

Transition between states.

| Field | Description |
|-------|-------------|
| `m_srcState` | Source state |
| `m_dstState` | Destination state |
| `m_event` | Trigger event |
| `m_guard` | Guard condition (can block the transition) |
| `m_action` | Action on transition |

### ProcessEventResult

```
FSM_OK — event processed
FSM_NO_TRANSITION — no matching transition
FSM_TERMINATED — machine terminated
```

### FSMBase

Base FSM.

| Method | Description |
|--------|-------------|
| `Start(initialState)` | Start with initial state |
| `Terminate()` | Terminate |
| `ProcessEvent(event)` | Handle event → transition |
| `GetCurrentState()` | Current state |
| `IsRunning()` | Machine is running |
| `AddTransition(transition)` | Add a transition |

### HFSMBase

Hierarchical FSM. States may contain nested FSMs.

| Method | Description |
|--------|-------------|
| `ProcessEvent(event)` | Handle with delegation to nested machines |
| `ProcessAbortEvent(event)` | Abort with rollback |

### OFSMBase

Object FSM. States are stored as objects bound to an owner.

### Usage in DayZ

- **HandFSM** (`systems/hand/`) — operations with items in hands (see `inventory.md`)
- **AI behaviour** — infected and animal states
- **Weapon mechanisms** — bolt and magazine states (4_World)
