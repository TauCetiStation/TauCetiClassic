// TO DO:
/*
epilepsy flash on lights
delay round message
microwave makes robots
dampen radios
reactivate cameras - done
eject engine
core sheild
cable stun
rcd light flash thingy on matter drain



*/



/datum/AI_Module
	var/uses = 0
	var/module_name
	var/mod_pick_name
	var/description = ""
	var/engaged = 0


/datum/AI_Module/large/
	uses = 1

/datum/AI_Module/small/
	uses = 5


/datum/AI_Module/large/fireproof_core
	module_name = "Core upgrade"
	mod_pick_name = "coreup"

/client/proc/fireproof_core()
	set category = "Malfunction"
	set name = "Fireproof Core"
	for(var/mob/living/silicon/ai/ai in player_list)
		ai.fire_res_on_core = 1
	usr.verbs -= /client/proc/fireproof_core
	to_chat(usr, "\red Core fireproofed.")

/datum/AI_Module/large/upgrade_turrets
	module_name = "AI Turret upgrade"
	mod_pick_name = "turret"

/client/proc/upgrade_turrets()
	set category = "Malfunction"
	set name = "Upgrade Turrets"
	usr.verbs -= /client/proc/upgrade_turrets
	for(var/obj/machinery/porta_turret/turret in machines)
		turret.health += 30
		turret.maxhealth += 30
		turret.auto_repair = 1
		turret.shot_delay = 15

/datum/AI_Module/large/disable_rcd
	module_name = "RCD disable"
	mod_pick_name = "rcd"

/client/proc/disable_rcd()
	set category = "Malfunction"
	set name = "Disable RCDs"
	var/mob/living/silicon/ai/A = usr
	var/datum/AI_Module/large/disable_rcd/rcdmod = A.current_modules["rcdmod"]
	if(rcdmod.uses > 0)
		rcdmod.uses --
		for(var/obj/item/weapon/rcd/rcd in world)
			rcd.disabled = 1
		for(var/obj/item/mecha_parts/mecha_equipment/tool/rcd/rcd in world)
			rcd.disabled = 1
		to_chat(usr, "RCD-disabling pulse emitted.")
	else to_chat(usr, "Out of uses.")

/datum/AI_Module/small/overload_machine
	module_name = "Machine overload"
	mod_pick_name = "overload"
	uses = 2

/datum/AI_Module/small/nanject
	module_name = "Nanites injector"
	mod_pick_name = "nanjector"
	uses = 1

/client/proc/overload_machine()
	set name = "Overload Machine"
	set category = "Malfunction"
	var/mob/living/silicon/ai/A = usr
	var/datum/AI_Module/small/overload_machine/overload = A.current_modules["overload_machine"]
	if(overload.uses > 0)
		if(A.active_module != "overload")
			A.active_module = "overload"
			to_chat(usr, "Power hack module active. Alt+click to choose a machine to overload.")

		else
			A.active_module = null
			to_chat(usr, "Power hack module deactivated.")
	else
		to_chat(usr, "Module activation failed. Out of uses.")


/client/proc/nanject()
	set name = "Add nanobot injector"
	set category = "Malfunction"
	var/mob/living/silicon/ai/A = usr
	var/datum/AI_Module/small/nanject/nanjector = A.current_modules["nanject"]
	if(nanjector.uses > 0)
		if(A.active_module != "overload")
			A.active_module = "nanject"
			to_chat(usr, "Upgrade module active. Alt+click to choose machine to install nanobot injector.")
		else
			A.active_module = null
			to_chat(usr, "Upgrade module deactivated.")
	else
		to_chat(usr, "Module activation failed. Out of uses.")

/datum/AI_Module/small/blackout
	module_name = "Blackout"
	mod_pick_name = "blackout"
	uses = 3

/client/proc/blackout()
	set category = "Malfunction"
	set name = "Blackout"
	var/mob/living/silicon/ai/A = usr
	var/datum/AI_Module/small/blackout/blackout = A.current_modules["blackout"]
	if(blackout.uses > 0)
		blackout.uses --
		for(var/obj/machinery/power/apc/apc in machines)
			if(prob(30*apc.overload))
				apc.overload_lighting()
			else apc.overload++
	else to_chat(usr, "Out of uses.")

