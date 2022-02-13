// Deprecated
/datum/stat_collector/proc/add_completion_antagonist(faction, role, html)
	var/datum/stat/antagonists_completion/stat = new
	stat.faction = faction
	stat.role = role
	stat.html = html
	completion_antagonists += stat

/datum/stat_collector/proc/add_centcomm_communication(type, title, author, content, time = roundduration2text())
	var/datum/stat/centcomm_communication/stat = new
	stat.__type = type
	stat.title = title
	stat.author = author
	stat.time = time
	stat.content = content
	centcomm_communications += stat

/datum/stat_collector/proc/add_achievement(key, name, title, desc)
	var/datum/stat/achievement/stat = new
	stat.key = key
	stat.name = name
	stat.title = title
	stat.desc = desc
	achievements += stat

/datum/stat_collector/proc/add_death_stat(mob/living/H)
	if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
		return
	if(!isliving(H))
		return
	if(!H.mind)
		return

	var/datum/stat/death_stat/stat = new
	stat.time_of_death = H.timeofdeath
	stat.from_suicide = H.suiciding

	var/turf/spot = get_turf(H)
	stat.death_x = spot.x
	stat.death_y = spot.y
	stat.death_z = spot.z

	stat.name = H.name
	stat.real_name = H.real_name

	if(H.lastattacker)
		stat.last_attacker_name = H.lastattacker?.name
		stat.last_attacker_key = H.lastattacker?.key

	stat.damage["BRUTE"] = H.getBruteLoss()
	stat.damage["FIRE"]  = H.getFireLoss()
	stat.damage["TOXIN"] = H.getToxLoss()
	stat.damage["OXY"]   = H.getOxyLoss()
	stat.damage["CLONE"] = H.getCloneLoss()
	stat.damage["BRAIN"] = H.getBrainLoss()

	if(H.mind)
		stat.mind_name = H.mind.name
		stat.assigned_role = H.mind.assigned_role
		stat.special_role = H.mind.special_role

	deaths += stat

/datum/stat_collector/proc/add_explosion_stat(turf/epicenter, dev_range, hi_range, li_range, flash_range)
	if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
		return

	var/datum/stat/explosion_stat/stat = new
	stat.epicenter_x = epicenter.x
	stat.epicenter_y = epicenter.y
	stat.epicenter_z = epicenter.z
	stat.devastation_range = dev_range
	stat.heavy_impact_range = hi_range
	stat.light_impact_range = li_range
	stat.flash_range = flash_range
	explosions += stat

/datum/stat_collector/proc/add_manifest_entry(key, name, assignment, special_role, list/antag_roles)
	var/datum/stat/manifest_entry/stat = new
	stat.name = STRIP_NEWLINE(name)
	stat.assignment = STRIP_NEWLINE(assignment)
	stat.special_role = STRIP_NEWLINE(special_role)
	if(antag_roles?.len)
		stat.antag_roles = list()
		for(var/role in antag_roles)
			stat.antag_roles += role

	manifest_entries += stat

/datum/stat_collector/proc/get_objective_stat(datum/objective/O)
	var/datum/stat/objective/stat = new
	stat.explanation_text = O.explanation_text
	stat.completed = O.completion_to_string(tags = FALSE)
	stat.__type = O.type

	if(O.faction)
		stat.owner = O.faction.ID
	else if(O.owner)
		stat.owner = STRIP_NEWLINE(O.owner.name)

	if(istype(O, /datum/objective/target))
		var/datum/objective/target/T = O
		stat.target_name = STRIP_NEWLINE(T.target.name)
		stat.target_assigned_role = T.target.assigned_job
		stat.target_special_role = T.target.special_role

	return stat

/datum/stat_collector/proc/get_role_stat(datum/role/R)
	var/datum/stat/role/stat = new R.stat_type
	stat.name = R.name
	stat.id = R.id
	stat.__type = R.type

	if(R.faction)
		stat.faction_id = R.faction.ID

	if(R.antag)
		stat.mind_name = STRIP_NEWLINE(R.antag.name)
		stat.mind_ckey = ckey(R.antag.key)

	stat.is_roundstart_role = R.is_roundstart_role
	stat.victory = R.IsSuccessful()

	if(R.objectives)
		stat.objectives = list()
		for(var/datum/objective/O in R.objectives.GetObjectives())
			stat.objectives += get_objective_stat(O)

	stat.set_custom_stat(R)
	return stat

/datum/stat_collector/proc/add_orphaned_role(datum/role/R)
	orphaned_roles += get_role_stat(R)

/datum/stat_collector/proc/add_faction(datum/faction/F)
	var/datum/stat/faction/stat = new F.stat_type

	stat.name = F.name
	stat.id = F.ID
	stat.__type = F.type

	stat.victory = F.IsSuccessful()
	stat.minor_victory = F.minor_victory

	if(F.objective_holder.objectives.len)
		stat.objectives = list()
		for(var/datum/objective/O in F.objective_holder.GetObjectives())
			stat.objectives += get_objective_stat(O)

	if(F.members.len)
		stat.members = list()
		for(var/datum/role/R in F.members)
			stat.members += get_role_stat(R)

	stat.set_custom_stat(F)
	factions += stat
