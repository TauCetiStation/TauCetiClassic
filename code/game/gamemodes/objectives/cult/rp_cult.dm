/datum/objective/target/rp_cult/format_explanation()
	return "Культ нуждается в душе последователя [target.current.real_name], [target.assigned_role]. "

// less violent rev objectives
/datum/objective/target/rp_cult/check_completion()
	if(!target || !target.current)
		return OBJECTIVE_LOSS

	if(iscultist(target.current))
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
