#define VOX_CAN_USE(A) (ishuman(A) && A.can_speak(all_languages["Vox-pidgin"]) || isobserver(A))
#define VOX_SHUTTLE_MOVE_TIME 40 //seconds
#define VOX_SHUTTLE_COOLDOWN 120 //seconds

#define SYNDICATE_SHUTTLE_MOVE_TIME 24 //seconds
#define SYNDICATE_SHUTTLE_COOLDOWN 20 //seconds

//
// Vox Shuttle
//

/obj/machinery/computer/shuttle_control/multi/antag/vox
	name = "skipjack control console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "syndishuttle"
	shuttle_tag = "Skipjack"

/obj/machinery/computer/shuttle_control/multi/antag/vox/attack_ai(mob/user)
	if(!IsAdminGhost(user))
		to_chat(user, "<span class='red'><b>W?r#nING</b>: #%@!!W?|_4?54@ \nUn?B88l3 T? L?-?o-L?CaT2 ##$!?RN?0..%..</span>")//Totally not stolen from ninja.
	else
		. = ..()

/obj/machinery/computer/shuttle_control/multi/antag/vox/attack_hand(mob/user)
	if(!VOX_CAN_USE(user))
		to_chat(user, "<span class='notice'>You have no idea how to use this.</span>")
		return
	. = ..()

/obj/machinery/computer/shuttle_control/multi/antag/vox/toggle_stealth(datum/shuttle/autodock/multi/antag/shuttle)
	if(shuttle.current_location != shuttle.home_waypoint)
		return // no point in this console after moving shuttle from start position.

	if(shuttle.cloaked)
		audible_message("<span class='notice'>Смена режима маскировки: торговое судно. КСН \"Исход\" будет оповещен о нашем прибытии.</span>")
	else
		audible_message("<span class='notice'>Смена режима маскировки: полная маскировки. КСН \"Исход\" не будет оповещен о нашем прибытии.</span>")

	..()

var/global/vox_shuttle_location

/datum/shuttle/autodock/multi/antag/vox
	name = "Skipjack"
	move_cooldown = VOX_SHUTTLE_COOLDOWN
	move_time = VOX_SHUTTLE_MOVE_TIME
	destination_tags = list(
		"vox_home",
		"vox_station_nw",
		"vox_station_ne",
		"vox_station_sw",
		"vox_station_se",
		"vox_mining"
		)
	shuttle_area = /area/shuttle/vox
	current_location = "vox_home"
	landmark_transition = "vox_trans"
	announcer = "NSV Icarus"
	arrival_message = "Внимание, КСН \"Исход\", неподалёку от вашей станции проходит корабль. По последним данным этот корабль принадлежит Торговой Конфедерации."
	departure_message = "Your guests are pulling away, Exodus - moving too fast for us to draw a bead on them. Looks like they're heading out of Tau Ceti at a rapid clip."
	return_warning = TRUE

/datum/shuttle/autodock/multi/antag/vox/post_move(destination)
	if(current_location == home_waypoint)
		vox_shuttle_location = "station"
	else if(next_location == home_waypoint)
		vox_shuttle_location = "start"
	..()

/datum/shuttle/autodock/multi/antag/vox/pre_move(obj/effect/shuttle_landmark/destination)
	..()
	var/dest_is_trans = destination == landmark_transition
	for(var/area/s_area in shuttle_area)
		s_area.parallax_movedir = dest_is_trans ? NORTH : 0

/datum/shuttle/autodock/multi/antag/vox/post_move(obj/effect/shuttle_landmark/destination)
	..()
	if(destination == landmark_transition)
		for(var/area/s_area in shuttle_area)
			addtimer(CALLBACK(s_area, /area.proc/parallax_slowdown), move_time - PARALLAX_LOOP_TIME)

/obj/effect/shuttle_landmark/vox/home
	name = "Dark Space"
	landmark_tag = "vox_home"

/obj/effect/shuttle_landmark/vox/station/north_west
	name = "North-west solar port"
	landmark_tag = "vox_station_nw"

/obj/effect/shuttle_landmark/vox/station/north_east
	name = "North-east starboard"
	landmark_tag = "vox_station_ne"

