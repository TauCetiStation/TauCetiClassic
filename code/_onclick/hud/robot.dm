var/obj/screen/robot_inventory


/datum/hud/proc/robot_hud()

	src.adding = list()
	src.other = list()
	var/obj/screen/using


	if(!isdrone(mymob))
//Medical/Security sensors
		using = new /obj/screen()
		using.name = "Sensor Augmentation"
		using.icon = 'icons/mob/screen1_robot.dmi'
		using.icon_state = "setsensor"
		using.screen_loc = ui_borg_sensor
		using.layer = ABOVE_HUD_LAYER
		using.plane = ABOVE_HUD_PLANE
		adding += using

//Show PDA screens
		using = new /obj/screen()
		using.name = "Show Pda Screens"
		using.icon = 'icons/mob/screen1_robot.dmi'
		using.icon_state = "pda"
		using.screen_loc = ui_borg_show_pda
		using.layer = ABOVE_HUD_LAYER
		using.plane = ABOVE_HUD_PLANE
		adding += using
		var/list/screens = list("PDA - Send Message" = "pda_send", "PDA - Show Message Log" = "pda_log",\
		"Pda - Ringtone" = "ringtone", "Pda - Toggle" = "toggleringer")
		var/screen_position = 2
		for(var/name in screens)
			var/obj/screen/ousing = new /obj/screen()
			ousing.name = name
			ousing.icon = 'icons/mob/screen1_robot.dmi'
			ousing.icon_state = screens[name]
			ousing.layer = ABOVE_HUD_LAYER
			ousing.plane = ABOVE_HUD_PLANE
			ousing.screen_loc = "SOUTH+[screen_position]:6,WEST"
			screen_position++
			other += ousing

//Show foto screens
		using = new /obj/screen()
		using.name = "Show Foto Screens"
		using.icon = 'icons/mob/screen1_robot.dmi'
		using.icon_state = "photo"
		using.screen_loc = ui_borg_show_foto
		using.layer = ABOVE_HUD_LAYER
		using.plane = ABOVE_HUD_PLANE
		adding += using
		screens = list("Take Image" = "takephoto", "View Images" = "photos", "Delete Image" = "deletthis")
		screen_position = 2
		for(var/name in screens)
			var/obj/screen/ousing = new /obj/screen()
			ousing.name = name
			ousing.icon = 'icons/mob/screen1_robot.dmi'
			ousing.icon_state = screens[name]
			ousing.layer = ABOVE_HUD_LAYER
			ousing.plane = ABOVE_HUD_PLANE
			ousing.screen_loc = "SOUTH+[screen_position]:6,WEST+1"
			screen_position++
			other += ousing

//Namepick
		using = new /obj/screen()
		using.name = "Namepick"
		using.icon = 'icons/mob/screen1_robot.dmi'
		using.icon_state = "changename"
		using.screen_loc = ui_borg_namepick
		using.layer = ABOVE_HUD_LAYER
		using.plane = ABOVE_HUD_PLANE
		adding += using

//Manifest
	using = new /obj/screen()
	using.name = "Show Crew Manifest"
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "crewmanifest"
	using.screen_loc = ui_borg_show_manifest
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	adding += using

//Diagnosis
	using = new /obj/screen()
	using.name = "Self Diagnosis"
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "selfdiagnosis"
	using.screen_loc = ui_borg_diagnostic
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	adding += using

//Alerts
	using = new /obj/screen()
	using.name = "Show Alerts"
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "showalerts"
	using.screen_loc = ui_borg_show_alerts
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	adding += using

//State Laws
	using = new /obj/screen()
	using.name = "State Laws"
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "statelaws"
	using.screen_loc = ui_borg_state_laws
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	adding += using

// Show Laws
	using = new /obj/screen()
	using.name = "Show Laws"
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "showlaws"
	using.screen_loc = ui_borg_show_laws
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	adding += using

// Toggle Component
	using = new /obj/screen()
	using.name = "Toggle Components"
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "togglecompanent"
	using.screen_loc = ui_borg_component
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	adding += using

// Toggle Lights
	using = new /obj/screen()
	using.name = "Toggle Lights"
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "togglelights"
	using.screen_loc = ui_borg_light
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	adding += using

//Radio
	using = new /obj/screen()
	using.name = "radio"
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "radio"
	using.screen_loc = ui_movi
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	src.adding += using

//Module select

	using = new /obj/screen()
	using.name = "module1"
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "inv1"
	using.screen_loc = ui_inv1
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	src.adding += using
	mymob:inv1 = using

	using = new /obj/screen()
	using.name = "module2"
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "inv2"
	using.screen_loc = ui_inv2
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	src.adding += using
	mymob:inv2 = using

	using = new /obj/screen()
	using.name = "module3"
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "inv3"
	using.screen_loc = ui_inv3
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	src.adding += using
	mymob:inv3 = using

//End of module select

//Intent
	using = new /obj/screen()
	using.name = "act_intent"
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "intent_" + mymob.a_intent
	using.screen_loc = ui_acti
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	src.adding += using
	action_intent = using

//Health
	mymob.healths = new /obj/screen()
	mymob.healths.icon = 'icons/mob/screen1_robot.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_borg_health

//Installed Module
	mymob.hands = new /obj/screen()
	mymob.hands.icon = 'icons/mob/screen1_robot.dmi'
	mymob.hands.icon_state = "nomod"
	mymob.hands.name = "module"
	mymob.hands.screen_loc = ui_borg_module

//Module Panel
	using = new /obj/screen()
	using.name = "panel"
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "panel"
	using.screen_loc = ui_borg_panel
	using.layer = HUD_LAYER
	using.plane = HUD_PLANE
	src.adding += using

