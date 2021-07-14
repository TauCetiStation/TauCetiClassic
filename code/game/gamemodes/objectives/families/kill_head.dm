/datum/objective/target/assassinate/kill_head/format_explanation()
	return "У меня есть ОЧЕНЬ ВЕСКИЕ ОСНОВАНИЯ полагать, что [target.assigned_role] на этой станции учился со мной в одной колледже! ПРОСЛЕДИТЕ, ЧТОБЫ ОН НЕ ПОКИНУЛ ЭТУ СТАНЦИЮ ЖИВЫМ, ПРИХВОСТНИ! МОГУЩЕСТВЕННЫЙ МОНАРХ ТРЕБУЕТ ЭТОГО!!!"

/datum/objective/target/assassinate/kill_head/can_be_target(datum/mind/possible_target)
	if(!..())
		return FALSE
	if(!(possible_target.assigned_role in command_positions))
		return FALSE
	return TRUE
