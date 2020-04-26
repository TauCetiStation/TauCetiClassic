/obj/item/device/assembly/timer
	name = "timer"
	desc = "Used to time things. Works well with contraptions which has to count down. Tick tock."
	icon_state = "timer"
	m_amt = 500
	g_amt = 50
	w_amt = 10
	origin_tech = "magnets=1"

	wires = WIRE_PULSE

	secured = 0

	var/timing = 0
	var/time = 10

/obj/item/device/assembly/timer/activate()
	if(!..())	return 0//Cooldown check

	timing = !timing

	update_icon()

	return 0


/obj/item/device/assembly/timer/toggle_secure()
	secured = !secured
	if(secured)
		START_PROCESSING(SSobj, src)
	else
		timing = 0
		STOP_PROCESSING(SSobj, src)
	update_icon()
	return secured


/obj/item/device/assembly/timer/attach_assembly(obj/item/device/assembly/A, mob/user)
	. = ..()
	message_admins("[key_name_admin(user)] attached \the [A] to \the [src]. [ADMIN_JMP(user)]")
	log_game("[key_name(user)] attached \the [A] to \the [src].")


/obj/item/device/assembly/timer/proc/timer_end()
	if(!secured)	return 0
	pulse(0)
	if(!holder)
		visible_message("[bicon(src)] *beep* *beep*", "*beep* *beep*")
	cooldown = 2
	spawn(10)
		process_cooldown()


	var/time_pulse = time2text(world.realtime,"hh:mm:ss")
	var/turf/T = get_turf(src)
	lastsignalers.Add("[time_pulse] <B>:</B> [src] activated  @ location ([T.x],[T.y],[T.z])")
	message_admins("[src] activated  @ location ([T.x],[T.y],[T.z]) [ADMIN_JMP(T)]")
	log_game("[src] activated  @ location ([T.x],[T.y],[T.z])")
	return


/obj/item/device/assembly/timer/process()
	if(timing && (time > 0))
		time--
	if(timing && time <= 0)
		timing = 0
		timer_end()
		time = 10
	return


/obj/item/device/assembly/timer/update_icon()
	cut_overlays()
	attached_overlays = list()
	if(timing)
		add_overlay("timer_timing")
		attached_overlays += "timer_timing"
	if(holder)
		holder.update_icon()
	return


/obj/item/device/assembly/timer/interact(mob/user)//TODO: Have this use the wires
	if(!secured)
		to_chat(user, "<span class='warning'>The [name] is unsecured!</span>")
		return 0
	var/second = time % 60
	var/minute = (time - second) / 60
	var/dat = text("<TT><B>Timing Unit</B>\n[] []:[]\n<A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT>", (timing ? text("<A href='?src=\ref[];time=0'>Timing</A>", src) : text("<A href='?src=\ref[];time=1'>Not Timing</A>", src)), minute, second, src, src, src, src)
	dat += "<BR><BR><A href='?src=\ref[src];refresh=1'>Refresh</A>"
	dat += "<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"
	user << browse(entity_ja(dat), "window=timer")
	onclose(user, "timer")
	return


/obj/item/device/assembly/timer/Topic(href, href_list)
	..()
	if(usr.incapacitated() || !in_range(loc, usr))
		usr << browse(null, "window=timer")
		onclose(usr, "timer")
		return

	if(href_list["time"])
		timing = text2num(href_list["time"])
		var/time_start = time2text(world.realtime,"hh:mm:ss")
		var/turf/T = get_turf(src)
		if(usr)
			lastsignalers.Add("[time_start] <B>:</B> [usr.key] set [src] [timing?"On":"Off"] @ location ([T.x],[T.y],[T.z]) <B>:</B> time set: [time]")
			message_admins("[key_name_admin(usr)] set [src] [timing?"On":"Off"], location ([T.x],[T.y],[T.z]) <B>:</B> time set: [time] [ADMIN_JMP(usr)]")
			log_game("[usr.ckey]([usr]) set [src] [timing?"On":"Off"], location ([T.x],[T.y],[T.z]),time set: [time]")
		else
			lastsignalers.Add("[time_start] <B>:</B> (NO USER FOUND) set [src] [timing?"On":"Off"] @ location ([T.x],[T.y],[T.z]) <B>:</B> time set: [time]")
			message_admins("( NO USER FOUND) set [src] [timing?"On":"Off"], location ([T.x],[T.y],[T.z]) <B>:</B> time set: [time]",0,1)
			log_game("(NO USER FOUND) set [src] [timing?"On":"Off"], location ([T.x],[T.y],[T.z]),time set: [time]")
		update_icon()

	if(href_list["tp"])
		var/tp = text2num(href_list["tp"])
		time += tp
		time = min(max(round(time), 0), 600)

	if(href_list["close"])
		usr << browse(null, "window=timer")
		return

	if(usr)
		attack_self(usr)

	return
