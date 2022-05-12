/datum/objective/gang/tunnel_snake
	explanation_text = "ТУННЕЛЬНЫЕ ЗМЕИ РУЛЯТ!!! Убедись, что все это знают, заставь хотя бы 25% людей на станции носить любую часть нашей униформы! ТУННЕЛЬНЫЕ ЗМЕИ РУЛЯТ!!!"

/datum/objective/gang/tunnel_snake/check_completion()
	var/people_on_station = 0
	var/people_reppin_tunnel_snakes = 0
	var/datum/faction/gang/G = faction
	if(!istype(G))
		return OBJECTIVE_LOSS
	for(var/mob/M in global.player_list)
		if(!considered_alive(M.mind))
			continue
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			people_on_station++
			for(var/clothing in H.get_all_slots())
				if(is_type_in_list(clothing, G.acceptable_clothes))
					people_reppin_tunnel_snakes++
	if(0.25 * people_on_station > people_reppin_tunnel_snakes)
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
