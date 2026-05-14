DayZ is a multiplayer post-apocalyptic open-world survival game built on the Enfusion Engine.
It is split into two main components: the client and the server — the latter holding the core gameplay configuration. Both are moddable.

Modding revolves around DayZ Tools, which covers every component of the game and includes editors such as Terrain Builder (map), Object Builder (objects), Central Economy (loot economy), Workbench (a minimal IDE for the Enfusion Engine), and more. Mods and game files are packed into PBO archives rather than kept as plain files.

The game uses a dedicated language, Enforce Script (C++-like), to define in-game logic. All source files are publicly viewable.

Documentation: `@.claude/references/INDEX.md`

### Critical constraints
1. Never attempt to build a PBO or launch the client/server. All changes are tested manually by the developer.
