#define ARRIVAL_SHUTTLE_MOVE_TIME 175
#define ARRIVAL_SHUTTLE_COOLDOWN 650
#define ARRIVAL_SHUTTLE_VELOCITY 0
#define ARRIVAL_SHUTTLE_TRANSIT 1
#define ARRIVAL_SHUTTLE_EXODUS 2


var/location = ARRIVAL_SHUTTLE_VELOCITY // 0 - Start 2 - NSS Exodus 1 - transit
var/moving = FALSE
var/area/curr_location
var/lastMove = 0

/obj/machinery/computer/arrival_shuttle
	name = "Arrival Shuttle Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "wagon"
	var/arrival_note = "Arrival shuttle docked with the NSS Exodus."
	var/department_note = "Arrival shuttle left the NSS Exodus."
	var/obj/item/device/radio/intercom/radio


/obj/machinery/computer/arrival_shuttle/atom_init()
//	curr_location= locate(/area/shuttle/arrival/velocity)
	arrival_note = "Arrival shuttle docked with the [station_name()]."
	department_note = "Arrival shuttle left the [station_name()]."
	radio = new (src)
	. = ..()

/obj/machinery/computer/arrival_shuttle/proc/try_move_from_station()
	if(moving || location != ARRIVAL_SHUTTLE_EXODUS || !SSshuttle)
		return
	var/myArea = get_area(src)
	if(SSshuttle.forbidden_atoms_check(myArea))
		addtimer(CALLBACK(src, .proc/try_move_from_station), 600)
		return
	arrival_shuttle_move()

/obj/machinery/computer/arrival_shuttle/proc/arrival_shuttle_ready_move()
	if(lastMove + ARRIVAL_SHUTTLE_COOLDOWN > world.time)
		return FALSE
	return TRUE

/obj/machinery/computer/arrival_shuttle/proc/arrival_shuttle_move()
	set waitfor = 0
	if(moving)
		return
	if(!arrival_shuttle_ready_move())
		return
	moving = TRUE
	lastMove = world.time
	var/area/fromArea
	var/area/toArea
	var/area/destArea
	var/destLocation

	if(location == ARRIVAL_SHUTTLE_VELOCITY)
		fromArea = locate(/area/shuttle/arrival/velocity)
		destArea = locate(/area/shuttle/arrival/station)
		destLocation = ARRIVAL_SHUTTLE_EXODUS
	else if(location == ARRIVAL_SHUTTLE_EXODUS)
		fromArea = locate(/area/shuttle/arrival/station)
		destArea = locate(/area/shuttle/arrival/velocity)
		destLocation = ARRIVAL_SHUTTLE_VELOCITY
	else
		return

	toArea = locate(/area/shuttle/arrival/transit)
	curr_location = fromArea

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

	toArea.parallax_movedir = WEST
	fromArea.move_contents_to(toArea, null, WEST)
	location = ARRIVAL_SHUTTLE_TRANSIT
	play_flying_sound(toArea)
	SSshuttle.shake_mobs_in_area(toArea, EAST)

	curr_location = toArea
	fromArea = toArea
	toArea = destArea

	sleep(ARRIVAL_SHUTTLE_MOVE_TIME)
	curr_location.parallax_slowdown()
	sleep(PARALLAX_LOOP_TIME)

	fromArea.move_contents_to(toArea, null, WEST)

	// Sending message only on EXODUS
	if (destLocation == ARRIVAL_SHUTTLE_EXODUS)
		if (!radio_message_via_ai(arrival_note))
			radio.autosay(arrival_note, "Arrivals Alert System")

	location = destLocation
	play_flying_sound(toArea)
	SSshuttle.shake_mobs_in_area(toArea, WEST)

	curr_location = destArea
	moving = FALSE
	open_doors(toArea, location)

	if(location == ARRIVAL_SHUTTLE_EXODUS)
		addtimer(CALLBACK(src, .proc/try_move_from_station), 600)


/obj/machinery/computer/arrival_shuttle/proc/lock_doors(area/A)
	SSshuttle.undock_act(/area/velocity, "velocity_1")
	SSshuttle.undock_act(/area/station/hallway/secondary/entry, "arrival_1")
	SSshuttle.undock_act(A)

/obj/machinery/computer/arrival_shuttle/proc/open_doors(area/A, arrival)
	switch(arrival)
		if(0) //Velocity
			SSshuttle.dock_act(/area/velocity, "velocity_1")
			SSshuttle.dock_act(A)

		if(2) //Station
			SSshuttle.dock_act(/area/station/hallway/secondary/entry, "arrival_1")
			SSshuttle.dock_act(A)

/obj/machinery/computer/arrival_shuttle/proc/play_flying_sound(area/A)
	for(var/mob/M in A)
		if(M.client)
			if(location == ARRIVAL_SHUTTLE_TRANSIT)
				M.playsound_local(null, 'sound/effects/shuttle_flying.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/obj/machinery/computer/arrival_shuttle/ui_interact(user)
	var/dat = "<center>Shuttle location:[curr_location]<br>Ready to move[!arrival_shuttle_ready_move() ? " in [max(round((lastMove + ARRIVAL_SHUTTLE_COOLDOWN - world.time) * 0.1), 0)] seconds" : ": now"]<br><b><A href='?src=\ref[src];move=1'>Send</A></b></center><br>"
	user << browse("[dat]", "window=researchshuttle;size=200x130")

/obj/machinery/computer/arrival_shuttle/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["move"])
		if(!arrival_shuttle_ready_move())
			to_chat(usr, "<span class='notice'>Shuttle is not ready to move yet.</span>")
		else if(!moving && location == ARRIVAL_SHUTTLE_VELOCITY)
			to_chat(usr, "<span class='notice'>Shuttle recieved message and will be sent shortly.</span>")
			arrival_shuttle_move()
		else
			to_chat(usr, "<span class='notice'>Shuttle is already moving or docked with station.</span>")

		usr.client.guard.velocity_console = TRUE

/obj/machinery/computer/arrival_shuttle/dock
	name = "Arrival Shuttle Communication Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "wagon"

/obj/machinery/computer/arrival_shuttle/dock/ui_interact(user)
	var/dat1 = "<center>Shuttle location:[curr_location]<br>Ready to move[!arrival_shuttle_ready_move() ? " in [max(round((lastMove + ARRIVAL_SHUTTLE_COOLDOWN - world.time) * 0.1), 0)] seconds" : ": now"]<br><b><A href='?src=\ref[src];back=1'>Send back</A></b></center><br>"
	user << browse(dat1, "window=researchshuttle;size=200x130")

/obj/machinery/computer/arrival_shuttle/dock/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["back"])
		if(!arrival_shuttle_ready_move())
			to_chat(usr, "<span class='notice'>Shuttle is not ready to move yet.</span>")
		else if(!moving && location == ARRIVAL_SHUTTLE_EXODUS)
			to_chat(usr, "<span class='notice'>Shuttle recieved message and will be sent shortly.</span>")
			arrival_shuttle_move()
		else
			to_chat(usr, "<span class='notice'>Shuttle is already moving or docked with station.</span>")

		usr.client.guard.velocity_console_dock = TRUE

/obj/machinery/computer/arrival_shuttle/proc/radio_message_via_ai(msg)
	if (!msg)
		return FALSE
	for (var/mob/living/silicon/ai/A in ai_list)
		if (A.can_retransmit_messages())
			A.retransmit_message(msg)
			return TRUE
	return FALSE