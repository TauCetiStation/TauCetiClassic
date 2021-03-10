SUBSYSTEM_DEF(religion)
	name = "Religion"
	init_order = SS_INIT_DEFAULT
	flags = SS_NO_INIT

	var/list/processing = list()
	var/list/currentrun = list()

/datum/controller/subsystem/religion/stat_entry()
	..("P:[processing.len]")

/datum/controller/subsystem/religion/fire(resumed = 0)
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

/datum/controller/subsystem/religion/Recover()
	if(istype(SSreligion.processing))
		processing = SSreligion.processing
