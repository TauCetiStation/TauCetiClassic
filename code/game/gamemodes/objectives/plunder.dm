/datum/objective/plunder
	var/needed_amount = 100000

/datum/objective/plunder/New()
	explanation_text = "Украдите [needed_amount] кредитов!"
	..()

/datum/objective/plunder/check_completion()
	var/datum/faction/responders/pirates/P = find_faction_by_type(/datum/faction/responders/pirates)
	if(P.booty < needed_amount)
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
