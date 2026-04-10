Иерархия сущностей игрового слоя. Источники: `entities/*.c`

### Иерархия наследования

```
IEntity (1_Core)
└── ObjectTyped
    └── Entity
        └── EntityAI
            ├── Man (игрок)
            ├── Building (здания)
            ├── InventoryItem (предметы)
            ├── DayZCreatureAI
            │   ├── DayZInfected (зомби)
            │   └── DayZAnimal (животные)
            ├── ScriptedEntity
            └── EntityLightSource
        └── Object (физический объект)
        └── Camera (камера)
        └── Pawn (сетевая сверка, см. примечание)
```

Примечание: `Man` наследует `Pawn` при `FEATURE_NETWORK_RECONCILIATION`, иначе `EntityAI` напрямую.

### Entity

Наследует `ObjectTyped`. Источник: `entities/entity.c`

#### Симуляция и анимация (proto native)

| Метод | Возврат | Описание |
|-------|---------|----------|
| `DisableSimulation(bool disable)` | `void` | Вкл/выкл симуляцию |
| `GetIsSimulationDisabled()` | `bool` | Проверка состояния |
| `GetSimulationTimeStamp()` | `int` | Тик симуляции |
| `GetAnimationPhase(animation)` | `float` | Фаза анимации |
| `SetAnimationPhase(animation, phase)` | `void` | Установить фазу |
| `ResetAnimationPhase(animation, phase)` | `void` | Сбросить немедленно |
| `GetBoneIndex(proxySelectionName)` | `int` | Индекс кости по имени |
| `GetBoneObject(boneIndex)` | `Object` | Proxy-объект кости |
| `SetInvisible(invisible)` | `void` | Невидимость |
| `MoveInTime(targetTransform[4], deltaT)` | `void` | Серверная телепортация / клиентская интерполяция |

#### Callback-и

| Метод | Описание |
|-------|----------|
| `OnAnimationPhaseStarted(animSource, phase)` | Начало фазы анимации |
| `OnCreatePhysics()` | Создание физики при добавлении в мир |
| `OnNetworkTransformUpdate(out pos, out ypr)` | Обновление трансформа по сети. `true` = визуальный срез |

### EntityAI

Наследует `Entity`. Основной класс сущностей с инвентарём, уроном, весом и компонентами. Источник: `entities/entityai.c`

#### Ключевые поля

| Поле | Тип | Описание |
|------|-----|----------|
| `m_KillerData` | `KillerData` | Данные убийцы |
| `m_EM` | `ComponentEnergyManager` | Энергетический компонент |
| `m_DamageZoneMap` | `DamageZoneMap` | Карта зон урона |
| `m_Weight` / `m_WeightEx` | `float` | Текущий / дополнительный вес |
| `m_VarTemperature` | `float` | Температура предмета |
| `m_IsFrozen` | `bool` | Заморожен |

#### Компоненты

| Метод | Возврат | Описание |
|-------|---------|----------|
| `CreateComponent(comp_type, extended_class_name)` | `Component` | Создать компонент |
| `GetComponent(comp_type, extended_class_name)` | `Component` | Получить (или создать) |
| `DeleteComponent(comp_type)` | `bool` | Удалить компонент |
| `HasComponent(comp_type)` | `bool` | Проверка наличия |

#### ScriptInvoker-ы

| Геттер | Когда вызывается |
|--------|------------------|
| `GetOnItemAttached()` | Предмет прикреплён к этой сущности |
| `GetOnItemDetached()` | Предмет откреплён |
| `GetOnItemAddedIntoCargo()` | Предмет добавлен в карго |
| `GetOnItemRemovedFromCargo()` | Предмет удалён из карго |
| `GetOnItemMovedInCargo()` | Предмет перемещён в карго |
| `GetOnItemFlipped()` | Предмет повёрнут |
| `GetOnViewIndexChanged()` | Изменён индекс вида |
| `GetOnSetLock()` / `GetOnReleaseLock()` | Резервирование карго |
| `GetOnAttachmentSetLock()` / `GetOnAttachmentReleaseLock()` | Резервирование аттачмента |
| `GetOnHitByInvoker()` | Сущность получила урон |
| `GetOnKilledInvoker()` | Сущность убита |

#### Enum-ы

