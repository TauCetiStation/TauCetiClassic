/datum/objective/fanatics_end_ritual
	explanation_text = "Провести ритуал возвышения, возвысив одного из последователей до чемпиона. Ритуал должен быть проведён на мостике."

/datum/objective/fanatics_end_ritual/check_completion()
	if(SSticker.fanatics_end_ritual_has_completed)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
