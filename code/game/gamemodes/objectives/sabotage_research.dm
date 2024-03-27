/datum/objective/research_sabotage
	explanation_text = "Sabotage the R&D servers and systems. Insert the diskette you were given into the R&D Server Controller to complete the objective."
	required_equipment = /obj/item/weapon/disk/data/syndi
	global_objective = TRUE
	var/already_completed = FALSE

/datum/objective/research_sabotage/check_completion()
	if(!already_completed)
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
