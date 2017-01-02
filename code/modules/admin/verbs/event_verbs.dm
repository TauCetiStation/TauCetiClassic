var/list/admin_verbs_event = list(
	/client/proc/event_map_loader,
	/client/proc/gateway_fix,
	//client/proc/Noir_anomaly,
	/client/proc/centcom_barriers_toggle
	)

//////////////////////////////
// Map loader
//////////////////////////////

/client/proc/event_map_loader()
	set category = "Event"
	set name = "Event map loader"
	if(!check_rights(R_PERMISSIONS))	return

	var/list/AllowedMaps = list()

	var/list/Lines = file2list("maps/event_map_list.txt")
	if(!Lines.len)	return
	for (var/t in Lines)
		if (!t)
			continue
		t = trim(t)
		if (length(t) == 0)
			continue
		else if (copytext(t, 1, 2) == "#")
			continue
		var/pos = findtext(t, " ")
		var/name = null
		if (pos)
            // No, don't do lowertext here, that breaks paths on linux
			name = copytext(t, 1, pos)
		//	value = copytext(t, pos + 1)
		else
            // No, don't do lowertext here, that breaks paths on linux
			name = t
		if (!name)
			continue

		AllowedMaps.Add(name)


	AllowedMaps += "--CANCEL--"

	var/choice = input("Select a map", , "CANCEL") in AllowedMaps
	if(choice == "--CANCEL--") return

	message_admins("[key_name_admin(src)] started loading event-map [choice]")
	log_admin("[key_name_admin(src)] started loading event-map [choice]")

	var/file = file(choice)
	if(isfile(file))
		maploader.load_map(file)//, load_speed = 100)

	message_admins("[key_name_admin(src)] loaded event-map [choice], zlevel [world.maxz]")
	log_admin("[key_name_admin(src)] loaded event-map [choice], zlevel [world.maxz]")

//////////////////////////////
// Noir event
//////////////////////////////
/*
/client/proc/Noir_anomaly()
	set category = "Event"
	set name = "Noir event(in dev!)"
	if(!check_rights(R_PERMISSIONS))	return

	if(alert("Are you really sure?",,"Yes","No") != "Yes")
		return

	for(var/atom/O in world)
		if(O.icon)
			if(O.color)
				O.color = null

			var/icon/newIcon = icon(O.icon)
			newIcon.GrayScale()
			O.icon = newIcon

	log_admin("[key_name(src)] started noir event!", 1)
	message_admins("\blue [key_name_admin(src)] started noir event!", 1)
*/
//////////////////////////////
// Gateway
//////////////////////////////

/client/proc/gateway_fix()
	set category = "Event"
	set name = "Connect Gateways"

	if(!check_rights(R_FUN))	return

	for(var/obj/machinery/gateway/G in machines)
		G.initialize()

	log_admin("[key_name(src)] connected gates")
	message_admins("\blue [key_name_admin(src)] connected gates")

//////////////////////////////
// Velocity\Centcomm barriers
//////////////////////////////
var/centcom_barriers_stat = 1

/client/proc/centcom_barriers_toggle()
	set category = "Event"
	set name = "Centcom Barriers Toggle"

	centcom_barriers_stat = !centcom_barriers_stat

	if(!check_rights(R_FUN))	return

	for(var/obj/effect/landmark/trololo/L in landmarks_list)
		L.active = centcom_barriers_stat
	for(var/obj/structure/centcom_barrier/B in world)
		B.density = centcom_barriers_stat

	log_admin("[key_name(src)] switched [centcom_barriers_stat? "on" : "off"] centcomm barriers")
	message_admins("\blue [key_name_admin(src)] switched [centcom_barriers_stat? "on" : "off"] centcomm barriers")

/obj/effect/landmark/trololo
	name = "Rickroll"
	//var/melody = 'sound/Never_Gonna_Give_You_Up.ogg'	//NOPE
	var/message = "<i>\blue It's not the door you're looking for...</i>"
	var/active = 1
	var/lchannel = 999

	Crossed(M as mob)
		if(!active) return
		/*if(istype(M, /mob/living/carbon))
			M << sound(melody,0,1,lchannel,20)*/

/obj/structure/centcom_barrier
	name = "Invisible wall"
	anchored = 1
	density = 1
	invisibility = 101
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x3"
