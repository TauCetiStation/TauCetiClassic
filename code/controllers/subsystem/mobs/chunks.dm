#define GRID_STEP 10
#define GRID_ELEM(value) CEIL(value / GRID_STEP)

SUBSYSTEM_DEF(chunks)
	name = "Chunks"

	flags = SS_NO_INIT | SS_NO_FIRE

	var/tick = 0
	var/list/grid = list()

/datum/controller/subsystem/chunks/fire()
	while(grid.len < world.maxz)
		add_level()

	tick += 1

	for(var/mob/living/L as anything in living_list)
		if(!QDELETED(L) && L.stat != DEAD)
			process_mob(L)

/datum/controller/subsystem/chunks/proc/add_level()
	var/x_size = GRID_ELEM(world.maxx)
	var/y_size = GRID_ELEM(world.maxy)
	var/list/z_grid[x_size][y_size]
	grid += list(z_grid)

	for(var/x in 1 to x_size)
		for(var/y in 1 to y_size)
			z_grid[x][y] = new /datum/chunk

/datum/controller/subsystem/chunks/proc/process_mob(mob/living/L)
	var/turf/T = get_turf(L)

	if(L.faction == "untouchable" || !T)
		return

	var/datum/chunk/zone = grid[T.z][GRID_ELEM(T.x)][GRID_ELEM(T.y)]

	zone.add_faction(L.faction)

/datum/controller/subsystem/chunks/proc/get_chunks_in_range(atom/A, range)
	var/turf/T = get_turf(A)

	if(!T || T.z > grid.len)
		return null

	var/z_grid = grid[T.z]
	var/x_start = GRID_ELEM(max(1, (T.x - range)))
	var/x_end = GRID_ELEM(min(world.maxx, T.x + range))
	var/y_start = GRID_ELEM(max(1, (T.y - range)))
	var/y_end = GRID_ELEM(min(world.maxx, T.y + range))

	. = list()
	for(var/x_ in x_start to x_end)
		for(var/y_ in y_start to y_end)
			var/datum/chunk/chunk = z_grid[x_][y_]
			. += chunk

/datum/controller/subsystem/chunks/proc/has_enemy_faction(atom/A, faction ,range)
	for(var/datum/chunk/chunk as anything in get_chunks_in_range(A, range))
		if(chunk.has_enemy_faction(faction))
			return TRUE

	return FALSE

/datum/controller/subsystem/chunks/proc/has_ally_faction(atom/A, faction ,range)
	for(var/datum/chunk/chunk as anything in get_chunks_in_range(A, range))
		if(chunk.has_ally_faction(faction))
			return TRUE

	return FALSE


/datum/chunk
	var/last_updated

	var/list/factions

/datum/chunk/proc/update()
	if(last_updated == SSchunks.tick)
		return

	last_updated = SSchunks.tick
	factions = null

/datum/chunk/proc/has_enemy_faction(faction)
	update()

	if(length(factions) == 1 && !LAZYACCESS(factions, faction))
		return TRUE

	return length(factions) >= 2

/datum/chunk/proc/has_ally_faction(faction)
	update()

	return LAZYACCESS(factions, faction)

/datum/chunk/proc/add_faction(faction)
	update()

	LAZYSET(factions, faction, TRUE)

#undef GRID_ELEM
#undef GRID_STEP
