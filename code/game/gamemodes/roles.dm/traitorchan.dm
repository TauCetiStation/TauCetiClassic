/datum/role/changeling/traitor
	name = TRAITORCHAN
	id = TRAITORCHAN
	required_pref = ROLE_TRAITOR

/datum/role/changeling/traitor/OnPostSetup(laterole)
	. = ..()
	var/datum/role/syndicate/traitor/temp_role = new /datum/role/syndicate/traitor()
	temp_role.equip_traitor(antag.current)
	temp_role.Drop()
