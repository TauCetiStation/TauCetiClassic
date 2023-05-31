/datum/objective/gang/become_captain
	explanation_text = "Привее-еет, друзья! Нам нужно расширить наше влияние, ха! Сделайте Короля Мороза капитаном этого заведения! Либо можете пригласить настоящего Капитана к нам на борт, или Хи-ха, товарищ Джек Фрост, сами займите эту должность!"

/datum/objective/gang/become_captain/check_completion()
	for(var/R in faction.members)
		var/datum/role/gangster/G = R
		if(!G.antag.current)
			continue
		var/mob/M = G.antag.current
		if(!considered_alive(M.mind))
			continue // dead people cant really do the objective lol
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.get_assignment() == "Captain")
				return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
