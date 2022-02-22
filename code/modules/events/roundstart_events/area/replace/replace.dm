/datum/event/feature/area/replace
	// replace: left_type on right_type (a = b)
	var/list/replace_types
	// called before deleting replaceable item
	var/datum/callback/replace_callback
	// called after deleting replaced item for new item
	var/datum/callback/new_atom_callback
	// number of items to replace, -1 for infinity
	var/num_replaceable = -1

	// finds a random item that exists in the area by these types
	var/list/random_replaceable_types

	var/picked_type

/datum/event/feature/area/replace/setup()
	. = ..()
	if(random_replaceable_types)
		picked_type = pick(random_replaceable_types)

/datum/event/feature/area/replace/proc/get_replace_type(atom/A)
	if(replace_types)
		return get_type_in_list(A, replace_types)

	else if(picked_type)
		return picked_type

	return null

/datum/event/feature/area/replace/proc/replace(atom/A)
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

/datum/event/feature/area/replace/start()
	var/count = 0
	for(var/area/target_area in targeted_areas)
		var/list/area_atoms = shuffle(target_area.GetAreaAllContents())
		for(var/atom/A in area_atoms)
			if(replace(A))
				count++

			if(count == num_replaceable)
				return
