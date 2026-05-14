How the DayZ AI system works: navigation, sensing, behavior of creatures and the player. Not an API reference — a description of architecture and nuances.

### Navigation

`@.claude/references/DayZ/Scripts/AI/infrastructure.md` - infrastructure: navmesh, groups, AIBehaviour, noise, visibility
`@.claude/references/DayZ/Scripts/AI/entityai.md` - EntityAI: base class, lifecycle, damage, synchronization, AI targeting
`@.claude/references/DayZ/Scripts/AI/creatures.md` - DayZCreature/CreatureAI: animations, CommandHandler, InputController, events, damage
`@.claude/references/DayZ/Scripts/AI/infected.md` - infected: mind states, combat system, stun, crawl, backstab, sound state machine
`@.claude/references/DayZ/Scripts/AI/animals.md` - animals: native AI behavior, species, HitComponents, death, predators vs prey
`@.claude/references/DayZ/Scripts/AI/player.md` - player: Man→Human→DayZPlayer, commands, InputController, melee, AI interaction (target, visibility, noise)
