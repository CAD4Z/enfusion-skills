Визуальные объекты: модели, кости, анимации, партиклы. Источник: `proto/envisual.c`

### vobject — визуальный объект

| Функция | Описание |
|---------|----------|
| `GetObject(name)` | Загрузить/получить из кеша |
| `ReleaseObject(object, flag)` | Освободить. `RF_RELEASE` = немедленное удаление |
| `GetNumAnimFrames(anim)` | Кол-во кадров анимации |
| `vtoa(vobj)` | Имя объекта в строку |
| `GetObjectMaterials(object, out materials[])` | Список материалов |

### Кости (Bone)

| Функция | Описание |
|---------|----------|
| `SetBone(ent, bone, angles, trans, scale)` | Установить трансформацию кости |
| `SetBoneMatrix(ent, bone, mat[4])` | Установить матрицу кости |
| `SetBoneGlobal(ent, bone, mat[4])` | Глобальная матрица кости |
| `GetBoneMatrix(ent, bone, out mat[4])` | Получить мировую матрицу |
| `GetBoneLocalMatrix(ent, bone, out mat[4])` | Получить локальную матрицу |

### Анимации

**AnimFlags:**

| Флаг | Описание |
|------|----------|
| `ONCE` | Однократное проигрывание, потом заморозка на последнем кадре |
| `BLENDOUT` | Автоматический blend-out после окончания |
| `USER` | Ожидает на первом кадре, управляется через `SetFrame` |
| `RESET` | Принудительный рестарт |
| `FORCEFPS` | Использовать указанный fps вместо anim.def |
| `NOANIMEND` | Не вызывать ANIMEND событие |
| `NOANIMHOOKS` | Не вызывать anim hooks |

| Функция | Описание |
|---------|----------|
| `SetAnimSlot(ent, slot, anim, blendin, blendout, mask, fps, flags)` | Установить анимацию в слот |
| `SetAnimFrame(ent, slot, frame)` | Установить кадр |
| `ChangeAnimSlotMask(ent, slot, blendin, mask)` | Сменить маску с blend'ом |
| `ChangeAnimSlotFPS(ent, slot, fps)` | Сменить framerate |
| `SetAnimMask(ent, mask)` | Маска каналов |
| `ClearAnimMask(ent, mask)` | Очистить маску |
| `IsAnimSlotPlaying(ent, mask)` | Проверка активности слотов |
| `SetMorphState(ent, morph, value)` | Морф-таргет (0..1) |

**BoneMask** — битовая маска для фильтрации костей. `NULL` = все кости. Non-managed, требует ручного `delete`.

### Партиклы

**EmitorParam enum** — параметры эмиттера:

| Параметр | Тип | Описание |
|----------|-----|----------|
| `BIRTH_RATE` / `BIRTH_RATE_RND` | float | Частота рождения |
| `LIFETIME` / `LIFETIME_RND` | float | Время жизни |
| `VELOCITY` / `VELOCITY_RND` | float | Скорость |
| `SIZE` | float | Размер |
| `STRETCH` | float | Растяжение |
| `GRAVITY_SCALE` / `GRAVITY_SCALE_RND` | float | Масштаб гравитации |
| `AIR_RESISTANCE` / `AIR_RESISTANCE_RND` | float | Сопротивление воздуха |
| `AVELOCITY` | float | Угловая скорость |
| `CONEANGLE` | vector | Угол конуса |
| `EMITOFFSET` | vector | Смещение эмиттера |
| `EFFECT_TIME` | float | Общее время эффекта |
| `CURRENT_TIME` | float | Текущее время |
| `ACTIVE_PARTICLES` | int | Активные частицы (только чтение) |
| `REPEAT` | bool | Повтор после окончания |
| `RANDOM_ANGLE` | bool | Случайный начальный поворот |
| `RANDOM_ROT` | bool | Случайное направление вращения |
| `WIND` | bool | Влияние ветра |
| `SORT` | bool | Сортировка |
| `SPRING` | float | Пружина |

| Функция | Описание |
|---------|----------|
| `GetParticleCount(ent)` | Кол-во активных частиц (суммирует все эмиттеры) |
| `HasActiveParticle(ent)` | Есть ли активные частицы |
| `GetParticleEmitorCount(ent)` | Кол-во эмиттеров |
| `GetParticleEmitors(ent, out names[], max)` | Имена эмиттеров |
| `SetParticleParm(ent, emitor, param, value)` | Установить параметр (-1 = все эмиттеры) |
| `GetParticleParm(ent, emitor, param, out value)` | Получить параметр |
| `GetParticleParmOriginal(ent, emitor, param, out value)` | Оригинальное значение |
| `ResetParticlePosition(ent)` | Сброс позиции (для телепортации) |
| `RestartParticle(ent)` | Полный рестарт эффекта |

### Динамические модели

| Функция | Описание |
|---------|----------|
| `CreateXOB(nsurfaces, nverts[], numindices[], materials[])` | Создать динамический меш |
| `UpdateVertsEx(ent, surf, verts[], uv[])` | Обновить вершины |
| `UpdateIndices(obj, surf, indices[])` | Обновить индексы |
