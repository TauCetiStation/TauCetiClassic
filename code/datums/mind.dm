/*	Note from Carnie:
		The way datum/mind stuff works has been changed a lot.
		Minds now represent IC characters rather than following a client around constantly.

	Guidelines for using minds properly:

	-	When creating a new mob for an existing IC character (e.g. cloning a dead guy or borging a brain of a human)
		the existing mind of the old mob should be transfered to the new mob like so:

			mind.transfer_to(new_mob)

	-	You must not assign key= or ckey= after transfer_to() since the transfer_to transfers the client for you.
		By setting key or ckey explicitly after transfering the mind with transfer_to you will cause bugs like DCing
		the player.

	-	IMPORTANT NOTE 2, if you want a player to become a ghost, use mob.ghostize() It does all the hard work for you.

	-	When creating a new mob which will be a new IC character (e.g. putting a shade in a construct or randomly selecting
		a ghost to become a xeno during an event). Simply assign the key or ckey like you've always done.

			new_mob.key = key

		The Login proc will handle making a new mob for that mobtype (including setting up stuff like mind.name). Simple!
		However if you want that mind to have any special properties like being a traitor etc you will have to do that
		yourself.

*/

/datum/mind
	var/key
	var/name				//replaces mob/var/original_name
	var/mob/current
	var/mob/original	//TODO: remove.not used in any meaningful way ~Carn. First I'll need to tweak the way silicon-mobs handle minds.
	var/active = 0

	var/memory

	var/assigned_role
	var/special_role

	var/holy_role = NONE

	var/protector_role = 0 //If we want force player to protect the station
	var/hulkizing = FALSE //Hulk before? If TRUE - cannot activate hulk mutation anymore.

	var/role_alt_title

	var/datum/job/assigned_job

	var/list/antag_roles = list()		// All the antag roles we have.

	var/antag_hud_icon_state = null //this mind's ANTAG_HUD should have this icon_state
	var/datum/atom_hud/antag/antag_hud = null //this mind's antag HUD

	var/list/spell_list = list()

	// the world.time since the mob has been brigged, or -1 if not at all
	var/brigged_since = -1

	//skills
	var/datum/skills/skills = new

	var/creation_time = 0 //World time when this datum was New'd. Useful to tell how long since a character spawned
	var/creation_roundtime

/datum/mind/New(key)
	src.key = key
	creation_time = world.time
	creation_roundtime = roundduration2text()

/datum/mind/proc/transfer_to(mob/new_character)
	for(var/role in antag_roles)
		var/datum/role/R = antag_roles[role]
		R.PreMindTransfer(current)

	if(current)					//remove ourself from our old body's mind variable
		SStgui.on_transfer(current, new_character)
		current.mind = null

	if(new_character.mind)		//remove any mind currently in our new body's mind variable
		new_character.mind.set_current(null)

	nanomanager.user_transferred(current, new_character) // transfer active NanoUI instances to new user

	transfer_actions(new_character)

	var/mob/old_character = current
	current = new_character		//link ourself to our new body
	new_character.mind = src	//and link our new body to ourself

	var/datum/atom_hud/antag/hud_to_transfer = antag_hud
	transfer_antag_huds(hud_to_transfer)

	if(old_character?.my_religion)
		old_character.my_religion.add_member(current, holy_role)

	for(var/role in antag_roles)
		var/datum/role/R = antag_roles[role]
		R.PostMindTransfer(new_character, old_character)

	old_character.logout_reason = LOGOUT_SWAP
	if(active)
		new_character.logout_reason = LOGOUT_SWAP
		new_character.key = key		//now transfer the key to link the client to our new body

/datum/mind/proc/get_ghost(even_if_they_cant_reenter, ghosts_with_clients)
	for(var/mob/dead/observer/G in (ghosts_with_clients ? global.player_list : global.dead_mob_list))
		if(G.mind == src)
			if(G.can_reenter_corpse || even_if_they_cant_reenter)
				return G
			break

/datum/mind/proc/store_memory(new_text)
	memory += "[new_text]<BR>"

/datum/mind/proc/show_memory(mob/recipient)
	var/output = "<B>[current.real_name]'s Memory</B><HR>"
	output += memory

	if(antag_roles.len)
		for(var/role in antag_roles)
			var/datum/role/R = antag_roles[role]
			output += R.GetMemory(src, FALSE) //preventing edits

	var/datum/browser/popup = new(recipient, "window=memory")
	popup.set_content(output)
	popup.open()

