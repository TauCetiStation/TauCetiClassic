/datum/objective/gang/become_captain
	explanation_text = "Нам нужно расширить наше влияние. Организуйте вступление капитана в нашу семью или сами назначьте кого-то капитаном!"

/datum/objective/gang/become_captain/check_completion()
	for(var/R in faction.members)
		var/datum/role/gangster/G = R
		if(!G.antag || !G.antag.current)
			continue
		var/mob/M = G.antag.current
		if(!considered_alive(M.mind))
			continue // dead people cant really do the objective lol
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.get_assignment() == "Captain")
				return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
