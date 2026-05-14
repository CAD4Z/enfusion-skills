`1_Core` (`engineScriptModule`) — the foundational script layer. Contains proto native bindings to the C++ Enfusion engine, base types, collections, math, entity system, physics, debugging, and file I/O. All higher-level modules (2_GameLib — 5_Mission) depend on it.

### Navigation

`references/DayZ/Scripts/api/1_Core/types.md` - primitives (int, float, bool, vector, string, typename, EnumTools)
`references/DayZ/Scripts/api/1_Core/collections.md` - collections (array, set, map) and typedefs
`references/DayZ/Scripts/api/1_Core/math.md` - math (Math, Math2D, Math3D, quaternions, intersections)
`references/DayZ/Scripts/api/1_Core/script_core.md` - script core (Class, Managed, ScriptModule, EnScript, Param, Sort)
`references/DayZ/Scripts/api/1_Core/entity.md` - entity system (IEntity, events, flags, transformations, hierarchy)
`references/DayZ/Scripts/api/1_Core/debug.md` - debugging (Print, ErrorEx, Shape, DiagMenu, DebugText)
`references/DayZ/Scripts/api/1_Core/system.md` - system functions (FileIO, input, time, CLI)
`references/DayZ/Scripts/api/1_Core/visual.md` - visual objects (models, bones, animations, particles)
`references/DayZ/Scripts/api/1_Core/widgets.md` - UI widgets (Widget system)
`references/DayZ/Scripts/api/1_Core/constants.md` - constants (Input, Colors, Materials)
`references/DayZ/Scripts/api/1_Core/defines.md` - preprocessor (#define: build, server, platform)
`references/DayZ/Scripts/api/1_Core/physics.md` - physics (Physics, geometries, joints, world)
