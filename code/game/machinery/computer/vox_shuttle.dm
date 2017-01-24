#define VOX_SHUTTLE_MOVE_TIME 375
#define VOX_SHUTTLE_COOLDOWN 1200

//Copied from Syndicate shuttle.
var/global/vox_shuttle_location
var/global/announce_vox_departure = 0 //Stealth systems - give an announcement or not.

/obj/machinery/computer/vox_stealth
	name = "skipjack cloaking field terminal"
	icon = 'icons/obj/computer.dmi'
	icon_state = "syndishuttle"
	req_access = list(access_syndicate)

/obj/machinery/computer/vox_stealth/attackby(obj/item/I, mob/user)
	return attack_hand(user)

/obj/machinery/computer/vox_stealth/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/vox_stealth/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/computer/vox_stealth/attack_hand(mob/user)
	if(!allowed(user))
		to_chat(user, "\red Access Denied")
		return

	if(announce_vox_departure)
		to_chat(user, "\red Shuttle stealth systems have been activated. The Exodus will not be warned of our arrival.")
		announce_vox_departure = 0
	else
		to_chat(user, "\red Shuttle stealth systems have been deactivated. The Exodus will be warned of our arrival.")
		announce_vox_departure = 1


/obj/machinery/computer/vox_station
	name = "skipjack terminal"
	icon = 'icons/obj/computer.dmi'
	icon_state = "syndishuttle"
	req_access = list(access_syndicate)
	var/area/curr_location
	var/moving = 0
	var/lastMove = 0
	var/warning //Warning about the end of the round.

/obj/machinery/computer/vox_station/New()
	curr_location= locate(/area/shuttle/vox/station)


/obj/machinery/computer/vox_station/proc/vox_move_to(area/destination)
	if(moving)	return
	if(lastMove + VOX_SHUTTLE_COOLDOWN > world.time)	return
	var/area/dest_location = locate(destination)
	if(curr_location == dest_location)	return

	//if(announce_vox_departure)
	//	if(curr_location == locate(/area/shuttle/vox/station))
	//		command_alert("Attention, Exodus, we just tracked a small target bypassing our defensive perimeter. Can't fire on it without hitting the station - you've got incoming visitors, like it or not.", "NSV Icarus")
	//	else if(dest_location == locate(/area/shuttle/vox/station))
	//		command_alert("Your guests are pulling away, Exodus - moving too fast for us to draw a bead on them. Looks like they're heading out of Tau Ceti at a rapid clip.", "NSV Icarus")

	moving = 1
	lastMove = world.time

	if(curr_location.z != dest_location.z)
		var/area/transit_location = locate(/area/vox_station/transit)
		curr_location.move_contents_to(transit_location)
		curr_location = transit_location
		sleep(VOX_SHUTTLE_MOVE_TIME)
		curr_location.parallax_slowdown()
		sleep(PARALLAX_LOOP_TIME)

	curr_location.move_contents_to(dest_location)
	curr_location = dest_location
	if(istype(dest_location, /area/shuttle/vox/station))
		vox_shuttle_location = "start"
	moving = 0

	return 1


/obj/machinery/computer/vox_station/attackby(obj/item/I, mob/user)
	return attack_hand(user)

/obj/machinery/computer/vox_station/attack_ai(mob/user)
	to_chat(user, "<span class='red'><b>W�r#nING</b>: #%@!!WȆ|_4�54@ \nUn�B88l3 T� L�-�o-L�CaT2 ##$!�RN�0..%..</span>")//Totally not stolen from ninja.
	return

/obj/machinery/computer/vox_station/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/computer/vox_station/attack_hand(mob/user)
	if(!allowed(user))
		to_chat(user, "<span class='red'>Access Denied.</span>")
		return

	user.set_machine(src)

	var/dat = {"Location: [curr_location]<br>
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
	return


/obj/machinery/computer/vox_station/Topic(href, href_list)
	. = ..()
	if(!. || !allowed(usr))
		return

	vox_shuttle_location = "station"
	if(href_list["start"])
		if(ticker && (istype(ticker.mode,/datum/game_mode/heist)))
			if(!warning)
				to_chat(usr, "<span class='red'>Returning to dark space will end your raid and report your success or failure. If you are sure, press the button again.</span>")
				warning = 1
				return
		vox_move_to(/area/shuttle/vox/station)
	else if(href_list["solars_fore_starboard"])
		vox_move_to(/area/vox_station/northeast_solars)
	else if(href_list["solars_fore_port"])
		vox_move_to(/area/vox_station/northwest_solars)
	else if(href_list["solars_aft_starboard"])
		vox_move_to(/area/vox_station/southeast_solars)
	else if(href_list["solars_aft_port"])
		vox_move_to(/area/vox_station/southwest_solars)
	else if(href_list["mining"])
		vox_move_to(/area/vox_station/mining)

	updateUsrDialog()

/obj/machinery/computer/vox_station/bullet_act(obj/item/projectile/Proj)
	visible_message("[Proj] ricochets off [src]!")
