/obj/item/device/assembly/signaler
	name = "remote signaling device"
	desc = "Used to remotely activate devices."
	icon_state = "signaller"
	item_state = "signaler"
	m_amt = 1000
	g_amt = 200
	w_amt = 100
	origin_tech = "magnets=1"
	wires = WIRE_RECEIVE | WIRE_PULSE | WIRE_RADIO_PULSE | WIRE_RADIO_RECEIVE

	secured = 1

	var/code = 30
	var/frequency = 1457
	var/delay = 0
	var/airlock_wire = null
	var/datum/wires/connected = null
	var/datum/radio_frequency/radio_connection
	var/deadman = 0

/obj/item/device/assembly/signaler/atom_init()
	. = ..()
	addtimer(CALLBACK(src, .proc/set_frequency, frequency), 40)

/obj/item/device/assembly/signaler/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src,frequency)
	frequency = 0
	connected = null
	return ..()

/obj/item/device/assembly/signaler/activate()
	if(cooldown > 0)
		return FALSE
	cooldown = 2
	addtimer(CALLBACK(src, .proc/process_cooldown), 10)
	signal()
	return TRUE

/obj/item/device/assembly/signaler/update_icon()
	if(holder)
		holder.update_icon()
	return

/obj/item/device/assembly/signaler/interact(mob/user, flag1)
	var/t1 = "-------"
