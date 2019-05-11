#define BUTTONS 0
#define CONTROLLER 1

/obj/machinery/embedded_controller
	var/datum/computer/file/embedded_program/program

	name = "Embedded Controller"
	anchored = 1
	allowed_checks = ALLOWED_CHECK_TOPIC

/obj/machinery/embedded_controller/radio/Destroy()
	disconnect_all()
	if(radio_controller)
		radio_controller.remove_object(src,frequency)
	if(program)
		qdel(program)
	return ..()


/obj/machinery/embedded_controller/proc/post_signal(datum/signal/signal, comm_line)
	return 0

/obj/machinery/embedded_controller/receive_signal(datum/signal/signal, receive_method, receive_param)
	if(!signal || signal.encryption) return

	if(program)
		program.receive_signal(signal, receive_method, receive_param)
			//spawn(5) program.process() //no, program.process sends some signals and machines respond and we here again and we lag -rastaf0

/obj/machinery/embedded_controller/process()
	if(program)
		program.process()

	update_icon()
	updateUsrDialog()

/obj/machinery/embedded_controller/attack_paw(mob/user)
	to_chat(user, "You do not have the dexterity to use this.")
	return

/obj/machinery/embedded_controller/radio
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_standby"
	power_channel = ENVIRON
	density = 0

	var/const/connection_range = 5
	var/const/max_airpumps = 6

	var/last_electrocute

	var/buildstage = AIRLOCK_CONTROLLER_COMPLETE
	var/panel_locked = TRUE
	var/controls_locked = TRUE
	var/has_all_connections = TRUE
	var/circuit_path
	var/assembly_path

	// Setup parameters only
	var/id_tag
	var/tag_exterior_door
	var/tag_interior_door
	var/tag_airpump
	var/tag_chamber_sensor
	var/tag_exterior_sensor
	var/tag_interior_sensor
	var/tag_secure = TRUE

	var/obj/machinery/door/airlock/exterior_door
	var/obj/machinery/door/airlock/interior_door
	var/obj/machinery/airlock_sensor/chamber_sensor
	var/obj/machinery/airlock_sensor/exterior_sensor
	var/obj/machinery/airlock_sensor/interior_sensor
	var/obj/machinery/access_button/exterior_access_button
	var/obj/machinery/access_button/interior_access_button
	var/list/obj/machinery/atmospherics/components/unary/vent_pump/airpumps = list()

	var/controller_one_access = FALSE
	var/buttons_one_access = FALSE
	var/list/buttons_req_access = list()
	var/access_setup_target = CONTROLLER

	var/connections_showed = FALSE
	var/accesses_showed = FALSE
	var/airlocks_showed = FALSE
	var/airpumps_showed = FALSE
	var/access_buttons_showed = FALSE
	var/airlock_sensors_showed = FALSE

	frequency = 1379

	unacidable = 1

/obj/machinery/embedded_controller/radio/atom_init(mapload, dir)
	. = ..()

	set_frequency(frequency)

	if(!mapload)
		buildstage = AIRLOCK_CONTROLLER_WITHOUT_CIRCUIT
		pixel_x = (dir & 3) ? 0 : (dir == 4 ? -30 : 30)
		pixel_y = (dir & 3) ? (dir == 1 ? -30 : 30) : 0
		panel_locked = FALSE
		has_all_connections = FALSE
		var/datum/computer/file/embedded_program/new_prog = new
		new_prog.memory["secure"] = tag_secure
		new_prog.master = src
		program = new_prog
		update_icon()
	else
		return INITIALIZE_HINT_LATELOAD

