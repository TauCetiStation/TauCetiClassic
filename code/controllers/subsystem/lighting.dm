SUBSYSTEM_DEF(lighting)
	name = "Lighting"

	init_order    = SS_INIT_LIGHTING
	wait          = SS_WAIT_LIGHTING

	flags = SS_TICKER
	msg_lobby = "Включаем свет..."

	var/static/list/sources_queue = list() // List of lighting sources queued for update.
	var/static/list/corners_queue = list() // List of lighting corners queued for update.
	var/static/list/objects_queue = list() // List of lighting objects queued for update.

/datum/controller/subsystem/lighting/stat_entry()
	..("L:[sources_queue.len]|C:[corners_queue.len]|O:[objects_queue.len]")

/datum/controller/subsystem/lighting/Initialize(timeofday)
	if(!initialized)
		if (config.starlight)
			for(var/I in global.all_areas)
				var/area/A = I
				if (A.dynamic_lighting == DYNAMIC_LIGHTING_IFSTARLIGHT)
					A.luminosity = 0

		create_all_lighting_objects()
		initialized = TRUE

	fire(init_fire = TRUE)

	..()

/datum/controller/subsystem/lighting/proc/create_all_lighting_objects()
	for(var/area/A in global.all_areas)
		if(!IS_DYNAMIC_LIGHTING(A))
			continue

		for(var/turf/T in A)

			if(!IS_DYNAMIC_LIGHTING(T))
				continue

			new/atom/movable/lighting_object(T)
			CHECK_TICK
		CHECK_TICK

/datum/controller/subsystem/lighting/fire(resumed = FALSE, init_fire = FALSE)
	MC_SPLIT_TICK_INIT(3)
	if(!init_fire)
		MC_SPLIT_TICK

	while (sources_queue.len)
		var/datum/light_source/L = sources_queue[sources_queue.len]
		sources_queue.len--

		L.update_corners()

		L.needs_update = LIGHTING_NO_UPDATE

		if(init_fire)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break


	if(!init_fire)
		MC_SPLIT_TICK

	var/i = 0

	for (i in 1 to corners_queue.len)
		var/datum/lighting_corner/C = corners_queue[i]

		C.needs_update = FALSE
		C.update_objects()
		if(init_fire)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if (i)
		corners_queue.Cut(1, i+1)
		i = 0


	if(!init_fire)
		MC_SPLIT_TICK

	for (i in 1 to objects_queue.len)
		var/atom/movable/lighting_object/O = objects_queue[i]

		if (QDELETED(O))
			continue

		O.update()
		O.needs_update = FALSE
		if(init_fire)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if (i)
		objects_queue.Cut(1, i+1)

/datum/controller/subsystem/lighting/Recover()
	initialized = SSlighting.initialized
	..()
