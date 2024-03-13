/datum/objective/target/rp_rev/format_explanation()
	return "Capture, convert or exile from station [target.current.real_name], the [target.assigned_role]. Assassinate if you have no choice."

// less violent rev objectives
/datum/objective/target/rp_rev/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD)
			return OBJECTIVE_HALFWIN

		//assume that only carbon mobs can become rev heads for now
		if(target.current:handcuffed || !ishuman(target.current) || isanyrev(target.current))
			return OBJECTIVE_WIN

		var/turf/T = get_turf(target.current)
		if(T && !is_station_level(T.z))
			return OBJECTIVE_WIN

		return OBJECTIVE_LOSS

	return OBJECTIVE_WIN
