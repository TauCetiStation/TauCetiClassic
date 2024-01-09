/datum/faction
	// Name of the faction
	var/name
	// Identifying strings for shorthand finding this faction.
	var/ID
	// What preference is required to be recruited to this faction.
	var/required_pref

	// How many members this faction is limited to. Set to 0 for no limit
	var/max_roles = 0
	// How many members this faction should be in it at the time of creating the game_mode
	var/min_roles = 1
	// Whether or not this faction accepts newspawn latejoiners
	var/accept_latejoiners = FALSE
	// Accepts roundstart populating. Set FALSE to make faction members list empty
	var/rounstart_populate = TRUE

	// Type of roles that should be in faction initially
	var/datum/role/initroletype
	// Type of roles that are recruited to faction during the round
	var/datum/role/roletype

	// Logo of faction
	var/logo_state
	// Global faction status indicator
	var/stage = FS_DORMANT //role_datums_defines.dm
	// You need to set it manually for the correct GetScoreboard()
	var/minor_victory = FALSE
	// This is intended to be used on GetScoreboard() to list things like nuclear ops purchases.
	var/list/faction_scoreboard_data = list()

	// Ref to leader
	var/datum/role/leader
	// Who is a member of this faction - ROLES, NOT MINDS
	var/list/datum/role/members = list()
	// What are the goals of this faction?
	var/datum/objective_holder/objective_holder

	// Type for collector of statistics by this faction
	var/datum/stat/faction/stat_type = /datum/stat/faction

	// Whether the faction should be printed to the scoreboard even if it has 0 members.
	var/always_print = FALSE

/datum/faction/New()
	SHOULD_CALL_PARENT(TRUE)
	..()
	objective_holder = new
	objective_holder.faction = src

/datum/faction/Destroy(force, ...)
	QDEL_NULL(objective_holder)
	return ..()

/datum/faction/proc/OnPostSetup()
	SHOULD_CALL_PARENT(TRUE)
	for(var/datum/role/R in members)
		R.OnPostSetup()

// Destroy fraction and her members
/datum/faction/proc/Dismantle()
	var/datum/game_mode/G = SSticker.mode
	for(var/datum/role/R in members)
		HandleRemovedRole(R)
	qdel(objective_holder)
	G.factions -= src
	qdel(src)

//Initialization proc, checks if the faction can be made given the current amount of players and/or other possibilites
/datum/faction/proc/can_setup(num_players)
	return TRUE

//For when you want your faction to have specific objectives (Vampire, suck blood. Cult, sacrifice the head of personnel's dog, etc.)
/datum/faction/proc/forgeObjectives()
	SHOULD_CALL_PARENT(TRUE)
	if(config.objectives_disabled)
		return FALSE
	for(var/datum/role/R in members)
		R.forgeObjectives()
	return TRUE

/datum/faction/proc/AnnounceObjectives()
	SHOULD_CALL_PARENT(TRUE)
	for(var/datum/role/R in members)
		R.AnnounceObjectives()

/datum/faction/proc/ShuttleDocked(state)
	return

/datum/faction/proc/get_initrole_type()
	if(!isnull(initroletype))
		return initroletype
	return roletype

/datum/faction/proc/get_role_type()
	if(!isnull(roletype))
		return roletype
	return initroletype

/datum/faction/proc/can_join_faction(mob/P)
	if(!P.client || !P.mind)
		return FALSE
	if(!required_pref)
		log_mode("[name] - [type] has no required_pref")
		return TRUE
	if(!P.client.prefs.be_role.Find(required_pref) || jobban_isbanned(P, required_pref) || role_available_in_minutes(P, required_pref) || jobban_isbanned(P, "Syndicate"))
		return FALSE
	return TRUE

/datum/faction/proc/can_latespawn_mob(mob/P)
	return TRUE

// Basically, they are members of the new faction
/datum/faction/proc/HandleNewMind(datum/mind/M, laterole) //Used on faction creation
	SHOULD_CALL_PARENT(TRUE)
	for(var/datum/role/R in members)
		if(R.antag == M)
			return null
	var/initial_role = initial(initroletype.id)
	if(M.GetRole(initial_role))
		log_mode("Mind already had a role of [initial_role]!")
		return null
	var/role_type = get_initrole_type()
	var/datum/role/newRole = new role_type(null, src)
	newRole.is_roundstart_role = !laterole
	if(!newRole.AssignToRole(M, laterole = laterole))
		newRole.Drop()
		return null
	return newRole

// Basically, these are the new members of the faction during the round
/datum/faction/proc/HandleRecruitedMind(datum/mind/M, laterole)
	SHOULD_CALL_PARENT(TRUE)
	for(var/datum/role/R in members)
		if(R.antag == M)
			return R
	var/late_role = initial(roletype.id)
	if(M.GetRole(late_role))
		log_mode("Mind already had a role of [late_role]!")
		return (M.GetRole(late_role))
	var/role_type = get_role_type()
	var/datum/role/R = new role_type(null, src) // Add him to our roles
	if(!R.AssignToRole(M, laterole = laterole))
		R.Drop()
		return null
	return R

