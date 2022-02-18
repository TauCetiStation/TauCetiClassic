/datum/event/roundstart/area/replace
	// replace: left_type on right_type (a = b)
	var/list/replace_types = list()
	// called before deleting replaceable item
	var/datum/callback/replace_callback
	// called after deleting replaced item for new item
	var/datum/callback/new_atom_callback
	// number of items to replace, -1 for infinity
	var/num_replaceable = -1
	// finds a random item that exists in the area by these types
	var/list/random_replaceable_types = list()

/datum/event/roundstart/area/replace/proc/find_replaceable_type()
	for(var/objects_type in random_replaceable_types)
		// Collect all atoms so that later can choose a completely random type for a future replacement
		var/list/all_atoms = list()
		for(var/area/A in targeted_areas)
			all_atoms |= A.get_all_contents_type(objects_type)
		if(!all_atoms.len)
			continue
		shuffle(all_atoms)
		var/atom/A = pick(all_atoms)
		return A.type
	return null

/datum/event/roundstart/area/replace/proc/get_replace_type(atom/A)
	for(var/type in replace_types)
		if(istype(A, type))
			return type
	return null

/datum/event/roundstart/area/replace/proc/replace(atom/A)
	var/replace_type = get_replace_type(A)
	if(!replace_type)
		return FALSE

	var/B_type = replace_types[replace_type]
	message_admins("RoundStart Event: \"[event_meta.name]\" replace [A] on [B_type ? "[B_type]" : "OTHER"] in [COORD(A)] - [ADMIN_JMP(A.loc)]")
	log_game("RoundStart Event: \"[event_meta.name]\" replace [A] on [B_type ? "[B_type]" : "OTHER"] in [COORD(A)]")
	if(replace_callback)
		replace_callback.Invoke(A)
	if(B_type)
		var/B = new B_type(A.loc)
		if(new_atom_callback)
			new_atom_callback.Invoke(B)

	if(!QDELETED(A))
		qdel(A)
	return TRUE

/datum/event/roundstart/area/replace/start()
	var/count = 0
	for(var/area/target_area in targeted_areas)
		var/list/area_atoms = shuffle(target_area.GetAreaAllContents())
		for(var/atom/A in area_atoms)
			if(replace(A))
				count++

			if(count == num_replaceable)
				return
