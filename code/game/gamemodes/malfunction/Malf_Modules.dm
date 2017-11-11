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
	var/module_name = null
	var/description = ""
	var/engaged = 0
	var/verb_caller = null
	var/need_only_one = FALSE
	var/mob/living/silicon/ai/owner = null
	var/list/valid_targets = list(/obj/machinery)

/datum/AI_Module/New(mob/living/silicon/ai/module_owner)
	owner = module_owner
	module_owner.current_modules[module_name] = src
	if(verb_caller)
		owner.verbs |= verb_caller

/datum/AI_Module/Destroy()
	if(owner)
		owner.current_modules[module_name] = null
		if(verb_caller && owner.client)
			owner.verbs -= verb_caller
		owner = null

/datum/AI_Module/proc/AIAltClickHandle(atom/A)
	if(!is_type_in_list(A, valid_targets))
		return 1

/datum/AI_Module/proc/BuyedNewHandle()
	return

/datum/AI_Module/module_picker
	module_name = "Module Picker"
	verb_caller = /mob/living/silicon/ai/proc/choose_modules
	var/temp = null
	var/processing_time = 100
	var/list/large_modules
	var/list/small_modules

/datum/AI_Module/module_picker/New()
	large_modules = subtypesof(/datum/AI_Module/large)
	small_modules = subtypesof(/datum/AI_Module/small)

/datum/AI_Module/module_picker/proc/use(mob/user)
	var/dat
	if(temp)
		dat = "[temp]<BR><BR><A href='byond://?src=\ref[src];clear=1'>Clear</A>"
	else if(processing_time <= 0)
		dat = "<B> No processing time is left available. No more modules are able to be chosen at this time."
	else
		dat = "<B>Select use of processing time: (currently [processing_time] left.)</B><BR>"
		dat += "<HR>"
		dat += "<B>Install Module:</B><BR>"
		dat += "<I>The number afterwards is the amount of processing time it consumes.</I><BR>"
		for(var/module in large_modules)
			var/datum/AI_Module/module_type = module
			dat += "<A href='byond://?src=\ref[src];module_type=[module]'>[initial(module_type.module_name)]</A> (50)<BR>"
		for(var/module in small_modules)
			var/datum/AI_Module/module_type = module
			dat += "<A href='byond://?src=\ref[src];module_type=[module]'>[initial(module_type.module_name)]</A> (10)<BR>"
		dat += "<HR>"

	user << browse(dat, "window=modpicker")
	onclose(user, "modpicker")

/datum/AI_Module/module_picker/Topic(href, href_list)
	..()
	var/mob/living/silicon/ai/cur_AI = usr
	if(cur_AI.stat || !cur_AI.client)
		return
	if(href_list["clear"])
		temp = null
	else if(href_list["module_type"])
		var/selected_module_path = text2path(href_list["module_type"])
		var/datum/AI_Module/selected_module = selected_module_path
		selected_module = cur_AI.current_modules[initial(selected_module.module_name)]
		if(selected_module)
			if(selected_module.need_only_one)
				temp = "This module is only needed once."
			else
				var/uses_to_add = initial(selected_module.uses)
				selected_module.uses += uses_to_add
				temp = "Added uses ([uses_to_add]) to module: [selected_module.module_name]"
				processing_time -= istype(selected_module, /datum/AI_Module/large) ? 50 : 10
		else
			selected_module = new selected_module_path(cur_AI)
			temp = selected_module.description
			processing_time -= istype(selected_module, /datum/AI_Module/large) ? 50 : 10
			selected_module.BuyedNewHandle()
	use(cur_AI)

/mob/living/silicon/ai/proc/choose_modules()
	set category = "Malfunction"
	set name = "Choose Module"
	var/datum/AI_Module/module_picker/malf_picker = current_modules["Module Picker"]
	malf_picker.use(src)

/datum/AI_Module/large/
	uses = 1

/datum/AI_Module/small/
	uses = 5

/datum/AI_Module/large/fireproof_core
	module_name = "Core upgrade: Fireproof Core"
	description = "An upgrade to improve core resistance, making it immune to fire and heat. This effect is permanent."
	need_only_one = TRUE

