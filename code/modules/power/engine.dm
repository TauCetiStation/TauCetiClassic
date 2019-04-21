/turf/simulated/floor/engine/attack_paw(mob/user)
	return src.attack_hand(user)

/turf/simulated/floor/engine/ex_act(severity)
	switch(severity)
		if(1.0)
			ChangeTurf(basetype)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				ChangeTurf(basetype)
				qdel(src)
				return
		else
	return

/turf/simulated/floor/engine/blob_act()
	if (prob(25))
		ChangeTurf(basetype)
		qdel(src)
		return
	return
