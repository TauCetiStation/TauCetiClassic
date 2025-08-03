/datum/objective/heist/inviolate_crew
	explanation_text = "Ни один Вокс на станции не должен остаться, ни живой, ни мертвый."

/datum/objective/heist/inviolate_crew/check_completion()
	var/datum/faction/heist/H = faction
	if(istype(H) && H.is_raider_crew_safe())
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
