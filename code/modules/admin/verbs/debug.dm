/client/proc/Debug2()
	set category = "Debug"
	set name = "Debug-Game"
	if(!check_rights(R_DEBUG))	return

	if(Debug2)
		Debug2 = 0
		message_admins("[key_name(src)] toggled debugging off.")
		log_admin("[key_name(src)] toggled debugging off.")
	else
		Debug2 = 1
		message_admins("[key_name(src)] toggled debugging on.")
		log_admin("[key_name(src)] toggled debugging on.")

	feedback_add_details("admin_verb","DG2") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_profiler()
	set category = "Debug"
	set name = "Toggle Profiler"

	if(!check_rights(R_DEBUG))
		return

	if(tgui_alert(usr, "Be sure you know what you are doing. You want to [config.auto_profile ? "STOP": "START"] Byond Profiler?",, list("Yes","No")) != "Yes")
		return

	config.auto_profile = !config.auto_profile

	if(config.auto_profile)
		SSprofiler.StartProfiling()
	else
		SSprofiler.StopProfiling()

	message_admins("[key_name(src)] toggled byond profiler [config.auto_profile ? "on" : "off"].")
	log_admin("[key_name(src)] toggled byond profiler [config.auto_profile ? "on" : "off"].")

/* 21st Sept 2010
Updated by Skie -- Still not perfect but better!
Stuff you can't do:
Call proc /mob/proc/make_dizzy() for some player
Because if you select a player mob as owner it tries to do the proc for
/mob/living/carbon/human instead. And that gives a run-time error.
But you can call procs that are of type /mob/living/carbon/human/proc for that player.
*/

/client/proc/callproc()
	set category = "Debug"
	set name = "Advanced ProcCall"

	if(!check_rights(R_PERMISSIONS))
		return

/client/proc/Cell()
	set category = "Debug"
	set name = "Air Status in Location"
	if(!mob)
		return
	var/turf/T = mob.loc

	if (!( istype(T, /turf) ))
		return

	var/datum/gas_mixture/env = T.return_air()

	var/t = "<span class='notice'>Coordinates: [COORD(T)]</span>\n"
	t += "<span class='warning'>Temperature: [env.temperature]</span>\n"
	t += "<span class='warning'>Pressure: [env.return_pressure()]kPa</span>\n"
	for(var/g in env.gas)
		t += "<span class='notice'>[g]: [env.gas[g]] / [env.gas[g] * R_IDEAL_GAS_EQUATION * env.temperature / env.volume]kPa</span>\n"


	to_chat(usr, t)
	feedback_add_details("admin_verb","ASL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_robotize(mob/M in mob_list)
	set category = "Fun"
	set name = "Make Robot"

	if(!SSticker)
		tgui_alert(usr, "Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has robotized [M.key].")
		spawn(10)
			M:Robotize()

	else
		tgui_alert(usr, "Invalid mob")

/client/proc/cmd_admin_animalize(mob/M in mob_list)
	set category = "Fun"
	set name = "Make Simple Animal"

	if(!SSticker)
		tgui_alert(usr, "Wait until the game starts")
		return

	if(!M)
		tgui_alert(usr, "That mob doesn't seem to exist, close the panel and try again.")
		return

	if(isnewplayer(M))
		tgui_alert(usr, "The mob must not be a new_player.")
		return

	log_admin("[key_name(src)] has animalized [M.key].")
	spawn(10)
		M.Animalize()


/client/proc/makepAI(turf/T in mob_list)
	set category = "Fun"
	set name = "Make pAI"
	set desc = "Specify a location to spawn a pAI device, then specify a key to play that pAI."

	var/list/available = list()
	for(var/mob/C as anything in mob_list)
		if(C.key)
			available.Add(C)
	var/mob/choice = input("Choose a player to play the pAI", "Spawn pAI") in available
	if(!choice)
		return 0
	if(!isobserver(choice))
		var/confirm = input("[choice.key] isn't ghosting right now. Are you sure you want to yank him out of them out of their body and place them in this pAI?", "Spawn pAI Confirmation", "No") in list("Yes", "No")
		if(confirm != "Yes")
			return 0
	var/obj/item/device/paicard/card = new(T)
	var/mob/living/silicon/pai/pai = new(card)
	pai.name = sanitize_safe(input(choice, "Enter your pAI name:", "pAI Name", "Personal AI") as text, MAX_NAME_LEN)
	pai.real_name = pai.name
	pai.key = choice.key
	card.setPersonality(pai)
	for(var/datum/paiCandidate/candidate in paiController.pai_candidates)
		if(candidate.key == choice.key)
			paiController.pai_candidates.Remove(candidate)
	feedback_add_details("admin_verb","MPAI") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_alienize(mob/M in mob_list)
	set category = "Fun"
	set name = "Make Alien"

	if(!SSticker)
		tgui_alert(usr, "Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has alienized [key_name(M)].")
		spawn(10)
			M:Alienize()
			feedback_add_details("admin_verb","MKAL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(usr)] made [key_name(M)] into an alien.")
		message_admins("<span class='notice'>[key_name_admin(usr)] made [key_name(M)] into an alien.</span>")
	else
		tgui_alert(usr, "Invalid mob")

/client/proc/cmd_admin_slimeize(mob/M in mob_list)
	set category = "Fun"
	set name = "Make slime"

	if(!SSticker)
		tgui_alert(usr, "Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has slimeized [key_name(M)].")
		spawn(10)
			M:slimeize()
			feedback_add_details("admin_verb","MKMET") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(usr)] made [key_name(M)] into a slime.")
		message_admins("<span class='notice'>[key_name_admin(usr)] made [key_name(M)] into a slime.</span>")
	else
		tgui_alert(usr, "Invalid mob")

