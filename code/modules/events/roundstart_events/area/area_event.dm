/datum/event/feature/area
	// percent of random areas if no special_area_types
	var/percent_areas = 5
	// if not specified, then random
	var/list/special_area_types
	// allows you pick a one random area from special_area_types
	var/rand_special_area = FALSE

	// refs
	var/list/area/targeted_areas = list()

/datum/event/feature/area/setup()
	..()
	SHOULD_CALL_PARENT(TRUE)
	if(special_area_types?.len)
		var/list/area_types = list()

		if(rand_special_area)
			var/type = pick(special_area_types)
			special_area_types = list(type)

		for(var/type in special_area_types)
			area_types |= typesof(type)

		for(var/area_type in area_types)
			targeted_areas += get_area_by_type(area_type)
	else
		var/all_areas_num = SSevents.allowed_areas_for_events.len
		var/number = round((all_areas_num * percent_areas) / 100)
		for(var/i in 1 to number)
			targeted_areas += SSevents.findEventArea()

	if(!targeted_areas.len)
		CRASH("No valid areas for roundstart event found.")

	var/list/names = list()
	for(var/area/A in targeted_areas)
		names += A.name

	log_game("RoundStart Event: Selected areas is [get_english_list(names)]")
