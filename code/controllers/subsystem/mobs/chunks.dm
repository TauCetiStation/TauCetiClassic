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

/datum/controller/subsystem/chunks/proc/has_enemy_faction(mob/M, range)
	var/turf/T = get_turf(M)

	if(!T || T.z > grid.len)
		return FALSE
	
	var/z_grid = grid[T.z]
	var/x_start = GRID_ELEM(max(1, (T.x - range)))
	var/x_end = GRID_ELEM(min(world.maxx, T.x + range))
	var/y_start = GRID_ELEM(max(1, (T.y - range)))
	var/y_end = GRID_ELEM(min(world.maxx, T.y + range))

	for(var/x_ in x_start to x_end)
		for(var/y_ in y_start to y_end)
			var/datum/chunk/chunk = z_grid[x_][y_]

			if(chunk.has_enemy_faction(M.faction))
				return TRUE

	return FALSE

/datum/chunk
	var/last_updated
	var/faction = null
	var/conflict = FALSE

/datum/chunk/proc/update()
	if (last_updated == SSchunks.tick)
		return

	last_updated = SSchunks.tick
	faction = null
	conflict = FALSE

/datum/chunk/proc/has_enemy_faction(faction)
	update()

	if(conflict)
		return conflict

	return src.faction && (src.faction != faction)

/datum/chunk/proc/add_faction(faction)
	update()

	if(!src.faction)
		src.faction = faction
	else if(src.faction != faction)
		conflict = TRUE

#undef GRID_ELEM
#undef GRID_STEP
