// TO DO:
/*
nanjector
robot_fabricator
*/


/datum/AI_Module
	var/uses = 0
	var/price = 0
	var/module_name = null
	var/description = null
	var/verb_caller = null
	var/need_only_once = FALSE
	var/only_for_malf_gamemode = FALSE
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
	return ..()

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
	var/list/available_modules = null

/datum/AI_Module/module_picker/New(mob/living/silicon/ai/module_owner)
	..()
	available_modules = subtypesof(/datum/AI_Module/large)
	available_modules += subtypesof(/datum/AI_Module/small)

/datum/AI_Module/module_picker/proc/use(mob/user)
	var/dat
	if(temp)
		dat = "[temp]<BR><BR><A href='byond://?src=\ref[src];clear=1'>Clear</A>"
	else if(processing_time <= 0)
		dat = "<B> No processing time is left available. No more modules are able to be chosen at this time.</B>"
	else
		dat = "<B>Select use of processing time: (currently [processing_time] left.)</B><BR>"
		dat += "<HR>"
		dat += "<B>Install Module:</B><BR>"
		dat += "<I>The number afterwards is the amount of processing time it consumes.</I><BR>"
		var/is_malf = istype(SSticker.mode, /datum/game_mode/malfunction)
		for(var/module in available_modules)
			var/datum/AI_Module/module_type = module
			if(initial(module_type.only_for_malf_gamemode) && !is_malf)
				continue
			dat += "<A href='byond://?src=\ref[src];module_type=[module]'>[initial(module_type.module_name)]</A> ([initial(module_type.price)])<BR>"
		dat += "<HR>"

	var/datum/browser/popup = new(user, "window=modpicker")
	popup.set_content(dat)
	popup.open()

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
		var/module_price = initial(selected_module.price)
		if(module_price > processing_time)
			temp = "Not enough processing time."
		else
			selected_module = cur_AI.current_modules[initial(selected_module.module_name)]
			if(selected_module)
				if(selected_module.need_only_once)
					temp = "This module is only needed once."
				else
					var/uses_to_add = initial(selected_module.uses)
					selected_module.uses += uses_to_add
					temp = "Added uses ([uses_to_add]) to module: [selected_module.module_name]"
					processing_time -= module_price
			else
				selected_module = new selected_module_path(cur_AI)
				temp = selected_module.description
				processing_time -= module_price
				selected_module.BuyedNewHandle()
	use(cur_AI)

/mob/living/silicon/ai/proc/choose_modules()
	set category = "Malfunction"
	set name = "Choose Module"
	var/datum/AI_Module/module_picker/malf_picker = current_modules["Module Picker"]
	malf_picker.use(src)

/datum/AI_Module/takeover
	module_name = "System Override"
	verb_caller = /mob/living/silicon/ai/proc/takeover

/mob/living/silicon/ai/proc/takeover()
	set category = "Malfunction"
	set name = "System Override"
	set desc = "Start the victory timer."
	var/datum/game_mode/malfunction/cur_malf = SSticker.mode
	if(!istype(cur_malf))
		to_chat(src, "<span class='red'>You cannot begin a takeover in this round type!</span>")
		return
	if(cur_malf.malf_mode_declared)
		to_chat(src,"<span class='notice'>You've already begun your takeover.</span>")
		return
	if(cur_malf.apcs < APC_MIN_TO_MALF_DECLARE)
		to_chat(src,"<span class='red'>You don't have enough hacked APCs to take over the station yet. You need to hack at least 5, however hacking more will make the takeover faster. You have hacked [SSticker.mode:apcs] APCs so far.</span>")
		return
	if(cur_malf.AI_malf_revealed < 4)
		if(alert(src, "Are you sure you wish to initiate the takeover? The station hostile runtime detection software is bound to alert everyone. You have hacked [SSticker.mode:apcs] APCs.", "Takeover:", "Yes", "No") != "Yes")
			return
		captain_announce("We have traced the intrude#, it seem& t( e yo3r AI s7stem, it &# *#ck@ng th$ sel$ destru$t mechani&m, stop i# bef*@!)$#&&@@  <CONNECTION LOST>", "Network Monitoring", sound = "malf4")

	cur_malf.takeover()

