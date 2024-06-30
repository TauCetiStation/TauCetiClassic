/datum/objective/bloodbath
	explanation_text = "Убей их всех."

/datum/objective/reproduct/check_completion()
	var/datum/faction/f = owner.antag_roles[XENOMORPH].faction
	if(istype(f))
		if(f.check_crew() == 0)
			return OBJECTIVE_WIN
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN

/datum/objective/kill_alien
	explanation_text = "Убейте ксеноморфа."

/datum/objective/reproduct/check_completion()
	var/mob/xeno = global.alien_list[ALIEN_HUNTER][1]
	if(xeno.stat == DEAD)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
