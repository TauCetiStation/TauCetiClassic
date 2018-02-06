//Console

/obj/machinery/computer/shuttle_control/emergency
	name = "Shuttle"
	desc = "For shuttle control."
	icon_state = "shuttle"
	light_color = "#7BF9FF"
	shuttle_tag = "Emergency Shuttle"
	var/debug = 0
	var/req_authorizations = 3
	var/list/authorized = list()

/obj/machinery/computer/shuttle_control/emergency/proc/has_authorization()
	return (authorized.len >= req_authorizations || emagged)

/obj/machinery/computer/shuttle_control/emergency/proc/reset_authorization()
	//no need to reset emagged status. If they really want to go back to the station they can.
	authorized = initial(authorized)

//returns 1 if the ID was accepted and a new authorization was added, 0 otherwise
/obj/machinery/computer/shuttle_control/emergency/proc/read_authorization(obj/item/ident)
	if(!istype(ident))
		return 0
	if(authorized.len >= req_authorizations)
		return 0 //don't need any more

	var/list/access
	var/auth_name
	var/dna_hash

	var/obj/item/weapon/card/id/ID = ident.GetID()

	if(!ID)
		return

	access = ID.access
	auth_name = "[ID.registered_name] ([ID.assignment])"
	dna_hash = ID.dna_hash

	if (!islist(access))
		return 0	//not an ID

	if (dna_hash in authorized)
		visible_message("\The [src] buzzes. That ID has already been scanned.")
		return 0

	if (!(access_heads in access))
		visible_message("\The [src] buzzes, rejecting [ident].")
		return 0

	visible_message("\The [src] beeps as it scans [ident].")
	authorized[dna_hash] = auth_name
	if(req_authorizations - authorized.len)
		to_chat(world, "<span class='notice'><b>Alert: [req_authorizations - authorized.len] authorization\s needed to override the shuttle autopilot.</b></span>")

	if(usr)
		message_admins("[key_name_admin(usr)] has inserted [ID] into the shuttle control computer - [req_authorizations - authorized.len] authorisation\s needed")
		log_game("[usr.ckey] has inserted [ID] into the shuttle control computer - [req_authorizations - authorized.len] authorisation\s needed")

	return 1

/obj/machinery/computer/shuttle_control/emergency/proc/emag_act(mob/user)
	if (!emagged)
		to_chat(user, "<span class='notice'>You short out \the [src]'s authorization protocols.</span>")
		emagged = TRUE

/obj/machinery/computer/shuttle_control/emergency/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/card/emag))
		emag_act()
		return
	if(read_authorization(I))
		return
	..()

/obj/machinery/computer/shuttle_control/emergency/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	var/data[0]
	var/datum/shuttle/autodock/ferry/emergency/shuttle = SSshuttle.emergency_shuttle
	if(!istype(shuttle))
		return

	var/shuttle_state
	switch(shuttle.moving_status)
		if(SHUTTLE_IDLE) shuttle_state = "idle"
		if(SHUTTLE_WARMUP) shuttle_state = "warmup"
		if(SHUTTLE_INTRANSIT) shuttle_state = "in_transit"

	var/shuttle_status
	switch(shuttle.process_state)
		if(IDLE_STATE)
			if(shuttle.in_use)
				shuttle_status = "Busy."
			else if(!shuttle.location)
				shuttle_status = "Standing-by at [station_name()]."
			else
				shuttle_status = "Standing-by at CentComm."
		if(WAIT_LAUNCH, FORCE_LAUNCH)
			shuttle_status = "Shuttle has recieved command and will depart shortly."
		if(WAIT_ARRIVE)
			shuttle_status = "Proceeding to destination."
		if(WAIT_FINISH)
			shuttle_status = "Arriving at destination now."

	//build a list of authorizations
	var/list/auth_list[req_authorizations]

	if(!emagged)
		var/i = 1
		for(var/dna_hash in authorized)
			auth_list[i++] = list("auth_name"=authorized[dna_hash], "auth_hash"=dna_hash)

		while(i <= req_authorizations)	//fill up the rest of the list with blank entries
			auth_list[i++] = list("auth_name"="", "auth_hash"=null)
	else
		for(var/i in 1 to req_authorizations)
			auth_list[i] = list("auth_name"="<font color=\"red\">ERROR</font>", "auth_hash"=null)

	var/has_auth = has_authorization()

	data = list(
		"shuttle_status" = shuttle_status,
		"shuttle_state" = shuttle_state,
		"has_docking" = shuttle.active_docking_controller? 1 : 0,
		"docking_status" = shuttle.active_docking_controller? shuttle.active_docking_controller.get_docking_status() : null,
		"docking_override" = shuttle.active_docking_controller? shuttle.active_docking_controller.override_enabled : null,
		"can_launch" = shuttle.can_launch(src),
		"can_cancel" = shuttle.can_cancel(src),
		"can_force" = shuttle.can_force(src),
		"auth_list" = auth_list,
		"has_auth" = has_auth,
		"user" = debug? user : null,
	)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "escape_shuttle_control_console.tmpl", "Shuttle Control", 470, 420)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/shuttle_control/emergency/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["removeid"])
		var/dna_hash = href_list["removeid"]
		authorized -= dna_hash

	else if(!emagged && href_list["scanid"])
		//They selected an empty entry. Try to scan their id.
		var/mob/living/carbon/human/H = usr
		if(istype(H))
			if(!read_authorization(H.get_active_hand()))	//try to read what's in their hand first
				read_authorization(H.wear_id)

	updateUsrDialog()


