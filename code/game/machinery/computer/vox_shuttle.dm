#define VOX_SHUTTLE_MOVE_TIME 375
#define VOX_SHUTTLE_COOLDOWN 1200
#define VOX_CAN_USE(A) (ishuman(A) && A.can_speak(all_languages[LANGUAGE_VOXPIDGIN]) || isobserver(A))
// human and know vox language (and ghosts, because ghosts see everything).

//Copied from Syndicate shuttle.
var/global/announce_vox_departure = FALSE // Stealth systems - give an announcement or not.

/obj/machinery/proc/console_say(text)
	visible_message("<b>[capitalize(CASE(src, NOMINATIVE_CASE))]</b> сигнализирует, \"[text]\'")

/obj/machinery/computer/vox_stealth
	name = "skipjack cloaking field terminal"
	cases = list("терминал маскировочного поля \"Скипджек\"", "терминала маскировочного поля \"Скипджек\"", "терминалу \"Скипджек\"", "терминал маскировочного поля \"Скипджек\"", "терминалом маскировочного поля \"Скипджек\"", "терминале маскировочного поля \"Скипджек\"")
	icon = 'icons/locations/shuttles/vox_pc.dmi'
	icon_state = "vox_invs"
	state_broken_preset = "tcbossb"
	state_nopower_preset = "tcboss0"

/obj/machinery/computer/vox_stealth/atom_init()
	. = ..()
	SSholomaps.holomap_landmarks += src

/obj/machinery/computer/vox_stealth/Destroy()
	SSholomaps.holomap_landmarks -= src
	return ..()

/obj/machinery/computer/vox_stealth/attackby(obj/item/I, mob/user)
	return attack_hand(user)

/obj/machinery/computer/vox_stealth/attack_ai(mob/user)
	if(!IsAdminGhost(user))
		to_chat(user, "<span class='red'><b>W?r#nING</b>: #%@!!W?|_4?54@ \nUn?B88l3 T? L?-?o-L?CaT2 ##$!?RN?0..%..</span>") // Totally not stolen from ninja (x2).
	else
		. = ..()

/obj/machinery/computer/vox_stealth/attack_hand(mob/user)
	if(!VOX_CAN_USE(user))
		to_chat(user, "<span class='notice'>Вы понятия не имеете, как это использовать.</span>")
		return

	. = ..()
	if(.)
		return

	if(get_area(src) != locate(/area/shuttle/vox/arkship))
		return // no point in this console after moving shuttle from start position.

	if(announce_vox_departure)
		console_say("Смена режима маскировки: полная маскировка. [station_name_ru()] не будет оповещен о нашем прибытии.")
		announce_vox_departure = FALSE
	else
		console_say("Смена режима маскировки: торговое судно. [station_name_ru()] будет оповещен о нашем прибытии.")
		announce_vox_departure = TRUE

/obj/machinery/computer/vox_station
	name = "skipjack terminal"
	cases = list("терминал \"Скипджек\"", "терминала \"Скипджек\"", "терминалу \"Скипджек\"", "терминал \"Скипджек\"", "терминалом \"Скипджек\"", "терминале \"Скипджек\"")
	icon = 'icons/locations/shuttles/vox_pc.dmi'
	icon_state = "vox_cont"
	state_broken_preset = "tcbossb"
	state_nopower_preset = "tcboss0"
	var/area/curr_location
	var/moving = FALSE
	var/lastMove = 0
	var/warning = FALSE // Warning about the end of the round.
	var/returning = FALSE

	var/datum/announcement/centcomm/vox/arrival/announce_arrival = new
	var/datum/announcement/centcomm/vox/returns/announce_returns = new

	// Random turfs of the transit areas for the interface
	var/list/solar_coords = list()

	var/list/solar_by_type = list(
		"solars_fore_starboard" = /area/shuttle/vox/northeast_solars,
		"solars_fore_port"      = /area/shuttle/vox/northwest_solars,
		"solars_aft_starboard"  = /area/shuttle/vox/southeast_solars,
		"solars_aft_port"       = /area/shuttle/vox/southwest_solars,
	)

/obj/machinery/computer/vox_station/atom_init()
	. = ..()
	curr_location = locate(/area/shuttle/vox/arkship)

/obj/machinery/computer/vox_station/process()
	if(..())
		if(lastMove + VOX_SHUTTLE_COOLDOWN + 20 >= world.time)
			updateUsrDialog()