/obj/machinery/embedded_controller/radio/atom_init_late()

	generate_access_lists()
	if(req_one_access.len)
		controller_one_access = TRUE

	for(var/obj/machinery/door/airlock/A in range(connection_range, src))
		if(A.id_tag == tag_exterior_door)
			exterior_door = A
			A.controller = src
		else if(A.id_tag == tag_interior_door)
			interior_door = A
			A.controller = src

	for(var/obj/machinery/airlock_sensor/S in range(connection_range, src))
		if(S.id_tag == tag_chamber_sensor)
			chamber_sensor = S
			S.controller = src
		else if(S.id_tag == tag_exterior_sensor)
			exterior_sensor = S
			S.controller = src
		else if(S.id_tag == tag_interior_sensor)
			interior_sensor = S
			S.controller = src

	for(var/obj/machinery/atmospherics/components/unary/vent_pump/P in range(connection_range, src))
		if(P.id_tag == tag_airpump)
			airpumps += P
			P.controller = src

	for(var/obj/machinery/access_button/B in range(connection_range, src))
		if(B.master_tag == id_tag)
			if(B.command == "cycle_exterior")
				exterior_access_button = B
				B.controller = src
			else
				interior_access_button = B
				B.controller = src
			B.generate_access_lists()

			if(B.req_one_access.len)
				buttons_one_access = TRUE
				buttons_req_access = B.req_one_access
			else
				buttons_req_access = B.req_access

	var/datum/computer/file/embedded_program/new_prog = new

	new_prog.exterior_door = exterior_door
	new_prog.interior_door = interior_door
	new_prog.chamber_sensor = chamber_sensor
	new_prog.exterior_sensor = exterior_sensor
	new_prog.interior_sensor = interior_sensor
	new_prog.airpumps = airpumps.Copy()

	new_prog.memory["secure"] = tag_secure
	new_prog.master = src
	program = new_prog

	program.signalDoor(exterior_door, "update")		//signals connected doors to update their status
	program.signalDoor(interior_door, "update")

/obj/machinery/embedded_controller/radio/proc/update_connection_state()
	has_all_connections = TRUE
	if(!exterior_door || !interior_door || !interior_access_button || !exterior_access_button)
		has_all_connections = FALSE
	return has_all_connections

/obj/machinery/embedded_controller/radio/attackby(obj/item/weapon/W, mob/user)
	switch(buildstage)
		if(AIRLOCK_CONTROLLER_COMPLETE)
			if(istype(W, /obj/item/weapon/card/id) && !(stat & NOPOWER))
				var/obj/item/weapon/card/id/card = W
				if(program.state == STATE_EXTERMINATING)
					to_chat(user, "<span class='danger'>ERROR</span>")
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					s.set_up(3, 1, src)
					s.start()
					electrocute_mob(usr, get_area(src), src)
					last_electrocute = world.timeofday
					return
				if(access_engine in card.access)
					panel_locked = !panel_locked
					to_chat(user, "<span class='notice'>You [panel_locked ? "lock" : "unlock"] the pannel</span>")
					return
				else
					to_chat(user, "<span class='warning'>Access Denied.</span>")
					return
			else if(isscrewdriver(W))
				if(program.state == STATE_EXTERMINATING)
					to_chat(user, "<span class='danger'>PANEL LOCKED</span>")
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					s.set_up(3, 1, src)
					s.start()
					electrocute_mob(usr, get_area(src), src)
					last_electrocute = world.timeofday
				else if(panel_locked && !issilicon(user) && !(stat & NOPOWER))
					to_chat(user, "<span class='warning'>The panel is locked!</span>")
				else if(program.memory["processing"])
					to_chat(user, "<span class='warning'>Can't open the pannel while processing!</span>")
				else
					to_chat(user, "<span class='notice'>You open the panel of [src]</span>")
					playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
					buildstage = AIRLOCK_CONTROLLER_PANEL_OPEN
					reset_menu()
					update_icon()
				return
			else if(istype(W, /obj/item/weapon/card/emag))
				emagged = TRUE
				to_chat(view(2, src), "<span class='danger'>ERROR: SYSTEM OVERCHARGED</span>")
				var/datum/effect/effect/system/spark_spread/s = new
				s.set_up(1, 1, src)
				s.start()
				return
		if(AIRLOCK_CONTROLLER_PANEL_OPEN)
			if(isscrewdriver(W))
				to_chat(user, "<span class='notice'>You close the panel of [src]</span>")
				playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
				buildstage = AIRLOCK_CONTROLLER_COMPLETE
				panel_locked = TRUE
				controls_locked = TRUE
				update_icon()
				return
			if(istype(W, /obj/item/weapon/card/id) && !(stat & NOPOWER))
				var/obj/item/weapon/card/id/card = W
				if(access_engine in card.access)
					controls_locked = !controls_locked
					to_chat(user, "<span class='notice'>You [controls_locked ? "lock" : "unlock"] controls</span>")
					return
				else
					to_chat(user, "<span class='warning'>Access Denied.</span>")
					return
			else if(ismultitool(W) && !(stat & NOPOWER))
				if(!controls_locked || issilicon(user))
					set_up_airlock_controller(user)
					update_icon()
					return
				else
					to_chat(user, "<span class='warning'>Controls are locked!</span>")
					return
			else if(iswirecutter(W))
				to_chat(user, "<span class='notice'>You remove wires from [src]</span>")
				playsound(src, 'sound/items/Wirecutter.ogg', 50, 1)
				new /obj/item/stack/cable_coil/random(loc, 1)
				buildstage = AIRLOCK_CONTROLLER_WITHOUT_WIRES
				emagged = FALSE
				update_icon()
				return
		if(AIRLOCK_CONTROLLER_WITHOUT_WIRES)
			if(iscoil(W))
				var/obj/item/stack/cable_coil/coil = W
				coil.use(1)
				to_chat(user, "<span class='notice'>You wire the [src]</span>")
				buildstage = AIRLOCK_CONTROLLER_PANEL_OPEN
				update_icon()
				return
			else if(iscrowbar(W))
				to_chat(user, "<span class='notice'>You remove the circuit board from [src]</span>")
				playsound(src, 'sound/items/crowbar.ogg', 50, 1)
				buildstage = AIRLOCK_CONTROLLER_WITHOUT_CIRCUIT
				disconnect_all()
				reset_menu()
				new circuit_path(loc)
				update_icon()
				return
		if(AIRLOCK_CONTROLLER_WITHOUT_CIRCUIT)
			if(istype(W, /obj/item/weapon/circuitboard))
				if(istype(W, circuit_path))
					to_chat(user, "<span class='notice'>You place the circuit board inside the [src]</span>")
					playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
					buildstage = AIRLOCK_CONTROLLER_WITHOUT_WIRES
					qdel(W)
					update_icon()
				else
					to_chat(user, "<span class='warning'>This circuit board doesn't match!</span>")
			else if(istype(W, /obj/item/weapon/pen))
				var/t = sanitize_safe(input(user, "Enter the new name for the [src].", name, name), MAX_LNAME_LEN)
				if(!in_range(src, user))
					return
				name = t
				return
			else if(iswrench(W))
				to_chat(user, "<span class='notice'>You remove the [src] from the wall!</span>")
				var/obj/item/assembly = new assembly_path
				assembly.loc = user.loc
				playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
				qdel(src)
				return

