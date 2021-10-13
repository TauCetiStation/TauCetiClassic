/datum/objective/cops/help_gang
	explanation_text = "Попытайтесь привести к победе **банду**"
	var/datum/faction/gang/my_gang

/datum/objective/cops/help_gang/check_completion()
	if(my_gang.IsSuccessful())
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
