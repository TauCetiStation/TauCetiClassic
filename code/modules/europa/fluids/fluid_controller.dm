SUBSYSTEM_DEF(fluids)
	name = "Fluids"

	init_order    = SS_INIT_FLUIDS
	priority      = SS_PRIORITY_FLUIDS
	wait          = SS_WAIT_FLUIDS
	display_order = SS_DISPLAY_FLUIDS

	flags = SS_NO_INIT | SS_BACKGROUND | SS_POST_FIRE_TIMING

	var/list/active_fluids = list()
	var/list/water_sources = list()
	var/next_water_act = 0
	var/water_act_delay = 15 // A bit longer than machines.

/datum/controller/subsystem/fluids/stat_entry()
	..("AF:[active_fluids.len]|FS:[water_sources.len]")

/datum/controller/subsystem/fluids/fire(resumed = 0)
	// Process water sources.
	for(var/thing in water_sources)
		var/turf/T = thing
		if(T)
			T.flood_neighbors()
		CHECK_TICK

 	// Process general fluid spread.
	var/list/spreading_fluids = active_fluids.Copy()
	for(var/thing in spreading_fluids)
		var/obj/effect/fluid/F = thing
		if(F)
			F.spread()
		CHECK_TICK

	// Equalize fluids.
	for(var/thing in spreading_fluids)
		if(!(thing in active_fluids))
			continue
		var/obj/effect/fluid/F = thing
		if(F)
			F.equalize()
		CHECK_TICK
	spreading_fluids.Cut()

	// Update icons and update things in water.
	for(var/thing in active_fluids)
		var/obj/effect/fluid/F = thing
		if(F)
			if(!F.loc || F.loc != F.start_loc)
				qdel(F)
			if(F.fluid_amount <= FLUID_EVAPORATION_POINT && prob(10))
				F.lose_fluid(rand(1, 3))
			if(F.fluid_amount <= FLUID_DELETING)
				qdel(F)
			else
				F.update_icon()
		CHECK_TICK

	// Sometimes, call water_act().
	if(world.time >= next_water_act)
		next_water_act = world.time + water_act_delay
		for(var/thing in active_fluids)
			for(var/other_thing in get_turf(thing))
				var/atom/A = other_thing
				if(A.simulated)
					var/obj/effect/fluid/F = thing
					A.water_act(F.fluid_amount)
		CHECK_TICK

/datum/controller/subsystem/fluids/proc/add_active_source(turf/T)
	if(istype(T) && !(T in water_sources))
		water_sources += T

/datum/controller/subsystem/fluids/proc/remove_active_source(turf/T)
	if(istype(T) && (T in water_sources))
		water_sources -= T

/datum/controller/subsystem/fluids/proc/add_active_fluid(obj/effect/fluid/F)
	if(istype(F) && !(F in active_fluids))
		active_fluids += F

/datum/controller/subsystem/fluids/proc/remove_active_fluid(obj/effect/fluid/F)
	if(istype(F) && (F in active_fluids))
		active_fluids -= F
