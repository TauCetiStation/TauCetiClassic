#define ARRIVAL_SHUTTLE_MOVE_TIME 200
#define ARRIVAL_SHUTTLE_COOLDOWN 650

var/location = 0 // 0 - Start 2 - NSS Exodus 1 - transit
var/moving = 0
var/area/curr_location
var/lastMove = 0

/obj/machinery/computer/arrival_shuttle
	name = "Arrival Shuttle Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "wagon"
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
		for(var/obj/machinery/light/small/L in fromArea)
			L.brightness_color = "#00ff00"
			L.color = "#00ff00"
			L.update(0)

		sleep(140)

		lock_doors(fromArea)

		sleep(10)

		for(var/obj/machinery/light/small/L in fromArea)
			L.brightness_color = initial(L.brightness_color)
			L.color = initial(L.color)
			L.update(0)

		sleep(50)

		toArea = locate(/area/shuttle/arrival/transit)
		curr_location = fromArea

		fromArea.move_contents_to(toArea, null, WEST)
		shake_mobs(toArea)

		location = 1
		curr_location = locate(/area/shuttle/arrival/transit)
		sleep(ARRIVAL_SHUTTLE_MOVE_TIME)

		fromArea = locate(/area/shuttle/arrival/transit)
		toArea = locate(/area/shuttle/arrival/station)

		fromArea.move_contents_to(toArea, null, WEST)
		radio.autosay(arrival_note, "Arrivals Alert System")

		shake_mobs(toArea)

		location = 2
		curr_location = locate(/area/shuttle/arrival/station)
		moving = 0

		open_doors(toArea, 1)

		return

	if(location == 2)
		fromArea = locate(/area/shuttle/arrival/station)
		for(var/obj/machinery/light/small/L in fromArea)
			L.brightness_color = "#00ff00"
			L.color = "#00ff00"
			L.update(0)

		sleep(140)

		lock_doors(fromArea)

		sleep(10)

		for(var/obj/machinery/light/small/L in fromArea)
			L.brightness_color = initial(L.brightness_color)
			L.color = initial(L.color)
			L.update(0)

		sleep(50)

		toArea = locate(/area/shuttle/arrival/transit)
		radio.autosay(department_note, "Arrivals Alert System")
		curr_location = fromArea

		fromArea.move_contents_to(toArea, null, WEST)

		shake_mobs(toArea)

		location = 1
		curr_location = locate(/area/shuttle/arrival/transit)
		sleep(ARRIVAL_SHUTTLE_MOVE_TIME)

		fromArea = locate(/area/shuttle/arrival/transit)
		toArea = locate(/area/shuttle/arrival/pre_game)

		fromArea.move_contents_to(toArea, null, WEST)

		shake_mobs(toArea)

		location = 0
		curr_location = locate(/area/shuttle/arrival/pre_game)
		moving = 0

		open_doors(toArea, 2)

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

/obj/machinery/computer/arrival_shuttle/proc/lock_doors(area/A)
	var/area/velocity = locate(/area/centcom/arrival)
	for(var/obj/machinery/door/airlock/external/D in velocity)
		if(D.tag == "velocity_1")
			D.close()
			spawn(10) //incase someone messing with door.
				if(D && D.density)
					D.locked = 1
					D.update_icon()

	var/area/station = locate(/area/hallway/secondary/entry)
	for(var/obj/machinery/door/airlock/external/D in station)
		if(D.tag == "arrival_1")
			D.close()
			spawn(10)
				if(D && D.density)
					D.locked = 1
					D.update_icon()

	for(var/obj/machinery/door/unpowered/shuttle/wagon/D in A)
		spawn(0)
			D.close()
			D.locked = 1

/obj/machinery/computer/arrival_shuttle/proc/open_doors(area/A, arrival)
	switch(arrival)
		if(1) //Station
			var/area/station = locate(/area/hallway/secondary/entry)
			for(var/obj/machinery/door/airlock/external/D in station)
				if(D.tag == "arrival_1")
					D.locked = 0
					D.update_icon()

			for(var/obj/machinery/door/unpowered/shuttle/wagon/D in A)
				spawn(0)
					D.locked = 0
					D.open()
		if(2) //Velocity
			var/area/velocity = locate(/area/centcom/arrival)
			for(var/obj/machinery/door/airlock/external/D in velocity)
				if(D.tag == "velocity_1")
					D.locked = 0
					D.update_icon()

			for(var/obj/machinery/door/unpowered/shuttle/wagon/D in A)
				spawn(0)
					D.locked = 0
					D.open()

/obj/machinery/computer/arrival_shuttle/proc/shake_mobs(area/A)
	for(var/mob/M in A)
		if(M.client)
			spawn(0)
				if(M.buckled)
					shake_camera(M, 2, 1)
				else
					shake_camera(M, 4, 2)
		M.Weaken(4)
		if(isliving(M) && !M.buckled)
			var/mob/living/L = M
			if(isturf(L.loc))
				for(var/i=0, i < 5, i++)
					var/turf/T = L.loc
					var/hit = 0
					T = get_step(T, EAST)
					if(T.density)
						hit = 1
						if(i > 1)
							L.adjustBruteLoss(10)
						break
					else
						for(var/atom/movable/AM in T.contents)
							if(AM.density)
								hit = 1
								if(i > 1)
									L.adjustBruteLoss(10)
									if(isliving(AM))
										var/mob/living/bumped = AM
										bumped.adjustBruteLoss(10)
								break
					if(hit)
						break
					step(L, EAST)

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
	icon_state = "wagon"

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