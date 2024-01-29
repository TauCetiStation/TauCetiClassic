//Config stuff
#define SPECOPS_MOVETIME 600	//Time to station is milliseconds. 60 seconds, enough time for everyone to be on the shuttle before it leaves.
#define SPECOPS_STATION_AREATYPE /area/shuttle/specops/station //Type of the spec ops shuttle area for station
#define SPECOPS_DOCK_AREATYPE /area/shuttle/specops/centcom	//Type of the spec ops shuttle area for dock
#define SPECOPS_RETURN_DELAY 6000 //Time between the shuttle is capable of moving.

var/global/specops_shuttle_moving_to_station = 0
var/global/specops_shuttle_moving_to_centcom = 0
var/global/specops_shuttle_at_station = 0
var/global/specops_shuttle_can_send = 1
var/global/specops_shuttle_time = 0
var/global/specops_shuttle_timeleft = 0

/obj/machinery/computer/specops_shuttle
	name = "special operations shuttle control console"
	cases = list("консоль управления шаттлом для специальных операций", "консоли управления шаттлом для специальных операций", "консоли управления шаттлом для специальных операций", "консоль управления шаттлом для специальных операций", "консолью управления шаттлом для специальных операций", "консоли управления шаттлом для специальных операций")
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	light_color = "#00ffff"
	var/temp = null
	var/hacked = 0
	var/allowedtocall = 0
	var/specops_shuttle_timereset = 0

/proc/specops_return()
	var/obj/item/device/radio/intercom/announcer = new /obj/item/device/radio/intercom(null)//We need a fake AI to announce some stuff below. Otherwise it will be wonky.
	announcer.config(list("Response Team" = 0))

	var/message_tracker[] = list(0,1,2,3,5,10,30,45)//Create a a list with potential time values.
	var/message = "Шаттл специального назначения готовится к отстыковке со станции [station_name_ru]."//Initial message shown.
	if(announcer)
		announcer.autosay(message, "А.Л.И.С.А.", "Response Team")

	while(specops_shuttle_time - world.timeofday > 0)
		var/ticksleft = specops_shuttle_time - world.timeofday

		if(ticksleft > 1e5)
			specops_shuttle_time = world.timeofday + 10	// midnight rollover
		specops_shuttle_timeleft = (ticksleft / 10)

		//All this does is announce the time before launch.
		if(announcer)
			var/rounded_time_left = round(specops_shuttle_timeleft)//Round time so that it will report only once, not in fractions.
			var/rounded_time_left_seconds = pluralize_russian(rounded_time_left, "секунду", "секунды", "секунд")
			if(rounded_time_left in message_tracker)//If that time is in the list for message announce.
				message = "ТРЕВОГА: осталось [rounded_time_left] [rounded_time_left_seconds]"
				if(rounded_time_left==0)
					message = "ТРЕВОГА: Шаттл начинает отстыковку"
				announcer.autosay(message, "А.Л.И.С.А.", "Response Team")
				message_tracker -= rounded_time_left//Remove the number from the list so it won't be called again next cycle.
				//Should call all the numbers but lag could mean some issues. Oh well. Not much I can do about that.

		sleep(5)

	specops_shuttle_moving_to_station = 0
	specops_shuttle_moving_to_centcom = 0

	specops_shuttle_at_station = 1

	var/area/start_location = locate(/area/shuttle/specops/station)
	var/area/end_location = locate(/area/shuttle/specops/centcom)

	SSshuttle.undock_act(start_location)
	SSshuttle.undock_act(/area/station/hallway/secondary/entry, "arrival_specops")

	sleep(10)

	var/list/dstturfs = list()
	var/throwy = world.maxy

	for(var/turf/T in end_location)
		dstturfs += T
		if(T.y < throwy)
			throwy = T.y

				// hey you, get out of the way!
	for(var/turf/T in dstturfs)
					// find the turf to move things to
		var/turf/D = locate(T.x, throwy - 1, 1)
					//var/turf/E = get_step(D, SOUTH)
		for(var/atom/movable/AM as mob|obj in T)
			AM.Move(D)
		if(istype(T, /turf/simulated))
			qdel(T)

	for(var/mob/living/carbon/bug in end_location) // If someone somehow is still in the shuttle's docking area...
		bug.gib()

	for(var/mob/living/simple_animal/pest in end_location) // And for the other kind of bug...
		pest.gib()

	start_location.move_contents_to(end_location)

	for(var/turf/T in get_area_turfs(end_location) )
		var/mob/M = locate(/mob) in T
		to_chat(M, "<span class='warning'>Вы прибыли на станцию ЦентКом. Операция завершена!</span>")

	SSshuttle.dock_act(end_location)
	SSshuttle.dock_act(/area/centcom/living, "centcomm_specops")

	specops_shuttle_at_station = 0

	for(var/obj/machinery/computer/specops_shuttle/S in computer_list)
		S.specops_shuttle_timereset = world.time + SPECOPS_RETURN_DELAY

	qdel(announcer)

