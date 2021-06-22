/datum/role
	// The name of the role (Traitor, Changeling)
	var/name
	// The unique ID of the role
	var/id

	// for atom_hud
	var/antag_hud_type
	var/antag_hud_name

	// Jobs that cannot be this antag.
	var/list/restricted_jobs = list()
	// Jobs that can only be this antag
	var/list/required_jobs = list()
	// Specie flags that for any amount of reasons can cause this role to not be available. TODO: use traits? ~Luduk
	var/list/restricted_species_flags = list()
	// The required preference for this role
	var/required_pref = ""
	// If this role is recruited to at roundstart, the person recruited is not assigned a position on station (Wizard, Nuke Op, Vox Raider)
	var/disallow_job = FALSE

	// Changes at start of round
	var/is_roundstart_role = FALSE
	// Logo of role
	var/logo_state

	// What faction this role is associated with.
	var/datum/faction/faction
	// The actual antag mind.
	var/datum/mind/antag
	// Where the objectives associated with the role will go.
	var/datum/objective_holder/objectives = new

	// Allows you to change the number of greeting messages for a role
	var/list/greets = list(GREET_DEFAULT, GREET_CUSTOM)

// Initializes the role. Adds the mind to the parent role, adds the mind to the faction, and informs the gamemode the mind is in a role.
/datum/role/New(datum/mind/M, datum/faction/fac, override = FALSE)
	SHOULD_CALL_PARENT(TRUE)
	// Link faction.
	faction = fac
	if(!faction)
		SSticker.mode.orphaned_roles += src
	else
		faction.add_role(src)

	if(M && !AssignToRole(M, override))
		Drop()
		return

	objectives.owner = M
	..()

/datum/role/proc/AssignToRole(datum/mind/M, override = FALSE, msg_admins = TRUE)
	if(!istype(M) && !override)
		log_mode("M is [M.type]!")
		return FALSE
	if(!CanBeAssigned(M) && !override)
		log_mode("[M.name] was to be assigned to [name] but failed CanBeAssigned!")
		return FALSE

	antag = M
	M.antag_roles[id] = src
	objectives.owner = M
	if(msg_admins)
		message_admins("[key_name(M)] is now \an [id].")
		log_mode("[key_name(M)] is now \an [id].")

	if (!OnPreSetup())
		return FALSE

	return TRUE

/datum/role/proc/RemoveFromRole(datum/mind/M, msg_admins = TRUE) //Called on deconvert
	antag.special_role = initial(antag.special_role)
	M.antag_roles[id] = null
	M.antag_roles.Remove(id)
	remove_antag_hud()
	if(msg_admins)
		message_admins("[key_name(M)] is <span class='danger'>no longer</span> \an [id].[M.current ? " [ADMIN_FLW(M.current)]" : ""]")
		log_mode("[key_name(M)] is <span class='danger'>no longer</span> \an [id].")
	antag = null

// Drops the antag mind from the parent role, informs the gamemode the mind now doesn't have a role, and deletes the role datum.
/datum/role/proc/Drop()
	if(antag)
		RemoveFromRole(antag)

	if(faction && (src in faction.members))
		faction.remove_role(src)

	if(!faction)
		SSticker.mode.orphaned_roles.Remove(src)

	qdel(src)

/datum/role/proc/handleRemovedObjective(datum/objective/O)
	SHOULD_CALL_PARENT(TRUE)
	ASSERT(O)
	if (!(O in objectives.objectives))
		log_mode("Trying to remove an objective ([O]) to role ([src]) who never had it.")
		return FALSE
	objectives.objectives -= O
	O.faction = null
	qdel(O)

