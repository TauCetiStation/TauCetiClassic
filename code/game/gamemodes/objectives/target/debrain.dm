/datum/objective/target/debrain/format_explanation()
	return "Steal the brain of [target.current.real_name]."

/datum/objective/target/debrain/check_completion()
	if(!target)//If it's a free objective.
		return OBJECTIVE_WIN
	if( !owner.current || owner.current.stat==DEAD )//If you're otherwise dead.
		return OBJECTIVE_LOSS
	if( !target.current || !isbrain(target.current) )
		return OBJECTIVE_LOSS
	var/atom/A = target.current
	while(A.loc)			//check to see if the brainmob is on our person
		A = A.loc
		if(A == owner.current)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
