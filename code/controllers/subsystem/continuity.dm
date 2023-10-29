SUBSYSTEM_DEF(continuity)
	name = "Continuity"
	init_order = SS_INIT_DEFAULT
	flags = SS_NO_FIRE

/datum/controller/subsystem/continuity/proc/read_files()
	for(var/datum/continuity_object/object in subtypesof(/datum/continuity_object))
		if(!object.filename)
			continue
		var/savefile/S = new /savefile("[PERSISTENT_CACHE_FOLDER]/[object.filename].sav")
		object.load(S)

/datum/controller/subsystem/continuity/proc/write_files()
	for(var/datum/continuity_object/object in subtypesof(/datum/continuity_object))
		if(!object.filename)
			continue
		var/savefile/S = new /savefile("[PERSISTENT_CACHE_FOLDER]/[object.filename].sav")
		object.save(S)

// Add new subtype of this datum to include your object into continuity subsystem.
/datum/continuity_object
	var/filename = null

/datum/continuity_object/proc/load(savefile/S)
	return

/datum/continuity_object/proc/save(savefile/S)
	return