/obj/machinery/embedded_controller/radio/proc/set_up_airlock_controller(mob/user)
	var/setup_menu = text("<b>Airlock Controller Setup</b><hr>")
	setup_menu += generate_setup_menu()
	user << browse("<head><title>[src]</title></head><tt>[entity_ja(setup_menu)]</tt>", "window=airlock_controller")
	onclose(user, "airlock_controller")

/obj/machinery/embedded_controller/radio/proc/generate_setup_menu()
	if(!connections_showed)
		. += "<b><a href='?src=\ref[src];show=connections'>Show connections management</a></b><br>"
	else
		. += "<b><a href='?src=\ref[src];show=connections'>Hide connections management</a></b><ul>"
		. += generate_connections_management()
		. += "</ul>"

	if(!accesses_showed)
		. += "<b><a href='?src=\ref[src];show=accesses'>Show access restrictions setup</a></b><br>"
	else
		. += "<b><a href='?src=\ref[src];show=accesses'>Hide access restrictions setup</a></b><br>"
		. += generate_access_management()

	. += "<b><a href='?src=\ref[src];disconnect=all'>Delete all connections</a></b><br>"

/obj/machinery/embedded_controller/radio/proc/generate_connections_management()
	if(!airlocks_showed)
		. += "<li><b><a href='?src=\ref[src];show=airlocks'>Airlocks</a></b></li>"
	else
		. += "<li><b><a href='?src=\ref[src];show=airlocks'>Airlocks</a></b></li><ul>"

		if(interior_door)
			. += "<li><b>Internal - <x style='color: green'>Connected</x> | <a href='?src=\ref[src];disconnect=interior_door'>Disconnect</a></b></li>"
		else
			. += "<li><b>Internal - <x style='color: red'>Not connected</x> | <a href='?src=\ref[src];connect=door;type=interior'>Connect</a></b></li>"

		if(exterior_door)
			. += "<li><b>External - <x style='color: green'>Connected</x> | <a href='?src=\ref[src];disconnect=exterior_door'>Disconnect</a></b></li>"
		else
			. += "<li><b>External - <x style='color: red'>Not connected</x> | <a href='?src=\ref[src];connect=door;type=exterior'>Connect</a></b></li>"

		. += "</ul>"

	if(!access_buttons_showed)
		. += "<li><b><a href='?src=\ref[src];show=access_buttons'>Access buttons</a></b></li>"
	else
		. += "<li><b><a href='?src=\ref[src];show=access_buttons'>Access buttons</a></b></li><ul>"

		if(interior_access_button)
			. += "<li><b>Internal - <x style='color: green'>Connected</x> | <a href='?src=\ref[src];disconnect=interior_access_button'>Disconnect</a></b></li>"
		else
			. += "<li><b>Internal - <x style='color: red'>Not connected</x> | <a href='?src=\ref[src];connect=access_button;type=interior'>Connect</a></b></li>"

		if(exterior_access_button)
			. += "<li><b>External - <x style='color: green'>Connected</x> | <a href='?src=\ref[src];disconnect=exterior_access_button'>Disconnect</a></b></li>"
		else
			. += "<li><b>External - <x style='color: red'>Not connected</x> | <a href='?src=\ref[src];connect=access_button;type=exterior'>Connect</a></b></li>"

		. += "</ul>"

