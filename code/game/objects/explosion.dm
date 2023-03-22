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

	propagate_blastwave(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range)
	return
