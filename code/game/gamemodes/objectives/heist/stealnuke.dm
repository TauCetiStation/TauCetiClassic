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
		if(!is_type_in_list(bomb_area, arkship_areas))
			return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