/obj/effect/shuttle_landmark/vox/station/south_west
	name = "South-west solar port"
	landmark_tag = "vox_station_sw"

/obj/effect/shuttle_landmark/vox/station/south_east
	name = "South-east starboard"
	landmark_tag = "vox_station_se"

/obj/effect/shuttle_landmark/vox/mining
	name = "Mining Asteroid"
	landmark_tag = "vox_mining"

/obj/effect/shuttle_landmark/vox/transition
	name = "Hyperspace"
	landmark_tag = "vox_trans"

//
// Syndicate
//
/obj/machinery/computer/shuttle_control/multi/antag/syndicate
	name = "syndicate shuttle terminal"
	circuit = /obj/item/weapon/circuitboard/computer/syndicate_shuttle
	icon = 'icons/obj/computer.dmi'
	icon_state = "syndishuttle"
	light_color = "#a91515"
	req_access = list(access_syndicate)
	shuttle_tag = "Syndicate"

/datum/shuttle/autodock/multi/antag/syndicate
	name = "Syndicate"
	move_cooldown = SYNDICATE_SHUTTLE_COOLDOWN
	move_time = SYNDICATE_SHUTTLE_MOVE_TIME
	destination_tags = list(
		"syndicate_home",
		"syndicate_station_nw",
		"syndicate_station_n",
		"syndicate_station_ne",
		"syndicate_station_sw",
		"syndicate_station_s",
		"syndicate_station_se",
		"syndicate_mining"
		)
	shuttle_area = /area/syndicate_station/shuttle
	dock_target = "syndicate_shuttle"
	current_location = "syndicate_home"
	landmark_transition = "syndicate_trans"

/datum/shuttle/autodock/multi/antag/syndicate/pre_move(obj/effect/shuttle_landmark/destination)
	..()
	var/dest_is_trans = destination == landmark_transition
	for(var/area/s_area in shuttle_area)
		s_area.parallax_movedir = dest_is_trans ? NORTH : 0

/datum/shuttle/autodock/multi/antag/syndicate/post_move(obj/effect/shuttle_landmark/destination)
	..()
	if(destination == landmark_transition)
		for(var/area/s_area in shuttle_area)
			addtimer(CALLBACK(s_area, /area.proc/parallax_slowdown), move_time - PARALLAX_LOOP_TIME)


/*
Vars:
	shuttle:
		airlock/docking_port:
			id_tag: "syndicate_shuttle"

	syndicate dock:
		simple_docking_controller:
			id_tag: "syndicate_base"
*/

/obj/effect/shuttle_landmark/syndicate/home
	name = "Syndicate Space"
	landmark_tag = "syndicate_home"
	docking_controller = "syndicate_base"

/obj/effect/shuttle_landmark/syndicate/station/north_west
	name = "North West of SS13"
	landmark_tag = "syndicate_station_nw"

/obj/effect/shuttle_landmark/syndicate/station/north
	name = "North of SS13"
	landmark_tag = "syndicate_station_n"

/obj/effect/shuttle_landmark/syndicate/station/north_east
	name = "North East of SS13"
	landmark_tag = "syndicate_station_ne"

/obj/effect/shuttle_landmark/syndicate/station/south_west
	name = "South West of SS13"
	landmark_tag = "syndicate_station_sw"

/obj/effect/shuttle_landmark/syndicate/station/south
	name = "South of SS13"
	landmark_tag = "syndicate_station_s"

/obj/effect/shuttle_landmark/syndicate/station/south_east
	name = "South East of SS13"
	landmark_tag = "syndicate_station_se"

/obj/effect/shuttle_landmark/syndicate/mining
	name = "North East of the Mining Asteroid"
	landmark_tag = "syndicate_mining"

/obj/effect/shuttle_landmark/syndicate/transition
	name = "Hyperspace"
	landmark_tag = "syndicate_trans"

#undef VOX_CAN_USE
#undef VOX_SHUTTLE_MOVE_TIME
#undef VOX_SHUTTLE_COOLDOWN

#undef SYNDICATE_SHUTTLE_MOVE_TIME
#undef SYNDICATE_SHUTTLE_COOLDOWN
