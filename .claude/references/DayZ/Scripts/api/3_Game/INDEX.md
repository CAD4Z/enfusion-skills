`3_Game` (`gameScriptModule`) — the DayZ game layer. Contains the main game class (CGame/DayZGame), the entity system (Entity→EntityAI→Man/Building/Object), player control (HumanInputController, cameras, items in hands), inventory (GameInventory, HandFSM), damage and bleeding systems, weather, sound, effects and post-processing (PPEManager), vehicles (Car/Helicopter/Boat), networking (RPC, Hive, REST), UI, AI, central economy and gameplay configuration. Built on top of 2_GameLib, serves as the base for 4_World.

Also contains: BIOS services, analytics, autotests, Xbox demo — not documented, not used in PC modding.

### Navigation

`@.claude/references/DayZ/Scripts/api/3_Game/game.md` - CGame, DayZGame, World: lifecycle, states, config, world
`@.claude/references/DayZ/Scripts/api/3_Game/entities.md` - entity hierarchy: Entity, EntityAI, Man, Building, Object, InventoryItem, DayZInfected, DayZAnimal
`@.claude/references/DayZ/Scripts/api/3_Game/human.md` - player: HumanInputController, cameras, items in hands, movement settings, EActions
`@.claude/references/DayZ/Scripts/api/3_Game/inventory.md` - inventory: GameInventory, HumanInventory, slots, cargo, Hand FSM
`@.claude/references/DayZ/Scripts/api/3_Game/damage.md` - damage: DamageSystem, bleeding, HitInfo, PlayerConstants
`@.claude/references/DayZ/Scripts/api/3_Game/sound.md` - sound: AbstractSoundScene, SoundObject, AbstractWave, DynamicMusicPlayer
`@.claude/references/DayZ/Scripts/api/3_Game/effects.md` - effects: Effect, SEffectManager, PPEManager, post-processing
`@.claude/references/DayZ/Scripts/api/3_Game/weather.md` - weather: Weather, WeatherPhenomenon, dynamic system
`@.claude/references/DayZ/Scripts/api/3_Game/vehicles.md` - vehicles: Transport, Car, Helicopter, Boat
`@.claude/references/DayZ/Scripts/api/3_Game/network.md` - network: ScriptRPC, JsonSerializer, SyncEvents, REST API, Hive, ERPCs
`@.claude/references/DayZ/Scripts/api/3_Game/ui.md` - UI: UIManager, UIScriptedMenu, widgets, Colors
`@.claude/references/DayZ/Scripts/api/3_Game/config.md` - configuration: CfgGameplayHandler, CfgGameplayJson, ModInfo, ObjectSpawnerHandler
`@.claude/references/DayZ/Scripts/api/3_Game/ai.md` - AI: AIWorld, AIAgent, AIGroup, PGFilter, navmesh
`@.claude/references/DayZ/Scripts/api/3_Game/particles.md` - particles: ParticleManager, ParticleSource, ParticleList
`@.claude/references/DayZ/Scripts/api/3_Game/ce.md` - central economy: CentralEconomy, ECE flags, RF flags
`@.claude/references/DayZ/Scripts/api/3_Game/fsm.md` - finite state machines: FSMBase, HFSMBase, pattern
`@.claude/references/DayZ/Scripts/api/3_Game/components.md` - components: Component, ComponentEnergyManager, UniversalTemperatureSource
