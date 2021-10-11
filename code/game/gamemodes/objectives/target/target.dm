var/global/list/target_objectives = list()

/datum/objective/target
	var/datum/mind/target = null		//If they are focused on a particular person.
	var/list/protected_jobs = list("Velocity Officer", "Velocity Chief", "Velocity Medical Doctor") // They can't be targets of any objective.

/datum/objective/target/New(text, _auto_target = TRUE)
	..()
	target_objectives |= src

/datum/objective/target/Destroy()
	target_objectives -= src
	return ..()

/datum/objective/target/proc/can_be_target(datum/mind/possible_target)
	if(possible_target == owner)
		return FALSE
	if(!ishuman(possible_target.current))
		return FALSE
	if(possible_target.current.stat == DEAD)
		return FALSE
	if(is_centcom_level(possible_target.current.z))
		return FALSE
	if(possible_target.assigned_role in protected_jobs)
		return FALSE
	return TRUE

/datum/objective/target/find_target()
	var/list/possible_targets = get_targets()
	if(possible_targets.len > 0)
		set_target(pick(possible_targets))
		return TRUE
	return FALSE

/datum/objective/target/proc/find_target_by_role(role, role_type=0)//Option sets either to check assigned role or special role. Default to assigned.
	for(var/datum/mind/possible_target in SSticker.minds)
		if(can_be_target(possible_target) && ((role_type ? possible_target.special_role : possible_target.assigned_role) == role) )
			set_target(possible_target)
			return TRUE
	return FALSE

/datum/objective/target/proc/get_targets()
	var/list/targets = list()
	for(var/datum/mind/possible_target in SSticker.minds)
		if(can_be_target(possible_target))
			targets += possible_target
	return targets

/datum/objective/target/find_pseudorandom_target(list/all_objectives)
	var/list/conflicting_objectives = list()
	for(var/datum/objective/target/O in all_objectives)
		if(O.type in conflicting_types)
			conflicting_objectives += O

	if(!conflicting_objectives.len)
		return FALSE

	var/datum/objective/target/enemy_objective = pick(conflicting_objectives)
	set_target(enemy_objective.target)

	return TRUE

/datum/objective/target/set_target(new_target)
	target = new_target
	explanation_text = format_explanation()

/datum/objective/target/select_target()
	var/new_target = input("Select target:", "Objective target", null) as null|anything in get_targets()
	if(!new_target)
		return FALSE
	auto_target = FALSE
	set_target(new_target)
	return TRUE

/datum/objective/target/proc/format_explanation()
	return "Somebody didn't override the format explanation text here. Objective type is [type]. Target is [target.name], have fun."

