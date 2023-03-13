/datum/objective/turn_into_zombie
	explanation_text = "Превратите всех людей на станции в зомби."

/datum/objective/turn_into_zombie/check_completion()
	if(!faction)
		return OBJECTIVE_LOSS
	if(!faction.members.len)
		return OBJECTIVE_LOSS
	for(var/mob/living/carbon/human/H as anything in human_list)
		if(!H || !H.mind || !is_station_level(H.z))
			continue
		if(!H.mind.GetRoleByType(faction.initroletype) || !H.mind.GetRoleByType(faction.roletype))
			return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
