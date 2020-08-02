#define VOX_SHUTTLE_MOVE_TIME 375
#define VOX_SHUTTLE_COOLDOWN 1200
#define VOX_CAN_USE(A) (ishuman(A) && A.can_speak(all_languages["Vox-pidgin"]) || isobserver(A))
// human and know vox language (and ghosts, because ghosts see everything).

//Copied from Syndicate shuttle.
var/global/vox_shuttle_location
var/global/announce_vox_departure = FALSE // Stealth systems - give an announcement or not.

/obj/machinery/proc/console_say(text)
	visible_message("<b>[src]</b> beeps, \"[text]\'")

/obj/machinery/computer/vox_stealth
	name = "skipjack cloaking field terminal"
	icon = 'icons/obj/computer.dmi'
	icon_state = "syndishuttle"
	state_broken_preset = "tcbossb"
	state_nopower_preset = "tcboss0"

/obj/machinery/computer/vox_stealth/attackby(obj/item/I, mob/user)
	return attack_hand(user)

/obj/machinery/computer/vox_stealth/attack_ai(mob/user)
	if(!IsAdminGhost(user))
		to_chat(user, "<span class='red'><b>W?r#nING</b>: #%@!!W?|_4?54@ \nUn?B88l3 T? L?-?o-L?CaT2 ##$!?RN?0..%..</span>") // Totally not stolen from ninja (x2).
	else
		. = ..()

/obj/machinery/computer/vox_stealth/attack_hand(mob/user)
	if(!VOX_CAN_USE(user))
		to_chat(user, "<span class='notice'>You have no idea how to use this.</span>")
		return

	. = ..()
	if(.)
		return

	if(get_area(src) != locate(/area/shuttle/vox/arkship))
		return // no point in this console after moving shuttle from start position.

	if(announce_vox_departure)
		console_say("Смена режима маскировки: полная маскировки. КСН \"Исход\" не будет оповещен о нашем прибытии.")
		announce_vox_departure = FALSE
	else
		console_say("Смена режима маскировки: торговое судно. КСН \"Исход\" будет оповещен о нашем прибытии.")
		announce_vox_departure = TRUE

/obj/machinery/computer/vox_station
	name = "skipjack terminal"
	icon = 'icons/obj/computer.dmi'
	icon_state = "syndishuttle"
	state_broken_preset = "tcbossb"
	state_nopower_preset = "tcboss0"
	var/area/curr_location
	var/moving = FALSE
	var/lastMove = 0
	var/warning = FALSE // Warning about the end of the round.
	var/returning = FALSE

/obj/machinery/computer/vox_station/atom_init()
	. = ..()
	curr_location = locate(/area/shuttle/vox/arkship)

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
			command_alert("Внимание, [station_name()], неподалёку от вашей станции проходит корабль не отвечающий на наши запросы. По последним данным этот корабль принадлежит Торговой Конфедерации.")
		else if(returning)
			command_alert("Your guests are pulling away, Exodus - moving too fast for us to draw a bead on them. Looks like they're heading out of [system_name()] at a rapid clip.", "NSV Icarus")

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
	if(istype(dest_location, /area/shuttle/vox/arkship))
		vox_shuttle_location = "start"
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
		to_chat(user, "<span class='notice'>You have no idea how to use this.</span>")
		return
	. = ..()

/obj/machinery/computer/vox_station/ui_interact(mob/user)
	var/dat = {"Skipjack Cloaking Field: [announce_vox_departure ? "<span class='danger'>Deactivated!</span>" : "<span class='vox'>Activated!</span>"]<br><br>
		Location: [curr_location]<br>
		Ready to move[max(lastMove + VOX_SHUTTLE_COOLDOWN - world.time, 0) ? " in [max(round((lastMove + VOX_SHUTTLE_COOLDOWN - world.time) * 0.1), 0)] seconds" : ": now"]<br>
		<a href='?src=\ref[src];start=1'>Return to dark space</a><br><br>
		<a href='?src=\ref[src];solars_fore_port=1'>North-west solar port</a> |
		<a href='?src=\ref[src];solars_fore_starboard=1'>North-east starboard</a><br>
		<a href='?src=\ref[src];solars_aft_port=1'>South-west solar port</a> |
		<a href='?src=\ref[src];solars_aft_starboard=1'>South-east starboard</a><br>
		<a href='?src=\ref[src];mining=1'>Mining Asteroid</a><br><br>
		<a href='?src=\ref[user];mach_close=computer'>Close</a>"}

	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")

/obj/machinery/computer/vox_station/Topic(href, href_list)
	. = ..()
	if(!. || !VOX_CAN_USE(usr))
		return

	vox_shuttle_location = "station"
	if(href_list["start"])
		if(SSticker && (istype(SSticker.mode,/datum/game_mode/heist)))
			if(!warning)
				to_chat(usr, "<span class='red'>Returning to dark space will end your raid and report your success or failure. If you are sure, press the button again.</span>")
				warning = TRUE
				addtimer(CALLBACK(src, .proc/reset_warning), 10 SECONDS) // so, if someone accidentaly uses this, it won't stuck for a whole round.
				return
		vox_move_to(/area/shuttle/vox/arkship)
	else if(href_list["solars_fore_starboard"])
		vox_move_to(/area/shuttle/vox/northeast_solars)
	else if(href_list["solars_fore_port"])
		vox_move_to(/area/shuttle/vox/northwest_solars)
	else if(href_list["solars_aft_starboard"])
		vox_move_to(/area/shuttle/vox/southeast_solars)
	else if(href_list["solars_aft_port"])
		vox_move_to(/area/shuttle/vox/southwest_solars)
	else if(href_list["mining"])
		vox_move_to(/area/shuttle/vox/mining)

	updateUsrDialog()

/obj/machinery/computer/vox_station/proc/reset_warning()
	if(returning) // no point in reseting, if shuttle is going back.
		return
	console_say("Mission abort procedure canceled.")
	warning = FALSE

/obj/machinery/computer/vox_station/bullet_act(obj/item/projectile/Proj)
	visible_message("[Proj] ricochets off [src]!")

#undef VOX_SHUTTLE_MOVE_TIME
#undef VOX_SHUTTLE_COOLDOWN
#undef VOX_CAN_USE
