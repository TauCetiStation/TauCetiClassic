/**
* Used in Mixed Mode, also simplifies equipping antags for other gamemodes and
* for the role panel.

		###VARS###
	===Static Vars===
	@id: String: The unique ID of the role
	@name: String: The name of the role (Traitor, Changeling)
	@plural_name: String: The name of a multitude of this role (Traitors, Changelings)
	@flags: BITFLAGS: Various flags associated with the role. (NEED_HOST means a host is required for the role.)
	@protection_jobs: list(String): Jobs that can not have this role.
	@protected_antags: list(String): Antagonists that can not have this role. (Cultists can't be wizards)
	@protected_host_roles: list(String): Antag IDs that can not be the host of this role (Wizards can have apprentices, but apprentices can't have apprentices)
	@disallow_job: Boolean: If this role is recruited to at roundstart, the person recruited is not assigned a position on station (Wizard, Nuke Op, Vox Raider)
	@min_players: int: minimum amount of players that can have this role (4 cultists)
	@max_players: int: maximum amount of players that can have this role (No more than 5 nuclear operatives)
	@faction: Faction: What faction this role is associated with.
	@minds: List(mind): The minds associated with this role (Wizards and their apprentices, Nuclear operatives and their commander)
	@antag: mind: The actual antag mind.
	@host: mind: The host, used in such things like cortical borers (Where the antag and host mind can swap at any time)
	@objectives: Objective Holder: Where the objectives associated with the role will go.

		###PROCS###
	@New(mind/M = null, role/parent=null,faction/F=null):
		initializes the role. Adds the mind to the parent role, adds the mind to the faction, and informs the gamemode the mind is in a role.
	@Drop():
		Drops the antag mind from the parent role, informs the gamemode the mind now doesn't have a role, and deletes the role datum.
	@CanBeAssigned(Mind)
		General sanity checks before assigning the person to the role, such as checking if they're part of the protected jobs or antags.
	@PreMindTransfer(Old_character, Mob/Living)
		Things to do to the *old* body prior to the mind transfer.
	@PostMindTransfer(New_character, Mob/Living, Old_character, Mob/Living)
		Things to do to the *new* body after the mind transfer is completed.
*/

#define ROLE_MIXABLE   			1 // Can be used in mixed mode
#define ROLE_NEED_HOST 			2 // Antag needs a host/partner
#define ROLE_ADDITIVE  			4 // Antag can be added on top of another antag.
#define ROLE_GOOD     			8 // Role is not actually an antag. (Used for GetAllBadMinds() etc)

/datum/role
	//////////////////////////////
	// "Static" vars
	//////////////////////////////
	// Unique ID of the definition.
	var/id = null

	// Displayed name of the antag type
	var/name = null

	var/plural_name = null

	// role name assigned to the antag's potential uplink
	var/name_for_uplink = null

	// Various flags and things.
	var/flags = 0

	// Jobs that cannot be this antag.
	var/list/restricted_jobs = list()

	var/protected_traitor_prob = PROB_PROTECTED_REGULAR

	// Jobs that can only be this antag
	var/list/required_jobs=list()

	// Specie flags that for any amount of reasons can cause this role to not be available.
	// TO-DO: use traits? ~Luduk
	var/list/restricted_species_flags = list()

	// Antag IDs that cannot be used with this antag type. (cultists can't be wizard, etc)
	var/list/protected_antags=list()

	// If set, sets special_role to this
	var/special_role=null

	// The required preference for this role
	var/required_pref = ""

	var/is_roundstart_role = FALSE

	// If set, assigned role is set to MODE to prevent job assignment.
	var/disallow_job=0

	var/min_players=0
	var/max_players=0

	// Assigned faction.
	var/datum/faction/faction = null

	var/list/minds = list()

	//////////////////////////////
	// Local
	//////////////////////////////
	// Actual antag
	var/datum/mind/antag=null
	var/destroyed = FALSE //Whether or not it has been gibbed

	var/list/uplink_items_bought = list() //migrated from mind, used in GetScoreboard()
	var/list/artifacts_bought = list() //migrated from mind

	// The host (set if NEED_HOST)
	var/datum/mind/host=null

	// Objectives
	var/datum/objective_holder/objectives=new

	var/logo_state

	var/list/greets = list(GREET_DEFAULT,GREET_CUSTOM)

	var/list/current_powers = list()
	var/list/available_powers = list()		//holds instances of each power
	var/powerpoints = 0

	// This datum represents all data that is exported to the statistics file at the end of the round.
	// If you want to store faction-specific data as statistics, you'll need to define your own datum.
	// See dynamic_stats.dm
	//var/datum/stat/role/stat_datum = null
	//var/datum/stat/role/stat_datum_type = /datum/stat/role

