/datum/faction/enemy_revs
	name = "Enemies of Revolution"
	ID = F_ENEMY_REVS
	logo_state = "enemy_revs-logo"
	initroletype = /datum/role/enemy_rev
	roletype = /datum/role/enemy_rev

/datum/faction/enemy_revs/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/revolution/enemy_revs_survive)
	return TRUE

/datum/faction/enemy_revs/proc/check_populated()
	//faction created, but not populated.
	if(!members.len)
		//Than, destroy faction and do not show it in round end
		Dismantle()
