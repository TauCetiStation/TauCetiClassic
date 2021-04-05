/*
	Faction Datums
		Used for keeping a collection of people (In this case ROLES) under one banner, making for easier
		objective syncing, communication, etc.

	@name: String: Name of the faction
	@ID: List(String): Identifying strings for shorthand finding this faction.
	@desc: String: Description of the faction, their intentions, how they do things, etc. Something for lorewriters to use.
	@initial_role: String(DEFINE): On initial setup via gamemode or faction creation, set the new minds role ID to this.
	@late_role: String(DEFINE): On later recruitment, set the new minds role ID to this. TRAITOR for example
	@required_pref: String(DEFINE): What preference is required to be recruited to this faction.
	@members: List(Reference): Who is a member of this faction - ROLES, NOT MINDS
	@max_roles: Integer: How many members this faction is limited to. Set to 0 for no limit
	@min_roles: Integer: how many members this faction should be in it at the time of creating the game_mode
	@accept_latejoiners: Boolean: Whether or not this faction accepts newspawn latejoiners
	@objective_holder: objectives datum: What are the goals of this faction?
	@faction_scoreboard_data: This is intended to be used on GetScoreboard() to list things like nuclear ops purchases.
*/

/datum/faction
	var/name = "unknown faction"
	var/ID = null
	var/desc = "This faction is bound to do something nefarious"
	var/required_pref = ""

	var/max_roles = 0
	var/min_roles = 1
	var/accept_latejoiners = FALSE

	var/datum/role/leader
	var/initial_role
	var/datum/role/initroletype
	var/late_role
	var/datum/role/roletype

	var/logo_state
	var/stage = FACTION_DORMANT //role_datums_defines.dm
	var/minor_victory = FALSE
	var/list/faction_scoreboard_data = list()

	var/list/datum/role/members = list()
	var/datum/objective_holder/objective_holder

/datum/faction/New()
	SHOULD_CALL_PARENT(TRUE)
	..()
	objective_holder = new
	objective_holder.faction = src

	min_roles = 1
	max_roles = 999

/datum/faction/proc/OnPostSetup()
	SHOULD_CALL_PARENT(TRUE)
	for(var/datum/role/R in members)
		R.OnPostSetup()

// Destroy fraction and her members
/datum/faction/proc/Dismantle()
	for(var/datum/role/R in members)
		var/datum/game_mode/G = SSticker.mode
		G.orphaned_roles += R
		remove_role(R)
	qdel(objective_holder)
	var/datum/game_mode/G = SSticker.mode
	G.factions -= src
	qdel(src)

//Initialization proc, checks if the faction can be made given the current amount of players and/or other possibilites
/datum/faction/proc/can_setup(num_players)
	return TRUE

//For when you want your faction to have specific objectives (Vampire, suck blood. Cult, sacrifice the head of personnel's dog, etc.)
/datum/faction/proc/forgeObjectives()
	SHOULD_CALL_PARENT(TRUE)
	for(var/datum/role/R in members)
		R.forgeObjectives()

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
		to_chat(world, "if(!P.client || !P.mind)")
		return FALSE
	if(!required_pref)
		log_mode("[name] - [type] has no required_pref")
		return TRUE
	if(!P.client.prefs.be_role.Find(required_pref) || jobban_isbanned(P, required_pref) || role_available_in_minutes(P, required_pref) || jobban_isbanned(P, "Syndicate"))
		to_chat(world, "------[P]------")
		to_chat(world, "P.client.prefs.be_role.Find(required_pref) - [P.client.prefs.be_role.Find(required_pref)]")
		to_chat(world, "jobban_isbanned(P, required_pref) - [jobban_isbanned(P, required_pref)]")
		to_chat(world, "role_available_in_minutes(P, required_pref) - [role_available_in_minutes(P, required_pref)]")
		to_chat(world, "required_pref - [required_pref]")
		return FALSE
	return TRUE

// Basically, they are members of the new faction
/datum/faction/proc/HandleNewMind(datum/mind/M) //Used on faction creation
	SHOULD_CALL_PARENT(TRUE)
	for(var/datum/role/R in members)
		if(R.antag == M)
			to_chat(world, "HandleNewMind - [M.name] - if(R.antag == M)")
			return null
	if(M.GetRole(initial_role))
		log_mode("Mind already had a role of [initial_role]!")
		return null
	var/role_type = get_initrole_type()
	var/datum/role/newRole = new role_type(null, src, initial_role)
	if(!newRole.AssignToRole(M))
		newRole.Drop()
		to_chat(world, "HandleNewMind - [M.name] - if(!newRole.AssignToRole(M))")
		return null
	// !!! DEBUG CODE !!!
	to_chat(world, "newRole - [newRole]")
	return newRole

