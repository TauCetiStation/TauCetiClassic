var/datum/controller/subsystem/objects/SSobj

/datum/var/isprocessing = 0
/datum/proc/process()
	set waitfor = FALSE
	STOP_PROCESSING(SSobj, src)
	return FALSE

/datum/controller/subsystem/objects
	name = "Objects"

	priority   = SS_PRIORITY_OBJECTS
	flags = SS_NO_INIT

	var/list/processing = list()
	var/list/currentrun = list()

/datum/controller/subsystem/objects/New()
	NEW_SS_GLOBAL(SSobj)

/datum/controller/subsystem/objects/stat_entry()
	..("P:[processing.len]")

/datum/controller/subsystem/objects/fire(resumed = 0)
	if (!resumed)
		src.currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/datum/thing = currentrun[currentrun.len]
		currentrun.len--

		if(QDELETED(thing))
			processing -= thing
		else
			thing.process()

		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/objects/Recover()
	if (istype(SSobj.processing))
		processing = SSobj.processing
