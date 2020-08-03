/obj/item/device/assembly/prox_sensor
	name = "proximity sensor"
	desc = "Used for scanning and alerting when someone enters a certain proximity."
	icon_state = "prox"
	m_amt = 800
	g_amt = 200
	w_amt = 50
	origin_tech = "magnets=1"

	wires = WIRE_PULSE

	secured = 0

	var/scanning = 0
	var/timing = 0
	var/time = 10

	var/range = 2

/obj/item/device/assembly/prox_sensor/activate()
	if(!..())	return 0//Cooldown check
	timing = !timing
	update_icon()
	return 0

/obj/item/device/assembly/prox_sensor/toggle_secure()
	secured = !secured
	if(secured)
		START_PROCESSING(SSobj, src)
	else
		scanning = 0
		timing = 0
		STOP_PROCESSING(SSobj, src)
	update_icon()
	return secured

/obj/item/device/assembly/prox_sensor/attach_assembly(obj/item/device/assembly/A, mob/user)
	. = ..()
	message_admins("[key_name_admin(user)] attached \the [A] to \the [src]. [ADMIN_JMP(user)]")
	log_game("[key_name(user)] attached \the [A] to \the [src].")

/obj/item/device/assembly/prox_sensor/HasProximity(atom/movable/AM)
	if (istype(AM, /obj/effect/beam))	return
	if (AM.move_speed < 12)	sense()
	return

/obj/item/device/assembly/prox_sensor/proc/sense()
	var/turf/mainloc = get_turf(src)
//	if(scanning && cooldown <= 0)
//		mainloc.visible_message("[bicon(src)] *boop* *boop*", "*boop* *boop*")
	if((!holder && !secured)||(!scanning)||(cooldown > 0))	return 0
	pulse(0)
	if(!holder)
		mainloc.visible_message("[bicon(src)] *beep* *beep*", "*beep* *beep*")
	cooldown = 2
	spawn(10)
		process_cooldown()

//	var/time_pulse = time2text(world.realtime,"hh:mm:ss")
//	var/turf/T = get_turf(src)
//	lastsignalers.Add("[time_pulse] <B>:</B> [src] activated  @ location ([T.x],[T.y],[T.z])")
//	message_admins("[src] activated  @ location ([T.x],[T.y],[T.z])",0,1)
//	log_game("[src] activated  @ location ([T.x],[T.y],[T.z])")
	return

/obj/item/device/assembly/prox_sensor/process()
	if(scanning)
		var/turf/mainloc = get_turf(src)
		for(var/mob/living/A in range(range,mainloc))
			if (A.move_speed < 12)
				sense()

	if(timing && (time >= 0))
		time--
	if(timing && time <= 0)
		timing = 0
		toggle_scan()
		time = 10
	return

/obj/item/device/assembly/prox_sensor/dropped()
	spawn(0)
		sense()
		return
	return

/obj/item/device/assembly/prox_sensor/proc/toggle_scan()
	if(!secured)	return 0
	scanning = !scanning
	update_icon()
	return

/obj/item/device/assembly/prox_sensor/update_icon()
	cut_overlays()
	attached_overlays = list()
	if(timing)
		add_overlay("prox_timing")
		attached_overlays += "prox_timing"
	if(scanning)
		add_overlay("prox_scanning")
		attached_overlays += "prox_scanning"
	if(holder)
		holder.update_icon()
	if(holder && istype(holder.loc,/obj/item/weapon/grenade/chem_grenade))
		var/obj/item/weapon/grenade/chem_grenade/grenade = holder.loc
		grenade.primed(scanning)
	return

/obj/item/device/assembly/prox_sensor/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()
	sense()

