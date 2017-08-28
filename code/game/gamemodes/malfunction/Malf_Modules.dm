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
	if(rcdmod.uses)
		rcdmod.uses--
		for(var/obj/item/weapon/rcd/rcd in world)
			rcd.disabled = TRUE
		for(var/obj/item/mecha_parts/mecha_equipment/tool/rcd/rcd in world)
			rcd.disabled = TRUE
		to_chat(usr, "RCD-disabling pulse emitted.")
	else to_chat(usr, "Out of uses.")

/datum/AI_Module/small/overload_machine
	module_name = "Machine overload"
	mod_pick_name = "overload_machine"
	uses = 2

/client/proc/overload_machine()
	set name = "Overload Machine"
	set category = "Malfunction"
	var/mob/living/silicon/ai/A = usr
	A.toggle_small_alt_click_module("overload_machine")

/datum/AI_Module/small/nanject
	module_name = "Nanites injector"
	mod_pick_name = "nanjector"
	uses = 1

/client/proc/nanject()
	set name = "Add nanobot injector"
	set category = "Malfunction"
	var/mob/living/silicon/ai/A = usr
	A.toggle_small_alt_click_module("nanject")

/datum/AI_Module/small/blackout
	module_name = "Blackout"
	mod_pick_name = "blackout"
	uses = 3

/client/proc/blackout()
	set category = "Malfunction"
	set name = "Blackout"
	var/mob/living/silicon/ai/A = usr
	var/datum/AI_Module/small/blackout/blackout = A.current_modules["blackout"]
	if(blackout.uses)
		blackout.uses--
		for(var/obj/machinery/power/apc/apc in machines)
			if(prob(30 * apc.overload))
				apc.overload_lighting()
			else
				apc.overload++
	else
		to_chat(usr, "Out of uses.")

/datum/AI_Module/small/interhack
	module_name = "Hack intercept"
	mod_pick_name = "interhack"

/client/proc/interhack()
	set category = "Malfunction"
	set name = "Hack intercept"
	usr.verbs -= /client/proc/interhack
	var/datum/game_mode/malfunction/cur_malf = ticker.mode
	if(!istype(cur_malf))
		return
	cur_malf.hack_intercept()

/datum/AI_Module/large/holohack
	module_name = "Hacked hologram"
	mod_pick_name = "holohack"

/client/proc/holohack()
	set category = "Malfunction"
	set name = "Hacked hologram"
	usr.verbs -= /client/proc/holohack
	var/datum/game_mode/malfunction/cur_malf = ticker.mode
	if(!istype(cur_malf))
		return
	cur_malf.hack_holopads()

/datum/AI_Module/small/reactivate_camera
	module_name = "Reactivate camera"
	mod_pick_name = "recam"
	uses = 10

/client/proc/reactivate_camera()
	set name = "Reactivate Camera"
	set category = "Malfunction"
	var/mob/living/silicon/ai/A = usr
	var/datum/AI_Module/small/reactivate_camera/camera_mod = A.current_modules["reactivate_camera"]
	if(!camera_mod.uses)
		to_chat(usr, "[camera_mod.module_name] module activation failed. Out of uses.")
		return

	var/list/disabled_cameras = list()
	for(var/obj/machinery/camera/cam in view(A.eyeobj))
		if(!cam.status)
			disabled_cameras += cam

	if(!length(disabled_cameras))
		to_chat(usr, "No cameras found or all cameras in your field of view is either active, or not repairable.")
		return
			
	var/obj/machinery/camera/sel_cam = input(usr, "Reactivate Camera","Choose Object") in disabled_cameras
	if(!sel_cam)
		return

	sel_cam.status = !sel_cam.status
	camera_mod.uses--
	sel_cam.audible_message("<span class='notice'>You hear a quiet click.</span>")
	to_chat(usr, "Camera successully reactivated!")

/datum/AI_Module/small/upgrade_camera
	module_name = "Upgrade Camera"
	mod_pick_name = "upgradecam"
	uses = 10

