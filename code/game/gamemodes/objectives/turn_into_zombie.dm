/datum/objective/turn_into_zombie
	explanation_text = "Превратите всех людей на станции в зомби."

/datum/objective/turn_into_zombie/check_completion()
	var/total_zombie = 0
	var/total_alive = 0
	var/total_non_infected = 0
	for(var/mob/living/carbon/human/H as anything in human_list)
		if(!H || !H.mind || !is_station_level(H.z))
			continue
		if(!isrolebytype(/datum/role/zombie, H))
			//dead without zombie-virus
			if(H.stat == DEAD)
				total_non_infected++
			else
				//CONSCIOUS || UNCONSCIOUS without client => afk
				if(H.client)
					total_alive++
		else
			total_zombie++

	if(total_zombie < total_alive * 3)
		. = OBJECTIVE_LOSS
	else if(total_zombie < total_non_infected)
		/*
		preventing greenscreen if all zombies were killed
		or initially zombification was not desired by the AI in Zombie-Malf mode
		*/
		. = OBJECTIVE_HALFWIN
	else
		. = OBJECTIVE_WIN
