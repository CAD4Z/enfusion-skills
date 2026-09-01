`4_World` (`worldScriptModule`) — the DayZ world layer. Contains implementations of all game entities and systems: player (PlayerBase, stats, notifiers), actions (UserActions pipeline), modifiers/agents/symptoms (diseases), items (ItemBase and descendants), weapons (Weapon FSM, recoil, magazines), vehicles (CarScript, BoatScript), construction (BaseBuildingBase), creatures (ZombieBase, AnimalBase), environment (Environment, cooking, food stages), supporting systems (inventory, temperature, bleeding, recipes, emotes, VirtualHud), plugins. Sits on top of 3_Game, serves as the base for 5_Mission.

### Navigation

`player.md` - player: PlayerBase, lifecycle, stats, notifiers, subsystems
`actions.md` - actions: ActionBase pipeline, types, components, conditions, registration
`modifiers.md` - modifiers/agents/symptoms: diseases, infections, infection pipeline
`items.md` - items: ItemBase, EdibleBase, ClothingBase, FireplaceBase, TentBase, TrapBase
`weapons.md` - weapons: Weapon_Base, FSM, recoil, magazines, attachments
`vehicles.md` - vehicles: CarScript, BoatScript, simulation, collisions
`building.md` - construction: BaseBuildingBase, Construction, lifecycle
`creatures.md` - creatures: ZombieBase, AnimalBase, AreaDamage, ScriptedLightBase
`environment.md` - environment: Environment, Cooking, FoodStage
`systems.md` - systems: inventory, temperature, catching, bleeding, recipes, emotes, VirtualHud
`plugins.md` - plugins: PluginBase, PluginDeveloper, PluginDiagMenu, PluginLocalProfile