/datum/AI_Module/small/interhack
	module_name = "Hack intercept"
	mod_pick_name = "interhack"

/datum/AI_Module/large/holohack
	module_name = "Hacked hologram"
	mod_pick_name = "holohack"

/client/proc/interhack()
	set category = "Malfunction"
	set name = "Hack intercept"
	usr.verbs -= /client/proc/interhack
	ticker.mode:hack_intercept()

/client/proc/holohack()
	set category = "Malfunction"
	set name = "Hacked hologram"
	usr.verbs -= /client/proc/holohack
	ticker.mode:hack_holopads()

/datum/AI_Module/small/reactivate_camera
	module_name = "Reactivate camera"
	mod_pick_name = "recam"
	uses = 10

/client/proc/reactivate_camera()
	set name = "Reactivate Camera"
	set category = "Malfunction"
	var/mob/living/silicon/ai/A = usr
	var/obj/machinery/camera/C = input(usr, "Reactivate Camera","Choose Object") as obj in view(1,A.eyeobj)
	if (istype (C, /obj/machinery/camera))
		var/datum/AI_Module/small/reactivate_camera/camera = A.current_modules["reactivate_camera"]
		if(camera.uses > 0)
			if(!C.status)
				C.status = !C.status
				camera.uses --
				for(var/mob/V in viewers(src, null))
					V.show_message(text("\blue You hear a quiet click."))
			else
				to_chat(usr, "This camera is either active, or not repairable.")
		else
			to_chat(usr, "Out of uses.")
	else
		to_chat(usr, "That's not a camera.")

/datum/AI_Module/small/upgrade_camera
	module_name = "Upgrade Camera"
	mod_pick_name = "upgradecam"
	uses = 10

/client/proc/upgrade_camera()
	set name = "Upgrade Camera"
	set category = "Malfunction"
	var/mob/living/silicon/ai/A = usr
	var/obj/machinery/camera/C = input(usr, "Upgrade Camera","Choose Object") as obj in view(1,A.eyeobj)
	if(istype(C))
		var/datum/AI_Module/small/upgrade_camera/UC = A.current_modules["upgrade_camera"]
		if(UC)
			if(UC.uses > 0)
				if(C.assembly)
					var/upgraded = 0

					if(!C.isXRay())
						C.upgradeXRay()
						//Update what it can see.
						cameranet.updateVisibility(C)
						upgraded = 1

					if(!C.isEmpProof())
						C.upgradeEmpProof()
						upgraded = 1

					if(!C.isMotion())
						C.upgradeMotion()
						upgraded = 1
						// Add it to machines that process
						machines |= C

					if(upgraded)
						UC.uses --
						C.visible_message("<span class='notice'>[bicon(C)] *beep*</span>")
						to_chat(usr, "Camera successully upgraded!")
					else
						to_chat(usr, "This camera is already upgraded!")
			else
				to_chat(usr, "Out of uses.")


/datum/AI_Module/module_picker
	var/temp = null
	var/processing_time = 100
	var/list/possible_modules = list(/datum/AI_Module/large/fireproof_core,
                                 /datum/AI_Module/large/upgrade_turrets,
                                 /datum/AI_Module/large/disable_rcd,
                                 /datum/AI_Module/small/overload_machine,
								 /datum/AI_Module/small/nanject,
                                 /datum/AI_Module/small/interhack,
								 /datum/AI_Module/large/holohack,
                                 /datum/AI_Module/small/blackout,
                                 /datum/AI_Module/small/reactivate_camera,
                                 /datum/AI_Module/small/upgrade_camera)

