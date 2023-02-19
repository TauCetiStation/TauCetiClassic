/datum/objective/revolution/enemies_of_rev_survive
	explanation_text = "Survive at any cost."

/datum/objective/revolution/enemies_of_rev_survive/check_completion()
	for(var/datum/role/R in faction.members)
		for(var/datum/objective/survive/S in R.GetObjectives())
			if(S.calculate_completion())
				return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
