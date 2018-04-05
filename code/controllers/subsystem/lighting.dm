var/datum/subsystem/lighting/SSlighting

/datum/subsystem/lighting
	name = "Lighting"

	init_order    = SS_INIT_LIGHTING
	priority      = SS_PRIORITY_LIGHTING
	wait          = SS_WAIT_LIGHTING
	display_order = SS_DISPLAY_LIGHTING

	flags = SS_POST_FIRE_TIMING

	var/initialized = FALSE
	var/list/changed_lights = list()		//list of all datum/light_source that need updating
	var/changed_lights_workload = 0			//stats on the largest number of lights (max changed_lights.len)
	var/list/changed_overlays = list()		//list of all turfs which may have a different light level
	var/changed_turfs_workload = 0			//stats on the largest number of turfs changed (max changed_turfs.len)


/datum/subsystem/lighting/New()
	NEW_SS_GLOBAL(SSlighting)


/datum/subsystem/lighting/stat_entry()
	..("L:[round(changed_lights_workload,1)]|T:[round(changed_turfs_workload,1)]")

//Does not loop. Should be run prior to process() being called for the first time.
/datum/subsystem/lighting/Initialize(timeofday)
	if(!initialized)
		var/list/turfs_to_init = block(locate(1, 1, 1), locate(world.maxx, world.maxy, world.maxz))

		for(var/thing in turfs_to_init)
			var/turf/T = thing
			if(!T.dynamic_lighting)
				continue
			else
				var/area/A = T.loc
				if(!A.dynamic_lighting)
					continue
			T.init_lighting_overlays()
			T.init_lighting_corners()
			CHECK_TICK

		var/list/changed_lights = src.changed_lights
		while (changed_lights.len)
			var/datum/light_source/LS = changed_lights[changed_lights.len]
			changed_lights.len--
			if(LS.check() || LS.destroyed || LS.force_update)
				LS.remove_lum()
				if(!LS.destroyed)
					LS.apply_lum()

			else if(LS.vis_update)	// We smartly update only tiles that became (in) visible to use.
				LS.smart_vis_update()

			LS.vis_update   = FALSE
			LS.force_update = FALSE
			LS.needs_update = FALSE
			CHECK_TICK

		var/list/changed_overlays = src.changed_overlays
		while (changed_overlays.len)
			var/atom/movable/lighting_overlay/LO = changed_overlays[changed_overlays.len]
			changed_overlays.len--
			LO.update_overlay()
			LO.needs_update = FALSE
			CHECK_TICK

		initialized = TRUE

	..()

//Workhorse of lighting. It cycles through each light that needs updating. It updates their
//effects and then processes every turf in the queue, updating their lighting object's appearance
//Any light that returns 1 in check() deletes itself
//By using queues we are ensuring we don't perform more updates than are necessary
/datum/subsystem/lighting/fire(resumed = 0)
	var/list/changed_lights = src.changed_lights

	if (!resumed)
		changed_lights_workload = MC_AVERAGE(changed_lights_workload, changed_lights.len)

	while (changed_lights.len)
		var/datum/light_source/LS = changed_lights[changed_lights.len]
		changed_lights.len--

		if(LS.check() || LS.destroyed || LS.force_update)
			LS.remove_lum()
			if(!LS.destroyed)
				LS.apply_lum()

		else if(LS.vis_update)	// We smartly update only tiles that became (in) visible to use.
			LS.smart_vis_update()

		LS.vis_update   = FALSE
		LS.force_update = FALSE
		LS.needs_update = FALSE

		if (MC_TICK_CHECK)
			return

	var/list/changed_overlays = src.changed_overlays

	if (!resumed)
		changed_turfs_workload = MC_AVERAGE(changed_turfs_workload, changed_overlays.len)

	while (changed_overlays.len)
		var/atom/movable/lighting_overlay/LO = changed_overlays[changed_overlays.len]
		changed_overlays.len--
		LO.update_overlay()
		LO.needs_update = FALSE
		if (MC_TICK_CHECK)
			return

/turf/proc/init_lighting_corners()
	for(var/i = 1 to 4)
		if(corners[i]) // Already have a corner on this direction.
			continue
		corners[i] = new/datum/lighting_corner(src, LIGHTING_CORNER_DIAGONAL[i])

/turf/proc/init_lighting_overlays()
	new/atom/movable/lighting_overlay(src, TRUE)

//Used to strip valid information from an existing instance and transfer it to the replacement. i.e. when a crash occurs
//It works by using spawn(-1) to transfer the data, if there is a runtime the data does not get transfered but the loop
//does not crash
//Not sure if i done this right. ~Zve
/datum/subsystem/lighting/Recover()
	initialized = SSlighting.initialized

	if(!istype(SSlighting.changed_overlays))
		SSlighting.changed_overlays = list()
	if(!istype(SSlighting.changed_lights))
		SSlighting.changed_lights = list()

	for(var/thing in SSlighting.changed_lights)
		var/datum/light_source/LS = thing
		spawn(-1)			//so we don't crash the loop (inefficient)
			if(LS.check() || LS.destroyed || LS.force_update)
				LS.remove_lum()
				if(!LS.destroyed)
					LS.apply_lum()

			else if(LS.vis_update)	// We smartly update only tiles that became (in) visible to use.
				LS.smart_vis_update()

			LS.vis_update   = FALSE
			LS.force_update = FALSE
			LS.needs_update = FALSE

	for(var/thing in changed_overlays)
		var/atom/movable/lighting_overlay/LO = thing
		spawn(-1)
			LO.update_overlay()
			LO.needs_update = FALSE

	var/msg = "## DEBUG: [time2text(world.timeofday)] [name] subsystem restarted. Reports:\n"
	for(var/varname in SSlighting.vars)
		switch(varname)
			if("tag","bestF","type","parent_type","vars")
				continue
			else
				var/varval1 = SSlighting.vars[varname]
				var/varval2 = vars[varname]
				if(istype(varval1,/list))
					varval1 = "/list([length(varval1)])"
					varval2 = "/list([length(varval2)])"
				msg += "\t [varname] = [varval1] -> [varval2]\n"
	world.log << msg