/datum/AI_Module/ai_win
	module_name = "Explode"
	verb_caller = /mob/living/silicon/ai/proc/ai_win

/mob/living/silicon/ai/proc/ai_win()
	set category = "Malfunction"
	set name = "Explode"
	set desc = "Station go boom."
	var/datum/game_mode/malfunction/cur_malf = SSticker.mode
	if(!istype(cur_malf))
		to_chat(src, "Uh oh, wrong game mode. Please contact a coder.")
		return
	cur_malf.ai_win()

/datum/AI_Module/large
	uses = 1
	price = MALF_LARGE_MODULE_PRICE

/datum/AI_Module/small
	uses = 5
	price = MALF_SMALL_MODULE_PRICE

/datum/AI_Module/large/fireproof_core
	module_name = "Core upgrade: Fireproof Core"
	description = "An upgrade to improve core resistance, making it immune to fire and heat. This effect is permanent."
	need_only_once = TRUE

/datum/AI_Module/large/fireproof_core/BuyedNewHandle()
	for(var/mob/living/silicon/ai/ai in ai_list)
		if(!ai.client)
			continue
		ai.fire_res_on_core = TRUE
	to_chat(owner, "<span class='notice'>Core fireproofed.</span>")

/datum/AI_Module/large/upgrade_turrets
	module_name = "AI Turret upgrade"
	description = "Improves the firing speed and health of all AI turrets. This effect is permanent."
	need_only_once = TRUE

/datum/AI_Module/large/upgrade_turrets/BuyedNewHandle()
	for(var/obj/machinery/porta_turret/turret in machines)
		turret.health += 30
		turret.maxhealth += 30
		turret.auto_repair = 1
		turret.shot_delay = 15
	to_chat(owner, "<span class='notice'>Turrets upgraded.</span>")

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
		for(var/obj/item/weapon/rcd/rcd in rcd_list)
			rcd.disabled = TRUE
		for(var/obj/item/mecha_parts/mecha_equipment/tool/rcd/rcd in mecha_rcd_list)
			rcd.disabled = TRUE
		to_chat(src, "<span class='notice'>RCD-disabling pulse emitted.</span>")
	else
		to_chat(src, "<span class='red'>Out of uses.</span>")

/datum/AI_Module/small/disable_dr
	module_name = "DR disable"
	description = "Send a specialised pulse to break all DR devices on the station."
	verb_caller = /mob/living/silicon/ai/proc/disable_dr

/mob/living/silicon/ai/proc/disable_dr()
	set category = "Malfunction"
	set name = "Disable DRs"
	var/datum/AI_Module/small/disable_dr/drmod = current_modules["DR disable"]
	if(drmod.uses)
		drmod.uses--
		for(var/obj/item/device/remote_device/dr in remote_device_list)
			dr.disabled = TRUE
		to_chat(src, "<span class='notice'>DR-disabling pulse emitted.</span>")
	else
		to_chat(src, "<span class='red'>Out of uses.</span>")

/datum/AI_Module/small/overload_machine
	module_name = "Machine overload"
	description = "Overloads an electrical machine, causing a small explosion. 2 uses."
	uses = 2
	verb_caller = /mob/living/silicon/ai/proc/overload_machine
	valid_targets = list(
			/obj/machinery/computer,
			/obj/machinery/autolathe,
			/obj/machinery/vending,
			/obj/machinery/atmospherics/components/unary/thermomachine,
			/obj/machinery/bot,
			/obj/machinery/power/apc,
			/obj/machinery/power/smes,
			/obj/machinery/clonepod,
			/obj/machinery/sleeper,
			/obj/machinery/dna_scannernew,
			/obj/machinery/atmospherics/components/binary/pump,
			/obj/machinery/atmospherics/components/omni/filter,
			/obj/machinery/atmospherics/components/omni/mixer,
			/obj/machinery/r_n_d,
			/obj/machinery/mecha_part_fabricator,
			/obj/machinery/photocopier,
			/obj/machinery/shieldwallgen,
			/obj/machinery/pdapainter,
			/obj/machinery/monkey_recycler,
			/obj/machinery/telepad,
			/obj/machinery/teleport,
			/obj/machinery/recharger,
			/obj/machinery/cell_charger
			)


