/datum/objective/gang/exterminate_species
	conflicting_types = list(
		/datum/objective/gang/save_species,
	)

	var/evil_species
	var/good_species = list()

/datum/objective/gang/exterminate_species/PostAppend()
	if(!..())
		return FALSE
	var/list/all_races = list()
	for(var/mob/living/carbon/human/H as anything in global.human_list)
		if(H.mind)
			all_races |= H.species.name

	for(var/datum/role/R as anything in faction.members)
		var/mob/living/carbon/human/H = R.antag.current
		good_species |= H.species.name

	var/list/right_races = all_races - good_species
	if(right_races.len)
		evil_species = pick(right_races)
		explanation_text = "[evil_species] ущемляют наши права! Вы отправлены на эту станцию дабы начать борьбу с ними! Истребляйте и сжигайте их, они не должны существовать в этой вселенной."
	else
		explanation_text = ""
		for(var/race in good_species)
			explanation_text += race
		explanation_text = " - это самые крутые фенотипы на станции. Про это узнают все, если вы начнёте уничтожать всех представителей иных рас и их поклонников."

/datum/objective/gang/exterminate_species/check_completion()
	for(var/mob/living/carbon/human/H as anything in global.human_list)
		if(H.mind && considered_alive(H.mind))
			if(evil_species)
				if(H.species.name == evil_species)
					return OBJECTIVE_LOSS
			else
				if(!(H.species.name in good_species))
					return OBJECTIVE_LOSS
	return OBJECTIVE_WIN

/datum/objective/gang/save_species
	conflicting_types = list(
		/datum/objective/gang/exterminate_species,
	)

	var/good_species

/datum/objective/gang/save_species/PostAppend()
	if(!..())
		return FALSE
	var/list/all_races = list()
	for(var/mob/living/carbon/human/H as anything in global.human_list)
		if(H.mind)
			all_races[H.species.name]++

	if(all_races.len > 1)
		sortTim(all_races, /proc/cmp_numeric_dsc, associative=TRUE)
		all_races -= all_races[1]

	good_species = pick(all_races)

	explanation_text = "Наше объединение поддерживает интересы всех существ в этой вселенной. Но НТ так не думает и отправляет [good_species] выполнять всякую грязную и дешевую работу. Ваше подразделение было отправлено на эту станцию с целью набрать в наши ряды всех работников, представляющих расу [good_species]. Даже если они в итоге не выживут, это будет весомое доказательство в несостоятельности политики НТ."

/datum/objective/gang/save_species/check_completion()
	var/all_agents = 0
	var/alive_agents_in_faction = 0
	for(var/datum/role/R as anything in faction.members)
		if(!R.antag || !ishuman(R))
			continue
		var/mob/living/carbon/human/H = R.antag.current
		if(H.species.name == good_species)
			alive_agents_in_faction++

	for(var/mob/living/carbon/human/H as anything in global.human_list)
		if(H.mind && H.species.name == good_species)
			all_agents++

	if(alive_agents_in_faction == all_agents)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