`EWetnessLevel`: `DRY`, `DAMP`, `WET`, `SOAKING`, `DRENCHED`

`PlantType`: `TREE_HARD(1000)`, `TREE_SOFT`, `BUSH_HARD`, `BUSH_SOFT`

`WeightUpdateType`: `FULL`, `ADD`, `REMOVE`, `RECURSIVE_ADD`, `RECURSIVE_REMOVE`

`EItemManipulationContext`: `UPDATE`, `ATTACHING`, `DETACHING`

`EInventoryIconVisibility` (битовая маска): `ALWAYS(0)`, `HIDE_VICINITY(1)`, `HIDE_PLAYER_CONTAINER(2)`, `HIDE_HANDS_SLOT(4)`

`EAttExclusions`: ограничения комбинаций аттачментов — `EXCLUSION_HEADGEAR_HELMET_0`, `EXCLUSION_MASK_0..3`, `EXCLUSION_GLASSES_REGULAR_0`, `EXCLUSION_GLASSES_TIGHT_0` и др.

### Man

Наследует `EntityAI` (или `Pawn`). Управляемый персонаж. Источник: `entities/man.c`

#### Proto native

| Метод | Возврат | Описание |
|-------|---------|----------|
| `GetInputInterface()` | `UAInterface` | Интерфейс ввода |
| `GetIdentity()` | `PlayerIdentity` | Идентичность игрока (MP) |
| `GetDrivingVehicle()` | `EntityAI` | Транспорт, которым управляет (или `NULL`) |
| `GetHumanInventory()` | `HumanInventory` | Инвентарь игрока |
| `GetEntityInHands()` | `EntityAI` | Предмет в руках |
| `GetCurrentWeaponMode()` | `string` | Текущий режим оружия |
| `SetSpeechRestricted(state)` / `IsSpeechRestricted()` | — / `bool` | Ограничение речи |
| `SetFaceTexture(texture)` / `SetFaceMaterial(material)` | `void` | Текстура/материал лица |
| `IsSoundInsideBuilding()` | `bool` | Звук внутри здания |
| `IsCameraInsideVehicle()` | `bool` | Камера внутри транспорта |
| `SetMasterAttenuation(att)` / `GetMasterAttenuation()` | — / `string` | Мастер-аттенюация звука |

#### Инвентарные операции

| Метод | Описание |
|-------|----------|
| `PredictiveDropEntity(item)` | Бросить предмет (клиентская предикция) |
| `LocalDropEntity(item)` | Бросить локально |
| `ServerDropEntity(item)` | Бросить на сервере |
| `IsUnconscious()` | В бессознании |

#### ScriptInvoker-ы

`GetOnItemAddedToHands()`, `GetOnItemRemovedFromHands()` — вызываются через `EEItemIntoHands()` / `EEItemOutOfHands()`.

### Building

Наследует `EntityAI`. Здания с дверями и лестницами. Источник: `entities/building.c`

#### Двери (proto native)

| Метод | Описание |
|-------|----------|
| `GetDoorCount()` | Количество дверей |
| `GetDoorIndex(componentIndex)` | Компонент → индекс двери |
| `IsDoorOpen(index)` | Запрошено открытие (фаза > 0.5) |
| `IsDoorOpened(index)` / `IsDoorClosed(index)` | Фаза на цели (1.0 / 0.0) |
| `IsDoorOpening(index)` / `IsDoorClosing(index)` | В процессе анимации |
| `IsDoorOpenedAjar(index)` / `IsDoorOpeningAjar(index)` | Приоткрыта (фаза 0.2) |
| `IsDoorLocked(index)` | Заблокирована |
| `OpenDoor(index)` / `CloseDoor(index)` | Открыть/закрыть |
| `LockDoor(index, force)` | Заблокировать. `force=true` — закроет если открыта |
| `UnlockDoor(index, animate)` | Разблокировать. `animate=true` — приоткроет |
| `GetDoorSoundPos(index)` / `GetDoorSoundDistance(index)` | Позиция/дальность звука |
| `PlayDoorSound(index)` | Проиграть звук двери |

#### Лестницы (proto native)

| Метод | Описание |
|-------|----------|
| `GetLaddersCount()` | Количество лестниц |
| `GetLadderPosTop(index)` / `GetLadderPosBottom(index)` | Позиции верха/низа |

#### События дверей

