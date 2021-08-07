SUBSYSTEM_DEF(lighting)
	name = "Lighting"

	init_order    = SS_INIT_LIGHTING
	wait          = SS_WAIT_LIGHTING
	display_order = SS_DISPLAY_LIGHTING

	flags = SS_TICKER

	var/static/list/sources_queue = list() // List of lighting sources queued for update.
	var/static/list/corners_queue = list() // List of lighting corners queued for update.
	var/static/list/objects_queue = list() // List of lighting objects queued for update.

/datum/controller/subsystem/lighting/stat_entry()
	..("L:[length(sources_queue)]|C:[length(corners_queue)]|O:[length(objects_queue)]")

/datum/controller/subsystem/lighting/Initialize(timeofday)
	if(!initialized)
		if (config.starlight)
			for(var/I in global.all_areas)
				var/area/A = I
				if (A.dynamic_lighting == DYNAMIC_LIGHTING_IFSTARLIGHT)
					A.luminosity = 0

		create_all_lighting_objects()
		initialized = TRUE

	fire(FALSE, TRUE)

	return ..()

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

/datum/controller/subsystem/lighting/fire(resumed, init_tick_checks)
	MC_SPLIT_TICK_INIT(3)
	if(!init_tick_checks)
		MC_SPLIT_TICK

	var/i = 0
	for (i in 1 to length(sources_queue))
		var/datum/light_source/L = sources_queue[i]

		L.update_corners()
		L.needs_update = LIGHTING_NO_UPDATE

		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if (i)
		sources_queue.Cut(1, i+1)
		i = 0

	if(!init_tick_checks)
		MC_SPLIT_TICK

	for (i in 1 to corners_queue.len)
		var/datum/lighting_corner/C = corners_queue[i]

		C.update_objects()
		C.needs_update = LIGHTING_NO_UPDATE
		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if (i)
		corners_queue.Cut(1, i+1)
		i = 0


	if(!init_tick_checks)
		MC_SPLIT_TICK

	for (i in 1 to objects_queue.len)
		var/atom/movable/lighting_object/O = objects_queue[i]

		if (QDELETED(O))
			continue

		O.update()
		O.needs_update = LIGHTING_NO_UPDATE
		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if (i)
		objects_queue.Cut(1, i+1)

/datum/controller/subsystem/lighting/Recover()
	initialized = SSlighting.initialized
	..()
