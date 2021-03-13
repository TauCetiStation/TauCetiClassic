
/proc/find_active_first_faction_by_type(faction_type)
	if(!SSticker || !SSticker.mode)
		return null
	return locate(faction_type) in SSticker.mode.factions

/proc/find_active_all_faction_by_type(faction_type)
	if(!SSticker || !SSticker.mode)
		return null

	var/list/L = list()
	for(var/datum/faction/F in SSticker.mode.factions)
		if(istype(F, faction_type))
			L += F

	if(!L.len)
		return null

	return L

/proc/find_active_faction_by_member(datum/role/R, datum/mind/M)
	if(!R)
		return null
	var/found_faction = null
	if(R.GetFaction())
		return R.GetFaction()
	if(SSticker?.mode?.factions?.len)
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

/proc/find_active_first_faction_by_typeandmember(fac_type, datum/role/R, datum/mind/M)
	var/list/found_factions = find_active_factions_by_member(R, M)
	return locate(fac_type) in found_factions

/proc/find_unique_objectives(list/new_objectives, list/old_objectives)
	var/list/uniques = list()
	for (var/datum/objective/new_objective in new_objectives)
		var/is_unique = TRUE
		for (var/datum/objective/old_objective in old_objectives)
			if (old_objective.type == new_objective.type)
				is_unique = FALSE
		if (is_unique)
			uniques.Add(new_objective)
	return uniques

/proc/add_faction_member(datum/faction/faction, mob/M, recruit = TRUE)
	if(recruit)
		faction.HandleRecruitedMind(M.mind)
	else
		faction.HandleNewMind(M.mind)

	var/datum/role/R
	if(recruit)
		R = M.mind.GetRole(faction.roletype)
	else
		R = M.mind.GetRole(faction.initroletype)
	R.Greet()
	R.forgeObjectives()
	R.AnnounceObjectives()

/proc/create_and_setup_role(role_type, mob/P, post_setup = TRUE)
	var/datum/role/R = SSticker.mode.CreateRole(role_type, P)
	R.Greet()
	R.forgeObjectives()
	R.AnnounceObjectives()
	if(post_setup)
		R.OnPostSetup()
