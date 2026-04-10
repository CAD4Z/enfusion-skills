`4_World` — система действий (User Actions). Самая частая точка расширения для моддеров. Источники: `classes/useractionscomponent/`

### Иерархия классов

```
ActionBase_Basic (C++)
 └── ActionBase
      ├── ActionInstantBase           — без анимации, эффект в OnStart
      ├── ActionSequentialBase        — многостадийные, без анимации
      └── AnimatedActionBase          — с анимацией и callback
           ├── ActionInteractBase     — взаимодействие (AC_INTERACT)
           │    └── ActionInteractLoopBase
           ├── ActionSingleUseBase    — одноразовые (AC_SINGLE_USE)
           ├── ActionContinuousBase   — продолжительные (AC_CONTINUOUS)
           └── FirearmActionBase      — оружейные механики
```

### Пайплайн выполнения

```
[Каждый кадр, нет активного действия]
  ActionManagerClient.FindContextualUserActions()
   → ActionInput.UpdatePossibleActions()
    → ActionBase.Can(player, target, item, conditionMask)
        1. Проверка conditionMask (транспорт/лестница/плавание...)
        2. Проверка стойки (StanceMask)
        3. CCTBase.Can() — условие цели
        4. CCIBase.Can() — условие предмета
        5. ActionCondition() — кастомная логика

[Игрок нажимает кнопку]
  ActionManager.ActionStart(action, target, item)
   → SetupAction() → CreateActionData()
   → [MP] WriteToContext() → сеть → ReadFromContext() на сервере
   → [Сервер] Can() повторно → AddActionJuncture() → ACK
   → [Клиент получает ACK] action.Start()
    → OnStart/OnStartServer/OnStartClient()
    → CreateAndSetupActionCallback() → player.StartCommand_Action()
    → ActionBaseCB.InitActionComponent() → CABase.Init()

[Каждый кадр, действие выполняется]
  AnimatedActionBase.Do(action_data, state)
   → UA_PROCESSING: CanContinue() → CABase.Execute()
   → UA_FINISHED: End()
   → UA_CANCEL: End()

[Анимационное событие "ActionExec"]
   → OnExecute() / OnExecuteServer() / OnExecuteClient()

[Для ContinuousBase: анимационный цикл]
   → "ActionExecStart" → OnStartAnimationLoop*()
   → "ActionExecEnd" → OnEndAnimationLoop*()
   → CABase завершён → OnFinishProgress*()

[Конец действия]
   → OnEnd/OnEndServer/OnEndClient()
```

### Состояния (UA_*)

| Константа | Значение | Описание |
|-----------|----------|----------|
| `UA_PROCESSING` | 2 | Компонент выполняется |
| `UA_FINISHED` | 4 | Завершено нормально |
| `UA_CANCEL` | 5 | Отменено |
| `UA_AM_PENDING` | 14 | Ожидание ACK от сервера |
| `UA_AM_ACCEPTED` | 15 | Сервер принял |
| `UA_AM_REJECTED` | 16 | Сервер отклонил |
| `UA_ANIM_EVENT` | 11 | Событие "ActionExec" |

### Типы действий

| Тип | Категория | Анимация | Когда эффект |
|-----|-----------|----------|-------------|
| `ActionInstantBase` | — | Нет | `OnStart()` |
| `ActionInteractBase` | AC_INTERACT | CMD_ACTIONMOD_PICKUP_HANDS | `OnExecute()` на ActionExec |
| `ActionSingleUseBase` | AC_SINGLE_USE | CMD_ACTIONMOD_PICKUP_HANDS | `OnExecuteServer()` на ActionExec |
| `ActionContinuousBase` | AC_CONTINUOUS | CMD_ACTIONMOD_EAT | `OnFinishProgressServer()` |
| `FirearmActionBase` | AC_SINGLE_USE | Weapon FSM | Через WeaponManager |

---

### ActionBase — ключевые переопределяемые методы

#### Идентификация

| Метод | Описание | По умолчанию |
|-------|----------|-------------|
| `HasTarget()` | Использует цель в мире | `true` |
| `IsInstant()` | Мгновенное, без анимации | `false` |
| `IsLocal()` | Только клиент, без синхронизации | `false` |
| `HasProgress()` | Показывать прогресс-бар | `true` |
| `UseMainItem()` | Предмет в руках задействован | `true` |
| `GetText()` | Текст подсказки в HUD | `m_Text` |

#### Условия

| Метод | Описание |
|-------|----------|
| `CreateConditionComponents()` | Установить `m_ConditionItem` и `m_ConditionTarget` |
| `ActionCondition(PlayerBase, ActionTarget, ItemBase)` | Основная проверка (каждый кадр) |
| `ActionConditionContinue(ActionData)` | Проверка во время выполнения |
| `GetStanceMask(PlayerBase)` | Допустимые стойки |

