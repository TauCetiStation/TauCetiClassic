/turf/simulated/floor/engine/attack_paw(mob/user)
	return attack_hand(user)

/turf/simulated/floor/engine/ex_act(severity)
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
