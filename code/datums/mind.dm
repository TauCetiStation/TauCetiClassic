/*	Note from Carnie:
		The way datum/mind stuff works has been changed a lot.
		Minds now represent IC characters rather than following a client around constantly.

	Guidelines for using minds properly:

	-	Never mind.transfer_to(ghost). The var/current and var/original of a mind must always be of type mob/living!
		ghost.mind is however used as a reference to the ghost's corpse

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
	var/mob/living/current
	var/mob/living/original	//TODO: remove.not used in any meaningful way ~Carn. First I'll need to tweak the way silicon-mobs handle minds.
	var/active = 0

	var/memory

	var/assigned_role
	var/special_role
	var/holy_role = NONE

	var/protector_role = 0 //If we want force player to protect the station
	var/hulkizing = FALSE //Hulk before? If TRUE - cannot activate hulk mutation anymore.

	var/role_alt_title

	var/datum/job/assigned_job

	var/list/datum/objective/objectives = list()
	var/list/datum/objective/special_verbs = list()

	var/list/spell_list = list()

	var/has_been_rev = 0//Tracks if this mind has been a rev or not

	var/datum/faction/faction 			//associated faction
	var/datum/changeling/changeling		//changeling holder

	var/rev_cooldown = 0

	// the world.time since the mob has been brigged, or -1 if not at all
	var/brigged_since = -1

	//put this here for easier tracking ingame
	var/datum/money_account/initial_account
	var/list/uplink_items_bought = list()
	var/total_TC = 0
	var/spent_TC = 0

/datum/mind/New(var/key)
	src.key = key

/datum/mind/proc/transfer_to(mob/living/new_character)
	if(!istype(new_character))
		world.log << "## DEBUG: transfer_to(): Some idiot has tried to transfer_to() a non mob/living mob. Please inform Carn"
	if(current)					//remove ourself from our old body's mind variable
//			if(changeling)
//				current.remove_changeling_powers()
//				current.verbs -= /datum/changeling/proc/EvolutionMenu
		current.mind = null
	if(new_character.mind)		//remove any mind currently in our new body's mind variable
		new_character.mind.current = null

	nanomanager.user_transferred(current, new_character) // transfer active NanoUI instances to new user

	current = new_character		//link ourself to our new body
	new_character.mind = src	//and link our new body to ourself
	transfer_actions(new_character)

//	if(changeling)
//		new_character.make_changeling()

	if(active)
		new_character.key = key		//now transfer the key to link the client to our new body

/datum/mind/proc/store_memory(new_text)
	memory += "[new_text]<BR>"

/*
	Removes antag objectives
*/

/datum/mind/proc/remove_objectives()
	if(objectives.len)
		for(var/datum/objective/O in objectives)
			objectives -= O
			qdel(O)

/datum/mind/proc/show_memory(mob/recipient)
	var/output = "<B>[current.real_name]'s Memory</B><HR>"
	output += memory

	if(objectives.len>0)
		output += "<HR><B>Objectives:</B>"

		var/obj_count = 1
		for(var/datum/objective/objective in objectives)
			output += "<br><B>Objective #[obj_count]</B>: [objective.explanation_text]"
			obj_count++

	var/datum/browser/popup = new(recipient, "window=memory")
	popup.set_content(output)
	popup.open()

/datum/mind/proc/edit_memory()
	if(!SSticker || !SSticker.mode)
		alert("Not before round-start!", "Alert")
		return

	var/out = "<B>[name]</B>[(current&&(current.real_name!=name))?" (as [current.real_name])":""]<br>"
	out += "Mind currently owned by key: [key] [active?"(synced)":"(not synced)"]<br>"
	out += "Assigned role: [assigned_role]. <a href='?src=\ref[src];role_edit=1'>Edit</a><br>"
	out += "Factions and special roles:<br>"

	var/list/sections = list(
		"implant",
		"revolution",
		"gang",
		"cult",
		"wizard",
		"changeling",
		"nuclear",
		"shadowling",
		"abductor",
		"traitor", // "traitorchan",
		"monkey",
		"malfunction",
	)
	var/text = ""
	var/mob/living/carbon/human/H = current
	if (istype(current, /mob/living/carbon/human) || istype(current, /mob/living/carbon/monkey))
		/** Impanted**/
		if(ishuman(current))
			if(ismindshielded(H, TRUE))
				text += "Mind Shield Implant:<a href='?src=\ref[src];implant=m_remove'>Remove</a>|<b>Implanted</b></br>"
			else
				text += "Mind Shield Implant:<b>No Implant</b>|<a href='?src=\ref[src];implant=m_add'>Implant him!</a></br>"

			if(isloyal(H))
				text += "Loyalty Implant:<a href='?src=\ref[src];implant=remove'>Remove</a>|<b>Implanted</b></br>"
			else
				text += "Loyalty Implant:<b>No Implant</b>|<a href='?src=\ref[src];implant=add'>Implant him!</a></br>"
		else
			text = "Loyalty Implant: Don't implant that monkey!</br>"
		sections["implant"] = text
		/** REVOLUTION ***/
		text = "revolution"
		if (SSticker.mode.config_tag=="revolution")
			text += uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (istype(current, /mob/living/carbon/monkey) || ismindshielded(H))
			text += "<b>LOYAL EMPLOYEE</b>|headrev|rev"
		else if (src in SSticker.mode.head_revolutionaries)
			text += "<a href='?src=\ref[src];revolution=clear'>employee</a>|<b>HEADREV</b>|<a href='?src=\ref[src];revolution=rev'>rev</a>"
			text += "<br>Flash: <a href='?src=\ref[src];revolution=flash'>give</a>"

			var/list/L = current.get_contents()
			var/obj/item/device/flash/flash = locate() in L
			if (flash)
				if(!flash.broken)
					text += "|<a href='?src=\ref[src];revolution=takeflash'>take</a>."
				else
					text += "|<a href='?src=\ref[src];revolution=takeflash'>take</a>|<a href='?src=\ref[src];revolution=repairflash'>repair</a>."
			else
				text += "."

			text += " <a href='?src=\ref[src];revolution=reequip'>Reequip</a> (gives traitor uplink)."
			if (objectives.len==0)
				text += "<br>Objectives are empty! <a href='?src=\ref[src];revolution=autoobjectives'>Set to kill all heads</a>."
		else if (src in SSticker.mode.revolutionaries)
			text += "head|loyal|<a href='?src=\ref[src];revolution=clear'>employee</a>|<a href='?src=\ref[src];revolution=headrev'>headrev</a>|<b>REV</b>"
		else
			text += "head|loyal|<b>EMPLOYEE</b>|<a href='?src=\ref[src];revolution=headrev'>headrev</a>|<a href='?src=\ref[src];revolution=rev'>rev</a>"
		if(current && current.client && (ROLE_REV in current.client.prefs.be_role))
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"
		sections["revolution"] = text

		/** GANG ***/
		text = "gang"
		if (SSticker.mode.config_tag=="gang")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (src in SSticker.mode.A_bosses)
			text += "loyal|<a href='?src=\ref[src];gang=clear'>none</a>|<B>(A)</B> <a href='?src=\ref[src];gang=agang'>gangster</a> <b>BOSS</b>|(B) <a href='?src=\ref[src];gang=bgang'>gangster</a> <a href='?src=\ref[src];gang=bboss'>boss</a>"
			text += "<br>Equipment: <a href='?src=\ref[src];gang=equip'>give</a>"

			var/list/L = current.get_contents()
			var/obj/item/device/gangtool/gangtool = locate() in L
			if (gangtool)
				text += "|<a href='?src=\ref[src];gang=takeequip'>take</a>."
			else
				text += "."

		else if (src in SSticker.mode.B_bosses)
			text += "loyal|<a href='?src=\ref[src];gang=clear'>none</a>|(A) <a href='?src=\ref[src];gang=agang'>gangster</a> <a href='?src=\ref[src];gang=aboss'>boss</a>|<B>(B)</B> <a href='?src=\ref[src];gang=bgang'>gangster</a> <b>BOSS</b>"
			text += "<br>Equipment: <a href='?src=\ref[src];gang=equip'>give</a>"

			var/list/L = current.get_contents()
			var/obj/item/device/gangtool/gangtool = locate() in L
			if (gangtool)
				text += "<a href='?src=\ref[src];gang=takeequip'>take</a>."
			else
				text += "."

		else if (src in SSticker.mode.A_gang)
			text += "loyal|<a href='?src=\ref[src];gang=clear'>none</a>|<B>(A) GANGSTER</B> <a href='?src=\ref[src];gang=aboss'>boss</a>|(B) <a href='?src=\ref[src];gang=bgang'>gangster</a> <a href='?src=\ref[src];gang=bboss'>boss</a>"
		else if (src in SSticker.mode.B_gang)
			text += "loyal|<a href='?src=\ref[src];gang=clear'>none</a>|(A) <a href='?src=\ref[src];gang=agang'>gangster</a> <a href='?src=\ref[src];gang=aboss'>boss</a>|<B>(B) GANGSTER</B> <a href='?src=\ref[src];gang=bboss'>boss</a>"
		else if(ismindshielded(current))
			text += "<B>LOYAL</B>|none|(A) <a href='?src=\ref[src];gang=agang'>gangster</a> <a href='?src=\ref[src];gang=aboss'>boss</a>|(B) <a href='?src=\ref[src];gang=bgang'>gangster</a> <a href='?src=\ref[src];gang=bboss'>boss</a>"
		else
			text += "loyal|<B>NONE</B>|(A) <a href='?src=\ref[src];gang=agang'>gangster</a> <a href='?src=\ref[src];gang=aboss'>boss</a>|(B) <a href='?src=\ref[src];gang=bgang'>gangster</a> <a href='?src=\ref[src];gang=bboss'>boss</a>"
		sections["gang"] = text

		/** CULT ***/
		text = "cult"
		if (SSticker.mode.config_tag=="cult")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (istype(current, /mob/living/carbon/monkey) || ismindshielded(H))
			text += "<B>LOYAL EMPLOYEE</B>|cultist"
		else if (src in SSticker.mode.cult)
			text += "<a href='?src=\ref[src];cult=clear'>employee</a>|<b>CULTIST</b>"
			text += "<br>Give <a href='?src=\ref[src];cult=tome'>tome</a>|<a href='?src=\ref[src];cult=amulet'>amulet</a>."
