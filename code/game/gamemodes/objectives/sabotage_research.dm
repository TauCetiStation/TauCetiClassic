/datum/objective/research_sabotage
	explanation_text = "Sabotage the R&D servers and systems. Alt Click on R&D Server Controller to complete a objective."
	var/already_completed = FALSE

/datum/objective/research_sabotage/check_completion()
	..()
	if((!already_completed))
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