/datum/mind/proc/edit_memory()
	if(!SSticker || !SSticker.mode)
		tgui_alert(usr, "Not before round-start!", "Alert")
		return

	var/out = "<B>[name]</B>[(current&&(current.real_name!=name))?" (as [current.real_name])":""]<br>"
	out += "Mind currently owned by key: [key] [active?"(synced)":"(not synced)"]<br>"
	out += "Assigned role: [assigned_role]. <a href='?src=\ref[src];job_edit=1'>Edit</a><br>"

	var/list/sections = list(
		"implant",
		"prefs",
		"roles",
	)

	var/text = ""
	var/mob/living/carbon/human/H = current
	if (ishuman(current) || ismonkey(current))
		/** Impanted**/
		if(ishuman(current))
			if(H.ismindshielded())
				text += "Mind Shield Implant:<a href='?src=\ref[src];implant=m_remove'>Remove</a>|<b>Implanted</b></br>"
			else
				text += "Mind Shield Implant:<b>No Implant</b>|<a href='?src=\ref[src];implant=m_add'>Implant him!</a></br>"

			if(H.isloyal())
				text += "Loyalty Implant:<a href='?src=\ref[src];implant=remove'>Remove</a>|<b>Implanted</b></br>"
			else
				text += "Loyalty Implant:<b>No Implant</b>|<a href='?src=\ref[src];implant=add'>Implant him!</a></br>"
		else
			text = "Loyalty Implant: Don't implant that monkey!</br>"
		sections["implant"] = text

	if(current && current.client)
		text = "Desires roles: [current.client.GetRolePrefs()]<BR>"
	else
		text = "Body destroyed or logged out."
	sections["roles"] = text

	text = "<font size='5'><b>Roles and Factions</b></font><BR>"
	if(!antag_roles.len)
		text += "<i>This mob has no roles.</i><br>"
	else
		for(var/role in antag_roles)
			var/datum/role/R = antag_roles[role]
			text += R.GetMemory(src, TRUE) //allowing edits

	text += "<br><a href='?src=\ref[src];add_role=1'>(add a new role)</a>"
	sections["prefs"] = text

	for(var/i in sections)
		if(sections[i])
			out += sections[i]+"<br>"

	out += "<b>Memory:</b><br>"
	out += memory
	out += "<br><a href='?src=\ref[src];memory_edit=1'>Edit memory</a><br>"
	out += "<a href='?src=\ref[src];refresh=1'>Refresh</a>"

	var/datum/browser/popup = new(usr, "window=edit_memory", "Memory", 700, 700)
	popup.set_content(out)
	popup.open()

/datum/mind/proc/edit_skills()
	if(!SSticker || !SSticker.mode)
		tgui_alert(usr, "Not before round-start!", "Alert")
		return
	var/out = "<B>[name]</B>[(current && (current.real_name != name)) ? " (as [current.real_name])": ""]<br>"
	out += "Mind currently owned by key: [key] [active ? "(synced)" : "(not synced)"]<br>"

	out +="<B>Available skillsets:</B><br>"
	if(!length(skills.available_skillsets))
		out +="<i>This mob has no skillsets.</i><br>"
	for(var/datum/skillset/skillset in skills.available_skillsets)
		out +="<i>[skillset]</i><a href='?src=\ref[src];delete_skillset=[skillset]'>-</a><br>"
	out += "<B>Maximum skill values:</B><br><table>"
	var/sorted_max = list()
	for(var/skill_type in all_skills)
		sorted_max[skill_type] = skills.get_max(skill_type)
	sorted_max = sortTim(sorted_max, GLOBAL_PROC_REF(cmp_numeric_dsc), TRUE)
	var/row = 0
	for(var/skill_type in sorted_max)
		var/datum/skill/skill = all_skills[skill_type]
		if(row % 3 == 0)
			out += "</tr><tr>"
		var/rank_name = skill.custom_ranks[skills.get_max(skill.type) + 1]
		out +="<td>[skill]:  [rank_name] ([skills.get_max(skill.type)])</td>"
		row++
	out +="</table>"
	out += "<br><a href='?src=\ref[src];add_skillset=1'>Add skillset</a><br>"
	out += "<a href='?src=\ref[src];maximize_skills=1'>Set current skills equal to available skills</a><br>"
	out += "<a href='?src=\ref[src];add_max=1'>Add maximal skillset</a><br>"
	out += "<a href='?src=\ref[src];refresh=2'>Refresh</a>"
	var/datum/browser/popup = new(usr, "window=edit_skills", "Skills", 700, 700)
	popup.set_content(out)
	popup.open()

