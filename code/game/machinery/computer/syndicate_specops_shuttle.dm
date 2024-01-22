//Config stuff
#define SYNDICATE_ELITE_MOVETIME 600	//Time to station is milliseconds. 60 seconds, enough time for everyone to be on the shuttle before it leaves.
#define SYNDICATE_ELITE_STATION_AREATYPE /area/shuttle/syndicate_elite/station //Type of the spec ops shuttle area for station
#define SYNDICATE_ELITE_DOCK_AREATYPE /area/shuttle/syndicate_elite/mothership	//Type of the spec ops shuttle area for dock

var/global/syndicate_elite_shuttle_moving_to_station = FALSE
var/global/syndicate_elite_shuttle_moving_to_mothership = FALSE
var/global/syndicate_elite_shuttle_at_station = FALSE
var/global/syndicate_elite_shuttle_can_send = TRUE
var/global/syndicate_elite_shuttle_time = 0
var/global/syndicate_elite_shuttle_timeleft = 0

/obj/machinery/computer/syndicate_elite_shuttle
	name = "Elite Syndicate Squad Shuttle Console"
	cases = list("консоль управления шаттлом элитного отряда Синдиката", "консоли управления шаттлом элитного отряда Синдиката", "консоли управления шаттлом элитного отряда Синдиката", "консоль управления шаттлом элитного отряда Синдиката", "консолью управления шаттлом элитного отряда Синдиката", "консоли управления шаттлом элитного отряда Синдиката")
	icon = 'icons/obj/computer.dmi'
	icon_state = "syndishuttle"
	state_broken_preset = "tcbossb"
	state_nopower_preset = "tcboss0"
	req_access = list(access_syndicate)
	var/temp = null
	var/hacked = FALSE
	var/backpermission = FALSE

/proc/syndicate_elite_shuttle_move(departpos)
	var/area/custom/syndicate_mothership/control/syndicate_ship = locate()//To find announcer. This area should exist for this proc to work.
	var/mob/living/silicon/decoy/announcer = locate() in syndicate_ship//We need a fake AI to announce some stuff below. Otherwise it will be wonky.

	var/message_tracker[] = list(0,1,2,3,5,10,30,45)//Create a a list with potential time values.
	var/message = "ШАТТЛ ЭЛИТНОГО ОТРЯДА СИНДИКАТА ГОТОВИТСЯ К ВЗЛЁТУ"//Initial message shown.
	if(announcer)
		announcer.say(message)

	while(syndicate_elite_shuttle_time - world.timeofday > 0)
		var/ticksleft = syndicate_elite_shuttle_time - world.timeofday

		if(ticksleft > 1e5)
			syndicate_elite_shuttle_time = world.timeofday	// midnight rollover
		syndicate_elite_shuttle_timeleft = (ticksleft / 10)

		//All this does is announce the time before launch.
		if(announcer)
			if(departpos == "station")
				var/rounded_time_left = round(syndicate_elite_shuttle_timeleft)//Round time so that it will report only once, not in fractions.
				var/rounded_time_left_seconds = pluralize_russian(syndicate_elite_shuttle_timeleft, "секунду", "секунды", "секунд")
				if(rounded_time_left in message_tracker)//If that time is in the list for message announce.
					message = "ТРЕВОГА: осталось [rounded_time_left] [rounded_time_left_seconds]"
					if(rounded_time_left==0)
						message = "ТРЕВОГА: Шаттл начинает отстыковку"
					announcer.say(message)
					message_tracker -= rounded_time_left//Remove the number from the list so it won't be called again next cycle.
					//Should call all the numbers but lag could mean some issues. Oh well. Not much I can do about that.
			else if(departpos == "syndimothership")
				var/rounded_time_left = round(syndicate_elite_shuttle_timeleft)
				var/rounded_time_left_seconds = pluralize_russian(syndicate_elite_shuttle_timeleft, "секунду", "секунды", "секунд")
				if(rounded_time_left in message_tracker)
					message = "Внимание, шаттл вернется на базу через [rounded_time_left] [rounded_time_left_seconds]. ВОЗВРАЩАЙТЕСЬ НА ШАТТЛ!"
					if(rounded_time_left==0)
						message = "Внимание: Шаттл пристыковался к материнскому кораблю. Добро пожаловать домой, солдаты."
					announcer.say(message)
					message_tracker -= rounded_time_left
		sleep(5)

	syndicate_elite_shuttle_moving_to_station = FALSE
	syndicate_elite_shuttle_moving_to_mothership = FALSE

	if (syndicate_elite_shuttle_moving_to_station || syndicate_elite_shuttle_moving_to_mothership) return

	if (!syndicate_elite_can_move())
		to_chat(usr, "<span class='warning'>Шаттл элитного отряда Синдиката не может улететь.</span>")
		return

	var/area/startloc
	var/area/endloc

	var/list/dstturfs = list()
	var/throwy = world.maxy

	if(departpos == "station")
		syndicate_elite_shuttle_at_station = TRUE
		startloc = locate(/area/shuttle/syndicate_elite/station)
		endloc = locate(/area/shuttle/syndicate_elite/mothership)
	else if(departpos == "syndimothership")
		syndicate_elite_shuttle_at_station = FALSE
		startloc = locate(/area/shuttle/syndicate_elite/mothership)
		endloc = locate(/area/shuttle/syndicate_elite/station)

	for(var/turf/T in startloc)
		dstturfs  = T
		if(T.y < throwy)
			throwy = T.y
	for(var/turf/T in dstturfs)
		// find the turf to move things to
		var/turf/D = locate(T.x, throwy - 1, 1)
		for(var/atom/movable/AM as mob|obj in T)
			AM.Move(D)
		if(istype(T, /turf/simulated))
			qdel(T)

	for(var/mob/living/carbon/bug in startloc) // If someone somehow is still in the shuttle's docking area...
		bug.gib()

	for(var/mob/living/simple_animal/pest in startloc) // And for the other kind of bug...
		pest.gib()

	endloc.move_contents_to(startloc)

	for(var/turf/T in get_area_turfs(startloc) )
		var/mob/M = locate(/mob) in T
		to_chat(M, syndicate_elite_shuttle_at_station ? "<span class='warning'>Вы прибыли на [station_name_ru]. Приступайте к операции!</span>" : "<span class='warning'>Вы прибыли домой. Отличная работа!</span>")

