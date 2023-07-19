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

/datum/faction/traitor/imposter
	name = "Imposters"
	roletype = /datum/role/traitor/imposter
	initroletype = /datum/role/traitor/imposter
	//latespawned human can be imposter
	accept_latejoiners = TRUE

// Station has other antags
/datum/faction/traitor/imposter/limit_roles(num_players)
	max_roles = ..()
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
