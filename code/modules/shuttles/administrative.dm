#define OFFICER_SHUTTLE_MOVE_TIME 60 //seconds
#define OFFICER_SHUTTLE_COOLDOWN 40 //seconds

//
//Transport shuttle
//
/obj/machinery/computer/shuttle_control/transport
	name = "Transport shuttle console"
	shuttle_tag = "Transport shuttle"
	req_access = list(access_cent_specops)

/datum/shuttle/autodock/ferry/transport
	name = "Transport shuttle"
	location = SHUTTLE_LOCATION_OFFSITE
	warmup_time = 5 //seconds
	shuttle_area = /area/shuttle/transport1
	dock_target = "transport_shuttle"
	waypoint_station = "nav_transport_start"
	waypoint_offsite = "nav_station_dock_2"

/*
Vars:
	shuttle:
		docking_port_multi:
			child_tags_txt: "transport_shuttle1;transport_shuttle2"
			id_tag: "transport_shuttle"
			name: "Transport Shuttle Docking Controller"
		simple_docking_controller/multi_slave: (south)
			master_tag: "transport_shuttle"
			id_tag: "transport_shuttle1"
			name: "Transport Shuttle Hatch Controller #1"
		simple_docking_controller/multi_slave: (north)
			master_tag: "transport_shuttle"
			id_tag: "transport_shuttle2"
			name: "Transport Shuttle Hatch Controller #2"

	centcom dock:
		simple_docking_controller:
			id_tag: "transport_centcom"
			name: "Transport Shuttle Dock Controller"

	station dock:
		docking_port_multi:
			child_tags_txt: "station_dock_21;station_dock_22"
			id_tag: "station_dock_2"
			name: "Docking Port Controller #2"
		airlock/docking_port_multi_slave: (south)
			master_tag: "station_dock_2"
			id_tag: "station_dock_21"
			name: "Docking Port Controller #2-1"
		airlock/docking_port_multi_slave: (north)
			master_tag: "station_dock_2"
			id_tag: "station_dock_22"
			name: "Docking Port Controller #2-2"
*/

/obj/effect/shuttle_landmark/transport/start
	name = "Station"
	landmark_tag = "nav_station_dock_2"
	docking_controller = "station_dock_2"

/obj/effect/shuttle_landmark/transport/out
	name = "Centcom"
	landmark_tag = "nav_transport_out"
	docking_controller = "transport_centcom"
	special_dock_targets = list("Transport shuttle" = "transport_shuttle2")

//
// Administration shuttle
//
/obj/machinery/computer/shuttle_control/administration
	name = "Administration shuttle console"
	shuttle_tag = "Administration shuttle"
	req_access = list(access_cent_specops)

/datum/shuttle/autodock/ferry/administration
	name = "Administration shuttle"
	location = SHUTTLE_LOCATION_OFFSITE
	shuttle_area = /area/shuttle/administration
	dock_target = "administration_shuttle"
	waypoint_station = "nav_administration_station"
	waypoint_offsite = "nav_administration_centcom"

/*
Vars:
	shuttle:
		simple_docking_controller:
			id_tag: "administration_shuttle"
			name: "Administration Shuttle Docking Port Controller"

	centcom dock:
		simple_docking_controller:
			id_tag: "administration_centcom"
			name: "Administration Shuttle Docking Port Controller"

	station dock:
		simple_docking_controller:
			id_tag: "administration_station"
			name: "Docking Port Controller #4"
*/

/obj/effect/shuttle_landmark/administration/start
	name = "Station"
	landmark_tag = "nav_administration_station"
	docking_controller = "administration_station"

/obj/effect/shuttle_landmark/administration/out
	name = "Centcom"
	landmark_tag = "nav_administration_centcom"
	docking_controller = "administration_centcom"
	base_turf = /turf/unsimulated/floor

//
// Centcom-Velocity-Station
//
/obj/machinery/computer/shuttle_control/multi/officer
	name = "Shuttle console"
	shuttle_tag = "Velocity ferry shuttle"

/datum/shuttle/autodock/multi/officer
	name = "Velocity ferry shuttle"
	move_cooldown = OFFICER_SHUTTLE_COOLDOWN
	move_time = OFFICER_SHUTTLE_MOVE_TIME
	warmup_time = 10 //seconds
	destination_tags = list(
		"nav_officer_station",
		"nav_officer_velocity",
		"nav_officer_centcom"
		)
	shuttle_area = /area/shuttle/officer
	dock_target = "officer_shuttle"
	current_location = "nav_officer_velocity"
	landmark_transition = "nav_officer_trans"
	var/obj/item/device/radio/intercom/announcer
	var/arrival_note = "Velocity transport shuttle docked with - dock 1."
	var/department_note = "Velocity transport shuttle departed from station."