/obj/machinery/embedded_controller/radio/proc/generate_access_management()
	. += "<br><b>Access restrinctions setup for <a href='?src=\ref[src];access_setup_target=1'>[access_setup_target ? "controller" : "access buttons"]</a></b><hr>"
	if(access_setup_target == CONTROLLER)
		. += "<br>Requied <b><a href='?src=\ref[src];controller_one_access=1' [controller_one_access ? "style='color: green'>ONE" : "style='color: red'>ALL"]</a></b> of chosen accesses:<br>"
		. += "<ul>"
		var/list/accesses = get_all_accesses()
		for(var/acc in accesses)
			var/acc_desc = get_access_desc(acc)
			if(acc_desc)
				if(!(acc in (controller_one_access ? req_one_access : req_access)))
					. += "<li><a href='?src=\ref[src];controller_access=[acc]'>[acc_desc]</a></li>"
				else if(controller_one_access)
					. += "<li><b><a style='color: green' href='?src=\ref[src];controller_access=[acc]'>[acc_desc]</a></b></li>"
				else
					. += "<li><b><a style='color: red' href='?src=\ref[src];controller_access=[acc]'>[acc_desc]</a></b></li>"
		. += "</ul>"
	else if(access_setup_target == BUTTONS)
		. += "<br>Requied <b><a href='?src=\ref[src];buttons_one_access=1' [buttons_one_access ? "style='color: green'>ONE" : "style='color: red'>ALL"]</a></b> of chosen accesses:<br>"
		. += "<ul>"
		var/list/accesses = get_all_accesses()
		for(var/acc in accesses)
			var/acc_desc = get_access_desc(acc)
			if(acc_desc)
				if(!(acc in buttons_req_access))
					. += "<li><a href='?src=\ref[src];buttons_access=[acc]'>[acc_desc]</a></li>"
				else if(buttons_one_access)
					. += "<li><b><a style='color: green' href='?src=\ref[src];buttons_access=[acc]'>[acc_desc]</a></b></li>"
				else
					. += "<li><b><a style='color: red' href='?src=\ref[src];buttons_access=[acc]'>[acc_desc]</a></b></li>"
		. += "</ul>"


