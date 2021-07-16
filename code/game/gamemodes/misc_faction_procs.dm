
/proc/find_faction_by_type(faction_type)
	if(!SSticker || !SSticker.mode)
		return null
	return locate(faction_type) in SSticker.mode.factions

/proc/find_factions_by_type(faction_type)
	if(!SSticker || !SSticker.mode)
		return null

	var/list/L = list()
	for(var/F in SSticker.mode.factions)
		if(istype(F, faction_type))
			L += F

	if(!L.len)
		return null

	return L

/proc/find_faction_by_member(datum/role/R, datum/mind/M)
	if(!R)
		return null
	if(R.GetFaction())
		return R.GetFaction()
	if(SSticker?.mode?.factions?.len)
		for(var/datum/faction/F in SSticker.mode.factions)
			for(var/datum/role/RR in F.members)
				if(RR == R || RR.antag == M)
					return F
	return null

/proc/find_factions_by_member(datum/role/R, datum/mind/M)
	var/list/found_factions = list()
	for(var/datum/faction/F in SSticker.mode.factions)
		for(var/datum/role/RR in F.members)
			if(RR == R || RR.antag == M)
				found_factions.Add(F)
				break
	return found_factions

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

/proc/setup_role(datum/role/R, mob/P, post_setup)
	R.Greet()
	R.add_antag_hud()
	R.forgeObjectives()
	R.AnnounceObjectives()
	if(post_setup)
		R.OnPostSetup()

/proc/add_faction_member(datum/faction/faction, mob/M, recruit = TRUE, post_setup = FALSE)
	ASSERT(faction)

	if(recruit)
		. = faction.HandleRecruitedMind(M.mind)
	else
		. = faction.HandleNewMind(M.mind)

	if(.)
		setup_role(., M, post_setup)

/proc/create_and_setup_role(role_type, mob/M, post_setup = TRUE)
	. = SSticker.mode.CreateRole(role_type, M)
	if(.)
		setup_role(., M, post_setup)
