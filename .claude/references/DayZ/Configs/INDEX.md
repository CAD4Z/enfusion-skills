`config.cpp` — the configuration file at the root of every PBO/mod that describes its contents and defines game entities and their properties through a class hierarchy. The syntax is C++-like.
It can optionally be binarized when building the PBO.

The configs of all loaded PBOs are merged by the engine into a single tree — classes with identical names within the same Cfg section extend/override each other.

### Navigation

`@.claude/references/DayZ/Configs/Classes/cfg_patches.md` - registers the PBO in the engine's addon system (mandatory)  
`@.claude/references/DayZ/Configs/Classes/cfg_mods.md` - describes the mod and specifies which script modules to attach (mandatory)  
`@.claude/references/DayZ/Configs/Classes/cfg_vehicles.md` - main entity registry  
`@.claude/references/DayZ/Configs/Classes/cfg_weapons.md` - weapon registry  
`@.claude/references/DayZ/Configs/Classes/cfg_magazines.md` - registry of magazines and loose rounds  
`@.claude/references/DayZ/Configs/Classes/cfg_ammo.md` - registry of projectiles/bullets  
`@.claude/references/DayZ/Configs/Classes/other_cfg.md` - other config classes

`@.claude/references/DayZ/Configs/mod_cpp.md` - responsible for the main menu presentation  
`@.claude/references/DayZ/Configs/scripts_api.md` - reading configs from Enforce Script  
