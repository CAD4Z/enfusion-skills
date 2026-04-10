`4_World` — строительство. Источники: `entities/itembase/basebuildingbase.c`, `classes/basebuilding/construction.c`

### Архитектура

`BaseBuildingBase extends ItemBase` владеет объектом `Construction` (`m_Construction`), который управляет `ConstructionPart` из конфига.

```
BaseBuildingBase
 └── m_Construction: Construction
      └── map<string, ConstructionPart>  // по имени части
```

### ConstructionPart

| Поле | Описание |
|------|----------|
| `m_PartName` | Имя части |
| `m_MainPartName` | Категория (Level) |
| `m_Id` | 1–93, для битовой синхронизации |
| `m_IsBuilt` | Построена ли |
| `m_IsBase` | Базовая часть (первая, при размещении) |
| `m_IsGate` | Ворота |
| `m_RequiredParts` | Зависимости (должны быть построены) |

### Синхронизация

Три `int` битовые маски (`m_SyncParts01/02/03`), до 93 частей (31 на int). `RegisterPartForSync(id)` ставит бит → `SetSynchDirty()` → клиент читает маски → `ShowConstructionPartPhysics()` / `HideConstructionPartPhysics()`.

### Конфигурация (CfgVehicles)

```
CfgVehicles MyFence Construction {
    Level1 {
        wall_base {
            name = "Wall Base";
            id = 1;
            is_base = 1;
            show_on_init = 0;
            required_parts[] = {};
            conflicted_parts[] = {};
            Materials {
                Material_0 { slot_name = "WoodLog"; quantity = 4; lockable = 1; }
            }
        }
    }
}
```

### Lifecycle строительства

#### Постройка (сервер)

```
Construction.BuildPartServer(player, part_name, action_id)
 1. Сброс здоровья зоны урона
 2. TakeMaterialsServer() — потребить/заблокировать материалы
 3. → BaseBuildingBase.OnPartBuiltServer()
     ├── Если базовая → SetBaseState(true)
     ├── RegisterPartForSync() + SetSynchDirty()
     ├── UpdateNavmesh()
     └── UpdateVisuals()
```

#### Разборка (сервер)

```
Construction.DismantlePartServer()
 1. ReceiveMaterialsServer() — вернуть материалы игроку
 2. DropNonUsableMaterialsServer() — сбросить непригодные
 3. → BaseBuildingBase.OnPartDismantledServer()
     └── Если базовая → DestroyConstruction() (ObjectDelete, 200мс)
```

#### Разрушение (сервер)

```
Construction.DestroyPartServer()
 1. DestroyMaterialsServer() — удалить заблокированные
 2. → BaseBuildingBase.OnPartDestroyedServer()
     └── DestroyConnectedParts() — каскадное разрушение зависимых
```

При `EEHealthLevelChanged` → `STATE_RUINED` → автоматический `DestroyPartServer()`.

### Проверка постройки (`CanBuildPart`)

Все условия:
1. Часть не построена
2. `HasRequiredPart()` — все зависимости построены
3. `!HasConflictPart()` — нет конфликтующих
4. `HasMaterials()` — все слоты заполнены
5. `!MaterialIsRuined()` — материалы не сломаны
6. `CanUseToolToBuildPart()` — инструмент подходит

### Материалы

Материалы — предметы в слотах инвентаря строения. `lockable=1` — блокируется при постройке (не вынимается). Ремонт стоит `REPAIR_MATERIAL_PERCENTAGE = 0.15` (15%) от стоимости постройки.

### Переопределяемые методы BaseBuildingBase

| Метод | Назначение |
|-------|------------|
| `GetConstructionKitType()` | Classname набора (напр. `"FenceKit"`) |
| `OnPartBuiltServer(Man, string, int)` | Хук после постройки |
| `OnPartBuiltClient(string, int)` | Клиент — звуки |
| `OnPartDismantledServer(Man, string, int)` | Хук после разборки |
| `OnPartDestroyedServer(Man, string, int, bool)` | Хук после разрушения |
| `UpdateVisuals()` | Обновить визуал |
| `IsOpened()` | Состояние ворот |
