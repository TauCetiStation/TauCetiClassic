/datum/faction/enemy_revs
	name = "Enemies of Revolution"
	ID = F_ENEMY_REVS
	logo_state = "enemy_revs-logo"
	roletype = /datum/role/enemy_rev

/datum/faction/enemy_revs/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/revolution/enemy_revs_survive)
	return TRUE

/datum/faction/enemy_revs/proc/isAnyMemberSurvived()
	for(var/datum/role/R in members)
		if(R.calculate_completion() == OBJECTIVE_WIN)
			return TRUE
