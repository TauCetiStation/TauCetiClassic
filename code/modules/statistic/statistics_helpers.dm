/datum/stat_collector/proc/add_communication_log(type, title, author, content, time = roundduration2text())
	var/datum/stat/communication_log/stat = new
	stat.__type = type
	stat.title = title
	stat.author = author
	stat.time = time
	stat.content = content
	communication_logs += stat

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
	stat.time_of_death = roundtimestamp(world.time)
	stat.from_suicide = H.suiciding
	stat.mob_type = H.type
	stat.last_phrase = H.last_phrase
	stat.last_examined_name = H.last_examined

	var/turf/spot = get_turf(H)
	stat.death_x = spot.x
	stat.death_y = spot.y
	stat.death_z = spot.z

	stat.name = H.name
	stat.real_name = H.real_name
	stat.last_attacker_name = H.lastattacker_name

	stat.damage["BRUTE"] = H.getBruteLoss()
	stat.damage["FIRE"]  = H.getFireLoss()
	stat.damage["TOXIN"] = H.getToxLoss()
	stat.damage["OXY"]   = H.getOxyLoss()
	stat.damage["CLONE"] = H.getCloneLoss()
	stat.damage["BRAIN"] = H.getBrainLoss()

	stat.mind_name = H.mind.name
	stat.assigned_role = H.mind.assigned_role
	stat.special_role = H.mind.special_role

	deaths += stat

/datum/stat_collector/proc/add_explosion_stat(turf/epicenter, dev_range, hi_range, li_range, flash_range, flame_range)
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
	stat.flame_range = flame_range
	stat.occurred_time = roundduration2text()

	explosions += stat

/datum/stat_collector/proc/add_emp_stat(turf/epicenter, high_range, light_range)
	if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
		return

	var/datum/stat/emp_stat/stat = new
	stat.epicenter_x = epicenter.x
	stat.epicenter_y = epicenter.y
	stat.epicenter_z = epicenter.z
	stat.heavy_range = high_range
	stat.light_range = light_range
	stat.occurred_time = roundduration2text()

	emps += stat

/datum/stat_collector/proc/add_manifest_entry(key, name, assigned_role, special_role, list/antag_roles, mob/controlled_mob)
	var/datum/stat/manifest_entry/stat = new
	stat.name = STRIP_NEWLINE(name)
	stat.assigned_role = STRIP_NEWLINE(assigned_role)
	stat.special_role = STRIP_NEWLINE(special_role)
	if(controlled_mob)
		stat.species = controlled_mob.get_species()
		stat.gender = controlled_mob.gender
		stat.flavor = STRIP_NEWLINE(controlled_mob.flavor_text)
		if(ishuman(controlled_mob))
			var/mob/living/carbon/human/H = controlled_mob
			stat.age = H.age

	if(antag_roles?.len)
		stat.antag_roles = list()
		for(var/role in antag_roles)
			stat.antag_roles += role

	manifest_entries += stat

/datum/stat_collector/proc/get_leave_stat(datum/mind/M, leave_type, leave_time = roundduration2text())
	var/datum/stat/leave_stat/stat = new
	stat.name = STRIP_NEWLINE(M.name)
	stat.assigned_role = STRIP_NEWLINE(M.assigned_role)
	stat.special_role = STRIP_NEWLINE(M.special_role)

	if(M.antag_roles?.len)
		stat.antag_roles = list()
		for(var/role in M.antag_roles)
			stat.antag_roles += role

	stat.leave_type = leave_type
	stat.start_time = M.creation_roundtime
	stat.leave_time = leave_time

	return stat

/datum/stat_collector/proc/add_leave_stat(datum/mind/M, leave_type, leave_time = roundduration2text())
	var/datum/stat/leave_stat/stat = get_leave_stat(M, leave_type, leave_time)
	leave_stats += stat

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
		stat.target_assigned_role = T.target.assigned_role
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

/datum/stat_collector/proc/add_vote(datum/poll/poll)
	var/datum/stat/vote/stat = new
	stat.name = poll.name
	stat.total_votes = poll.total_votes()
	stat.total_voters = poll.total_voters()
	stat.winner = poll.winner.text

	for(var/datum/vote_choice/V in poll.choices)
		stat.results[V.text] = V.total_votes()

	completed_votes += stat