/datum/AI_Module/module_picker/proc/use(user)
	var/dat
	if (src.temp)
		dat = "[src.temp]<BR><BR><A href='byond://?src=\ref[src];temp=1'>Clear</A>"
	else if(src.processing_time <= 0)
		dat = "<B> No processing time is left available. No more modules are able to be chosen at this time."
	else
		dat = "<B>Select use of processing time: (currently [src.processing_time] left.)</B><BR>"
		dat += "<HR>"
		dat += "<B>Install Module:</B><BR>"
		dat += "<I>The number afterwards is the amount of processing time it consumes.</I><BR>"
		for(var/datum/AI_Module/large/module in src.possible_modules)
			dat += "<A href='byond://?src=\ref[src];[module.mod_pick_name]=1'>[module.module_name]</A> (50)<BR>"
		for(var/datum/AI_Module/small/module in src.possible_modules)
			dat += "<A href='byond://?src=\ref[src];[module.mod_pick_name]=1'>[module.module_name]</A> (15)<BR>"
		dat += "<HR>"

	user << browse(dat, "window=modpicker")
	onclose(user, "modpicker")
	return

/datum/AI_Module/module_picker/Topic(href, href_list)
	..()
	var/mob/living/silicon/ai/A = usr
	if (href_list["coreup"])
		var/already
		for (var/datum/AI_Module/mod in A.current_modules)
			if(istype(mod, /datum/AI_Module/large/fireproof_core))
				already = 1
		if (!already)
			usr.verbs += /client/proc/fireproof_core
			A.current_modules["fireproof_core"] = new /datum/AI_Module/large/fireproof_core
			src.temp = "An upgrade to improve core resistance, making it immune to fire and heat. This effect is permanent."
			src.processing_time -= 50
		else
			src.temp = "This module is only needed once."

	else if (href_list["turret"])
		var/already
		for (var/datum/AI_Module/mod in A.current_modules)
			if(istype(mod, /datum/AI_Module/large/upgrade_turrets))
				already = 1
		if (!already)
			usr.verbs += /client/proc/upgrade_turrets
			A.current_modules["upgrade_turrets"] = new /datum/AI_Module/large/upgrade_turrets
			src.temp = "Improves the firing speed and health of all AI turrets. This effect is permanent."
			src.processing_time -= 50
		else
			src.temp = "This module is only needed once."

	else if (href_list["rcd"])
		var/already
		for (var/datum/AI_Module/mod in A.current_modules)
			if(istype(mod, /datum/AI_Module/large/disable_rcd))
				mod:uses += 1
				already = 1
		if (!already)
			A.current_modules["disable_rcd"] = new /datum/AI_Module/large/disable_rcd
			usr.verbs += /client/proc/disable_rcd
			src.temp = 	"Send a specialised pulse to break all RCD devices on the station."
		else
			src.temp = "Additional use added to RCD disabler."
		src.processing_time -= 50

	else if (href_list["overload"])
		var/already
		for (var/datum/AI_Module/mod in A.current_modules)
			if(istype(mod, /datum/AI_Module/small/overload_machine))
				mod:uses += 2
				already = 1
		if (!already)
			usr.verbs += /client/proc/overload_machine
			A.current_modules["overload_machine"] = new /datum/AI_Module/small/overload_machine
			src.temp = "Overloads an electrical machine, causing a small explosion. 2 uses."
		else
			src.temp = "Two additional uses added to Overload module."
		src.processing_time -= 15

	else if (href_list["nanjector"])
		var/already
		for (var/datum/AI_Module/mod in A.current_modules)
			if(istype(mod, /datum/AI_Module/small/nanject))
				mod:uses += 1
				already = 1
		if (!already)
			usr.verbs += /client/proc/nanject
			A.current_modules["nanject"] = new /datum/AI_Module/small/nanject
			src.temp = "Upgrades an electrical machine with nanobot injector. 1 use."
		else
			src.temp = "Additional use added to Nanobot injector module."
		src.processing_time -= 15

	else if (href_list["blackout"])
		var/already
		for (var/datum/AI_Module/mod in A.current_modules)
			if(istype(mod, /datum/AI_Module/small/blackout))
				mod:uses += 3
				already = 1
		if (!already)
			usr.verbs += /client/proc/blackout
			src.temp = "Attempts to overload the lighting circuits on the station, destroying some bulbs. 3 uses."
			A.current_modules["blackout"] = new /datum/AI_Module/small/blackout
		else
			src.temp = "Three additional uses added to Blackout module."
		src.processing_time -= 15

	else if (href_list["interhack"])
		var/already
		for (var/datum/AI_Module/mod in A.current_modules)
			if(istype(mod, /datum/AI_Module/small/interhack))
				already = 1
		if (!already)
			usr.verbs += /client/proc/interhack
			src.temp = "Hacks the status upgrade from Cent. Com, removing any information about malfunctioning electrical systems."
			A.current_modules["interhack"] = new /datum/AI_Module/small/interhack
			src.processing_time -= 15
		else
			src.temp = "This module is only needed once."

	else if (href_list["holohack"])
		var/already
		for (var/datum/AI_Module/mod in A.current_modules)
			if(istype(mod, /datum/AI_Module/large/holohack))
				already = 1
		if (!already)
			usr.verbs += /client/proc/holohack
			src.temp = "Hacks holopads to project much more useful hologram."
			A.current_modules["holohack"] = new /datum/AI_Module/large/holohack
			src.processing_time -= 50
		else
			src.temp = "This module is only needed once."

	else if (href_list["recam"])
		var/already
		for (var/datum/AI_Module/mod in A.current_modules)
			if(istype(mod, /datum/AI_Module/small/reactivate_camera))
				mod:uses += 10
				already = 1
		if (!already)
			usr.verbs += /client/proc/reactivate_camera
			src.temp = "Reactivates a currently disabled camera. 10 uses."
			A.current_modules["reactivate_camera"] = new /datum/AI_Module/small/reactivate_camera
		else
			src.temp = "Ten additional uses added to ReCam module."
		src.processing_time -= 15

	else if(href_list["upgradecam"])
		var/already
		for (var/datum/AI_Module/mod in A.current_modules)
			if(istype(mod, /datum/AI_Module/small/upgrade_camera))
				mod:uses += 10
				already = 1
		if (!already)
			usr.verbs += /client/proc/upgrade_camera
			src.temp = "Upgrades a camera to have X-Ray vision, Motion and be EMP-Proof. 10 uses."
			A.current_modules["upgrade_camera"] = new /datum/AI_Module/small/upgrade_camera
		else
			src.temp = "Ten additional uses added to ReCam module."
		src.processing_time -= 15

	else
		if (href_list["temp"])
			src.temp = null
	src.use(usr)
	return