/datum/faction/proc/HandleRecruitedRole(datum/role/R)
	SHOULD_CALL_PARENT(TRUE)
	SSticker.mode.orphaned_roles -= R
	add_role(R)

/datum/faction/proc/HandleRemovedRole(datum/role/R)
	SHOULD_CALL_PARENT(TRUE)
	SSticker.mode.orphaned_roles += R
	remove_role(R)

/datum/faction/proc/add_role(datum/role/R)
	SHOULD_CALL_PARENT(TRUE)
	members += R
	R.faction = src

/datum/faction/proc/remove_role(datum/role/R)
	SHOULD_CALL_PARENT(TRUE)
	members -= R
	R.faction = null
	if(leader == R)
		leader = null

/datum/faction/proc/AppendObjective(objective_type,duplicates=0)
	SHOULD_CALL_PARENT(TRUE)
	if(!duplicates && locate(objective_type) in objective_holder.GetObjectives())
		return null
	var/datum/objective/O
	if(istype(objective_type, /datum/objective)) //Passed an actual objective
		O = objective_type
	else
		O = new objective_type
	if(objective_holder.AddObjective(O, null, src))
		return O
	return null

/datum/faction/proc/GetObjectives()
	return objective_holder.GetObjectives()

/datum/faction/proc/CheckObjectives()
	return objective_holder.GetObjectiveString(check_success = TRUE)

/datum/faction/proc/calculate_completion()
	for(var/datum/objective/O in GetObjectives())
		O.calculate_completion()
	for(var/datum/role/R in members)
		R.calculate_completion()

// Numbers!!
/datum/faction/proc/build_scorestat()
	return

// Numbers!!
/datum/faction/proc/get_scorestat()
	return ""

/datum/faction/proc/custom_result()
	return ""

/datum/faction/proc/custom_member_output()
	return ""

/datum/faction/proc/GetScoreboard()
	var/count = 1
	var/score_results = ""
	if(objective_holder.objectives.len > 0)
		score_results += "<ul>"
		var/custom_result = custom_result()
		if(custom_result)
			score_results += custom_result
		else
			if (IsSuccessful())
				score_results += "<span class='green'><B>\The [capitalize(name)] was successful!</B></span>"
				feedback_add_details("[ID]_success","SUCCESS")
				SSStatistics.score.roleswon++
			else if (minor_victory)
				score_results += "<span class='orange'><B>\The [capitalize(name)] has achieved a minor victory.</B> [minorVictoryText()]</span>"
				feedback_add_details("[ID]_success","HALF")
			else
				score_results += "<span class='red'><B>\The [capitalize(name)] has failed.</B></span>"
				feedback_add_details("[ID]_success","FAIL")

		score_results += "<br><br>"
		for (var/datum/objective/objective in objective_holder.GetObjectives())
			objective.extra_info()
			score_results += "<B>Objective #[count]</B>: [objective.explanation_text] [objective.completion_to_string()]"
			feedback_add_details("[ID]_objective","[objective.type]|[objective.completion_to_string(FALSE)]")
			count++
			if (count <= objective_holder.objectives.len)
				score_results += "<br>"

		score_results += "</ul>"

	score_results += "<ul>"

	var/custom_member_output = custom_member_output()
	var/have_objectives = FALSE
	if(custom_member_output)
		score_results += custom_member_output
	else
		var/list/name_by_members = list()
		score_results += "<FONT size = 2><B>Members:</B></FONT><br>"
		for(var/datum/role/R in members)
			if(!name_by_members[R.name])
				name_by_members[R.name] = list()
			name_by_members[R.name] += R

		for(var/name in name_by_members)
			score_results += "<b>[name]:</b><ul>"
			for(var/datum/role/R in name_by_members[name])
				var/results = R.GetScoreboard()
				if(results)
					score_results += results
					score_results += "<br>"
					if(R.objectives.objectives.len)
						have_objectives = TRUE
			score_results += "</ul>"

	score_results += "</ul>"

	if(!have_objectives)
		score_results += "<br>"

	return score_results

/datum/faction/Topic(href, href_list)
	..()
	if(href_list["destroyfac"])
		if(!check_rights(R_ADMIN))
			message_admins("[usr] tried to destroy a faction without permissions.")
			return
		if(tgui_alert(usr, "Are you sure you want to destroy [capitalize(name)]?",  "Destroy Faction" , list("Yes" , "No")) != "Yes")
			return
		message_admins("[key_name(usr)] destroyed faction [capitalize(name)].")
		log_mode("[key_name(usr)] destroyed faction [capitalize(name)].")
		Dismantle()

/datum/faction/proc/IsSuccessful()
	if(objective_holder.objectives.len > 0)
		for(var/datum/objective/objective in objective_holder.GetObjectives())
			if(objective.completed == OBJECTIVE_LOSS)
				return FALSE
	for(var/datum/role/R in members)
		if(!R.IsSuccessful())
			return FALSE
	return TRUE

