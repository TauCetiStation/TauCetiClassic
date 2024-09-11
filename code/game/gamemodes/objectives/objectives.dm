/datum/objective
	var/datum/mind/owner = null				//Who owns the objective.
	var/datum/faction/faction = null 		//Is the objective faction-wide?

	var/explanation_text = "Free Objective"	//What that person is supposed to do.
	var/completed = OBJECTIVE_LOSS			//currently only used for custom objectives.

	var/target_amount = 0					//If they are focused on a particular number. Steal objectives have their own counter.
	var/auto_target = TRUE //Whether we pick a target automatically on PostAppend()
	var/required_equipment = null
	var/global_objective = FALSE

/datum/objective/New(text, _auto_target = TRUE)
	if(global_objective)
		global_objectives += src
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

/datum/objective/proc/give_required_equipment()
	if(isnull(required_equipment))
		return
	var/mob/living/carbon/human/H = owner.current
	var/RE = new required_equipment(H.loc)
	var/list/slots = list(
		"backpack" = SLOT_IN_BACKPACK,
		"left hand" = SLOT_L_HAND,
		"right hand" = SLOT_R_HAND,
	)
	var/where = H.equip_in_one_of_slots(RE, slots)
	H.update_icons()
	if(where)
		to_chat(H, "You have been given additional equipment for the mission.")
	else
		to_chat(H, "Unfortunately you have lost additional equipment for the mission.")
