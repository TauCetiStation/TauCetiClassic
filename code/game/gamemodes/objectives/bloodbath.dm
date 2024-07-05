/datum/objective/bloodbath
	explanation_text = "Убейте всех людей на корабле."

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
	if(alien_list[ALIEN_LONE_HUNTER].len == 0)
		return OBJECTIVE_WIN
	if(alien_list[ALIEN_LONE_HUNTER][1].stat == DEAD)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/defend_alien
	explanation_text = "Ксеноморф должен выжить."

/datum/objective/defend_alien/check_completion()
	if(alien_list[ALIEN_LONE_HUNTER].len == 0)
		return OBJECTIVE_LOSS
	if(alien_list[ALIEN_LONE_HUNTER][1].stat == DEAD)
		return OBJECTIVE_LOSS

	var/mob/M = owner.current
	if(!owner.current || ((owner.current.stat == DEAD) && !M.fake_death) || isbrain(owner.current))
		return OBJECTIVE_HALFWIN
	return OBJECTIVE_WIN
