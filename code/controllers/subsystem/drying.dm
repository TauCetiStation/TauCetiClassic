SUBSYSTEM_DEF(drying)
	name = "Drying"

	priority = SS_PRIORITY_OBJECTS // yes, objects.

	flags = SS_POST_FIRE_TIMING | SS_NO_INIT

	var/list/drying = list()
	var/list/currentrun = list()

/datum/controller/subsystem/drying/stat_entry()
	..("P:[drying.len]")

/datum/controller/subsystem/drying/fire(resumed = 0)
	if (!resumed)
		src.currentrun = drying.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/obj/item/thing = currentrun[currentrun.len]
		currentrun.len--

		if(!QDELETED(thing) && thing.wet > 0)
			thing.dry_process()
		else
			drying -= thing

		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/drying/Recover()
	if (istype(SSdrying.drying))
		drying = SSdrying.drying
