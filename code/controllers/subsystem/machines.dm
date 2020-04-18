var/datum/subsystem/machines/SSmachine

/datum/subsystem/machines
	name = "Machines"

	init_order    = SS_INIT_MACHINES
	display_order = SS_DISPLAY_MACHINES

	flags = SS_KEEP_TIMING

	var/list/processing = list()
	var/list/currentrun = list()
	var/list/powernets  = list()


/datum/subsystem/machines/Initialize()
	makepowernets()
	fire()
	..()

/datum/subsystem/machines/proc/makepowernets()
	for(var/datum/powernet/PN in powernets)
		qdel(PN)
	powernets.Cut()

	for(var/obj/structure/cable/PC in cable_list)
		if(!PC.powernet)
			var/datum/powernet/NewPN = new()
			NewPN.add_cable(PC)
			propagate_network(PC,PC.powernet)

/datum/subsystem/machines/New()
	NEW_SS_GLOBAL(SSmachine)


/datum/subsystem/machines/stat_entry()
	..("M:[processing.len]|PN:[powernets.len]")


/datum/subsystem/machines/fire(resumed = 0)
	if (!resumed)
		for(var/datum/powernet/Powernet in powernets)
			Powernet.reset() //reset the power state.
		src.currentrun = processing.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	var/seconds = wait * 0.1
	while(currentrun.len)
		var/obj/machinery/thing = currentrun[currentrun.len]
		currentrun.len--
		if (QDELETED(thing) || thing.process(seconds) == PROCESS_KILL)
			processing -= thing
			thing.isprocessing = FALSE
		if (MC_TICK_CHECK)
			return

/datum/subsystem/machines/proc/setup_template_powernets(list/cables)
	for(var/A in cables)
		var/obj/structure/cable/PC = A
		if(!PC.powernet)
			var/datum/powernet/NewPN = new()
			NewPN.add_cable(PC)
			propagate_network(PC,PC.powernet)

/datum/subsystem/machines/Recover()
	if (istype(SSmachine.processing))
		processing = SSmachine.processing
	if (istype(SSmachine.powernets))
		powernets = SSmachine.powernets
