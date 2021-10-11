/datum/faction/strike_team
	name = "Custom Strike Team"
	ID = F_CUSTOMSQUAD
	logo_state = "nano-logo"

/datum/faction/strike_team/forgeObjectives(mission)
	var/datum/objective/custom/c = AppendObjective(/datum/objective/custom)
	if(c)
		c.explanation_text = mission

//________________________________________________

/datum/faction/strike_team/ert
	name = "Emergency Response Team"
	ID = F_EMERSQUAD
	logo_state = "ert-logo"

	initroletype = /datum/role/emergency_responder

//________________________________________________

/datum/faction/strike_team/deathsquad
	name = "Nanotrasen Deathsquad"
	ID = F_DEATHSQUAD
	logo_state = "death-logo"

	initroletype = /datum/role/death_commando


//________________________________________________

/datum/faction/strike_team/syndiesquad
	name = "Syndicate Deep-Strike squad"
	ID = F_SYNDIESQUAD
	logo_state = "elite-logo"

	initroletype = /datum/role/syndicate_elite_commando