/proc/specops_process()
	var/obj/item/device/radio/intercom/announcer = new /obj/item/device/radio/intercom(null)//We need a fake AI to announce some stuff below. Otherwise it will be wonky.
	announcer.config(list("Response Team" = 0))

	var/message_tracker[] = list(0,1,2,3,5,10,30,45)//Create a a list with potential time values.
	var/message = "Шаттл специального назначения готовится к отстыковке со станции Центрального Командования."//Initial message shown.
	if(announcer)
		announcer.autosay(message, "А.Л.И.С.А.", "Response Team")
//		message = "ARMORED SQUAD TAKE YOUR POSITION ON GRAVITY LAUNCH PAD"
//		announcer.autosay(message, "A.L.I.C.E.", "Response Team")

	while(specops_shuttle_time - world.timeofday > 0)
		var/ticksleft = specops_shuttle_time - world.timeofday

		if(ticksleft > 1e5)
			specops_shuttle_time = world.timeofday + 10	// midnight rollover
		specops_shuttle_timeleft = (ticksleft / 10)

		//All this does is announce the time before launch.
		if(announcer)
			var/rounded_time_left = round(specops_shuttle_timeleft)//Round time so that it will report only once, not in fractions.
			var/rounded_time_left_seconds = pluralize_russian(rounded_time_left, "секунду", "секунды", "секунд")
			if(rounded_time_left in message_tracker)//If that time is in the list for message announce.
				message = "ТРЕВОГА: осталось [rounded_time_left] [rounded_time_left_seconds]"
				if(rounded_time_left==0)
					message = "ТРЕВОГА: Шаттл начинает отстыковку"
				announcer.autosay(message, "А.Л.И.С.А.", "Response Team")
				message_tracker -= rounded_time_left//Remove the number from the list so it won't be called again next cycle.
				//Should call all the numbers but lag could mean some issues. Oh well. Not much I can do about that.

		sleep(5)

	specops_shuttle_moving_to_station = 0
	specops_shuttle_moving_to_centcom = 0

	specops_shuttle_at_station = 1
	if (specops_shuttle_moving_to_station || specops_shuttle_moving_to_centcom)
		return

	if (!specops_can_move())
		to_chat(usr, "<span class='warning'>Шаттл специального назначения не может улететь.</span>")
		return

	var/area/start_location = locate(/area/shuttle/specops/centcom)
	var/area/end_location = locate(/area/shuttle/specops/station)

	SSshuttle.undock_act(start_location)
	SSshuttle.undock_act(/area/centcom/living, "centcomm_specops")

	sleep(10)

	var/list/dstturfs = list()
	var/throwy = world.maxy

	for(var/turf/T in end_location)
		dstturfs += T
		if(T.y < throwy)
			throwy = T.y

				// hey you, get out of the way!
	for(var/turf/T in dstturfs)
					// find the turf to move things to
		var/turf/D = locate(T.x, throwy - 1, 1)
					//var/turf/E = get_step(D, SOUTH)
		for(var/atom/movable/AM as mob|obj in T)
			AM.Move(D)
		if(istype(T, /turf/simulated))
			qdel(T)

	start_location.move_contents_to(end_location)

	SSshuttle.dock_act(end_location)
	SSshuttle.dock_act(/area/station/hallway/secondary/entry, "arrival_specops")

	for(var/turf/T in get_area_turfs(end_location) )
		var/mob/M = locate(/mob) in T
		to_chat(M, "<span class='warning'>Вы прибыли на [station_name_ru]. Начинайте операцию!</span>")

	for(var/obj/machinery/computer/specops_shuttle/S in computer_list)
		S.specops_shuttle_timereset = world.time + SPECOPS_RETURN_DELAY

	qdel(announcer)