// General sanity checks before assigning the person to the role, such as checking if they're part of the protected jobs or antags.
/datum/role/proc/CanBeAssigned(datum/mind/M)
	if(M.assigned_role in list("Velocity Officer", "Velocity Chief", "Velocity Medical Doctor"))
		return FALSE

	if(restricted_jobs.len > 0)
		if(M.assigned_role in restricted_jobs)
			return FALSE

	if(required_jobs.len > 0)
		if(!(M.assigned_role in required_jobs))
			return FALSE

	if(M?.current?.client)
		var/datum/preferences/prefs = M.current.client.prefs
		var/datum/species/S = all_species[prefs.species]

		if(!S.can_be_role(required_pref))
			return FALSE

		for(var/specie_flag in restricted_species_flags)
			if(S.flags[specie_flag])
				return FALSE

	if(is_type_in_list(src, M.antag_roles)) //No double double agent agent
		return FALSE

	return TRUE

// Return TRUE on success, FALSE on failure.
/datum/role/proc/OnPreSetup()
	antag.special_role = id

	if(disallow_job)
		var/datum/job/job = SSjob.GetJob(antag.assigned_role)
		if(job)
			job.current_positions--
		antag.assigned_role = "MODE"
	return TRUE

// Return TRUE on success, FALSE on failure.
/datum/role/proc/OnPostSetup(laterole = FALSE)
	SHOULD_CALL_PARENT(TRUE)
	add_antag_hud()
	SEND_SIGNAL(src, COMSIG_ROLE_POSTSETUP, laterole)

/datum/role/process()
	return

/datum/role/proc/check_win()
	return

// Create objectives here.
/datum/role/proc/forgeObjectives()
	SHOULD_CALL_PARENT(TRUE)
	if(config.objectives_disabled)
		return FALSE
	return TRUE

/datum/role/proc/AppendObjective(objective_type, duplicates = 0)
	if(!duplicates && locate(objective_type) in objectives)
		return null
	var/datum/objective/O
	if(istype(objective_type, /datum/objective)) //Passed an actual objective
		O = objective_type
	else
		O = new objective_type
	if(objectives.AddObjective(O, antag))
		return O
	return null

/datum/role/proc/get_logo_icon(custom)
	if(custom)
		return icon('icons/misc/logos.dmi', custom)
	if(logo_state)
		return icon('icons/misc/logos.dmi', logo_state)
	return icon('icons/misc/logos.dmi', "unknown-logo")

