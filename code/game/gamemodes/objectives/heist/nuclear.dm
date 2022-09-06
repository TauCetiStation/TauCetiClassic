/datum/objective/heist/nuclear
	explanation_text = "Steal a Nuclear Fission Explosive and Authentication Disk."
	var/list/area/arkship_areas = list(/area/shuttle/vox/arkship, /area/shuttle/vox/arkship_hold)

/datum/objective/heist/nuclear/check_completion()
	if(!is_type_in_list(/obj/machinery/nuclearbomb, poi_list) || !is_type_in_list(/obj/item/weapon/disk/nuclear, poi_list))
		return OBJECTIVE_LOSS

	for(var/obj/machinery/nuclearbomb/B in poi_list)
		var/turf/T = get_turf(B)
		if(!is_centcom_level(T.z))
			return OBJECTIVE_LOSS
		var/area/A = get_area(T)
		for(var/area/vox_area in arkship_areas)
			if(!istype(A, vox_area))
				return OBJECTIVE_LOSS

	for(var/obj/item/weapon/disk/nuclear/D in poi_list)
		var/turf/T = get_turf(D)
		if(!is_centcom_level(T.z))
			return OBJECTIVE_LOSS
		var/area/A = get_area(T)
		for(var/area/vox_area in arkship_areas)
			if(!istype(A, vox_area))
				return OBJECTIVE_LOSS

	return OBJECTIVE_WIN