/datum/shuttle/autodock/multi/officer/New(_name, obj/effect/shuttle_landmark/start_waypoint)
	..()
	announcer = new ()

/datum/shuttle/autodock/multi/officer/Destroy()
	QDEL_NULL(announcer)
	return ..()

/datum/shuttle/autodock/multi/officer/post_move(obj/effect/shuttle_landmark/destination)
	..()
	if(destination.landmark_tag == "nav_officer_station")
		announcer.autosay(arrival_note, "Arrivals Alert System")
	else if(current_location.landmark_tag == "nav_officer_station")
		announcer.autosay(department_note, "Arrivals Alert System")

/*
Vars:
	shuttle:
		simple_docking_controller:
			id_tag: "officer_shuttle"
			name: "Velocity Shuttle Docking Port Controller"

	centcom dock:
		simple_docking_controller:
			id_tag: "officer_centcom"
			name: "Velocity Shuttle Docking Port Controller"

	velocity dock:
		simple_docking_controller:
			id_tag: "officer_velocity"
			name: "Velocity Shuttle Docking Port Controller"

	station dock:
		simple_docking_controller:
			id_tag: "officer_station"
			name: "Docking Port Controller #1"
*/

/obj/effect/shuttle_landmark/officer/station
	name = "NSS Exodus"
	landmark_tag = "nav_officer_station"
	docking_controller = "officer_station"

/obj/effect/shuttle_landmark/officer/velocity
	name = "NTS Velocity"
	landmark_tag = "nav_officer_velocity"
	docking_controller = "officer_velocity"

/obj/effect/shuttle_landmark/officer/centcom
	name = "Central Command"
	landmark_tag = "nav_officer_centcom"
	docking_controller = "officer_centcom"

/obj/effect/shuttle_landmark/officer/transit
	name = "Hyperspace"
	landmark_tag = "nav_officer_trans"

//
//SpecOps
//
/obj/machinery/computer/shuttle_control/specops
	name = "Special operations shuttle console"
	shuttle_tag = "Special Operations"
	req_access = list(access_cent_specops)

/obj/machinery/computer/shuttle_control/specops/attack_ai(mob/user)
	to_chat(user, "<span class='warning'>Access Denied.</span>")
	return 1

/datum/shuttle/autodock/ferry/specops
	name = "Special Operations"
	location = SHUTTLE_LOCATION_OFFSITE
	shuttle_area = /area/shuttle/specops
	dock_target = "specops_shuttle"
	waypoint_station = "nav_specops_station"
	waypoint_offsite = "nav_specops_centcom"
	var/specops_return_delay = 10 MINUTES //After moving, the amount of time that must pass before the shuttle may move again
	var/specops_countdown_time = 60 SECONDS //Length of the countdown when moving the shuttle

	var/obj/item/device/radio/intercom/announcer = null
	var/reset_time = 0	//the world.time at which the shuttle will be ready to move again.
	var/launch_prep = 0
	var/cancel_countdown = 0

/datum/shuttle/autodock/ferry/specops/New()
	..()
	announcer = new /obj/item/device/radio/intercom(null)//We need a fake AI to announce some stuff below. Otherwise it will be wonky.
	announcer.config(list("Response Team" = 0))

/datum/shuttle/autodock/ferry/specops/proc/radio_announce(message)
	if(announcer)
		announcer.autosay(message, "A.L.I.C.E.", "Response Team")

/datum/shuttle/autodock/ferry/specops/launch(user)
	set waitfor = 0
	if (!can_launch())
		return FALSE

	if (istype(user, /obj/machinery/computer))
		var/obj/machinery/computer/C = user

		if(world.time <= reset_time)
			C.visible_message("<span class='notice'>Central Command will not allow the Special Operations shuttle to launch yet.</span>")
			if (((world.time - reset_time) * 0.1) > 60)
				C.visible_message("<span class='notice'>[-((world.time - reset_time)*0.1)/60] minutes remain!</span>")
			else
				C.visible_message("<span class='notice'>[-(world.time - reset_time)*0.1] seconds remain!</span>")
			return FALSE

		C.visible_message("<span class='notice'>The Special Operations shuttle will depart in [(specops_countdown_time*0.1)] seconds.</span>")

	if (!location)	//returning
		radio_announce("THE SPECIAL OPERATIONS SHUTTLE IS PREPARING TO RETURN")
	else
		radio_announce("THE SPECIAL OPERATIONS SHUTTLE IS PREPARING FOR LAUNCH")

	sleep_until_launch()
	if(cancel_countdown)
		return FALSE

	//launch
	radio_announce("ALERT: INITIATING LAUNCH SEQUENCE")
	return ..()