`OnDoorOpenStart`, `OnDoorOpenFinish`, `OnDoorOpenAjarStart`, `OnDoorOpenAjarFinish`, `OnDoorCloseStart`, `OnDoorCloseFinish`, `OnDoorLocked`, `OnDoorUnlocked`

### DayZInfected

Наследует `DayZCreatureAI`. Заражённые (зомби). Источник: `entities/dayzinfected.c`

#### Константы

`DayZInfectedConstants` (команды): `COMMANDID_MOVE`, `COMMANDID_VAULT`, `COMMANDID_DEATH`, `COMMANDID_HIT`, `COMMANDID_ATTACK`, `COMMANDID_CRAWL`, `COMMANDID_SCRIPT`

`DayZInfectedConstants` (состояния ИИ): `MINDSTATE_CALM`, `MINDSTATE_DISTURBED`, `MINDSTATE_ALERTED`, `MINDSTATE_CHASE`, `MINDSTATE_FIGHT`

`DayZInfectedConstantsMovement`: `MOVEMENTSTATE_IDLE(0)`, `MOVEMENTSTATE_WALK`, `MOVEMENTSTATE_RUN`, `MOVEMENTSTATE_SPRINT`

`DayZInfectedDeathAnims`: `ANIM_DEATH_DEFAULT(0)`, `ANIM_DEATH_IMPULSE(1)`, `ANIM_DEATH_BACKSTAB(2)`, `ANIM_DEATH_NECKSTAB(3)`

#### Команды (proto native)

| Метод | Возврат | Описание |
|-------|---------|----------|
| `StartCommand_Move()` | `DayZInfectedCommandMove` | Начать движение |
| `StartCommand_Vault(type)` | — | Перепрыгивание |
| `StartCommand_Death(type, direction)` | — | Смерть |
| `StartCommand_Hit(heavy, type, direction)` | — | Получение удара |
| `StartCommand_Attack(target, type, subtype)` | `DayZInfectedCommandAttack` | Атака |
| `StartCommand_Crawl(type)` | — | Ползание |
| `StartCommand_Script(cmd)` / `StartCommand_ScriptInst(typename)` | `DayZInfectedCommandScript` | Скриптовая команда |
| `GetCommand_Move()` / `GetCommand_Vault()` / `GetCommand_Attack()` / `GetCommand_Script()` | — | Получить текущую команду |
| `CanAttackToPosition(targetPos)` | `bool` | Может ли атаковать позицию |

#### Классы команд

| Класс | Ключевые методы |
|-------|-----------------|
| `DayZInfectedCommandMove` | `SetStanceVariation()`, `SetIdleState()`, `StartTurn(dir, speed)`, `IsTurning()` |
| `DayZInfectedCommandAttack` | `WasHit()` |
| `DayZInfectedCommandVault` | `WasLand()` |
| `DayZInfectedCommandScript` | `SetFlagFinished()`, `PrePhys_Get/SetTranslation/Rotation()`, `PostPhys_Get/SetPosition/Rotation()`, `PostPhys_LockRotation()` |

### InventoryItem

Наследует `EntityAI`. Предметы инвентаря. Источник: `entities/inventoryitem.c`

| Метод | Описание |
|-------|----------|
| `SwitchOn()` / `IsOn()` | Включение/состояние |
| `EnableCollisionsWithCharacter(state)` | Коллизии с персонажем |
| `GetMeleeCombatData()` | Данные ближнего боя |
| `ThrowPhysically(player, force)` | Бросить физически |
| `ForceFarBubble(state)` | Принудительное сетевое расстояние |

### Object

Наследует `Entity`. Физический объект мира. Источник: `entities/object.c`

| Метод | Описание |
|-------|----------|
| `Delete()` | Удалить объект |
| `AddProxyPhysics(proxyName)` / `RemoveProxyPhysics(proxyName)` | Управление proxy-физикой |
| `GetLODS(out array)` | Получить LOD-ы |

### Pawn

Базовый класс сетевой сверки (`FEATURE_NETWORK_RECONCILIATION`). Источник: `entities/pawn.c`

| Класс | Описание |
|-------|----------|
| `PawnMove` | Данные перемещения для сверки |
| `PawnOwnerState` | Состояние владельца |
| `NetworkMoveStrategy` | `NONE`, `LATEST`, `PHYSICS` |
