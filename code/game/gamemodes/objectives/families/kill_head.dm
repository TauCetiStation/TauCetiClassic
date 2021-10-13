/datum/objective/target/assassinate/kill_head/format_explanation()
	return "К нам поступил заказ на устранение [target.assigned_role] на этой станции. Убейте его любой ценой."

// Refind new target if no heads
/datum/objective/target/assassinate/kill_head/find_target()
	var/list/possible_targets = get_targets()
	var/list/heads = list()
	if(!possible_targets.len)
		return FALSE

	for(var/datum/mind/M in possible_targets)
		if(M.assigned_role in command_positions)
			heads += M

	if(heads.len)
		set_target(pick(heads))
	else
		set_target(pick(possible_targets))

	return TRUE
