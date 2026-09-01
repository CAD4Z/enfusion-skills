`config.cpp` — the configuration file at the root of every PBO/mod that describes its contents and defines game entities and their properties through a class hierarchy. The syntax is C++-like.
It can optionally be binarized when building the PBO.

The configs of all loaded PBOs are merged by the engine into a single tree — classes with identical names within the same Cfg section extend/override each other.

### Navigation

`Classes/cfg_patches.md` - registers the PBO in the engine's addon system (mandatory)  
`Classes/cfg_mods.md` - describes the mod and specifies which script modules to attach (mandatory)  
`Classes/cfg_vehicles.md` - main entity registry  
`Classes/cfg_weapons.md` - weapon registry  
`Classes/cfg_magazines.md` - registry of magazines and loose rounds  
`Classes/cfg_ammo.md` - registry of projectiles/bullets  
`Classes/other_cfg.md` - other config classes

`mod_cpp.md` - responsible for the main menu presentation  
`scripts_api.md` - reading configs from Enforce Script  
