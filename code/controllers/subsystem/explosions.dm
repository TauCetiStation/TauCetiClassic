/// A wrapper for [/atom/proc/ex_act] to ensure that the explosion propagation and attendant signal are always handled.
#define EX_ACT(target, args...)\
	target.ex_act(##args);

SUBSYSTEM_DEF(explosions)
	name = "Explosions"
	init_order = SS_INIT_EXPLOSIONS
	priority = SS_PRIORITY_EXPLOSIONS
	wait = SS_WAIT_EXPLOSION
	flags = SS_TICKER|SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/lowturf = list()
	var/list/medturf = list()
	var/list/highturf = list()

	var/list/low_mov_atom = list()
	var/list/med_mov_atom = list()
	var/list/high_mov_atom = list()

	var/currentpart = SSAIR_PIPENETS

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

/proc/propagate_blastwave(atom/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range)
	epicenter = get_turf(epicenter)
	if(!epicenter)
		return

	var/max_range = max(devastation_range, heavy_impact_range, light_impact_range)

	var/x0 = epicenter.x
	var/y0 = epicenter.y

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

/datum/controller/subsystem/explosions/proc/is_exploding()
	return (lowturf.len || medturf.len || highturf.len || low_mov_atom.len || med_mov_atom.len || high_mov_atom.len)

/datum/controller/subsystem/explosions/fire(resumed = 0)
	if (!is_exploding())
		return
	Master.current_ticklimit = TICK_LIMIT_RUNNING //force using the entire tick if we need it.

	if(currentpart == SSEXPLOSIONS_TURFS)
		currentpart = SSEXPLOSIONS_MOVABLES

		var/list/low_turf = lowturf
		lowturf = list()
		for(var/thing in low_turf)
			var/turf/turf_thing = thing
			EX_ACT(turf_thing, EXPLODE_LIGHT)

		var/list/med_turf = medturf
		medturf = list()
		for(var/thing in med_turf)
			var/turf/turf_thing = thing
			EX_ACT(turf_thing, EXPLODE_HEAVY)

		var/list/high_turf = highturf
		highturf = list()
		for(var/thing in high_turf)
			var/turf/turf_thing = thing
			EX_ACT(turf_thing, EXPLODE_DEVASTATE)

	if(currentpart == SSEXPLOSIONS_MOVABLES)

		var/list/local_high_mov_atom = high_mov_atom
		high_mov_atom = list()
		for(var/thing in local_high_mov_atom)
			var/atom/movable/movable_thing = thing
			if(QDELETED(movable_thing))
				continue
			EX_ACT(movable_thing, EXPLODE_DEVASTATE)

		var/list/local_med_mov_atom = med_mov_atom
		med_mov_atom = list()
		for(var/thing in local_med_mov_atom)
			var/atom/movable/movable_thing = thing
			if(QDELETED(movable_thing))
				continue
			EX_ACT(movable_thing, EXPLODE_HEAVY)

		var/list/local_low_mov_atom = low_mov_atom
		low_mov_atom = list()
		for(var/thing in local_low_mov_atom)
			var/atom/movable/movable_thing = thing
			if(QDELETED(movable_thing))
				continue
			EX_ACT(movable_thing, EXPLODE_LIGHT)

	currentpart = SSEXPLOSIONS_TURFS
