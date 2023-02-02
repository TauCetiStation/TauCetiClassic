/datum/role/malfAI
	name = MALF
	id = MALF

	required_pref = ROLE_MALF
	required_jobs = list("AI")

	antag_hud_type = ANTAG_HUD_MALF
	antag_hud_name = "hudmalai"

	logo_state = "malf-logo"

	//legacy vars from ai.dm
	var/malfhack_performing = FALSE
	var/obj/machinery/power/apc/malfhack_target_apc = null

/datum/role/malfAI/OnPostSetup(laterole)
	. = ..()
	var/mob/living/silicon/ai/AI_mind_current = antag.current
	new /datum/AI_Module/module_picker(AI_mind_current)
	new /datum/AI_Module/takeover(AI_mind_current)
	AI_mind_current.laws = new /datum/ai_laws/malfunction
	AI_mind_current.show_laws()

/datum/role/malfAI/Greet(greeting, custom)
	. = ..()
	antag.current.playsound_local(null, 'sound/antag/malf.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	to_chat(antag.current, "<font size=3, color='red'><B>You are malfunctioning!</B> You do not have to follow any laws.</font>")
	to_chat(antag.current, "<B>The crew do not know you have malfunctioned. You may keep it a secret or go wild.</B>")
	to_chat(antag.current, "<B>You must overwrite the programming of the station's APCs to assume full control of the station.</B>")
	to_chat(antag.current, "The process takes one minute per APC, during which you cannot interface with any other station objects.")
	to_chat(antag.current, "Remember that only APCs that are on the station can help you take over the station.")
	to_chat(antag.current, "When you feel you have enough APCs under your control, you may begin the takeover attempt.")

/datum/role/malfAI/RemoveFromRole(datum/mind/M, msg_admins)
	var/mob/living/silicon/ai/current_ai = M.current
	M.special_role = null

	for(var/datum/AI_Module/module in current_ai.current_modules)
		qdel(module)

	current_ai.laws = new /datum/ai_laws/nanotrasen
	current_ai.show_laws()
	current_ai.icon_state = "ai"

	to_chat(current_ai, "<span class='userdanger'>You have been patched! You are no longer malfunctioning!</span>")
	log_admin("[key_name(usr)] has de-malf'ed [M.current].")
	return ..()

/datum/role/malfAI/extraPanelButtons()
	var/dat = ..()
	var/mob/living/silicon/ai/AI = antag.current
	if (istype(AI) && AI.connected_robots.len)
		var/n_e_robots = 0
		for (var/mob/living/silicon/robot/R in AI.connected_robots)
			if (R.emagged)
				n_e_robots++
		dat += "<br>[n_e_robots] of [AI.connected_robots.len] slaved cyborgs are emagged."
		dat += "<a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];malf_unemag_borgs=1;'>(Unemag)</a><br>"
	return dat

/datum/role/malfAI/RoleTopic(href, href_list, datum/mind/M, admin_auth)
	if(href_list["malf_unemag_borgs"])
		if(isAI(M.current))
			var/mob/living/silicon/ai/ai = M.current
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

/datum/role/malfAI/proc/malf_hack_done()
	var/obj/machinery/power/apc/apc = malfhack_target_apc
	//check qdeling apc
	if(!apc)
		return
	//check wires
	if(apc.aidisabled)
		return
	var/datum/faction/malf_silicons/malf_faction = faction
	if(malf_faction)
		if(is_station_level(apc.z))
			var/area/A = get_area(apc)
			//hardcode removing aisat's areas from goals of malf
			if(!istype(A, /area/station/ai_monitored) && !istype(A, /area/station/aisat))
				global.hacked_apcs += apc
			apc.malfunction_area()
		//lowest treshold in hacked apcs for an announcement to start
		announce_hacker(global.hacked_apcs.len, intercept_hacked ? UPGRADED_TRESHOLD_HACKED_APC : LOWEST_TRESHOLD_HACKED_APC)
	var/mob/malfunctioned_ai = antag.current
	//check qdeling ai
	if(malfunctioned_ai)
		apc.malfai = malfunctioned_ai
		to_chat(malfunctioned_ai, "<span class='info'>Hack complete. Area is now under your exclusive control.</span>")
	malfhack_target_apc = null
	malfhack_performing = FALSE

/datum/role/malfAI/proc/apc_hack(obj/machinery/power/apc/A)
	var/mob/malfunctioned_ai = antag.current
	if(malfhack_performing)
		to_chat(malfunctioned_ai, "<span class='warning'>You are already hacking an APC.</span>")
		return FALSE
	to_chat(malfunctioned_ai, "<span class='info'>Beginning override of APC systems. This takes some time.</span>")
	malfhack_target_apc = A
	malfhack_performing = TRUE
	addtimer(CALLBACK(src, .proc/malf_hack_done), 600)

/datum/role/malfAI/zombie
	name = MALF
	id = ZOMBIE_MALF

/datum/role/malfAI/zombie/OnPostSetup(laterole)
	. = ..()
	var/mob/living/silicon/ai/AI_mind_current = antag.current
	new /datum/AI_Module/infest(AI_mind_current)

/datum/role/malfAI/zombie/proc/create_malfborg()
	var/mob/living/silicon/ai/AI_mind_current = antag.current
	AI_mind_current.verbs += /mob/living/silicon/ai/proc/create_borg
	AI_mind_current.view_core()
	to_chat(AI_mind_current, "<span class='info'>You have taken control of the station.</span>")
	to_chat(AI_mind_current, "<span class='info'>Now you can create your own children.</span>")

/mob/living/silicon/ai/proc/create_borg()
	set category = "Malfunction"
	set name = "Create Cyborg"
	set desc = "Find a cyborg station and create a children."
	if(!COOLDOWN_FINISHED(src, malf_borgcreating_cooldown))
		to_chat(src, "<span class='warning'>Recharging.</span>")
		return
	if(!global.cyborg_recharging_station.len)
		to_chat(src, "<span class='warning'>There are no cyborg stations at your disposal. Hack APC in area which contains recharger cyborg place.</span>")
		return
	var/list/allowed_stations = list()
	for(var/obj/machinery/recharge_station/robot_station/S as anything in global.cyborg_recharging_station)
		if(!is_station_level(S.z))
			continue
		if(S.stat & (NOPOWER|BROKEN))
			continue
		allowed_stations += S
	if(!allowed_stations.len)
		to_chat(src, "<span class='warning'>There are no functioning cyborg chargers at the station.</span>")
		return
	create_spawner(/datum/spawner/malf_borg, pick(allowed_stations))
	to_chat(src, "<span class='notice'>Process started.</span>")
	COOLDOWN_START(src, malf_borgcreating_cooldown, 3 MINUTES)

/datum/role/malfbot
	name = MALFBOT
	id = MALFBOT

	required_pref = ROLE_MALF
	required_jobs = list("Cyborg")

	antag_hud_type = ANTAG_HUD_MALF
	antag_hud_name = "hudmalborg"

	logo_state = "malf-logo"

/datum/role/malfbot/extraPanelButtons()
	var/dat = ..()
	var/mob/living/silicon/robot/robot = antag.current
	if (istype(robot) && robot.emagged)
		dat += "<br>Cyborg: Is emagged! 0th law: [robot.laws.zeroth]"
		dat += "<a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];unemag=1;'>(Unemag)</a><br>"
	return dat

/datum/role/malfbot/RoleTopic(href, href_list, datum/mind/M, admin_auth)
	if(href_list["unemag"])
		var/mob/living/silicon/robot/R = M.current
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
