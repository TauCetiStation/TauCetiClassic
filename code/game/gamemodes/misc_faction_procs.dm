
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

/proc/setup_role(datum/role/R, post_setup)
	R.Greet()
	R.add_antag_hud()
	R.forgeObjectives()
	R.AnnounceObjectives()
	if(post_setup)
		R.OnPostSetup()

/proc/add_faction_member(datum/faction/faction, mob/M, recruit = TRUE, post_setup = FALSE, laterole = TRUE)
	ASSERT(faction)

	if(recruit)
		. = faction.HandleRecruitedMind(M.mind, laterole)
	else
		. = faction.HandleNewMind(M.mind, laterole)

	if(.)
		setup_role(., post_setup)

/proc/create_and_setup_role(role_type, mob/M, post_setup = TRUE, setup_role = TRUE)
	. = SSticker.mode.CreateRole(role_type, M)
	if(. && setup_role)
		setup_role(., post_setup)

/proc/create_faction(faction_type, post_setup = TRUE, give_objectives = TRUE)
	var/datum/faction/F = SSticker.mode.CreateFaction(faction_type, num_players(), TRUE)
	if(post_setup)
		F.OnPostSetup()
	if(give_objectives)
		F.forgeObjectives()
		F.AnnounceObjectives()
	return F

/proc/create_uniq_faction(faction_type, post_setup = TRUE, give_objectives = TRUE)
	. = find_faction_by_type(faction_type)
	if(!.)
		. = create_faction(faction_type, post_setup, give_objectives)

// create faction with custom parameters
// can be used before ticker initialization
/proc/create_custom_faction(name, id, logo, objective)
	var/datum/faction/F = new /datum/faction/custom

	if(name)
		F.name = name

	if(id)
		F.ID = id

	if(logo)
		F.logo_state = logo

	if(objective)
		var/datum/objective/custom/C = new /datum/objective/custom
		C.explanation_text = objective
		F.AppendObjective(C)

	if(SSticker && SSticker.current_state >= GAME_STATE_PLAYING)
		SSticker.mode.factions += F
	else
		// gamemode will check this list at Setup and register these factions
		LAZYADD(preinit_factions, F)

	return F
