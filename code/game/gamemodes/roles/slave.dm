/datum/role/slave
	name = SLAVE
	id = SLAVE

/datum/role/slave/AssignToRole(datum/mind/M, override = FALSE, msg_admins = TRUE, laterole = TRUE)
	if(!..())
		return FALSE
	ADD_TRAIT(M.current, TRAIT_SLAVE_PERSON, GAMEMODE_TRAIT)
	return TRUE

/datum/role/slave/RemoveFromRole(datum/mind/M, msg_admins)
	. = ..()
	REMOVE_TRAIT(M.current, TRAIT_SLAVE_PERSON, GAMEMODE_TRAIT)

/datum/role/slave/proc/copy_variables(datum/role/master)
	antag_hud_type = master.antag_hud_type
	antag_hud_name = master.antag_hud_name
	logo_state = master.logo_state
	objectives = master.objectives