//Shuttle

/datum/shuttle/autodock/ferry/emergency
	name = "Emergency Shuttle"
	location = SHUTTLE_LOCATION_OFFSITE
	warmup_time = 0
	shuttle_area = /area/shuttle/escape
	dock_target = "emergency_shuttle"
	waypoint_station = "nav_emergency_station"
	waypoint_offsite = "nav_emergency_centcom"
	landmark_transition = "nav_emergency_trans"
	transition_parallax_movedir = WEST
	move_time = 0

/datum/shuttle/autodock/ferry/emergency/New()
	. = ..()
	if(SSshuttle.emergency_shuttle)
		CRASH("An emergency shuttle has already been created.")
		return
	SSshuttle.emergency_shuttle = src

/datum/shuttle/autodock/ferry/emergency/Destroy()
	if(SSshuttle.emergency_shuttle == src)
		SSshuttle.emergency_shuttle = null
	return ..()

/datum/shuttle/autodock/ferry/emergency/arrived()
	. = ..()
	if(!location)
		SSshuttle.location = SHUTTLE_AT_STATION
		move_time = SHUTTLELEAVETIME
		SSshuttle.settimeleft(SHUTTLELEAVETIME)
		if(SSshuttle.alert == 0)
			captain_announce("The Emergency Shuttle has docked with the station. You have [round(SSshuttle.timeleft()/60,1)] minutes to board the Emergency Shuttle.")
			world << sound('sound/AI/shuttledock.ogg')
		else
			captain_announce("The scheduled Crew Transfer Shuttle has docked with the station. It will depart in approximately [round(SSshuttle.timeleft()/60,1)] minutes.")

		send2slack_service("the shuttle has docked with the station")

	else
		SSshuttle.location = SHUTTLE_AT_CENTCOM

	if(istype(in_use, /obj/machinery/computer/shuttle_control/emergency))
		var/obj/machinery/computer/shuttle_control/emergency/C = in_use
		C.reset_authorization()

/datum/shuttle/autodock/ferry/emergency/post_move(obj/effect/shuttle_landmark/destination)
	..()
	if(current_location == waypoint_station)
		SSshuttle.location = SHUTTLE_IN_TRANSIT
		SSshuttle.departed = TRUE
		SSshuttle.direction = 2
		SSshuttle.settimeleft(SHUTTLETRANSITTIME)

/datum/shuttle/autodock/ferry/emergency/can_launch(user)
	if(!SSshuttle.online)
		return FALSE
	if(istype(user, /obj/machinery/computer/shuttle_control/emergency))
		var/obj/machinery/computer/shuttle_control/emergency/C = user
		if(!C.has_authorization())
			return FALSE
	return ..()

