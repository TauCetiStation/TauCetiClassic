SUBSYSTEM_DEF(continuity)
	name = "Continuity"
	init_order = SS_INIT_DEFAULT
	flags = SS_NO_FIRE
	var/list/continuity_objects = list()

/datum/controller/subsystem/continuity/proc/generate_continuity_objects()
	for(var/datum/continuity_object/object_type as anything in subtypesof(/datum/continuity_object))
		if(initial(object_type.filename))
			continuity_objects += new object_type
			world.log << "creating_object: [initial(object_type.filename)]"

/datum/controller/subsystem/continuity/proc/read_files()
	generate_continuity_objects()

	for(var/datum/continuity_object/object in continuity_objects)
		var/savefile/S = new /savefile("[PERSISTENT_CACHE_FOLDER]/[object.filename].sav")
		world.log << "found_object: [object.filename]"
		object.load(S)

/datum/controller/subsystem/continuity/proc/write_files()
	for(var/datum/continuity_object/object in continuity_objects)
		var/savefile/S = new /savefile("[PERSISTENT_CACHE_FOLDER]/[object.filename].sav")
		world.log << "found_object2: [object.filename]"
		object.save(S)

// Add new subtype of this datum to include your object into continuity subsystem.
/datum/continuity_object
	var/filename = null

/datum/continuity_object/proc/load(savefile/S)
	return

/datum/continuity_object/proc/save(savefile/S)
	return