/datum/AI_Module/small/overload_machine/AIAltClickHandle(obj/machinery/M)
	if(..())
		return 1

	if(!M.is_operational())
		to_chat(usr, "<span class='red'>The machine is non-functional</span>")
		return 1

	uses--
	M.audible_message("<span class='notice'>You hear a loud electrical buzzing sound!</span>")
	to_chat(owner, "<span class='notice'>Machine overloaded. Uses left: [uses]</span>")
	if(uses <= 0)
		owner.active_module = null
	addtimer(CALLBACK(src, .proc/overload_post_action, M), 50)

/mob/living/silicon/ai/proc/overload_machine()
	set name = "Overload Machine"
	set category = "Malfunction"
	toggle_small_alt_click_module("Machine overload")

/datum/AI_Module/small/overload_machine/proc/overload_post_action(obj/machinery/M)
	if(M)
		explosion(get_turf(M), 0,1,2,3)
		qdel(M)
	else
		uses++

/datum/AI_Module/small/blackout
	module_name = "Blackout"
	description = "Attempts to overload the lighting circuits on the station, destroying some bulbs. 3 uses."
	uses = 3
	verb_caller = /mob/living/silicon/ai/proc/blackout

/mob/living/silicon/ai/proc/blackout()
	set category = "Malfunction"
	set name = "Blackout"
	var/datum/AI_Module/small/blackout/blackout = current_modules["Blackout"]
	if(!blackout.uses)
		to_chat(src, "<span class='red'>[blackout.module_name] module activation failed. Out of uses.</span>")
		return
	blackout.uses--
	for(var/obj/machinery/power/apc/apc in apc_list)
		if(prob(30 * apc.overload))
			apc.overload_lighting()
		else
			apc.overload++
	to_chat(src, "<span class='notice'>APCs overloaded. Uses left: [blackout.uses]</span>")

/datum/AI_Module/small/interhack
	module_name = "Hack intercept"
	description = "Hacks the status update from Cent. Com, removing any information about malfunctioning electrical systems."
	need_only_once = TRUE
	only_for_malf_gamemode = TRUE

/datum/AI_Module/small/interhack/BuyedNewHandle()
	var/datum/game_mode/malfunction/cur_malf = SSticker.mode
	if(!istype(cur_malf)) //Is it possible? Probably not
		qdel(src)
		return
	cur_malf.intercept_hacked = TRUE
	to_chat(owner, "<span class='notice'>Status update hacked.</span>")

/datum/AI_Module/large/holohack
	module_name = "Hacked hologram"
	description = "Hacks holopads to project much more useful hologram."
	need_only_once = TRUE
	verb_caller = /mob/living/silicon/ai/proc/holohack

/mob/living/silicon/ai/proc/holohack()
	set category = "Malfunction"
	set name = "Holohack toggle"
	holohack = !holohack
	if(holo)
		holo.clear_holo()
	to_chat(src, "<span class='notice'>Holopads hack [holohack ? "enabled" : "disabled"].</span>")

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
		to_chat(src, "<span class='red'>[camera_mod.module_name] module activation failed. Out of uses.</span>")
		return

	var/list/disabled_cameras = list()
	for(var/obj/machinery/camera/cam in range(eyeobj))
		if(!cam.status)
			disabled_cameras += cam

	if(!length(disabled_cameras))
		to_chat(src, "<span class='red'>No cameras found or all cameras in your field of view is either active, or not repairable.</span>")
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
		return 1

	if(sel_cam.isXRay() && sel_cam.isEmpProof())
		to_chat(owner, "<span class='notice'>This camera is already upgraded</span>")
		return 1

	if(!sel_cam.isXRay())
		sel_cam.upgradeXRay()
		//Update what it can see.
		cameranet.updateVisibility(sel_cam, 0)

	if(!sel_cam.isEmpProof())
		sel_cam.upgradeEmpProof()

	uses--
	sel_cam.audible_message("<span class='notice'>[bicon(sel_cam)] beeps</span>")
	to_chat(owner, "<span class='notice'>Camera successully upgraded. Uses left: [uses]</span>")
	if(uses <= 0)
		owner.active_module = null

/mob/living/silicon/ai/proc/upgrade_camera()
	set name = "Upgrade Camera"
	set category = "Malfunction"
	toggle_small_alt_click_module("Upgrade Camera")
