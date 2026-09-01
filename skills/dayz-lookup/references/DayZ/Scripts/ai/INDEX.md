How the DayZ AI system works: navigation, sensing, behavior of creatures and the player. Not an API reference — a description of architecture and nuances.

### Navigation

`infrastructure.md` - infrastructure: navmesh, groups, AIBehaviour, noise, visibility
`entityai.md` - EntityAI: base class, lifecycle, damage, synchronization, AI targeting
`creatures.md` - DayZCreature/CreatureAI: animations, CommandHandler, InputController, events, damage
`infected.md` - infected: mind states, combat system, stun, crawl, backstab, sound state machine
`animals.md` - animals: native AI behavior, species, HitComponents, death, predators vs prey
`player.md` - player: Man→Human→DayZPlayer, commands, InputController, melee, AI interaction (target, visibility, noise)
