/datum/objective/borer_survive
	explanation_text = "Выжить в носителе до конца смены."

/datum/objective/borer_survive/check_completion()
	if(owner && owner.current)
		var/mob/living/simple_animal/borer/B = owner.current
		if(istype(B) && B.stat < DEAD && B.host && B.host.stat < DEAD)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/borer_reproduce
	explanation_text = "Дать хоть одно потомство."

/datum/objective/borer_reproduce/check_completion()
	if(owner && owner.current)
		var/mob/living/simple_animal/borer/B = owner.current
		if(istype(B) && B.has_reproduced)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
