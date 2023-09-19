/turf/simulated/floor/engine/attack_paw(mob/user)
	return attack_hand(user)

/turf/simulated/floor/engine/ex_act(severity)
	for(var/thing in contents)
		var/atom/movable/movable_thing = thing
		if(QDELETED(movable_thing))
			continue
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += movable_thing
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += movable_thing
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += movable_thing

	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(50))
				return
		if(EXPLODE_LIGHT)
			return

	ChangeTurf(basetype)
	qdel(src)

/turf/simulated/floor/engine/blob_act()
	if (prob(25))
		ChangeTurf(basetype)
		qdel(src)
		return
	return
