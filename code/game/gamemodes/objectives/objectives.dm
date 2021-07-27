/datum/objective
	var/datum/mind/owner = null				//Who owns the objective.
	var/datum/faction/faction = null 		//Is the objective faction-wide?

	var/explanation_text = "Free Objective"	//What that person is supposed to do.
	var/completed = OBJECTIVE_LOSS			//currently only used for custom objectives.

	var/target_amount = 0					//If they are focused on a particular number. Steal objectives have their own counter.
	var/auto_target = TRUE //Whether we pick a target automatically on PostAppend()

/datum/objective/New(text, _auto_target = TRUE)
	auto_target = _auto_target
	if(text)
		explanation_text = text

/datum/objective/proc/calculate_completion()
	completed = check_completion()
	return completed

/datum/objective/proc/check_completion()
	return completed

/datum/objective/proc/completion_to_string(tags = TRUE)
	var/result = "Error"
	if(completed == OBJECTIVE_WIN)
		result = "SUCCESS"
		if(tags)
			result = "<font color='green'><b>[result]</b></font>"
	if(completed == OBJECTIVE_HALFWIN)
		result = "HALF"
		if(tags)
			result = "<font color='orange'><b>[result]</b></font>"
	if(completed == OBJECTIVE_LOSS)
		result = "FAIL"
		if(tags)
			result = "<font color='red'><b>[result]</b></font>"
	return result

/datum/objective/proc/find_target()
	return TRUE

/datum/objective/proc/extra_info()
	return

/datum/objective/proc/select_target()
	return FALSE

/datum/objective/proc/PostAppend()
	if(auto_target)
		return find_target()
	return TRUE

/datum/objective/proc/ShuttleDocked()
	return
