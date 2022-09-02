/datum/objective/turn_into_zombie
	explanation_text = "Превратите всех людей на станции в зомби."

/datum/objective/turn_into_zombie/check_completion()
	for(var/mob/living/carbon/human/H as anything in human_list)
		if(!H || !H.mind || !is_station_level(H.z))
			continue
		if(!isrolebytype(/datum/role/zombie, H))
			return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
