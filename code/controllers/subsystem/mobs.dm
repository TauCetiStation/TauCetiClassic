SUBSYSTEM_DEF(mobs)
	name = "Mobs"

	priority      = SS_PRIORITY_MOBS
	display_order = SS_DISPLAY_MOBS

	flags = SS_KEEP_TIMING | SS_NO_INIT

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
		if(M)
			M.Life(seconds)
		else
			mob_list -= M
		if (MC_TICK_CHECK)
			return
