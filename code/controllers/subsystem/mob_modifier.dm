SUBSYSTEM_DEF(mob_modifier)
	name = "Mob Modifiers"
	init_order = SS_INIT_DEFAULT
	flags = SS_NO_INIT

	var/list/processing = list()
	var/list/currentrun = list()

/datum/controller/subsystem/mob_modifier/stat_entry()
	..("P:[processing.len]")

/datum/controller/subsystem/mob_modifier/fire(resumed = 0)
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

/datum/controller/subsystem/mob_modifier/Recover()
	if(istype(SSmob_modifier.processing))
		processing = SSmob_modifier.processing
