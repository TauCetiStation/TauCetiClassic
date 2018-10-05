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



/* 21st Sept 2010
Updated by Skie -- Still not perfect but better!
Stuff you can't do:
Call proc /mob/proc/make_dizzy() for some player
Because if you select a player mob as owner it tries to do the proc for
/mob/living/carbon/human/ instead. And that gives a run-time error.
But you can call procs that are of type /mob/living/carbon/human/proc/ for that player.
*/

/client/proc/callproc()
	set category = "Debug"
	set name = "Advanced ProcCall"

	if(!check_rights(R_PERMISSIONS))
		return

	if(1) return	//TODO: config option

	spawn(0)
		var/target = null
		var/targetselected = 0
		var/lst[] // List reference
		lst = new/list() // Make the list
		var/returnval = null
		var/class = null

		switch(alert("Proc owned by something?",,"Yes","No"))
			if("Yes")
				targetselected = 1
				class = input("Proc owned by...","Owner",null) as null|anything in list("Obj","Mob","Area or Turf","Client")
				switch(class)
					if("Obj")
						target = input("Enter target:","Target",usr) as obj in world
					if("Mob")
						target = input("Enter target:","Target",usr) as mob in world
					if("Area or Turf")
						target = input("Enter target:","Target",usr.loc) as area|turf in world
					if("Client")
						var/list/keys = list()
						for(var/client/C)
							keys += C
						target = input("Please, select a player!", "Selection", null, null) as null|anything in keys
					else
						return
			if("No")
				target = null
				targetselected = 0

		var/procname = input("Proc path, eg: /proc/fake_blood","Path:", null) as text|null
		if(!procname)	return

		var/argnum = input("Number of arguments","Number:",0) as num|null
		if(!argnum && (argnum!=0))	return

		lst.len = argnum // Expand to right length
		//TODO: make a list to store whether each argument was initialised as null.
		//Reason: So we can abort the proccall if say, one of our arguments was a mob which no longer exists
		//this will protect us from a fair few errors ~Carn

		var/i
		for(i=1, i<argnum+1, i++) // Lists indexed from 1 forwards in byond

			// Make a list with each index containing one variable, to be given to the proc
			class = input("What kind of variable?","Variable Type") in list("text","num","type","reference","mob reference","icon","file","client","mob's area","CANCEL")
			switch(class)
				if("CANCEL")
					return

				if("text")
					lst[i] = sanitize(input("Enter new text:","Text",null) as text)

				if("num")
					lst[i] = input("Enter new number:","Num",0) as num

				if("type")
					lst[i] = input("Enter type:","Type") in typesof(/obj,/mob,/area,/turf)

				if("reference")
					lst[i] = input("Select reference:","Reference",src) as mob|obj|turf|area in world

				if("mob reference")
					lst[i] = input("Select reference:","Reference",usr) as mob in world

				if("file")
					lst[i] = input("Pick file:","File") as file

				if("icon")
					lst[i] = input("Pick icon:","Icon") as icon

				if("client")
					var/list/keys = list()
					for(var/mob/M in mob_list)
						keys += M.client
					lst[i] = input("Please, select a player!", "Selection", null, null) as null|anything in keys

				if("mob's area")
					var/mob/temp = input("Select mob", "Selection", usr) as mob in world
					lst[i] = temp.loc

		if(targetselected)
			if(!target)
				to_chat(usr, "<font color='red'>Error: callproc(): owner of proc no longer exists.</font>")
				return
			if(!hascall(target,procname))
				to_chat(usr, "<font color='red'>Error: callproc(): target has no such call [procname].</font>")
				return
			log_admin("[key_name(src)] called [target]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
			returnval = call(target,procname)(arglist(lst)) // Pass the lst as an argument list to the proc
		else
			//this currently has no hascall protection. wasn't able to get it working.
			log_admin("[key_name(src)] called [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
			returnval = call(procname)(arglist(lst)) // Pass the lst as an argument list to the proc

		to_chat(usr, "<font color='blue'>[procname] returned: [returnval ? returnval : "null"]</font>")
		feedback_add_details("admin_verb","APC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/Cell()
	set category = "Debug"
	set name = "Air Status in Location"
	if(!mob)
		return
	var/turf/T = mob.loc

	if (!( istype(T, /turf) ))
		return

	var/datum/gas_mixture/env = T.return_air()

	var/t = "<span class='notice'>Coordinates: [T.x],[T.y],[T.z]</span>\n"
	t += "<span class='warning'>Temperature: [env.temperature]</span>\n"
	t += "<span class='warning'>Pressure: [env.return_pressure()]kPa</span>\n"
	for(var/g in env.gas)
		t += "<span class='notice'>[g]: [env.gas[g]] / [env.gas[g] * R_IDEAL_GAS_EQUATION * env.temperature / env.volume]kPa</span>\n"


	usr.show_message(t, 1)
	feedback_add_details("admin_verb","ASL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_robotize(mob/M in mob_list)
	set category = "Fun"
	set name = "Make Robot"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has robotized [M.key].")
		spawn(10)
			M:Robotize()

	else
		alert("Invalid mob")

/client/proc/cmd_admin_animalize(mob/M in mob_list)
	set category = "Fun"
	set name = "Make Simple Animal"

	if(!ticker)
		alert("Wait until the game starts")
		return

	if(!M)
		alert("That mob doesn't seem to exist, close the panel and try again.")
		return

	if(isnewplayer(M))
		alert("The mob must not be a new_player.")
		return

	log_admin("[key_name(src)] has animalized [M.key].")
	spawn(10)
		M.Animalize()


/client/proc/makepAI(turf/T in mob_list)
	set category = "Fun"
	set name = "Make pAI"
	set desc = "Specify a location to spawn a pAI device, then specify a key to play that pAI."

	var/list/available = list()
	for(var/mob/C in mob_list)
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

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has alienized [M.key].")
		spawn(10)
			M:Alienize()
			feedback_add_details("admin_verb","MKAL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(usr)] made [key_name(M)] into an alien.")
		message_admins("\blue [key_name_admin(usr)] made [key_name(M)] into an alien.")
	else
		alert("Invalid mob")

/client/proc/cmd_admin_slimeize(mob/M in mob_list)
	set category = "Fun"
	set name = "Make slime"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has slimeized [M.key].")
		spawn(10)
			M:slimeize()
			feedback_add_details("admin_verb","MKMET") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(usr)] made [key_name(M)] into a slime.")
		message_admins("\blue [key_name_admin(usr)] made [key_name(M)] into a slime.")
	else
		alert("Invalid mob")

/client/proc/cmd_admin_blobize(mob/M in mob_list)
	set category = "Fun"
	set name = "Make Blob"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] has blobized [M.key].")
		var/mob/living/carbon/human/H = M
		spawn(10)
			H.Blobize()

	else
		alert("Invalid mob")

/*
/client/proc/cmd_admin_monkeyize(mob/M in world)
	set category = "Fun"
	set name = "Make Monkey"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/target = M
		log_admin("[key_name(src)] is attempting to monkeyize [M.key].")
		spawn(10)
			target.monkeyize()
	else
		alert("Invalid mob")

/client/proc/cmd_admin_changelinginize(mob/M in world)
	set category = "Fun"
	set name = "Make Changeling"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] has made [M.key] a changeling.")
		spawn(10)
			M.absorbed_dna[M.real_name] = M.dna.Clone()
			M.make_changeling()
			if(M.mind)
				M.mind.special_role = "Changeling"
	else
		alert("Invalid mob")
*/
/*
/client/proc/cmd_admin_abominize(mob/M in world)
	set category = null
	set name = "Make Abomination"

	to_chat(usr, "Ruby Mode disabled. Command aborted.")
	return
	if(!ticker)
		alert("Wait until the game starts.")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] has made [M.key] an abomination.")

	//	spawn(10)
	//		M.make_abomination()

*/
/*
/client/proc/make_cultist(mob/M in world) // -- TLE, modified by Urist
	set category = "Fun"
	set name = "Make Cultist"
	set desc = "Makes target a cultist"
	if(!cultwords["travel"])
		runerandom()
	if(M)
		if(M.mind in ticker.mode.cult)
			return
		else
			if(alert("Spawn that person a tome?",,"Yes","No")=="Yes")
				to_chat(M, "\red You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie. A tome, a message from your new master, appears on the ground.")
				new /obj/item/weapon/book/tome(M.loc)
			else
				to_chat(M, "\red You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie.")
			var/glimpse=pick("1","2","3","4","5","6","7","8")
			switch(glimpse)
				if("1")
					to_chat(M, "\red You remembered one thing from the glimpse... [cultwords["travel"]] is travel...")
				if("2")
					to_chat(M, "\red You remembered one thing from the glimpse... [cultwords["blood"]] is blood...")
				if("3")
					to_chat(M, "\red You remembered one thing from the glimpse... [cultwords["join"]] is join...")
				if("4")
					to_chat(M, "\red You remembered one thing from the glimpse... [cultwords["hell"]] is Hell...")
				if("5")
					to_chat(M, "\red You remembered one thing from the glimpse... [cultwords["destroy"]] is destroy...")
				if("6")
					to_chat(M, "\red You remembered one thing from the glimpse... [cultwords["technology"]] is technology...")
				if("7")
					to_chat(M, "\red You remembered one thing from the glimpse... [cultwords["self"]] is self...")
				if("8")
					to_chat(M, "\red You remembered one thing from the glimpse... [cultwords["see"]] is see...")

			if(M.mind)
				M.mind.special_role = "Cultist"
				ticker.mode.cult += M.mind
			to_chat(src, "Made [M] a cultist.")
*/

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
	SSmachine.makepowernets()
	log_admin("[key_name(src)] has remade the powernet. makepowernets() called.")
	message_admins("[key_name_admin(src)] has remade the powernets. makepowernets() called.")
	feedback_add_details("admin_verb","MPWN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/cmd_debug_load_junkyard()
	set category = "Debug"
	set name = "Load Junkyard"
	SSjunkyard.populate_junkyard()
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

	if (!ticker)
		alert("Wait until the game starts")
		return
	if (istype(M, /mob/living/carbon/human))
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
			id.registered_name = H.real_name
			id.assignment = "Captain"
			id.name = "[id.registered_name]'s ID Card ([id.assignment])"
			H.equip_to_slot_or_del(id, slot_wear_id)
			H.update_inv_wear_id()
	else
		alert("Invalid mob")
	feedback_add_details("admin_verb","GFA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(src)] has granted [M.key] full access.")
	message_admins("\blue [key_name_admin(usr)] has granted [M.key] full access.")

/client/proc/cmd_assume_direct_control(mob/M in mob_list)
	set category = "Admin"
	set name = "Assume direct control"
	set desc = "Direct intervention."

	if(!check_rights(R_DEBUG|R_ADMIN))
		return
	if(M.ckey)
		if(alert("This mob is being controlled by [M.ckey]. Are you sure you wish to assume control of it? [M.ckey] will be made a ghost.",,"Yes","No") != "Yes")
			return
		else
			var/mob/dead/observer/ghost = new/mob/dead/observer(M,1)
			ghost.ckey = M.ckey
	message_admins("\blue [key_name_admin(usr)] assumed direct control of [M].")
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

/client/proc/cmd_admin_dress(mob/living/carbon/human/M in mob_list)
	set category = "Fun"
	set name = "Select equipment"
	if(!ishuman(M))
		alert("Invalid mob")
		return
	//log_admin("[key_name(src)] has alienized [M.key].")
	var/list/dresspacks = list(
		"strip",
		"standard space gear",
		"tournament standard red",
		"tournament standard green",
		"tournament gangster",
		"tournament chef",
		"tournament janitor",
		"pirate",
		"space pirate",
		"soviet admiral",
		"tunnel clown",
		"masked killer",
		"assassin",
		"preparation",
		"death commando",
		"syndicate commando",
		"special ops officer",
		"blue wizard",
		"red wizard",
		"marisa wizard",
		"emergency response team",
		"nanotrasen representative",
		"nanotrasen officer",
		"nanotrasen captain",
		"captain",
		"hop",
		"hos",
		"cmo",
		"rd",
		"ce",
		"warden",
		"security officer",
		"detective",
		"doctor",
		"paramedic",
		"chemist",
		"virologist",
		"psychiatrist",
		"engineer",
		"atmos-tech",
		"scientist",
		"xenobiologist",
		"xenoarcheologist",
		"roboticist",
		"geneticist",
		"janitor",
		"chef",
		"bartender",
		"barber",
		"botanist",
		"qm",
		"cargo",
		"miner",
		"librarian",
		"agent",
		"assistant",
		"test subject",
		"tourist",
		"mime",
		"clown"
		)
	var/list/dresspacks_without_money = list(
		"strip",
		"blue wizard",
		"red wizard",
		"marisa wizard"
		)
	var/dresscode = input("Select dress for [M]", "Robust quick dress shop") as null|anything in dresspacks
	if (isnull(dresscode))
		return
	feedback_add_details("admin_verb","SEQ") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	for (var/obj/item/I in M)
		if (istype(I, /obj/item/weapon/implant))
			continue
		qdel(I)
	switch(dresscode)
		if ("strip")
			//do nothing
		if ("standard space gear")
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)

			M.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/globose(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/globose(M), slot_head)
			var/obj/item/weapon/tank/jetpack/J = new /obj/item/weapon/tank/jetpack/oxygen(M)
			M.equip_to_slot_or_del(J, slot_back)
			J.toggle()
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/breath(M), slot_wear_mask)
			J.Topic(null, list("stat" = 1))
		if ("tournament standard red","tournament standard green") //we think stunning weapon is too overpowered to use it on tournaments. --rastaf0
			if (dresscode=="tournament standard red")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/color/red(M), slot_w_uniform)
			else
				M.equip_to_slot_or_del(new /obj/item/clothing/under/color/green(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)

			M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/thunderdome(M), slot_head)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/pulse_rifle/destroyer(M), slot_r_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/kitchenknife(M), slot_l_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/smokebomb(M), slot_r_store)


		if ("tournament gangster") //gangster are supposed to fight each other. --rastaf0
			M.equip_to_slot_or_del(new /obj/item/clothing/under/det(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)

			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/det_suit(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/monocle(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/det_hat(M), slot_head)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile(M), slot_r_hand)
			M.equip_to_slot_or_del(new /obj/item/ammo_box/a357(M), slot_l_store)

		if ("tournament chef") //Steven Seagal FTW
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chef(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/chef(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/chefhat(M), slot_head)

			M.equip_to_slot_or_del(new /obj/item/weapon/kitchen/rollingpin(M), slot_r_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/kitchenknife(M), slot_l_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/kitchenknife(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/kitchenknife(M), slot_s_store)

		if ("tournament janitor")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/janitor(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)
			var/obj/item/weapon/storage/backpack/backpack = new(M)
			for(var/obj/item/I in backpack)
				qdel(I)
			M.equip_to_slot_or_del(backpack, slot_back)

			M.equip_to_slot_or_del(new /obj/item/weapon/mop(M), slot_r_hand)
			var/obj/item/weapon/reagent_containers/glass/bucket/bucket = new(M)
			bucket.reagents.add_reagent("water", 70)
			M.equip_to_slot_or_del(bucket, slot_l_hand)

			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/chem_grenade/cleaner(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/chem_grenade/cleaner(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), slot_in_backpack)

		if ("pirate")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/pirate(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/bandana(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword/pirate(M), slot_r_hand)

		if ("space pirate")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/pirate(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/pirate(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/pirate(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(M), slot_glasses)

			M.equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword/pirate(M), slot_r_hand)

		if ("soviet soldier")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/soviet(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka(M), slot_head)

		if("tunnel clown")//Tunnel clowns rule!
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(M), slot_wear_mask)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/chaplain_hood(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/monocle(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/chaplain_hoodie(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/bikehorn(M), slot_r_store)

			var/obj/item/weapon/card/id/W = new(M)
			W.assignment = "Tunnel Clown!"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = get_all_accesses()
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)

			var/obj/item/weapon/twohanded/fireaxe/fire_axe = new(M)
			M.equip_to_slot_or_del(fire_axe, slot_r_hand)

		if("masked killer")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/overalls(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/latex(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/surgical(M), slot_wear_mask)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/welding(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/monocle(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/apron(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/weapon/kitchenknife(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/scalpel(M), slot_r_store)

			var/obj/item/weapon/twohanded/fireaxe/fire_axe = new(M)
			M.equip_to_slot_or_del(fire_axe, slot_r_hand)

			for(var/obj/item/carried_item in M.contents)
				if(!istype(carried_item, /obj/item/weapon/implant))//If it's not an implant.
					carried_item.add_blood(M)//Oh yes, there will be blood...

		if("assassin")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/suit_jacket(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/wcoat(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword(M), slot_l_store)

			var/obj/item/weapon/storage/secure/briefcase/sec_briefcase = new(M)
			for(var/obj/item/briefcase_item in sec_briefcase)
				qdel(briefcase_item)
			for(var/i=3, i>0, i--)
				sec_briefcase.contents += new /obj/item/weapon/spacecash/c1000
			sec_briefcase.contents += new /obj/item/weapon/gun/energy/crossbow
			sec_briefcase.contents += new /obj/item/weapon/gun/projectile/revolver/mateba
			sec_briefcase.contents += new /obj/item/ammo_box/a357
			sec_briefcase.contents += new /obj/item/weapon/plastique
			M.equip_to_slot_or_del(sec_briefcase, slot_l_hand)

			var/obj/item/device/pda/heads/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Reaper"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"

			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/syndicate/W = new(M)
			W.assignment = "Reaper"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = get_all_accesses()
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("preparation")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/norm(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/device/flashlight(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), slot_gloves)
			var/obj/item/weapon/card/id/syndicate/W = new(M)
			W.assignment = "Unknown"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = get_all_accesses()
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)

		if("death commando")//Was looking to add this for a while.
			M.equip_death_commando()

		if("syndicate commando")
			M.equip_syndicate_commando()

		if("nanotrasen representative")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/centcom/representative(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/centcom(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/white(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/hop(M), slot_l_ear)

			var/obj/item/device/pda/heads/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "NanoTrasen Navy Representative"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"

			M.equip_to_slot_or_del(pda, slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/clipboard(M), slot_belt)

			var/obj/item/weapon/card/id/centcom/W = new(M)
			W.assignment = "NanoTrasen Navy Representative"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.icon_state = "centcom"
			W.item_state = "id_inv"
			W.access = get_all_accesses()
			W.access += list("VIP Guest","Custodian","Thunderdome Overseer","Intel Officer","Medical Officer","Death Commando","Research Officer")
			W.rank = "NanoTrasen Representative"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)

		if("nanotrasen officer")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/centcom/officer(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/centcom(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/white(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/beret/centcomofficer(M), slot_head)

			var/obj/item/device/pda/heads/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "NanoTrasen Navy Officer"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"

			M.equip_to_slot_or_del(pda, slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy(M), slot_belt)

			var/obj/item/weapon/card/id/centcom/W = new(M)
			W.assignment = "NanoTrasen Navy Officer"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.rank = "NanoTrasen Representative"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)


		if("nanotrasen captain")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/centcom/captain(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/centcom(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/white(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/beret/centcomcaptain(M), slot_head)

			var/obj/item/device/pda/heads/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "NanoTrasen Navy Captain"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"

			M.equip_to_slot_or_del(pda, slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy(M), slot_belt)

			var/obj/item/weapon/card/id/centcom/W = new(M)
			W.assignment = "NanoTrasen Navy Captain"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.rank = "NanoTrasen Representative"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)

		if("emergency response team")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/centcom_officer(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/swat(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/ert(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun(M), slot_belt)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), slot_back)

			var/obj/item/weapon/card/id/ert/W = new(M)
			W.assignment = "Emergency Response Team"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.rank = "Emergency Response Team"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)

		if("special ops officer")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate/combat(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/swat/officer(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/eyepatch(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/cigarette/cigar/havana(M), slot_wear_mask)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/deathsquad/beret(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/pulse_rifle/M1911(M), slot_belt)
			M.equip_to_slot_or_del(new /obj/item/weapon/lighter/zippo(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), slot_back)

			var/obj/item/weapon/card/id/centcom/W = new(M)
			W.assignment = "Special Operations Officer"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.rank = "NanoTrasen Representative"
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)

		if("blue wizard")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/lightpurple(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/spellbook(M), slot_r_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/staff(M), slot_l_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box(M), slot_in_backpack)

		if("red wizard")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/lightpurple(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/red(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/red(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/spellbook(M), slot_r_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/staff(M), slot_l_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box(M), slot_in_backpack)

		if("marisa wizard")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/lightpurple(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/marisa(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal/marisa(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/marisa(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/spellbook(M), slot_r_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/staff(M), slot_l_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box(M), slot_in_backpack)
		if("soviet admiral")
			M.equip_to_slot_or_del(new /obj/item/clothing/head/hgpiratecap(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/eyepatch(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/hgpirate(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/revolver/mateba(M), slot_belt)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/soviet(M), slot_w_uniform)
			var/obj/item/weapon/card/id/W = new(M)
			W.assignment = "Admiral"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("captain")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/captain(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/caphat(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(M), slot_glasses)

			var/obj/item/device/pda/captain/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Captain"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/gold/W = new(M)
			W.assignment = "Captain"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = get_all_accesses()
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)

			var/obj/item/weapon/implant/mindshield/loyalty/L = new(M)
			START_PROCESSING(SSobj, L)
			L.inject(M)
		if("hop")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/head_of_personnel(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/hop(M), slot_l_ear)

			var/obj/item/device/pda/heads/hop/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Head of Personnel"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/silver/W = new(M)
			W.assignment = "Head of Personnel"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_security, access_sec_doors, access_brig, access_court, access_forensics_lockers,
			            access_medical, access_engine, access_change_ids, access_ai_upload, access_eva, access_heads,
			            access_all_personal_lockers, access_maint_tunnels, access_bar, access_janitor, access_construction, access_morgue,
			            access_crematorium, access_kitchen, access_cargo, access_cargo_bot, access_mailsorting, access_qm, access_hydroponics, access_lawyer,
			            access_theatre, access_chapel_office, access_library, access_research, access_mining, access_heads_vault, access_mining_station,
			            access_clown, access_mime, access_hop, access_RC_announce, access_keycard_auth, access_gateway, access_barber)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("hos")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/head_of_security(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/hos(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sechud(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(M), slot_l_store)

			var/obj/item/device/pda/heads/hos/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Head of Security"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/secGold/W = new(M)
			W.assignment = "Head of Security"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_security, access_sec_doors, access_brig, access_armory, access_court,
			            access_forensics_lockers, access_morgue, access_maint_tunnels, access_all_personal_lockers,
			            access_research, access_engine, access_mining, access_medical, access_construction, access_mailsorting,
			            access_heads, access_hos, access_RC_announce, access_keycard_auth, access_gateway, access_detective)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)

			var/obj/item/weapon/implant/mindshield/loyalty/L = new(M)
			L.inject(M)
			START_PROCESSING(SSobj, L)
		if("cmo")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chief_medical_officer(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat/cmo(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/cmo(M), slot_l_ear)

			var/obj/item/device/pda/heads/cmo/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Chief Medical Officer"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/medGold/W = new(M)
			W.assignment = "Chief Medical Officer"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_medical, access_morgue, access_genetics, access_heads,
			access_chemistry, access_virology, access_cmo, access_surgery, access_RC_announce,
			access_keycard_auth, access_sec_doors, access_psychiatrist)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("rd")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/rd(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/research_director(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(M), slot_wear_suit)

			var/obj/item/device/pda/heads/rd/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Research Director"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/sciGold/W = new(M)
			W.assignment = "Research Director"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_rd, access_heads, access_tox, access_genetics, access_morgue,
			            access_tox_storage, access_teleporter, access_sec_doors, access_minisat,
			            access_research, access_robotics, access_xenobiology, access_ai_upload,
			            access_RC_announce, access_keycard_auth, access_tcomsat, access_gateway, access_xenoarch)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("ce")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chief_engineer(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/workboots(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/hardhat/white(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(M), slot_belt)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), slot_gloves)

			var/obj/item/device/pda/heads/ce/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Chief Engineer"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_l_store)

			var/obj/item/weapon/card/id/engGold/W = new(M)
			W.assignment = "Chief Engineer"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels,
			            access_teleporter, access_external_airlocks, access_atmospherics, access_emergency_storage, access_eva,
			            access_heads, access_construction, access_sec_doors, access_minisat,
			            access_ce, access_RC_announce, access_keycard_auth, access_tcomsat, access_ai_upload)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("warden")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/warden(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sechud(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sec(M), slot_l_ear)

			var/obj/item/device/pda/warden/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Warden"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_l_store)

			var/obj/item/weapon/card/id/sec/W = new(M)
			W.assignment = "Warden"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_security, access_sec_doors, access_brig, access_armory, access_court, access_maint_tunnels)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("security officer")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/security(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/device/flash(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sec(M), slot_l_ear)

			var/obj/item/device/pda/security/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Security Officer"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_l_store)

			var/obj/item/weapon/card/id/sec/W = new(M)
			W.assignment = "Security Officer"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_security, access_sec_doors, access_brig, access_court, access_maint_tunnels)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("detective")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sec(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/det(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/det_suit(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/det_hat(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/device/detective_scanner(M), slot_r_hand)

			var/obj/item/device/pda/detective/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Detective"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/sec/W = new(M)
			W.assignment = "Detective"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_security, access_sec_doors, access_detective, access_maint_tunnels, access_court)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("doctor")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_med(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(M), slot_shoes)

			var/obj/item/device/pda/medical/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Medical Doctor"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/med/W = new(M)
			W.assignment = "Medical Doctor"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_medical, access_morgue, access_surgery)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("paramedic")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_med(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/fr_jacket(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(M), slot_shoes)

			var/obj/item/device/pda/medical/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Paramedic"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/med/W = new(M)
			W.assignment = "Paramedic"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_medical, access_morgue, access_maint_tunnels, access_external_airlocks, access_security, access_engine_equip, access_research, access_mailsorting)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("chemist")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_med(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chemist(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat/chemist(M), slot_wear_suit)

			var/obj/item/device/pda/chemist/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Chemist"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/med/W = new(M)
			W.assignment = "Chemist"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_medical, access_chemistry)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("virologist")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/virologist(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/surgical(M), slot_wear_mask)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat/virologist(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_med(M), slot_l_ear)

			var/obj/item/device/pda/viro/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Virologist"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/med/W = new(M)
			W.assignment = "Virologist"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_medical, access_virology)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("psychiatrist")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_med(M), slot_l_ear)

			var/obj/item/device/pda/medical/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Psychiatrist"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/med/W = new(M)
			W.assignment = "Psychiatrist"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_medical, access_psychiatrist)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("engineer")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_eng(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/engineer(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/workboots(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(M), slot_belt)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/hardhat/yellow(M), slot_head)

			var/obj/item/device/pda/engineering/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Station Egnineer"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_l_store)

			var/obj/item/weapon/card/id/eng/W = new(M)
			W.assignment = "Station Engineer"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_external_airlocks, access_construction)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("atmos-tech")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_eng(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/atmospheric_technician(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/workboots(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/atmostech/(M), slot_belt)

			var/obj/item/device/pda/atmos/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Atmospheric Technician"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_l_store)

			var/obj/item/weapon/card/id/eng/W = new(M)
			W.assignment = "Atmospheric Technician"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_atmospherics, access_maint_tunnels, access_emergency_storage, access_construction)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("scientist")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sci(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/scientist(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat/science(M), slot_wear_suit)

			var/obj/item/device/pda/science/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Scientist"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/sci/W = new(M)
			W.assignment = "Scientist"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_tox, access_tox_storage, access_research, access_xenoarch)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("xenoarcheologist")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sci(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/scientist(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat/science(M), slot_wear_suit)

			var/obj/item/device/pda/science/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Xenoarcheologist"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/sci/W = new(M)
			W.assignment = "Xenoarcheologist"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_research, access_xenoarch)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("xenobiologist")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sci(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/scientist(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat/science(M), slot_wear_suit)

			var/obj/item/device/pda/science/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Xenobiologist"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/sci/W = new(M)
			W.assignment = "Xenobiologist"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_research, access_xenobiology)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("roboticist")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sci(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/roboticist(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(M), slot_wear_suit)

			var/obj/item/device/pda/roboticist/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Roboticist"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/sci/W = new(M)
			W.assignment = "Roboticist"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_robotics, access_tech_storage, access_morgue, access_research)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("geneticist")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_medsci(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/geneticist(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat/genetics(M), slot_wear_suit)

			var/obj/item/device/pda/geneticist/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Geneticist"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/med/W = new(M)
			W.assignment = "Geneticist"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_medical, access_morgue, access_genetics, access_research)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("janitor")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/janitor(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_l_ear)

			var/obj/item/device/pda/janitor/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Janitor"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/civ/W = new(M)
			W.assignment = "Janitor"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_janitor, access_maint_tunnels)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("chef")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chef(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/chef(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/chefhat(M), slot_head)

			var/obj/item/device/pda/chef/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Chef"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/civ/W = new(M)
			W.assignment = "Chef"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_kitchen)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("bartender")
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/bartender(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_l_ear)

			var/obj/item/device/pda/bar/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Bartender"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/civ/W = new(M)
			W.assignment = "Bartender"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_bar)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("barber")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/barber(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/wcoat(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(M), slot_shoes)

			var/obj/item/device/pda/barber/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Barber"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/civ/W = new(M)
			W.assignment = "Barber"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_barber)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("botanist")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/hydroponics(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/botanic_leather(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/apron(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/device/plant_analyzer(M), slot_s_store)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_l_ear)

			var/obj/item/device/pda/botanist/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Botanist"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/civ/W = new(M)
			W.assignment = "Botanist"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_hydroponics, access_morgue)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("qm")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_cargo(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/cargo(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(M), slot_glasses)

			var/obj/item/device/pda/cargo/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Quartermastert"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/cargoGold/W = new(M)
			W.assignment = "Quartermaster"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("cargo")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_cargo(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/cargotech(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)

			var/obj/item/device/pda/cargo/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Cargo Technician"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/cargo/W = new(M)
			W.assignment = "Cargo Technician"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_maint_tunnels, access_cargo, access_cargo_bot, access_mailsorting)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("miner")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/miner(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_cargo(M), slot_l_ear)

			var/obj/item/device/pda/shaftminer/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Shaft Miner"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/cargo/W = new(M)
			W.assignment = "Shaft Miner"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_mining, access_mint, access_mining_station, access_mailsorting)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("librarian")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/suit_jacket/red(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_l_ear)

			var/obj/item/device/pda/librarian/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Librarian"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/civ/W = new(M)
			W.assignment = "Librarian"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_library)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("agent")
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sec(M), slot_l_ear)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/internalaffairs(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/internalaffairs(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/big(M), slot_glasses)

			var/obj/item/device/pda/lawyer/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Internal Affairs Agent"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/civ/W = new(M)
			W.assignment = "Internal Affairs Agent"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_lawyer, access_court, access_sec_doors)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)

			var/obj/item/weapon/implant/mindshield/loyalty/L = new(M)
			L.inject(M)
			START_PROCESSING(SSobj, L)
		if("assistant")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_l_ear)

			var/obj/item/device/pda/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Assistant"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/W = new(M)
			W.assignment = "Assistant"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_library)
			if(config.assistant_maint)
				W.access += access_maint_tunnels
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("test subject")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/fluff/jane_sidsuit(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_l_ear)

			var/obj/item/device/pda/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Test Subject"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/W = new(M)
			W.assignment = "Test Subject"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_library)
			if(config.assistant_maint)
				W.access += access_maint_tunnels
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)
		if("tourist")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/tourist(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/tourist(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_l_ear)
		if("mime")
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/mime(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/device/pda/mime(M), slot_belt)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/white(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/mime(M), slot_wear_mask)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/beret(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/suspenders(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(M.back), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/toy/crayon/mime(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing(M), slot_in_backpack)

			var/obj/item/device/pda/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Mime"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/mime/W = new(M)
			W.assignment = "Mime"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_library, access_clown, access_theatre)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)

		if("clown")
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/clown(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(M.back), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/device/pda/clown(M), slot_belt)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(M), slot_wear_mask)
			M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/bikehorn(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/stamp/clown(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/toy/crayon/rainbow(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/fancy/crayons(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/toy/waterflower(M), slot_in_backpack)

			var/obj/item/device/pda/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Clown"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"
			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/clown/W = new(M)
			W.assignment = "Clown"
			W.name = "[M.real_name]'s ID Card ([W.assignment])"
			W.access = list(access_library, access_clown, access_theatre)
			W.registered_name = M.real_name
			M.equip_to_slot_or_del(W, slot_wear_id)

	if(!(dresscode in dresspacks_without_money) && M.mind)
		if(M.mind.initial_account)
			if(M.mind.initial_account.owner_name != M.real_name)
				qdel(M.mind.initial_account)
				M.mind.initial_account = null
				create_random_account_and_store_in_mind(M)
			//else do nothing
		else
			create_random_account_and_store_in_mind(M)

	M.regenerate_icons()

	log_admin("[key_name(usr)] changed the equipment of [key_name(M)] to [dresscode].")
	message_admins("\blue [key_name_admin(usr)] changed the equipment of [key_name_admin(M)] to [dresscode]..")
	return

/client/proc/startSinglo()

	set category = "Debug"
	set name = "Start Singularity"
	set desc = "Sets up the singularity and all machines to get power flowing through the station."

	if(alert("Are you sure? This will start up the engine. Should only be used during debug!",,"Yes","No") != "Yes")
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
			SMES.chargemode = 1

/client/proc/setup_supermatter_engine()
	set category = "Debug"
	set name = "Setup supermatter"
	set desc = "Sets up the supermatter engine."

	if(!check_rights(R_DEBUG))
		return

	var/response = alert("Are you sure? This will start up the engine. Should only be used during debug!",,"Setup Completely","Setup except coolant","No")

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
			Rad.anchored = 1
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
			SMES.chargemode = 1
			SMES.chargelevel = 200000
			SMES.output = 75000

	if(!found_the_pump && response == "Setup Completely")
		to_chat(src, "\red Unable to locate air supply to fill up with coolant, adding some coolant around the supermatter")
		var/turf/simulated/T = SM.loc
		T.zone.air.gas["nitrogen"] += 450
		T.zone.air.temperature = 50
		T.zone.air.update_values()


	log_admin("[key_name(usr)] setup the supermatter engine [response == "Setup except coolant" ? "without coolant" : ""]")
	message_admins("\blue [key_name_admin(usr)] setup the supermatter engine  [response == "Setup except coolant" ? "without coolant": ""]")
	return



/client/proc/cmd_debug_mob_lists()
	set category = "Debug"
	set name = "Debug Mob Lists"
	set desc = "For when you just gotta know."

	switch(input("Which list?") in list("Players","Admins","Mobs","Living Mobs","Dead Mobs", "Clients", "Joined Clients"))
		if("Players")
			to_chat(usr, jointext(player_list,","))
		if("Admins")
			to_chat(usr, jointext(admins,","))
		if("Mobs")
			to_chat(usr, jointext(mob_list,","))
		if("Living Mobs")
			to_chat(usr, jointext(living_mob_list,","))
		if("Dead Mobs")
			to_chat(usr, jointext(dead_mob_list,","))
		if("Clients")
			to_chat(usr, jointext(clients,","))
		if("Joined Clients")
			to_chat(usr, jointext(joined_player_list,","))

/client/proc/cmd_display_del_log()
	set category = "Debug"
	set name = "Display del() Log"
	set desc = "Display del's log of everything that's passed through it."

	var/list/dellog = list("<B>List of things that have gone through qdel this round</B><BR><BR><ol>")
	sortTim(SSgarbage.items, cmp=/proc/cmp_qdel_item_time, associative = TRUE)
	for(var/path in SSgarbage.items)
		var/datum/qdel_item/I = SSgarbage.items[path]
		dellog += "<li><u>[path]</u><ul>"
		if (I.failures)
			dellog += "<li>Failures: [I.failures]</li>"
		dellog += "<li>qdel() Count: [I.qdels]</li>"
		dellog += "<li>Destroy() Cost: [I.destroy_time]ms</li>"
		if (I.hard_deletes)
			dellog += "<li>Total Hard Deletes [I.hard_deletes]</li>"
			dellog += "<li>Time Spent Hard Deleting: [I.hard_delete_time]ms</li>"
		if (I.slept_destroy)
			dellog += "<li>Sleeps: [I.slept_destroy]</li>"
		if (I.no_hint)
			dellog += "<li>No hint: [I.no_hint]</li>"
		dellog += "</ul></li>"

	dellog += "</ol>"

	usr << browse(dellog.Join(), "window=dellog")

/client/proc/cmd_display_init_log()
	set category = "Debug"
	set name = "Display Initialzie() Log"
	set desc = "Displays a list of things that didn't handle Initialize() properly"

	if(!LAZYLEN(SSatoms.BadInitializeCalls))
		to_chat(usr, "<span class='notice'>There is no bad initializations found in log.</span>")
	else
		usr << browse(replacetext(SSatoms.InitLog(), "\n", "<br>"), "window=initlog")

// DNA2 - Admin Hax
/client/proc/cmd_admin_toggle_block(mob/M,block)
	if(!ticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon))
		var/saved_key = M.key
		M.dna.SetSEState(block,!M.dna.GetSEState(block))
		//domutcheck(M,null,MUTCHK_FORCED)  //#Z2
		genemutcheck(M,block,null,MUTCHK_FORCED) //#Z2
		if(istype(M, /mob/living/carbon))
			M.update_mutations()
			var/state="[M.dna.GetSEState(block)?"on":"off"]"
			var/blockname=assigned_blocks[block]
			message_admins("[key_name_admin(src)] has toggled [M.key]'s [blockname] block [state]!")
			log_admin("[key_name(src)] has toggled [M.key]'s [blockname] block [state]!")
		else
			message_admins("[key_name_admin(src)] has toggled [saved_key]'s HULK block on!")
			log_admin("[key_name(src)] has toggled [saved_key]'s HULK block on!")
	else
		alert("Invalid mob")

/client/proc/reload_nanoui_resources()
	set category = "Debug"
	set name = "Reload NanoUI Resources"
	set desc = "Force the client to redownload NanoUI Resources"

	// Close open NanoUIs.
	nanomanager.close_user_uis(usr)

	// Re-load the assets.
	var/datum/asset/assets = get_asset_datum(/datum/asset/nanoui)
	assets.register()

	// Clear the user's cache so they get resent.
	usr.client.cache = list()

	to_chat(usr, "Your NanoUI Resource files have been refreshed")

/client/proc/view_runtimes()
	set category = "Debug"
	set name = "View Runtimes"
	set desc = "Open the runtime Viewer"

	if(!check_rights(R_DEBUG))
		return

	error_cache.show_to(src)
