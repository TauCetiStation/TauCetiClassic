/area/station/engineering/engine/poweralert(state, source)
	if (state != poweralm)
		log_investigate("has a power alarm!",INVESTIGATE_SINGULO)
	..()
