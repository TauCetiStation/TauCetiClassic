SUBSYSTEM_DEF(fastprocess)
	name = "Fast Process"
	priority = SS_PRIORITY_FASTPROCESS
	flags = SS_BACKGROUND | SS_POST_FIRE_TIMING | SS_NO_INIT
	wait = SS_WAIT_FASTPROCESS

	var/list/processing = list()
	var/list/currentrun = list()

/datum/controller/subsystem/fastprocess/stat_entry()
	..("FP:[processing.len]")

/datum/controller/subsystem/fastprocess/fire(resumed = 0)
	if (!resumed)
		src.currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/datum/thing = currentrun[currentrun.len]
		currentrun.len--

		if(!QDELETED(thing))
			thing.process()
		else
			SSfastprocess.processing -= thing

		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/fastprocess/Recover()
	if (istype(SSfastprocess.processing))
		processing = SSfastprocess.processing
