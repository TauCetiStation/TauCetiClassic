// Time for station to equip themselfs
#define FIRST_ADDITION_IMPOSTER_CD 7 MINUTES

/datum/faction/traitor
	name = "Traitors"
	ID = TRAITOR
	required_pref = ROLE_TRAITOR

	roletype = /datum/role/traitor
	initroletype = /datum/role/traitor

	min_roles = 1
	max_roles = 4

	logo_state = "synd-logo"

	var/traitors_possible = 4 //hard limit on traitors if scaling is turned off
	var/const/traitor_scaling_coeff = 7.0 //how much does the amount of players get divided by to determine traitors

/datum/faction/traitor/can_setup(num_players)
	. = ..()
	limit_roles(num_players)
	return TRUE

/datum/faction/traitor/proc/calculate_traitor_scaling(count_players)
	if(config.traitor_scaling)
		return max(1, round(count_players / traitor_scaling_coeff))
	return max(1, min(count_players, traitors_possible))

/datum/faction/traitor/proc/limit_roles(num_players)
	max_roles = calculate_traitor_scaling(num_players)
	return max_roles

/datum/faction/traitor/proc/sort_possible_traitors(list/players_list)
	for(var/mob/living/player in players_list)
		if(player.ismindprotect())
			players_list -= player
			continue
		if(!player.mind || !player.client)
			players_list -= player
			continue
		for(var/job in list("Cyborg", "Security Officer", "Security Cadet", "Warden", "Velocity Officer", "Velocity Chief", "Velocity Medical Doctor"))
			if(player.mind.assigned_role == job)
				players_list -= player
	return player_list

/datum/faction/traitor/proc/is_shuttle_staying()
	if(SSshuttle.departed)
		log_mode("But shuttle was departed.")
		return FALSE
	if(SSshuttle.online) //shuttle in the way, but may be revoked
		addtimer(CALLBACK(src, PROC_REF(traitorcheckloop)), global.autotraitors_spawn_cd)
		log_mode("But shuttle was online.")
		return FALSE
	return TRUE

/datum/faction/traitor/proc/get_max_traitors(playercount)
	return round(playercount / 10) + 1

/datum/faction/traitor/proc/traitorcheckloop()
	if(!is_shuttle_staying())
		return FALSE

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
	var/max_traitors = get_max_traitors(playercount)
	var/traitor_prob = 0
	traitor_prob = (playercount - (max_traitors - 1) * 10) * 5
	if(traitorcount < max_traitors - 1)
		traitor_prob += 50

	if(traitorcount < max_traitors)
		if(prob(traitor_prob))
			log_mode("Making a new Traitor.")
			if(!sorted_players.len)
				log_mode("No potential traitors.  Cancelling new traitor.")
				addtimer(CALLBACK(src, PROC_REF(traitorcheckloop)), global.autotraitors_spawn_cd)
				return TRUE

			var/mob/living/newtraitor = pick(sorted_players)
			add_faction_member(src, newtraitor, TRUE, TRUE)
	return TRUE

/datum/faction/traitor/imposter
	name = "Imposters"
	roletype = /datum/role/traitor/imposter
	initroletype = /datum/role/traitor/imposter
	//latespawned human can be imposter
	accept_latejoiners = TRUE
	//abstract variable which helps decide how much imposters we need
	var/antag_counting = 0

/datum/faction/traitor/imposter/OnPostSetup()
	. = ..()
	antag_counting = members.len
	addtimer(CALLBACK(src, PROC_REF(first_imposter_addition)), FIRST_ADDITION_IMPOSTER_CD)
	addtimer(CALLBACK(src, PROC_REF(try_increase_roles_count)), global.autotraitors_spawn_cd)

// Mindprotected gain imposter
/datum/faction/traitor/imposter/proc/first_imposter_addition()
	var/list/mindprotected_list = list()
	var/static/list/unusual_position_list = list("Cyborg", "Captain", "Blueshield Officer") + security_positions
	for(var/mob/living/carbon/human/player as anything in human_list)
		if(isanyantag(player))
			continue
		if(player.mind.assigned_role in unusual_position_list)
			mindprotected_list += player
	log_mode("IMPOSTERS: First addition list has [mindprotected_list.len] lenght")
	var/mob/M = pick(mindprotected_list)
	add_faction_member(src, M)
	antag_counting++

/datum/faction/traitor/imposter/get_max_traitors(playercount)
	return antag_counting

/datum/faction/traitor/imposter/traitorcheckloop()
	log_mode("IMPOSTERS: Try add new auto-imposter.")
	return ..()

/datum/faction/traitor/imposter/proc/try_increase_roles_count()
	antag_counting++
	if(antag_counting > members.len)
		traitorcheckloop()
	else
		log_mode("IMPOSTERS: Imposter count is [antag_counting], members count is [members.len]. Adding auto-imposters failed")
	addtimer(CALLBACK(src, PROC_REF(try_increase_roles_count)), global.autotraitors_spawn_cd)

// Station has other antags
/datum/faction/traitor/imposter/limit_roles(num_players)
	..()
	max_roles /= 3
	log_mode("IMPOSTERS: [src] faction has [max_roles] limit of roundstart roles")
	return max_roles

/datum/faction/traitor/imposter/can_latespawn_mob(mob/P)
	//Not every joined human can start with traitor role
	if(prob(80))
		log_mode("IMPOSTERS: [P] latespawned without adding to [src] faction")
		return FALSE
	//calculate every time which members are succeed, stop spawn when at least 1 succeeded
	for(var/datum/role/member_role in members)
		if(member_role.IsSuccessful())
			log_mode("IMPOSTERS: [P] wanna be a member of [src], but [src] faction members have completed objectives")
			return FALSE
	//probability 20% to increase amount of imposters by ~20%
	if(members.len < calculate_traitor_scaling(player_list.len))
		return TRUE
	log_mode("IMPOSTERS: Members ([members.len]) has enough people for current players amount ([player_list.len])")

/datum/faction/traitor/imposter/sort_possible_traitors(list/players_list)
	for(var/mob/living/player in players_list)
		if(!player.mind || !player.client)
			players_list -= player
			continue
		for(var/job in list("Velocity Officer", "Velocity Chief", "Velocity Medical Doctor"))
			if(player.mind.assigned_role == job)
				players_list -= player
	return player_list

#undef FIRST_ADDITION_IMPOSTER_CD
