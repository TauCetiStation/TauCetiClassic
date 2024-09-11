/datum/faction/responders
	name = "Emergency Response Team"
	ID = F_EMERSQUAD
	logo_state = "ert-logo"

	initroletype = /datum/role/emergency_responder

	// Indicates that the first member of ERT will be the leader
	var/leader_selected = FALSE

/datum/faction/responders/nt_ert

/datum/faction/responders/deathsquad
	name = "Nanotrasen Deathsquad"
	ID = F_DEATHSQUAD
	logo_state = "death-logo"

	initroletype = /datum/role/death_commando

/datum/faction/responders/gorlex
	name = F_EMERNUKE
	ID = F_EMERNUKE
	logo_state = "nuke-logo"
	initroletype = /datum/role/syndicate_responder

/datum/faction/responders/pirates
	name = F_EMERPIRATES
	ID = F_EMERPIRATES
	logo_state = "raider-logo"
	initroletype = /datum/role/pirate
	var/booty = 0 //money stolen from station

/datum/faction/responders/soviet
	name = "USSP Recon Platoon"
	ID = "USSP Recon Platoon"
	logo_state = "soviet"
	initroletype = /datum/role/soviet

/datum/faction/responders/security
	name = "Security Team"
	ID = "Security Team"
	initroletype = /datum/role/security_responder

/datum/faction/responders/marines
	name = "Marine Squad"
	ID = "Marine Squad"
	initroletype = /datum/role/marine_responder

/datum/faction/responders/clowns
	name = "Space Circus"
	ID = "Space Circus"
	initroletype = /datum/role/emag_clown
