#define MINE_SCI_SHUTTLE_COOLDOWN 150
#define MINE_SHUTTLE_MOVE_TIME 40

#define STATION_DOCK /area/shuttle/mining/station
#define MINE_DOCK /area/shuttle/mining/outpost
#define SCI_DOCK /area/shuttle/mining/research

#define M_S_SHUTTLE_FLOOR /turf/simulated/shuttle/floor/mining

var/global/obj/machinery/computer/mine_sci_shuttle/flight_comp/autopilot = null
var/global/area/asteroid/mine_sci_curr_location = null

/obj/machinery/computer/mine_sci_shuttle
	name = "Mine-Science Shuttle Console"
	cases = list("консоль шаттла", "консоли шаттла", "консоли шаттла", "консоль шаттла", "консолью шаттла", "консоли шаттла")
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	state_broken_preset = "commb"
	state_nopower_preset = "comm0"
	circuit = /obj/item/weapon/circuitboard/mine_sci_shuttle

	var/lastMove = 0

/obj/machinery/computer/mine_sci_shuttle/process()
	if(..())
		if(lastMove + MINE_SHUTTLE_MOVE_TIME + MINE_SCI_SHUTTLE_COOLDOWN + 20 >= world.time)
			updateUsrDialog()

/obj/machinery/computer/mine_sci_shuttle/ui_interact(mob/user)
	var/seconds = max(round((autopilot.lastMove + MINE_SCI_SHUTTLE_COOLDOWN - world.time) * 0.1), 0)
	var/seconds_word = pluralize_russian(seconds, "секунду", "секунды", "секунд")
	var/dat
	if(autopilot)
		var/shuttle_location = station_name_ru()
		if(istype(autopilot.mine_sci_curr_location, MINE_DOCK))
			shuttle_location = "Шахтёрский аванпост"
		else if(istype(autopilot.mine_sci_curr_location, SCI_DOCK))
			shuttle_location = "Научный аванпост"
		dat += "<ul><li>Местоположение: <b>[shuttle_location]</b></li>"
		dat += {"<li>Готов лететь[max(autopilot.lastMove + MINE_SHUTTLE_MOVE_TIME + MINE_SCI_SHUTTLE_COOLDOWN - world.time, 0) ? " через [seconds] [seconds_word]" : ": сейчас"]</li>"}
		dat += "</ul>"
		dat += "<a href='?src=\ref[src];mine=1'>Шахтёрский аванпост</a> | "
		dat += "<a href='?src=\ref[src];station=1'>[station_name_ru()]</a> | "
		dat += "<a href='?src=\ref[src];sci=1'>Научный аванпост</a><br>"
	else
		dat = "Невозможно найти шаттл"

	var/datum/browser/popup = new(user, "flightcomputer", "[capitalize(CASE(src, NOMINATIVE_CASE))]", 365, 200)
	popup.set_content(dat)
	popup.open()


/obj/machinery/computer/mine_sci_shuttle/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(!autopilot)
		to_chat(usr, "<span class='warning'>Шаттл не обнаружен!</span>")
		return FALSE
	if(autopilot.moving)
		to_chat(usr, "<span class='notice'>Шаттл уже запущен.</span>")
		return FALSE

	var/result = FALSE
	if(href_list["mine"])
		result = autopilot.mine_sci_move_to(MINE_DOCK)
	else if(href_list["sci"])
		result = autopilot.mine_sci_move_to(SCI_DOCK)
	else if(href_list["station"])
		result = autopilot.mine_sci_move_to(STATION_DOCK)
	if(result)
		lastMove = world.time
		to_chat(usr, "<span class='notice'>Шаттл получил запрос и будет отправлен в ближайшее время.</span>")

	updateUsrDialog()

//-------------------------------------------
//------------FLIGHT COMPUTER----------------
//-------------------------------------------

