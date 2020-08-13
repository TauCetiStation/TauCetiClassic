SUBSYSTEM_DEF(nanoui)
	name = "NanoUI"

	priority      = SS_PRIORITY_NANOUI
	wait          = SS_WAIT_NANOUI
	display_order = SS_DISPLAY_NANOUI

	flags = SS_NO_INIT | SS_FIRE_IN_LOBBY

	var/list/currentrun = list()
	var/list/open_uis   = list() // A list of open UIs, grouped by src_object and ui_key.
	var/list/processing = list() // A list of processing UIs, ungrouped.

/datum/controller/subsystem/nanoui/stat_entry()
	..("P:[processing.len]")

/datum/controller/subsystem/nanoui/fire(resumed = 0)
	if (!resumed)
		src.currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/datum/nanoui/ui = currentrun[currentrun.len]
		currentrun.len--
		if(ui && ui.user && ui.src_object)
			ui.process()
		else
			processing -= ui
		if (MC_TICK_CHECK)
			return