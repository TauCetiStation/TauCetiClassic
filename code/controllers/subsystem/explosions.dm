/// A wrapper for [/atom/proc/ex_act] to ensure that the explosion propagation and attendant signal are always handled.
#define EX_ACT(target, args...)\
	target.ex_act(##args);

SUBSYSTEM_DEF(explosions)
	name = "Explosions"
	init_order = SS_INIT_EXPLOSIONS
	priority = SS_PRIORITY_EXPLOSIONS
	wait = SS_WAIT_EXPLOSION
	flags = SS_TICKER | SS_NO_INIT | SS_SHOW_IN_MC_TAB
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/cost_lowturf = 0
	var/cost_medturf = 0
	var/cost_highturf = 0

	var/cost_low_mov_atom = 0
	var/cost_med_mov_atom = 0
	var/cost_high_mov_atom = 0

	var/list/lowturf = list()
	var/list/medturf = list()
	var/list/highturf = list()

	var/list/low_mov_atom = list()
	var/list/med_mov_atom = list()
	var/list/high_mov_atom = list()

	var/currentpart = SSAIR_PIPENETS

/datum/controller/subsystem/explosions/stat_entry(msg)
	msg += "C:{"
	msg += "LT:[round(cost_lowturf, 1)]|"
	msg += "MT:[round(cost_medturf, 1)]|"
	msg += "HT:[round(cost_highturf, 1)]|"

	msg += "LO:[round(cost_low_mov_atom, 1)]|"
	msg += "MO:[round(cost_med_mov_atom, 1)]|"
	msg += "HO:[round(cost_high_mov_atom, 1)]|"

	msg += "} "

	msg += "AMT:{"
	msg += "LT:[lowturf.len]|"
	msg += "MT:[medturf.len]|"
	msg += "HT:[highturf.len]|"

	msg += "LO:[low_mov_atom.len]|"
	msg += "MO:[med_mov_atom.len]|"
	msg += "HO:[high_mov_atom.len]|"

	msg += "} "
	return ..()

/datum/controller/subsystem/explosions/proc/is_exploding()
	return (lowturf.len || medturf.len || highturf.len || low_mov_atom.len || med_mov_atom.len || high_mov_atom.len)

/**
 * Makes a given atom explode.
 *
 * Arguments:
 * - [epicenter][/turf]: The turf that's exploding.
 * - devastation_range: The range at which the effects of the explosion are at their strongest.
 * - heavy_impact_range: The range at which the effects of the explosion are relatively severe.
 * - light_impact_range: The range at which the effects of the explosion are relatively weak.
 * - flash_range: The range at which the explosion flashes people.
 * - adminlog: Whether to log the explosion/report it to the administration.
 */
/proc/explosion(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog = 1, z_transfer = 1)
	. = SSexplosions.explode(arglist(args))

/**
 * Makes a given turf explode. Now on the explosions subsystem!
 *
 * Arguments:
 * - [epicenter][/turf]: The turf that's exploding.
 * - devastation_range: The range at which the effects of the explosion are at their strongest.
 * - heavy_impact_range: The range at which the effects of the explosion are relatively severe.
 * - light_impact_range: The range at which the effects of the explosion are relatively weak.
 * - flash_range: The range at which the explosion flashes people.
 * - adminlog: Whether to log the explosion/report it to the administration.
 */
/datum/controller/subsystem/explosions/proc/explode(turf/epicenter, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 0, flame_range = 0, flash_range = 0, adminlog = TRUE, z_transfer = TRUE)
	set waitfor = FALSE

	//DO NOT REMOVE THIS STOPLAG, IT BREAKS THINGS
	//not sleeping causes us to ex_act() the thing that triggered the explosion
	//doing that might cause it to trigger another explosion
	//this is bad
	//I would make this not ex_act the thing that triggered the explosion,
	//but everything that explodes gives us their loc or a get_turf()
	//and somethings expect us to ex_act them so they can qdel()
	stoplag(1) //tldr, let the calling proc call qdel(src) before we explode

	SSStatistics.add_explosion_stat(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range)

	if(isnull(flash_range))
		flash_range = devastation_range

	propagate_blastwave(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range)
	return

/**
 * Handles the effects of an explosion originating from a given point.
 *
 * Primarily handles popagating the balstwave of the explosion to the relevant turfs.
 * Also handles the fireball from the explosion.
 * Also handles the smoke cloud from the explosion.
 * Also handles sfx and screenshake.
 *
 * Arguments:
 * - [epicenter][/atom]: The location of the explosion rounded to the nearest turf.
 * - devastation_range: The range at which the effects of the explosion are at their strongest.
 * - heavy_impact_range: The range at which the effects of the explosion are relatively severe.
 * - light_impact_range: The range at which the effects of the explosion are relatively weak.
 * - flash_range: The range at which the explosion flashes people.
 */
/datum/controller/subsystem/explosions/proc/propagate_blastwave(atom/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range)
	epicenter = get_turf(epicenter)
	if(!epicenter)
		return

	var/max_range = max(devastation_range, heavy_impact_range, light_impact_range)

	var/x0 = epicenter.x
	var/y0 = epicenter.y

	if(flash_range)
		flash_range = min(flash_range, MAX_EXPLOSION_RANGE)
		for(var/mob/living/Mob_to_flash in viewers(flash_range, epicenter))
			Mob_to_flash.flash_eyes()

	var/list/affected_turfs = prepare_explosion_turfs(max_range, epicenter)
	//lists are guaranteed to contain at least 1 turf at this point
	//we presuppose that we'll be iterating away from the epicenter
	for(var/turf/explode as anything in affected_turfs)
		var/our_x = explode.x
		var/our_y = explode.y
		var/dist = HYPOTENUSE(our_x, our_y, x0, y0)

		var/severity = EXPLODE_NONE
		if(dist < devastation_range)
			severity = EXPLODE_DEVASTATE
		else if(dist < heavy_impact_range)
			severity = EXPLODE_HEAVY
		else if(dist < light_impact_range)
			severity = EXPLODE_LIGHT

		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.highturf += explode
				SSexplosions.high_mov_atom += explode.GetAreaAllContents()
			if(EXPLODE_HEAVY)
				SSexplosions.medturf += explode
				SSexplosions.med_mov_atom += explode.GetAreaAllContents()
			if(EXPLODE_LIGHT)
				SSexplosions.lowturf += explode
				SSexplosions.low_mov_atom += explode.GetAreaAllContents()

/// Returns a list of turfs in X range from the epicenter
/// Returns in a unique order, spiraling outwards
/// This is done to ensure our progressive cache of blast resistance is always valid
/// This is quite fast
/proc/prepare_explosion_turfs(range, turf/epicenter)
	var/list/outlist = list()
	// Add in the center
	outlist += epicenter

	var/our_x = epicenter.x
	var/our_y = epicenter.y
	var/our_z = epicenter.z

	var/max_x = world.maxx
	var/max_y = world.maxy
	for(var/i in 1 to range)
		var/lowest_x = our_x - i
		var/lowest_y = our_y - i
		var/highest_x = our_x + i
		var/highest_y = our_y + i
		// top left to one before top right
		if(highest_y <= max_y)
			outlist += block(
				locate(max(lowest_x, 1), highest_y, our_z),
				locate(min(highest_x - 1, max_x), highest_y, our_z))
		// top right to one before bottom right
		if(highest_x <= max_x)
			outlist += block(
				locate(highest_x, min(highest_y, max_y), our_z),
				locate(highest_x, max(lowest_y + 1, 1), our_z))
		// bottom right to one before bottom left
		if(lowest_y >= 1)
			outlist += block(
				locate(min(highest_x, max_x), lowest_y, our_z),
				locate(max(lowest_x + 1, 1), lowest_y, our_z))
		// bottom left to one before top left
		if(lowest_x >= 1)
			outlist += block(
				locate(lowest_x, max(lowest_y, 1), our_z),
				locate(lowest_x, min(highest_y - 1, max_y), our_z))

	return outlist

/datum/controller/subsystem/explosions/fire(resumed = 0)
	if(!is_exploding())
		return
	var/timer
	Master.current_ticklimit = TICK_LIMIT_RUNNING //force using the entire tick if we need it.

	if(currentpart == SSEXPLOSIONS_TURFS)
		currentpart = SSEXPLOSIONS_MOVABLES

		timer = TICK_USAGE_REAL
		var/list/low_turf = lowturf
		lowturf = list()
		for(var/turf/turf_thing as anything in low_turf)
			EX_ACT(turf_thing, EXPLODE_LIGHT)
		cost_lowturf = MC_AVERAGE(cost_lowturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/med_turf = medturf
		medturf = list()
		for(var/turf/turf_thing as anything in med_turf)
			EX_ACT(turf_thing, EXPLODE_HEAVY)
		cost_medturf = MC_AVERAGE(cost_medturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/high_turf = highturf
		highturf = list()
		for(var/turf/turf_thing as anything in high_turf)
			EX_ACT(turf_thing, EXPLODE_DEVASTATE)
		cost_highturf = MC_AVERAGE(cost_highturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

	if(currentpart == SSEXPLOSIONS_MOVABLES)

		timer = TICK_USAGE_REAL
		var/list/local_high_mov_atom = high_mov_atom
		high_mov_atom = list()
		for(var/atom/movable/movable_thing as anything in local_high_mov_atom)
			if(QDELETED(movable_thing))
				continue
			EX_ACT(movable_thing, EXPLODE_DEVASTATE)
		cost_high_mov_atom = MC_AVERAGE(cost_high_mov_atom, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/local_med_mov_atom = med_mov_atom
		med_mov_atom = list()
		for(var/atom/movable/movable_thing as anything in local_med_mov_atom)
			if(QDELETED(movable_thing))
				continue
			EX_ACT(movable_thing, EXPLODE_HEAVY)
		cost_med_mov_atom = MC_AVERAGE(cost_med_mov_atom, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/local_low_mov_atom = low_mov_atom
		low_mov_atom = list()
		for(var/atom/movable/movable_thing as anything in local_low_mov_atom)
			if(QDELETED(movable_thing))
				continue
			EX_ACT(movable_thing, EXPLODE_LIGHT)
		cost_low_mov_atom = MC_AVERAGE(cost_low_mov_atom, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
	
	currentpart = SSEXPLOSIONS_TURFS