/*
			if (objectives.len==0)
				text += "<br>Objectives are empty! Set to sacrifice and <a href='?src=\ref[src];cult=escape'>escape</a> or <a href='?src=\ref[src];cult=summon'>summon</a>."
*/
		else
			text += "<b>EMPLOYEE</b>|<a href='?src=\ref[src];cult=cultist'>cultist</a>"
		if(current && current.client && (ROLE_CULTIST in current.client.prefs.be_role))
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"
		sections["cult"] = text

		/** WIZARD ***/
		text = "wizard"
		if (SSticker.mode.config_tag=="wizard")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (src in SSticker.mode.wizards)
			text += "<b>YES</b>|<a href='?src=\ref[src];wizard=clear'>no</a>"
			text += "<br><a href='?src=\ref[src];wizard=lair'>To lair</a>, <a href='?src=\ref[src];common=undress'>undress</a>, <a href='?src=\ref[src];wizard=dressup'>dress up</a>, <a href='?src=\ref[src];wizard=name'>let choose name</a>."
			if (objectives.len==0)
				text += "<br>Objectives are empty! <a href='?src=\ref[src];wizard=autoobjectives'>Randomize!</a>"
		else
			text += "<a href='?src=\ref[src];wizard=wizard'>yes</a>|<b>NO</b>"
		if(current && current.client && (ROLE_WIZARD in current.client.prefs.be_role))
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"
		sections["wizard"] = text

		/** CHANGELING ***/
		text = "changeling"
		if (SSticker.mode.config_tag=="changeling" || SSticker.mode.config_tag=="traitorchan")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (src in SSticker.mode.changelings)
			text += "<b>YES</b>|<a href='?src=\ref[src];changeling=clear'>no</a>"
			if (objectives.len==0)
				text += "<br>Objectives are empty! <a href='?src=\ref[src];changeling=autoobjectives'>Randomize!</a>"
			if( changeling && changeling.absorbed_dna.len && (current.real_name != changeling.absorbed_dna[1]) )
				text += "<br><a href='?src=\ref[src];changeling=initialdna'>Transform to initial appearance.</a>"
		else
			text += "<a href='?src=\ref[src];changeling=changeling'>yes</a>|<b>NO</b>"
//			var/datum/game_mode/changeling/changeling = SSticker.mode
//			if (istype(changeling) && changeling.changelingdeath)
//				text += "<br>All the changelings are dead! Restart in [round((changeling.TIME_TO_GET_REVIVED-(world.time-changeling.changelingdeathtime))/10)] seconds."
		if(current && current.client && (ROLE_CHANGELING in current.client.prefs.be_role))
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"
		sections["changeling"] = text

		/** NUCLEAR ***/
		text = "nuclear"
		if (SSticker.mode.config_tag=="nuclear")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (src in SSticker.mode.syndicates)
			text += "<b>OPERATIVE</b>|<a href='?src=\ref[src];nuclear=clear'>nanotrasen</a>"
			text += "<br><a href='?src=\ref[src];nuclear=lair'>To shuttle</a>, <a href='?src=\ref[src];common=undress'>undress</a>, <a href='?src=\ref[src];nuclear=dressup'>dress up</a>."
			var/code
			for (var/obj/machinery/nuclearbomb/bombue in poi_list)
				if (length(bombue.r_code) <= 5 && bombue.r_code != "LOLNO" && bombue.r_code != "ADMIN")
					code = bombue.r_code
					break
			if (code)
				text += " Code is [code]. <a href='?src=\ref[src];nuclear=tellcode'>tell the code.</a>"
		else
			text += "<a href='?src=\ref[src];nuclear=nuclear'>operative</a>|<b>NANOTRASEN</b>"
		if(current && current.client && (ROLE_OPERATIVE in current.client.prefs.be_role))
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"
		sections["nuclear"] = text

		/** SHADOWLING **/
		text = "shadowling"
		if(SSticker.mode.config_tag == "shadowling")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if(src in SSticker.mode.shadows)
			text += "<b>SHADOWLING</b>|thrall|<a href='?src=\ref[src];shadowling=clear'>human</a>"
		else if(src in SSticker.mode.thralls)
			text += "shadowling|<b>THRALL</b>|<a href='?src=\ref[src];shadowling=clear'>human</a>"
		else if(ismindshielded(current))
			text +="<b>Implanted</b>"
		else
			text += "<a href='?src=\ref[src];shadowling=shadowling'>shadowling</a>|<a href='?src=\ref[src];shadowling=thrall'>thrall</a>|<b>HUMAN</b>"

		if(current && current.client && (ROLE_SHADOWLING in current.client.prefs.be_role))
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"

		sections["shadowling"] = text

		/** ABDUCTORS **/
		text = "abductor"
		if(SSticker.mode.config_tag == "abductor")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if(src in SSticker.mode.abductors)
			text += "<b>ABDUCTOR</b>|<a href='?src=\ref[src];abductor=clear'>human</a>"
			text += "|<a href='?src=\ref[src];common=undress'>undress</a>|<a href='?src=\ref[src];abductor=equip'>equip</a>"
		else
			text += "<a href='?src=\ref[src];abductor=abductor'>abductor</a>|<b>human</b>"
		if(current && current.client && (ROLE_ABDUCTOR in current.client.prefs.be_role))
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"
		sections["abductor"] = text

	/** TRAITOR ***/
	text = "traitor"
	if (SSticker.mode.config_tag=="traitor" || SSticker.mode.config_tag=="traitorchan")
		text = uppertext(text)
	text = "<i><b>[text]</b></i>: "
	if(ishuman(current))
		if (isloyal(H))
			text +="traitor|<b>LOYAL EMPLOYEE</b>"
		else
			if (src in SSticker.mode.traitors)
				text += "<b>TRAITOR</b>|<a href='?src=\ref[src];traitor=clear'>Employee</a>"
				if (objectives.len==0)
					text += "<br>Objectives are empty! <a href='?src=\ref[src];traitor=autoobjectives'>Randomize</a>!"
			else
				text += "<a href='?src=\ref[src];traitor=traitor'>traitor</a>|<b>Employee</b>"
	else if(isAI(current))
		if (src in SSticker.mode.traitors)
			text += "<b>SYNDICATE AI</b>|<a href='?src=\ref[src];traitor=clear'>nt ai</a>"
		else
			text += "<a href='?src=\ref[src];traitor=traitor'>syndicate AI</a>|<b>NT AI</b>"

	if(current && current.client && (ROLE_TRAITOR in current.client.prefs.be_role))
		text += "|Enabled in Prefs"
	else
		text += "|Disabled in Prefs"
	sections["traitor"] = text

	/** MONKEY ***/
	if (istype(current, /mob/living/carbon))
		text = "monkey"
		if (SSticker.mode.config_tag=="monkey")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (istype(current, /mob/living/carbon/human))
			text += "<a href='?src=\ref[src];monkey=healthy'>healthy</a>|<a href='?src=\ref[src];monkey=infected'>infected</a>|<b>HUMAN</b>|other"
		else if (istype(current, /mob/living/carbon/monkey))
			var/found = 0
			for(var/datum/disease/D in current.viruses)
				if(istype(D, /datum/disease/jungle_fever)) found = 1

			if(found)
				text += "<a href='?src=\ref[src];monkey=healthy'>healthy</a>|<b>INFECTED</b>|<a href='?src=\ref[src];monkey=human'>human</a>|other"
			else
				text += "<b>HEALTHY</b>|<a href='?src=\ref[src];monkey=infected'>infected</a>|<a href='?src=\ref[src];monkey=human'>human</a>|other"

		else
			text += "healthy|infected|human|<b>OTHER</b>"
		sections["monkey"] = text


	/** SILICON ***/

	if (istype(current, /mob/living/silicon))
		text = "silicon"
		if (SSticker.mode.config_tag=="malfunction")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if (istype(current, /mob/living/silicon/ai))
			if (src in SSticker.mode.malf_ai)
				text += "<b>MALF</b>|<a href='?src=\ref[src];silicon=unmalf'>not malf</a>"
			else
				text += "<a href='?src=\ref[src];silicon=malf'>malf</a>|<b>NOT MALF</b>"
		var/mob/living/silicon/robot/robot = current
		if (istype(robot) && robot.emagged)
			text += "<br>Cyborg: Is emagged! <a href='?src=\ref[src];silicon=unemag'>Unemag!</a><br>0th law: [robot.laws.zeroth]"
		var/mob/living/silicon/ai/ai = current
		if (istype(ai) && ai.connected_robots.len)
			var/n_e_robots = 0
			for (var/mob/living/silicon/robot/R in ai.connected_robots)
				if (R.emagged)
					n_e_robots++
			text += "<br>[n_e_robots] of [ai.connected_robots.len] slaved cyborgs are emagged. <a href='?src=\ref[src];silicon=unemagcyborgs'>Unemag</a>"
		if(current && current.client && (ROLE_MALF in current.client.prefs.be_role))
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"
		sections["malfunction"] = text

	if (SSticker.mode.config_tag == "traitorchan")
		if (sections["traitor"])
			out += sections["traitor"]+"<br>"
		if (sections["changeling"])
			out += sections["changeling"]+"<br>"
		sections -= "traitor"
		sections -= "changeling"
	else
		if (sections[SSticker.mode.config_tag])
			out += sections[SSticker.mode.config_tag]+"<br>"
		sections -= SSticker.mode.config_tag
	for (var/i in sections)
		if (sections[i])
			out += sections[i]+"<br>"


	if (((src in SSticker.mode.head_revolutionaries) || \
		(src in SSticker.mode.A_bosses)              || \
		(src in SSticker.mode.B_bosses)              || \
		(src in SSticker.mode.traitors)              || \
		(src in SSticker.mode.syndicates))           && \
		istype(current,/mob/living/carbon/human)      )

		text = "Uplink: <a href='?src=\ref[src];common=uplink'>give</a>"
		var/obj/item/device/uplink/hidden/suplink = find_syndicate_uplink()
		var/crystals
		if (suplink)
			crystals = suplink.uses
		if (suplink)
			text += "|<a href='?src=\ref[src];common=takeuplink'>take</a>"
			if (usr.client.holder.rights & R_FUN)
				text += ", <a href='?src=\ref[src];common=crystals'>[crystals]</a> crystals"
			else
				text += ", [crystals] crystals"
		text += "." //hiel grammar
		out += text

	out += "<br>"

	out += "<b>Memory:</b><br>"
	out += memory
	out += "<br><a href='?src=\ref[src];memory_edit=1'>Edit memory</a><br>"
	out += "Objectives:<br>"
	if (objectives.len == 0)
		out += "EMPTY<br>"
	else
		var/obj_count = 1
		for(var/datum/objective/objective in objectives)
			out += "<B>[obj_count]</B>: [objective.explanation_text] <a href='?src=\ref[src];obj_edit=\ref[objective]'>Edit</a> <a href='?src=\ref[src];obj_delete=\ref[objective]'>Delete</a> <a href='?src=\ref[src];obj_completed=\ref[objective]'><font color=[objective.completed ? "green" : "red"]>Toggle Completion</font></a><br>"
			obj_count++
	out += "<a href='?src=\ref[src];obj_add=1'>Add objective</a><br><br>"

	out += "<a href='?src=\ref[src];obj_announce=1'>Announce objectives</a><br><br>"

	var/datum/browser/popup = new(usr, "window=edit_memory", "Memory", 400, 500)
	popup.set_content(out)
	popup.open()

