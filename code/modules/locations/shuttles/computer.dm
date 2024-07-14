/obj/machinery/computer/research_shuttle/new_shuttle_white
	icon = 'icons/locations/shuttles/computer_shuttle_white.dmi'

/obj/machinery/computer/mining_shuttle/new_shuttle_mining
	icon = 'icons/locations/shuttles/computer_shuttle_mining.dmi'

/obj/machinery/computer/security/erokez
	name = "security camera monitor"
	cases = list("монитор камер видеонаблюдения", "монитора камер видеонаблюдения", "монитору камер видеонаблюдения", "монитор камер видеонаблюдения", "монитором камер видеонаблюдения", "мониторе камер видеонаблюдения")
	desc = "Используется для доступа к различным камерам на станции."
	icon = 'icons/obj/computer.dmi'
	icon_state = "erokez"
	light_color = "#ffffbb"
	network = list("SS13")

/obj/machinery/computer/security/erokez/update_icon()
	icon_state = initial(icon_state)
	if(stat & BROKEN)
		icon_state += "b"
	return

/obj/machinery/computer/crew/erokez
	name = "crew monitoring computer"
	cases = list("компьютер контроля за состоянием экипажа", "компьютера контроля за состоянием экипажа", "компьютеру контроля за состоянием экипажа", "компьютер контроля за состоянием экипажа", "компьютером контроля за состоянием экипажа", "компьютере контроля за состоянием экипажа")
	desc = "Используется для мониторинга активных датчиков состояния здоровья, встроенных в большую часть униформы экипажа."
	icon = 'icons/obj/computer.dmi'
	icon_state = "erokezz"
	light_color = "#315ab4"

/obj/machinery/computer/crew/erokez/update_icon()
	icon_state = initial(icon_state)
	if(stat & BROKEN)
		icon_state += "b"
	return


/obj/machinery/computer/narcissus_shuttle
	name = "Narcissus Shuttle Console"
	cases = list("консоль шаттла", "консоли шаттла", "консоли шаттла", "консоль шаттла", "консолью шаттла", "консоли шаттла")
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	resistance_flags = FULL_INDESTRUCTIBLE
	var/docked = TRUE

/obj/machinery/computer/narcissus_shuttle/ui_interact(mob/user)
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

/obj/machinery/computer/narcissus_shuttle/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(!(get_security_level() == "delta"))
		to_chat(usr, "<span class='warning'>Для эвакуации необходимо запустить систему самоуничтожения корабля!</span>")
		return FALSE

	if(href_list["evacuation"])
		do_move()

	updateUsrDialog()

/obj/machinery/computer/narcissus_shuttle/proc/do_move()
	var/area/current_location = locate(/area/shuttle/nostromo_narcissus)
	var/area/transit_location = locate(/area/shuttle/nostromo_narcissus/transit)

	SSshuttle.undock_act(/area/station/nostromo, "evac_shuttle_1")
	SSshuttle.undock_act(/area/shuttle/nostromo_narcissus, "evac_shuttle_1")

	transit_location.parallax_movedir = WEST
	current_location.move_contents_to(transit_location)
	SSshuttle.shake_mobs_in_area(transit_location, EAST)

	transit_location.parallax_slowdown()