/datum/mind/Topic(href, href_list)
	if(href_list["add_key_memory"])
		current?.add_key_memory()
		return

	if(!check_rights(R_ADMIN))
		return

	if (href_list["job_edit"])
		var/new_job = input("Select new job", "Assigned job", assigned_role) as null|anything in get_all_jobs()
		if (!new_job)
			return
		assigned_role = new_job

	if (href_list["greet_role"])
		var/datum/role/R = locate(href_list["greet_role"])
		var/chosen_greeting
		var/custom_greeting
		if (R.greets.len)
			chosen_greeting = input("Choose a greeting", "Assigned role", null) as null|anything in R.greets
			if (chosen_greeting == GREET_CUSTOM)
				custom_greeting = input("Choose a custom greeting", "Assigned role", "") as null|text

			if ((chosen_greeting && chosen_greeting != GREET_CUSTOM) || (chosen_greeting == GREET_CUSTOM && custom_greeting))
				R.Greet(chosen_greeting,custom_greeting)

	if (href_list["add_role"])
		var/list/available_roles = list()
		for(var/role in subtypesof(/datum/role))
			var/datum/role/R = role
			if (initial(R.id) && !(initial(R.id) in antag_roles))
				available_roles[initial(R.id)] = R

		if(!available_roles.len)
			tgui_alert(usr, "This mob already has every available roles! Geez, calm down!", "Assigned role")
			return

		var/new_role = input("Select new role", "Assigned role", null) as null|anything in available_roles
		if (!new_role)
			return

		var/joined_faction
		var/list/all_factions = list()
		if (tgui_alert(usr, "Do you want that role to be part of a faction?", "Assigned role", list("Yes", "No")) == "Yes")
			all_factions = get_faction_list()
			joined_faction = input("Select new faction", "Assigned faction", null) as null|anything in all_factions


		var/role_type = available_roles[new_role]
		var/datum/role/newRole = new role_type
		if(!newRole)
			WARNING("Role killed itself or was otherwise missing!")
			return

		var/chosen_greeting
		var/custom_greeting
		if (newRole.greets.len)
			if (tgui_alert(usr, "Do you want to greet them as their new role?", "Assigned role", list("Yes", "No")) == "Yes")
				chosen_greeting = input("Choose a greeting", "Assigned role", null) as null|anything in newRole.greets
				if (chosen_greeting == GREET_CUSTOM)
					custom_greeting = input("Choose a custom greeting", "Assigned role", "") as null|text

		if(!newRole.AssignToRole(src,1))//it shouldn't fail since we're using our admin powers to force the role
			newRole.Drop()//but just in case
			return

		if (joined_faction && joined_faction != "-----")
			if (istype(all_factions[joined_faction], /datum/faction))//we got an existing faction
				var/datum/faction/joined = all_factions[joined_faction]
				joined.HandleRecruitedRole(newRole)
			else //we got an inexisting faction, gotta create it first!
				var/datum/faction/joined = SSticker.mode.CreateFaction(all_factions[joined_faction], null, 1)
				if (joined)
					joined.HandleRecruitedRole(newRole)

		newRole.OnPostSetup()
		if ((chosen_greeting && chosen_greeting != "custom") || (chosen_greeting == "custom" && custom_greeting))
			newRole.Greet(chosen_greeting, custom_greeting)

	else if(href_list["role_edit"])
		var/datum/role/R = locate(href_list["role_edit"])

		if(href_list["remove_role"])
			R.Drop()

		else if(href_list["remove_from_faction"])
			if(!R.faction)
				to_chat(usr, "<span class='warning'>Can't leave a faction when you already don't belong to any!</span>")
			else if(R in R.faction.members)
				R.faction.HandleRemovedRole(R)

		else if(href_list["add_to_faction"])
			if(R.faction)
				to_chat(usr, "<span class='warning'>A role can only belong to one faction!</span>")
				return
			var/list/all_factions = get_faction_list()
			var/join_faction = input("Select new faction", "Assigned faction", null) as null|anything in all_factions
			if(!join_faction || join_faction == "-----")
				return
			if(istype(all_factions[join_faction], /datum/faction))//we got an existing faction
				var/datum/faction/joined = all_factions[join_faction]
				joined.HandleRecruitedRole(R)
			else //we got an inexisting faction, gotta create it first!
				var/datum/faction/joined = SSticker.mode.CreateFaction(all_factions[join_faction], null, 1)
				if(joined)
					joined.HandleRecruitedRole(R)

	else if (href_list["memory_edit"])
		var/new_memo = sanitize(input("Write new memory", "Memory", input_default(memory)) as null|message, extra = FALSE)
		if (!new_memo)
			return
		memory = new_memo

	else if (href_list["obj_add"])
		var/datum/objective_holder/obj_holder = locate(href_list["obj_holder"])

		var/list/available_objectives = list()

		for(var/objective_type in subtypesof(/datum/objective))
			available_objectives[objective_type] = objective_type

		var/new_obj = input("Select a new objective", "New Objective", null) as null|anything in available_objectives
		if(!new_obj)
			return

		var/obj_type = available_objectives[new_obj]

		var/datum/objective/new_objective
		if(ispath(obj_type, /datum/objective/custom))
			new_objective = new obj_type(null, usr, obj_holder.faction)
		else
			new_objective = new obj_type()

		var/setup = TRUE
		if (istype(new_objective, /datum/objective/target) || istype(new_objective, /datum/objective/steal))
			var/datum/objective/target/new_O = new_objective // the /datum/objective/steal has same proc names
			if (tgui_alert(usr, "Do you want to specify a target?", "New Objective", list("Yes", "No")) == "Yes")
				setup = new_O.select_target()

		if(!setup)
			tgui_alert(usr, "Couldn't set-up a proper target.", "New Objective")
			return

		if (tgui_alert(usr, "Add the objective to a faction?", "Faction", list("Yes", "No")) == "Yes")
			var/datum/faction/fac = input("To which faction shall we give this?", "Faction-wide objective", null) as anything in SSticker.mode.factions
			fac.handleNewObjective(new_objective)
			message_admins("[usr.key]/([usr.name]) gave \the [new_objective.faction.ID] the objective: [new_objective.explanation_text]")
			log_admin("[usr.key]/([usr.name]) gave \the [new_objective.faction.ID] the objective: [new_objective.explanation_text]")
			edit_memory()
			return TRUE // It's a faction objective, let's not move any further.

		if (obj_holder.owner)//so objectives won't target their owners.
			new_objective.owner = obj_holder.owner

		if (obj_holder.owner)
			obj_holder.AddObjective(new_objective, src)
			message_admins("[usr.key]/([usr.name]) gave [key]/([name]) the objective: [new_objective.explanation_text]")
			log_admin("[usr.key]/([usr.name]) gave [key]/([name]) the objective: [new_objective.explanation_text]")
		else if (new_objective.faction && istype(new_objective, /datum/objective/custom)) //is it a custom objective with a faction modifier?
			new_objective.faction.AppendObjective(new_objective)
			message_admins("[usr.key]/([usr.name]) gave \the [new_objective.faction.ID] the objective: [new_objective.explanation_text]")
			log_admin("[usr.key]/([usr.name]) gave \the [new_objective.faction.ID] the objective: [new_objective.explanation_text]")
		else if (obj_holder.faction) //or is it just an explicit faction obj?
			obj_holder.faction.AppendObjective(new_objective)
			message_admins("[usr.key]/([usr.name]) gave \the [obj_holder.faction.ID] the objective: [new_objective.explanation_text]")
			log_admin("[usr.key]/([usr.name]) gave \the [obj_holder.faction.ID] the objective: [new_objective.explanation_text]")

	else if (href_list["obj_delete"])
		var/datum/objective/objective = locate(href_list["obj_delete"])
		var/datum/objective_holder/obj_holder = locate(href_list["obj_holder"])

		ASSERT(istype(objective) && istype(obj_holder))

		if (obj_holder.owner)
			log_admin("[usr.key]/([usr.name]) removed [key]/([name])'s objective ([objective.explanation_text])")
		else if (obj_holder.faction)
			message_admins("[usr.key]/([usr.name]) removed \the [obj_holder.faction.ID]'s objective ([objective.explanation_text])")
			log_admin("[usr.key]/([usr.name]) removed \the [obj_holder.faction.ID]'s objective ([objective.explanation_text])")
			objective.faction.handleRemovedObjective(objective)

		obj_holder.objectives.Remove(objective)

	else if(href_list["obj_completed"])
		var/datum/objective/objective = locate(href_list["obj_completed"])

		ASSERT(istype(objective))

		if(objective.completed == OBJECTIVE_LOSS)
			objective.completed = OBJECTIVE_HALFWIN
		else if(objective.completed == OBJECTIVE_HALFWIN)
			objective.completed = OBJECTIVE_WIN
		else if(objective.completed == OBJECTIVE_WIN)
			objective.completed = OBJECTIVE_LOSS

		message_admins("[usr.key]/([usr.name]) toggled [key]/([name]) [objective.explanation_text] to [objective.completion_to_string()]")
		log_admin("[usr.key]/([usr.name]) toggled [key]/([name]) [objective.explanation_text] to [objective.completion_to_string()]")

	else if(href_list["obj_gen"])
		var/owner = locate(href_list["obj_owner"])
		if(istype(owner, /datum/role))
			var/datum/role/R = owner
			var/list/prev_objectives = R.objectives.objectives.Copy()
			R.forgeObjectives()
			var/list/unique_objectives_role = find_unique_objectives(R.objectives.objectives, prev_objectives)
			if (!unique_objectives_role.len)
				tgui_alert(usr, "No new objectives generated.", "Alert")
			else
				for (var/datum/objective/objective in unique_objectives_role)
					log_admin("[usr.key]/([usr.name]) gave [key]/([name]) the objective: [objective.explanation_text]")
		else if(isfaction(owner))
			var/datum/faction/F = owner
			var/list/faction_objectives = F.GetObjectives()
			var/list/prev_objectives = faction_objectives.Copy()
			F.forgeObjectives()
			var/list/unique_objectives_faction = find_unique_objectives(F.GetObjectives(), prev_objectives)
			if (!unique_objectives_faction.len)
				tgui_alert(usr, "No new objectives generated.", "Alert")
			else
				for (var/datum/objective/objective in unique_objectives_faction)
					message_admins("[usr.key]/([usr.name]) gave \the [F.ID] the objective: [objective.explanation_text]")
					log_admin("[usr.key]/([usr.name]) gave \the [F.ID] the objective: [objective.explanation_text]")

	else if(href_list["role"]) //Something role specific
		var/datum/role/R = locate(href_list["role"])
		if(R)
			R.Topic(href, href_list)

	else if (href_list["obj_announce"])
		to_chat(src.current, "<span class='notice'>Your objectives are:</span>")
		for (var/role in antag_roles)
			var/datum/role/R = antag_roles[role]
			R.AnnounceObjectives()

	else if(href_list["implant"])
		var/mob/living/carbon/human/H = current
		var/is_mind_shield = findtext(href_list["implant"], "m_")
		if(is_mind_shield)
			href_list["implant"] = copytext(href_list["implant"], 3)
		if(href_list["implant"] == "remove")
			if(is_mind_shield)
				for(var/obj/item/weapon/implant/mind_protect/mindshield/I in H.contents)
					if(I.implanted)
						qdel(I)
			else
				for(var/obj/item/weapon/implant/mind_protect/loyalty/I in H.contents)
					if(I.implanted)
						qdel(I)
			H.sec_hud_set_implants()
			to_chat(H, "<span class='notice'><Font size =3><B>Your [is_mind_shield ? "mind shield" : "loyalty"] implant has been deactivated.</B></FONT></span>")
		if(href_list["implant"] == "add")
			var/obj/item/weapon/implant/mind_protect/mindshield/L
			if(is_mind_shield)
				L = new(H)
				L.inject(H)
			else
				L = new /obj/item/weapon/implant/mind_protect/loyalty(H)
				L.inject(H)

			H.sec_hud_set_implants()
			to_chat(H, "<span class='warning'><Font size =3><B>You somehow have become the recepient of a [is_mind_shield ? "mind shield" : "loyalty"] transplant,\
			 and it just activated!</B></FONT></span>")
			for(var/type in list(TRAITOR, CULTIST, HEADREV, REV))
				if(is_mind_shield && (type == HEADREV || type == TRAITOR))
					continue
				var/datum/role/R = GetRole(type)
				if(R)
					R.Deconvert()

			to_chat(src, "<span class='warning'><Font size = 3><B>The nanobots in the [is_mind_shield ? "mind shield" : "loyalty"] implant remove all evil thoughts about the company.</B></Font></span>")

	else if (href_list["common"])
		switch(href_list["common"])
			if("undress")
				for(var/obj/item/W in current)
					current.drop_from_inventory(W)
	else if (href_list["maximize_skills"])
		skills.maximize_active_skills()
		message_admins("[usr.key]/([usr.name]) set up the skills of \the [key]/[name] to their maximum.")
		log_admin("[usr.key]/([usr.name]) set up the skills of \the [key]/[name] to their maximum.")
		edit_skills()
		return
	else if (href_list["delete_skillset"])
		var/to_delete = global.skillset_names_aliases[href_list["delete_skillset"]]
		skills.remove_available_skillset(to_delete)
		message_admins("[usr.key]/([usr.name]) removed skillset [to_delete] from \the [key]/[name].")
		log_admin("[usr.key]/([usr.name]) removed skillset [to_delete] from \the [key]/[name].")
		edit_skills()
		return
	else if (href_list["add_max"])
		skills.add_available_skillset(/datum/skillset/max)
		message_admins("[usr.key]/([usr.name]) gave \the [key]/[name] maximal skillset.")
		log_admin("[usr.key]/([usr.name]) gave \the [key]/[name] maximal skillset.")
		edit_skills()
		return
	else if (href_list["add_skillset"])
		var/new_skillset = input("Select new skillset", "Skillsets selection", null) as null|anything in global.skillset_names_aliases
		if (!new_skillset)
			return
		skills.add_available_skillset(skillset_names_aliases[new_skillset])
		message_admins("[usr.key]/([usr.name]) gave \the [key]/[name] new skillset: [new_skillset]")
		log_admin("[usr.key]/([usr.name]) gave \the [key]/[name] new skillset: [new_skillset]")
		edit_skills()
		return
	else if (href_list["refresh"])
		if(href_list["refresh"]=="2")
			edit_skills()
			return
		edit_memory()
		return

	edit_memory()