/proc/specops_can_move()
	if(specops_shuttle_moving_to_station || specops_shuttle_moving_to_centcom)
		return 0
	for(var/obj/machinery/computer/specops_shuttle/S in computer_list)
		if(world.timeofday <= S.specops_shuttle_timereset)
			return 0
	return 1

/obj/machinery/computer/specops_shuttle/attackby(I, user)
	attack_hand(user)

/obj/machinery/computer/specops_shuttle/emag_act(mob/user)
	to_chat(user, "<span class='notice'>Электронные системы в этой консоли слишком продвинуты для вашей примитивной хакерской аппаратуры.</span>")
	return TRUE //yep, don't try do that

/obj/machinery/computer/specops_shuttle/ui_interact(mob/user)
	var/seconds = max(round(specops_shuttle_timeleft), 0)
	var/seconds_word = pluralize_russian(seconds, "секунду", "секунды", "секунд")
	var/dat
	if (temp)
		dat = temp
	else
		dat += {"\nМестоположение: [specops_shuttle_moving_to_station || specops_shuttle_moving_to_centcom ? "Отправляющийся на [station_name_ru] через [seconds] [seconds_word]":specops_shuttle_at_station ? "[station_name_ru]":"Док"]<BR>
			[specops_shuttle_moving_to_station || specops_shuttle_moving_to_centcom ? "\n*Шаттл специального назначения уже отправляется.*<BR>\n<BR>":specops_shuttle_at_station ? "\n<A href='?src=\ref[src];sendtodock=1'>Начать полёт</a><BR>\n<BR>":"\n<A href='?src=\ref[src];sendtostation=1'>Отправка на [station_name_ru]</A><BR>\n<BR>"]"}

	var/datum/browser/popup = new(user, "computer", "Шаттл специального назначения", 575, 450)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/specops_shuttle/Topic(href, href_list)
	var/seconds = max(round((world.timeofday - specops_shuttle_timereset) / 10), 0)
	var/seconds_word = pluralize_russian(seconds, "секунду", "секунды", "секунд")
	. = ..()
	if(!. || !allowed(usr))
		return

	if (href_list["sendtodock"])
		if(!specops_shuttle_at_station || specops_shuttle_moving_to_station || specops_shuttle_moving_to_centcom) return

		if (!specops_can_move())
			to_chat(usr, "<span class='notice'>Центральное командование пока не разрешило шаттлу специального назначения вернуться.</span>")
			if(world.timeofday <= specops_shuttle_timereset)
				if (((world.timeofday - specops_shuttle_timereset) / 10) > 60)
					to_chat(usr, "<span class='notice'>[-((world.timeofday - specops_shuttle_timereset) / 10) / 60] минут осталось!</span>")
				to_chat(usr, "<span class='notice'>[seconds] [seconds_word] осталось!</span>")
			return FALSE

		to_chat(usr, "<span class='notice'>Шаттл специального назначения прибудет на Центральное командование через [(SPECOPS_MOVETIME / 10)] секунд.</span>")

		temp += "Шаттл отправляется.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

		specops_shuttle_moving_to_centcom = 1
		specops_shuttle_time = world.timeofday + SPECOPS_MOVETIME
		spawn(0)
			specops_return()

	else if (href_list["sendtostation"])
		if(specops_shuttle_at_station || specops_shuttle_moving_to_station || specops_shuttle_moving_to_centcom) return

		if (!specops_can_move())
			to_chat(usr, "<span class='warning'>Шаттл специального назначения не может улететь.</span>")
			return FALSE

		to_chat(usr, "<span class='notice'>Шаттл специального назначения прибудет на [station_name_ru] через [(SPECOPS_MOVETIME/10)] секунд.</span>")

		temp += "Шаттл отправляется.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

		specops_shuttle_moving_to_station = 1

		specops_shuttle_time = world.timeofday + SPECOPS_MOVETIME
		spawn(0)
			specops_process()

	else if (href_list["mainmenu"])
		temp = null

	updateUsrDialog()
