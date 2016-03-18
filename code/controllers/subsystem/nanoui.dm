var/datum/subsystem/nanoui/SSnano

/datum/subsystem/nanoui
	name = "NanoUI"
	wait = 10
	priority = 16
	display = 6

	can_fire = 1 // This needs to fire before round start.

	var/list/open_uis = list() // A list of open UIs, grouped by src_object and ui_key.
	var/list/processing_uis = list() // A list of processing UIs, ungrouped.

/datum/subsystem/nanoui/New()
	NEW_SS_GLOBAL(SSnano)

/datum/subsystem/nanoui/stat_entry()
	..("P:[processing_uis.len]")

/datum/subsystem/nanoui/fire()
	for(var/thing in processing_uis)
		var/datum/nanoui/ui = thing
		if(ui && ui.user && ui.src_object)
			ui.process()
			continue
		processing_uis.Remove(ui)
