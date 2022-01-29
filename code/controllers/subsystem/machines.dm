SUBSYSTEM_DEF(machines)
	name = "Machines"
	msg_lobby = "Чиним машинерию..."

	init_order = SS_INIT_MACHINES

	flags = SS_KEEP_TIMING

	var/list/processing = list()
	var/list/processing_second = list()
	var/list/currentrun = list()
	var/list/powernets  = list()

/datum/controller/subsystem/machines/Initialize()
	makepowernets()
	fire()
	..()

/datum/controller/subsystem/machines/proc/makepowernets()
	for(var/datum/powernet/PN in powernets)
		qdel(PN)
	powernets.Cut()

	for(var/obj/structure/cable/PC in cable_list)
		if(!PC.powernet)
			var/datum/powernet/NewPN = new()
			NewPN.add_cable(PC)
			propagate_network(PC,PC.powernet)


/datum/controller/subsystem/machines/stat_entry()
	..("M:[processing.len]|PN:[powernets.len]")


/datum/controller/subsystem/machines/fire(resumed = 0)
	if (!resumed)
		for(var/datum/powernet/Powernet in powernets)
			Powernet.reset() //reset the power state.
		src.currentrun = processing_second + processing

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	var/seconds = wait * 0.1
	while(currentrun.len)
		var/obj/machinery/thing = currentrun[currentrun.len]
		currentrun.len--
		if (QDELETED(thing) || thing.process(seconds) == PROCESS_KILL)
			processing -= thing
			processing_second -= thing
			thing.isprocessing = FALSE
		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/machines/proc/setup_template_powernets(list/cables)
	for(var/A in cables)
		var/obj/structure/cable/PC = A
		if(!PC.powernet)
			var/datum/powernet/NewPN = new()
			NewPN.add_cable(PC)
			propagate_network(PC,PC.powernet)

/datum/controller/subsystem/machines/Recover()
	if (istype(SSmachines.processing))
		processing = SSmachines.processing
	if (istype(SSmachines.processing_second))
		processing_second = SSmachines.processing_second
	if (istype(SSmachines.powernets))
		powernets = SSmachines.powernets
