/datum/objective/target/rp_rev/format_explanation()
	return "Захватите, завербуйте или сгоните со станции [target.current.real_name], представителя [target.assigned_role]. Ликвидация разрешена, если нет иных способов сдерживания."

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
