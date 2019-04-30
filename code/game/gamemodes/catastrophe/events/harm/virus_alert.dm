// probably the most simplest event, you can use this one as a template
/datum/catastrophe_event/virus_alert
	name = "Virus alert"

	one_time_event = TRUE

	weight = 100

	event_type = "harmful"
	steps = 4

/datum/catastrophe_event/virus_alert/on_step()
	switch(step)
		if(1)
			announce(CYRILLIC_EVENT_VIRUS_ALERT_1)
			infect_n_people(rand(2, 3), "lesser")
		if(2)
			announce(CYRILLIC_EVENT_VIRUS_ALERT_2)
			infect_n_people(rand(2, 5), "greater")
		if(3)
			announce(CYRILLIC_EVENT_VIRUS_ALERT_3)
			infect_n_people(1, "slowzombie")
		if(4)
			announce(CYRILLIC_EVENT_VIRUS_ALERT_4)
			infect_n_people(3, "fastzombie")

/datum/catastrophe_event/virus_alert/proc/infect_n_people(need_to_infect, infect_type)
	var/list/possible = list()

	for(var/mob/living/carbon/human/H in player_list)
		if(!H.virus2.len)
			possible += H

	while(possible.len && need_to_infect > 0)
		var/mob/living/carbon/human/H = pick(possible)
		possible -= H
		need_to_infect -= 1

		switch(infect_type)
			if("lesser")
				infect_mob_random_lesser(H)
			if("greater")
				infect_mob_random_greater(H)
			if("slowzombie")
				H.infect_zombie_virus(target_zone = null, forced = TRUE, fast = FALSE)
			if("fastzombie")
				H.infect_zombie_virus(target_zone = null, forced = TRUE, fast = TRUE)

		message_admins("[key_name_admin(H)] was infected with [infect_type] virus by the gamemode [ADMIN_JMP(H)]")