#define ARRIVAL_SHUTTLE_MOVE_TIME 175
#define ARRIVAL_SHUTTLE_COOLDOWN 650
#define ARRIVAL_SHUTTLE_VELOCITY 0
#define ARRIVAL_SHUTTLE_TRANSIT 1
#define ARRIVAL_SHUTTLE_EXODUS 2


var/global/location = ARRIVAL_SHUTTLE_VELOCITY // 0 - Start 2 - NSS Exodus 1 - transit
var/global/moving = FALSE
var/global/area/curr_location
var/global/lastMove = 0

/obj/machinery/computer/arrival_shuttle
	name = "Arrival Shuttle Console"
	cases = list("консоль трансферного шаттла", "консоли трансферного шаттла", "консоли трансферного шаттла", "консоль трансферного шаттла", "консолью трансферного шаттла", "консоли трансферного шаттла")
	icon = 'icons/obj/computer.dmi'
	icon_state = "wagon"
	var/arrival_note = "Трансферный шаттл пристыковался к КСН Исход."
	var/department_note = "Трансферный шаттл покинул КСН Исход."
	var/obj/item/device/radio/intercom/radio


/obj/machinery/computer/arrival_shuttle/atom_init()
	curr_location= locate(/area/shuttle/arrival/velocity)
	arrival_note = "Трансферный шаттл пристыковался к [station_name_ru()]."
	department_note = "Трансферный шаттл покинул [station_name_ru()]."
	radio = new (src)
	. = ..()

/obj/machinery/computer/arrival_shuttle/process()
	if(..())
		if(lastMove + ARRIVAL_SHUTTLE_COOLDOWN + 20 >= world.time)
			updateUsrDialog()

/obj/machinery/computer/arrival_shuttle/proc/try_move_from_station()
	if(moving || location != ARRIVAL_SHUTTLE_EXODUS || !SSshuttle)
		return
	var/myArea = get_area(src)
	if(SSshuttle.forbidden_atoms_check(myArea))
		addtimer(CALLBACK(src, PROC_REF(try_move_from_station)), 600)
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
		L.force_override_color = "#00ff00"
		L.color = "#00ff00"
		L.update(0)

	sleep(140)

	lock_doors(fromArea)

	sleep(10)

	for(var/obj/machinery/light/small/L in fromArea)
		L.force_override_color = initial(L.force_override_color)
		L.color = initial(L.color)
		L.update(0)

	sleep(50)

	toArea.parallax_movedir = WEST
	fromArea.move_contents_to(toArea, null)
	location = ARRIVAL_SHUTTLE_TRANSIT
	play_flying_sound(toArea)
	SSshuttle.shake_mobs_in_area(toArea, EAST)

	curr_location = toArea
	fromArea = toArea
	toArea = destArea

	sleep(ARRIVAL_SHUTTLE_MOVE_TIME)
	curr_location.parallax_slowdown()
	sleep(PARALLAX_LOOP_TIME)

	fromArea.move_contents_to(toArea, null)

	// Sending message only on EXODUS
	if (destLocation == ARRIVAL_SHUTTLE_EXODUS)
		if (!radio_message_via_ai(arrival_note))
			radio.autosay(arrival_note, "Система оповещения")

	location = destLocation
	play_flying_sound(toArea)
	SSshuttle.shake_mobs_in_area(toArea, WEST)

	curr_location = destArea
	moving = FALSE
	open_doors(toArea, location)

	if(location == ARRIVAL_SHUTTLE_EXODUS)
		addtimer(CALLBACK(src, PROC_REF(try_move_from_station)), 600)


/obj/machinery/computer/arrival_shuttle/proc/lock_doors(area/A)
	SSshuttle.undock_act(/area/velocity, "velocity_1")
	SSshuttle.undock_act(/area/station/hallway/secondary/arrival, "arrival_1")
	SSshuttle.undock_act(A)
	// Sending message only on EXODUS
	if(curr_location == locate(/area/shuttle/arrival/station))
		SSshuttle.undock_act(/area/station/hallway/secondary/arrival, "arrival_1")
		SSshuttle.undock_act(curr_location, "arrival_1")
		if (!radio_message_via_ai(department_note))
			radio.autosay(department_note, "Система оповещения")

