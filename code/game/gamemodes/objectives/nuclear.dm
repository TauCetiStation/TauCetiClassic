/datum/objective/nuclear
	explanation_text = "Уничтожьте станцию ядерной бомбой."

/datum/objective/nuclear/check_completion()
	if(..())
		return OBJECTIVE_WIN
	if(SSticker.explosion_in_progress || SSticker.station_was_nuked)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
