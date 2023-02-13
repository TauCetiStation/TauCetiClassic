/datum/objective/gang/kill_undercover_cops
	explanation_text = "НаноТрейзен намерена помешать нам, отправляя своих агентов под прикрытием. Найдите и уничтожьте их всех."

/datum/objective/gang/kill_undercover_cops/check_completion()
	var/datum/faction/cops/cops = find_faction_by_type(/datum/faction/cops)
	for(var/datum/role/cop/undercover/C in cops.members)
		if(!C.antag.current)
			continue
		if(considered_alive(C.antag))
			return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
