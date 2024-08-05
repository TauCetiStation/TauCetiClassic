/obj/machinery/computer/nostromo
	icon_state = "shuttle"
	resistance_flags = FULL_INDESTRUCTIBLE
	unacidable = TRUE

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

	if(href_list["evacuation"])
		do_move()
		docked = FALSE

	updateUsrDialog()

/obj/machinery/computer/nostromo/narcissus_shuttle/proc/do_move()
	var/area/current_location = locate(/area/shuttle/nostromo_narcissus)
	var/area/transit_location = locate(/area/shuttle/nostromo_narcissus/transit)

	SSshuttle.undock_act(/area/station/nostromo, "evac_shuttle_1")
	SSshuttle.undock_act(/area/shuttle/nostromo_narcissus, "evac_shuttle_1")

	current_location.move_contents_to(transit_location)
	SSshuttle.shake_mobs_in_area(transit_location, EAST)

	transit_location.parallax_movedir = WEST


/obj/machinery/computer/nostromo/cockpit
	resistance_flags = FULL_INDESTRUCTIBLE
	unacidable = TRUE
	name = "Nostromo Ship Console"
	cases = list("консоль корабля", "консоли корабля", "консоли корабля", "консоль корабля", "консолью корабля", "консоли корабля")
	var/course = 0
	var/side = 0
	var/next_course_change
	var/obj/machinery/computer/nostromo/cockpit/second_console
	var/mob/living/silicon/decoy/nostromo/N_AI

/obj/machinery/computer/nostromo/cockpit/atom_init()
	..()
	next_course_change = world.time + rand(110, 120) SECOND
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/nostromo/cockpit/atom_init_late()
	second_console = locate() in orange(1, src)
	N_AI = locate() in mob_list
	if(!side)
		side = pick(1, -1)
		second_console.side = -side

/obj/machinery/computer/nostromo/cockpit/process()
	..()
	if(world.time > next_course_change)
		course += rand(2, 4) * side
		next_course_change += rand(110, 120) SECOND
		if(abs(course) > 18)
			if(N_AI)
				N_AI.announce("cockpit")
		if(abs(course) > 24)
			var/turf/T = get_turf(landmarks_list["Nostromo Ambience"][1])
			empulse(T, 30, 60, custom_effects = EMP_SEBB)
			explosion(get_turf(src), 0,1,2,3)
			qdel(second_console)
			qdel(src)

/obj/machinery/computer/nostromo/cockpit/examine(mob/user, distance)
	if(distance > 4)
		return
	to_chat(user, "<span class='notice'>Текущее значение наклона по осям: [course] : [second_console.course]</span>")

/obj/machinery/computer/nostromo/cockpit/attack_hand(mob/user)
	if((side == 1 && course >= side) || (side == -1 && course <= side))
		if(do_after(user, 20, target = src))
			to_chat(user, "<span class='notice'>Вы успешно корректируете курс корабля.</span>")
			course -= rand(4, 6) * side
			second_console.course -= rand(1, 3) * side
