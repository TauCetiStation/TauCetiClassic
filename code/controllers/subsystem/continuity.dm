SUBSYSTEM_DEF(continuity)
	name = "Continuity"
	init_order = SS_INIT_DEFAULT
	flags = SS_NO_FIRE

	var/list/continuity_objects = list()

/datum/controller/subsystem/continuity/Initialize()
	continuity_load_things()

	return ..()

/datum/controller/subsystem/continuity/proc/add_object(object, save_path)
	LAZYADDASSOCLIST(continuity_objects, save_path, object)

/datum/controller/subsystem/continuity/proc/remove_object(object, save_path)
	LAZYREMOVEASSOC(continuity_objects, save_path, object)

/datum/controller/subsystem/continuity/proc/continuity_save_things()
	for(var/save_path in continuity_objects)
		var/list/objects_list = continuity_objects[save_path]
		var/File = file("[PERSISTENT_CACHE_FOLDER]/[save_path].json")

		var/datalist = list()

		for(var/thing in objects_list)
			if(istext(thing))
				datalist += thing
				continue

			var/datum/component/continuity_object/object = thing
			datalist += object.save()

		WRITE_FILE(File, json_encode(datalist))

/datum/controller/subsystem/continuity/proc/continuity_load_things()
	for(var/save_path in continuity_objects)
		var/list/objects_list = continuity_objects[save_path]
		var/File = file("[PERSISTENT_CACHE_FOLDER]/[save_path].json")
		var/filetext = file2text(File)
		if(!filetext)
			continue
		var/list/datalist = json_decode(filetext)
		world.log << datalist.len
		world.log << list2params(datalist)

		if(!datalist.len)
			continue

		for(var/datum/component/continuity_object/object in objects_list)
			var/objectparams = pick_n_take(datalist)
			world.log << objectparams
			object.load(objectparams)
