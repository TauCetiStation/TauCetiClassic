/datum/objective/target/assassinate/format_explanation()
	return "Assassinate [target.current.real_name], the [target.assigned_role]."

/datum/objective/target/assassinate/check_completion()
	var/mob/M = target.current
	if(target && target.current)
		if(((target.current.stat == DEAD) && !M.fake_death) || issilicon(target.current) || isbrain(target.current) || !SSmapping.has_level(target.current.z) || !target.current.ckey) //Borgs/brains/AIs count as dead for traitor objectives. --NeoFite
			return OBJECTIVE_WIN
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN

/datum/objective/target/assassinate/religious
	var/datum/religion/religion = null

/datum/objective/target/assassinate/religious/New(_religion)
	. = ..()
	religion = _religion

/datum/objective/target/assassinate/religious/get_targets()
	var/list/targets = list()
	for(var/datum/mind/possible_target in SSticker.minds)
		if(!religion.can_convert(possible_target.current))
			targets += possible_target
	log_debug("IMPOSTERS: Heretic objective has [targets.len] possible targets")
	return targets
