SUBSYSTEM_DEF(parallax)
	name = "Parallax"

	wait     = SS_WAIT_PARALLAX
	priority = SS_PRIORITY_PARALLAX

	flags = SS_POST_FIRE_TIMING | SS_BACKGROUND | SS_NO_INIT
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT

	var/list/currentrun
	var/planet_x_offset = 128
	var/planet_y_offset = 128

/datum/controller/subsystem/parallax/PreInit()
	planet_y_offset = rand(100, 160)
	planet_x_offset = rand(100, 160)

/datum/controller/subsystem/parallax/fire(resumed = 0)
	if (!resumed)
		src.currentrun = clients.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(length(currentrun))
		var/client/C = currentrun[currentrun.len]
		currentrun.len--

		var/atom/movable/A = C?.eye
		if(!A)
			if (MC_TICK_CHECK)
				return
			continue

		for (A; isloc(A.loc) && !isturf(A.loc); A = A.loc);

		if(A != C.movingmob)
			if(C.movingmob != null)
				LAZYREMOVE(C.movingmob.clients_in_contents, C)
			LAZYADD(A.clients_in_contents, C)
			C.movingmob = A
		if (MC_TICK_CHECK)
			return
	currentrun = null
