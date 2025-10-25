//Advanced airlock controller for when you want a more versatile airlock controller - useful for turning simple access control rooms into airlocks
/obj/machinery/embedded_controller/radio/advanced_airlock_controller
	name = "Advanced Airlock Controller"

/obj/machinery/embedded_controller/radio/advanced_airlock_controller/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/embedded_controller/radio/advanced_airlock_controller/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdvancedAirlockController", name)
		ui.open()

/obj/machinery/embedded_controller/radio/advanced_airlock_controller/tgui_data(mob/user)
	return list(
		"chamberPressure" = round(program.memory["chamber_sensor_pressure"]),
		"externalPressure" = round(program.memory["external_sensor_pressure"]),
		"internalPressure" = round(program.memory["internal_sensor_pressure"]),
		"processing" = program.memory["processing"],
		"purge" = program.memory["purge"],
		"secure" = program.memory["secure"]
	)

/obj/machinery/embedded_controller/radio/advanced_airlock_controller/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return

	var/list/command_map = list(
		"cycleExterior" = "cycle_ext",
		"cycleInterior" = "cycle_int",
		"forceExterior" = "force_ext",
		"forceInterior" = "force_int",
		"abort" = "abort",
		"purge" = "purge",
		"secure" = "secure"
	)

	var/converted_command = command_map[action]

	if(converted_command)
		program.receive_user_command(converted_command)

	return TRUE


//Airlock controller for airlock control - most airlocks on the station use this
/obj/machinery/embedded_controller/radio/airlock_controller
	name = "Airlock Controller"
	tag_secure = 1
	layer = 3.3	//Above windows

/obj/machinery/embedded_controller/radio/airlock_controller/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/embedded_controller/radio/airlock_controller/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AirlockController", name)
		ui.open()

/obj/machinery/embedded_controller/radio/airlock_controller/tgui_data()
	var/data = list()

	data["chamberPressure"] = round(program.memory["chamber_sensor_pressure"])
	data["exteriorStatus"] = program.memory["exterior_status"]
	data["interiorStatus"] = program.memory["interior_status"]
	data["processing"] = program.memory["processing"]

	return data

/obj/machinery/embedded_controller/radio/airlock_controller/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return

	var/list/command_map = list(
		"cycleExterior" = "cycle_ext",
		"cycleInterior" = "cycle_int",
		"forceExterior" = "force_ext",
		"forceInterior" = "force_int",
		"abort" = "abort"
	)

	var/converted_command = command_map[action]

	if(converted_command)
		program.receive_user_command(converted_command)

	return TRUE

//Access controller for door control - used in virology and the like
/obj/machinery/embedded_controller/radio/access_controller
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_control_standby"

	name = "Access Controller"
	tag_secure = 1


/obj/machinery/embedded_controller/radio/access_controller/update_icon()
	if(on && program)
		if(program.memory["processing"])
			icon_state = "access_control_process"
		else
			icon_state = "access_control_standby"
	else
		icon_state = "access_control_off"

/obj/machinery/embedded_controller/radio/access_controller/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/embedded_controller/radio/access_controller/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AccessAirlockController", name)
		ui.open()

/obj/machinery/embedded_controller/radio/access_controller/tgui_data(mob/user)
	return list(
		"exteriorStatus" = program.memory["exterior_status"],
		"interiorStatus" = program.memory["interior_status"],
		"processing" = program.memory["processing"]
	)

/obj/machinery/embedded_controller/radio/access_controller/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return

	var/converted_command = ""

	switch(action)
		if("cycleExterior")
			converted_command = "cycle_ext_door"
		if("cycleInterior")
			converted_command = "cycle_int_door"
		if("forceExterior")
			if(program.memory["interior_status"]["state"] == "closed")
				converted_command = "force_ext"
		if("forceInterior")
			if(program.memory["exterior_status"]["state"] == "closed")
				converted_command = "force_int"

	if(length(converted_command))
		program.receive_user_command(converted_command)
	return TRUE