// Basically, these are the new members of the faction during the round
/datum/faction/proc/HandleRecruitedMind(datum/mind/M, override = FALSE)
	SHOULD_CALL_PARENT(TRUE)
	for(var/datum/role/R in members)
		if(R.antag == M)
			return R
	if(M.GetRole(late_role))
		log_mode("Mind already had a role of [late_role]!")
		return (M.GetRole(late_role))
	var/role_type = get_role_type()
	var/datum/role/R = new role_type(null, src, late_role) // Add him to our roles
	if(!R.AssignToRole(M, override))
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
		return FALSE
	var/datum/objective/O
	if(istype(objective_type, /datum/objective)) //Passed an actual objective
		O = objective_type
	else
		O = new objective_type
	if(objective_holder.AddObjective(O, null, src))
		return TRUE
	return FALSE

/datum/faction/proc/GetObjectives()
	return objective_holder.GetObjectives()

/datum/faction/proc/CheckObjectives()
	return objective_holder.GetObjectiveString(check_success = TRUE)

// Numbers!!
/datum/faction/proc/build_scorestat()
	return

// Numbers!!
/datum/faction/proc/get_scorestat()
	return ""

/datum/faction/proc/custom_result()
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
				score_results += "<font color='green'><B>\The [capitalize(name)] was successful!</B></font>"
				feedback_add_details("[ID]_success","SUCCESS")
				score["roleswon"]++
			else if (minor_victory)
				score_results += "<font color='orange'><B>\The [capitalize(name)] has achieved a minor victory.</B> [minorVictoryText()]</font>"
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

	antagonists_completion = list(list("faction" = ID, "html" = score_results))

	score_results += "<ul>"
	score_results += "<FONT size = 2><B>Members:</B></FONT><br>"
	var/i = 1
	for(var/datum/role/R in members)
		var/results = R.GetScoreboard()
		if(results)
			score_results += results
			score_results += "<br>"
		if(R.objectives.objectives.len <= 0)
			if (i < members.len)
				score_results += "<br>"
		i++
	score_results += "</ul>"
	score_results += "<br>"

	return score_results

/datum/faction/Topic(href, href_list)
	SHOULD_CALL_PARENT(TRUE)
	..()
	if(href_list["destroyfac"])
		if(!check_rights(R_ADMIN))
			message_admins("[usr] tried to destroy a faction without permissions.")
			return
		if(alert(usr, "Are you sure you want to destroy [capitalize(name)]?",  "Destroy Faction" , "Yes" , "No") != "Yes")
			return
		message_admins("[key_name(usr)] destroyed faction [capitalize(name)].")
		log_mode("[key_name(usr)] destroyed faction [capitalize(name)].")
		Dismantle()

/datum/faction/proc/IsSuccessful()
	var/win = TRUE
	if(objective_holder.objectives.len > 0)
		for (var/datum/objective/objective in objective_holder.GetObjectives())
			if(!objective.check_completion())
				win = FALSE
	return win

/datum/faction/proc/get_logo_icon(custom)
	if(custom)
		return icon('icons/misc/logos.dmi', custom)
	if(logo_state)
		return icon('icons/misc/logos.dmi', logo_state)
	return icon('icons/misc/logos.dmi', "unknown-logo")

/datum/faction/proc/GetFactionHeader() //Returns what will show when the factions objective completion is summarized
	var/icon/logo = get_logo_icon()
	var/header = {"<img src='data:image/png;base64, [icon2base64(logo)]' style='position:relative; top:10px;'> <FONT size = 2><B>[capitalize(name)]</B></FONT> <img src='data:image/png;base64,[icon2base64(logo)]' style='position:relative; top:10px;'>"}
	return header

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

	dat += "[fac_objects ? "" : "<br>"] - <b>Members</b> - "
	if(!members.len)
		dat += "<br><i>Unpopulated</i><br>"
	else
		for(var/datum/role/R in members)
			dat += "<br>"
			dat += R.AdminPanelEntry(TRUE)
	return dat

/datum/faction/process()
	for (var/datum/role/R in members)
		R.process()

/datum/faction/proc/stage(value)
	stage = value
	switch(value)
		if(FACTION_DEFEATED) //Faction was close to victory, but then lost. Send shuttle and end theme.
			sleep(5 SECONDS)
			SSshuttle.always_fake_recall = FALSE
			SSshuttle.online = TRUE
			OnPostDefeat()
			set_security_level("blue")
		if(FACTION_ENDGAME) //Faction is nearing victory. Set red alert and play endgame music.
			sleep(2 SECONDS)
			set_security_level("red")

/datum/faction/proc/OnPostDefeat()
	if(SSshuttle.location || SSshuttle.direction) //If traveling or docked somewhere other than idle at command, don't call.
		return
	SSshuttle.incall()
	SSshuttle.announce_crew_called.play()

/datum/faction/proc/check_win()
	return

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
