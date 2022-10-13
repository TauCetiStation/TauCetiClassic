/datum/role/slave
	name = SLAVE
	id = SLAVE

/datum/role/slave/proc/copy_variables(datum/role/master)
	antag_hud_type = master.antag_hud_type
	antag_hud_name = master.antag_hud_name
	logo_state = master.logo_state
	objectives = master.objectives
