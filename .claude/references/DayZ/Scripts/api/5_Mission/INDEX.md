`5_Mission` (`missionScriptModule`) — the top layer of the client and server. Contains mission classes (lifecycle game/server/main menu), HUD on top of the game world (stats, quickbar, vehicle HUD, gameplay effects), inventory UI (drag & drop, vicinity, containers), all in-game menus (inspect, map, note, gestures, respawn, …), main menu with character creation and server browser, chat, dev tools (ScriptConsole, SceneEditor, CameraTools). Built on top of 4_World, the entry point of the entire UI portion of the game.

### Navigation

`@.claude/references/DayZ/Scripts/api/5_Mission/mission.md` - missions: MissionBase/Server/Gameplay/MainMenu, lifecycle, CreateScriptedMenu factory, OnEvent router
`@.claude/references/DayZ/Scripts/api/5_Mission/hud.md` - HUD: IngameHud, IngameHudVisibility, VehicleHud, HudDebug, DebugMonitor, GameplayEffectWidgets, BleedingIndicator
`@.claude/references/DayZ/Scripts/api/5_Mission/inventory.md` - inventory UI: InventoryMenu, LayoutHolder, Container hierarchy, ItemManager, VicinityItemManager, Quickbar, ColorManager, CombinationFlags
`@.claude/references/DayZ/Scripts/api/5_Mission/menus.md` - in-game menus: InGameMenu (Xbox/PC), Inspect, Map, Note, Book, Gestures, RadialQuickbar, Logout, Respawn, Invite, Warning, Loading, Connection
`@.claude/references/DayZ/Scripts/api/5_Mission/mainmenu.md` - main menu: MainMenu (PC/Console), TitleScreen, Startup, MainMenuData, CharacterCreation, ServerBrowser, Options, Keybindings, Credits, OptionSelector framework
`@.claude/references/DayZ/Scripts/api/5_Mission/chat.md` - chat: Chat, ChatLine, ChatInputMenu, channels (CCSystem/CCAdmin/CCDirect/CCMegaphone/CCTransmitter/CCPublicAddressSystem/CCBattlEye), filters via EDayZProfilesOptions
`@.claude/references/DayZ/Scripts/api/5_Mission/dev_tools.md` - dev tools: ScriptConsole (Items/Config/EnScript/General/Output/Vicinity/Sounds/Weather/Camera tabs), SceneEditorMenu, CameraToolsMenu
