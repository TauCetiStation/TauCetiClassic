
/obj/machinery/computer/trader_shuttle
	name = "Narcissus Shuttle Console"
	icon_state = "shuttle"
	cases = list("консоль шаттла", "консоли шаттла", "консоли шаттла", "консоль шаттла", "консолью шаттла", "консоли шаттла")
	resistance_flags = FULL_INDESTRUCTIBLE
	var/docked = TRUE
	var/area/transit_location

/obj/machinery/computer/trader_shuttle/atom_init()
	. = ..()
	transit_location = locate(/area/shuttle/trader/transit) in all_areas

/obj/machinery/computer/trader_shuttle/ui_interact(mob/user)
	var/dat
	var/shuttle_location
	if(is_centcom_level(src.z))
		shuttle_location = "Велосити"
	else
		shuttle_location = station_name_ru()

	if(docked)
		dat += "<ul><li>Местоположение: <b>[shuttle_location].</b></li>"
		dat += "</ul>"
		dat += "<a href='?src=\ref[src];move=1'>Начать процедуру отстыковки</a>"
	else
		dat += "<ul><li>Местоположение: <b>Космос.</b></li>"

	var/datum/browser/popup = new(user, "flightcomputer", "[capitalize(CASE(src, NOMINATIVE_CASE))]", 365, 200)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/trader_shuttle/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["move"])
		do_move()
		docked = FALSE

	updateUsrDialog()

/obj/machinery/computer/trader_shuttle/proc/do_move()
	var/area/curr_location
	var/area/dest_location

	if(is_centcom_level(src.z))
		curr_location = locate(/area/shuttle/trader/velocity) in all_areas
		dest_location = locate(/area/shuttle/trader/station) in all_areas
		SSshuttle.undock_act(/area/velocity, "trader_shuttle")
	else
		curr_location = locate(/area/shuttle/trader/station) in all_areas
		dest_location = locate(/area/shuttle/trader/velocity) in all_areas
		SSshuttle.undock_act(/area/station/hallway/secondary/entry, "trader_shuttle")
	SSshuttle.undock_act(curr_location, "trader_shuttle")

	transit_location.parallax_movedir = EAST
	curr_location.move_contents_to(transit_location)
	SSshuttle.shake_mobs_in_area(transit_location, EAST)

	sleep(40)
	transit_location.parallax_slowdown()
	sleep(PARALLAX_LOOP_TIME)

	SSshuttle.clean_arriving_area(dest_location)

	transit_location.move_contents_to(dest_location)

	SSshuttle.shake_mobs_in_area(dest_location, EAST)

	if(is_centcom_level(src.z))
		SSshuttle.dock_act(/area/velocity, "trader_shuttle")
	else
		SSshuttle.dock_act(/area/station/hallway/secondary/entry, "trader_shuttle")
	SSshuttle.dock_act(dest_location, "trader_shuttle")

