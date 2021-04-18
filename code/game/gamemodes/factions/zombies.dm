/datum/faction/zombie // for events
	name = ZOMBIES
	ID = ZOMBIES

	initroletype = /datum/role/zombie

	logo_state = "zombie-logo"

/datum/faction/zombie/forgeObjectives()
	. = ..()
	AppendObjective(/datum/objective/turn_into_zombie)
