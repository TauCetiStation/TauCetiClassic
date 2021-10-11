/datum/objective/target/sacrifice/format_explanation()
	var/datum/faction/cult/C = faction
	if(istype(C) && C.sacrifice_target)
		return "Принесите в жертву [C.sacrifice_target.name], [C.sacrifice_target.assigned_role]."
	return "Свободная задача"

/datum/objective/target/sacrifice/find_target()
	var/datum/faction/cult/C = faction
	if(istype(C))
		C.find_sacrifice_target()
	if(C.sacrifice_target)
		set_target(C.sacrifice_target)
	return TRUE

/datum/objective/target/sacrifice/select_target()
	return FALSE

/datum/objective/target/sacrifice/check_completion()
	var/datum/faction/cult/C = faction
	if(istype(C))
		if(C.sacrifice_target in C.sacrificed)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
