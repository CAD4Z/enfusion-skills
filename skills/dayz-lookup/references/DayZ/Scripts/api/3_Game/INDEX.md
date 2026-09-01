`3_Game` (`gameScriptModule`) — the DayZ game layer. Contains the main game class (CGame/DayZGame), the entity system (Entity→EntityAI→Man/Building/Object), player control (HumanInputController, cameras, items in hands), inventory (GameInventory, HandFSM), damage and bleeding systems, weather, sound, effects and post-processing (PPEManager), vehicles (Car/Helicopter/Boat), networking (RPC, Hive, REST), UI, AI, central economy and gameplay configuration. Built on top of 2_GameLib, serves as the base for 4_World.

Also contains: BIOS services, analytics, autotests, Xbox demo — not documented, not used in PC modding.

### Navigation

`game.md` - CGame, DayZGame, World: lifecycle, states, config, world
`entities.md` - entity hierarchy: Entity, EntityAI, Man, Building, Object, InventoryItem, DayZInfected, DayZAnimal
`human.md` - player: HumanInputController, cameras, items in hands, movement settings, EActions
`inventory.md` - inventory: GameInventory, HumanInventory, slots, cargo, Hand FSM
`damage.md` - damage: DamageSystem, bleeding, HitInfo, PlayerConstants
`sound.md` - sound: AbstractSoundScene, SoundObject, AbstractWave, DynamicMusicPlayer
`effects.md` - effects: Effect, SEffectManager, PPEManager, post-processing
`weather.md` - weather: Weather, WeatherPhenomenon, dynamic system
`vehicles.md` - vehicles: Transport, Car, Helicopter, Boat
`network.md` - network: ScriptRPC, JsonSerializer, SyncEvents, REST API, Hive, ERPCs
`ui.md` - UI: UIManager, UIScriptedMenu, widgets, Colors
`config.md` - configuration: CfgGameplayHandler, CfgGameplayJson, ModInfo, ObjectSpawnerHandler
`ai.md` - AI: AIWorld, AIAgent, AIGroup, PGFilter, navmesh
`particles.md` - particles: ParticleManager, ParticleSource, ParticleList
`ce.md` - central economy: CentralEconomy, ECE flags, RF flags
`fsm.md` - finite state machines: FSMBase, HFSMBase, pattern
`components.md` - components: Component, ComponentEnergyManager, UniversalTemperatureSource
