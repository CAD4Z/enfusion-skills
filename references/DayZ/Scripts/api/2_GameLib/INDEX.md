`2_GameLib` (`gameLibScriptModule`) — game library layer. Contains the Game class (lifecycle, spawning), callback system (ScriptCallQueue, ScriptInvoker, ScriptCaller), input (InputManager), menus (MenuManager), settings (Settings), component system (GenericComponent, ScriptComponent), extended entities (GenericEntity, CharacterEntity), and a testing framework. Built on top of 1_Core, base for 3_Game.

### Navigation

`references/DayZ/Scripts/api/2_GameLib/game.md` - Game class: lifecycle, entity spawning, world management
`references/DayZ/Scripts/api/2_GameLib/callbacks.md` - ScriptCallQueue, ScriptInvoker, ScriptCaller
`references/DayZ/Scripts/api/2_GameLib/input.md` - ActionManager, InputManager, InputTrigger
`references/DayZ/Scripts/api/2_GameLib/menus.md` - MenuManager, MenuBase, dialogs
`references/DayZ/Scripts/api/2_GameLib/settings.md` - Settings, GameSettings, SettingsMenu
`references/DayZ/Scripts/api/2_GameLib/components.md` - GenericComponent, ScriptComponent, BaseSoundComponent
`references/DayZ/Scripts/api/2_GameLib/entities.md` - GenericEntity, LightEntity, CharacterEntity, hierarchy
`references/DayZ/Scripts/api/2_GameLib/testing.md` - TestHarness, TestSuite, TestBase, stages
