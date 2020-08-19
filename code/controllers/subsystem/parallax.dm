SUBSYSTEM_DEF(parallax)
	name = "Parallax"

	priority = SS_PRIORITY_PARALAX
	wait     = SS_WAIT_PARALAX

	flags = SS_POST_FIRE_TIMING | SS_FIRE_IN_LOBBY | SS_BACKGROUND | SS_NO_INIT

	var/list/currentrun
	var/planet_x_offset = 128
	var/planet_y_offset = 128

/datum/controller/subsystem/parallax/Initialize(timeofday)
	planet_y_offset = rand(100, 160)
	planet_x_offset = rand(100, 160)
	..()

/datum/controller/subsystem/parallax/fire(resumed = 0)
	if (!resumed)
		src.currentrun = clients.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(length(currentrun))
		var/client/C = currentrun[currentrun.len]
		currentrun.len--

		if (!C || !C.eye)
			if (MC_TICK_CHECK)
				return
			continue
		var/atom/movable/A = C.eye
		if(!A)
			return
		for (A; isloc(A.loc) && !isturf(A.loc); A = A.loc);

		if(A != C.movingmob)
			if(C.movingmob != null)
				C.movingmob.client_mobs_in_contents -= C.mob
				UNSETEMPTY(C.movingmob.client_mobs_in_contents)
			LAZYINITLIST(A.client_mobs_in_contents)
			A.client_mobs_in_contents += C.mob
			C.movingmob = A
		if (MC_TICK_CHECK)
			return
	currentrun = null
