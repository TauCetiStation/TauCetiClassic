/datum/faction/changeling/traitorchan
	name = TRAITORCHAN
	ID = TRAITORCHAN
	logo_state = "synd-logo"

	roletype = /datum/role/changeling/traitor
	initroletype = /datum/role/changeling/traitor

	min_roles = 1
	max_roles = 2

/datum/faction/changeling/traitorchan/can_setup(num_players)
	max_roles = max(round(num_players/30, 1), 1)
	return TRUE
