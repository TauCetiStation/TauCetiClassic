/datum/objective/gang/save_station
	explanation_text = "Босс в восторге от возможности покупки еще одной станции, да-да-да, он знает что вы здесь, но Маджима хотел бы, чтобы вы ТОЧНО поняли, что инфраструктура этой станции НЕ должна быть испорчена. Убедись, чтобы хотя бы 85% станции не будет разгромлено, на кону твоя задница."

/datum/objective/gang/save_station/check_completion()
	var/datum/station_state/current_state = new
	current_state.count()
	var/station_integrity = min(PERCENT(SSticker.start_state.score(current_state)), 100)
	if(station_integrity < 85)
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
