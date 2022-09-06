/datum/objective/heist/nuclear
	explanation_text = "Escape with a Nuclear Fission Explosive and Authentication Disk."
	var/list/area/arkship_areas = list(/area/shuttle/vox/arkship, /area/shuttle/vox/arkship_hold)

/datum/objective/heist/nuclear/check_completion()
	var/list/point_interest = getpois(with_mobs = FALSE)
	if(!is_type_in_list(/obj/machinery/nuclearbomb, point_interest) || !is_type_in_list(/obj/item/weapon/disk/nuclear, point_interest))
		return OBJECTIVE_LOSS

	for(var/obj/machinery/nuclearbomb/B in point_interest)
		if(!B.loc)
			continue
		var/turf/T = get_turf(B)
		if(!is_centcom_level(T.z))
			return OBJECTIVE_LOSS
		var/area/A = get_area(T)
		for(var/area/vox_area in arkship_areas)
			if(!istype(A, vox_area))
				return OBJECTIVE_LOSS

	for(var/obj/item/weapon/disk/nuclear/D in point_interest)
		if(!D.loc)
			continue
		var/turf/T = get_turf(D)
		if(!is_centcom_level(T.z))
			return OBJECTIVE_LOSS
		var/area/A = get_area(T)
		for(var/area/vox_area in arkship_areas)
			if(!istype(A, vox_area))
				return OBJECTIVE_LOSS

	return OBJECTIVE_WIN