//Store
	mymob.throw_icon = new /obj/screen()
	mymob.throw_icon.icon = 'icons/mob/screen1_robot.dmi'
	mymob.throw_icon.icon_state = "store"
	mymob.throw_icon.name = "store"
	mymob.throw_icon.screen_loc = ui_borg_store

//Inventory
	robot_inventory = new /obj/screen()
	robot_inventory.name = "inventory"
	robot_inventory.icon = 'icons/mob/screen1_robot.dmi'
	robot_inventory.icon_state = "inventory"
	robot_inventory.screen_loc = ui_borg_inventory

	mymob.pullin = new /obj/screen/pull()
	mymob.pullin.icon = 'icons/mob/screen1_robot.dmi'
	mymob.pullin.update_icon(mymob)
	mymob.pullin.screen_loc = ui_borg_pull

	mymob.zone_sel = new /obj/screen/zone_sel()
	mymob.zone_sel.icon = 'icons/mob/screen1_robot.dmi'
	mymob.zone_sel.cut_overlays()
	mymob.zone_sel.add_overlay(image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]"))

	//Handle the gun settings buttons
	mymob.gun_setting_icon = new /obj/screen/gun/mode(null)
	if (mymob.client)
		if (mymob.client.gun_mode) // If in aim mode, correct the sprite
			mymob.gun_setting_icon.icon_state = "gun1"
	for(var/obj/item/weapon/gun/G in mymob) // If targeting someone, display other buttons
		if (G.target)
			mymob.item_use_icon = new /obj/screen/gun/item(null)
			if (mymob.client.target_can_click)
				mymob.item_use_icon.icon_state = "gun0"
			src.adding += mymob.item_use_icon
			mymob.gun_move_icon = new /obj/screen/gun/move(null)
			if (mymob.client.target_can_move)
				mymob.gun_move_icon.icon_state = "gun0"
				mymob.gun_run_icon = new /obj/screen/gun/run(null)
				if (mymob.client.target_can_run)
					mymob.gun_run_icon.icon_state = "gun0"
				src.adding += mymob.gun_run_icon
			src.adding += mymob.gun_move_icon

	mymob.client.screen = list()

	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.hands, mymob.healths, mymob.pullin, mymob.gun_setting_icon, robot_inventory) //, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += src.adding
	mymob.client.screen += mymob.client.void

	return


/datum/hud/proc/toggle_show_robot_modules()
	if(!isrobot(mymob))
		return

	var/mob/living/silicon/robot/r = mymob

	r.shown_robot_modules = !r.shown_robot_modules
	update_robot_modules_display()


/datum/hud/proc/update_robot_modules_display()
	if(!isrobot(mymob))
		return

	var/mob/living/silicon/robot/r = mymob

	if(r.shown_robot_modules)
		//Modules display is shown
		//r.client.screen += robot_inventory	//"store" icon

		if(!r.module)
			to_chat(usr, "<span class='danger'>No module selected</span>")
			return

		if(!r.module.modules)
			to_chat(usr, "<span class='danger'>Selected module has no modules to select</span>")
			return

		if(!r.robot_modules_background)
			return

		var/display_rows = round((r.module.modules.len) / 8) +1 //+1 because round() returns floor of number
		r.robot_modules_background.screen_loc = "CENTER-4:16,SOUTH+1:7 to CENTER+3:16,SOUTH+[display_rows]:7"
		r.client.screen += r.robot_modules_background

		var/x = -4	//Start at CENTER-4,SOUTH+1
		var/y = 1

		//Unfortunately adding the emag module to the list of modules has to be here. This is because a borg can
		//be emagged before they actually select a module. - or some situation can cause them to get a new module
		// - or some situation might cause them to get de-emagged or something.
		if(r.emagged)
			if(!(r.module.emag in r.module.modules))
				r.module.modules.Add(r.module.emag)
		else
			if(r.module.emag in r.module.modules)
				r.module.modules.Remove(r.module.emag)

		for(var/atom/movable/A in r.module.modules)
			if( (A != r.module_state_1) && (A != r.module_state_2) && (A != r.module_state_3) )
				//Module is not currently active
				r.client.screen += A
				if(x < 0)
					A.screen_loc = "CENTER[x]:16,SOUTH+[y]:7"
				else
					A.screen_loc = "CENTER+[x]:16,SOUTH+[y]:7"
				A.layer = ABOVE_HUD_LAYER
				A.plane = ABOVE_HUD_PLANE

				x++
				if(x == 4)
					x = -4
					y++

	else
		//Modules display is hidden
		//r.client.screen -= robot_inventory	//"store" icon
		for(var/atom/A in r.module.modules)
			if( (A != r.module_state_1) && (A != r.module_state_2) && (A != r.module_state_3) )
				//Module is not currently active
				r.client.screen -= A
		r.shown_robot_modules = 0
		r.client.screen -= r.robot_modules_background

/datum/hud/proc/toggle_robot_additional_screens(screen_type, toggled) // if screen_type is 0. it's PDA.
	if(!isrobot(mymob))
		return
	var/list/screens
	if(screen_type)
		screens = list("Take Image", "View Images", "Delete Image")
	else
		screens = list("PDA - Send Message", "PDA - Show Message Log", "Pda - Ringtone", "Pda - Toggle")
	var/mob/living/silicon/robot/R = mymob
	if(toggled)
		for(var/obj/screen/using in other)
			if(using.name in screens)
				R.client.screen += using
	else
		for(var/obj/screen/using in other)
			if(using.name in screens)
				R.client.screen -= using