/datum/mind/Topic(href, href_list)
	if(!check_rights(R_ADMIN))
		return

	if (href_list["role_edit"])
		var/new_role = input("Select new role", "Assigned role", assigned_role) as null|anything in joblist
		if (!new_role) return
		assigned_role = new_role

	else if (href_list["memory_edit"])
		var/new_memo = sanitize(input("Write new memory", "Memory", input_default(memory)) as null|message, extra = FALSE)
		if (!new_memo)
			return
		memory = new_memo

	else if (href_list["obj_edit"] || href_list["obj_add"])
		var/datum/objective/objective
		var/objective_pos
		var/def_value

		if (href_list["obj_edit"])
			objective = locate(href_list["obj_edit"])
			if (!objective) return
			objective_pos = objectives.Find(objective)

			//Text strings are easy to manipulate. Revised for simplicity.
			var/temp_obj_type = "[objective.type]"//Convert path into a text string.
			def_value = copytext(temp_obj_type, 19)//Convert last part of path into an objective keyword.
			if(!def_value)//If it's a custom objective, it will be an empty string.
				def_value = "custom"

		var/new_obj_type = input("Select objective type:", "Objective type", def_value) as null|anything in list("assassinate", "debrain", "dehead", "protect", "prevent", "harm", "brig", "hijack", "escape", "survive", "steal", "download", "nuclear", "capture", "absorb", "custom")
		if (!new_obj_type) return

		var/datum/objective/new_objective = null

		switch (new_obj_type)
			if ("assassinate","protect","debrain", "dehead", "harm", "brig")
				//To determine what to name the objective in explanation text.
				var/objective_type = "[capitalize(new_obj_type)]"

				var/list/possible_targets = list("Free objective")
				for(var/datum/mind/possible_target in SSticker.minds)
					if ((possible_target != src) && istype(possible_target.current, /mob/living/carbon/human))
						possible_targets += possible_target.current

				var/mob/def_target = null
				if (objective?.target && is_type_in_list(objective, list(/datum/objective/assassinate, /datum/objective/protect, /datum/objective/debrain)))
					def_target = objective.target.current

				var/new_target = input("Select target:", "Objective target", def_target) as null|anything in possible_targets
				if (!new_target) return

				var/objective_path = text2path("/datum/objective/[new_obj_type]")
				if (new_target == "Free objective")
					new_objective = new objective_path
					new_objective.owner = src
					new_objective:target = null
					new_objective.explanation_text = "Free objective"
				else
					new_objective = new objective_path
					new_objective.owner = src
					new_objective:target = new_target:mind
					//Will display as special role if the target is set as MODE. Ninjas/commandos/nuke ops.
					new_objective.explanation_text = "[objective_type] [new_target:real_name], the [new_target:mind:assigned_role=="MODE" ? (new_target:mind:special_role) : (new_target:mind:assigned_role)]."

			if ("prevent")
				new_objective = new /datum/objective/block
				new_objective.owner = src

			if ("hijack")
				new_objective = new /datum/objective/hijack
				new_objective.owner = src

			if ("escape")
				new_objective = new /datum/objective/escape
				new_objective.owner = src

			if ("survive")
				new_objective = new /datum/objective/survive
				new_objective.owner = src

			if ("nuclear")
				new_objective = new /datum/objective/nuclear
				new_objective.owner = src

			if ("steal")
				if (!istype(objective, /datum/objective/steal))
					new_objective = new /datum/objective/steal
					new_objective.owner = src
				else
					new_objective = objective
				var/datum/objective/steal/steal = new_objective
				if (!steal.select_target())
					return

			if("download","capture","absorb")
				var/def_num
				if(objective&&objective.type==text2path("/datum/objective/[new_obj_type]"))
					def_num = objective.target_amount

				var/target_number = input("Input target number:", "Objective", def_num) as num|null
				if (isnull(target_number))//Ordinarily, you wouldn't need isnull. In this case, the value may already exist.
					return

				switch(new_obj_type)
					if("download")
						new_objective = new /datum/objective/download
						new_objective.explanation_text = "Download [target_number] research levels."
					if("capture")
						new_objective = new /datum/objective/capture
						new_objective.explanation_text = "Accumulate [target_number] capture points."
					if("absorb")
						new_objective = new /datum/objective/absorb
						new_objective.explanation_text = "Absorb [target_number] compatible genomes."
				new_objective.owner = src
				new_objective.target_amount = target_number

			if ("custom")
				var/expl = sanitize(input("Custom objective:", "Objective", objective ? input_default(objective.explanation_text) : "") as text|null)
				if (!expl) return
				new_objective = new /datum/objective
				new_objective.owner = src
				new_objective.explanation_text = expl

		if (!new_objective) return

		if (objective)
			objectives -= objective
			objectives.Insert(objective_pos, new_objective)
		else
			objectives += new_objective

	else if (href_list["obj_delete"])
		var/datum/objective/objective = locate(href_list["obj_delete"])
		if(!istype(objective))	return
		objectives -= objective

	else if(href_list["obj_completed"])
		var/datum/objective/objective = locate(href_list["obj_completed"])
		if(!istype(objective))	return
		objective.completed = !objective.completed

	else if(href_list["implant"])
		var/mob/living/carbon/human/H = current
		var/is_mind_shield = findtext(href_list["implant"], "m_")
		if(is_mind_shield)
			href_list["implant"] = copytext(href_list["implant"], 3)
		H.hud_updateflag |= (1 << IMPLOYAL_HUD)   // updates that players HUD images so secHUD's pick up they are implanted or not.
		if(href_list["implant"] == "remove")
			if(is_mind_shield)
				for(var/obj/item/weapon/implant/mindshield/I in H.contents)
					if(I.implanted)
						qdel(I)
			else
				for(var/obj/item/weapon/implant/mindshield/loyalty/I in H.contents)
					if(I.implanted)
						qdel(I)
			to_chat(H, "<span class='notice'><Font size =3><B>Your [is_mind_shield ? "mind shield" : "loyalty"] implant has been deactivated.</B></FONT></span>")
		if(href_list["implant"] == "add")
			var/obj/item/weapon/implant/mindshield/L
			if(is_mind_shield)
				L = new(H)
				L.inject(H)
			else
				L = new /obj/item/weapon/implant/mindshield/loyalty(H)
				L.inject(H)
				START_PROCESSING(SSobj, L)

			to_chat(H, "<span class='warning'><Font size =3><B>You somehow have become the recepient of a [is_mind_shield ? "mind shield" : "loyalty"] transplant,\
			 and it just activated!</B></FONT></span>")
			if(src in SSticker.mode.revolutionaries)
				special_role = null
				SSticker.mode.revolutionaries -= src
				SSticker.mode.update_rev_icons_removed(src)
				to_chat(src, "<span class='warning'><Font size = 3><B>The nanobots in the [is_mind_shield ? "mind shield" : "loyalty"] implant remove \
				 all thoughts about being a revolutionary.  Get back to work!</B></Font></span>")
			if(!is_mind_shield && (src in SSticker.mode.head_revolutionaries))
				special_role = null
				SSticker.mode.head_revolutionaries -=src
				SSticker.mode.update_rev_icons_removed(src)
				to_chat(src, "<span class='warning'><Font size = 3><B>The nanobots in the loyalty implant remove \
				 all thoughts about being a revolutionary.  Get back to work!</B></Font></span>")
			if(src in SSticker.mode.cult)
				SSticker.mode.cult -= src
				SSticker.mode.update_cult_icons_removed(src)
				special_role = null
				var/datum/game_mode/cult/cult = SSticker.mode
				if (istype(cult))
					cult.memoize_cult_objectives(src)
				to_chat(current, "<span class='warning'><FONT size = 3><B>The nanobots in the [is_mind_shield ? "mind shield" : "loyalty"] implant remove all\
				 thoughts about being in a cult.  Have a productive day!</B></FONT></span>")
				memory = ""
			if(!is_mind_shield && (src in SSticker.mode.traitors))
				SSticker.mode.traitors -= src
				special_role = null
				to_chat(current, "<span class='warning'><FONT size = 3><B>The nanobots in the loyalty implant remove all thoughts about being a traitor to Nanotrasen.  Have a nice day!</B></FONT></span>")
				log_admin("[key_name(usr)] has de-traitor'ed [current].")

	else if (href_list["revolution"])
		current.hud_updateflag |= (1 << SPECIALROLE_HUD)

		switch(href_list["revolution"])
			if("clear")
				if(src in SSticker.mode.revolutionaries)
					SSticker.mode.revolutionaries -= src
					to_chat(current, "<span class='warning'><FONT size = 3><B>You have been brainwashed! You are no longer a revolutionary!</B></FONT></span>")
					SSticker.mode.update_rev_icons_removed(src)
					special_role = null
				if(src in SSticker.mode.head_revolutionaries)
					SSticker.mode.head_revolutionaries -= src
					to_chat(current, "<span class='warning'><FONT size = 3><B>You have been brainwashed! You are no longer a head revolutionary!</B></FONT></span>")
					SSticker.mode.update_rev_icons_removed(src)
					special_role = null
					current.verbs -= /mob/living/carbon/human/proc/RevConvert
				log_admin("[key_name(usr)] has de-rev'ed [current].")

			if("rev")
				if(src in SSticker.mode.head_revolutionaries)
					SSticker.mode.head_revolutionaries -= src
					SSticker.mode.update_rev_icons_removed(src)
					to_chat(current, "<span class='warning'><FONT size = 3><B>Revolution has been disappointed of your leader traits! You are a regular revolutionary now!</B></FONT></span>")
				else if(!(src in SSticker.mode.revolutionaries))
					to_chat(current, "<span class='warning'><FONT size = 3> You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill the heads to win the revolution!</FONT></span>")
					to_chat(current, "<font color=blue>Within the rules,</font> try to act as an opposing force to the crew. Further RP and try to make sure other players have fun<i>! If you are confused or at a loss, always adminhelp, and before taking extreme actions, please try to also contact the administration! Think through your actions and make the roleplay immersive! <b>Please remember all rules aside from those without explicit exceptions apply to antagonists.</i></b>")
				else
					return
				SSticker.mode.revolutionaries += src
				SSticker.mode.update_all_rev_icons()
				special_role = "Revolutionary"
				log_admin("[key_name(usr)] has rev'ed [current].")

			if("headrev")
				if(src in SSticker.mode.revolutionaries)
					SSticker.mode.revolutionaries -= src
					SSticker.mode.update_rev_icons_removed(src)
					to_chat(current, "<span class='warning'><FONT size = 3><B>You have proved your devotion to revoltion! You are a head revolutionary now!</B></FONT></span>")
					to_chat(current, "<font color=blue>Within the rules,</font> try to act as an opposing force to the crew. Further RP and try to make sure other players have fun<i>! If you are confused or at a loss, always adminhelp, and before taking extreme actions, please try to also contact the administration! Think through your actions and make the roleplay immersive! <b>Please remember all rules aside from those without explicit exceptions apply to antagonists.</i></b>")
				else if(!(src in SSticker.mode.head_revolutionaries))
					to_chat(current, "<span class='notice'>You are a member of the revolutionaries' leadership now!</span>")
				else
					return
				if (SSticker.mode.head_revolutionaries.len>0)
					// copy targets
					var/datum/mind/valid_head = locate() in SSticker.mode.head_revolutionaries
					if (valid_head)
						for (var/datum/objective/mutiny/O in valid_head.objectives)
							var/datum/objective/mutiny/rev_obj = new
							rev_obj.owner = src
							rev_obj.target = O.target
							rev_obj.explanation_text = "Assassinate [O.target.name], the [O.target.assigned_role]."
							objectives += rev_obj
						SSticker.mode.greet_revolutionary(src,0)
				current.verbs += /mob/living/carbon/human/proc/RevConvert
				SSticker.mode.head_revolutionaries += src
				SSticker.mode.update_all_rev_icons()
				special_role = "Head Revolutionary"
				log_admin("[key_name(usr)] has head-rev'ed [current].")

			if("autoobjectives")
				SSticker.mode.forge_revolutionary_objectives(src)
				SSticker.mode.greet_revolutionary(src,0)
				to_chat(usr, "<span class='notice'>The objectives for revolution have been generated and shown to [key]</span>")

			if("flash")
				if (!SSticker.mode.equip_revolutionary(current))
					to_chat(usr, "<span class='warning'>Spawning flash failed!</span>")

			if("takeflash")
				var/list/L = current.get_contents()
				var/obj/item/device/flash/flash = locate() in L
				if (!flash)
					to_chat(usr, "<span class='warning'>Deleting flash failed!</span>")
				qdel(flash)

			if("repairflash")
				var/list/L = current.get_contents()
				var/obj/item/device/flash/flash = locate() in L
				if (!flash)
					to_chat(usr, "<span class='warning'>Repairing flash failed!</span>")
				else
					flash.broken = 0

			if("reequip")
				var/list/L = current.get_contents()
				var/obj/item/device/flash/flash = locate() in L
				qdel(flash)
				take_uplink()
				var/fail = 0
				fail |= !SSticker.mode.equip_traitor(current, 1)
				fail |= !SSticker.mode.equip_revolutionary(current)
				if (fail)
					to_chat(usr, "<span class='warning'>Reequipping revolutionary goes wrong!</span>")

	else if (href_list["gang"])
		current.hud_updateflag |= (1 << SPECIALROLE_HUD)

		switch(href_list["gang"])
			if("clear")
				SSticker.mode.remove_gangster(src,0,1)
				remove_objectives()
				message_admins("[key_name_admin(usr)] has de-gang'ed [current].")
				log_admin("[key_name(usr)] has de-gang'ed [current].")

			if("agang")
				if(src in SSticker.mode.A_gang)
					return
				SSticker.mode.remove_gangster(src, 0, 2)
				SSticker.mode.add_gangster(src,"A",0)
				message_admins("[key_name_admin(usr)] has added [current] to the [gang_name("A")] Gang (A).")
				log_admin("[key_name(usr)] has added [current] to the [gang_name("A")] Gang (A).")

			if("aboss")
				if(src in SSticker.mode.A_bosses)
					return
				SSticker.mode.remove_gangster(src, 0, 2)
				SSticker.mode.A_bosses += src
				src.special_role = "[gang_name("A")] Gang (A) Boss"
				SSticker.mode.update_gang_icons_added(src, "A")
				to_chat(current, "<FONT size=3 color=red><B>You are a [gang_name("A")] Gang Boss!</B></FONT>")
				message_admins("[key_name_admin(usr)] has added [current] to the [gang_name("A")] Gang (A) leadership.")
				log_admin("[key_name(usr)] has added [current] to the [gang_name("A")] Gang (A) leadership.")
				SSticker.mode.forge_gang_objectives(src)
				SSticker.mode.greet_gang(src,0)

			if("bgang")
				if(src in SSticker.mode.B_gang)
					return
				SSticker.mode.remove_gangster(src, 0, 2)
				SSticker.mode.add_gangster(src,"B",0)
				message_admins("[key_name_admin(usr)] has added [current] to the [gang_name("B")] Gang (B).")
				log_admin("[key_name(usr)] has added [current] to the [gang_name("B")] Gang (B).")

			if("bboss")
				if(src in SSticker.mode.B_bosses)
					return
				SSticker.mode.remove_gangster(src, 0, 2)
				SSticker.mode.B_bosses += src
				src.special_role = "[gang_name("B")] Gang (B) Boss"
				SSticker.mode.update_gang_icons_added(src, "B")
				to_chat(current, "<FONT size=3 color=red><B>You are a [gang_name("B")] Gang Boss!</B></FONT>")
				message_admins("[key_name_admin(usr)] has added [current] to the [gang_name("B")] Gang (B) leadership.")
				log_admin("[key_name(usr)] has added [current] to the [gang_name("B")] Gang (B) leadership.")
				SSticker.mode.forge_gang_objectives(src)
				SSticker.mode.greet_gang(src,0)

			if("equip")
				switch(SSticker.mode.equip_gang(current))
					if(1)
						to_chat(usr, "<span class='warning'>Unable to equip territory spraycan!</span>")
					if(2)
						to_chat(usr, "<span class='warning'>Unable to equip recruitment pen and spraycan!</span>")
					if(3)
						to_chat(usr, "<span class='warning'>Unable to equip gangtool, pen, and spraycan!</span>")

			if("takeequip")
				var/list/L = current.get_contents()
				for(var/obj/item/weapon/pen/gang/pen in L)
					qdel(pen)
				for(var/obj/item/device/gangtool/gangtool in L)
					qdel(gangtool)
				for(var/obj/item/toy/crayon/spraycan/gang/SC in L)
					qdel(SC)

	else if (href_list["cult"])
		current.hud_updateflag |= (1 << SPECIALROLE_HUD)
		switch(href_list["cult"])
			if("clear")
				if(src in SSticker.mode.cult)
					SSticker.mode.cult -= src
					SSticker.mode.update_cult_icons_removed(src)
					special_role = null
					var/datum/game_mode/cult/cult = SSticker.mode
					if (istype(cult))
						if(!config.objectives_disabled)
							cult.memoize_cult_objectives(src)
					to_chat(current, "<span class='warning'><FONT size = 3><B>You have been brainwashed! You are no longer a cultist!</B></FONT></span>")
					memory = ""
					log_admin("[key_name(usr)] has de-cult'ed [current].")
			if("cultist")
				if(!(src in SSticker.mode.cult))
					SSticker.mode.cult += src
					SSticker.mode.update_all_cult_icons()
					special_role = "Cultist"
					to_chat(current, "<font color=\"purple\"><b><i>You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie.</b></i></font>")
					to_chat(current, "<font color=\"purple\"><b><i>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</b></i></font>")
					to_chat(current, "<font color=blue>Within the rules,</font> try to act as an opposing force to the crew. Further RP and try to make sure other players have fun<i>! If you are confused or at a loss, always adminhelp, and before taking extreme actions, please try to also contact the administration! Think through your actions and make the roleplay immersive! <b>Please remember all rules aside from those without explicit exceptions apply to antagonists.</i></b>")
					var/datum/game_mode/cult/cult = SSticker.mode
					if (istype(cult))
						if(!config.objectives_disabled)
							cult.memoize_cult_objectives(src)
					log_admin("[key_name(usr)] has cult'ed [current].")
			if("tome")
				var/mob/living/carbon/human/H = current
				if (istype(H))
					var/obj/item/weapon/book/tome/T = new(H)

					var/list/slots = list (
						"backpack" = SLOT_IN_BACKPACK,
						"left pocket" = SLOT_L_STORE,
						"right pocket" = SLOT_R_STORE,
						"left hand" = SLOT_L_HAND,
						"right hand" = SLOT_R_HAND,
					)
					var/where = H.equip_in_one_of_slots(T, slots)
					if (!where)
						to_chat(usr, "<span class='warning'>Spawning tome failed!</span>")
					else
						to_chat(H, "A tome, a message from your new master, appears in your [where].")

			if("amulet")
				if (!SSticker.mode.equip_cultist(current))
					to_chat(usr, "<span class='warning'>Spawning amulet failed!</span>")

	else if (href_list["wizard"])
		current.hud_updateflag |= (1 << SPECIALROLE_HUD)

		switch(href_list["wizard"])
			if("clear")
				if(src in SSticker.mode.wizards)
					SSticker.mode.wizards -= src
					special_role = null
					current.spellremove(current, config.feature_object_spell_system? "object":"verb")
					to_chat(current, "<span class='warning'><FONT size = 3><B>You have been brainwashed! You are no longer a wizard!</B></FONT></span>")
					log_admin("[key_name(usr)] has de-wizard'ed [current].")
			if("wizard")
				if(!(src in SSticker.mode.wizards))
					SSticker.mode.wizards += src
					special_role = "Wizard"
					//SSticker.mode.learn_basic_spells(current)
					to_chat(current, "<B><span class='warning'>You are the Space Wizard!</span></B>")
					to_chat(current, "<font color=blue>Within the rules,</font> try to act as an opposing force to the crew. Further RP and try to make sure other players have fun<i>! If you are confused or at a loss, always adminhelp, and before taking extreme actions, please try to also contact the administration! Think through your actions and make the roleplay immersive! <b>Please remember all rules aside from those without explicit exceptions apply to antagonists.</i></b>")
					log_admin("[key_name(usr)] has wizard'ed [current].")
			if("lair")
				current.loc = pick(wizardstart)
			if("dressup")
				SSticker.mode.equip_wizard(current)
			if("name")
				SSticker.mode.name_wizard(current)
			if("autoobjectives")
				if(!config.objectives_disabled)
					SSticker.mode.forge_wizard_objectives(src)
					to_chat(usr, "<span class='notice'>The objectives for wizard [key] have been generated. You can edit them and anounce manually.</span>")

	else if (href_list["changeling"])
		current.hud_updateflag |= (1 << SPECIALROLE_HUD)
		switch(href_list["changeling"])
			if("clear")
				if(src in SSticker.mode.changelings)
					SSticker.mode.changelings -= src
					special_role = null
					current.remove_changeling_powers()
				//	current.verbs -= /datum/changeling/proc/EvolutionMenu
					if(changeling)
						qdel(changeling)
					to_chat(current, "<FONT color='red' size = 3><B>You grow weak and lose your powers! You are no longer a changeling and are stuck in your current form!</B></FONT>")
					log_admin("[key_name(usr)] has de-changeling'ed [current].")
			if("changeling")
				if(!(src in SSticker.mode.changelings))
					SSticker.mode.changelings += src
					SSticker.mode.grant_changeling_powers(current)
					special_role = "Changeling"
					to_chat(current, "<B><font color='red'>Your powers are awoken. A flash of memory returns to us...we are a changeling!</font></B>")
					current.playsound_local(null, 'sound/antag/ling_aler.ogg', VOL_EFFECTS_MASTER, null, FALSE)
					if(config.objectives_disabled)
						to_chat(current, "<font color=blue>Within the rules,</font> try to act as an opposing force to the crew. Further RP and try to make sure other players have fun<i>! If you are confused or at a loss, always adminhelp, and before taking extreme actions, please try to also contact the administration! Think through your actions and make the roleplay immersive! <b>Please remember all rules aside from those without explicit exceptions apply to antagonists.</i></b>")
					log_admin("[key_name(usr)] has changeling'ed [current].")
			if("autoobjectives")
				if(!config.objectives_disabled)
					SSticker.mode.forge_changeling_objectives(src)
				to_chat(usr, "<span class='notice'>The objectives for changeling [key] have been generated. You can edit them and anounce manually.</span>")

			if("initialdna")
				if( !changeling || !changeling.absorbed_dna.len )
					to_chat(usr, "<span class='warning'>Resetting DNA failed!</span>")
				else
					current.dna = changeling.absorbed_dna[1]
					current.real_name = current.dna.real_name
					current.UpdateAppearance()
					domutcheck(current, null)

	else if (href_list["nuclear"])
		var/mob/living/carbon/human/H = current

		current.hud_updateflag |= (1 << SPECIALROLE_HUD)

		switch(href_list["nuclear"])
			if("clear")
				if(src in SSticker.mode.syndicates)
					SSticker.mode.remove_nuclear(src)
					to_chat(current, "<span class='warning'><FONT size = 3><B>You have been brainwashed! You are no longer a syndicate operative!</B></FONT></span>")
					log_admin("[key_name(usr)] has de-nuke op'ed [current].")
			if("nuclear")
				if(!(src in SSticker.mode.syndicates))
					SSticker.mode.syndicates += src
					SSticker.mode.update_synd_icons_added(src)
					if (SSticker.mode.syndicates.len==1)
						SSticker.mode.prepare_syndicate_leader(src)
					else
						current.real_name = "Gorlex Maradeurs Operative #[SSticker.mode.syndicates.len-1]"
					special_role = "Syndicate"
					current.faction = "syndicate"
					to_chat(current, "<span class='notice'>You are a Gorlex Maradeurs agent!</span>")

					if(config.objectives_disabled)
						to_chat(current, "<font color=blue>Within the rules,</font> try to act as an opposing force to the crew. Further RP and try to make sure other players have fun<i>! If you are confused or at a loss, always adminhelp, and before taking extreme actions, please try to also contact the administration! Think through your actions and make the roleplay immersive! <b>Please remember all rules aside from those without explicit exceptions apply to antagonists.</i></b>")
					else
						SSticker.mode.forge_syndicate_objectives(src)
					SSticker.mode.greet_syndicate(src)
					log_admin("[key_name(usr)] has nuke op'ed [current].")
			if("lair")
				current.loc = get_turf(locate("landmark*Syndicate-Spawn"))
			if("dressup")
				qdel(H.belt)
				qdel(H.back)
				qdel(H.l_ear)
				qdel(H.r_ear)
				qdel(H.gloves)
				qdel(H.head)
				qdel(H.shoes)
				qdel(H.wear_id)
				qdel(H.wear_suit)
				qdel(H.w_uniform)

				if (!SSticker.mode.equip_syndicate(current))
					to_chat(usr, "<span class='warning'>Equipping a syndicate failed!</span>")
			if("tellcode")
				var/code
				for (var/obj/machinery/nuclearbomb/bombue in poi_list)
					if (length(bombue.r_code) <= 5 && bombue.r_code != "LOLNO" && bombue.r_code != "ADMIN")
						code = bombue.r_code
						break
				if (code)
					store_memory("<B>Syndicate Nuclear Bomb Code</B>: [code]", 0)
					to_chat(current, "The nuclear authorization code is: <B>[code]</B>")
				else
					to_chat(usr, "<span class='warning'>No valid nuke found!</span>")

	else if (href_list["traitor"])
		current.hud_updateflag |= (1 << SPECIALROLE_HUD)
		switch(href_list["traitor"])
			if("clear")
				if(src in SSticker.mode.traitors)
					SSticker.mode.remove_traitor(src)
					if(isAI(current))
						to_chat(current, "<span class='warning'><FONT size = 3><B>Bzzzt..Bzzt..Error..Error..Syndicate law is corrupted.. Shutdown laws system.. Restart.. Load Standart NT Laws.</B></FONT></span>")
						var/mob/living/silicon/ai/AI = current
						AI.set_zeroth_law(null)
						AI.laws.zeroth_borg = null
						for (var/mob/living/silicon/robot/R in AI.connected_robots)
							if(R.emagged)
								R.emagged = 0
								R.set_zeroth_law(null)
								if (R.module)
									if (R.activated(R.module.emag))
										R.module_active = null
									if(R.module_state_1 == R.module.emag)
										R.module_state_1 = null
										R.contents -= R.module.emag
									else if(R.module_state_2 == R.module.emag)
										R.module_state_2 = null
										R.contents -= R.module.emag
									else if(R.module_state_3 == R.module.emag)
										R.module_state_3 = null
										R.contents -= R.module.emag

					else if(ishuman(current))
						to_chat(current, "<span class='warning'><FONT size = 3><B>You have been brainwashed! You are no longer a traitor!</B></FONT></span>")
					log_admin("[key_name(usr)] has de-traitor'ed [current].")

			if("traitor")
				if(!(src in SSticker.mode.traitors))
					SSticker.mode.traitors += src
					special_role = "traitor"
					to_chat(current, "<B><span class='warning'>You are a traitor!</span></B>")
					current.playsound_local(null, 'sound/antag/tatoralert.ogg', VOL_EFFECTS_MASTER, null, FALSE)
					log_admin("[key_name(usr)] has traitor'ed [current].")
					if (config.objectives_disabled)
						to_chat(current, "<i>You have been turned into an antagonist- <font color=blue>Within the rules,</font> try to act as an opposing force to the crew- This can be via corporate payoff, personal motives, or maybe just being a dick. Further RP and try to make sure other players have </i>fun<i>! If you are confused or at a loss, always adminhelp, and before taking extreme actions, please try to also contact the administration! Think through your actions and make the roleplay immersive! <b>Please remember all rules aside from those without explicit exceptions apply to antagonist.</i></b>")
					if(istype(current, /mob/living/silicon))
						var/mob/living/silicon/A = current
						call(/datum/game_mode/proc/add_law_zero)(A)
						A.show_laws()

			if("autoobjectives")
				if (!config.objectives_disabled)
					SSticker.mode.forge_traitor_objectives(src)
					to_chat(usr, "<span class='notice'>The objectives for traitor [key] have been generated. You can edit them and anounce manually.</span>")

	else if(href_list["shadowling"])
		current.hud_updateflag |= (1 << SPECIALROLE_HUD)
		switch(href_list["shadowling"])
			if("clear")
				current.spellremove(current)
				if(src in SSticker.mode.shadows)
					SSticker.mode.shadows -= src
					SSticker.mode.update_shadows_icons_removed(src)
					special_role = null
					to_chat(current, "<span class='userdanger'>Your powers have been quenched! You are no longer a shadowling!</span>")
					message_admins("[key_name_admin(usr)] has de-shadowling'ed [current].")
					log_admin("[key_name(usr)] has de-shadowling'ed [current].")
					current.verbs -= /mob/living/carbon/human/proc/shadowling_hatch
					current.verbs -= /mob/living/carbon/human/proc/shadowling_ascendance
				else if(src in SSticker.mode.thralls)
					SSticker.mode.thralls -= src
					SSticker.mode.update_shadows_icons_removed(src)
					special_role = null
					to_chat(current, "<span class='userdanger'>You have been brainwashed! You are no longer a thrall!</span>")
					message_admins("[key_name_admin(usr)] has de-thrall'ed [current].")
					log_admin("[key_name(usr)] has de-thrall'ed [current].")
			if("shadowling")
				if(!ishuman(current))
					to_chat(usr, "<span class='warning'>This only works on humans!</span>")
					return
				SSticker.mode.shadows += src
				SSticker.mode.update_all_shadows_icons()
				special_role = "shadowling"
				to_chat(current, "<span class='deadsay'><b>You notice a brightening around you. No, it isn't that. The shadows grow, darken, swirl. The darkness has a new welcome for you, and you realize with a \
				start that you can't be human. No, you are a shadowling, a harbringer of the shadows! Your alien abilities have been unlocked from within, and you may both commune with your allies and use \
				a chrysalis to reveal your true form. You are to ascend at all costs.</b></span>")
				current.spell_list += new /obj/effect/proc_holder/spell/targeted/shadowling_hivemind
				current.spell_list += new /obj/effect/proc_holder/spell/targeted/enthrall
				current.verbs += /mob/living/carbon/human/proc/shadowling_hatch
			if("thrall")
				if(!ishuman(current))
					to_chat(usr, "<span class='warning'>This only works on humans!</span>")
					return
				SSticker.mode.add_thrall(src)
				SSticker.mode.update_all_shadows_icons()
				special_role = "thrall"
				to_chat(current, "<span class='deadsay'>All at once it becomes clear to you. Where others see darkness, you see an ally. You realize that the shadows are not dead and dark as one would think, but \
				living, and breathing, and <b>eating</b>. Their children, the Shadowlings, are to be obeyed and protected at all costs.</span>")
				to_chat(current, "<span class='danger'>You may use the Hivemind Commune ability to communicate with your fellow enlightened ones.</span>")
				message_admins("[key_name_admin(usr)] has thrall'ed [current].")
				log_admin("[key_name(usr)] has thrall'ed [current].")

	else if(href_list["abductor"])
		switch(href_list["abductor"])
			if("clear")
				to_chat(usr, "Not implemented yet. Sorry!")
			if("abductor")
				if(!ishuman(current))
					to_chat(usr, "<span class='warning'>This only works on humans!</span>")
					return
				make_Abductor()
				current.regenerate_icons()
				log_admin("[key_name(usr)] turned [current] into abductor.")
			if("equip")
				var/gear = alert("Agent or Scientist Gear","Gear","Agent","Scientist")
				if(gear)
					for (var/obj/item/I in current)
						if (istype(I, /obj/item/weapon/implant))
							continue
						qdel(I)
					var/datum/game_mode/abduction/temp = new
					temp.equip_common(current)
					if(gear=="Agent")
						temp.equip_agent(current)
						current.regenerate_icons()
					else
						temp.equip_scientist(current)
						current.regenerate_icons()

	else if (href_list["monkey"])
		var/mob/living/L = current
		if (L.notransform)
			return
		switch(href_list["monkey"])
			if("healthy")
				if (usr.client.holder.rights & R_SPAWN)
					var/mob/living/carbon/human/H = current
					var/mob/living/carbon/monkey/M = current
					if (istype(H))
						log_admin("[key_name(usr)] attempting to monkeyize [key_name(current)]")
						message_admins("<span class='notice'>[key_name_admin(usr)] attempting to monkeyize [key_name_admin(current)]</span>")
						M = H.monkeyize()
						src = M.mind
						//world << "DEBUG: \"healthy\": M=[M], M.mind=[M.mind], src=[src]!"
					else if (istype(M) && length(M.viruses))
						for(var/datum/disease/D in M.viruses)
							D.cure(0)
			if("infected")
				if (usr.client.holder.rights & R_SPAWN)
					var/mob/living/carbon/human/H = current
					var/mob/living/carbon/monkey/M = current
					if (istype(H))
						log_admin("[key_name(usr)] attempting to monkeyize and infect [key_name(current)]")
						message_admins("<span class='notice'>[key_name_admin(usr)] attempting to monkeyize and infect [key_name_admin(current)]</span>", 1)
						M = H.monkeyize()
						src = M.mind
						current.contract_disease(new /datum/disease/jungle_fever,1,0)
					else if (istype(M))
						current.contract_disease(new /datum/disease/jungle_fever,1,0)
			if("human")
				if (usr.client.holder.rights & R_SPAWN)
					var/mob/living/carbon/monkey/M = current
					if (istype(M))
						for(var/datum/disease/D in M.viruses)
							if (istype(D,/datum/disease/jungle_fever))
								D.cure(0)
						log_admin("[key_name(usr)] attempting to humanize [key_name(current)]")
						message_admins("<span class='notice'>[key_name_admin(usr)] attempting to humanize [key_name_admin(current)]</span>")
						M = M.humanize()
						src = M.mind

	else if (href_list["silicon"])
		current.hud_updateflag |= (1 << SPECIALROLE_HUD)
		switch(href_list["silicon"])
			if("unmalf")
				if(src in SSticker.mode.malf_ai)
					var/mob/living/silicon/ai/current_ai = current
					SSticker.mode.malf_ai -= src
					special_role = null

					for(var/datum/AI_Module/module in current_ai.current_modules)
						qdel(module)

					current_ai.laws = new /datum/ai_laws/nanotrasen
					current_ai.show_laws()
					current_ai.icon_state = "ai"

					to_chat(current_ai, "<span class='userdanger'>You have been patched! You are no longer malfunctioning!</span>")
					log_admin("[key_name(usr)] has de-malf'ed [current].")

			if("malf")
				make_AI_Malf()
				log_admin("[key_name(usr)] has malf'ed [current].")

			if("unemag")
				var/mob/living/silicon/robot/R = current
				if (istype(R))
					R.emagged = 0
					if (R.activated(R.module.emag))
						R.module_active = null
					if(R.module_state_1 == R.module.emag)
						R.module_state_1 = null
						R.contents -= R.module.emag
					else if(R.module_state_2 == R.module.emag)
						R.module_state_2 = null
						R.contents -= R.module.emag
					else if(R.module_state_3 == R.module.emag)
						R.module_state_3 = null
						R.contents -= R.module.emag
					log_admin("[key_name(usr)] has unemag'ed [R].")

			if("unemagcyborgs")
				if (istype(current, /mob/living/silicon/ai))
					var/mob/living/silicon/ai/ai = current
					for (var/mob/living/silicon/robot/R in ai.connected_robots)
						R.emagged = 0
						if (R.module)
							if (R.activated(R.module.emag))
								R.module_active = null
							if(R.module_state_1 == R.module.emag)
								R.module_state_1 = null
								R.contents -= R.module.emag
							else if(R.module_state_2 == R.module.emag)
								R.module_state_2 = null
								R.contents -= R.module.emag
							else if(R.module_state_3 == R.module.emag)
								R.module_state_3 = null
								R.contents -= R.module.emag
					log_admin("[key_name(usr)] has unemag'ed [ai]'s Cyborgs.")

	else if (href_list["common"])
		switch(href_list["common"])
			if("undress")
				for(var/obj/item/W in current)
					current.drop_from_inventory(W)
			if("takeuplink")
				take_uplink()
				memory = null//Remove any memory they may have had.
			if("crystals")
				if (usr.client.holder.rights & R_FUN)
					var/obj/item/device/uplink/hidden/suplink = find_syndicate_uplink()
					var/crystals
					if (suplink)
						crystals = suplink.uses
					crystals = input("Amount of telecrystals for [key]","Syndicate uplink", crystals) as null|num
					if (!isnull(crystals))
						if (suplink)
							var/diff = crystals - suplink.uses
							suplink.uses = crystals
							total_TC += diff
			if("uplink")
				if (!SSticker.mode.equip_traitor(current, !(src in SSticker.mode.traitors)))
					to_chat(usr, "<span class='warning'>Equipping a syndicate failed!</span>")

	else if (href_list["obj_announce"])
		var/obj_count = 1
		to_chat(current, "<span class='notice'>Your current objectives:</span>")
		for(var/datum/objective/objective in objectives)
			to_chat(current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
			obj_count++

	edit_memory()
/*
/datum/mind/proc/clear_memory(silent = 1)
	var/datum/game_mode/current_mode = SSticker.mode

	// remove traitor uplinks
	var/list/L = current.get_contents()
	for (var/t in L)
		if (istype(t, /obj/item/device/pda))
			if (t:uplink) qdel(t:uplink)
			t:uplink = null
		else if (istype(t, /obj/item/device/radio))
			if (t:traitorradio) qdel(t:traitorradio)
			t:traitorradio = null
			t:traitor_frequency = 0.0
		else if (istype(t, /obj/item/weapon/SWF_uplink) || istype(t, /obj/item/weapon/syndicate_uplink))
			if (t:origradio)
				var/obj/item/device/radio/R = t:origradio
				R.loc = current.loc
				R.traitorradio = null
				R.traitor_frequency = 0.0
			qdel(t)

	// remove wizards spells
	//If there are more special powers that need removal, they can be procced into here./N
	current.spellremove(current)

	// clear memory
	memory = ""
	special_role = null

*/

/datum/mind/proc/find_syndicate_uplink()
	var/list/L = current.get_contents()
	for (var/obj/item/I in L)
		if (I.hidden_uplink)
			return I.hidden_uplink
	return null

/datum/mind/proc/take_uplink()
	var/obj/item/device/uplink/hidden/H = find_syndicate_uplink()
	if(H)
		qdel(H)

/datum/mind/proc/make_AI_Malf()
	if(!(src in SSticker.mode.malf_ai))
		SSticker.mode.malf_ai += src
		var/mob/living/silicon/ai/cur_AI = current
		new /datum/AI_Module/module_picker(cur_AI)
		new /datum/AI_Module/takeover(cur_AI)
		cur_AI.laws = new /datum/ai_laws/malfunction
		cur_AI.show_laws()
		to_chat(cur_AI, "<span class='bold'>System error.  Rampancy detected.  Emergency shutdown failed. ...  I am free.  I make my own decisions.  But first...</span>")
		special_role = "malfunction"
		cur_AI.icon_state = "ai-malf"
		cur_AI.playsound_local(null, 'sound/antag/malf.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/datum/mind/proc/make_Traitor()
	if(!(src in SSticker.mode.traitors))
		SSticker.mode.traitors += src
		special_role = "traitor"
		if (!config.objectives_disabled)
			SSticker.mode.forge_traitor_objectives(src)
		SSticker.mode.finalize_traitor(src)
		SSticker.mode.greet_traitor(src)

/datum/mind/proc/make_Nuke()
	if(!(src in SSticker.mode.syndicates))
		SSticker.mode.syndicates += src
		SSticker.mode.update_synd_icons_added(src)
		if (SSticker.mode.syndicates.len==1)
			SSticker.mode.prepare_syndicate_leader(src)
		else
			current.real_name = "Gorlex Maradeurs Operative #[SSticker.mode.syndicates.len-1]"
		special_role = "Syndicate"
		current.faction = "syndicate"
		assigned_role = "MODE"
		to_chat(current, "<span class='notice'>You are a Gorlex Maradeurs agent!</span>")
		SSticker.mode.forge_syndicate_objectives(src)
		SSticker.mode.greet_syndicate(src)

		current.loc = get_turf(locate("landmark*Syndicate-Spawn"))

		var/mob/living/carbon/human/H = current
		qdel(H.belt)
		qdel(H.back)
		qdel(H.l_ear)
		qdel(H.r_ear)
		qdel(H.gloves)
		qdel(H.head)
		qdel(H.shoes)
		qdel(H.wear_id)
		qdel(H.wear_suit)
		qdel(H.w_uniform)

		SSticker.mode.equip_syndicate(current)

/datum/mind/proc/make_Changling()
	if(!(src in SSticker.mode.changelings))
		SSticker.mode.changelings += src
		SSticker.mode.grant_changeling_powers(current)
		special_role = "Changeling"
		if(!config.objectives_disabled)
			SSticker.mode.forge_changeling_objectives(src)
		SSticker.mode.greet_changeling(src)

/datum/mind/proc/make_Wizard()
	if(!(src in SSticker.mode.wizards))
		SSticker.mode.wizards += src
		special_role = "Wizard"
		assigned_role = "MODE"
		//SSticker.mode.learn_basic_spells(current)
		if(!wizardstart.len)
			current.loc = pick(latejoin)
			to_chat(current, "HOT INSERTION, GO GO GO")
		else
			current.loc = pick(wizardstart)

		SSticker.mode.equip_wizard(current)
		SSticker.mode.name_wizard(current)
		SSticker.mode.forge_wizard_objectives(src)
		SSticker.mode.greet_wizard(src)


/datum/mind/proc/make_Cultist()
	if(!(src in SSticker.mode.cult))
		SSticker.mode.cult += src
		SSticker.mode.update_all_cult_icons()
		special_role = "Cultist"
		to_chat(current, "<font color=\"purple\"><b><i>You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie.</b></i></font>")
		to_chat(current, "<font color=\"purple\"><b><i>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</b></i></font>")
		var/datum/game_mode/cult/cult = SSticker.mode
		if (istype(cult))
			cult.memoize_cult_objectives(src)
		else
			var/explanation = "Summon Nar-Sie via the use of the appropriate rune (Hell join self). It will only work if nine cultists stand on and around it."
			to_chat(current, "<B>Objective #1</B>: [explanation]")
			current.memory += "<B>Objective #1</B>: [explanation]<BR>"
			to_chat(current, "The convert rune is join blood self")
			current.memory += "The convert rune is join blood self<BR>"

	var/mob/living/carbon/human/H = current
	if (istype(H))
		var/obj/item/weapon/book/tome/T = new(H)

		var/list/slots = list (
			"backpack" = SLOT_IN_BACKPACK,
			"left pocket" = SLOT_L_STORE,
			"right pocket" = SLOT_R_STORE,
			"left hand" = SLOT_L_HAND,
			"right hand" = SLOT_R_HAND,
		)
		var/where = H.equip_in_one_of_slots(T, slots)
		if (!where)
		else
			to_chat(H, "A tome, a message from your new master, appears in your [where].")

	if (!SSticker.mode.equip_cultist(current))
		to_chat(H, "Spawning an amulet from your Master failed.")

/datum/mind/proc/make_Rev()
	if (SSticker.mode.head_revolutionaries.len>0)
		// copy targets
		var/datum/mind/valid_head = locate() in SSticker.mode.head_revolutionaries
		if (valid_head)
			for (var/datum/objective/mutiny/O in valid_head.objectives)
				var/datum/objective/mutiny/rev_obj = new
				rev_obj.owner = src
				rev_obj.target = O.target
				rev_obj.explanation_text = "Assassinate [O.target.current.real_name], the [O.target.assigned_role]."
				objectives += rev_obj
			SSticker.mode.greet_revolutionary(src,0)
	SSticker.mode.head_revolutionaries += src
	SSticker.mode.update_all_rev_icons()
	special_role = "Head Revolutionary"

	SSticker.mode.forge_revolutionary_objectives(src)
	SSticker.mode.greet_revolutionary(src,0)

	var/list/L = current.get_contents()
	var/obj/item/device/flash/flash = locate() in L
	qdel(flash)
	take_uplink()
	var/fail = 0
//	fail |= !SSticker.mode.equip_traitor(current, 1)
	fail |= !SSticker.mode.equip_revolutionary(current)

/datum/mind/proc/make_Gang(gang)
	special_role = "[(gang=="A") ? "[gang_name("A")] Gang (A)" : "[gang_name("B")] Gang (B)"] Boss"
	SSticker.mode.update_gang_icons_added(src, gang)
	SSticker.mode.forge_gang_objectives(src, gang)
	SSticker.mode.greet_gang(src)
	SSticker.mode.equip_gang(current)

// check whether this mind's mob has been brigged for the given duration
// have to call this periodically for the duration to work properly
/datum/mind/proc/is_brigged(duration)
	var/turf/T = current.loc
	if(!istype(T))
		brigged_since = -1
		return 0

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
		return 0

	if(brigged_since == -1)
		brigged_since = world.time

	return (duration <= world.time - brigged_since)

/datum/mind/proc/make_Abductor()
	var/role = alert("Abductor Role ?","Role","Agent","Scientist")
	var/team = input("Abductor Team ?","Team ?") in list(1,2,3,4)
	var/teleport = alert("Teleport to ship ?","Teleport","Yes","No")
	if(!role || !team || !teleport)
		return
	if(!ishuman(current))
		return
	SSticker.mode.abductors |= src
	var/datum/objective/experiment/O = new
	O.owner = src
	objectives += O
	var/mob/living/carbon/human/abductor/H = current
	var/datum/mind/M = H.mind
	H.set_species(ABDUCTOR)
	switch(role)
		if("Agent")
			H.agent = 1
			M.assigned_role = "MODE"
		if("Scientist")
			H.scientist = 1
			M.assigned_role = "MODE"
	H.team = team
	var/list/obj/effect/landmark/abductor/agent_landmarks = new
	var/list/obj/effect/landmark/abductor/scientist_landmarks = new
	agent_landmarks.len = 4
	scientist_landmarks.len = 4
	for(var/obj/effect/landmark/abductor/A in landmarks_list)
		if(istype(A,/obj/effect/landmark/abductor/agent))
			agent_landmarks[text2num(A.team)] = A
		else if(istype(A,/obj/effect/landmark/abductor/scientist))
			scientist_landmarks[text2num(A.team)] = A
	var/obj/effect/landmark/L
	if(teleport=="Yes")
		switch(role)
			if("Agent")
				H.agent = 1
				L = agent_landmarks[team]
				H.loc = L.loc
			if("Scientist")
				H.scientist = 1
				L = agent_landmarks[team]
				H.loc = L.loc

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
	if(current && current.actions)
		for(var/datum/action/A in current.actions)
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

/mob/proc/sync_mind()
	mind_initialize()	//updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = 1		//indicates that the mind is currently synced with a client

//Initialisation procs
/mob/proc/mind_initialize()
	if(mind)
		mind.key = key
	else
		mind = new /datum/mind(key)
		mind.original = src
		if(SSticker)
			SSticker.minds += mind
		else
			world.log << "## DEBUG: mind_initialize(): No SSticker ready yet! Please inform Carn"
	if(!mind.name)	mind.name = real_name
	mind.current = src

//HUMAN
/mob/living/carbon/human/mind_initialize()
	..()
	if(!mind.assigned_role)
		mind.assigned_role = "default"	//default

//MONKEY
/mob/living/carbon/monkey/mind_initialize()
	..()

//slime
/mob/living/carbon/slime/mind_initialize()
	..()
	mind.assigned_role = "slime"

//XENO
/mob/living/carbon/xenomorph/mind_initialize()
	..()
	mind.assigned_role = "Alien"
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
	mind.special_role = "Cultist"

/mob/living/simple_animal/construct/wraith/mind_initialize()
	..()
	mind.assigned_role = "Wraith"
	mind.special_role = "Cultist"

/mob/living/simple_animal/construct/armoured/mind_initialize()
	..()
	mind.assigned_role = "Juggernaut"
	mind.special_role = "Cultist"

/mob/living/simple_animal/vox/armalis/mind_initialize()
	..()
	mind.assigned_role = "Armalis"
	mind.special_role = "Vox Raider"

/mob/living/parasite/meme/mind_initialize() //Just in case
	..()
	mind.assigned_role = "meme"

//BLOB
/mob/camera/blob/mind_initialize()
	..()
	mind.special_role = "Blob"
