#define SYNDICATE_SHUTTLE_MOVE_TIME 215
#define SYNDICATE_SHUTTLE_COOLDOWN 200
#define SYNDICATE_SHUTTLE_ALERT_DELAY (1 MINUTES)

/obj/machinery/computer/lop_shuttle
	name = "syndicate shuttle terminal"
	circuit = /obj/item/weapon/circuitboard/computer/lop_shuttle
	icon = 'icons/obj/computer.dmi'
	icon_state = "syndishuttle"
	state_broken_preset = "tcbossb"
	state_nopower_preset = "tcboss0"
	light_color = "#a91515"
	req_access = list(access_syndicate)
	var/area/curr_location
	var/moving = FALSE
	var/lastMove = 0
	var/datum/announcement/centcomm/syndi_shuttle/announce

/obj/effect/landmark/lop_shuttle
	name = "lone oper shuttle landmark"


/obj/machinery/computer/lop_shuttle/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/lop_shuttle/atom_init_late()
	curr_location = get_area(locate("landmark*lone oper shuttle landmark"))

/obj/machinery/computer/lop_shuttle/process()
	if(..())
		if(lastMove + SYNDICATE_SHUTTLE_COOLDOWN + 20 >= world.time)
			updateUsrDialog()

/obj/machinery/computer/lop_shuttle/proc/syndicate_move_to(area/destination)
	if(moving)
		return
	if(lastMove + SYNDICATE_SHUTTLE_COOLDOWN > world.time)
		return
	var/area/dest_location = locate(destination)
	if(curr_location == dest_location)
		return

	moving = TRUE
	lastMove = world.time

	if(curr_location.z != dest_location.z)
		var/area/transit_location = locate(/area/shuttle/lone_op/transit)
		curr_location.move_contents_to(transit_location)
		curr_location = transit_location
		sleep(SYNDICATE_SHUTTLE_MOVE_TIME)
		curr_location.parallax_slowdown()
		sleep(PARALLAX_LOOP_TIME)

	curr_location.move_contents_to(dest_location)
	curr_location = dest_location
	moving = FALSE
	if(!announce)
		announce = new
		addtimer(CALLBACK(announce, /datum/announcement.proc/play), SYNDICATE_SHUTTLE_ALERT_DELAY)
	return TRUE

/obj/machinery/computer/lop_shuttle/ui_interact(mob/user)
	var/dat = {"Location: [curr_location]<br>
	Ready to move[max(lastMove + SYNDICATE_SHUTTLE_COOLDOWN - world.time, 0) ? " in [max(round((lastMove + SYNDICATE_SHUTTLE_COOLDOWN - world.time) * 0.1), 0)] seconds" : ": now"]<br>
	<a href='?src=\ref[src];syndicate=1'>Syndicate Space</a><br>
	<a href='?src=\ref[src];station_north=1'>North of SS13</a> |
	<a href='?src=\ref[src];station_south=1'>South of SS13</a>|"}

	var/datum/browser/popup = new(user, "computer", "[src.name]", 575, 450, ntheme = CSS_THEME_SYNDICATE)
	popup.set_content(dat)
	popup.open()


/obj/machinery/computer/lop_shuttle/Topic(href, href_list)
	. = ..()
	if(!. || !allowed(usr))
		return

	if(href_list["syndicate"])
		syndicate_move_to(/area/shuttle/lone_op/start)
	else if(href_list["station_north"])
		syndicate_move_to(/area/shuttle/lone_op/north)
	else if(href_list["station_south"])
		syndicate_move_to(/area/shuttle/lone_op/south)

	updateUsrDialog()

/obj/item/weapon/circuitboard/computer/lop_shuttle
	name = "Syndicate Shuttle (Computer Board)"
	build_path = /obj/machinery/computer/lop_shuttle

#undef SYNDICATE_SHUTTLE_MOVE_TIME
#undef SYNDICATE_SHUTTLE_COOLDOWN
#undef SYNDICATE_SHUTTLE_ALERT_DELAY
