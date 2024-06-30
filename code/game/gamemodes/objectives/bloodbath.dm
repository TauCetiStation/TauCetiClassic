/datum/objective/bloodbath
	explanation_text = "Убей их всех."

/datum/objective/reproduct/check_completion()
	for(var/mob/living/carbon/human/H as anything in human_list)
		var/turf/human_loc = get_turf(H)
		if(!human_loc || !is_station_level(human_loc.z))
			continue
		if(H.stat == DEAD)
			continue
		if(H.species.flags[IS_SYNTHETIC] || H.species.flags[IS_PLANT])
			continue
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN

/datum/objective/kill_alien
	explanation_text = "Ксеноморф на корабле! Убейте эту тварь как можно скорее!"

/datum/objective/kill_alien/check_completion()
	if(alien_list[ALIEN_SOLO_HUNTER].len == 0)
		return OBJECTIVE_WIN
	if(alien_list[ALIEN_SOLO_HUNTER][1].stat == DEAD)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
