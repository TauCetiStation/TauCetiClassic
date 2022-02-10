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

	stat.damage["BRUTE"] = H.bruteloss
	stat.damage["FIRE"]  = H.fireloss
	stat.damage["TOXIN"] = H.toxloss
	stat.damage["OXY"]   = H.oxyloss
	stat.damage["CLONE"] = H.cloneloss
	stat.damage["BRAIN"] = H.brainloss

	if(H.mind)
		stat.mind_name = H.mind.name
		stat.assigned_role = H.mind.assigned_role
		stat.special_role = H.mind.special_role
		stat.key = ckey(H.mind.key)

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
	stat.key = ckey(key)
	stat.name = STRIP_NEWLINE(name)
	stat.assignment = STRIP_NEWLINE(assignment)
	stat.special_role = STRIP_NEWLINE(special_role)
	if(antag_roles?.len)
		stat.antag_roles = list()
		for(var/role in antag_roles)
			antag_roles += role

	manifest_entries += stat

/*
/datum/stat_collector/proc/add_role(datum/role/R)
	R.stat_datum.generate_statistics(R)
	roles.Add(R.stat_datum)

/datum/stat_collector/proc/add_faction(datum/faction/F)
	F.stat_datum.generate_statistics(F)
	factions.Add(F.stat_datum)
*/