/datum/AI_Module/large/fireproof_core/BuyedNewHandle()
	for(var/mob/living/silicon/ai/ai in player_list)
		ai.fire_res_on_core = TRUE
	to_chat(owner, "<span class='red'>Core fireproofed.</span>")

/datum/AI_Module/large/upgrade_turrets
	module_name = "AI Turret upgrade"
	description = "Improves the firing speed and health of all AI turrets. This effect is permanent."
	need_only_one = TRUE

/datum/AI_Module/large/upgrade_turrets/BuyedNewHandle()
	for(var/obj/machinery/porta_turret/turret in machines)
		turret.health += 30
		turret.maxhealth += 30
		turret.auto_repair = 1
		turret.shot_delay = 15
	to_chat(owner, "<span class='red'>Turrets upgraded.</span>")

/datum/AI_Module/large/disable_rcd
	module_name = "RCD disable"
	description = "Send a specialised pulse to break all RCD devices on the station."
	verb_caller = /mob/living/silicon/ai/proc/disable_rcd

/mob/living/silicon/ai/proc/disable_rcd()
	set category = "Malfunction"
	set name = "Disable RCDs"
	var/datum/AI_Module/large/disable_rcd/rcdmod = current_modules["RCD disable"]
	if(rcdmod.uses)
		rcdmod.uses--
		for(var/obj/item/weapon/rcd/rcd in world)
			rcd.disabled = TRUE
		for(var/obj/item/mecha_parts/mecha_equipment/tool/rcd/rcd in world)
			rcd.disabled = TRUE
		to_chat(src, "RCD-disabling pulse emitted.")
	else
		to_chat(src, "Out of uses.")

/datum/AI_Module/small/overload_machine
	module_name = "Machine overload"
	description = "Overloads an electrical machine, causing a small explosion. 2 uses."
	uses = 2
	verb_caller = /mob/living/silicon/ai/proc/overload_machine

/datum/AI_Module/small/overload_machine/AIAltClickHandle(obj/machinery/M)
	if(..())
		return

	uses--
	M.audible_message("<span class='notice'>You hear a loud electrical buzzing sound!</span>")
	to_chat(owner, "Machine overloaded. Uses left: [uses]")
	if(uses <= 0)
		owner.active_module = null
	addtimer(CALLBACK(src, .proc/overload_post_action, M), 50)

/mob/living/silicon/ai/proc/overload_machine()
	set name = "Overload Machine"
	set category = "Malfunction"
	var/mob/living/silicon/ai/cur_AI = usr
	cur_AI.toggle_small_alt_click_module("Machine overload")

/datum/AI_Module/small/overload_machine/proc/overload_post_action(obj/machinery/M)
	if(M)
		explosion(get_turf(M), 0,1,2,3)
		qdel(M)
	else
		uses++

/datum/AI_Module/small/nanject
	module_name = "Nanites injector"
	description = "Upgrades an electrical machine with nanobot injector. 1 use."
	uses = 1
	verb_caller = /mob/living/silicon/ai/proc/nanject

/datum/AI_Module/small/nanject/AIAltClickHandle(obj/machinery/M)
	if(..())
		return

	if(!M.nanjector)
		uses--
		M.nanjector = TRUE
		to_chat(owner, "Nanobot injector installed. Uses left: [uses]")
		owner.active_module = null
		M.audible_message("<span class='notice'>You hear a quiet click.</span>")
		if(uses <= 0)
			owner.active_module = null
	else
		to_chat(owner, "This machine already upgraded.")

/mob/living/silicon/ai/proc/nanject()
	set name = "Add nanobot injector"
	set category = "Malfunction"
	var/mob/living/silicon/ai/cur_AI = usr
	cur_AI.toggle_small_alt_click_module("Nanites injector")

/datum/AI_Module/small/blackout
	module_name = "Blackout"
	description = "Attempts to overload the lighting circuits on the station, destroying some bulbs. 3 uses."
	uses = 3
	verb_caller = /mob/living/silicon/ai/proc/blackout

