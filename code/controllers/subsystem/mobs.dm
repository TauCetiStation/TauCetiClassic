SUBSYSTEM_DEF(mobs)
	name = "Mobs"

	priority      = SS_PRIORITY_MOBS

	flags = SS_KEEP_TIMING | SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/currentrun = list()

/datum/controller/subsystem/mobs/stat_entry()
	..("P:[mob_list.len]")


/datum/controller/subsystem/mobs/fire(resumed = 0)
	var/seconds = wait * 0.1
	if (!resumed)
		src.currentrun = mob_list.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/mob/M = currentrun[currentrun.len]
		currentrun.len--
		if(QDELETED(M))
			mob_list -= M // just to be sure
		else
			M.Life(seconds)
		if (MC_TICK_CHECK)
			return
