/datum/faction/enemies_of_rev
	name = "Enemies of Revolution"
	ID = F_ENEMIES_OF_REV
	logo_state = "enemy_revs-logo"
	initroletype = /datum/role/enemy_rev
	roletype = /datum/role/enemy_rev

/datum/faction/enemies_of_rev/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/revolution/enemies_of_rev_survive)
	return TRUE

/datum/faction/enemies_of_rev/proc/check_populated()
	//faction created, but not populated.
	if(!members.len)
		//Than, destroy faction and do not show it in round end
		Dismantle()