/datum/role/New(datum/mind/M, datum/faction/fac=null, new_id, override = FALSE)
	SHOULD_CALL_PARENT(TRUE)
	// Link faction.
	faction=fac
	if(!faction)
		SSticker.mode.orphaned_roles += src
	else
		faction.add_role(src)

	if(new_id)
		id = new_id

	if(M && !AssignToRole(M, override))
		Drop()
		return FALSE

	if(!plural_name)
		plural_name="[name]s"

	objectives.owner = M
	//stat_datum = new stat_datum_type()
	..()
	return TRUE

/datum/role/proc/AssignToRole(datum/mind/M, override = 0, msg_admins = TRUE)
	if(!istype(M) && !override)
		stack_trace("M is [M.type]!")
		return FALSE
	if(!CanBeAssigned(M) && !override)
		stack_trace("[M.name] was to be assigned to [name] but failed CanBeAssigned!")
		return FALSE

	antag = M
	M.antag_roles.Add(id)
	M.antag_roles[id] = src
	objectives.owner = M
	if(msg_admins)
		message_admins("[key_name(M)] is now \an [id].[M.current ? " [ADMIN_JMP(M.current)]" : ""]")

	if (!OnPreSetup())
		return FALSE
	return TRUE

/datum/role/proc/RemoveFromRole(datum/mind/M, msg_admins = TRUE) //Called on deconvert
	M.antag_roles[id] = null
	M.antag_roles.Remove(id)
	if(msg_admins)
		message_admins("[key_name(M)] is <span class='danger'>no longer</span> \an [id].[M.current ? " [ADMIN_JMP(M.current)]" : ""]")
	antag = null

// Destroy this role
/datum/role/proc/Drop()
	if(faction && (src in faction.members))
		faction.members.Remove(src)

	if(!faction)
		SSticker.mode.orphaned_roles.Remove(src)

	if(antag)
		RemoveFromRole(antag)
	qdel(src)

// Scaling, should fuck with min/max players.
// Return TRUE on success, FALSE on failure.
/datum/role/proc/calculateRoleNumbers()
	return TRUE

// General sanity checks before assigning antag.
// Return TRUE on success, FALSE on failure.
/datum/role/proc/CanBeAssigned(datum/mind/M)
	if(restricted_jobs.len > 0)
		if(M.assigned_role in restricted_jobs)
			return FALSE

	if(protected_antags.len > 0)
		for(var/forbidden_role in protected_antags)
			if(forbidden_role in M.antag_roles)
				return FALSE

	if(required_jobs.len > 0)
		if(!(M.assigned_role in required_jobs))
			return FALSE

	var/datum/preferences/prefs = M.current.client.prefs
	var/datum/species/S = all_species[prefs.species]

	if(!S.can_be_role(name))
		return FALSE

	for(var/specie_flag in restricted_species_flags)
		if(S.flags[specie_flag])
			return FALSE

	if(is_type_in_list(src, M.antag_roles)) //No double double agent agent
		return FALSE
	return TRUE

// Return TRUE on success, FALSE on failure.
/datum/role/proc/OnPreSetup()
	if(special_role)
		antag.special_role=special_role
	if(disallow_job)
		var/datum/job/job = SSjob.GetJob(antag.assigned_role)
		if(job)
			job.current_positions--
		antag.assigned_role="MODE"
	return TRUE

// Return TRUE on success, FALSE on failure.
/datum/role/proc/OnPostSetup(laterole = FALSE)
	return TRUE

/datum/role/proc/update_antag_hud()
	return

/datum/role/process()
	return

/datum/role/proc/check_win()
	return

