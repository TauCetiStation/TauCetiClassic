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
	var/datum/stat/cult_info/cult_info = null

/datum/stat/faction/proc/set_custom_stat(datum/faction/F)
	return

/datum/stat/faction/cult_info
	var/real_number_members
	var/captured_areas
	var/end_favor
	var/end_piety
	var/runes_on_station
	var/anomalies_destroyed

	var/list/aspects
	var/list/ritename_by_count


/datum/stat/faction/cult_info/set_custom_stat(datum/faction/cult/F)
	real_number_members = F.religion.members.len
	captured_areas = F.religion.captured_areas.len - F.religion.area_types.len
	end_favor = F.religion.favor
	end_piety = F.religion.piety
	runes_on_station = F.religion.runes.len
	anomalies_destroyed = SSStatistics.score.destranomaly

	var/list/aspect_types = subtypesof(/datum/aspect)
	aspects = list()
	for(var/type in aspect_types)
		var/datum/aspect/A = type
		if(!initial(A.name))
			continue
		aspects[initial(A.name)] = 0
	for(var/name in F.religion.aspects)
		var/datum/aspect/A = F.religion.aspects[name]
		aspects[name] = A.power

	ritename_by_count = list()
	var/list/rite_types = subtypesof(/datum/religion_rites)
	for(var/type in rite_types)
		var/datum/religion_rites/R = type
		if(!initial(R.name))
			continue
		ritename_by_count[initial(R.name)] = 0
	for(var/name in F.religion.ritename_by_count)
		ritename_by_count[name] = F.religion.ritename_by_count[name]

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