/mob/living/silicon/ai/proc/blackout()
	set category = "Malfunction"
	set name = "Blackout"
	var/datum/AI_Module/small/blackout/blackout = current_modules["Blackout"]
	if(blackout.uses)
		blackout.uses--
		for(var/obj/machinery/power/apc/apc in machines)
			if(prob(30 * apc.overload))
				apc.overload_lighting()
			else
				apc.overload++
	else
		to_chat(src, "Out of uses.")

/datum/AI_Module/small/interhack
	module_name = "Hack intercept"
	description = "Hacks the status update from Cent. Com, removing any information about malfunctioning electrical systems."
	need_only_one = TRUE

/datum/AI_Module/small/interhack/BuyedNewHandle()
	var/datum/game_mode/malfunction/cur_malf = ticker.mode
	if(!istype(cur_malf))
		return
	cur_malf.intercept_hacked = TRUE
	to_chat(owner, "Status update hacked.")

/datum/AI_Module/large/holohack
	module_name = "Hacked hologram"
	description = "Hacks holopads to project much more useful hologram."
	need_only_one = TRUE
	verb_caller = /mob/living/silicon/ai/proc/holohack

/mob/living/silicon/ai/proc/holohack()
	set category = "Malfunction"
	set name = "Holohack toggle"
	holohack = !holohack
	to_chat(usr, "Holopads hack [holohack ? "enabled" : "disabled"].")

/datum/AI_Module/small/reactivate_camera
	module_name = "Reactivate camera"
	description = "Reactivates a currently disabled camera. 10 uses."
	uses = 10
	verb_caller = /mob/living/silicon/ai/proc/reactivate_camera

/mob/living/silicon/ai/proc/reactivate_camera()
	set name = "Reactivate Camera"
	set category = "Malfunction"
	var/datum/AI_Module/small/reactivate_camera/camera_mod = current_modules["Reactivate camera"]
	if(!camera_mod.uses)
		to_chat(src, "[camera_mod.module_name] module activation failed. Out of uses.")
		return

	var/list/disabled_cameras = list()
	for(var/obj/machinery/camera/cam in range(eyeobj))
		if(!cam.status)
			disabled_cameras += cam

	if(!length(disabled_cameras))
		to_chat(src, "No cameras found or all cameras in your field of view is either active, or not repairable.")
		return
			
	var/obj/machinery/camera/sel_cam = input(src, "Reactivate Camera","Choose Object") in disabled_cameras
	if(!sel_cam)
		return

	sel_cam.status = !sel_cam.status
	camera_mod.uses--
	sel_cam.audible_message("<span class='notice'>You hear a quiet click.</span>")
	to_chat(src, "<span class='notice'>Camera successully reactivated!</span>")

/datum/AI_Module/small/upgrade_camera
	module_name = "Upgrade Camera"
	description = "Upgrades a camera to have X-Ray vision, Motion and be EMP-Proof. 10 uses."
	uses = 10
	verb_caller = /mob/living/silicon/ai/proc/upgrade_camera
	valid_targets = list(/obj/machinery/camera)

/datum/AI_Module/small/upgrade_camera/AIAltClickHandle(obj/machinery/camera/sel_cam)
	if(..())
		return

	if(sel_cam.isXRay() && sel_cam.isEmpProof() && sel_cam.isMotion())
		to_chat(owner, "This camera is already upgraded")
		return

	if(!sel_cam.isXRay())
		sel_cam.upgradeXRay()
		//Update what it can see.
		cameranet.updateVisibility(sel_cam, 0)

	if(!sel_cam.isEmpProof())
		sel_cam.upgradeEmpProof()

	if(!sel_cam.isMotion())
		sel_cam.upgradeMotion()
		// Add it to machines that process
		machines |= sel_cam

	uses--
	sel_cam.audible_message("<span class='notice'>[bicon(sel_cam)] beeps</span>")
	to_chat(owner, "Camera successully upgraded. Uses left: [uses]")
	if(uses <= 0)
		owner.active_module = null

/mob/living/silicon/ai/proc/upgrade_camera()
	set name = "Upgrade Camera"
	set category = "Malfunction"
	var/mob/living/silicon/ai/cur_AI = usr
	cur_AI.toggle_small_alt_click_module("Upgrade Camera")
