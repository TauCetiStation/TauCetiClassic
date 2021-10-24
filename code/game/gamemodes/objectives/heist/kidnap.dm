/datum/objective/target/kidnap/format_explanation()
	return "The Shoal has a need for [target.current.real_name], the [target.assigned_role]. Take them alive."

/datum/objective/target/kidnap/find_target()
	var/list/jobs = list("Roboticist" , "Medical Doctor" , "Chemist" , "Station Engineer")
	var/list/possible_targets = get_targets()
	var/list/priority_targets = list()

	for(var/datum/mind/possible_target in possible_targets)
		if(can_be_target(possible_target) && (possible_target.assigned_role in jobs))
			priority_targets += possible_target

	if(priority_targets.len > 0)
		target = pick(priority_targets)
	else if(possible_targets.len > 0)
		target = pick(possible_targets)

	if(target && target.current)
		explanation_text = format_explanation()
	return TRUE

/datum/objective/target/kidnap/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD)
			return OBJECTIVE_LOSS // They're dead. Fail.
		if(get_area(target.current) == get_area_by_type(/area/shuttle/vox/arkship))
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
