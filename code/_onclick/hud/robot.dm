/mob/living/silicon/robot/add_to_hud(datum/hud/hud)
	hud.ui_style = 'icons/hud/screen1_robot.dmi'
	
	var/list/types = list(
		/atom/movable/screen/complex/act_intent,
		/atom/movable/screen/pull/robot,
		/atom/movable/screen/zone_sel,
		/atom/movable/screen/crew_manifest/robot,
		/atom/movable/screen/self_diagnosis,
		/atom/movable/screen/alerts/robot,
		/atom/movable/screen/state_laws/robot,
		/atom/movable/screen/show_laws,
		/atom/movable/screen/toggle_components,
		/atom/movable/screen/toggle_lights,
		/atom/movable/screen/radio,
		/atom/movable/screen/panel,
		/atom/movable/screen/store,
		/atom/movable/screen/robot_inventory,
		/atom/movable/screen/robot_hands/first,
		/atom/movable/screen/robot_hands/second,
		/atom/movable/screen/robot_hands/third,
		/atom/movable/screen/module,
		/atom/movable/screen/complex/gun,
		/atom/movable/screen/health/robot
	)

	if(!isdrone(src))
		types += list(
			/atom/movable/screen/sensor_augmentation/robot,
			/atom/movable/screen/complex/ordered/robot_pda,
			/atom/movable/screen/complex/ordered/robot_image,
		)

//Namepick
		if(!custom_name)
			types += /atom/movable/screen/namepick

	hud.init_screens(types)

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