/client/proc/upgrade_camera()
	set name = "Upgrade Camera"
	set category = "Malfunction"
	var/mob/living/silicon/ai/A = usr
	var/datum/AI_Module/small/upgrade_camera/camera_mod = A.current_modules["upgrade_camera"]
	if(!camera_mod.uses)
		to_chat(usr, "[camera_mod.module_name] module activation failed. Out of uses.")
		return

	var/list/upgradeable_cameras = list()
	for(var/obj/machinery/camera/cam in view(A.eyeobj))
		if(!cam.isXRay() || !cam.isEmpProof() || !cam.isMotion())
			upgradeable_cameras += cam

	if(!length(upgradeable_cameras))
		to_chat(usr, "No cameras found or all cameras in your field of view is already upgraded.")
		return

	var/obj/machinery/camera/sel_cam = input(usr, "Upgrade Camera","Choose Object") in upgradeable_cameras
	if(!sel_cam)
		return

	var/upgraded = FALSE
	if(!sel_cam.isXRay())
		sel_cam.upgradeXRay()
		//Update what it can see.
		cameranet.updateVisibility(sel_cam)
		upgraded = TRUE

	if(!sel_cam.isEmpProof())
		sel_cam.upgradeEmpProof()
		upgraded = TRUE

	if(!sel_cam.isMotion())
		sel_cam.upgradeMotion()
		upgraded = TRUE
		// Add it to machines that process
		machines |= sel_cam

	if(upgraded)
		camera_mod.uses--
		sel_cam.audible_message("<span class='notice'>[bicon(sel_cam)] beeps</span>")
		to_chat(usr, "Camera successully upgraded!")
	else
		to_chat(usr, "This camera is already upgraded!")


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
		if(!A.current_modules["fireproof_core"])
			usr.verbs += /client/proc/fireproof_core
			A.current_modules["fireproof_core"] = new /datum/AI_Module/large/fireproof_core
			temp = "An upgrade to improve core resistance, making it immune to fire and heat. This effect is permanent."
			processing_time -= 50
		else
			temp = "This module is only needed once."

	else if (href_list["turret"])
		if(!A.current_modules["upgrade_turrets"])
			usr.verbs += /client/proc/upgrade_turrets
			A.current_modules["upgrade_turrets"] = new /datum/AI_Module/large/upgrade_turrets
			temp = "Improves the firing speed and health of all AI turrets. This effect is permanent."
			processing_time -= 50
		else
			temp = "This module is only needed once."

	else if (href_list["rcd"])
		if(!A.current_modules["disable_rcd"])
			A.current_modules["disable_rcd"] = new /datum/AI_Module/large/disable_rcd
			usr.verbs += /client/proc/disable_rcd
			temp = 	"Send a specialised pulse to break all RCD devices on the station."
		else
			var/datum/AI_Module/large/disable_rcd/rcd_mod = A.current_modules["disable_rcd"]
			rcd_mod.uses += 1
			temp = "Additional use added to RCD disabler."
		processing_time -= 50

	else if (href_list["overload_machine"])
		if(!A.current_modules["overload_machine"])
			usr.verbs += /client/proc/overload_machine
			A.current_modules["overload_machine"] = new /datum/AI_Module/small/overload_machine
			temp = "Overloads an electrical machine, causing a small explosion. 2 uses."
		else
			var/datum/AI_Module/small/overload_machine/overload_mod = A.current_modules["overload_machine"]
			overload_mod.uses += 2
			temp = "Two additional uses added to Overload module."
		processing_time -= 15

	else if (href_list["nanjector"])
		if(!A.current_modules["nanject"])
			usr.verbs += /client/proc/nanject
			A.current_modules["nanject"] = new /datum/AI_Module/small/nanject
			temp = "Upgrades an electrical machine with nanobot injector. 1 use."
		else
			var/datum/AI_Module/small/overload_machine/nanject_mod = A.current_modules["nanject"]
			nanject_mod.uses += 1
			temp = "Additional use added to Nanobot injector module."
		processing_time -= 15

	else if (href_list["blackout"])
		if(!A.current_modules["blackout"])
			usr.verbs += /client/proc/blackout
			temp = "Attempts to overload the lighting circuits on the station, destroying some bulbs. 3 uses."
			A.current_modules["blackout"] = new /datum/AI_Module/small/blackout
		else
			var/datum/AI_Module/small/blackout/blackout_mod = A.current_modules["blackout"]
			blackout_mod.uses += 3
			temp = "Three additional uses added to Blackout module."
		processing_time -= 15

	else if (href_list["interhack"])
		if(!A.current_modules["interhack"])
			usr.verbs += /client/proc/interhack
			temp = "Hacks the status upgrade from Cent. Com, removing any information about malfunctioning electrical systems."
			A.current_modules["interhack"] = new /datum/AI_Module/small/interhack
			processing_time -= 15
		else
			temp = "This module is only needed once."

	else if (href_list["holohack"])
		if(!A.current_modules["holohack"])
			usr.verbs += /client/proc/holohack
			temp = "Hacks holopads to project much more useful hologram."
			A.current_modules["holohack"] = new /datum/AI_Module/large/holohack
			processing_time -= 50
		else
			temp = "This module is only needed once."

	else if (href_list["recam"])
		if(!A.current_modules["reactivate_camera"])
			usr.verbs += /client/proc/reactivate_camera
			temp = "Reactivates a currently disabled camera. 10 uses."
			A.current_modules["reactivate_camera"] = new /datum/AI_Module/small/reactivate_camera
		else
			var/datum/AI_Module/small/reactivate_camera/reactivatecam_mod = A.current_modules["reactivate_camera"]
			reactivatecam_mod.uses += 10
			temp = "Ten additional uses added to ReCam module."
		processing_time -= 15

	else if(href_list["upgradecam"])
		if(!A.current_modules["upgrade_camera"])
			usr.verbs += /client/proc/upgrade_camera
			temp = "Upgrades a camera to have X-Ray vision, Motion and be EMP-Proof. 10 uses."
			A.current_modules["upgrade_camera"] = new /datum/AI_Module/small/upgrade_camera
		else
			var/datum/AI_Module/small/upgrade_camera/upgradecam_mod = A.current_modules["upgrade_camera"]
			upgradecam_mod.uses += 10
			temp = "Ten additional uses added to ReCam module."
		processing_time -= 15

	else
		if (href_list["temp"])
			temp = null
	use(usr)

