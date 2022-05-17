var/global/atom/movable/screen/robot_inventory


/datum/hud/proc/robot_hud()
	var/atom/movable/screen/using

	var/list/types = list(
		/atom/movable/screen/crew_manifest/robot,
		/atom/movable/screen/self_diagnosis,
		/atom/movable/screen/alerts/robot,
		/atom/movable/screen/state_laws/robot,
		/atom/movable/screen/show_laws,
		/atom/movable/screen/toggle_components,
		/atom/movable/screen/toggle_lights,
		/atom/movable/screen/radio,
		/atom/movable/screen/panel,
	)

	if(!isdrone(mymob))
//Medical/Security sensors
		types += list(
			/atom/movable/screen/sensor_augmentation/robot,
			/atom/movable/screen/show_pda_screens,
			/atom/movable/screen/show_photo_screens,
		)

//Show PDA screens
		var/list/screens = list(
			/atom/movable/screen/robot_pda/send, /atom/movable/screen/robot_pda/log,
			/atom/movable/screen/robot_pda/ringtone, /atom/movable/screen/robot_pda/toggle,
		)
		var/screen_position = 2
		for(var/screen_type in screens)
			using = new screen_type()
			using.screen_loc = "SOUTH+[screen_position]:6,WEST"
			screen_position++
			other += using

//Show foto screens
		screens = list(/atom/movable/screen/robot_image/take, /atom/movable/screen/robot_image/view, /atom/movable/screen/robot_image/delete)
		screen_position = 2
		for(var/screen_type in screens)
			using = new screen_type()
			using.screen_loc = "SOUTH+[screen_position]:6,WEST+1"
			screen_position++
			other += using

//Namepick
		var/mob/living/silicon/robot/R = mymob
		if(!R.custom_name)
			types += /atom/movable/screen/namepick

	types += list(
		/atom/movable/screen/crew_manifest/robot,
		/atom/movable/screen/self_diagnosis,
		/atom/movable/screen/alerts/robot,
		/atom/movable/screen/state_laws/robot,
		/atom/movable/screen/show_laws,
		/atom/movable/screen/toggle_components,
		/atom/movable/screen/toggle_lights,
		/atom/movable/screen/radio,
		/atom/movable/screen/panel,
	)
	init_screens(types, list_to = adding)

//Module select

	using = new /atom/movable/screen/robot_hands/first()
	src.adding += using
	mymob:inv1 = using

	using = new /atom/movable/screen/robot_hands/second()
	src.adding += using
	mymob:inv2 = using

	using = new /atom/movable/screen/robot_hands/third()
	src.adding += using
	mymob:inv3 = using

//End of module select

//Intent
	add_intents('icons/mob/screen1_robot.dmi')

//Health
	add_healths(type = /atom/movable/screen/health/robot)

//Installed Module
	mymob.hands = new /atom/movable/screen/module()

//Store
	mymob.throw_icon = new /atom/movable/screen/store()

//Inventory
	robot_inventory = new /atom/movable/screen/robot_inventory()

	add_pullin(type = /atom/movable/screen/pull/robot)

	mymob.zone_sel = new /atom/movable/screen/zone_sel/robot()
	mymob.zone_sel.update_icon()

	//Handle the gun settings buttons
	mymob.gun_setting_icon = new /atom/movable/screen/gun/mode(null)
	mymob.gun_setting_icon.update_icon(mymob.client)

	if(mymob.client.gun_mode)
		mymob.client.add_gun_icons()

	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.hands, mymob.gun_setting_icon, robot_inventory) //, mymob.rest, mymob.sleep, mymob.mach )


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
				r.module.add_item(r.module.emag)
		else
			if(r.module.emag in r.module.modules)
				r.module.remove_item(r.module.emag)

		for(var/atom/movable/A in r.module.modules)
			if( (A != r.module_state_1) && (A != r.module_state_2) && (A != r.module_state_3) )
				//Module is not currently active
				r.client.screen += A
				if(x < 0)
					A.screen_loc = "CENTER[x]:16,SOUTH+[y]:7"
				else
					A.screen_loc = "CENTER+[x]:16,SOUTH+[y]:7"
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
	var/screens_type = screen_type ? /atom/movable/screen/robot_image : /atom/movable/screen/robot_pda
	var/mob/living/silicon/robot/R = mymob
	if(toggled)
		for(var/atom/movable/screen/using as anything in other)
			if(istype(using, screens_type))
				R.client.screen += using
	else
		for(var/atom/movable/screen/using as anything in other)
			if(istype(using, screens_type))
				R.client.screen -= using
