`2_GameLib` (`gameLibScriptModule`) — game library layer. Contains the Game class (lifecycle, spawning), callback system (ScriptCallQueue, ScriptInvoker, ScriptCaller), input (InputManager), menus (MenuManager), settings (Settings), component system (GenericComponent, ScriptComponent), extended entities (GenericEntity, CharacterEntity), and a testing framework. Built on top of 1_Core, base for 3_Game.

### Navigation

`game.md` - Game class: lifecycle, entity spawning, world management
`callbacks.md` - ScriptCallQueue, ScriptInvoker, ScriptCaller
`input.md` - ActionManager, InputManager, InputTrigger
`menus.md` - MenuManager, MenuBase, dialogs
`settings.md` - Settings, GameSettings, SettingsMenu
`components.md` - GenericComponent, ScriptComponent, BaseSoundComponent
`entities.md` - GenericEntity, LightEntity, CharacterEntity, hierarchy
`testing.md` - TestHarness, TestSuite, TestBase, stages
