/datum/faction/zombie // for events
	name = F_ZOMBIES
	ID = F_ZOMBIES

	initroletype = /datum/role/zombie

	logo_state = "zombie-logo"

/datum/faction/zombie/forgeObjectives()
	. = ..()
	AppendObjective(/datum/objective/turn_into_zombie)
