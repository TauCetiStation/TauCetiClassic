/datum/role/mercenary
	name = "Mercenary"
	id = "Mercenary"
	logo_state = "synd-logo"

/datum/role/mercenary/forgeObjectives()
	. = ..()
	if(!.)
		return

	if(prob(50) && mode_has_antags())
		AppendObjective(/datum/objective/target/assassinate, TRUE)
	else
		AppendObjective(/datum/objective/target/protect, TRUE)
	AppendObjective(/datum/objective/escape)