// /datum/role and other game_mode--
/datum/mind/proc/GetRole(role_id)
	if(role_id in antag_roles)
		return antag_roles[role_id]
	return FALSE

/datum/mind/proc/GetRoleByType(type)
	for(var/role_id in antag_roles)
		var/datum/role/R = antag_roles[role_id]
		if(istype(R, type))
			return R
	return null

/datum/mind/proc/GetFactionFromRole(role_id)
	var/datum/role/R = GetRole(role_id)
	if(R)
		return R.GetFaction()
	return FALSE

/datum/mind/proc/IsPartOfFaction(datum/faction/F)
	if(!length(antag_roles))
		return FALSE

	for(var/role_id in antag_roles)
		var/datum/role/R = antag_roles[role_id]
		if(R.GetFaction() == F)
			return TRUE

	return FALSE

/datum/mind/proc/set_current(mob/new_current)
	if(current)
		UnregisterSignal(src, COMSIG_PARENT_QDELETING)
	current = new_current
	if(current)
		RegisterSignal(src, COMSIG_PARENT_QDELETING, PROC_REF(clear_current))

/datum/mind/proc/clear_current(datum/source)
	SIGNAL_HANDLER
	set_current(null)

// check whether this mind's mob has been brigged for the given duration
// have to call this periodically for the duration to work properly
/datum/mind/proc/is_brigged(duration)
	var/turf/T = current.loc
	if(!istype(T))
		brigged_since = -1
		return FALSE

	var/is_currently_brigged = 0

	if(istype(T.loc,/area/station/security/brig))
		is_currently_brigged = 1
		for(var/obj/item/weapon/card/id/card in current)
			is_currently_brigged = 0
			break // if they still have ID they're not brigged
		for(var/obj/item/device/pda/P in current)
			if(P.id)
				is_currently_brigged = 0
				break // if they still have ID they're not brigged

	if(!is_currently_brigged)
		brigged_since = -1
		return FALSE

	if(brigged_since == -1)
		brigged_since = world.time

	return (duration <= world.time - brigged_since)

