/datum/objective/revolution/enemy_revs_survive
	explanation_text = "Survive at any cost."

/datum/objective/revolution/enemy_revs_survive/check_completion()
	var/datum/faction/enemy_revs/enemies = faction
	if(istype(enemies) && enemies.isAnyMemberSurvived())
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
