//Airlock controller for airlock control - most airlocks on the station use this
/obj/machinery/embedded_controller/radio/airlock_controller
	name = "Airlock Controller"
	tag_secure = 1
	layer = 3.3	//Above windows
	assembly_path = /obj/item/embedded_controller_assembly/airlock_controller
	circuit_path = /obj/item/weapon/circuitboard/airlock_controller

/obj/machinery/embedded_controller/radio/airlock_controller/update_icon()
	overlays.Cut()
	switch(buildstage)
		if(AIRLOCK_CONTROLLER_COMPLETE)
			if(program && has_all_connections && !(stat & NOPOWER))
				if(program.memory["processing"])
					if(program.state == STATE_EXTERMINATING)
						icon_state = "airlock_control_emagged"
					else
						icon_state = "airlock_control_process"
				else
					icon_state = "airlock_control_standby"
			else
				icon_state = "airlock_control_off"
		if(AIRLOCK_CONTROLLER_PANEL_OPEN)
			icon_state = "airlock_control_stg2"
			if(has_all_connections && !(stat & NOPOWER))
				overlays += image('icons/obj/airlock_machines.dmi', "airlock_control_overlay_on")
			else if(!(stat & NOPOWER))
				overlays += image('icons/obj/airlock_machines.dmi', "airlock_control_overlay_off")
		if(AIRLOCK_CONTROLLER_WITHOUT_WIRES)
			icon_state = "airlock_control_stg1"
		if(AIRLOCK_CONTROLLER_WITHOUT_CIRCUIT)
			icon_state = "airlock_control_stg0"

/obj/machinery/embedded_controller/radio/airlock_controller/update_connection_state()
	. = ..()
	if(!.)
		return
	if(!chamber_sensor || !airpumps.len)
		has_all_connections = FALSE
	return has_all_connections

/obj/machinery/embedded_controller/radio/airlock_controller/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null)
	if(buildstage == AIRLOCK_CONTROLLER_COMPLETE && has_all_connections)
		var/data[0]

		data = list(
			"chamber_pressure" = round(program.memory["chamber_sensor_pressure"]),
			"exterior_status" = program.memory["exterior_status"],
			"interior_status" = program.memory["interior_status"],
			"processing" = program.memory["processing"],
		)

		ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)

		if(!ui)
			ui = new(user, src, ui_key, "simple_airlock_console.tmpl", name, 470, 290)

			ui.set_initial_data(data)

			ui.open()

			ui.set_auto_update(1)

/obj/machinery/embedded_controller/radio/airlock_controller/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	var/clean = 0
	switch(href_list["command"])	//anti-HTML-hacking checks
		if("cycle_ext")
			clean = 1
		if("cycle_int")
			clean = 1
		if("force_ext")
			clean = 1
		if("force_int")
			clean = 1
		if("abort")
			clean = 1

	if(clean)
		program.receive_user_command(href_list["command"])

	return 1

/obj/machinery/embedded_controller/radio/airlock_controller/generate_connections_management()
	. = ..()
	if(!airlock_sensors_showed)
		. += "<li><b><a href='?src=\ref[src];show=sensors'>Sensors</a></b></li>"
	else
		. += "<li><b><a href='?src=\ref[src];show=sensors'>Sensors</a></b></li><ul>"

		if(chamber_sensor)
			. += "<li><b>Chamber  - <b style='color: green'>Connected</b> | <a href='?src=\ref[src];disconnect=chamber_sensor'>Disconnect</a></b></li>"
		else
			. += "<li><b>Chamber  - <b style='color: red'>Not connected</b> | <a href='?src=\ref[src];connect=sensor;type=chamber'>Connect</a></b></li>"

		. += "</ul>"

	if(!airpumps_showed)
		. += "<li><b><a href='?src=\ref[src];show=airpumps'>Airpumps</a></b></li>"
	else
		. += "<li><b><a href='?src=\ref[src];show=airpumps'>Airpumps</a></b></li><ul>"

		var/airpump_number = 1

		if(!airpumps.len)
			. += "<li><b>[airpump_number]  - <b style='color: red'>Not connected</b> | <a href='?src=\ref[src];connect=airpump'>Connect</a></b></li>"

		else
			for(var/airpump in airpumps)
				. += "<li><b>[airpump_number]  - <b style='color: green'>Connected</b> | <a href='?src=\ref[src];disconnect=airpump;airpump=[airpump_number]'>Disconnect</a></b></li>"
				airpump_number++

			if(airpumps.len < max_airpumps)
				. += "<li><b>[airpump_number]  - New connection | <a href='?src=\ref[src];connect=airpump'>Connect</a></b></li>"

		. += "</ul>"

/obj/item/embedded_controller_assembly/airlock_controller
	name = "airlock controller assembly"
	desc = "Used for building airlock controllers."
	icon_state = "airlock_control_stg0"
	path = /obj/machinery/embedded_controller/radio/airlock_controller