/mob/living/silicon/ai/proc/module_handler(atom/A)
	if(!active_module)
		return

	var/obj/machinery/M = A

	switch(active_module)
		if("nanject")
			nanject_action(M)
		if("overload_machine")
			overload_action(M)
		if("emag")
			emag_action(M)

/mob/living/silicon/ai/proc/nanject_action(obj/machinery/M)
	var/datum/AI_Module/small/nanject/nanjector = current_modules["nanject"]

	if(!M.nanjector)
		nanjector.uses--
		M.nanjector = TRUE
		to_chat(src, "Nanobot injector installed.")
		active_module = null
		M.audible_message("<span class='notice'>You hear a quiet click.</span>")
	else
		to_chat(src, "This machine already upgraded.")

/mob/living/silicon/ai/proc/overload_action(obj/machinery/M)
	var/datum/AI_Module/small/overload_machine/overload = current_modules["overload_machine"]

	overload.uses--
	M.audible_message("<span class='notice'>You hear a loud electrical buzzing sound!</span>")
	to_chat(src, "Machine overloaded.")
	active_module = null
	addtimer(CALLBACK(src, .proc/overload_post_action, M), 50)

/mob/living/silicon/ai/proc/overload_post_action(obj/machinery/M)
	if(M)
		explosion(get_turf(M), 0,1,2,3)
		qdel(M)
	else
		var/datum/AI_Module/small/overload_machine/overload = current_modules["overload_machine"]
		if(!overload)
			return
		overload.uses++

/mob/living/silicon/ai/proc/emag_action(obj/machinery/M)
	if(!emag_recharge)
		if(!M.emagged)
			emag_recharge = TRUE
			to_chat(usr, "You sequenced electromagnetic pulse to cripple [M.name] circuits.")
			M.emagged = TRUE
			addtimer(CALLBACK(src, .proc/emag_reload), 1200)
		else
			to_chat(usr, "[M.name] circuits already affected.")
	else
		to_chat(usr, "Electromagnetic sequencer still recharging.")

/mob/living/silicon/ai/proc/emag_reload()
	emag_recharge = FALSE