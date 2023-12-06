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
