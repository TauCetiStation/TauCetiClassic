var/datum/subsystem/objects/SSobj

/datum/proc/process()
	set waitfor = 0
	SSobj.processing.Remove(src)
	return 0

/datum/subsystem/objects
	name = "Objects"
	priority = 12

	var/list/processing = list()
	var/list/currentrun = list()
	var/list/burning = list()
	var/list/drying = list()

/datum/subsystem/objects/New()
	NEW_SS_GLOBAL(SSobj)

/datum/subsystem/objects/Initialize(timeofday, zlevel)
	setupGenetics()
	GenerateGasOverlays()
	//color_windows_init()
	global_announcer = new(null) //Doh...
	for(var/V in world)
		var/atom/A = V
		if (zlevel && A.z != zlevel)
			continue
		A.initialize()
		CHECK_TICK
	. = ..()


/datum/subsystem/objects/stat_entry()
	..("P:[processing.len]")


/datum/subsystem/objects/fire(resumed = 0)
	if (!resumed)
		src.currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/datum/thing = currentrun[1]
		currentrun.Cut(1, 2)
		if(thing)
			thing.process(wait)
		else
			SSobj.processing.Remove(thing)
		if (MC_TICK_CHECK)
			return

	for(var/obj/item/dryingobj in SSobj.drying)
		if(dryingobj && dryingobj.wet)
			dryingobj.dry_process()
		else
			SSobj.drying.Remove(dryingobj)

	//for(var/obj/burningobj in SSobj.burning)
	//	if(burningobj && (burningobj.burn_state == ON_FIRE))
	//		if(burningobj.burn_world_time < world.time)
	//			burningobj.burn()
	//	else
	//		SSobj.burning.Remove(burningobj)

/datum/subsystem/objects/proc/setup_template_objects(list/objects)
	for(var/A in objects)
		var/atom/B = A
		B.initialize()