/datum/role/proc/AdminPanelEntry(show_logo = FALSE, datum/mind/mind)
	var/icon/logo = get_logo_icon()
	var/mob/M = antag?.current
	if (M)
		return {"[show_logo ? "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> " : "" ]
	[name] <a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]/[M.key]</a>[M.client ? "" : " <i> - (logged out)</i>"][M.stat == DEAD ? " <b><font color=red> - (DEAD)</font></b>" : ""]
	 - <a href='?src=\ref[usr];priv_msg=\ref[M]'>(PM)</a>
	 - <a href='?_src_=holder;traitor=\ref[M]'>(TP)</a>
	 - <a href='?_src_=holder;adminplayerobservejump=\ref[M]'>JMP</a>"}
	else if(antag)
		return {"[show_logo ? "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> " : "" ]
	[name] [antag.name]/[antag.key]<b><font color=red> - (DESTROYED)</font></b>
	 - <a href='?src=\ref[usr];priv_msg=\ref[M]'>(PM)</a>
	 - <a href='?_src_=holder;traitor=\ref[M]'>(TP)</a>
	 - <a href='?_src_=holder;adminplayerobservejump=\ref[M]'>JMP</a>"}


/datum/role/proc/Greet(greeting = GREET_DEFAULT, custom)
	var/icon/logo = get_logo_icon()
	switch(greeting)
		if (GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <B>You are \a [name][faction ? ", a member of the [faction.GetFactionHeader()]":"."]</B>")
			to_chat(antag.current, "[custom]")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <B>You are \a [name][faction ? ", a member of the [faction.GetFactionHeader()]":"."]</B>")

	return TRUE

// Things to do to the *old* body prior to the mind transfer.
/datum/role/proc/PreMindTransfer(mob/living/old_character)
	return

// Things to do to the *new* body after the mind transfer is completed.
/datum/role/proc/PostMindTransfer(mob/living/new_character, mob/living/old_character)
	return

/datum/role/proc/GetFaction()
	return faction

/datum/role/proc/IsSuccessful()
	if(objectives.objectives.len > 0)
		for (var/datum/objective/objective in objectives.GetObjectives())
			if(!objective.check_completion())
				return FALSE
	return TRUE

/datum/role/proc/printplayerwithicon(datum/mind/mind)
	var/text = ""
	var/mob/M = mind.current
	if(!M)
		var/icon/sprotch = icon('icons/effects/blood.dmi', "gibbearcore")
		text += "<img src='data:image/png;base64,[icon2base64(sprotch)]' style='position:relative; top:10px;'/>"
	else
		var/icon/flat = getFlatIcon(M, SOUTH, exact = 1)
		if(M.stat == DEAD)
			if (!istype(M, /mob/living/carbon/brain))
				flat.Turn(90)
			var/icon/ded = icon('icons/effects/blood.dmi', "floor_old")
			ded.Blend(flat, ICON_OVERLAY)
			end_icons += ded
		else
			end_icons += flat
		var/tempstate = end_icons.len
		text += "<img src='logo_[tempstate].png' style='position:relative; top:10px;'/>" // change to base64?

	var/icon/logo = get_logo_icon()
	text += "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative;top:10px;'/><b>[mind.key]</b> was <b>[mind.name]</b> ("
	if(M)
		if(M.stat == DEAD)
			text += "died"
		else
			text += "survived"
		if(M.real_name != mind.name)
			text += " as <b>[M.real_name]</b>"
	else
		text += "body destroyed"
	text += ")"

	return text

/datum/role/proc/Declare()
	var/win = TRUE
	var/text = ""

	if(!antag)
		text += "<br> Has been deconverted, and is now a [pick("loyal", "effective", "nominal")] [pick("dog", "pig", "underdog", "servant")] of [pick("corporation", "NanoTrasen")]"
		win = FALSE
		return text

	text = printplayerwithicon(antag)

	if(objectives.objectives.len > 0)
		var/count = 1
		text += "<ul>"
		for(var/datum/objective/objective in objectives.GetObjectives())
			var/successful = objective.calculate_completion()
			text += "<B>Objective #[count]</B>: [objective.explanation_text] [objective.completion_to_string()]"
			feedback_add_details("[id]_objective","[objective.type]|[objective.completion_to_string(FALSE)]")
			if(!successful) //If one objective fails, then you did not win.
				win = FALSE
			if (count < objectives.objectives.len)
				text += "<br>"
			count++
		if (!faction)
			if(win)
				text += "<br><font color='green'><B>\The [name] was successful!</B></font>"
				feedback_add_details("[id]_success","SUCCESS")
				score["roleswon"]++
			else
				text += "<br><font color='red'><B>\The [name] has failed.</B></font>"
				feedback_add_details("[id]_success","FAIL")
		text += "</ul>"

	antagonists_completion += list(list("role" = id, "html" = text))

	return text

/datum/role/proc/extraPanelButtons(datum/mind/M)
	var/signal_buttons = SEND_SIGNAL(src, COMSIG_ROLE_PANELBUTTONS)
	return signal_buttons ? signal_buttons : ""

/datum/role/proc/GetMemory(datum/mind/M, admin_edit = FALSE)
	var/text = ""
	if (faction)
		text += "<br>[faction.GetFactionHeader()]"

	if (admin_edit)
		if (faction)
			text += "<a href='?src=\ref[M];role_edit=\ref[src];remove_from_faction=1'>(remove from faction)</a>[faction.extraPanelButtons(M)]"
		else
			text += "<a href='?src=\ref[M];role_edit=\ref[src];add_to_faction=1'> - (add to faction) - </a>"

	text += "<br>"
	if(faction)
		text += "<ul>"
		if(faction.objective_holder)
			if(faction.objective_holder.objectives.len)
				text += "<ul><b>Faction objectives:</b><br>"
			text += faction.objective_holder.GetObjectiveString(FALSE, admin_edit, M)
			if(faction.objective_holder.objectives.len)
				text += "</ul>"

	var/icon/logo = get_logo_icon()
	text += "<b><img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> [name]</b>"
	if (admin_edit)
		text += " - <a href='?src=\ref[M];role_edit=\ref[src];remove_role=1'>(remove)</a> - <a href='?src=\ref[M];greet_role=\ref[src]'>(greet)</a>[extraPanelButtons(M)]"

	if(objectives.objectives.len)
		text += "<br><ul><b>Personal objectives:</b><br>"
	else
		text += "<br>No objectives available<br>"
	text += objectives.GetObjectiveString(FALSE, admin_edit, M, src)
	if(objectives.objectives.len)
		text += "</ul>"

	if(faction)
		text += "</ul>"

	text += "<HR>"
	return text

/datum/role/proc/GetScoreboard()
	SHOULD_CALL_PARENT(TRUE)
	var/dat = Declare()
	var/signal_buttons = SEND_SIGNAL(src, COMSIG_ROLE_GETSCOREBOARD)
	dat += signal_buttons ? signal_buttons : ""
	return dat

// DO NOT OVERRIDE
/datum/role/Topic(href, href_list)
	if(!check_rights(R_ADMIN))
		to_chat(usr, "You are not an admin.")
		return FALSE

	if(!href_list["mind"])
		to_chat(usr, "<span class='warning'>BUG: mind variable not specified in Topic([href])!</span>")
		return TRUE

	var/datum/mind/M = locate(href_list["mind"])
	if(!M)
		return
	RoleTopic(href, href_list, M, check_rights(R_ADMIN))
	SEND_SIGNAL(src, COMSIG_ROLE_ROLETOPIC, href, href_list, M, check_rights(R_ADMIN))

	M.edit_memory() // Update window

// USE THIS INSTEAD (global)
/datum/role/proc/RoleTopic(href, href_list, datum/mind/M, admin_auth)

/datum/role/proc/ShuttleDocked(state)
	if(objectives.objectives.len)
		for(var/datum/objective/O in objectives.objectives)
			O.ShuttleDocked(state)

/datum/role/proc/AnnounceObjectives()
	if(!antag || !antag.current)
		return

	var/text = ""
	if(faction)
		text += "[faction.GetFactionHeader()]<br>"
		if(faction.objective_holder)
			if(faction.objective_holder.objectives.len)
				text += "<ul><b>Faction objectives:</b><br>"
				var/obj_count = 1
				for(var/datum/objective/O in faction.objective_holder.objectives)
					text += "<b>Objective #[obj_count++]</b>: [O.explanation_text]<br>"
				text += "</ul>"

	if(objectives.objectives.len)
		var/icon/logo = get_logo_icon()
		text += "<b><img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> [name]</b>"
		text += "<ul><b>[capitalize(name)] objectives:</b><br>"
		var/obj_count = 1
		for(var/datum/objective/O in objectives.objectives)
			text += "<b>Objective #[obj_count++]</b>: [O.explanation_text]<br>"
		text += "</ul>"
	to_chat(antag.current, text)

// -- Custom reagent reaction for your antag - now in a (somewhat) maintable fashion

/datum/role/proc/handle_reagent(reagent_id)
	return

/datum/role/proc/handle_splashed_reagent(reagent_id)
	return

// What do they display on the player StatPanel ?
/datum/role/proc/StatPanel()
	return ""

// Adds the specified antag hud to the player. Usually called in an antag datum file
/datum/role/proc/add_antag_hud(custom_name)
	if(antag_hud_type && (antag_hud_name || custom_name))
		var/name = antag_hud_name ? antag_hud_name :custom_name
		var/datum/atom_hud/antag/hud = global.huds[antag_hud_type]
		hud.join_hud(antag.current)
		set_antag_hud(antag.current, name)

// Removes the specified antag hud from the player. Usually called in an antag datum file
/datum/role/proc/remove_antag_hud()
	if(antag_hud_type && antag_hud_name)
		var/datum/atom_hud/antag/hud = global.huds[antag_hud_type]
		hud.leave_hud(antag.current)
		set_antag_hud(antag.current, null)
