/datum/objective/reproduct
	explanation_text = "Улей должен жить и размножаться. Ваша численность должна превосходить экипаж станции в X раз."

/datum/objective/reproduct/PostAppend()
	..()
	var/datum/faction/infestation/aliens = faction
	if(!istype(aliens))
		return FALSE
	explanation_text = "Улей должен жить и размножаться. Ваша численность должна превосходить экипаж станции в [WIN_PERCENT/100] раз."
	return TRUE

/datum/objective/reproduct/check_completion()
	var/datum/faction/infestation/aliens = faction
	if(istype(aliens))
		var/data = aliens.count_alien_percent()
		if(data[ALIEN_PERCENT] >= WIN_PERCENT)
			return OBJECTIVE_WIN
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
