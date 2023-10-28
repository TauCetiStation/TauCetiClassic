/datum/objective/hijack
	explanation_text = "Hijack the emergency shuttle by escaping alone. You are free to use any means."

/datum/objective/hijack/check_completion()
	if(!owner.current || owner.current.stat != CONSCIOUS)
		return OBJECTIVE_LOSS
	if(SSshuttle.location<2)
		return OBJECTIVE_LOSS
	if(issilicon(owner.current))
		return OBJECTIVE_LOSS
	var/area/shuttle = locate(/area/shuttle/escape/centcom)
	var/list/protected_mobs = list(/mob/living/silicon/ai, /mob/living/silicon/pai)
	for(var/mob/living/player in player_list)
		if(player.type in protected_mobs)	continue
		if (player.mind && (player.mind != owner))
			if(player.stat != DEAD)			//they're not dead!
				if(get_turf(player) in shuttle)
					return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
