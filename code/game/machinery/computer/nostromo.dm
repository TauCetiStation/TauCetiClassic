/obj/machinery/computer/nostromo
	icon_state = "shuttle"
	resistance_flags = FULL_INDESTRUCTIBLE
	unacidable = TRUE
	var/datum/map_module/alien/MM = null

/obj/machinery/computer/nostromo/atom_init()
	. = ..()
	MM = SSmapping.get_map_module_by_name(MAP_MODULE_ALIEN)
	if(!MM)
		return INITIALIZE_HINT_QDEL
	else
		MM.shuttle_console = src

/obj/machinery/computer/nostromo/narcissus_shuttle
	name = "Narcissus Shuttle Console"
	cases = list("консоль шаттла", "консоли шаттла", "консоли шаттла", "консоль шаттла", "консолью шаттла", "консоли шаттла")
	var/docked = TRUE

/obj/machinery/computer/nostromo/narcissus_shuttle/ui_interact(mob/user)
	var/dat
	if(docked)
		dat += "<ul><li>Местоположение: <b>[station_name_ru()]</b></li>"
		dat += "</ul>"
		dat += "<a href='?src=\ref[src];evacuation=1'>Начать процедуру отстыковки</a>"
	else
		dat += "<ul><li>Местоположение: <b>Космос</b></li>"

	var/datum/browser/popup = new(user, "flightcomputer", "[capitalize(CASE(src, NOMINATIVE_CASE))]", 365, 200)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/nostromo/narcissus_shuttle/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(!(get_security_level() == "delta"))
		to_chat(usr, "<span class='warning'>Для эвакуации необходимо запустить систему самоуничтожения корабля!</span>")
		return FALSE

	if(!isrolebytype(/datum/role/nostromo_android, usr) && MM.alien && (MM.alien.stat != DEAD) && (MM.alien in orange(7, src)))
		to_chat(usr, "<span class='warning'>МЫ НЕ МОЖЕМ УЛЕТЕТЬ, ПОКА КСЕНОМОРФ С НАМИ НА ШАТТЛЕ!</span>")
		return FALSE

	if(href_list["evacuation"] && do_after(usr, 10 SECOND, target = src))
		do_move()

	updateUsrDialog()

/obj/machinery/computer/nostromo/narcissus_shuttle/proc/do_move()
	set waitfor = FALSE

	if(!docked)
		return

	docked = FALSE

	var/area/current_location = get_area_by_type(/area/shuttle/nostromo_narcissus/ship)
	var/area/transit_location = get_area_by_type(/area/shuttle/nostromo_narcissus/transit)

	SSshuttle.undock_act(/area/station/nostromo, "evac_shuttle_1")
	SSshuttle.undock_act(/area/shuttle/nostromo_narcissus/ship, "evac_shuttle_1")

	sleep(5 SECOND)

	current_location.move_contents_to(transit_location)
	SSshuttle.shake_mobs_in_area(transit_location, EAST)

	transit_location.parallax_movedir = WEST

	var/list/turfs = get_area_turfs(transit_location)
	for(var/turf/T in turfs)
		T.explosive_resistance = INFINITY // ANTINUKE KOSTIL

	MM.nuke_detonate()


/obj/machinery/computer/nostromo/cockpit
	resistance_flags = FULL_INDESTRUCTIBLE
	unacidable = TRUE
	name = "Nostromo Ship Console"
	cases = list("консоль корабля", "консоли корабля", "консоли корабля", "консоль корабля", "консолью корабля", "консоли корабля")
	var/course = 0
	var/side = 0
	var/next_course_change = 0
	var/obj/machinery/computer/nostromo/cockpit/second_console = null

/obj/machinery/computer/nostromo/cockpit/atom_init()
	..()
	if(!MM)
		return INITIALIZE_HINT_QDEL
	RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(round_start))
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/nostromo/cockpit/atom_init_late()
	second_console = locate() in orange(1, src)
	if(!side)
		MM.console = src
		side = pick(1, -1)
		second_console.side = -side

/obj/machinery/computer/nostromo/cockpit/proc/round_start()
	next_course_change = world.time + rand(90, 110) SECOND
	UnregisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING)

/obj/machinery/computer/nostromo/cockpit/process()
	..()
	if(world.time > next_course_change)
		next_course_change += rand(110, 130) SECOND
		course += rand(3, 4) * side
		if(abs(course) > 18)
			MM.AI_announce("cockpit")
		if(abs(course) > 24)
			MM.breakdown()

/obj/machinery/computer/nostromo/cockpit/proc/explode()
	explosion(loc, 0, 0, 2)
	qdel(second_console)
	qdel(src)

/obj/machinery/computer/nostromo/cockpit/examine(mob/user, distance)
	if(distance > 4)
		return
	to_chat(user, "<span class='notice'>Текущее значение отклонения [course].</span>")

/obj/machinery/computer/nostromo/cockpit/attack_hand(mob/user)
	if((side == 1 && course >= side) || (side == -1 && course <= side))
		if(do_after(user, 2 SECOND, target = src))
			to_chat(user, "<span class='notice'>Вы успешно корректируете курс корабля.</span>")
			course -= rand(4, 6) * side
			second_console.course -= rand(1, 3) * side

/obj/machinery/nostromo
