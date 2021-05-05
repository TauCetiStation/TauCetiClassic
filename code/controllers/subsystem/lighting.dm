var/global/list/lighting_update_lights = list() // List of lighting sources  queued for update.
var/global/list/lighting_update_corners = list() // List of lighting corners  queued for update.
var/global/list/lighting_update_objects = list() // List of lighting objects queued for update.

SUBSYSTEM_DEF(lighting)
	name = "Lighting"

	init_order    = SS_INIT_LIGHTING
	wait          = SS_WAIT_LIGHTING
	display_order = SS_DISPLAY_LIGHTING

	flags = SS_TICKER

/datum/controller/subsystem/lighting/stat_entry()
	..("L:[global.lighting_update_lights.len]|C:[global.lighting_update_corners.len]|O:[global.lighting_update_objects.len]")

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

/datum/controller/subsystem/lighting/fire(resumed, init_tick_checks)
	MC_SPLIT_TICK_INIT(3)
	if(!init_tick_checks)
		MC_SPLIT_TICK

	while (global.lighting_update_lights.len)
		var/datum/light_source/L = global.lighting_update_lights[global.lighting_update_lights.len]
		global.lighting_update_lights.len--

		L.update_corners()

		L.needs_update = LIGHTING_NO_UPDATE

		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break


	if(!init_tick_checks)
		MC_SPLIT_TICK

	var/i = 0

	for (i in 1 to global.lighting_update_corners.len)
		var/datum/lighting_corner/C = global.lighting_update_corners[i]

		C.update_objects()
		C.needs_update = FALSE
		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if (i)
		global.lighting_update_corners.Cut(1, i+1)
		i = 0


	if(!init_tick_checks)
		MC_SPLIT_TICK

	for (i in 1 to global.lighting_update_objects.len)
		var/atom/movable/lighting_object/O = global.lighting_update_objects[i]

		if (QDELETED(O))
			continue

		O.update()
		O.needs_update = FALSE
		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if (i)
		global.lighting_update_objects.Cut(1, i+1)

/datum/controller/subsystem/lighting/Recover()
	initialized = SSlighting.initialized
	..()
