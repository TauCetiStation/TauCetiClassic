/datum/objective/gang/destroy_gangs
	explanation_text = "Остановите действие банд на станции."

/datum/objective/gang/destroy_gangs/check_completion()
	var/list/all_gangs = find_factions_by_type(/datum/faction/gang)
	if(!all_gangs.len)
		return OBJECTIVE_LOSS
	var/list/all_gangsters = list()
	for(var/G in all_gangs)
		var/datum/faction/gang/GG = G
		all_gangsters |= GG.members

	var/alive_gangsters = 0
	var/alive_cops = 0
	for(var/M in all_gangsters)
		var/datum/role/gangster/gangbanger = M
		if(gangbanger.antag.current)
			if(!ishuman(gangbanger.antag.current))
				continue
			var/mob/living/carbon/human/H = gangbanger.antag.current
			if(H.stat != CONSCIOUS || H.handcuffed)
				continue
			alive_gangsters++

	for(var/M in faction.members)
		var/datum/role/bacon = M
		if(bacon.antag.current)
			if(!ishuman(bacon.antag.current)) // always returns false
				continue
			var/mob/living/carbon/human/H = bacon.antag.current
			if(H.stat != CONSCIOUS)
				continue
			alive_cops++

	if(alive_gangsters > alive_cops)
		return OBJECTIVE_LOSS
	if(alive_gangsters == alive_cops)
		return OBJECTIVE_HALFWIN
	return OBJECTIVE_WIN
