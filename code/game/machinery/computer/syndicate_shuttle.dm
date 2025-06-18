#define SYNDICATE_SHUTTLE_MOVE_TIME 215
#define SYNDICATE_SHUTTLE_COOLDOWN 200

/obj/machinery/computer/syndicate_station
	name = "syndicate shuttle terminal"
	cases = list("терминал шаттла Синдиката", "терминала шаттла Синдиката", "терминалу шаттла Синдиката", "терминал шаттла Синдиката", "терминалом шаттла Синдиката", "терминале шаттла Синдиката")
	circuit = /obj/item/weapon/circuitboard/computer/syndicate_shuttle
	icon = 'icons/obj/computer.dmi'
	icon_state = "syndishuttle"
	state_broken_preset = "tcbossb"
	state_nopower_preset = "tcboss0"
	light_color = "#a91515"
	req_access = list(access_syndicate)
	var/area/curr_location
	var/moving = FALSE
	var/lastMove = 0

/obj/effect/landmark/syndi_shuttle
	name = "Syndi shuttle"

/obj/machinery/computer/syndicate_station/atom_init()
	..()
	SSholomaps.holomap_landmarks += src
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/syndicate_station/atom_init_late()
	curr_location = get_area(locate("landmark*Syndi shuttle"))

/obj/machinery/computer/syndicate_station/Destroy()
	SSholomaps.holomap_landmarks -= src
	return ..()

/obj/machinery/computer/syndicate_station/process()
	if(..())
		if(lastMove + SYNDICATE_SHUTTLE_COOLDOWN + 20 >= world.time)
			updateUsrDialog()

/obj/machinery/computer/syndicate_station/proc/syndicate_move_to(area/destination)
	if(moving)
		return
	if(lastMove + SYNDICATE_SHUTTLE_COOLDOWN > world.time)
		return
	var/area/dest_location = locate(destination)
	if(curr_location == dest_location)
		return

	moving = TRUE
	lastMove = world.time
	//mix stuff
	var/datum/faction/nuclear/crossfire/N = find_faction_by_type(/datum/faction/nuclear/crossfire)
	if(N)
		N.landing_nuke()

	if(curr_location.z != dest_location.z)
		var/area/transit_location = locate(/area/shuttle/syndicate/transit)
		curr_location.move_contents_to(transit_location)
		curr_location = transit_location
		sleep(SYNDICATE_SHUTTLE_MOVE_TIME)
		curr_location.parallax_slowdown()
		sleep(PARALLAX_LOOP_TIME)

	curr_location.move_contents_to(dest_location)
	curr_location = dest_location
	moving = FALSE
	return TRUE

/obj/machinery/computer/syndicate_station/ui_interact(mob/user)
	var/seconds = max(round((lastMove + SYNDICATE_SHUTTLE_COOLDOWN - world.time) * 0.1), 0)
	var/seconds_word = pluralize_russian(seconds, "секунду", "секунды", "секунд")
	var/dat = {"Местоположение: <b>[capitalize(CASE(curr_location, NOMINATIVE_CASE))]</b><br>
	Готов к полёту[max(lastMove + SYNDICATE_SHUTTLE_COOLDOWN - world.time, 0) ? " через [seconds] [seconds_word]" : ": сейчас"]<br>
	<a href='?src=\ref[src];syndicate=1'>Пространство Синдиката</a><br>
	<a href='?src=\ref[src];station_nw=1'>Северо-запад от [station_name_ru()]</a> |
	<a href='?src=\ref[src];station_n=1'>К северу от [station_name_ru()]</a> |
	<a href='?src=\ref[src];station_ne=1'>Северо-восток от [station_name_ru()]</a><br>
	<a href='?src=\ref[src];station_sw=1'>Юго-запад от [station_name_ru()]</a> |
	<a href='?src=\ref[src];station_s=1'>К югу от [station_name_ru()]</a> |
	<a href='?src=\ref[src];station_se=1'>Юго-восток от [station_name_ru()]</a><br>
	<a href='?src=\ref[src];mining=1'>Северо-восток от шахтёрского астероида</a><br>"}

	var/datum/browser/popup = new(user, "computer", "[capitalize(CASE(src, NOMINATIVE_CASE))]", 575, 450, ntheme = CSS_THEME_SYNDICATE)
	popup.set_content(dat)
	popup.open()


/obj/machinery/computer/syndicate_station/Topic(href, href_list)
	. = ..()
	if(!. || !allowed(usr))
		return
	if(war_device_activated)
		if(world.time < SYNDICATE_CHALLENGE_TIMER)
			to_chat(usr, "<span class='warning'>Вы объявили станции войну! Вы должны дать им хотя бы \
		 	[round(((SYNDICATE_CHALLENGE_TIMER - world.time) / 10) / 60)] \
		 	минут, чтобы они успели приготовиться.</span>")
			return
	else
		war_device_activation_forbidden = TRUE

	if(href_list["syndicate"])
		syndicate_move_to(/area/shuttle/syndicate/start)
	else if(href_list["station_nw"])
		syndicate_move_to(/area/shuttle/syndicate/northwest)
	else if(href_list["station_n"])
		syndicate_move_to(/area/shuttle/syndicate/north)
	else if(href_list["station_ne"])
		syndicate_move_to(/area/shuttle/syndicate/northeast)
	else if(href_list["station_sw"])
		syndicate_move_to(/area/shuttle/syndicate/southwest)
	else if(href_list["station_s"])
		syndicate_move_to(/area/shuttle/syndicate/south)
	else if(href_list["station_se"])
		syndicate_move_to(/area/shuttle/syndicate/southeast)
	else if(href_list["mining"])
		syndicate_move_to(/area/shuttle/syndicate/mining)

	updateUsrDialog()

/obj/item/weapon/circuitboard/computer/syndicate_shuttle
	name = "Syndicate Shuttle (Computer Board)"
	cases = list("шаттл Синдиката (Компьютерная плата)", "шаттла Синдиката (Компьютерная плата)", "шаттлу Синдиката (Компьютерная плата)", "шаттл Синдиката (Компьютерная плата)", "шаттлом Синдиката (Компьютерная плата)", "шаттле Синдиката (Компьютерная плата)")
	build_path = /obj/machinery/computer/syndicate_station

#undef SYNDICATE_SHUTTLE_MOVE_TIME
#undef SYNDICATE_SHUTTLE_COOLDOWN