/datum/shuttle/autodock/ferry/specops/post_move()
	..()
	reset_time = world.time + specops_return_delay
	if(location)	//just arrived home
		for(var/turf/T in get_area_turfs(shuttle_area))
			var/mob/M = locate(/mob) in T
			to_chat(M, "<span class='danger'>You have arrived at Central Command. Operation has ended!</span>")
	else	//just left for the station
		for(var/turf/T in get_area_turfs(shuttle_area))
			var/mob/M = locate(/mob) in T
			to_chat(M, "<span class='danger'>You have arrived at [station_name()]. Commence operation!</span>")

/datum/shuttle/autodock/ferry/specops/cancel_launch()
	if (!can_cancel())
		return

	cancel_countdown = 1
	radio_announce("ALERT: LAUNCH SEQUENCE ABORTED")
	if (istype(in_use, /obj/machinery/computer))
		var/obj/machinery/computer/C = in_use
		C.visible_message("<span class='warning'>Launch sequence aborted.</span>")
	..()


/datum/shuttle/autodock/ferry/specops/can_launch()
	if(launch_prep)
		return FALSE
	return ..()

//should be fine to allow forcing. process_state only becomes WAIT_LAUNCH after the countdown is over.
///datum/shuttle/autodock/ferry/specops/can_force()
//	return 0

/datum/shuttle/autodock/ferry/specops/can_cancel()
	if(launch_prep)
		return TRUE
	return ..()

/datum/shuttle/autodock/ferry/specops/proc/sleep_until_launch()
	var/message_tracker[] = list(0,1,2,3,5,10,30,45)//Create a a list with potential time values.

	var/launch_time = world.time + specops_countdown_time
	var/time_until_launch

	cancel_countdown = 0
	launch_prep = TRUE
	while(!cancel_countdown && (launch_time - world.time) > 0)
		var/ticksleft = launch_time - world.time

		//if(ticksleft > 1e5)
		//	launch_time = world.timeofday + 10	// midnight rollover
		time_until_launch = (ticksleft / 10)

		//All this does is announce the time before launch.
		var/rounded_time_left = round(time_until_launch)//Round time so that it will report only once, not in fractions.
		if(rounded_time_left in message_tracker)//If that time is in the list for message announce.
			radio_announce("ALERT: [rounded_time_left] SECOND[(rounded_time_left!=1)?"S":""] REMAIN")
			message_tracker -= rounded_time_left//Remove the number from the list so it won't be called again next cycle.
			//Should call all the numbers but lag could mean some issues. Oh well. Not much I can do about that.

		sleep(5)

	launch_prep = FALSE

/*
Vars:
	shuttle:
		docking_port_multi:
			child_tags_txt: "specops_station1;specops_station2"
			id_tag: "specops_shuttle"
			name: "Special Operations Shuttle Docking Port Controller"
		simple_docking_controller/multi_slave: (south)
			master_tag: "specops_shuttle"
			id_tag: "specops_shuttle1"
			name: "Special Operations Shuttle Hatch Controller #1"
		simple_docking_controller/multi_slave: (east)
			master_tag: "specops_shuttle"
			id_tag: "specops_shuttle2"
			name: "Special Operations Shuttle Hatch Controller #2"

	centcom dock:
		simple_docking_controller:
			id_tag: "specops_centcom"
			name: "Special Operations Shuttle Docking Port Controller"

	station dock:
		docking_port_multi:
			id_tag: "specops_station"
			name: "Docking Port Controller #3"
		simple_docking_controller/multi_slave: (south)
			master_tag: "specops_station"
			id_tag: "specops_station1"
			name: "Docking Port Controller #3-1"
		simple_docking_controller/multi_slave: (east)
			master_tag: "specops_station"
			id_tag: "specops_station2"
			name: "Docking Port Controller #3-2"
*/

/obj/effect/shuttle_landmark/specops/station
	name = "Station"
	landmark_tag = "nav_specops_station"
	docking_controller = "specops_station"

/obj/effect/shuttle_landmark/specops/centcom
	name = "Centcom"
	landmark_tag = "nav_specops_centcom"
	docking_controller = "specops_centcom"
	special_dock_targets = list("Special Operations" = "specops_shuttle1")

#undef OFFICER_SHUTTLE_MOVE_TIME
#undef OFFICER_SHUTTLE_COOLDOWN