/client/proc/cmd_admin_blobize(mob/M in mob_list)
	set category = "Fun"
	set name = "Make Blob"

	if(!SSticker)
		tgui_alert(usr, "Wait until the game starts")
		return
	log_admin("[key_name(src)] has blobized [key_name(M)].")
	addtimer(CALLBACK(M, TYPE_PROC_REF(/mob, Blobize)), 1 SECOND)

//TODO: merge the vievars version into this or something maybe mayhaps
/client/proc/cmd_debug_del_all()
	set category = "Debug"
	set name = "Del-All"

	// to prevent REALLY stupid deletions
	var/blocked = list(/obj, /mob, /mob/living, /mob/living/carbon, /mob/living/carbon/human, /mob/dead, /mob/dead/observer, /mob/living/silicon, /mob/living/silicon/robot, /mob/living/silicon/ai)
	var/hsbitem = input(usr, "Choose an object to delete.", "Delete:") as null|anything in typesof(/obj) + typesof(/mob) - blocked
	if(hsbitem)
		for(var/atom/O in world)
			if(istype(O, hsbitem))
				qdel(O)
			CHECK_TICK
		log_admin("[key_name(src)] has deleted all instances of [hsbitem].")
		message_admins("[key_name_admin(src)] has deleted all instances of [hsbitem].")
	feedback_add_details("admin_verb","DELA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_debug_make_powernets()
	set category = "Debug"
	set name = "Make Powernets"
	SSmachines.makepowernets()
	log_admin("[key_name(src)] has remade the powernet. makepowernets() called.")
	message_admins("[key_name_admin(src)] has remade the powernets. makepowernets() called.")
	feedback_add_details("admin_verb","MPWN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/cmd_debug_load_junkyard()
	set category = "Debug"
	set name = "Load Junkyard"
	SSjunkyard.populate_junkyard()

	//todo: safe gate ref in map datum
	for(var/obj/machinery/gateway/center/G in gateways_list)
		if (G.name == "Junkyard Gateway")
			G.toggleon()

	log_admin("[key_name(src)] pupulated junkyard. SSjunkyard.populate_junkyard() called.")
	message_admins("[key_name_admin(src)] pupulated junkyard. SSjunkyard.populate_junkyard() called.")
	feedback_add_details("admin_verb","PPJYD") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!



/client/proc/cmd_debug_tog_aliens()
	set category = "Server"
	set name = "Toggle Aliens"

	aliens_allowed = !aliens_allowed
	log_admin("[key_name(src)] has turned aliens [aliens_allowed ? "on" : "off"].")
	message_admins("[key_name_admin(src)] has turned aliens [aliens_allowed ? "on" : "off"].")
	feedback_add_details("admin_verb","TAL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_debug_tog_vcounter()
	set category = "Server"
	set name = "Toggle Visual Counters"

	visual_counter = !visual_counter
	log_admin("[key_name(src)] has turned visual counters [visual_counter ? "on" : "off"].")
	message_admins("[key_name_admin(src)] has turned visual counters [visual_counter ? "on" : "off"].")
	feedback_add_details("admin_verb","TVC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_message_spam_control()
	set category = "Server"
	set name = "Global Message Cooldown"

	global_message_cooldown = !global_message_cooldown
	log_admin("[key_name(src)] has turned global message cooldown [global_message_cooldown ? "on" : "off"].")
	message_admins("[key_name_admin(src)] has turned global message cooldown [global_message_cooldown ? "on" : "off"].")
	feedback_add_details("admin_verb","TGMC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_grantfullaccess(mob/M in mob_list)
	set category = "Admin"
	set name = "Grant Full Access"

	if (!SSticker)
		tgui_alert(usr, "Wait until the game starts")
		return
	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		if (H.wear_id)
			var/obj/item/weapon/card/id/id = H.wear_id
			if(istype(H.wear_id, /obj/item/device/pda))
				var/obj/item/device/pda/pda = H.wear_id
				id = pda.id
			id.icon_state = "gold"
			id:access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
		else
			var/obj/item/weapon/card/id/id = new/obj/item/weapon/card/id(M);
			id.icon_state = "gold"
			id:access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
			id.assignment = "Captain"
			id.assign(H.real_name)
			H.equip_to_slot_or_del(id, SLOT_WEAR_ID)
	else
		tgui_alert(usr, "Invalid mob")
	feedback_add_details("admin_verb","GFA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(src)] has granted [key_name(M)] full access.")
	message_admins("<span class='notice'>[key_name_admin(usr)] has granted [key_name_admin(M)] full access.</span>")

/client/proc/cmd_assume_direct_control(mob/M in mob_list)
	set category = "Admin"
	set name = "Assume direct control"
	set desc = "Direct intervention."

	if(!check_rights(R_DEBUG|R_ADMIN))
		return
	if(M.ckey)
		if(tgui_alert(usr, "This mob is being controlled by [M.ckey]. Are you sure you wish to assume control of it? [M.ckey] will be made a ghost.",, list("Yes","No")) != "Yes")
			return
		else
			var/mob/dead/observer/ghost = new/mob/dead/observer(M,1)
			M.logout_reason = LOGOUT_SWAP
			ghost.ckey = M.ckey
	message_admins("<span class='notice'>[key_name_admin(usr)] assumed direct control of [M].</span>")
	log_admin("[key_name(usr)] assumed direct control of [M].")
	var/mob/adminmob = src.mob
	M.ckey = src.ckey
	if( isobserver(adminmob) )
		qdel(adminmob)
	feedback_add_details("admin_verb","ADC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!





/client/proc/cmd_switch_radio()
	set category = "Debug"
	set name = "Switch Radio Mode"
	set desc = "Toggle between normal radios and experimental radios. Have a coder present if you do this."

	GLOBAL_RADIO_TYPE = !GLOBAL_RADIO_TYPE // toggle
	log_admin("[key_name(src)] has turned the experimental radio system [GLOBAL_RADIO_TYPE ? "on" : "off"].")
	message_admins("[key_name_admin(src)] has turned the experimental radio system [GLOBAL_RADIO_TYPE ? "on" : "off"].")
	feedback_add_details("admin_verb","SRM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_areatest()
	set category = "Mapping"
	set name = "Test areas"

	var/list/areas_all = list()
	var/list/areas_with_APC = list()
	var/list/areas_with_air_alarm = list()
	var/list/areas_with_RC = list()
	var/list/areas_with_light = list()
	var/list/areas_with_LS = list()
	var/list/areas_with_intercom = list()
	var/list/areas_with_camera = list()

	for(var/area/A in world)
		if(!(A.type in areas_all))
			areas_all.Add(A.type)

	for(var/obj/machinery/power/apc/APC in machines)
		var/area/A = get_area(APC)
		if(!(A.type in areas_with_APC))
			areas_with_APC.Add(A.type)

	for(var/obj/machinery/alarm/alarm in machines)
		var/area/A = get_area(alarm)
		if(!(A.type in areas_with_air_alarm))
			areas_with_air_alarm.Add(A.type)

	for(var/obj/machinery/requests_console/RC in machines)
		var/area/A = get_area(RC)
		if(!(A.type in areas_with_RC))
			areas_with_RC.Add(A.type)

	for(var/obj/machinery/light/L in machines)
		var/area/A = get_area(L)
		if(!(A.type in areas_with_light))
			areas_with_light.Add(A.type)

	for(var/obj/machinery/light_switch/LS in machines)
		var/area/A = get_area(LS)
		if(!(A.type in areas_with_LS))
			areas_with_LS.Add(A.type)

	for(var/obj/item/device/radio/intercom/I in machines)
		var/area/A = get_area(I)
		if(!(A.type in areas_with_intercom))
			areas_with_intercom.Add(A.type)

	for(var/obj/machinery/camera/C in machines)
		var/area/A = get_area(C)
		if(!(A.type in areas_with_camera))
			areas_with_camera.Add(A.type)

	var/list/areas_without_APC = areas_all - areas_with_APC
	var/list/areas_without_air_alarm = areas_all - areas_with_air_alarm
	var/list/areas_without_RC = areas_all - areas_with_RC
	var/list/areas_without_light = areas_all - areas_with_light
	var/list/areas_without_LS = areas_all - areas_with_LS
	var/list/areas_without_intercom = areas_all - areas_with_intercom
	var/list/areas_without_camera = areas_all - areas_with_camera

	to_chat(world, "<b>AREAS WITHOUT AN APC:</b>")
	for(var/areatype in areas_without_APC)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT AN AIR ALARM:</b>")
	for(var/areatype in areas_without_air_alarm)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT A REQUEST CONSOLE:</b>")
	for(var/areatype in areas_without_RC)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT ANY LIGHTS:</b>")
	for(var/areatype in areas_without_light)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT A LIGHT SWITCH:</b>")
	for(var/areatype in areas_without_LS)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT ANY INTERCOMS:</b>")
	for(var/areatype in areas_without_intercom)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT ANY CAMERAS:</b>")
	for(var/areatype in areas_without_camera)
		to_chat(world, "* [areatype]")

/client/proc/robust_dress_shop()
	var/list/baseoutfits = list("Naked", "As Job...", "As Responder...")
	var/list/outfits = list()
	var/list/paths = subtypesof(/datum/outfit) - typesof(/datum/outfit/job) - typesof(/datum/outfit/responders)

	for(var/datum/outfit/O as anything in paths)
		if(initial(O.name))
			outfits[initial(O.name)] = O

	var/dresscode = input("Select outfit", "Robust quick dress shop") as null|anything in baseoutfits + sortList(outfits)
	if(isnull(dresscode))
		return

	if(outfits[dresscode])
		dresscode = outfits[dresscode]

	else if(dresscode == "As Job...")
		var/list/job_paths = subtypesof(/datum/outfit/job)
		var/list/job_outfits = list()
		for(var/datum/outfit/O as anything in job_paths)
			job_outfits[initial(O.name)] = O

		dresscode = input("Select job equipment", "Robust quick dress shop") as null|anything in sortList(job_outfits)
		dresscode = job_outfits[dresscode]
		if(isnull(dresscode))
			return

	else if(dresscode == "As Responder...")
		var/list/responder_paths = subtypesof(/datum/outfit/responders)
		var/list/responder_outfits = list()
		for(var/datum/outfit/O as anything in responder_paths)
			responder_outfits[initial(O.name)] = O

		dresscode = input("Select responder equipment", "Robust quick dress shop") as null|anything in sortList(responder_outfits)
		dresscode = responder_outfits[dresscode]
		if(isnull(dresscode))
			return


	return dresscode

//todo: this proc should use /datum/outfit
/client/proc/cmd_admin_dress(mob/living/carbon/human/M in mob_list)
	set category = "Fun"
	set name = "Select equipment"

	if(!ishuman(M))
		tgui_alert(usr, "Invalid mob")
		return

	var/dresscode = robust_dress_shop()

	if(!dresscode)
		return

	for(var/item in M.get_equipped_items())
		qdel(item)
	if(dresscode != "Naked")
		M.equipOutfit(dresscode)

	log_admin("[key_name(usr)] changed the equipment of [key_name(M)] to [dresscode].")
	message_admins("<span class='notice'>[key_name_admin(usr)] changed the equipment of [key_name_admin(M)] to [dresscode]..</span>")
	return

/client/proc/startSinglo()

	set category = "Debug"
	set name = "Start Singularity"
	set desc = "Sets up the singularity and all machines to get power flowing through the station."

	if(tgui_alert(usr, "Are you sure? This will start up the engine. Should only be used during debug!",, list("Yes","No")) != "Yes")
		return

	for(var/obj/machinery/power/emitter/E in machines)
		if(E.anchored)
			E.active = 1

	for(var/obj/machinery/field_generator/F in machines)
		if(F.anchored)
			F.var_edit_start = 1
	spawn(30)
		for(var/obj/machinery/the_singularitygen/G in machines)
			if(G.anchored)
				var/obj/singularity/S = new /obj/singularity(get_turf(G), 50)
				spawn(0)
					qdel(G)
				S.energy = 1750
				S.current_size = STAGE_FOUR
				S.icon = 'icons/effects/224x224.dmi'
				S.icon_state = "singularity_s7"
				S.pixel_x = -96
				S.pixel_y = -96
				S.grav_pull = 0
				//S.consume_range = 3
				S.dissipate = 0
				//S.dissipate_delay = 10
				//S.dissipate_track = 0
				//S.dissipate_strength = 10

	for(var/obj/machinery/power/rad_collector/Rad in machines)
		if(Rad.anchored)
			if(!Rad.P)
				var/obj/item/weapon/tank/phoron/Phoron = new/obj/item/weapon/tank/phoron(Rad)
				Phoron.air_contents.gas["phoron"] = 70
				Rad.drainratio = 0
				Rad.P = Phoron
				Phoron.loc = Rad

			if(!Rad.active)
				Rad.toggle_power()

	for(var/obj/machinery/power/smes/SMES in machines)
		if(SMES.anchored)
			SMES.input_attempt = TRUE
			SMES.input_level = 200000

/client/proc/setup_supermatter_engine()
	set category = "Debug"
	set name = "Setup supermatter"
	set desc = "Sets up the supermatter engine."

	if(!check_rights(R_DEBUG))
		return

	var/response = tgui_alert(usr, "Are you sure? This will start up the engine. Should only be used during debug!",, list("Setup Completely","Setup except coolant","No"))

	if(response == "No")
		return

	var/found_the_pump = 0
	var/obj/machinery/power/supermatter/SM

	for(var/obj/machinery/M in machines)
		if(!M)
			continue
		if(!M.loc)
			continue
		if(!M.loc.loc)
			continue

		if(istype(M,/obj/machinery/power/rad_collector))
			var/obj/machinery/power/rad_collector/Rad = M
			Rad.anchored = TRUE
			Rad.connect_to_network()

			var/obj/item/weapon/tank/phoron/Phoron = new/obj/item/weapon/tank/phoron(Rad)

			Phoron.air_contents.gas["phoron"] = 29.1154	//This is a full tank if you filled it from a canister
			Rad.P = Phoron

			Phoron.loc = Rad

			if(!Rad.active)
				Rad.toggle_power()
			Rad.update_icon()

		else if(istype(M,/obj/machinery/atmospherics/components/binary/pump))	//Turning on every pump.
			var/obj/machinery/atmospherics/components/binary/pump/Pump = M
			if(Pump.name == "Engine Feed" && response == "Setup Completely")
				var/datum/gas_mixture/air2 = Pump.AIR2

				found_the_pump = 1
				air2.gas["nitrogen"] = 3750	//The contents of 2 canisters.
				air2.temperature = 50
				air2.update_values()
			//Pump.on=1
			Pump.target_pressure = 4500
			Pump.update_icon()

		else if(istype(M,/obj/machinery/power/supermatter))
			SM = M
			spawn(50)
				SM.power = 320

		else if(istype(M,/obj/machinery/power/smes))	//This is the SMES inside the engine room.  We don't need much power.
			var/obj/machinery/power/smes/SMES = M
			SMES.input_attempt = TRUE
			SMES.input_level = 200000
			SMES.output_level = 75000

	if(!found_the_pump && response == "Setup Completely")
		to_chat(src, "<span class='warning'>Unable to locate air supply to fill up with coolant, adding some coolant around the supermatter</span>")
		var/turf/simulated/T = SM.loc
		T.zone.air.gas["nitrogen"] += 450
		T.zone.air.temperature = 50
		T.zone.air.update_values()


	log_admin("[key_name(usr)] setup the supermatter engine [response == "Setup except coolant" ? "without coolant" : ""]")
	message_admins("[key_name_admin(usr)] setup the supermatter engine  [response == "Setup except coolant" ? "without coolant": ""]")
	return



/client/proc/cmd_debug_mob_lists()
	set category = "Debug"
	set name = "Debug Mob Lists"
	set desc = "For when you just gotta know."

	switch(input("Which list?") in list("Players","Admins","Mobs","Alive Mobs","Dead Mobs", "Clients", "Joined Clients"))
		if("Players")
			to_chat(usr, jointext(player_list,","))
		if("Admins")
			to_chat(usr, jointext(admins,","))
		if("Mobs")
			to_chat(usr, jointext(mob_list,","))
		if("Alive Mobs")
			to_chat(usr, jointext(alive_mob_list,","))
		if("Dead Mobs")
			to_chat(usr, jointext(dead_mob_list,","))
		if("Clients")
			to_chat(usr, jointext(clients,","))
		if("Joined Clients")
			to_chat(usr, jointext(joined_player_list,","))

// DNA2 - Admin Hax
/client/proc/cmd_admin_toggle_block(mob/M,block)
	if(!SSticker)
		tgui_alert(usr, "Wait until the game starts")
		return
	if(iscarbon(M))
		var/saved_key = M.key
		M.dna.SetSEState(block,!M.dna.GetSEState(block))
		//domutcheck(M,null,MUTCHK_FORCED)  //#Z2
		genemutcheck(M,block,null,MUTCHK_FORCED) //#Z2
		if(iscarbon(M))
			M.update_mutations()
			var/state="[M.dna.GetSEState(block)?"on":"off"]"
			var/blockname=assigned_blocks[block]
			message_admins("[key_name_admin(src)] has toggled [key_name_admin(M)]'s [blockname] block [state]!")
			log_admin("[key_name(src)] has toggled [key_name(M)]'s [blockname] block [state]!")
		else
			message_admins("[key_name_admin(src)] has toggled [saved_key]'s HULK block on!")
			log_admin("[key_name(src)] has toggled [saved_key]'s HULK block on!")
	else
		tgui_alert(usr, "Invalid mob")

// from Goonstation
/client/proc/edit_color_matrix()
	set category = "Debug"
	set name = "Edit Color Matrix"
	set desc = "A little more control over the VFX"

	if(!check_rights(R_DEBUG))
		return

	var/static/datum/debug_color_matrix/debug_color_matrix = new
	debug_color_matrix.edit(src)

/datum/debug_color_matrix

/datum/debug_color_matrix/proc/edit(client/user)
	var/static/editor = file2text('html/admin/color_matrix.html')
	user << browse(editor, "window=colormatrix;size=410x500;")
	addtimer(CALLBACK(src, PROC_REF(callJsFunc), usr, "setRef", list("\ref[src]")), 10) //This is shit but without it, it calls the JS before the window is open and doesn't work.

/datum/debug_color_matrix/Topic(href, href_list)
	if(!islist(usr.client.color))
		usr.client.color = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)

	// as somepotato pointed out this form is very insecure, so let's do some serverside verification that we got what we wanted
	var/sanitised = sanitize(strip_html_properly(href_list["matrix"]))
	var/list/matrixStrings = splittext(sanitised, ",")
	// we are expecting 12 strings, so abort if we don't have that many
	if(matrixStrings.len != 20)
		return

	var/list/matrix = list()
	for(var/matrixString in matrixStrings)
		var/num = text2num(matrixString)
		if(isnum(num))
			matrix += num

	var/list/show_to = list(usr.client)

	if(href_list["everyone"] == "y")
		show_to = clients

	if(href_list["animate"] == "y")
		for(var/client/C in show_to)
			animate(C, color = matrix, time = 5, easing = SINE_EASING)
	else
		for(var/client/C in show_to)
			C.color = matrix

/datum/debug_color_matrix/proc/callJsFunc(client, funcName, list/params)
	var/paramsJS = list2params(params)
	client << output(paramsJS,"colormatrix.browser:[funcName]")

/client/proc/burn_tile()
	set category = "Debug"
	set name = "Floor: Burn"

	var/turf/simulated/floor/T = get_turf(usr)
	if(!istype(T))
		return

	T.burn_tile()

/client/proc/break_tile()
	set category = "Debug"
	set name = "Floor: Break"

	var/turf/simulated/floor/T = get_turf(usr)
	if(!istype(T))
		return

	T.break_tile()

/client/proc/fix_tile()
	set category = "Debug"
	set name = "Floor: Fix"

	var/turf/simulated/floor/T = get_turf(usr)
	if(!istype(T))
		return

	T.burnt = 0
	T.broken = 0
	T.update_icon()
