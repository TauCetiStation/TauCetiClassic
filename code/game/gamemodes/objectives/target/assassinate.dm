/datum/objective/target/assassinate/format_explanation()
	return "Assassinate [target.current.real_name], the [target.assigned_role]."

/datum/objective/target/assassinate/check_completion()
	var/mob/M = target.current
	if(target && target.current)
		if(((target.current.stat == DEAD) && !M.fake_death) || issilicon(target.current) || isbrain(target.current) || !SSmapping.has_level(target.current.z) || !target.current.ckey) //Borgs/brains/AIs count as dead for traitor objectives. --NeoFite
			return OBJECTIVE_WIN
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN

/datum/objective/target/assassinate_heads/format_explanation()
	return "Assassinate Heads of Staff."

/datum/objective/target/assassinate_heads/check_completion()
	var/list/heads = get_living_heads()

	for(var/datum/mind/head_mind in heads)
		if(head_mind && head_mind.current)
			if(((head_mind.current.stat == DEAD) && !head_mind.current.fake_death) || issilicon(head_mind.current) || isbrain(head_mind.current) || !SSmapping.has_level(head_mind.current.z) || !head_mind.current.ckey)
				return OBJECTIVE_WIN
			return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
