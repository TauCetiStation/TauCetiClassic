/*SUBSYSTEM_DEF(preferences)
	name = "Preferences"
	wait = SS_WAIT_EXPLOSION
	flags = SS_TICKER | SS_SHOW_IN_MC_TAB//| SS_NO_INIT 

	wait = SS_WAIT_PREFERENCES

	var/list/processing = list()

/datum/controller/subsystem/preferences/stat_entry()
	..("PTS:[processing.len]")

/datum/controller/subsystem/preferences/mark_dirty(/datum/preferences/P)

// PreShutdown & Shutdown

/datum/controller/subsystem/preferences/fire(resumed = 0)
*/
