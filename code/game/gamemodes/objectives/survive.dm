/datum/objective/survive
	explanation_text = "Stay alive until the end."

/datum/objective/survive/check_completion()
	var/mob/M = owner.current
	if(!owner.current || ((owner.current.stat == DEAD) && !M.fake_death) || isbrain(owner.current))
		return OBJECTIVE_LOSS		//Brains no longer win survive objectives. --NEO
	if(issilicon(owner.current) && owner.current != owner.original)
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
