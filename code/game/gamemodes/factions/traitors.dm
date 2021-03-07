/datum/faction/syndicate
	name = "The Syndicate"
	ID = SYNDIOPS
	required_pref = ROLE_TRAITOR
	desc = "A coalition of companies that actively work against Nanotrasen's intentions. Seen as Freedom fighters by some, Rebels and Malcontents by others."
	logo_state = "nuke-logo"

/datum/faction/syndicate/traitor
	name = "Syndicate agents"
	ID = TRAITOR
	initial_role = TRAITOR
	late_role = TRAITOR
	desc = "Operatives of the syndicate, implanted into the crew in one way or another."
	logo_state = "synd-logo"
	roletype = /datum/role/syndicate/traitor
	initroletype = /datum/role/syndicate/traitor

	var/traitors_possible = 4 //hard limit on traitors if scaling is turned off
	var/const/traitor_scaling_coeff = 7.0 //how much does the amount of players get divided by to determine traitors

/datum/faction/syndicate/traitor/can_setup(num_players)
	. = ..()

	if(config.traitor_scaling)
		max_roles = max(1, round(num_players/traitor_scaling_coeff))
	else
		max_roles = max(1, min(num_players, traitors_possible))

	return TRUE

/datum/faction/syndicate/traitor/auto
	accept_latejoiners = TRUE

/datum/faction/syndicate/traitor/auto/can_setup(num_players)
	. = ..()
	var/max_traitors = 1
	var/traitor_prob = 0
	max_traitors = round(num_players / 10) + 1
	traitor_prob = (num_players - (max_traitors - 1) * 10) * 10

	if(config.traitor_scaling)
		max_roles = max_traitors - 1 + prob(traitor_prob)
		log_game("Number of traitors: [max_roles]")
		message_admins("Players counted: [num_players]  Number of traitors chosen: [max_roles]")
	else
		max_roles = max(1, min(num_players, traitors_possible))
	return TRUE
