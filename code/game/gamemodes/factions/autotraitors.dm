/datum/faction/traitor/auto
	name = "AutoTraitors"
	var/next_try = 0

/datum/faction/traitor/auto/can_setup(num_players)
	var/max_traitors = 1
	var/traitor_prob = 0
	max_traitors = round(num_players / 10) + 1
	traitor_prob = (num_players - (max_traitors - 1) * 10) * 10

	if(config.traitor_scaling)
		max_roles = max_traitors - 1 + prob(traitor_prob)
		log_mode("Number of traitors: [max_roles]")
		message_admins("Players counted: [num_players]  Number of traitors chosen: [max_roles]")
	else
		max_roles = max(1, min(num_players, traitors_possible))

	return TRUE

/datum/faction/traitor/auto/proc/calculate_autotraitor_probability(playercount, current_traitors, max_traitors)
	var/traitor_prob = 0
	traitor_prob = (playercount - (max_traitors - 1) * 10) * 5
	if(current_traitors < max_traitors - 1)
		traitor_prob += 50
	return traitor_prob

/datum/faction/traitor/auto/proc/traitorcheckloop()
	log_mode("Try add new autotraitor.")

	if(SSshuttle.departed)
		log_mode("But shuttle was departed.")
		return
	if(SSshuttle.online) //shuttle in the way, but may be revoked
		addtimer(CALLBACK(src, PROC_REF(traitorcheckloop)), global.autotraitors_spawn_cd)
		log_mode("But shuttle was online.")
		return

	var/list/possible_autotraitor = list()
	var/playercount = 0
	var/traitorcount = 0

	for(var/mob/living/player as anything in living_list)
		if(player.client && player.mind && player.stat != DEAD && (is_station_level(player.z) || is_mining_level(player.z)))
			playercount++
			if(isanyantag(player))
				traitorcount++
			else if((player.client && (required_pref in player.client.prefs.be_role)) && !jobban_isbanned(player, "Syndicate") && !jobban_isbanned(player, required_pref) && !role_available_in_minutes(player, required_pref))
				if(!possible_autotraitor.len || !possible_autotraitor.Find(player))
					possible_autotraitor += player

	var/list/sorted_players = sort_possible_traitors(possible_autotraitor)
	log_mode("AUTOTRAITORS: [sorted_players.len] candidates picked to antag adding.")
	var/max_traitors = get_max_traitors(playercount)
	log_mode("AUTOTRAITORS: [max_traitors] calculated traitors can be total.")
	var/traitor_prob = calculate_autotraitor_probability(playercount, traitorcount, max_traitors)
	log_mode("AUTOTRAITORS: [traitor_prob]% probability to add new traitor.")

	if(traitorcount < max_traitors)
		if(prob(traitor_prob))
			log_mode("Making a new Traitor.")
			if(!sorted_players.len)
				log_mode("No potential traitors.  Cancelling new traitor.")
				addtimer(CALLBACK(src, PROC_REF(traitorcheckloop)), global.autotraitors_spawn_cd)
				return

			var/mob/living/newtraitor = pick(sorted_players)
			add_faction_member(src, newtraitor, TRUE, TRUE)
	addtimer(CALLBACK(src, PROC_REF(traitorcheckloop)), global.autotraitors_spawn_cd)

/datum/faction/traitor/auto/proc/sort_possible_traitors(list/sorting_list)
	for(var/mob/living/player in sorting_list)
		if(player.ismindprotect())
			sorting_list -= player
			continue
		if(!player.mind || !player.client)
			sorting_list -= player
			continue
		for(var/job in list("Cyborg", "Security Officer", "Security Cadet", "Warden", "Velocity Officer", "Velocity Chief", "Velocity Medical Doctor"))
			if(player.mind.assigned_role == job)
				sorting_list -= player
	return sorting_list

/datum/faction/traitor/auto/proc/get_max_traitors(playercount)
	return round(playercount / 10) + 1

/datum/faction/traitor/auto/OnPostSetup()
	addtimer(CALLBACK(src, PROC_REF(traitorcheckloop)), global.autotraitors_spawn_cd)
	return ..()