/datum/admins/proc/makeAntag(datum/role/role_type, datum/faction/fac_type, count = 1, recruitment_source = FROM_PLAYERS, stealth = TRUE)
	var/role_req
	var/role_name
	if(fac_type)
		role_req = initial(fac_type.required_pref)
		role_name = initial(fac_type.name)
	else if(role_type)
		role_req = initial(role_type.required_pref)
		role_name = initial(role_type.name)

	var/list/mob/candidates
	if(recruitment_source == FROM_GHOSTS)
		candidates = pollGhostCandidates("Do you want to be [fac_type ? "in" : "a"] [role_name]?", role_req, role_req, 100)
	else
		if(stealth)
			candidates = alive_mob_list
		else
			candidates = pollCandidates("Do you want to be [fac_type ? "in" : "a"] [role_name]?", role_req, role_req, 100, alive_mob_list)

	var/recruit_count = 0
	if(!candidates.len)
		return FALSE

	candidates = shuffle(candidates)

	if(fac_type)
		var/datum/faction/FF = create_uniq_faction(fac_type)
		while(count > 0 && candidates.len)
			var/mob/M = pick(candidates)
			candidates -= M
			if(!M.mind)
				continue

			if(isobserver(M))
				M = makeBody(M)

			if(add_faction_member(FF, M, FALSE, FALSE))
				recruit_count++
				count--

		FF.OnPostSetup()

	if(role_type)
		while(count > 0 && candidates.len)
			var/mob/M = pick(candidates)
			candidates -= M
			if(!M.mind)
				continue

			if(isobserver(M))
				M = makeBody(M)

			if(create_and_setup_role(role_type, M, TRUE))
				recruit_count++
				count--

	return recruit_count