/obj/machinery/computer/mine_sci_shuttle/flight_comp
	name = "Shuttle Console"
	cases = list("консоль шаттла", "консоли шаттла", "консоли шаттла", "консоль шаттла", "консолью шаттла", "консоли шаттла")
	icon = 'icons/locations/shuttles/computer_shuttle_mining.dmi'
	state_broken_preset = null
	state_nopower_preset = null
	circuit = /obj/item/weapon/circuitboard/mine_sci_shuttle/flight_comp
	var/area/asteroid/mine_sci_curr_location
	var/moving = 0
	lastMove = 0

/obj/machinery/computer/mine_sci_shuttle/flight_comp/atom_init()
	. = ..()
	var/area/my_area = get_area(src)
	if(istype(get_turf(src),M_S_SHUTTLE_FLOOR) &&\
		   is_type_in_list(my_area,list(STATION_DOCK, MINE_DOCK, SCI_DOCK))) //if we build console not in shuttle area
		autopilot = src
		set_dir(WEST)
		if(!mine_sci_curr_location)
			mine_sci_curr_location = my_area

/obj/machinery/computer/mine_sci_shuttle/flight_comp/process()
	if(..())
		if(lastMove + MINE_SCI_SHUTTLE_COOLDOWN + 20 >= world.time)
			updateUsrDialog()

/obj/machinery/computer/mine_sci_shuttle/flight_comp/Destroy()
	if(autopilot == src) //if we have more than one flight comp! (look imbossible)
		autopilot = null
	return ..()

/obj/machinery/computer/mine_sci_shuttle/flight_comp/proc/mine_sci_move_to(area/destination)
	if(moving)
		return FALSE
	if((lastMove + MINE_SCI_SHUTTLE_COOLDOWN) > world.time)
		return FALSE
	var/area/dest_location = locate(destination)
	if(mine_sci_curr_location == dest_location)
		return FALSE

	moving = TRUE
	lastMove = world.time
	addtimer(CALLBACK(src, PROC_REF(mine_sci_do_move), dest_location), MINE_SCI_SHUTTLE_COOLDOWN, TIMER_UNIQUE)
	return TRUE

/obj/machinery/computer/mine_sci_shuttle/flight_comp/proc/mine_sci_do_move(area/destination)
	if(moving)
		var/area/transit_location = locate(/area/shuttle/mining/transit)

		if(istype(mine_sci_curr_location, STATION_DOCK))
			SSshuttle.undock_act(/area/station/hallway/secondary/mine_sci_shuttle, "stat_dock")
			SSshuttle.undock_act(mine_sci_curr_location)
		else if(istype(mine_sci_curr_location, MINE_DOCK))
			SSshuttle.undock_act(/area/asteroid/mine/production, "mine_dock")
			SSshuttle.undock_act(mine_sci_curr_location)
		else if(istype(mine_sci_curr_location, SCI_DOCK))
			SSshuttle.undock_act(/area/asteroid/research_outpost/entry, "sci_dock")
			SSshuttle.undock_act(mine_sci_curr_location)

		transit_location.parallax_movedir = EAST
		mine_sci_curr_location.move_contents_to(transit_location)
		SSshuttle.shake_mobs_in_area(transit_location, WEST)

		sleep(MINE_SHUTTLE_MOVE_TIME)
		transit_location.parallax_slowdown()
		sleep(PARALLAX_LOOP_TIME)

		SSshuttle.clean_arriving_area(destination)

		transit_location.move_contents_to(destination)

		SSshuttle.shake_mobs_in_area(destination, EAST)

		if(istype(destination, STATION_DOCK))
			SSshuttle.dock_act(/area/station/hallway/secondary/mine_sci_shuttle, "stat_dock")
			SSshuttle.dock_act(destination)
		else if(istype(destination, MINE_DOCK))
			SSshuttle.dock_act(/area/asteroid/mine/production, "mine_dock")
			SSshuttle.dock_act(destination)
		else if(istype(destination, SCI_DOCK))
			SSshuttle.dock_act(/area/asteroid/research_outpost/entry, "sci_dock")
			SSshuttle.dock_act(destination)

		mine_sci_curr_location = destination
		moving = FALSE

#undef M_S_SHUTTLE_FLOOR

#undef MINE_SCI_SHUTTLE_COOLDOWN

#undef STATION_DOCK
#undef MINE_DOCK
#undef SCI_DOCK