/obj/machinery/embedded_controller/radio/Topic(href, href_list)
	if(buildstage == AIRLOCK_CONTROLLER_PANEL_OPEN)
		if(get_dist(src, usr) > 1 || !(stat & NOPOWER))
			usr << browse(null, "window=door_control")

		if(!ismultitool(usr.get_active_hand()))
			to_chat(usr, "<span class='warning'>You need a multitool!</span>")
			return

		if(href_list["show"])
			switch(href_list["show"])
				if("connections")
					connections_showed = !connections_showed
				if("accesses")
					accesses_showed = !accesses_showed
				if("airlocks")
					airlocks_showed = !airlocks_showed
				if("access_buttons")
					access_buttons_showed = !access_buttons_showed
				if("sensors")
					airlock_sensors_showed = !airlock_sensors_showed
				if("airpumps")
					airpumps_showed = !airpumps_showed

		if(href_list["connect"])
			var/obj/item/device/multitool/M = usr.get_active_hand()

			switch(href_list["connect"])
				if("door")
					if(!M.airlocks_buffer.len)
						to_chat(usr, "<span class='warning'>The airlocks buffer of multitool is empty</span>")
						return

					var/list/obj/machinery/door/airlock/airlock = M.airlocks_buffer[M.airlocks_buffer.len]
					if(airlock.controller)
						to_chat(usr, "<span class='warning'>The last saved airlock already has a connection!</span>")
						M.airlocks_buffer -= airlock
					else if(get_dist(src, airlock) > connection_range)
						to_chat(usr, "<span class='warning'>The last saved airlock is out of range!</span>")
						M.airlocks_buffer -= airlock
					else
						to_chat(usr, "<span class='notice'>You connect the last saved airlock</span>")
						switch(href_list["type"])
							if("interior")
								interior_door = airlock
								program.interior_door = airlock
							if("exterior")
								exterior_door = airlock
								program.exterior_door = airlock
						airlock.controller = src
						program.signalDoor(airlock, "update")
						airlock.frequency = 1379
						airlock.set_frequency(airlock.frequency)
						M.airlocks_buffer -= airlock

				if("access_button")
					if(!M.buttons_buffer.len)
						to_chat(usr, "<span class='warning'>The buttons buffer of multitool is empty</span>")
						return

					var/obj/machinery/access_button/button = M.buttons_buffer[M.buttons_buffer.len]
					if(button.controller)
						to_chat(usr, "<span class='warning'>The last saved button already has a connection!</span>")
						M.buttons_buffer -= button
					else if(get_dist(src, button) > connection_range)
						to_chat(usr, "<span class='warning'>The last saved button is out of range!</span>")
						M.buttons_buffer -= button
					else
						to_chat(usr, "<span class='notice'>You connect the last saved button</span>")
						switch(href_list["type"])
							if("interior")
								interior_access_button = button
								button.command = "cycle_interior"
							if("exterior")
								exterior_access_button = button
								button.command = "cycle_exterior"
						button.controller = src
						button.update_icon()
						M.buttons_buffer -= button

				if("sensor")
					if(!M.sensors_buffer.len)
						to_chat(usr, "<span class='warning'>The sensors buffer of multitool is empty</span>")
						return

					var/obj/machinery/airlock_sensor/sensor = M.sensors_buffer[M.sensors_buffer.len]
					if(sensor.controller)
						to_chat(usr, "<span class='warning'>The last saved sensor already has a connection!</span>")
						M.sensors_buffer -= sensor
					else if(get_dist(src, sensor) > connection_range)
						to_chat(usr, "<span class='warning'>The last saved sensor is out of range!</span>")
						M.sensors_buffer -= sensor
					else
						to_chat(usr, "<span class='notice'>You connect the last saved sensor</span>")
						switch(href_list["type"])
							if("chamber")
								chamber_sensor = sensor
								program.chamber_sensor = sensor
							if("interior")
								interior_sensor = sensor
								program.interior_sensor = sensor
							if("exterior")
								exterior_sensor = sensor
								program.exterior_sensor = sensor
						sensor.controller = src
						sensor.update_icon()
						M.sensors_buffer -= sensor

				if("airpump")
					if(!M.airpumps_buffer.len)
						to_chat(usr, "<span class='warning'>The airpumps buffer of multitool is empty</span>")
						return

					var/obj/machinery/atmospherics/components/unary/vent_pump/airpump = M.airpumps_buffer[M.airpumps_buffer.len]
					if(airpump.controller)
						to_chat(usr, "<span class='warning'>The last saved airpump already has a connection!</span>")
						M.airpumps_buffer -= airpump
					else if(get_dist(src, airpump) > connection_range)
						to_chat(usr, "<span class='warning'>The last saved airpump is out of range!</span>")
						M.airpumps_buffer -= airpump
					else
						to_chat(usr, "<span class='notice'>You connect the last saved airpump</span>")
						airpumps += airpump
						program.airpumps += airpump
						airpump.controller = src
						airpump.frequency = 1379
						airpump.set_frequency(airpump.frequency)
						M.airpumps_buffer -= airpump

		if(href_list["disconnect"])
			switch(href_list["disconnect"])
				if("interior_door")
					disconnect_door(interior_door)
				if("exterior_door")
					disconnect_door(exterior_door)
				if("interior_access_button")
					disconnect_access_button(interior_access_button)
				if("exterior_access_button")
					disconnect_access_button(exterior_access_button)
				if("chamber_sensor")
					disconnect_sensor(chamber_sensor)
				if("interior_sensor")
					disconnect_sensor(interior_sensor)
				if("exterior_sensor")
					disconnect_sensor(exterior_sensor)
				if("airpump")
					disconnect_airpump(airpumps[text2num(href_list["airpump"])])
				if("all")
					disconnect_all()

		if(href_list["access_setup_target"])
			access_setup_target = !access_setup_target

		if(href_list["controller_one_access"])
			controller_one_access = !controller_one_access
			if(controller_one_access)
				req_one_access = req_access.Copy()
				req_access.Cut()
			else
				req_access = req_one_access.Copy()
				req_one_access.Cut()

		if(href_list["buttons_one_access"])
			buttons_one_access = !buttons_one_access
			update_buttons_accesses()

		if(href_list["controller_access"])
			var/acc = text2num(href_list["controller_access"])
			if(controller_one_access)
				if(!(acc in req_one_access))
					req_one_access += acc
				else
					req_one_access -= acc
			else
				if(!(acc in req_access))
					req_access += acc
				else
					req_access -= acc

		if(href_list["buttons_access"])
			var/acc = text2num(href_list["buttons_access"])
			if(!(acc in buttons_req_access))
				buttons_req_access += acc
			else
				buttons_req_access -= acc
			update_buttons_accesses()

		update_connection_state()
		update_icon()
		set_up_airlock_controller(usr)

	else if(emagged)
		to_chat(view(2, src), "<span class='danger'>INTERFACE ERROR [program.state == STATE_EXTERMINATING ? "" : ": SELF-REPAIR PROTOCOLS ACTIVATED"]</span>")
		program.toggleDoor(program.memory["exterior_status"], exterior_door, 1, "close")
		program.toggleDoor(program.memory["interior_status"], interior_door, 1, "close")
		exterior_door.secondsElectrified = -1
		interior_door.secondsElectrified = -1
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		electrocute_mob(usr, get_area(src), src)
		last_electrocute = world.timeofday
		program.state = STATE_EXTERMINATING
		update_icon()
		return FALSE

	else
		. = ..()

