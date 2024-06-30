/datum/objective/bloodbath
	explanation_text = "Убей их всех."

/datum/objective/reproduct/check_completion()
	var/datum/faction/alien/f = owner.antag_roles[SOLO_XENOMORPH].faction
	if(istype(f))
		if(f.check_crew() == 0)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/kill_alien
	explanation_text = "Убейте ксеноморфа."

/datum/objective/kill_alien/check_completion()
	if(alien_list[ALIEN_SOLO_HUNTER].len == 0)
		return OBJECTIVE_WIN
	if(alien_list[ALIEN_SOLO_HUNTER][1].stat == DEAD)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
