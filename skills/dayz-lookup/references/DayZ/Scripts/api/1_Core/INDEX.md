`1_Core` (`engineScriptModule`) — the foundational script layer. Contains proto native bindings to the C++ Enfusion engine, base types, collections, math, entity system, physics, debugging, and file I/O. All higher-level modules (2_GameLib — 5_Mission) depend on it.

### Navigation

`types.md` - primitives (int, float, bool, vector, string, typename, EnumTools)
`collections.md` - collections (array, set, map) and typedefs
`math.md` - math (Math, Math2D, Math3D, quaternions, intersections)
`script_core.md` - script core (Class, Managed, ScriptModule, EnScript, Param, Sort)
`entity.md` - entity system (IEntity, events, flags, transformations, hierarchy)
`debug.md` - debugging (Print, ErrorEx, Shape, DiagMenu, DebugText)
`system.md` - system functions (FileIO, input, time, CLI)
`visual.md` - visual objects (models, bones, animations, particles)
`widgets.md` - UI widgets (Widget system)
`constants.md` - constants (Input, Colors, Materials)
`defines.md` - preprocessor (#define: build, server, platform)
`physics.md` - physics (Physics, geometries, joints, world)
