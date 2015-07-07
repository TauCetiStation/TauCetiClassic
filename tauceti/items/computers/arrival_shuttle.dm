#define ARRIVAL_SHUTTLE_MOVE_TIME 200
#define ARRIVAL_SHUTTLE_COOLDOWN 400

var/location = 0 // 0 - Start 2 - NSS Exodus 1 - transit
var/moving = 0
var/area/curr_location
var/lastMove = 0

/obj/machinery/computer/arrival_shuttle
	name = "Arrival Shuttle Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	var/arrival_note = "Arrival shuttle docked with the NSS Exodus."
	var/department_note = "Arrival shuttle left the NSS Exodus."
	var/obj/item/device/radio/intercom/radio


/obj/machinery/computer/arrival_shuttle/New()
//	curr_location= locate(/area/shuttle/arrival/pre_game)
	radio = new (src)

/obj/machinery/computer/arrival_shuttle/proc/arrival_shuttle_move()
	if(moving)	return
	if(lastMove + ARRIVAL_SHUTTLE_COOLDOWN > world.time)	return
	moving = 1
	lastMove = world.time
	var/area/fromArea
	var/area/toArea

	if(location == 0)
		fromArea = locate(/area/shuttle/arrival/pre_game)
		sleep(75)

		for(var/obj/machinery/door/unpowered/shuttle/D in fromArea)
			spawn(0)
			D.close()

		toArea = locate(/area/shuttle/arrival/transit)
		curr_location = fromArea

		fromArea.move_contents_to(toArea, null, WEST)
		for(var/mob/M in toArea)
			if(M.client)
				spawn(0)
					if(M.buckled)
						shake_camera(M, 2, 1)
					else
						shake_camera(M, 4, 2)
						M.Weaken (4)
		location = 1
		curr_location = locate(/area/shuttle/arrival/transit)
		sleep(ARRIVAL_SHUTTLE_MOVE_TIME)

		fromArea = locate(/area/shuttle/arrival/transit)
		toArea = locate(/area/shuttle/arrival/station)

		fromArea.move_contents_to(toArea, null, WEST)
		radio.autosay(arrival_note, "Arrivals Alert System")
		for(var/mob/M in toArea)
			if(M.client)
				spawn(0)
					if(M.buckled)
						shake_camera(M, 2, 1)
					else
						shake_camera(M, 4, 2)
						M.Weaken (4)
		location = 2
		curr_location = locate(/area/shuttle/arrival/station)
		moving = 0
		return

	if(location == 2)
		fromArea = locate(/area/shuttle/arrival/station)
		sleep(75)

		for(var/obj/machinery/door/unpowered/shuttle/D in fromArea)
			spawn(0)
			D.close()

		toArea = locate(/area/shuttle/arrival/transit)
		radio.autosay(department_note, "Arrivals Alert System")
		curr_location = fromArea

		fromArea.move_contents_to(toArea, null, WEST)
		for(var/mob/M in toArea)
			if(M.client)
				spawn(0)
					if(M.buckled)
						shake_camera(M, 2, 1)
					else
						shake_camera(M, 4, 2)
						M.Weaken (4)
		location = 1
		curr_location = locate(/area/shuttle/arrival/transit)
		sleep(ARRIVAL_SHUTTLE_MOVE_TIME)

		fromArea = locate(/area/shuttle/arrival/transit)
		toArea = locate(/area/shuttle/arrival/pre_game)

		fromArea.move_contents_to(toArea, null, WEST)
		for(var/mob/M in toArea)
			if(M.client)
				spawn(0)
					if(M.buckled)
						shake_camera(M, 2, 1)
					else
						shake_camera(M, 4, 2)
						M.Weaken (4)
		location = 0
		curr_location = locate(/area/shuttle/arrival/pre_game)
		moving = 0
		return


/*
	var/area/transit_location = locate(/area/shuttle/arrival/transit)
	if (location == 0)
		fromArea = locate(/area/shuttle/arrival/pre_game)
		curr_location= locate(/area/shuttle/arrival/pre_game)
		toArea = locate(/area/shuttle/arrival/station)
	else
		fromArea = locate(/area/shuttle/arrival/station)
		curr_location= locate(/area/shuttle/arrival/station)
		toArea = locate(/area/shuttle/arrival/pre_game)

	for(var/obj/machinery/door/unpowered/shuttle/D in fromArea)
		spawn(0)
		D.close()

	fromArea.move_contents_to(transit_location)
	if(fromArea == locate(/area/shuttle/arrival/station))
		radio.autosay(department_note, "Arrivals Alert System")
	curr_location = transit_location
	sleep(ARRIVAL_SHUTTLE_MOVE_TIME)
	curr_location.move_contents_to(toArea)
	if(toArea == locate(/area/shuttle/arrival/station))
		radio.autosay(arrival_note, "Arrivals Alert System")
	curr_location = toArea
	if (!location)
		location = 1
	else
		location = 0

	moving = 0

	return */

/obj/machinery/computer/arrival_shuttle/attack_hand(user as mob)
	src.add_fingerprint(usr)
	var/dat = "<center>Shuttle location:[curr_location]<br>Ready to move[max(lastMove + ARRIVAL_SHUTTLE_COOLDOWN - world.time, 0) ? " in [max(round((lastMove + ARRIVAL_SHUTTLE_COOLDOWN - world.time) * 0.1), 0)] seconds" : ": now"]<br><b><A href='?src=\ref[src];move=1'>Send</A></b></center><br>"

	user << browse("[dat]", "window=researchshuttle;size=200x100")

/obj/machinery/computer/arrival_shuttle/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["move"])
		if(!in_range(src, usr))
			usr << "\red Too far."
			return
		if (!moving)
			usr << "\blue Shuttle recieved message and will be sent shortly."
			arrival_shuttle_move()
		else
			usr << "\blue Shuttle is already moving."

/obj/machinery/computer/arrival_shuttle/dock
	name = "Arrival Shuttle Communication Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"

/obj/machinery/computer/arrival_shuttle/dock/attack_hand(user as mob)
	src.add_fingerprint(usr)
	var/dat1 = "<center>Shuttle location:[curr_location]<br>Ready to move[max(lastMove + ARRIVAL_SHUTTLE_COOLDOWN - world.time, 0) ? " in [max(round((lastMove + ARRIVAL_SHUTTLE_COOLDOWN - world.time) * 0.1), 0)] seconds" : ": now"]<br><b><A href='?src=\ref[src];back=1'>Send back</A></b></center><br>"

	user << browse("[dat1]", "window=researchshuttle;size=200x100")

/obj/machinery/computer/arrival_shuttle/dock/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["back"])
		if(!in_range(src, usr))
			usr << "\red Too far."
			return
		if (!moving && location == 2)
			usr << "\blue Shuttle recieved message and will be sent shortly."
			arrival_shuttle_move()
		else
			usr << "\blue Shuttle is already moving or docked with station."