/obj/machinery/computer/vox_station/proc/vox_move_to(area/destination)
	if(moving)
		return
	if(lastMove + VOX_SHUTTLE_COOLDOWN > world.time)
		return
	var/area/dest_location = locate(destination)
	if(curr_location == dest_location)
		return

	if(dest_location == locate(/area/shuttle/vox/arkship))
		returning = TRUE

	if(announce_vox_departure)
		if(curr_location == locate(/area/shuttle/vox/arkship))
			announce_arrival.play()
		else if(returning)
			announce_returns.play()

	moving = TRUE
	lastMove = world.time

	if(curr_location.type != dest_location.type)
		var/area/transit_location = locate(/area/shuttle/vox/transit)
		curr_location.move_contents_to(transit_location)
		curr_location = transit_location
		sleep(VOX_SHUTTLE_MOVE_TIME)
		curr_location.parallax_slowdown()
		sleep(PARALLAX_LOOP_TIME)

	curr_location.move_contents_to(dest_location)
	curr_location = dest_location
	moving = FALSE

	return TRUE


/obj/machinery/computer/vox_station/attackby(obj/item/I, mob/user)
	return attack_hand(user)

/obj/machinery/computer/vox_station/attack_ai(mob/user)
	if(!IsAdminGhost(user))
		to_chat(user, "<span class='red'><b>W?r#nING</b>: #%@!!W?|_4?54@ \nUn?B88l3 T? L?-?o-L?CaT2 ##$!?RN?0..%..</span>")//Totally not stolen from ninja.
	else
		. = ..()

/obj/machinery/computer/vox_station/attack_hand(mob/user)
	if(!VOX_CAN_USE(user))
		to_chat(user, "<span class='notice'>Вы понятия не имеете, как это использовать.</span>")
		return
	. = ..()

/obj/machinery/computer/vox_station/ui_interact(mob/user)
	if(!solar_coords.len)
		for(var/ref in solar_by_type)
			var/turf/rand = pick(get_area_turfs(solar_by_type[ref], FALSE))
			solar_coords[ref] = list(rand.x, rand.y)

	// beautifully
	var/const/X = "&times;"

	var/button_html = ""
	for(var/ref in solar_coords)
		button_html += {"
		<a href='?src=\ref[src];[ref]=1'
			style='position: absolute; top: [world.maxy-solar_coords[ref][2]]px; left: [solar_coords[ref][1]]px;'>
			[X]
		</a>"}

	var/time_to_move = max(lastMove + VOX_SHUTTLE_COOLDOWN - world.time, 0)
	var/time_seconds = round(time_to_move * 0.1)
	var/sec_word = pluralize_russian(time_seconds, "секунду", "секунды", "секунд")
	var/dat = {"Маскировочное Поле Skipjack: [announce_vox_departure ? "<span style='color: #ff0000;font-weight: bold;'>Деактивировано!</span>" : "<span style='color: #aa00aa'>Активировано!</span>"]<br><br>
		Местоположение: <b>[capitalize(CASE(curr_location, NOMINATIVE_CASE))]</b><br>
		Готов к полёту[time_to_move ? " через [time_seconds] [sec_word]" : ": Готово"]<br><br>
		<a href='?src=\ref[src];start=1' style='width:100%;text-align:center'>Вернуться в далёкий космос</a>
		<div class="center_div" style="position: relative;" >
			<img src="nanomap_[SSmapping.station_image]_1.png" width="[world.maxx]px" height="[world.maxy]px">
			[button_html]
		</div>
		<a href='?src=\ref[src];mining=1' style='width:100%;text-align:center'>Шахтёрский астероид</a><br><br>"}

	var/datum/browser/popup = new(user, "computer", "[capitalize(CASE(src, NOMINATIVE_CASE))]", 500, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/vox_station/Topic(href, href_list)
	. = ..()
	if(!. || !VOX_CAN_USE(usr))
		return

	if(href_list["start"])
		if(find_faction_by_type(/datum/faction/heist))
			if(!warning)
				console_say("<span class='red'>Нажмите кнопку ещё раз для подтверждения процедуры.</span>")
				warning = TRUE
				addtimer(CALLBACK(src, PROC_REF(reset_warning)), 10 SECONDS) // so, if someone accidentaly uses this, it won't stuck for a whole round.
				return
		vox_move_to(/area/shuttle/vox/arkship)

	else if(href_list["mining"])
		vox_move_to(/area/shuttle/vox/mining)

	else
		for(var/ref in href_list)
			if(solar_by_type[ref])
				vox_move_to(solar_by_type[ref])
				break

	updateUsrDialog()

/obj/machinery/computer/vox_station/proc/reset_warning()
	if(returning) // no point in reseting, if shuttle is going back.
		return
	console_say("Процедура полёта отменена.")
	warning = FALSE

#undef VOX_SHUTTLE_MOVE_TIME
#undef VOX_SHUTTLE_COOLDOWN
#undef VOX_CAN_USE
