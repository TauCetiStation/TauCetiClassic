/datum/objective/target/debrain
	conflicting_types = list(
		/datum/objective/target/protect
	)

/datum/objective/target/debrain/format_explanation()
	return "Steal the brain of [target.current.real_name]."

/datum/objective/target/debrain/check_completion()
	if(!target)//If it's a free objective.
		return OBJECTIVE_WIN
	if( !owner.current || owner.current.stat==DEAD )//If you're otherwise dead.
		return OBJECTIVE_LOSS
	if( !target.current || !isbrain(target.current) )
		return OBJECTIVE_LOSS
	var/list/all_items = owner.current.GetAllContents()
	if(target.current in all_items)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
