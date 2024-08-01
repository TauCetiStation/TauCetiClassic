#define TRADER_SHUTTLE_COOLDOWN 5 MINUTE

/obj/machinery/computer/trader_shuttle
	name = "Shuttle Console"
	icon_state = "shuttle"
	cases = list("консоль шаттла", "консоли шаттла", "консоли шаттла", "консоль шаттла", "консолью шаттла", "консоли шаттла")
	resistance_flags = FULL_INDESTRUCTIBLE
	var/docked = TRUE
	var/lastmove = 0
	var/area/space_location
	var/area/station_location

/obj/machinery/computer/trader_shuttle/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/trader_shuttle/atom_init_late()
	space_location = locate(/area/shuttle/trader/space) in all_areas
	station_location = locate(/area/shuttle/trader/station) in all_areas

/obj/machinery/computer/trader_shuttle/ui_interact(mob/user)
	var/dat
	var/seconds = max(round((lastMove + TRADER_SHUTTLE_COOLDOWN - world.time) * 0.1), 0)
	var/seconds_word = pluralize_russian(seconds, "секунду", "секунды", "секунд")

	if(docked)
		if(is_centcom_level(src.z))
			dat += "<ul><li>Местоположение: <b>Космос.</b></li>"
			dat += "<ul><li>Готов к полёту[max(lastMove + TRADER_SHUTTLE_COOLDOWN - world.time, 0) ? " через [seconds] [seconds_word]" : ": сейчас"].</b></li>"
			dat += "</ul>"
			dat += "<a href='?src=\ref[src];station=1'>Пристыковаться к станции.</a>"
		else
			dat += "<ul><li>Местоположение: <b>[station_name_ru()].</b></li>"
			dat += "<ul><li>Готов к полёту[max(lastMove + TRADER_SHUTTLE_COOLDOWN - world.time, 0) ? " через [seconds] [seconds_word]" : ": сейчас"].</b></li>"
			dat += "</ul>"
			dat += "<a href='?src=\ref[src];space=1'>Начать процедуру отстыковки</a>"
	else
		if(is_centcom_level(src.z))
			dat += "<ul><li>Местоположение: <b>Приближаемся к станции.</b></li>"
		else
			dat += "<ul><li>Местоположение: <b>Отдаляемся от станции.</b></li>"

	var/datum/browser/popup = new(user, "flightcomputer", "[capitalize(CASE(src, NOMINATIVE_CASE))]", 365, 200)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/trader_shuttle/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(world.time < lastMove + TRADER_SHUTTLE_COOLDOWN)
		return

	if(href_list["station"])
		docked = FALSE
		dock_to_station()

	if(href_list["space"])
		docked = FALSE
		undock_to_station()

	last_move = world.time
	updateUsrDialog()

/obj/machinery/computer/trader_shuttle/proc/dock_to_station()
	space_location.parallax_slowdown()
	sleep(PARALLAX_LOOP_TIME)

	SSshuttle.clean_arriving_area(station_location)
	space_location.move_contents_to(station_location)
	SSshuttle.shake_mobs_in_area(station_location, WEST)

	SSshuttle.dock_act(/area/station/hallway/secondary/entry, "trader_shuttle")
	SSshuttle.dock_act(station_location, "trader_shuttle")
	docked = TRUE

/obj/machinery/computer/trader_shuttle/proc/undock_to_station()
	SSshuttle.undock_act(/area/station/hallway/secondary/entry, "trader_shuttle")
	SSshuttle.undock_act(station_location, "trader_shuttle")
	sleep(PARALLAX_LOOP_TIME)

	space_location.parallax_movedir = EAST
	station_location.move_contents_to(space_location)
	SSshuttle.shake_mobs_in_area(space_location, WEST)

	docked = TRUE

#undef TRADER_SHUTTLE_COOLDOWN
