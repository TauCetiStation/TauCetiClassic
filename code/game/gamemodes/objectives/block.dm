/datum/objective/block
	explanation_text = "Do not allow any organic lifeforms to escape on the shuttle alive."

/datum/objective/block/check_completion()
	if(!issilicon(owner.current))
		return OBJECTIVE_LOSS
	if(SSshuttle.location<2)
		return OBJECTIVE_LOSS
	if(!owner.current)
		return OBJECTIVE_LOSS
	var/area/shuttle = locate(/area/shuttle/escape/centcom)
	var/protected_mobs[] = list(/mob/living/silicon/ai, /mob/living/silicon/pai, /mob/living/silicon/robot)
	for(var/mob/living/player in player_list)
		if(player.type in protected_mobs)	continue
		if (player.mind)
			if (player.stat != DEAD)
				if (get_turf(player) in shuttle)
					return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
