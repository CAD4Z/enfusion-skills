Visual objects: models, bones, animations, particles. Source: `proto/envisual.c`

### vobject — visual object

| Function | Description |
|---------|----------|
| `GetObject(name)` | Load/get from cache |
| `ReleaseObject(object, flag)` | Release. `RF_RELEASE` = immediate removal |
| `GetNumAnimFrames(anim)` | Number of animation frames |
| `vtoa(vobj)` | Object name to string |
| `GetObjectMaterials(object, out materials[])` | List of materials |

### Bones

| Function | Description |
|---------|----------|
| `SetBone(ent, bone, angles, trans, scale)` | Set bone transform |
| `SetBoneMatrix(ent, bone, mat[4])` | Set bone matrix |
| `SetBoneGlobal(ent, bone, mat[4])` | Global bone matrix |
| `GetBoneMatrix(ent, bone, out mat[4])` | Get world matrix |
| `GetBoneLocalMatrix(ent, bone, out mat[4])` | Get local matrix |

### Animations

**AnimFlags:**

| Flag | Description |
|------|----------|
| `ONCE` | Single playback, then frozen on the last frame |
| `BLENDOUT` | Automatic blend-out after end |
| `USER` | Waits on the first frame, controlled via `SetFrame` |
| `RESET` | Forced restart |
| `FORCEFPS` | Use the specified fps instead of anim.def |
| `NOANIMEND` | Do not fire ANIMEND event |
| `NOANIMHOOKS` | Do not fire anim hooks |

| Function | Description |
|---------|----------|
| `SetAnimSlot(ent, slot, anim, blendin, blendout, mask, fps, flags)` | Set animation in a slot |
| `SetAnimFrame(ent, slot, frame)` | Set frame |
| `ChangeAnimSlotMask(ent, slot, blendin, mask)` | Change mask with blend |
| `ChangeAnimSlotFPS(ent, slot, fps)` | Change framerate |
| `SetAnimMask(ent, mask)` | Channel mask |
| `ClearAnimMask(ent, mask)` | Clear mask |
| `IsAnimSlotPlaying(ent, mask)` | Slot activity check |
| `SetMorphState(ent, morph, value)` | Morph target (0..1) |

**BoneMask** — bitmask for filtering bones. `NULL` = all bones. Non-managed, requires manual `delete`.

### Particles

**EmitorParam enum** — emitter parameters:

| Parameter | Type | Description |
|----------|-----|----------|
| `BIRTH_RATE` / `BIRTH_RATE_RND` | float | Birth rate |
| `LIFETIME` / `LIFETIME_RND` | float | Lifetime |
| `VELOCITY` / `VELOCITY_RND` | float | Velocity |
| `SIZE` | float | Size |
| `STRETCH` | float | Stretch |
| `GRAVITY_SCALE` / `GRAVITY_SCALE_RND` | float | Gravity scale |
| `AIR_RESISTANCE` / `AIR_RESISTANCE_RND` | float | Air resistance |
| `AVELOCITY` | float | Angular velocity |
| `CONEANGLE` | vector | Cone angle |
| `EMITOFFSET` | vector | Emitter offset |
| `EFFECT_TIME` | float | Total effect time |
| `CURRENT_TIME` | float | Current time |
| `ACTIVE_PARTICLES` | int | Active particles (read-only) |
| `REPEAT` | bool | Repeat after finishing |
| `RANDOM_ANGLE` | bool | Random initial rotation |
| `RANDOM_ROT` | bool | Random rotation direction |
| `WIND` | bool | Wind influence |
| `SORT` | bool | Sorting |
| `SPRING` | float | Spring |

| Function | Description |
|---------|----------|
| `GetParticleCount(ent)` | Number of active particles (sums all emitters) |
| `HasActiveParticle(ent)` | Whether any particles are active |
| `GetParticleEmitorCount(ent)` | Number of emitters |
| `GetParticleEmitors(ent, out names[], max)` | Emitter names |
| `SetParticleParm(ent, emitor, param, value)` | Set parameter (-1 = all emitters) |
| `GetParticleParm(ent, emitor, param, out value)` | Get parameter |
| `GetParticleParmOriginal(ent, emitor, param, out value)` | Original value |
| `ResetParticlePosition(ent)` | Reset position (for teleportation) |
| `RestartParticle(ent)` | Full restart of the effect |

### Dynamic models

| Function | Description |
|---------|----------|
| `CreateXOB(nsurfaces, nverts[], numindices[], materials[])` | Create dynamic mesh |
| `UpdateVertsEx(ent, surf, verts[], uv[])` | Update vertices |
| `UpdateIndices(obj, surf, indices[])` | Update indices |
