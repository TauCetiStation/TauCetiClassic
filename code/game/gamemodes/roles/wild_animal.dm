/datum/role/animal
	name = ROLE_WILD_ANIMAL
	id = ROLE_WILD_ANIMAL
	hide_logo = TRUE

/datum/role/animal/forgeObjectives()
	. = ..()
	if(!.)
		return
	AppendObjective(/datum/objective/survive)