/mob/living/silicon/ai/proc/module_handler(atom/A)
	if(!active_module)
		return

	var/obj/machinery/M = A

	switch(active_module)
		if("nanject")
			nanject_action(M)
		if("overload")
			overload_action(M)
		if("emag")
			emag_action(M)

/mob/living/silicon/ai/proc/nanject_action(obj/machinery/M)
	var/datum/AI_Module/small/nanject/nanjector = current_modules["nanject"]

	if(!M.nanjector)
		nanjector.uses--
		M.nanjector = TRUE
		to_chat(usr, "Nanobot injector installed.")
		active_module = null
		for(var/mob/V in hearers(M, null))
			V.show_message("<span class='notice'>You hear a quiet click.</span>", 2)
	else
		to_chat(usr, "This machine already upgraded.")

/mob/living/silicon/ai/proc/overload_action(obj/machinery/M)
	var/datum/AI_Module/small/overload_machine/overload = current_modules["overload"]

	overload.uses--
	for(var/mob/V in hearers(M, null))
		V.show_message("<span class='notice'>You hear a loud electrical buzzing sound!</span>", 2)
	to_chat(usr, "Machine overloaded.")
	active_module = null
	sleep(50)
	if(M)
		explosion(get_turf(M), 0,1,2,3)
		qdel(M)

/mob/living/silicon/ai/proc/emag_action(obj/machinery/M)
	if(emag_recharge == 0)
		if(!M.emagged)
			emag_recharge = 1200
			to_chat(usr, "You sequenced electromagnetic pulse to cripple [M.name] circuits.")
			M.emagged = TRUE
		else
			to_chat(usr, "[M.name] circuits already affected.")
	else
		to_chat(usr, "Electromagnetic sequencer still recharging.")