/datum/mind/proc/AddSpell(obj/effect/proc_holder/spell/spell)
	spell_list += spell
	if(!spell.action)
		spell.action = new/datum/action/spell_action
		spell.action.target = spell
		spell.action.name = spell.name
		spell.action.button_icon = spell.action_icon
		spell.action.button_icon_state = spell.action_icon_state
		spell.action.background_icon_state = spell.action_background_icon_state
	spell.action.Grant(current)
	return

/datum/mind/proc/transfer_actions(mob/living/new_character)
	if(current && isliving(current))
		var/mob/living/M = current
		if(M.actions)
			for(var/datum/action/A in M.actions)
				A.Grant(new_character)
	transfer_mindbound_actions(new_character)

/datum/mind/proc/transfer_mindbound_actions(mob/living/new_character)
	for(var/obj/effect/proc_holder/spell/spell in spell_list)
		if(!spell.action) // Unlikely but whatever
			spell.action = new/datum/action/spell_action
			spell.action.target = spell
			spell.action.name = spell.name
			spell.action.button_icon = spell.action_icon
			spell.action.button_icon_state = spell.action_icon_state
			spell.action.background_icon_state = spell.action_background_icon_state
		spell.action.Grant(new_character)
	return

/datum/mind/proc/get_faction_list()
	var/list/all_factions = list()
	for(var/datum/faction/F in SSticker.mode.factions)
		all_factions[F.name] = F
	all_factions += "-----"
	for(var/factiontype in subtypesof(/datum/faction))
		var/datum/faction/F = factiontype
		if (!(initial(F.name) in all_factions))
			all_factions[initial(F.name)] = F
	all_factions += "-----"
	return all_factions

