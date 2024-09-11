/datum/stat/objective
	// string, anything, faction or mind.name
	var/owner
	// string, anything
	var/explanation_text
	// string, ["SUCCESS", "HALF", "FAIL"]
	var/completed
	// string, byond_type
	var/__type

	// string, anything
	var/target_name
	// string, anything
	var/target_assigned_role
	// string, anything
	var/target_special_role

/datum/stat/faction
	// Default stats
	// string, pool in ./code/game/gamemodes/factions in var name
	var/name
	// string, pool in ./code/game/gamemodes/factions in var ID
	var/id
	// string, byond_type
	var/__type

	// boolean, [0, 1]
	var/victory
	// boolean, [0, 1]
	var/minor_victory

	// array of objects
	var/list/datum/stat/objective/objectives = null
	// array of objects
	var/list/datum/stat/role/members = null

	// Other factions stats
	// object
	var/datum/stat/cult_info/cult_info = null

/datum/stat/faction/proc/set_custom_stat(datum/faction/F)
	return

/datum/stat/faction/cult/set_custom_stat(datum/faction/cult/F)
	var/datum/stat/cult_info/stat = new

	stat.real_number_members = F.religion.members.len
	stat.captured_areas = F.religion.captured_areas.len - F.religion.area_types.len
	stat.end_favor = F.religion.favor
	stat.end_piety = F.religion.piety
	stat.runes_on_station = F.religion.runes.len
	stat.anomalies_destroyed = SSStatistics.score.destranomaly

	var/list/aspect_types = subtypesof(/datum/aspect)
	stat.aspects = list()
	for(var/type in aspect_types)
		var/datum/aspect/A = type
		if(!initial(A.name))
			continue
		stat.aspects[initial(A.name)] = 0
	for(var/name in F.religion.aspects)
		var/datum/aspect/A = F.religion.aspects[name]
		stat.aspects[name] = A.power

	stat.ritename_by_count = list()
	var/list/rite_types = subtypesof(/datum/religion_rites)
	for(var/type in rite_types)
		var/datum/religion_rites/R = type
		if(!initial(R.name))
			continue
		stat.ritename_by_count[initial(R.name)] = 0
	for(var/name in F.religion.ritename_by_count)
		stat.ritename_by_count[name] = F.religion.ritename_by_count[name]

	cult_info = stat

/datum/stat/cult_info
	// int, [0...]
	var/real_number_members
	// int, [0...]
	var/captured_areas
	// int, [0...]
	var/end_favor
	// int, [0...]
	var/end_piety
	// int, [0...]
	var/runes_on_station
	// int, [0...]
	var/anomalies_destroyed

	// object, where key is aspect name and value is int, [0...]
	var/list/aspects
	// object, where key is rine name and value is int, [0...]
	var/list/ritename_by_count

/datum/stat/uplink_info
	// int, [0...]
	var/total_TC
	// int, [0...]
	var/spent_TC
	// array of objects
	var/list/datum/stat/uplink_purchase/uplink_purchases

/datum/stat/uplink_purchase
	// string, anything
	var/bundlename
	// int, [0...]
	var/cost
	// string, byond_type
	var/item_type

/datum/stat/changeling_info
	// int, [0...]. victims
	var/victims_number
	// array of objects
	var/list/datum/stat/changeling_purchase/changeling_purchase

/datum/stat/changeling_purchase
	// string, byond_type
	var/power_type
	// string, anything
	var/power_name
	// int, [0...]
	var/cost

/datum/stat/wizard_info
	// array of objects
	var/list/datum/stat/book_purchase/book_purchases

/datum/stat/book_purchase
	// string, byond_type
	var/power_type
	// string, anything
	var/power_name
	// int, [0...]
	var/cost

/datum/stat/role
	// Default stats
	// string, pool in ./code/game/gamemodes/roles in var name
	var/name
	// string, pool in ./code/game/gamemodes/roles in var id
	var/id
	// string, byond_type
	var/__type

	// string, pool in ./code/game/gamemodes/factions in var ID
	var/faction_id
	// string, anything
	var/mind_name
	// string, lowercase and only words and digits
	var/mind_ckey
	// boolead, [0, 1]
	var/is_roundstart_role

	// boolead, [0, 1]
	var/victory

	// array of objects
	var/list/datum/stat/objective/objectives = null

	// Other roles stats
	// object
	var/datum/stat/uplink_info/uplink_info = null
	// object
	var/datum/stat/changeling_info/changeling_info = null
	// object
	var/datum/stat/wizard_info/wizard_info = null


/datum/stat/role/proc/set_custom_stat(datum/role/R)
	var/datum/component/gamemode/syndicate/S = R.GetComponent(/datum/component/gamemode/syndicate)
	if(S)
		uplink_info = new
		uplink_info.total_TC = S.total_TC
		uplink_info.spent_TC = S.spent_TC
		uplink_info.uplink_purchases = S.uplink_purchases

/datum/stat/role/changeling/set_custom_stat(datum/role/changeling/C)
	var/datum/stat/changeling_info/_changeling_info = new
	_changeling_info.victims_number = C.absorbedamount

	_changeling_info.changeling_purchase = list()
	for(var/obj/effect/proc_holder/changeling/P in C.purchasedpowers)
		if(P.genomecost <= 0)
			continue
		var/datum/stat/changeling_purchase/stat = new
		stat.power_name = P.name
		stat.power_type = P.type
		stat.cost = P.genomecost

		_changeling_info.changeling_purchase += stat

	changeling_info = _changeling_info

/datum/stat/role/wizard/set_custom_stat(datum/role/wizard/W)
	var/datum/stat/wizard_info/_wizard_info = new

	_wizard_info.book_purchases = list()
	for(var/datum/stat/book_purchase/book_stat in W.list_of_purchases)
		_wizard_info.book_purchases += book_stat

	wizard_info = _wizard_info
