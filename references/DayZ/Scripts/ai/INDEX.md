How the DayZ AI system works: navigation, sensing, behavior of creatures and the player. Not an API reference — a description of architecture and nuances.

### Navigation

`references/DayZ/Scripts/ai/infrastructure.md` - infrastructure: navmesh, groups, AIBehaviour, noise, visibility
`references/DayZ/Scripts/ai/entityai.md` - EntityAI: base class, lifecycle, damage, synchronization, AI targeting
`references/DayZ/Scripts/ai/creatures.md` - DayZCreature/CreatureAI: animations, CommandHandler, InputController, events, damage
`references/DayZ/Scripts/ai/infected.md` - infected: mind states, combat system, stun, crawl, backstab, sound state machine
`references/DayZ/Scripts/ai/animals.md` - animals: native AI behavior, species, HitComponents, death, predators vs prey
`references/DayZ/Scripts/ai/player.md` - player: Man→Human→DayZPlayer, commands, InputController, melee, AI interaction (target, visibility, noise)
