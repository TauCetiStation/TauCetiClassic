var/datum/subsystem/objects/SSobj

/datum/var/isprocessing = 0
/datum/proc/process()
	set waitfor = 0
	STOP_PROCESSING(SSobj, src)
	return 0

/datum/subsystem/objects
	name = "Objects"

	init_order = SS_INIT_OBJECT
	priority   = SS_PRIORITY_OBJECTS

	var/list/processing = list()
	var/list/currentrun = list()

/datum/subsystem/objects/New()
	NEW_SS_GLOBAL(SSobj)

/datum/subsystem/objects/Initialize(timeofday)
	setupGenetics()
	color_windows_init()
	populate_gear_list()

	global_announcer = new(null) //Doh...

	for(var/thing in world)
		var/atom/A = thing
		A.initialize()
		CHECK_TICK
	..()


/datum/subsystem/objects/stat_entry()
	..("P:[processing.len]")


/datum/subsystem/objects/fire(resumed = 0)
	if (!resumed)
		src.currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/datum/thing = currentrun[currentrun.len]
		currentrun.len--

		if(QDELETED(thing))
			processing -= thing // not really necessary, since objects remove themself when qdel() happens.
		else
			thing.process()

		if (MC_TICK_CHECK)
			return


/datum/subsystem/objects/proc/setup_template_objects(list/objects)
	for(var/A in objects)
		var/atom/B = A
		B.initialize()

/datum/subsystem/objects/Recover()
	if (istype(SSobj.processing))
		processing = SSobj.processing
