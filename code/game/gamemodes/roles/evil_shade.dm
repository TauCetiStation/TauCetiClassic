/datum/role/evil_shade
	name = EVIL_SHADE
	id = EVIL_SHADE

/datum/role/evil_shade/forgeObjectives()
	. = ..()
	if(!.)
		return
	AppendObjective(/datum/objective/revenant, FALSE)

/datum/objective/revenant
	completed = OBJECTIVE_WIN
	explanation_text = "Вы - злой дух, питающийся негативными эмоциями живых людей. Мертвые люди эмоций не испытывают, поэтому вам запрещено убивать."
