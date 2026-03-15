/datum/faction/malf_drones
	name = F_MALF_DRONES
	ID = F_MALF_DRONES
	logo_state = "malf-logo"
	initroletype = /datum/role/malf_drone
	max_roles = 6

/datum/faction/malf_drones/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(pick(
		/datum/objective/malf_drone/closets,
		/datum/objective/malf_drone/disposal,
		/datum/objective/malf_drone/chairs,
		/datum/objective/malf_drone/department/table,
		/datum/objective/malf_drone/department/airlock))
	return TRUE
