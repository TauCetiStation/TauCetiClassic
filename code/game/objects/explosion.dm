//A very crude linear approximatiaon of pythagoras theorem.
/proc/cheap_pythag(dx, dy)
	dx = abs(dx); dy = abs(dy);
	if(dx>=dy)	return dx + (0.5*dy)	//The longest side add half the shortest side approximates the hypotenuse
	else		return dy + (0.5*dx)

/proc/explosion(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog = 1, z_transfer = 1)
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
	if(flash_range)
		flash_range = min(flash_range, MAX_EXPLOSION_RANGE)
		for(var/mob/living/Mob_to_flash in viewers(flash_range, epicenter))
			Mob_to_flash.flash_eyes()

	custom_explosion(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range)
	return

/proc/custom_explosion(atom/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range)
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
		var/dist = CHEAP_HYPOTENUSE(our_x, our_y, x0, y0)

		var/severity = EXPLODE_NONE
		if(dist < devastation_range)
			severity = EXPLODE_DEVASTATE
		else if(dist < heavy_impact_range)
			severity = EXPLODE_HEAVY
		else if(dist < light_impact_range)
			severity = EXPLODE_LIGHT

		var/list/items = list()
		items += explode.GetAreaAllContents()
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.highturf += explode
				SSexplosions.high_mov_atom += items
			if(EXPLODE_HEAVY)
				SSexplosions.medturf += explode
				SSexplosions.med_mov_atom += items
			if(EXPLODE_LIGHT)
				SSexplosions.lowturf += explode
				SSexplosions.low_mov_atom += items

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