/obj/item/weapon/circuitboard/airlock_controller
	name = "Circuit board (Airlock Controller)"
	desc = "Used for building airlock controllers."
	origin_tech = "programming=3;engineering=2"
	icon = 'icons/obj/doors/door_electronics.dmi'
	icon_state = "door_electronics"



//Advanced airlock controller for when you want a more versatile airlock controller - useful for turning simple access control rooms into airlocks
/obj/machinery/embedded_controller/radio/advanced_airlock_controller
	name = "Advanced Airlock Controller"
	assembly_path = /obj/item/embedded_controller_assembly/advanced_airlock_controller
	circuit_path = /obj/item/weapon/circuitboard/advanced_airlock_controller

/obj/machinery/embedded_controller/radio/advanced_airlock_controller/update_icon()
	overlays.Cut()
	switch(buildstage)
		if(AIRLOCK_CONTROLLER_COMPLETE)
			if(program && has_all_connections && !(stat & NOPOWER))
				if(program.memory["processing"])
					if(program.state == STATE_EXTERMINATING)
						icon_state = "airlock_control_advanced_emagged"
					else
						icon_state = "airlock_control_advanced_process"
				else
					icon_state = "airlock_control_advanced_standby"
			else
				icon_state = "airlock_control_advanced_off"
		if(AIRLOCK_CONTROLLER_PANEL_OPEN)
			icon_state = "airlock_control_advanced_stg2"
			if(has_all_connections && !(stat & NOPOWER))
				overlays += image('icons/obj/airlock_machines.dmi', "airlock_control_overlay_on")
			else if(!(stat & NOPOWER))
				overlays += image('icons/obj/airlock_machines.dmi', "airlock_control_overlay_off")
		if(AIRLOCK_CONTROLLER_WITHOUT_WIRES)
			icon_state = "airlock_control_advanced_stg1"
		if(AIRLOCK_CONTROLLER_WITHOUT_CIRCUIT)
			icon_state = "airlock_control_advanced_stg0"

/obj/machinery/embedded_controller/radio/advanced_airlock_controller/update_connection_state()
	. = ..()
	if(!.)
		return
	if(!interior_sensor || !exterior_sensor || !chamber_sensor || !airpumps.len)
		has_all_connections = FALSE

/obj/machinery/embedded_controller/radio/advanced_airlock_controller/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null)
	if(buildstage == AIRLOCK_CONTROLLER_COMPLETE && has_all_connections)
		var/data[0]

		data = list(
			"chamber_pressure" = round(program.memory["chamber_sensor_pressure"]),
			"external_pressure" = round(program.memory["external_sensor_pressure"]),
			"internal_pressure" = round(program.memory["internal_sensor_pressure"]),
			"processing" = program.memory["processing"],
			"purge" = program.memory["purge"],
			"secure" = program.memory["secure"]
		)

		ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)

		if (!ui)
			ui = new(user, src, ui_key, "advanced_airlock_console.tmpl", name, 470, 290)

			ui.set_initial_data(data)

			ui.open()

			ui.set_auto_update(1)

/obj/machinery/embedded_controller/radio/advanced_airlock_controller/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	var/clean = 0
	switch(href_list["command"])	//anti-HTML-hacking checks
		if("cycle_ext")
			clean = 1
		if("cycle_int")
			clean = 1
		if("force_ext")
			clean = 1
		if("force_int")
			clean = 1
		if("abort")
			clean = 1
		if("purge")
			clean = 1
		if("secure")
			clean = 1

	if(clean)
		program.receive_user_command(href_list["command"])

	return 1

/obj/machinery/embedded_controller/radio/advanced_airlock_controller/generate_connections_management()
	. = ..()
	if(!airlock_sensors_showed)
		. += "<li><b><a href='?src=\ref[src];show=sensors'>Sensors</a></b></li>"
	else
		. += "<li><b><a href='?src=\ref[src];show=sensors'>Sensors</a></b></li><ul>"

		if(chamber_sensor)
			. += "<li><b>Chamber  - <b style='color: green'>Connected</b> | <a href='?src=\ref[src];disconnect=chamber_sensor'>Disconnect</a></b></li>"
		else
			. += "<li><b>Chamber  - <b style='color: red'>Not connected</b> | <a href='?src=\ref[src];connect=sensor;type=chamber'>Connect</a></b></li>"

		if(interior_sensor)
			. += "<li><b>Internal  - <b style='color: green'>Connected</b> | <a href='?src=\ref[src];disconnect=interior_sensor'>Disconnect</a></b></li>"
		else
			. += "<li><b>Internal  - <b style='color: red'>Not connected</b> | <a href='?src=\ref[src];connect=sensor;type=interior'>Connect</a></b></li>"

		if(exterior_sensor)
			. += "<li><b>External  - <b style='color: green'>Connected</b> | <a href='?src=\ref[src];disconnect=exterior_sensor'>Disconnect</a></b></li>"
		else
			. += "<li><b>External  - <b style='color: red'>Not connected</b> | <a href='?src=\ref[src];connect=sensor;type=exterior'>Connect</a></b></li>"

		. += "</ul>"

	if(!airpumps_showed)
		. += "<li><b><a href='?src=\ref[src];show=airpumps'>Airpumps</a></b></li>"
	else
		. += "<li><b><a href='?src=\ref[src];show=airpumps'>Airpumps</a></b></li><ul>"

		var/airpump_number = 1

		if(!airpumps.len)
			. += "<li><b>[airpump_number]  - <b style='color: red'>Not connected</b> | <a href='?src=\ref[src];connect=airpump'>Connect</a></b></li>"

		else
			for(var/airpump in airpumps)
				. += "<li><b>[airpump_number]  - <b style='color: green'>Connected</b> | <a href='?src=\ref[src];disconnect=airpump;airpump=[airpump_number]'>Disconnect</a></b></li>"
				airpump_number++

			if(airpumps.len < max_airpumps)
				. += "<li><b>[airpump_number]  - New connection | <a href='?src=\ref[src];connect=airpump'>Connect</a></b></li>"

		. += "</ul>"

