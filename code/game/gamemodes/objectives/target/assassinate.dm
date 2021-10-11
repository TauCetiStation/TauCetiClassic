/datum/objective/target/assassinate
	conflicting_types = list(
		/datum/objective/target/protect
	)

/datum/objective/target/assassinate/format_explanation()
	return "Assassinate [target.current.real_name], the [target.assigned_role]."

/datum/objective/target/assassinate/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD || issilicon(target.current) || isbrain(target.current) || !SSmapping.has_level(target.current.z) || !target.current.ckey) //Borgs/brains/AIs count as dead for traitor objectives. --NeoFite
			return OBJECTIVE_WIN
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
