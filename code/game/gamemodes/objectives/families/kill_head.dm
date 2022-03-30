/datum/objective/target/assassinate/kill_head/format_explanation()
	return "У меня есть ОЧЕНЬ ВЕСКИЕ ОСНОВАНИЯ полагать, что [target.assigned_role] на этой станции учился со мной в одном колледже! ПРОСЛЕДИТЕ, ЧТОБЫ ОН НЕ ПОКИНУЛ ЭТУ СТАНЦИЮ ЖИВЫМ, ПРИХВОСТНИ! МОГУЩЕСТВЕННЫЙ МОНАРХ ТРЕБУЕТ ЭТОГО!!!"

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
		target = pick(heads)
	else
		target = pick(possible_targets)

	if(target && target.current)
		explanation_text = format_explanation()
	return TRUE
