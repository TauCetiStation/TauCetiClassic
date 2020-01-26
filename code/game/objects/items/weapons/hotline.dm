// HOTLINE
// An IC solution for Admin-to-mob hotline.

var/global/datum/hotline/hotline_controller = new()

/datum/hotline
	var/list/obj/item/weapon/phone/hotline/clients = list()
	var/list/all_hotlines = list()
	var/list/active_hotlines = list()
	var/timer_id = null

/datum/hotline/proc/connect(obj/item/weapon/phone/hotline/P)
	if (istype(P))
		clients += P

/datum/hotline/proc/disconnect(obj/item/weapon/phone/hotline/P)
	if (istype(P))
		clients -= P

/datum/hotline/proc/scan_phones()
	all_hotlines.Cut()
	for(var/obj/item/weapon/phone/hotline/H in clients)
		if(!(H.hotline_name in all_hotlines))
			all_hotlines += H.hotline_name
	for(var/H in active_hotlines)
		if(!(H in all_hotlines))
			all_hotlines += H
	return

/datum/hotline/proc/reconnect_phones()
	for (var/obj/item/weapon/phone/hotline/H in clients)
		if ((H.hotline_name in active_hotlines) && !H.connected)
			H.connected = TRUE

/datum/hotline/proc/is_active_hotline(hotline_name)
	if (hotline_name == "All" && length(active_hotlines))
		return TRUE
	return (hotline_name in active_hotlines)

// Stop hotline channel
// "All" hotline name is special. It stop ALL hotlines
/datum/hotline/proc/stop_hotline(hotline_name)
	if (!hotline_name)
		return
	var/msg_log = "[key_name(usr)] stopped "
	if (hotline_name == "All")
		msg_log += "all hotlines."
		active_hotlines.Cut()
	else
		msg_log += "a [hotline_name]'s hotline."
		active_hotlines -= hotline_name

	for(var/obj/item/weapon/phone/hotline/H in clients)
		if(is_active_hotline(H.hotline_name))
			if(ishuman(H.loc))
				var/mob/living/carbon/human/L = H.loc
				L.playsound_local(null, 'sound/weapons/phone_beeps.ogg', VOL_EFFECTS_MASTER, 50, FALSE)
				L = null
			H.connected = FALSE
	log_admin(msg_log)
	message_admins("<font color='red'>HOTLINE:</font> [msg_log]")

// Start hotline channel
// "All" hotline name is special. It start all hotlines
/datum/hotline/proc/start_hotline(hotline_name)
	if (!hotline_name)
		return
	scan_phones()
	var/list/started = list()
	if(hotline_name == "All")
		for (var/H in all_hotlines)
			active_hotlines[H] = TRUE
			started += H
	else
		started += hotline_name
		active_hotlines[hotline_name] = TRUE
	log_admin("[key_name(usr)] started hotline[length(started) > 1 ? "s" : ""] " + started.Join(", ") + ".")
	message_admins("<font color='red'>HOTLINE:</font> [key_name(usr)] started hotline[length(started) > 1 ? "s" : ""] " + started.Join(", ") + ".")
	reconnect_phones()
	ring()

/datum/hotline/proc/transmit(message as text, destination as text)
	var/heard = 0
	for(var/obj/item/weapon/phone/hotline/H in clients)
		if(H.picked && H.connected && (destination == "All" || H.hotline_name == destination))
			H.say(message)
			heard++
	log_say("Hotline/[key_name(usr)] : \[[destination]\]: [message]")
	message_admins("<font color='red'>HOTLINE:</font> [key_name(usr)] messaged [destination]([heard]). Message: \"[message]\".")
	return (heard > 0)

/datum/hotline/proc/stop_ring()
	if(timer_id && !length(active_hotlines))
		deltimer(timer_id)
		timer_id = null
		for(var/obj/item/weapon/phone/hotline/H in clients)
			H.ringing = FALSE

/datum/hotline/proc/ring()
	timer_id = addtimer(CALLBACK(src, .proc/ring, FALSE), 6 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)
	for(var/obj/item/weapon/phone/hotline/H in clients)
		if((H.hotline_name in active_hotlines) && H.connected && !H.picked)
			H.ringing = TRUE
			playsound(H, 'sound/weapons/phone_ring.ogg', VOL_EFFECTS_MASTER, null, FALSE, 4)
		else
			H.ringing = FALSE


/obj/item/weapon/phone/hotline
	name = "red phone"
	desc = "The rotary dial has been replaced with a black knob of unknown purpose. Should anything ever go wrong..."
	var/connected = TRUE
	var/ringing = FALSE
	var/picked = FALSE
	var/hotline_name = "Hotline"
	var/addresser_name = ""
	var/mob/listener = null

/obj/item/weapon/phone/hotline/atom_init()
	. = ..()
	global.hotline_controller.connect(src)

/obj/item/weapon/phone/hotline/Destroy()
	global.hotline_controller.disconnect(src)
	return ..()

/obj/item/weapon/phone/hotline/attack_self(mob/user)
	if (picked)
		hang_phone()
	else if(ringing)
		pick_phone()
	return ..()