/datum/shuttle/autodock/ferry/emergency/can_force(user)
	if(!SSshuttle.online)
		return FALSE
	if(istype(user, /obj/machinery/computer/shuttle_control/emergency))
		var/obj/machinery/computer/shuttle_control/emergency/C = user

		//initiating or cancelling a launch ALWAYS requires authorization, but if we are already set to launch anyways than forcing does not.
		//this is so that people can force launch if the docking controller cannot safely undock without needing X heads to swipe.
		if(!(process_state == WAIT_LAUNCH || C.has_authorization()))
			return FALSE
	return ..()

/datum/shuttle/autodock/ferry/emergency/can_cancel(user)
	if(in_use == SSshuttle && user != SSshuttle)
		return FALSE
	if(istype(user, /obj/machinery/computer/shuttle_control/emergency))
		var/obj/machinery/computer/shuttle_control/emergency/C = user
		if(!C.has_authorization())
			return FALSE
	return ..()

/datum/shuttle/autodock/ferry/emergency/launch(user)
	if(!can_launch(user))
		return

	if(istype(user, /obj/machinery/computer/shuttle_control/emergency))	//if we were given a command by an emergency shuttle console
		to_chat(world, "<span class='notice'><b>Alert: The shuttle autopilot has been overridden. Launch sequence initiated!</b></span>")

	if(usr)
		message_admins("[key_name_admin(usr)] has overridden the shuttle autopilot and activated launch sequence")
		log_game("[usr.ckey] has overridden the shuttle autopilot and activated launch sequence")

	..(user)

/datum/shuttle/autodock/ferry/emergency/force_launch(user)
	if(!can_force(user))
		return

	if(istype(user, /obj/machinery/computer/shuttle_control/emergency))	//if we were given a command by an emergency shuttle console
		to_chat(world, "<span class='notice'><b>Alert: The shuttle autopilot has been overridden. Bluespace drive engaged!</b></span>")

	if(usr)
		message_admins("[key_name_admin(usr)] has overridden the shuttle autopilot and forced immediate launch")
		log_game("[usr.ckey] has overridden the shuttle autopilot and forced immediate launch")

	..(user)

/datum/shuttle/autodock/ferry/emergency/cancel_launch(var/user)
	if(!can_cancel(user))
		return

	if (istype(user, /obj/machinery/computer/shuttle_control/emergency))	//if we were given a command by an emergency shuttle console
		to_chat(world, "<span class='notice'><b>Alert: The shuttle autopilot has been overridden. Launch sequence aborted!</b></span>")

	if(usr)
		message_admins("[key_name_admin(usr)] has overridden the shuttle autopilot and cancelled launch sequence")
		log_game("[usr.ckey] has overridden the shuttle autopilot and cancelled launch sequence")

	..(user)

//Landmarks

/*
Vars:
	shuttle:
		simple_docking_controller:
			id_tag: "emergency_shuttle"
			name: "Emergency Shuttle Docking Port Controller"

	centcom dock:
		simple_docking_controller:
			id_tag: "emergency_centcom"
			name: "Emergency Shuttle Docking Port Controller"

	station dock:
		docking_port_multi:
			child_tags_txt: "emergency_station1;emergency_station2"
			id_tag: "emergency_station"
			name: "Emergency Shuttle Docking Port Controller"
		airlock/docking_port_multi_slave: (west)
			master_tag: "emergency_station"
			id_tag: "emergency_station1"
			name: "Emergency Shuttle Docking Port Controller #1"
		airlock/docking_port_multi_slave: (east)
			master_tag: "emergency_station"
			id_tag: "emergency_station2"
			name: "Emergency Shuttle Docking Port Controller #2"
*/

/obj/effect/shuttle_landmark/emergency/centcom
	name = "Central Command"
	landmark_tag = "nav_emergency_centcom"
	docking_controller = "emergency_centcom"

/obj/effect/shuttle_landmark/emergency/station
	name = "NSS Exodus"
	landmark_tag = "nav_emergency_station"
	docking_controller = "emergency_station"

/obj/effect/shuttle_landmark/emergency/transition
	name = "Hyperspace"
	landmark_tag = "nav_emergency_trans"