/obj/item/device/assembly/prox_sensor/interact(mob/user)//TODO: Change this to the wires thingy
	if(!secured)
		to_chat(user, "<span class='warning'>The [name] is unsecured!</span>")
		return 0
	var/second = time % 60
	var/minute = (time - second) / 60
	var/dat = text("<TT><B>Proximity Sensor</B>\n[] []:[]\n<A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT>", (timing ? text("<A href='?src=\ref[];time=0'>Arming</A>", src) : text("<A href='?src=\ref[];time=1'>Not Arming</A>", src)), minute, second, src, src, src, src)
	dat += text("<BR>Range: <A href='?src=\ref[];range=-1'>-</A> [] <A href='?src=\ref[];range=1'>+</A>", src, range, src)
	dat += "<BR><A href='?src=\ref[src];scanning=1'>[scanning?"Armed":"Unarmed"]</A> (Movement sensor active when armed!)"
	dat += "<BR><BR><A href='?src=\ref[src];refresh=1'>Refresh</A>"
	dat += "<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"
	user << browse(dat, "window=prox")
	onclose(user, "prox")
	return

/obj/item/device/assembly/prox_sensor/Topic(href, href_list)
	..()
	if(usr.incapacitated() || !in_range(loc, usr))
		usr << browse(null, "window=prox")
		onclose(usr, "prox")
		return

	if(href_list["scanning"])
		toggle_scan()
		var/time_scan = time2text(world.realtime,"hh:mm:ss")
		var/turf/T = get_turf(src)
		if(usr)
			lastsignalers.Add("[time_scan] <B>:</B> [usr.key] used [src] @ location ([T.x],[T.y],[T.z]) <B>:</B> time set: [time]")
			message_admins("[key_name_admin(usr)] used [src] , location ([T.x],[T.y],[T.z]) <B>:</B> time set: [time] [ADMIN_JMP(usr)]")
			log_game("[key_name(usr)] used [src], location ([T.x],[T.y],[T.z]),time set: [time]")
		else
			lastsignalers.Add("[time_scan] <B>:</B> (NO USER FOUND) set [src] @ location ([T.x],[T.y],[T.z]) <B>:</B> time set: [time]")
			message_admins("( NO USER FOUND) used [src], location ([T.x],[T.y],[T.z]) <B>:</B> time set: [time]")
			log_game("(NO USER FOUND) used [src] , location ([T.x],[T.y],[T.z]),time set: [time]")

	if(href_list["time"])
		timing = text2num(href_list["time"])
		update_icon()
		var/time_start = time2text(world.realtime,"hh:mm:ss")
		var/turf/T = get_turf(src)
		if(usr)
			lastsignalers.Add("[time_start] <B>:</B> [usr.key] set [src] [timing?"On":"Off"] @ location ([T.x],[T.y],[T.z]) <B>:</B> time set: [time]")
			message_admins("[key_name_admin(usr)] set [src] [timing?"On":"Off"], location ([T.x],[T.y],[T.z]) <B>:</B> time set: [time] [ADMIN_JMP(usr)]")
			log_game("[key_name(usr)] set [src] [timing?"On":"Off"], location ([T.x],[T.y],[T.z]),time set: [time]")
		else
			lastsignalers.Add("[time_start] <B>:</B> (NO USER FOUND) set [src] [timing?"On":"Off"] @ location ([T.x],[T.y],[T.z]) <B>:</B> time set: [time]")
			message_admins("( NO USER FOUND) set [src] [timing?"On":"Off"], location ([T.x],[T.y],[T.z]) <B>:</B> time set: [time]")
			log_game("(NO USER FOUND) set [src] [timing?"On":"Off"], location ([T.x],[T.y],[T.z]),time set: [time]")

	if(href_list["tp"])
		var/tp = text2num(href_list["tp"])
		time += tp
		time = min(max(round(time), 0), 600)

	if(href_list["range"])
		var/r = text2num(href_list["range"])
		range += r
		range = min(max(range, 1), 5)

	if(href_list["close"])
		usr << browse(null, "window=prox")
		return

	if(usr)
		attack_self(usr)

	return