//	if ((src.b_stat && !( flag1 )))
//		t1 = text("-------<BR>\nGreen Wire: []<BR>\nRed Wire:   []<BR>\nBlue Wire:  []<BR>\n", (src.wires & 4 ? text("<A href='?src=\ref[];wires=4'>Cut Wire</A>", src) : text("<A href='?src=\ref[];wires=4'>Mend Wire</A>", src)), (src.wires & 2 ? text("<A href='?src=\ref[];wires=2'>Cut Wire</A>", src) : text("<A href='?src=\ref[];wires=2'>Mend Wire</A>", src)), (src.wires & 1 ? text("<A href='?src=\ref[];wires=1'>Cut Wire</A>", src) : text("<A href='?src=\ref[];wires=1'>Mend Wire</A>", src)))
//	else
//		t1 = "-------"	Speaker: [src.listening ? "<A href='byond://?src=\ref[src];listen=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];listen=1'>Disengaged</A>"]<BR>
	var/dat = {"
<TT>

<A href='byond://?src=\ref[src];send=1'>Send Signal</A><BR>
<B>Frequency/Code</B> for signaler:<BR>
Frequency:
<A href='byond://?src=\ref[src];freq=-10'>-</A>
<A href='byond://?src=\ref[src];freq=-2'>-</A>
[format_frequency(src.frequency)]
<A href='byond://?src=\ref[src];freq=2'>+</A>
<A href='byond://?src=\ref[src];freq=10'>+</A><BR>

Code:
<A href='byond://?src=\ref[src];code=-5'>-</A>
<A href='byond://?src=\ref[src];code=-1'>-</A>
[src.code]
<A href='byond://?src=\ref[src];code=1'>+</A>
<A href='byond://?src=\ref[src];code=5'>+</A><BR>
[t1]
</TT>"}
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return


/obj/item/device/assembly/signaler/Topic(href, href_list)
	..()

	if(usr.incapacitated() || !in_range(loc, usr))
		usr << browse(null, "window=radio")
		onclose(usr, "radio")
		return

	if (href_list["freq"])
		var/new_frequency = (frequency + text2num(href_list["freq"]))
		if(new_frequency < 1200 || new_frequency > 1600)
			new_frequency = sanitize_frequency(new_frequency)
		set_frequency(new_frequency)

	if(href_list["code"])
		src.code += text2num(href_list["code"])
		src.code = round(src.code)
		src.code = min(100, src.code)
		src.code = max(1, src.code)

	if(href_list["send"])
		spawn( 0 )
			signal()

	if(usr)
		attack_self(usr)

	return


/obj/item/device/assembly/signaler/proc/signal()
	if(!radio_connection) return

	var/datum/signal/signal = new
	signal.source = src
	signal.encryption = code
	signal.data["message"] = "ACTIVATE"
	radio_connection.post_signal(src, signal)

	var/time = time2text(world.realtime,"hh:mm:ss")
	var/turf/T = get_turf(src)
	if(usr)
		lastsignalers.Add("[time] <B>:</B> [usr.key] used [src] @ location ([T.x],[T.y],[T.z]) <B>:</B> [format_frequency(frequency)]/[code]")
		message_admins("[key_name_admin(usr)] used [src], location ([T.x],[T.y],[T.z]) <B>:</B> [format_frequency(frequency)]/[code] [ADMIN_JMP(usr)]")
		log_game("[usr.ckey]([usr]) used [src], location ([T.x],[T.y],[T.z]),frequency: [format_frequency(frequency)], code:[code]")
	else
		lastsignalers.Add("[time] <B>:</B> (<span class='warning'>NO USER FOUND</span>) used [src] @ location ([T.x],[T.y],[T.z]) <B>:</B> [format_frequency(frequency)]/[code]")
		message_admins("(<span class='warning'>NO USER FOUND</span>) used [src], location ([T.x],[T.y],[T.z]) <B>:</B> [format_frequency(frequency)]/[code]")
		log_game("(NO USER FOUND) used [src], location ([T.x],[T.y],[T.z]),frequency: [format_frequency(frequency)], code:[code]")

	return

/*
		for(var/obj/item/device/assembly/signaler/S in not_world)
			if(!S)	continue
			if(S == src)	continue
			if((S.frequency == src.frequency) && (S.code == src.code))
				spawn(0)
					if(S)	S.pulse(0)
		return 0*/


/obj/item/device/assembly/signaler/pulse(radio = 0)
	if(connected && wires)
		connected.pulse_signaler(src)
	else if(holder)
		holder.process_activation(src, 1, 0)
	else
		..(radio)
	return 1


/obj/item/device/assembly/signaler/attach_assembly(obj/item/device/assembly/A, mob/user)
	. = ..()
	message_admins("[key_name_admin(user)] attached \the [A] to \the [src]. [ADMIN_JMP(user)]")
	log_game("[key_name(user)] attached \the [A] to \the [src].")


/obj/item/device/assembly/signaler/receive_signal(datum/signal/signal)
	if(!signal)	return 0
	if(signal.encryption != code)	return 0
	if(!(src.wires & WIRE_RADIO_RECEIVE))	return 0
	pulse(1)

	if(!holder)
		audible_message("[bicon(src)] *beep* *beep*", hearing_distance = 1)
	return


/obj/item/device/assembly/signaler/proc/set_frequency(new_frequency)
	if(!frequency)
		return
	if(!radio_controller)
		sleep(20)
	if(!radio_controller)
		return
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, RADIO_CHAT)
	return

/obj/item/device/assembly/signaler/process()
	if(!deadman)
		STOP_PROCESSING(SSobj, src)
	var/mob/M = src.loc
	if(!M || !ismob(M))
		if(prob(5))
			signal()
		deadman = 0
		STOP_PROCESSING(SSobj, src)
	else if(prob(5))
		M.visible_message("[M]'s finger twitches a bit over [src]'s signal button!")
	return

/obj/item/device/assembly/signaler/verb/deadman_it()
	set src in usr
	set name = "Threaten to push the button!"
	set desc = "BOOOOM!"
	deadman = 1
	START_PROCESSING(SSobj, src)
	usr.visible_message("<span class='warning'>[usr] moves their finger over [src]'s signal button...</span>")

// Embedded signaller used in anomalies.
/obj/item/device/assembly/signaler/anomaly
	name = "anomaly core"
	desc = "The neutralized core of an anomaly. It'd probably be valuable for research."
	icon_state = "anomaly core"
	item_state = "electronic"

/obj/item/device/assembly/signaler/anomaly/receive_signal(datum/signal/signal)
	if(!signal)
		return 0
	if(signal.encryption != code)
		return 0
	for(var/obj/effect/anomaly/A in orange(0, src))
		A.anomalyNeutralize()

/obj/item/device/assembly/signaler/anomaly/attack_self()
	return
