/datum/objective/heist/stealnuke
	explanation_text = "Escape with all Nuclear Fission Explosives and Authentication Disk."
	var/list/arkship_areas = list(/area/shuttle/vox/arkship, /area/shuttle/vox/arkship_hold)

/datum/objective/heist/stealnuke/check_completion()
	for(var/obj/machinery/nuclearbomb/B in poi_list)
		if(!B || !B.loc)
			continue
		var/turf/bomb_turf = get_turf(B)
		if(!is_centcom_level(bomb_turf.z))
			return OBJECTIVE_LOSS
		var/area/bomb_area = get_area(bomb_turf)
		for(var/vox_area in arkship_areas)
			if(!istype(bomb_area, get_area_by_type(vox_area)))
				return OBJECTIVE_LOSS

	for(var/obj/item/weapon/disk/nuclear/D in poi_list)
		if(!D || !D.loc)
			continue
		var/turf/disk_turf = get_turf(D)
		if(!is_centcom_level(disk_turf.z))
			return OBJECTIVE_LOSS
		var/area/disk_area = get_area(disk_turf)
		for(var/vox_area in arkship_areas)
			if(!istype(disk_area, get_area_by_type(vox_area)))
				return OBJECTIVE_LOSS

	return OBJECTIVE_WIN
