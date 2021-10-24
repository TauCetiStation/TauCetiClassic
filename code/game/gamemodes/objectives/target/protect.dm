/datum/objective/target/protect/format_explanation()
	return "Protect [target.current.real_name], the [target.assigned_role]."

/datum/objective/target/protect/check_completion()
	if(!target)			//If it's a free objective.
		return OBJECTIVE_WIN
	if(target.current)
		if(target.current.stat == DEAD || issilicon(target.current) || isbrain(target.current))
			return OBJECTIVE_LOSS
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

