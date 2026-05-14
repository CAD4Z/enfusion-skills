`4_World` (`worldScriptModule`) — the DayZ world layer. Contains implementations of all game entities and systems: player (PlayerBase, stats, notifiers), actions (UserActions pipeline), modifiers/agents/symptoms (diseases), items (ItemBase and descendants), weapons (Weapon FSM, recoil, magazines), vehicles (CarScript, BoatScript), construction (BaseBuildingBase), creatures (ZombieBase, AnimalBase), environment (Environment, cooking, food stages), supporting systems (inventory, temperature, bleeding, recipes, emotes, VirtualHud), plugins. Sits on top of 3_Game, serves as the base for 5_Mission.

### Navigation

`@.claude/references/DayZ/Scripts/api/4_World/player.md` - player: PlayerBase, lifecycle, stats, notifiers, subsystems
`@.claude/references/DayZ/Scripts/api/4_World/actions.md` - actions: ActionBase pipeline, types, components, conditions, registration
`@.claude/references/DayZ/Scripts/api/4_World/modifiers.md` - modifiers/agents/symptoms: diseases, infections, infection pipeline
`@.claude/references/DayZ/Scripts/api/4_World/items.md` - items: ItemBase, EdibleBase, ClothingBase, FireplaceBase, TentBase, TrapBase
`@.claude/references/DayZ/Scripts/api/4_World/weapons.md` - weapons: Weapon_Base, FSM, recoil, magazines, attachments
`@.claude/references/DayZ/Scripts/api/4_World/vehicles.md` - vehicles: CarScript, BoatScript, simulation, collisions
`@.claude/references/DayZ/Scripts/api/4_World/building.md` - construction: BaseBuildingBase, Construction, lifecycle
`@.claude/references/DayZ/Scripts/api/4_World/creatures.md` - creatures: ZombieBase, AnimalBase, AreaDamage, ScriptedLightBase
`@.claude/references/DayZ/Scripts/api/4_World/environment.md` - environment: Environment, Cooking, FoodStage
`@.claude/references/DayZ/Scripts/api/4_World/systems.md` - systems: inventory, temperature, catching, bleeding, recipes, emotes, VirtualHud
`@.claude/references/DayZ/Scripts/api/4_World/plugins.md` - plugins: PluginBase, PluginDeveloper, PluginDiagMenu, PluginLocalProfile