/proc/syndicate_elite_can_move()
	if(syndicate_elite_shuttle_moving_to_station || syndicate_elite_shuttle_moving_to_mothership) return 0
	else return 1

/obj/machinery/computer/syndicate_elite_shuttle/attackby(I, user)
	attack_hand(user)

/obj/machinery/computer/syndicate_elite_shuttle/emag_act(mob/user)
	to_chat(user, "<span class='notice'>Электронные системы в этой консоли слишком продвинуты для вашей примитивной хакерской периферии.</span>")
	return TRUE //yep, don't try do that

/obj/machinery/computer/syndicate_elite_shuttle/ui_interact(mob/user)
	var/seconds = max(round(syndicate_elite_shuttle_timeleft), 0)
	var/seconds_word = pluralize_russian(seconds, "секунду", "секунды", "секунд")
	var/dat
	if (temp)
		dat = temp
	else
		dat  = {"\nМестоположение: [syndicate_elite_shuttle_moving_to_station || syndicate_elite_shuttle_moving_to_mothership ? "Отправляющийся на [station_name_ru] через [seconds] [seconds_word]":syndicate_elite_shuttle_at_station ? "[station_name_ru]":"Док"]<BR>
			[syndicate_elite_shuttle_moving_to_station || syndicate_elite_shuttle_moving_to_mothership ? "\n*Шаттл элитного отряда Синдиката уже отправляется.*<BR>\n<BR>":syndicate_elite_shuttle_at_station ? "\n<A href='?src=\ref[src];sendtodock=1'>Возвращение шаттла на материнский корабль</A><BR>\n<BR>":"\n<A href='?src=\ref[src];sendtostation=1'>Отправка на [station_name_ru]</A><BR>\n<BR>"]"}

	var/datum/browser/popup = new(user, "computer", "Шаттл специального назначения", 575, 450)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/syndicate_elite_shuttle/Topic(href, href_list)
	var/seconds = max(round(SYNDICATE_ELITE_MOVETIME/10), 0)
	var/seconds_word = pluralize_russian(seconds, "секунду", "секунды", "секунд")
	. = ..()
	if(!. || !allowed(usr))
		return

	if (href_list["sendtodock"])
		if(!syndicate_elite_shuttle_at_station|| syndicate_elite_shuttle_moving_to_station || syndicate_elite_shuttle_moving_to_mothership) return

		if(backpermission)
			syndicate_elite_shuttle_moving_to_mothership = TRUE
			syndicate_elite_shuttle_time = world.timeofday + SYNDICATE_ELITE_MOVETIME
			syndicate_elite_shuttle_move("syndimothership")
		else
			to_chat(usr, "<span class='notice'>Материнский корабль пока не разрешил шаттлу элитного отряда Синдиката вернуться.</span>")
			return FALSE

	else if (href_list["sendtostation"])
		if(syndicate_elite_shuttle_at_station || syndicate_elite_shuttle_moving_to_station || syndicate_elite_shuttle_moving_to_mothership) return

		if (!specops_can_move())
			to_chat(usr, "<span class='warning'>Шаттл элитного отряда Синдиката не может улететь.</span>")
			return FALSE

		to_chat(usr, "<span class='notice'>Шаттл элитного отряда Синдиката прибудет на [station_name_ru] через [seconds] [seconds_word].</span>")

		temp  = "Шаттл отправляется.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
		syndicate_elite_shuttle_moving_to_station = TRUE
		syndicate_elite_shuttle_time = world.timeofday + SYNDICATE_ELITE_MOVETIME
		syndicate_elite_shuttle_move("station")


	else if (href_list["mainmenu"])
		temp = null

	updateUsrDialog()
