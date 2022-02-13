/datum/stat/objective
	var/owner // string faction or mind.name
	var/explanation_text
	var/completed
	var/__type

	var/target_name
	var/target_assigned_role
	var/target_special_role

/datum/stat/faction
	var/name
	var/id
	var/__type

	var/victory
	var/minor_victory

	var/list/datum/stat/objective/objectives = null
	var/list/datum/stat/role/members = null

/datum/stat/faction/proc/set_custom_stat(datum/faction/F)
	return

/datum/stat/role
	var/name
	var/id
	var/__type

	var/faction_id
	var/mind_name
	var/mind_ckey
	var/is_roundstart_role

	var/victory

	var/list/datum/stat/objective/objectives = null

/datum/stat/role/proc/set_custom_stat(datum/role/R)
	return