/mob/proc/sync_mind()
	mind_initialize()	//updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = 1		//indicates that the mind is currently synced with a client

//Initialisation procs
/mob/proc/mind_initialize()
	SHOULD_CALL_PARENT(TRUE)
	if(mind)
		mind.key = key
	else
		create_mind()
	if(!mind.name)	mind.name = real_name
	mind.set_current(src)

/mob/proc/create_mind()
	mind = new /datum/mind(key)
	mind.original = src
	if(SSticker)
		SSticker.minds += mind
	else
		world.log << "## DEBUG: mind_initialize(): No SSticker ready yet! Please inform Carn"

//HUMAN
/mob/living/carbon/human/mind_initialize()
	..()
	if(!mind.assigned_role)
		mind.assigned_role = "default"	//default

//slime
/mob/living/carbon/slime/mind_initialize()
	..()
	mind.assigned_role = "slime"

//XENO
/mob/living/carbon/xenomorph/mind_initialize()
	..()
	mind.assigned_role = "Alien"

	if(!isalien(src))
		var/datum/faction/infestation/I = create_uniq_faction(/datum/faction/infestation)
		add_faction_member(I, src, TRUE)

	//XENO HUMANOID
/mob/living/carbon/xenomorph/humanoid/queen/mind_initialize()
	..()
	mind.special_role = "Queen"

