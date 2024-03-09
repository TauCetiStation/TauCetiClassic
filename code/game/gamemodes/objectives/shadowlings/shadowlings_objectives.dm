/datum/objective/enthrall
	explanation_text = "Возвысьтесь в свою истинную форму. Вы сможете это сделать, только если 50% экипажа будет вашими рабами."

/datum/objective/enthrall/check_completion()
	var/datum/faction/shadowlings/S = faction
	return istype(S) && S.shadowling_ascended
