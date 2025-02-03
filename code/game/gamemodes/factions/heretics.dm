/datum/faction/heretic
	name = "Heretics"
	ID = HERETIC
	required_pref = ROLE_HERETIC

	roletype = /datum/role/heretic
	initroletype = /datum/role/heretic

	min_roles = 1
	max_roles = 4

	logo_state = "heretic-logo"

	var/heretic_possible = 4
	var/const/heretic_scaling_coeff = 7.0

/datum/faction/heretic/can_setup(num_players)
	. = ..()
	limit_roles(num_players)
	return TRUE

/datum/faction/heretic/proc/calculate_heretic_scaling(count_players)
	if(config.heretic_scaling)
		return max(1, round(count_players / heretic_scaling_coeff))
	return max(1, min(count_players, heretic_possible))

/datum/faction/heretic/proc/limit_roles(num_players)
	max_roles = calculate_heretic_scaling(num_players)
	return max_roles
