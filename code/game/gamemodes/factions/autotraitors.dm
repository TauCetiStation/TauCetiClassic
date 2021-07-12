#define SPAWN_CD 15 MINUTES

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

	abandon_allowed = 1
	return TRUE

/datum/faction/traitor/auto/proc/traitorcheckloop()
	log_mode("Try add new autotraitor.")
	if(SSshuttle.departed)
		log_mode("But shuttle was departed.")
		return

	if(SSshuttle.online) //shuttle in the way, but may be revoked
		addtimer(CALLBACK(src, .proc/traitorcheckloop), SPAWN_CD)
		log_mode("But shuttle was online.")
		return

	var/list/possible_autotraitor = list()
	var/playercount = 0
	var/traitorcount = 0

	for(var/mob/living/player in living_list)
		if (player.client && player.mind && player.stat != DEAD)
			playercount++
			if(isanyantag(player))
				traitorcount++
			else if((player.client && (required_pref in player.client.prefs.be_role)) && !jobban_isbanned(player, "Syndicate") && !jobban_isbanned(player, required_pref) && !role_available_in_minutes(player, required_pref) && !player.ismindprotect())
				if(!possible_autotraitor.len || !possible_autotraitor.Find(player))
					possible_autotraitor += player

	for(var/mob/living/player in possible_autotraitor)
		if(!player.mind || !player.client)
			possible_autotraitor -= player
			continue
		for(var/job in list("Cyborg", "Security Officer", "Security Cadet", "Warden", "Velocity Officer", "Velocity Chief", "Velocity Medical Doctor"))
			if(player.mind.assigned_role == job)
				possible_autotraitor -= player

	var/max_traitors = 1
	var/traitor_prob = 0
	max_traitors = round(playercount / 10) + 1
	traitor_prob = (playercount - (max_traitors - 1) * 10) * 5
	if(traitorcount < max_traitors - 1)
		traitor_prob += 50

	if(traitorcount < max_traitors)
		if(prob(traitor_prob))
			log_mode("Making a new Traitor.")
			if(!possible_autotraitor.len)
				log_mode("No potential traitors.  Cancelling new traitor.")
				addtimer(CALLBACK(src, .proc/traitorcheckloop), SPAWN_CD)
				return

			var/mob/living/newtraitor = pick(possible_autotraitor)
			add_faction_member(src, newtraitor, TRUE, TRUE)

	addtimer(CALLBACK(src, .proc/traitorcheckloop), SPAWN_CD)

/datum/faction/traitor/auto/OnPostSetup()
	addtimer(CALLBACK(src, .proc/traitorcheckloop), SPAWN_CD)
	return ..()

#undef SPAWN_CD