// Create objectives here.
/datum/role/proc/ForgeObjectives()
	return

/datum/role/proc/AppendObjective(objective_type,duplicates=0)
	if(!duplicates && locate(objective_type) in objectives)
		return FALSE
	var/datum/objective/O
	if(istype(objective_type, /datum/objective)) //Passed an actual objective
		O = objective_type
	else
		O = new objective_type
	if(objectives.AddObjective(O, antag))
		return TRUE
	return FALSE

/datum/role/proc/ReturnObjectivesString(check_success = FALSE, check_name = TRUE)
	var/dat = ""
	if(check_name)
		var/datum/mind/N = antag
		dat += "<br>[N] - [N.name]<br>"
	dat += objectives.GetObjectiveString(check_success)
	return dat

/datum/role/proc/AdminPanelEntry(show_logo = FALSE,datum/admins/A)
	var/icon/logo = icon('icons/misc/logos.dmi', logo_state)
	if(!antag || !antag.current)
		return
	var/mob/M = antag.current
	if (M)
		return {"[show_logo ? "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> " : "" ]
	[name] <a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]/[M.key]</a>[M.client ? "" : " <i> - (logged out)</i>"][M.stat == DEAD ? " <b><font color=red> - (DEAD)</font></b>" : ""]
	 - <a href='?src=\ref[usr];priv_msg=\ref[M]'>(priv msg)</a>
	 - <a href='?_src_=holder;traitor=\ref[M]'>(role panel)</a>"}
	else
		return {"[show_logo ? "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> " : "" ]
	[name] [antag.name]/[antag.key]<b><font color=red> - (DESTROYED)</font></b>
	 - <a href='?src=\ref[usr];priv_msg=\ref[M]'>(priv msg)</a>
	 - <a href='?_src_=holder;traitor=\ref[M]'>(role panel)</a>"}


/datum/role/proc/Greet(greeting,custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/misc/logos.dmi', logo_state)
	switch(greeting)
		if (GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <B>[custom]</B>")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <B>You are \a [name][faction ? ", a member of the [faction.GetObjectivesMenuHeader()]":"."]</B>")

/datum/role/proc/PreMindTransfer(mob/living/old_character)
	return

/datum/role/proc/PostMindTransfer(mob/living/new_character, mob/living/old_character)
	return

/datum/role/proc/GetFaction()
	return faction

/datum/role/proc/printplayerwithicon(mob/M)
	var/text = ""
	if(!M)
		var/icon/sprotch = icon('icons/effects/blood.dmi', "sprotch")
		text += "<img src='data:image/png;base64,[icon2base64(sprotch)]' style='position:relative; top:10px;'/>"
	else
		var/icon/flat = getFlatIcon(M, SOUTH, 0, 1)
		if(M.stat == DEAD)
			if (!istype(M, /mob/living/carbon/brain))
				flat.Turn(90)
			var/icon/ded = icon('icons/effects/blood.dmi', "floor1-old")
			ded.Blend(flat,ICON_OVERLAY)
			end_icons += ded
		else
			end_icons += flat
		var/tempstate = end_icons.len
		text += "<img src='logo_[tempstate].png' style='position:relative; top:10px;'/>"

	var/icon/logo = icon('icons/misc/logos.dmi', logo_state)
	text += "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative;top:10px;'/><b>[antag.key]</b> was <b>[antag.name]</b> ("
	if(M)
		if(!antag.GetRole(id))
			text += "removed"
		else if(M.stat == DEAD)
			text += "died"
		else
			text += "survived"
		if(antag.current.real_name != antag.name)
			text += " as <b>[antag.current.real_name]</b>"
	else
		text += "body destroyed"
	text += ")"

	return text

/datum/role/proc/Declare()
	var/win = TRUE
	var/text = ""
	var/mob/M = antag.current

	if(!M)
		win = FALSE

	text = printplayerwithicon(M)

	if(objectives.objectives.len > 0)
		var/count = 1
		text += "<ul>"
		for(var/datum/objective/objective in objectives.GetObjectives())
			var/successful = objective.check_completion()
			text += "<B>Objective #[count]</B>: [objective.explanation_text] [successful ? "<font color='green'><B>Success!</B></font>" : "<font color='red'>Fail.</font>"]"
			feedback_add_details("[id]_objective","[objective.type]|[successful ? "SUCCESS" : "FAIL"]")
			if(!successful) //If one objective fails, then you did not win.
				win = FALSE
			if (count < objectives.objectives.len)
				text += "<br>"
			count++
		if (!faction)
			if(win)
				text += "<br><font color='green'><B>\The [name] was successful!</B></font>"
				feedback_add_details("[id]_success","SUCCESS")
			else
				text += "<br><font color='red'><B>\The [name] has failed.</B></font>"
				feedback_add_details("[id]_success","FAIL")
		text += "</ul>"

	stat_collection.add_role(src, win)

	return text

/datum/role/proc/extraPanelButtons()
	var/dat = ""
	//example:
	//dat = " - <a href='?src=\ref[M];spawnpoint=\ref[src]'>(move to spawn)</a>"
	return dat

/datum/role/proc/GetMemory(datum/mind/M, admin_edit = FALSE)
	var/icon/logo = icon('icons/misc/logos.dmi', logo_state)
	var/text = "<b><img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> [name]</b>"
	if (admin_edit)
		text += " - <a href='?src=\ref[M];role_edit=\ref[src];remove_role=1'>(remove)</a> - <a href='?src=\ref[M];greet_role=\ref[src]'>(greet)</a>[extraPanelButtons()]"
	text += "<br>faction: "
	if (faction)
		text += faction.name
	else
		text += "<i>none</i> <br/>"
	if (admin_edit)
		text += " - "
		if (faction)
			text += "<a href='?src=\ref[M];role_edit=\ref[src];remove_from_faction=1'>(remove)</a>"
		else
			text += "<a href='?src=\ref[M];role_edit=\ref[src];add_to_faction=1'>(add)</a>"
	text += "<br>"
	if (objectives.objectives.len)
		text += "<b>personal objectives</b><br><ul>"
	text += objectives.GetObjectiveString(0,admin_edit,M, src)
	if (objectives.objectives.len)
		text += "</ul>"
	if (faction && faction.objective_holder)
		if (faction.objective_holder.objectives.len)
			if (objectives.objectives.len)
				text += "<br>"
			text += "<b>faction objectives</b><ul>"
			text += "<br/>"
		text += faction.objective_holder.GetObjectiveString(0,admin_edit,M)
		if (faction.objective_holder.objectives.len)
			text += "</ul>"
	text += "<br>"
	return text

/datum/role/proc/GetScoreboard()
	return Declare()

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

// USE THIS INSTEAD (global)
/datum/role/proc/RoleTopic(href, href_list, datum/mind/M, admin_auth)

/datum/role/proc/ShuttleDocked(state)
	if(objectives.objectives.len)
		for(var/datum/objective/O in objectives.objectives)
			O.ShuttleDocked(state)

/datum/role/proc/AnnounceObjectives()
	var/text = ""
	if (objectives.objectives.len)
		text += "<b>[capitalize(name)] objectives:</b><ul>"
		var/obj_count = 1
		for(var/datum/objective/O in objectives.objectives)
			text += "<b>Objective #[obj_count++]</b>: [O.explanation_text]<br>"
		text += "</ul>"
	if (faction && faction.objective_holder)
		if (faction.objective_holder.objectives.len)
			if (objectives.objectives.len)
				text += "<br>"
			text += "<b>Faction objectives:</b><ul>"
			var/obj_count = 1
			for(var/datum/objective/O in faction.objective_holder.objectives)
				text += "<b>Objective #[obj_count++]</b>: [O.explanation_text]<br>"
			text += "</ul>"
	to_chat(antag.current, text)

/datum/role/proc/GetMemoryHeader()
	return name

// -- Custom reagent reaction for your antag - now in a (somewhat) maintable fashion

/datum/role/proc/handle_reagent(reagent_id)
	return

/datum/role/proc/handle_splashed_reagent(reagent_id)
	return

//Does the role have special clothing restrictions?
/datum/role/proc/can_wear(obj/item/clothing/C)
	return TRUE

// What do they display on the player StatPanel ?
/datum/role/proc/StatPanel()
	return ""