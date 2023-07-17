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

/datum/faction/traitor/proc/limit_roles(num_players)
	if(config.traitor_scaling)
		max_roles = max(1, round(num_players/traitor_scaling_coeff))
	else
		max_roles = max(1, min(num_players, traitors_possible))
	return max_roles

/datum/faction/traitor/imposter
	name = "Imposters"
	roletype = /datum/role/traitor/imposter
	initroletype = /datum/role/traitor/imposter
	//latespawned human can be imposter
	accept_latejoiners = TRUE

// Station has other antags
/datum/faction/traitor/imposter/limit_roles(num_players)
	//one traitor is better than 4 in lowpop
	if(num_players > max_roles * 3)
		max_roles = 1
		log_debug("IMPOSTERS: Only 1 imposter can be added to round in roundstart")
		return max_roles
	max_roles = ..()
	max_roles /= 3
	log_debug("IMPOSTERS: [src] faction has [max_roles] limit of roundstart roles")
	return max_roles

/datum/faction/traitor/imposter/can_latespawn_mob(mob/P)
	//Not every joined human can start with traitor role
	if(prob(80))
		log_debug("IMPOSTERS: [P] latespawned without adding to [src] faction")
		return FALSE
	//calculate every time which members are succeed, stop spawn when at least 1 succeeded
	for(var/datum/role/member_role in members)
		if(member_role.IsSuccessful())
			log_debug("IMPOSTERS: [P] wanna be a member of [src], but [src] faction members have completed objectives")
			return FALSE
	//probability 20% to increase amount of imposters by ~20%
	if(members.len < (player_list.len / traitor_scaling_coeff) / 2)
		return TRUE
	log_debug("IMPOSTERS: Members ([members.len]) has enough people for current players amount ([player_list.len])")