/datum/faction/proc/get_logo_icon(custom)
	if(custom)
		return icon('icons/misc/logos.dmi', custom)
	if(logo_state)
		return icon('icons/misc/logos.dmi', logo_state)
	return icon('icons/misc/logos.dmi', "unknown-logo")

/datum/faction/proc/GetFactionHeader() //Returns what will show when the factions objective completion is summarized
	var/icon/logo = get_logo_icon()
	var/header = {"[bicon(logo, css = "style='position:relative; top:10;'")] <FONT size = 3><B>[capitalize(name)]</B></FONT> [bicon(logo, css = "style='position:relative; top:10;'")]"}
	return header


/datum/faction/proc/extraPanelButtons(datum/mind/M)
	return ""

/datum/faction/proc/AdminPanelEntry(datum/mind/M)
	SHOULD_CALL_PARENT(TRUE)
	var/dat = ""
	dat += GetFactionHeader()
	dat += " <a href='?src=\ref[src];destroyfac=1'>\[Destroy\]</A>"
	var/fac_objects = objective_holder.GetObjectiveString(FALSE, FALSE, M)
	if(fac_objects)
		dat += "<br><ul><b>Faction objectives:</b><br>"
		dat += fac_objects
		dat += "</ul>"

	dat += AdminPanelEntryMembers(M, fac_objects)

	return dat

/datum/faction/proc/AdminPanelEntryMembers(datum/mind/M, fac_objects)
	var/dat = ""
	dat += "[fac_objects ? "" : "<br>"] - <b>Members</b> - "
	if(members.len)
		for(var/datum/role/R in members)
			dat += "<br>"
			dat += R.AdminPanelEntry(TRUE)
	else
		dat += "<br><i>Unpopulated</i><br>"

	return dat

/datum/faction/process()
	for (var/datum/role/R in members)
		R.process()

/datum/faction/proc/stage(value)
	stage = value
	switch(value)
		if(FS_DEFEATED) //Faction was close to victory, but then lost. Send shuttle and end theme.
			sleep(5 SECONDS)
			SSshuttle.fake_recall = FALSE
			SSshuttle.online = TRUE
			OnPostDefeat()
			set_security_level("blue")
		if(FS_ENDGAME) //Faction is nearing victory. Set red alert and play endgame music.
			sleep(2 SECONDS)
			set_security_level("red")

/datum/faction/proc/OnPostDefeat()
	if(SSshuttle.location || SSshuttle.direction) //If traveling or docked somewhere other than idle at command, don't call.
		return
	SSshuttle.incall()
	SSshuttle.announce_crew_called.play()

/datum/faction/proc/check_win()
	return FALSE

/datum/faction/proc/minorVictoryText()
	return ""

// Generic proc for added/removed faction objectives
// Override this in the proper faction if you need to notify the players or if the objective is important.
/datum/faction/proc/handleNewObjective(datum/objective/O)
	SHOULD_CALL_PARENT(TRUE)
	ASSERT(O)
	O.faction = src
	if(O in objective_holder.objectives)
		log_mode("Trying to add an objective ([O]) to faction ([src]) when it already has it.")
		return FALSE

	AppendObjective(O)
	return TRUE

/datum/faction/proc/handleRemovedObjective(datum/objective/O)
	SHOULD_CALL_PARENT(TRUE)
	ASSERT(O)
	if (!(O in objective_holder.objectives))
		log_mode("Trying to remove an objective ([O]) to faction ([src]) who never had it.")
		return FALSE
	objective_holder.objectives -= O
	O.faction = null
	qdel(O)

/datum/faction/proc/latespawn(mob/M)
	return

/**
	Should the faction make any changes to everybodies statpanel (EVERYBODIES, NOT JUST THE MEMBERS), put it here

	Format it as just information you would want to print to the stat panel, such as return "Time left: [max(malf.AI_win_timeleft/(malf.apcs/3), 0)]"
*/
/datum/faction/proc/get_statpanel_addition()
	return null

/datum/faction/proc/get_member_by_mind(datum/mind/M)
	for(var/datum/role/R in members)
		if(R.antag == M)
			return R

/datum/faction/proc/get_member_by_ckey(ckey)
	for(var/datum/role/R in members)
		if(R.antag && ckey(R.antag.key) == ckey)
			return R

/datum/faction/proc/get_active_members()
	. = list()
	for(var/datum/role/R in members)
		var/mob/M = R.antag?.current
		if(!M || !M.client)
			continue
		. += M

/datum/faction/proc/check_crew()
	var/total_human = 0
	for(var/mob/living/carbon/human/H as anything in human_list)
		var/turf/human_loc = get_turf(H)
		if(!human_loc || !is_station_level(human_loc.z))
			continue
		if(H.stat == DEAD)
			continue
		if(!H.mind || !H.client)
			continue
		total_human++
	return total_human