/obj/machinery/computer/arrival_shuttle/proc/open_doors(area/A, arrival)
	switch(arrival)
		if(0) //Velocity
			SSshuttle.dock_act(/area/velocity, "velocity_1")
			SSshuttle.dock_act(A)

		if(2) //Station
			SSshuttle.dock_act(/area/station/hallway/secondary/arrival, "arrival_1")
			SSshuttle.dock_act(A)

/obj/machinery/computer/arrival_shuttle/proc/play_flying_sound(area/A)
	for(var/mob/M in A)
		if(M.client)
			if(location == ARRIVAL_SHUTTLE_TRANSIT)
				M.playsound_local(null, 'sound/effects/shuttle_flying.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/obj/machinery/computer/arrival_shuttle/ui_interact(user)
	var/seconds = max(round((lastMove + ARRIVAL_SHUTTLE_COOLDOWN - world.time) * 0.1), 0)
	var/seconds_word = pluralize_russian(seconds, "секунду", "секунды", "секунд")
	var/dat = "<center><div class='Section'>Местоположение: <b>[capitalize(CASE(curr_location, NOMINATIVE_CASE))]</b><br>Готов к полёту[!arrival_shuttle_ready_move() ? " через [seconds] [seconds_word]" : ": сейчас"]<br><A href='?src=\ref[src];move=1'>Начать полёт</A></div></center>"
	var/datum/browser/popup = new(user, "researchshuttle", "[capitalize(CASE(src, NOMINATIVE_CASE))]", 330, 130)
	popup.set_content(dat)
	popup.open()


/obj/machinery/computer/arrival_shuttle/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["move"])
		if(!arrival_shuttle_ready_move())
			to_chat(usr, "<span class='notice'>Шаттл ещё не готов к полёту.</span>")
		else if(!moving && location == ARRIVAL_SHUTTLE_VELOCITY)
			to_chat(usr, "<span class='notice'>Шаттл получил запрос и будет отправлен в ближайшее время.</span>")
			arrival_shuttle_move()
		else
			to_chat(usr, "<span class='notice'>Шаттл уже движется или состыкован со станцией.</span>")

		usr.client.guard.velocity_console = TRUE

/obj/machinery/computer/arrival_shuttle/dock
	name = "Arrival Shuttle Communication Console"
	cases = list("консоль связи трансферного шаттла", "консоли связи трансферного шаттла", "консоли связи трансферного шаттла", "консоль связи трансферного шаттла", "консолью связи трансферного шаттла", "консоли связи трансферного шаттла")
	icon = 'icons/obj/computer.dmi'
	icon_state = "wagon"

/obj/machinery/computer/arrival_shuttle/dock/ui_interact(user)
	var/seconds = max(round((lastMove + ARRIVAL_SHUTTLE_COOLDOWN - world.time) * 0.1), 0)
	var/seconds_word = pluralize_russian(seconds, "секунду", "секунды", "секунд")
	var/dat = "<center>Местоположение: <b>[capitalize(CASE(curr_location, NOMINATIVE_CASE))]</b><br>Готов к полёту[!arrival_shuttle_ready_move() ? " через [seconds] [seconds_word]" : ": сейчас"]<br><b><A href='?src=\ref[src];back=1'>Запросить шаттл обратно</A></b></center><br>"
	var/datum/browser/popup = new(user, "researchshuttle", "[capitalize(CASE(src, NOMINATIVE_CASE))]", 290, 130)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/arrival_shuttle/dock/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["back"])
		if(!arrival_shuttle_ready_move())
			to_chat(usr, "<span class='notice'>Шаттл ещё не готов к полёту.</span>")
		else if(!moving && location == ARRIVAL_SHUTTLE_EXODUS)
			to_chat(usr, "<span class='notice'>Шаттл получил запрос и будет отправлен в ближайшее время.</span>")
			arrival_shuttle_move()
		else
			to_chat(usr, "<span class='notice'>Шаттл уже движется или состыкован со станцией.</span>")

		usr.client.guard.velocity_console_dock = TRUE

/obj/machinery/computer/arrival_shuttle/proc/radio_message_via_ai(msg)
	if (!msg)
		return FALSE
	for (var/mob/living/silicon/ai/A as anything in ai_list)
		if (A.can_retransmit_messages())
			A.retransmit_message(msg)
			return TRUE
	return FALSE
