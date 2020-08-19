#define SYNDICATE_SHUTTLE_MOVE_TIME 215
#define SYNDICATE_SHUTTLE_COOLDOWN 200

/obj/machinery/computer/syndicate_station
	name = "syndicate shuttle terminal"
	circuit = /obj/item/weapon/circuitboard/computer/syndicate_shuttle
	icon = 'icons/obj/computer.dmi'
	icon_state = "syndishuttle"
	state_broken_preset = "tcbossb"
	state_nopower_preset = "tcboss0"
	light_color = "#a91515"
	req_access = list(access_syndicate)
	var/area/curr_location
	var/moving = 0
	var/lastMove = 0

/obj/effect/landmark/syndi_shuttle

/obj/machinery/computer/syndicate_station/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/syndicate_station/atom_init_late()
	var/obj/O = locate(/obj/effect/landmark/syndi_shuttle) in landmarks_list
	curr_location = get_area(O)

/obj/machinery/computer/syndicate_station/proc/syndicate_move_to(area/destination)
	if(moving)	return
	if(lastMove + SYNDICATE_SHUTTLE_COOLDOWN > world.time)	return
	var/area/dest_location = locate(destination)
	if(curr_location == dest_location)	return

	moving = 1
	lastMove = world.time

	if(curr_location.z != dest_location.z)
		var/area/transit_location = locate(/area/shuttle/syndicate/transit)
		curr_location.move_contents_to(transit_location)
		curr_location = transit_location
		sleep(SYNDICATE_SHUTTLE_MOVE_TIME)
		curr_location.parallax_slowdown()
		sleep(PARALLAX_LOOP_TIME)

	curr_location.move_contents_to(dest_location)
	curr_location = dest_location
	moving = 0
	return 1

/obj/machinery/computer/syndicate_station/ui_interact(mob/user)
	var/dat = {"Location: [curr_location]<br>
	Ready to move[max(lastMove + SYNDICATE_SHUTTLE_COOLDOWN - world.time, 0) ? " in [max(round((lastMove + SYNDICATE_SHUTTLE_COOLDOWN - world.time) * 0.1), 0)] seconds" : ": now"]<br>
	<a href='?src=\ref[src];syndicate=1'>Syndicate Space</a><br>
	<a href='?src=\ref[src];station_nw=1'>North West of SS13</a> |
	<a href='?src=\ref[src];station_n=1'>North of SS13</a> |
	<a href='?src=\ref[src];station_ne=1'>North East of SS13</a><br>
	<a href='?src=\ref[src];station_sw=1'>South West of SS13</a> |
	<a href='?src=\ref[src];station_s=1'>South of SS13</a> |
	<a href='?src=\ref[src];station_se=1'>South East of SS13</a><br>
	<a href='?src=\ref[src];mining=1'>North East of the Mining Asteroid</a><br>
	<a href='?src=\ref[user];mach_close=computer'>Close</a>"}

	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")


/obj/machinery/computer/syndicate_station/Topic(href, href_list)
	. = ..()
	if(!. || !allowed(usr))
		return
	if(war_device_activated)
		if(world.time < SYNDICATE_CHALLENGE_TIMER)
			to_chat(usr, "<span class='warning'>You've issued a combat challenge to the station! You've got to give them at least \
		 	[round(((SYNDICATE_CHALLENGE_TIMER - world.time) / 10) / 60)] \
		 	more minutes to allow them to prepare.</span>")
			return
	else
		war_device_activation_forbidden = TRUE

	if(href_list["syndicate"])
		syndicate_move_to(/area/shuttle/syndicate/start)
	else if(href_list["station_nw"])
		syndicate_move_to(/area/shuttle/syndicate/northwest)
	else if(href_list["station_n"])
		syndicate_move_to(/area/shuttle/syndicate/north)
	else if(href_list["station_ne"])
		syndicate_move_to(/area/shuttle/syndicate/northeast)
	else if(href_list["station_sw"])
		syndicate_move_to(/area/shuttle/syndicate/southwest)
	else if(href_list["station_s"])
		syndicate_move_to(/area/shuttle/syndicate/south)
	else if(href_list["station_se"])
		syndicate_move_to(/area/shuttle/syndicate/southeast)
	else if(href_list["mining"])
		syndicate_move_to(/area/shuttle/syndicate/mining)

	updateUsrDialog()

/obj/item/weapon/circuitboard/computer/syndicate_shuttle
	name = "Syndicate Shuttle (Computer Board)"
	build_path = /obj/machinery/computer/syndicate_station

#undef SYNDICATE_SHUTTLE_MOVE_TIME
#undef SYNDICATE_SHUTTLE_COOLDOWN
