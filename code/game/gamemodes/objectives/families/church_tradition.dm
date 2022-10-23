/datum/objective/gang/church_tradition
	explanation_text = "Босс хочет, чтобы ко всем нашим уважаемым коллегам относились с должным уважением. Если друг упадет, убедись, что его похоронят в гробу. И защитите жизни всех священников, чтобы обеспечить надлежащий уход за трупами."

/datum/objective/gang/church_tradition/check_completion()
	for(var/R in faction.members)
		var/datum/role/gangster/G = R
		if(!G.antag.current)
			continue
		var/mob/M = G.antag.current
		if(considered_alive(M.mind))
			continue
		if(istype(M.loc, /obj/structure/closet/coffin))
			continue
		return OBJECTIVE_LOSS
	if(global.chaplain_religion.members.len)
		for(var/mob/M in global.chaplain_religion.members)
			if(M && !considered_alive(M.mind) && !M.suiciding)
				return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