/obj/item/weapon/phone/hotline/dropped(mob/user)
	if (picked)
		hang_phone(TRUE)
	return ..()

/obj/item/weapon/phone/hotline/proc/pick_phone()
	if(picked || !ishuman(usr) || usr.incapacitated())
		return
	usr.visible_message("[usr] picked up the phone.", "You picked up the phone.")
	playsound(src, 'sound/weapons/phone_pick.ogg', VOL_EFFECTS_MASTER, null, FALSE, -2)
	log_game("[key_name(usr)] picked up a [hotline_name]'s phone.")
	message_admins("<font color='red'>HOTLINE:</font> [key_name_admin(usr)] picked up a [hotline_name]'s phone.", "[ADMIN_PP(usr)] [ADMIN_VV(usr)] [ADMIN_SM(usr)] [ADMIN_TP(usr)] [ADMIN_FLW(usr)]")
	connected = TRUE
	ringing = FALSE
	picked = TRUE

/obj/item/weapon/phone/hotline/proc/hang_phone(force_hang = FALSE)
	if(!picked || !ishuman(usr) || (!force_hang && usr.incapacitated()))
		return
	usr.visible_message("[usr] hung up the phone.", "You hung up the phone.")
	playsound(src, 'sound/weapons/phone_hang.ogg', VOL_EFFECTS_MASTER, null, FALSE, -2)
	log_game("[key_name(usr)] hanged off a [hotline_name]'s phone.")
	message_admins("<font color='red'>HOTLINE:</font> [key_name_admin(usr)] hanged off a [hotline_name]'s phone.", "[ADMIN_PP(usr)] [ADMIN_VV(usr)] [ADMIN_SM(usr)] [ADMIN_TP(usr)] [ADMIN_FLW(usr)]")
	connected = TRUE  // connection reset
	picked = FALSE

/obj/item/weapon/phone/hotline/proc/say(message)
	if(ishuman(loc))
		var/mob/living/carbon/human/L = loc
		var/part_a = "<span class='secradio'><span class='name'>"
		var/part_b = "</span><b> [bicon(src)]\[Hotline\]</b> <span class='message'>"
		var/part_c = "</span></span>"
		var/rendered = "[part_a][addresser_name ? addresser_name : hotline_name][part_b]says, \"[message]\"[part_c]"
		L.show_message(rendered, SHOWMSG_AUDIO)
		L = null

/client/proc/hotline_set()
	set name = "Hotline Toggle"
	set category = "Special Verbs"
	set desc = "Setup an IC admin-to-mob hotline."

	// Checking hotlines exists
	if(!world.has_round_started())
		to_chat(usr, "<span class='warning'>The game hasn't started yet!</span>")
		return

	global.hotline_controller.scan_phones()
	var/list/hotlines = global.hotline_controller.all_hotlines
	if(!length(hotlines))
		to_chat(usr, "<span class='warning'>There is no Hotline phones!</span>")
		return
	// Render hotlines list and get hotline for action
	var/list/hotlines_with_status = list()
	for (var/H in hotlines)
		if (global.hotline_controller.is_active_hotline(H))
			hotlines_with_status += "[H] (Active)"
		else
			hotlines_with_status += H
	if (global.hotline_controller.is_active_hotline("All"))
		hotlines_with_status += "All (Active)"
	else
		hotlines_with_status += "All"
	var/destination = input(usr, "Please, choose the hotline you want to setup.") as null|anything in hotlines_with_status
	if(!destination)
		return
	destination = replacetext(destination, " (Active)", "")
	if (!length(destination))
		return
	// Start or Stop hotline actions
	if (global.hotline_controller.is_active_hotline(destination))
		var/ask_msg = "Stop the [destination] hotline?"
		if (destination == "All")
			ask_msg = "Stop ALL hotlines?"
		switch(alert(ask_msg,, "Yes", "No"))
			if ("Yes")
				global.hotline_controller.stop_hotline(destination)
				return
			if ("No")
				if (destination != "All")
					return
	var/ask_start_msg = "Start [destination]'s hotline?"
	if (destination == "All")
		ask_start_msg = "Start ALL hotlines?"
	if (alert(ask_start_msg,,"Yes","No") == "No")
		return
	global.hotline_controller.start_hotline(destination)

/client/proc/hotline_say()
	set name = "Hotline Say"
	set category = "Special Verbs"
	set desc = "Say to the Hotline"

	// Some code from response_team()
	if(!world.has_round_started())
		to_chat(usr, "<span class='warning'>The round hasn't started yet!</span>")
		return

	if(!length(global.hotline_controller.active_hotlines))
		to_chat(usr, "<span class='warning'>The Hotline isn't active!</span>")
		return

	var/list/hotlines = list()
	for(var/H in global.hotline_controller.active_hotlines)
		hotlines += H
	hotlines += "All"
	var/destination = input(usr, "Please, choose the hotline you want send message to.") as null|anything in hotlines
	if(!destination)
		return

	var/message = sanitize_safe(input(usr, "Message:", "Hotline message") as text)
	if(!message)
		return

	global.hotline_controller.transmit(message, destination)
