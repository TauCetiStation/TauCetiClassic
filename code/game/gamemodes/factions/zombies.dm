/datum/faction/zombie
	name = F_ZOMBIES
	ID = F_ZOMBIES

	initroletype = /datum/role/zombie

	logo_state = "zombie-logo"

	var/last_check = 0

/datum/faction/zombie/forgeObjectives()
	. = ..()
	AppendObjective(/datum/objective/turn_into_zombie)

/datum/faction/zombie/check_win()
	if(last_check > world.time)
		return FALSE
	last_check = world.time + 30 SECONDS
	if(round(length(members) / check_crew() >= 0.8))
		return TRUE
	return FALSE