#### Флаги состояний игрока (condition mask)

`CanBeUsedInVehicle()`, `CanBeUsedSwimming()`, `CanBeUsedOnLadder()`, `CanBeUsedInRestrain()`, `CanBeUsedRaised()`, `CanBeUsedOnBack()`, `CanBeUsedWithBrokenLegs()`

#### Хуки выполнения

| Метод | Когда |
|-------|-------|
| `OnStart/OnStartServer/OnStartClient(ActionData)` | Начало действия |
| `OnEnd/OnEndServer/OnEndClient(ActionData)` | Конец действия |
| `OnExecute/OnExecuteServer/OnExecuteClient(ActionData)` | Событие ActionExec |
| `OnUpdate/OnUpdateServer/OnUpdateClient(ActionData)` | Каждый кадр |

#### Дополнительные хуки ContinuousBase

| Метод | Когда |
|-------|-------|
| `OnStartAnimationLoopServer/Client(ActionData)` | Начало цикла анимации |
| `OnEndAnimationLoopServer/Client(ActionData)` | Конец цикла анимации |
| `OnFinishProgressServer/Client(ActionData)` | Компонент завершён |

#### Синхронизация

| Метод | Описание |
|-------|----------|
| `CreateActionData()` | Вернуть кастомный подкласс ActionData |
| `WriteToContext(ctx, ActionData)` | Сериализация → сервер |
| `ReadFromContext(ctx, out ActionReciveData)` | Десериализация на сервере |
| `HandleReciveData(ActionReciveData, ActionData)` | Применить данные |

---

### Компоненты действий (CABase)

Определяют **длительность и логику завершения** действия. Создаются в `ActionBaseCB::CreateActionComponent()`.

```
CABase
 ├── CAInteract / CASingleUse      — мгновенное завершение
 ├── CAContinuousTime               — завершение через N секунд
 ├── CAContinuousRepeat             — повтор каждые N секунд
 ├── CAContinuousQuantity           — потребление количества предмета
 │    ├── CAContinuousQuantityEdible
 │    ├── CAContinuousQuantityLiquidTransfer
 │    └── ...
 ├── CAContinuousFill / Empty       — жидкости
 ├── CAContinuousMineRock/Wood      — добыча
 ├── CAContinuousCraft              — крафт
 └── ...
```

#### CABase API

| Метод | Описание |
|-------|----------|
| `Setup(ActionData)` | Инициализация при старте |
| `Execute(ActionData)` | Каждый кадр → `UA_PROCESSING` / `UA_FINISHED` / `UA_CANCEL` |
| `Cancel(ActionData)` | Отмена игроком |
| `GetProgress()` | 0..1 для прогресс-бара |

#### Основные компоненты

| Компонент | Конструктор | Логика |
|-----------|-------------|--------|
| `CAContinuousTime(float sec)` | Время до завершения | `elapsed >= total` → FINISHED |
| `CAContinuousRepeat(float sec)` | Время цикла | Сброс после каждого цикла, вечный |
| `CAContinuousQuantity(float per_sec)` | Расход в секунду | `spent >= item.quantity` → FINISHED |

---

### Условия предмета (CCI)

| Класс | Условие Can() | CanContinue() |
|-------|---------------|---------------|
| `CCINone` | Всегда true | Всегда true |
| `CCIDummy` | item != null | + предмет в руках |
| `CCINonRuined` | Не null, не сломан | + в руках |
| `CCINotEmpty` | Не null, quantity > 0 | + в руках |
| `CCINotRuinedAndEmpty` | Не сломан, quantity > 0 | + в руках |
| `CCINotPresent` | item == null | Can() |

### Условия цели (CCT)

| Класс | Условие | Дистанция от |
|-------|---------|-------------|
| `CCTNone` | Всегда true | — |
| `CCTObject(dist)` | Объект, не игрок, не сломан | Позиция объекта |
| `CCTCursor(dist)` | Объект/родитель, не сломан | Позиция курсора |
| `CCTNonRuined(dist)` | Не Man, не сломан | Корень игрока |
| `CCTMan(dist, alive)` | Цель — Man, не сам, лицом к цели | Позиция объекта |
| `CCTSelf` | Игрок жив | — |
| `CCTSurface(dist)` | Нет объекта (земля) | Позиция курсора |
| `CCTWaterSurface(dist)` | Водная поверхность | Позиция игрока |

Дистанция проверяется от `player.GetPosition()` и от позиции головы — стойка не ломает проверку.

---

### Регистрация и привязка

#### Регистрация действия

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

#### Привязка к предмету

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

#### Привязка к игроку (self-target)

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

### Пример: создание ContinuousAction

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