/obj/item/embedded_controller_assembly/advanced_airlock_controller
	name = "advanced airlock controller assembly"
	desc = "Used for building advanced airlock controllers."
	icon_state = "airlock_control_advanced_stg0"
	path = /obj/machinery/embedded_controller/radio/advanced_airlock_controller

/obj/item/weapon/circuitboard/advanced_airlock_controller
	name = "Circuit board (Advanced Airlock Controller)"
	desc = "Used for building advanced airlock controllers."
	origin_tech = "programming=4;engineering=3"
	icon = 'icons/obj/doors/door_electronics.dmi'
	icon_state = "door_electronics"



//Access controller for door control - used in virology and the like
/obj/machinery/embedded_controller/radio/access_controller
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_control_standby"
	name = "Access Controller"
	tag_secure = 1
	assembly_path = /obj/item/embedded_controller_assembly/access_controller
	circuit_path = /obj/item/weapon/circuitboard/access_controller

/obj/machinery/embedded_controller/radio/access_controller/update_icon()
	overlays.Cut()
	switch(buildstage)
		if(AIRLOCK_CONTROLLER_COMPLETE)
			if(program && has_all_connections && !(stat & NOPOWER))
				if(program.memory["processing"])
					if(program.state == STATE_EXTERMINATING)
						icon_state = "access_control_emagged"
					else
						icon_state = "access_control_process"
				else
					icon_state = "access_control_standby"
			else
				icon_state = "access_control_off"
		if(AIRLOCK_CONTROLLER_PANEL_OPEN)
			icon_state = "access_control_stg2"
			if(has_all_connections && !(stat & NOPOWER))
				overlays += image('icons/obj/airlock_machines.dmi', "access_control_overlay_on")
			else if(!(stat & NOPOWER))
				overlays += image('icons/obj/airlock_machines.dmi', "access_control_overlaycc_off")
		if(AIRLOCK_CONTROLLER_WITHOUT_WIRES)
			icon_state = "access_control_stg1"
		if(AIRLOCK_CONTROLLER_WITHOUT_CIRCUIT)
			icon_state = "access_control_stg0"

/obj/machinery/embedded_controller/radio/access_controller/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null)
	if(buildstage == AIRLOCK_CONTROLLER_COMPLETE && has_all_connections)
		var/data[0]

		data = list(
			"exterior_status" = program.memory["exterior_status"],
			"interior_status" = program.memory["interior_status"],
			"processing" = program.memory["processing"]
		)

		ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)

		if(!ui)
			ui = new(user, src, ui_key, "door_access_console.tmpl", name, 330, 220)

			ui.set_initial_data(data)

			ui.open()

			ui.set_auto_update(1)

/obj/machinery/embedded_controller/radio/access_controller/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	var/clean = 0
	switch(href_list["command"])	//anti-HTML-hacking checks
		if("cycle_ext_door")
			clean = 1
		if("cycle_int_door")
			clean = 1
		if("force_ext")
			if(program.memory["interior_status"]["state"] == "closed")
				clean = 1
		if("force_int")
			if(program.memory["exterior_status"]["state"] == "closed")
				clean = 1

	if(clean)
		program.receive_user_command(href_list["command"])

	return 1

/obj/item/embedded_controller_assembly/access_controller
	name = "access controller assembly"
	desc = "Used for building access controllers."
	icon_state = "access_control_stg0"
	path = /obj/machinery/embedded_controller/radio/access_controller

/obj/item/weapon/circuitboard/access_controller
	name = "Circuit board (Access Controller)"
	desc = "Used for building access controllers."
	origin_tech = "programming=3;engineering=2"
	icon = 'icons/obj/doors/door_electronics.dmi'
	icon_state = "door_electronics"