/obj/machinery/embedded_controller/radio/proc/update_buttons_accesses()
	if(buttons_one_access)
		interior_access_button.req_access = null
		interior_access_button.req_one_access = buttons_req_access
		exterior_access_button.req_access = null
		exterior_access_button.req_one_access = buttons_req_access
	else
		interior_access_button.req_one_access = null
		interior_access_button.req_access = buttons_req_access
		exterior_access_button.req_one_access = null
		exterior_access_button.req_access = buttons_req_access

/obj/machinery/embedded_controller/radio/proc/reset_menu()
	connections_showed = FALSE
	accesses_showed = FALSE
	airlocks_showed = FALSE
	airpumps_showed = FALSE
	access_buttons_showed = FALSE
	airlock_sensors_showed = FALSE
	access_setup_target = CONTROLLER

/obj/machinery/embedded_controller/radio/proc/disconnect_all()
	if(exterior_door)
		disconnect_door(exterior_door)
	if(interior_door)
		disconnect_door(interior_door)
	if(exterior_access_button)
		disconnect_access_button(exterior_access_button)
	if(interior_access_button)
		disconnect_access_button(interior_access_button)
	if(chamber_sensor)
		disconnect_sensor(chamber_sensor)
	if(exterior_sensor)
		disconnect_sensor(exterior_sensor)
	if(interior_sensor)
		disconnect_sensor(interior_sensor)
	for(var/airpump in airpumps)
		disconnect_airpump(airpump)

