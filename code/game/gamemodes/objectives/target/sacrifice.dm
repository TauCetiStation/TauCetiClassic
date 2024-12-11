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
		target = C.sacrifice_target
		explanation_text = format_explanation()
	return TRUE

/datum/objective/target/sacrifice/select_target()
	return FALSE

/datum/objective/target/sacrifice/check_completion()
	var/datum/faction/cult/C = faction
	if(istype(C))
		if(C.sacrifice_target in C.sacrificed)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/target/fanatics_sacrifice/format_explanation()
	var/datum/faction/fanatics/F = faction
	if(istype(F) && F.sacrifice_target)
		return "Принесите в жертву [F.sacrifice_target.name], [F.sacrifice_target.assigned_role]."
	return "Свободная задача"

/datum/objective/target/fanatics_sacrifice/find_target()
	var/datum/faction/fanatics/F = faction
	if(istype(F))
		F.find_sacrifice_target()
	if(F.sacrifice_target)
		target = F.sacrifice_target
		explanation_text = format_explanation()
	return TRUE

/datum/objective/target/fanatics_sacrifice/select_target()
	return FALSE

/datum/objective/target/fanatics_sacrifice/check_completion()
	var/datum/faction/fanatics/F = faction
	if(istype(F))
		if(F.sacrifice_target in F.sacrificed)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
