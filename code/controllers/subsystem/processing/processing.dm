SUBSYSTEM_DEF(processing)
	name = "Processing"
	priority = SS_PRIORITY_PROCESS
	flags = SS_BACKGROUND | SS_POST_FIRE_TIMING | SS_NO_INIT | SS_SHOW_IN_MC_TAB
	wait = SS_WAIT_PROCESSING

	var/stat_tag = "P" //Used for logging
	var/list/processing = list()
	var/list/currentrun = list()

/datum/controller/subsystem/processing/stat_entry(msg)
	msg = "[stat_tag]:[length(processing)]"
	return ..()

/datum/controller/subsystem/processing/fire(resumed = FALSE)
	if (!resumed)
		currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/current_run = currentrun

	while(current_run.len)
		var/datum/thing = current_run[current_run.len]
		current_run.len--
		if(QDELETED(thing))
			processing -= thing
		else if(thing.process(wait * 0.1) == PROCESS_KILL)
			// fully stop so that a future START_PROCESSING will work
			STOP_PROCESSING(src, thing)
		if (MC_TICK_CHECK)
			return