/obj/machinery/embedded_controller/radio/proc/disconnect_door(obj/machinery/door/airlock/airlock)
	if(airlock == exterior_door)
		exterior_door = null
		program.exterior_door = null
	else if(airlock == interior_door)
		interior_door = null
		program.interior_door = null
	else
		return
	airlock.controller = null
	update_connection_state()
	update_icon()

/obj/machinery/embedded_controller/radio/proc/disconnect_access_button(obj/machinery/access_button/button)
	if(button == exterior_access_button)
		exterior_access_button = null
	else if(button == interior_access_button)
		interior_access_button = null
	else
		return
	button.controller = null
	button.update_icon()
	update_connection_state()
	update_icon()

/obj/machinery/embedded_controller/radio/proc/disconnect_sensor(obj/machinery/airlock_sensor/sensor)
	if(sensor == chamber_sensor)
		chamber_sensor = null
		program.chamber_sensor = null
	else if(sensor == exterior_sensor)
		exterior_sensor = null
		program.exterior_sensor = null
	else if(sensor == interior_sensor)
		interior_sensor = null
		program.interior_sensor = null
	else
		return
	sensor.controller = null
	sensor.update_icon()
	update_connection_state()
	update_icon()

/obj/machinery/embedded_controller/radio/proc/disconnect_airpump(obj/machinery/atmospherics/components/unary/vent_pump/airpump)
	if(airpump in airpumps)
		airpumps -= airpump
		program.airpumps -= airpump
	else
		return
	airpump.controller = null
	airpump.frequency = 1439
	airpump.set_frequency(airpump.frequency)
	update_connection_state()
	update_icon()

/obj/machinery/embedded_controller/radio/post_signal(datum/signal/signal)
	signal.transmission_method = TRANSMISSION_RADIO
	if(radio_connection)
		return radio_connection.post_signal(src, signal)
	else
		qdel(signal)

/obj/machinery/embedded_controller/radio/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency)

/obj/machinery/embedded_controller/radio/power_change()
	..()
	update_icon()
	if(chamber_sensor)
		chamber_sensor.update_icon()
	if(exterior_sensor)
		exterior_sensor.update_icon()
	if(interior_sensor)
		interior_sensor.update_icon()
	if(exterior_access_button)
		exterior_access_button.update_icon()
	if(interior_access_button)
		interior_access_button.update_icon()

/obj/machinery/embedded_controller/radio/examine(mob/user)
	..()
	switch(buildstage)
		if(AIRLOCK_CONTROLLER_WITHOUT_CIRCUIT)
			to_chat(user, "<span class='notice'>It requieres a circuit board</span>")
		if(AIRLOCK_CONTROLLER_WITHOUT_WIRES)
			to_chat(user, "<span class='notice'>It requieres some wires</span>")



/obj/item/embedded_controller_assembly
	icon = 'icons/obj/airlock_machines.dmi'
	var/path

/obj/item/embedded_controller_assembly/attackby(obj/item/weapon/W, mob/user)
	..()
	if(iswrench(W))
		playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
		new /obj/item/stack/sheet/metal(get_turf(src.loc), 2)
		qdel(src)

/obj/item/embedded_controller_assembly/afterattack(atom/target, mob/user, inrange, params)
	if(!inrange)
		return

	var/T = target
	if(!istype(T, /turf/simulated/wall) && !istype(T, /obj/structure/window))
		return

	var/ndir = get_dir(T, usr)
	if(!(ndir in cardinal))
		return

	var/turf/loc = get_turf_loc(usr)
	var/area/A = get_area(src)

	if (!istype(loc, /turf/simulated/floor))
		to_chat(usr, "<span class='warning'>Airlock controller cannot be placed on this spot.</span>")
		return

	if (A.requires_power == 0 || istype(A, /area/space))
		to_chat(usr, "<span class='warning'>Airlock controller cannot be placed in this area.</span>")
		return

	if(gotwallitem(loc, ndir))
		to_chat(usr, "<span class='warning'>There's already an item on this wall!</span>")
		return

	new path(loc, ndir)

	qdel(src)

#undef BUTTONS
#undef CONTROLLER
