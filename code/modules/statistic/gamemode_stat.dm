/datum/stat/objective
	var/owner // string faction or mind.name
	var/explanation_text
	var/completed
	var/__type

	var/target_name
	var/target_assigned_role
	var/target_special_role

/datum/stat/uplink_info
	var/total_TC
	var/spent_TC
	var/list/datum/stat/uplink_purchase/uplink_purchases

/datum/stat/uplink_purchase
	var/bundlename
	var/cost
	var/item_type

/datum/stat/faction
	// Default stats
	var/name
	var/id
	var/__type

	var/victory
	var/minor_victory

	var/list/datum/stat/objective/objectives = null
	var/list/datum/stat/role/members = null

	// Other factions stats

/datum/stat/faction/proc/set_custom_stat(datum/faction/F)
	return

/datum/stat/role
	// Default stats
	var/name
	var/id
	var/__type

	var/faction_id
	var/mind_name
	var/mind_ckey
	var/is_roundstart_role

	var/victory

	var/list/datum/stat/objective/objectives = null

	// Other roles stats
	var/datum/stat/uplink_info/uplink_info = null

/datum/stat/role/proc/set_custom_stat(datum/role/R)
	var/datum/component/gamemode/syndicate/S = R.GetComponent(/datum/component/gamemode/syndicate)
	if(S)
		uplink_info = new
		uplink_info.total_TC = S.total_TC
		uplink_info.spent_TC = S.spent_TC
		uplink_info.uplink_purchases = S.uplink_purchases

