/datum/objective/target/syndicate_rev/format_explanation()
	//lore: Syndicate want to capture the station without ERT-DeathSquad intervention before the station will be completely filled with subjects loyal to the Syndicate
	return "Capture, convert or exile from station [target.current.real_name], the [target.assigned_role]. Don't let them escape to Central Command free. Assassinate if you have no choice."

/datum/objective/target/syndicate_rev/check_completion()
	if(target && target.current)
		if(!considered_alive(target))
			return OBJECTIVE_HALFWIN
		if(target.current:handcuffed || !ishuman(target.current) || isanyrev(target.current))
			return OBJECTIVE_WIN
		var/turf/T = get_turf(target.current)
		//escaping by shuttle is not provided
		if(T && !is_station_level(T.z) && !is_centcom_level(T.z))
			return OBJECTIVE_WIN
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
