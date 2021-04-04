/datum/faction/strike_team
	name = "Custom Strike Team"
	ID = CUSTOMSQUAD
	logo_state = "nano-logo"

/datum/faction/strike_team/forgeObjectives(mission)
	. = ..()
	var/datum/objective/custom/c = AppendObjective(/datum/objective/custom)
	c.explanation_text = mission

//________________________________________________

/datum/faction/strike_team/ert
	name = "Emergency Response Team"
	ID = EMERSQUAD
	logo_state = "ert-logo"

	initial_role = RESPONDER
	initroletype = /datum/role/emergency_responder

//________________________________________________

/datum/faction/strike_team/deathsquad
	name = "Nanotrasen Deathsquad"
	ID = DEATHSQUAD
	logo_state = "death-logo"

	initial_role = DEATHSQUADIE
	initroletype = /datum/role/death_commando


//________________________________________________

/datum/faction/strike_team/syndiesquad
	name = "Syndicate Deep-Strike squad"
	ID = SYNDIESQUAD
	logo_state = "elite-logo"

	initial_role = SYNDIESQUADIE
	initroletype = /datum/role/syndicate_elite_commando

