//Transport shuttle

/obj/machinery/computer/shuttle_control/transport
	name = "Transport shuttle console"
	shuttle_tag = "Transport shuttle"
	req_access = list(access_cent_specops)

/datum/shuttle/autodock/ferry/transport
	name = "Transport shuttle"
	location = 1
	warmup_time = 10
	shuttle_area = /area/shuttle/transport1/centcom
	dock_target = "transport_shuttle_centcom_shuttle"
	waypoint_station = "nav_transport_start"
	waypoint_offsite = "nav_transport_out"

/obj/effect/shuttle_landmark/transport/start
	name = "Station"
	landmark_tag = "nav_transport_start"
	docking_controller = "transport_shuttle_dock"

/obj/effect/shuttle_landmark/transport/out
	name = "Centcom"
	landmark_tag = "nav_transport_out"
	docking_controller = "transport_shuttle_centcom"
	special_dock_targets = list("Transport shuttle" = "transport_shuttle_centcom_shuttle2")


//Administration shuttle
/obj/machinery/computer/shuttle_control/administration
	name = "Administration shuttle console"
	shuttle_tag = "Administration shuttle"
	req_access = list(access_cent_specops)

/datum/shuttle/autodock/ferry/administration
	name = "Administration shuttle"
	location = 1
	warmup_time = 10
	shuttle_area = /area/shuttle/administration/centcom
	dock_target = "administration_shuttle"
	waypoint_station = "nav_administration_start"
	waypoint_offsite = "nav_administration_out"

/obj/effect/shuttle_landmark/administration/start
	name = "Station"
	landmark_tag = "nav_administration_start"
	docking_controller = "administration_shuttle_dock"

/obj/effect/shuttle_landmark/administration/out
	name = "Centcom"
	landmark_tag = "nav_administration_out"
	docking_controller = "administration_shuttle_centcom"
	base_turf = /turf/unsimulated/floor


//Centcom-Velocity-Station
/obj/machinery/computer/shuttle_control/multi/centcom_ferry
	name = "Shuttle console"
	shuttle_tag = "Centcom ferry shuttle"
	req_access = list(access_cent_specops)

/datum/shuttle/autodock/multi/centcom_ferry
	name = "Centcom ferry shuttle"
	warmup_time = 10
	destination_tags = list(
		"nav_centcom_ferry_station",
		"nav_centcom_ferry_velocity",
		"nav_centcom_ferry_centcom"
		)
	shuttle_area = /area/shuttle/officer/velocity
	dock_target = "centcom_ferry_shuttle"
	current_location = "nav_centcom_ferry_velocity"


/obj/effect/shuttle_landmark/centcom_ferry/stataion
	name = "NSS Exodus"
	landmark_tag = "nav_centcom_ferry_station"
	docking_controller = "centcom_ferry_station"

/obj/effect/shuttle_landmark/centcom_ferry/velocity
	name = "NTS Velocity"
	landmark_tag = "nav_centcom_ferry_velocity"
	docking_controller = "centcom_ferry_velocity"

/obj/effect/shuttle_landmark/centcom_ferry/centcom
	name = "Central Command"
	landmark_tag = "nav_centcom_ferry_centcom"
	docking_controller = "centcom_ferry_centcom"


//SpecOps
/obj/machinery/computer/shuttle_control/specops
	name = "Special operations shuttle console"
	shuttle_tag = "Special Operations"
	req_access = list(access_cent_specops)

/obj/machinery/computer/shuttle_control/specops/attack_ai(mob/user as mob)
	to_chat(user, "<span class='warning'>Access Denied.</span>")
	return 1

/datum/shuttle/autodock/ferry/specops
	name = "Special Operations"
	location = 1
	shuttle_area = /area/shuttle/specops/centcom
	dock_target = "specops_shuttle"
	waypoint_station = "nav_specops_start"
	waypoint_offsite = "nav_specops_out"
	var/specops_return_delay = 6000		//After moving, the amount of time that must pass before the shuttle may move again
	var/specops_countdown_time = 600	//Length of the countdown when moving the shuttle

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
		return

	if (istype(user, /obj/machinery/computer))
		var/obj/machinery/computer/C = user

		if(world.time <= reset_time)
			C.visible_message("<span class='notice'>Central Command will not allow the Special Operations shuttle to launch yet.</span>")
			if (((world.time - reset_time) * 0.1) > 60)
				C.visible_message("<span class='notice'>[-((world.time - reset_time)*0.1)/60] minutes remain!</span>")
			else
				C.visible_message("<span class='notice'>[-(world.time - reset_time)*0.1] seconds remain!</span>")
			return

		C.visible_message("<span class='notice'>The Special Operations shuttle will depart in [(specops_countdown_time*0.1)] seconds.</span>")

	if (!location)	//returning
		radio_announce("THE SPECIAL OPERATIONS SHUTTLE IS PREPARING TO RETURN")
	else
		radio_announce("THE SPECIAL OPERATIONS SHUTTLE IS PREPARING FOR LAUNCH")

	sleep_until_launch()
	if(cancel_countdown)
		return

	//launch
	radio_announce("ALERT: INITIATING LAUNCH SEQUENCE")
	..(user)

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

/obj/effect/shuttle_landmark/specops/start
	name = "Station"
	landmark_tag = "nav_specops_start"
	docking_controller = "specops_shuttle_dock"

/obj/effect/shuttle_landmark/specops/out
	name = "Centcom"
	landmark_tag = "nav_specops_out"
	docking_controller = "specops_shuttle_centcom"
	special_dock_targets = list("Special Operations" = "specops_shuttle1")
