/datum/objective/nuclear
	explanation_text = "Destroy the station with a nuclear device."

/datum/objective/nuclear/check_completion()
	if(..())
		return OBJECTIVE_WIN
	if(SSticker.explosion_in_progress || SSticker.station_was_nuked)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