/mob/living/carbon/xenomorph/humanoid/hunter/mind_initialize()
	..()
	mind.special_role = "Hunter"

/mob/living/carbon/xenomorph/humanoid/drone/mind_initialize()
	..()
	mind.special_role = "Drone"

/mob/living/carbon/xenomorph/humanoid/sentinel/mind_initialize()
	..()
	mind.special_role = "Sentinel"
	//XENO LARVA
/mob/living/carbon/xenomorph/larva/mind_initialize()
	..()
	mind.special_role = "Larva"

/mob/living/carbon/xenomorph/humanoid/maid/mind_initialize()
	..()
	mind.special_role = "Drone"

//AI
/mob/living/silicon/ai/mind_initialize()
	..()
	mind.assigned_role = "AI"

//BORG
/mob/living/silicon/robot/mind_initialize()
	..()
	mind.assigned_role = "Cyborg"

//PAI
/mob/living/silicon/pai/mind_initialize()
	..()
	mind.assigned_role = "pAI"
	mind.special_role = ""

//Animals
/mob/living/simple_animal/mind_initialize()
	..()
	mind.assigned_role = "Animal"

/mob/living/simple_animal/corgi/mind_initialize()
	..()
	mind.assigned_role = "Corgi"

/mob/living/simple_animal/shade/mind_initialize()
	..()
	mind.assigned_role = "Shade"

/mob/living/simple_animal/construct/builder/mind_initialize()
	..()
	mind.assigned_role = "Artificer"
	to_chat(src, "<span class='cult'>Вы играете за Artificer. Вы самый слабый по всем характеристикам вид оболочки, но вы можете строить укрепления, чинить другие оболочки (нажав на них), а так же создавать новые оболочки и камни души.</span>")

/mob/living/simple_animal/construct/wraith/mind_initialize()
	..()
	mind.assigned_role = "Wraith"
	to_chat(src, "<span class='cult'>Вы играете за Wraith. Несмотря на вашу хрупкость, вы владеете самой большой подвижностью и можете проходить сквозь стены.</span>")

/mob/living/simple_animal/construct/armoured/mind_initialize()
	..()
	mind.assigned_role = "Juggernaut"
	to_chat(src, "<span class='cult'>Вы играете за Juggernaut. Ваша подвижность очень ограничена, но вы можете выдержать большое количество повреждений. Ваша сила позволяет вам рвать на куски как врагов, так и стены.</span>")

/mob/living/simple_animal/construct/behemoth/mind_initialize()
	..()
	mind.assigned_role = "Behemoth"
	to_chat(src, "<span class='cult'>Вы играете за Behemoth. Вы самая сильная и живучая оболочка, но это не остановит Полкана.</span>")

/mob/living/simple_animal/construct/proteon/mind_initialize()
	..()
	mind.assigned_role = "Proteon"
	to_chat(src, "<span class='cult'>Вы играете за Proteon. Ваши боевые способности превосходят все оболочки, а так же вы очень быстры и ловки, но при этом вы очень хрупки, по сравнению с другими.</span>")

/mob/living/simple_animal/vox/armalis/mind_initialize()
	..()
	mind.assigned_role = "Armalis"
	mind.special_role = "Vox Raider"

/mob/living/simple_animal/hostile/mimic/prophunt/mind_initialize()
	..()

	var/datum/faction/infestation/I = create_uniq_faction(/datum/faction/props)
	add_faction_member(I, src, TRUE)
