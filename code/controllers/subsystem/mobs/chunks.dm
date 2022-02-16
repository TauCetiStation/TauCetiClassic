#define GRID_STEP 8
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
	var/list/x_grid[GRID_ELEM(world.maxx)][GRID_ELEM(world.maxy)]
	grid += list(x_grid)

	for(var/x in 1 to x_grid.len)
		var/list/y_grid = x_grid[x]

		for(var/y in 1 to y_grid.len)
			y_grid[y] = new /datum/chunk

/datum/controller/subsystem/chunks/proc/process_mob(mob/living/L)
	var/turf/T = get_turf(L)

	if(L.faction == "untouchable" || !T)
		return

	var/datum/chunk/zone = grid[T.z][GRID_ELEM(T.x)][GRID_ELEM(T.y)]
	
	zone.add_faction(L.faction)

/datum/controller/subsystem/chunks/proc/has_enemy_faction(mob/M, range)
	var/turf/T = get_turf(M)

	if(!T || T.z > grid.len)
		return FALSE
	
	var/x_grid = grid[T.z]
	var/x_start = GRID_ELEM(max(1, (T.x - range)))
	var/x_end = GRID_ELEM(min(world.maxx, T.x + range))
	var/y_start = GRID_ELEM(max(1, (T.y - range)))
	var/y_end = GRID_ELEM(min(world.maxx, T.y + range))

	for(var/x_ in x_start to x_end)
		var/list/y_grid = x_grid[x_]

		for(var/y_ in y_start to y_end)
			var/datum/chunk/chunk = y_grid[y_]

			if(chunk.has_enemy_faction(M.faction))
				return TRUE

	return FALSE

/datum/chunk
	var/last_updated
	var/list/factions = list()

/datum/chunk/proc/update()
	if (last_updated == SSchunks.tick)
		return

	last_updated = SSchunks.tick
	factions.len = 0

/datum/chunk/proc/has_enemy_faction(faction)
	update()

	if(factions.len == 1)
		return factions[1] != faction

	return factions.len >= 2

/datum/chunk/proc/add_faction(faction)
	update()

	if(factions.len < 2)
		factions |= faction

#undef GRID_ELEM
#undef GRID_STEP
