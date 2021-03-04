
/proc/find_active_faction_by_type(faction_type)
	if(!SSticker || !SSticker.mode)
		return null
	return locate(faction_type) in SSticker.mode.factions

/proc/find_active_faction_by_member(datum/role/R, datum/mind/M)
	if(!R)
		return null
	var/found_faction = null
	if(R.GetFaction())
		return R.GetFaction()
	if(SSticker && SSticker.mode && SSticker.mode.factions.len)
		var/success = FALSE
		for(var/datum/faction/F in SSticker.mode.factions)
			for(var/datum/role/RR in F.members)
				if(RR == R || RR.antag == M)
					found_faction = F
					success = TRUE
					break
			if(success)
				break
	return found_faction

/proc/find_active_factions_by_member(datum/role/R, datum/mind/M)
	var/list/found_factions = list()
	for(var/datum/faction/F in SSticker.mode.factions)
		for(var/datum/role/RR in F.members)
			if(RR == R || RR.antag == M)
				found_factions.Add(F)
				break
	return found_factions

/proc/find_active_faction_by_typeandmember(fac_type, datum/role/R, datum/mind/M)
	var/list/found_factions = find_active_factions_by_member(R, M)
	return locate(fac_type) in found_factions
