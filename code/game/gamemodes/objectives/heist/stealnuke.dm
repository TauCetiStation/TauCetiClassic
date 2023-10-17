/datum/objective/heist/stealnuke
	explanation_text = "Escape with all Nuclear Fission Explosives"
	var/list/arkship_areas = list(/area/shuttle/vox/arkship, /area/shuttle/vox/arkship_hold, /area/shuttle/vox/transit)

/datum/objective/heist/stealnuke/check_completion()
	var/amount_nukes_in_world = 0
	var/amount_stealed_nukes = 0
	for(var/obj/machinery/nuclearbomb/B in poi_list)
		if(QDELETED(B))
			continue
		amount_nukes_in_world++
		var/turf/bomb_turf = get_turf(B)
		if(!is_centcom_level(bomb_turf.z))
			continue
		var/area/bomb_area = get_area(bomb_turf)
		if(!is_type_in_list(bomb_area, arkship_areas))
			continue
		amount_stealed_nukes++

	if(!amount_stealed_nukes)
		return OBJECTIVE_LOSS
	if(amount_stealed_nukes < amount_nukes_in_world)
		return OBJECTIVE_HALFWIN
	return OBJECTIVE_WIN
