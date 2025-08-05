
// JEDI

/datum/faction/star_wars/jedi
	name = "Jedi Order"
	ID = F_JEDI_ORDER

	initroletype = /datum/role/star_wars/jedi_leader
	roletype = /datum/role/star_wars/jedi

	min_roles = 2
	max_roles = 2

	logo_state = "jedi_logo"

/datum/faction/star_wars/jedi/forgeObjectives()
	if(!..())
		return FALSE

	AppendObjective(/datum/objective/star_wars/convert)
	AppendObjective(/datum/objective/star_wars/jedi)
	return TRUE

// SITH

/datum/faction/star_wars/sith
	name = "Sith Order"
	ID = F_SITH_ORDER

	initroletype = /datum/role/star_wars/sith_leader
	roletype = /datum/role/star_wars/sith

	min_roles = 2
	max_roles = 2

	logo_state = "sith_logo"


/datum/faction/star_wars/sith/forgeObjectives()
	if(!..())
		return FALSE

	AppendObjective(/datum/objective/star_wars/convert)
	AppendObjective(/datum/objective/star_wars/sith)
	return TRUE
