`4_World` (`worldScriptModule`) — the DayZ world layer. Contains implementations of all game entities and systems: player (PlayerBase, stats, notifiers), actions (UserActions pipeline), modifiers/agents/symptoms (diseases), items (ItemBase and descendants), weapons (Weapon FSM, recoil, magazines), vehicles (CarScript, BoatScript), construction (BaseBuildingBase), creatures (ZombieBase, AnimalBase), environment (Environment, cooking, food stages), supporting systems (inventory, temperature, bleeding, recipes, emotes, VirtualHud), plugins. Sits on top of 3_Game, serves as the base for 5_Mission.

### Navigation

`references/DayZ/Scripts/api/4_World/player.md` - player: PlayerBase, lifecycle, stats, notifiers, subsystems
`references/DayZ/Scripts/api/4_World/actions.md` - actions: ActionBase pipeline, types, components, conditions, registration
`references/DayZ/Scripts/api/4_World/modifiers.md` - modifiers/agents/symptoms: diseases, infections, infection pipeline
`references/DayZ/Scripts/api/4_World/items.md` - items: ItemBase, EdibleBase, ClothingBase, FireplaceBase, TentBase, TrapBase
`references/DayZ/Scripts/api/4_World/weapons.md` - weapons: Weapon_Base, FSM, recoil, magazines, attachments
`references/DayZ/Scripts/api/4_World/vehicles.md` - vehicles: CarScript, BoatScript, simulation, collisions
`references/DayZ/Scripts/api/4_World/building.md` - construction: BaseBuildingBase, Construction, lifecycle
`references/DayZ/Scripts/api/4_World/creatures.md` - creatures: ZombieBase, AnimalBase, AreaDamage, ScriptedLightBase
`references/DayZ/Scripts/api/4_World/environment.md` - environment: Environment, Cooking, FoodStage
`references/DayZ/Scripts/api/4_World/systems.md` - systems: inventory, temperature, catching, bleeding, recipes, emotes, VirtualHud
`references/DayZ/Scripts/api/4_World/plugins.md` - plugins: PluginBase, PluginDeveloper, PluginDiagMenu, PluginLocalProfile
