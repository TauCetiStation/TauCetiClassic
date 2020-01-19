// HOTLINE
// An IC solution for Admin-to-mob hotline.

var/global/datum/hotline/admin_hotline = new()

/datum/hotline
	var/list/obj/item/weapon/phone/hotline/clients = list()
	var/list/all_hotlines = list()
	var/list/active_hotlines = list()
	var/hotline_global = ""
	var/timer_id = 0

/datum/hotline/proc/update()
	all_hotlines.Cut()
	for(var/obj/item/weapon/phone/hotline/H in clients)
		if(!(H.hotline_name in all_hotlines))
			all_hotlines += H.hotline_name
	for(var/H in active_hotlines)
		if(!(H in all_hotlines))
			all_hotlines += H
	return all_hotlines

/datum/hotline/proc/transmit(message as text, destination as text)
	var/heard = 0
	if(destination == "All")
		for(var/obj/item/weapon/phone/hotline/H in clients)
			if(H.picked)
				H.say(message)
				heard++
	else
		for(var/obj/item/weapon/phone/hotline/H in clients)
			if(H.picked && (H.hotline_name == destination))
				H.say(message)
				heard++
	return heard

/datum/hotline/proc/stop_ring()
	if(timer_id)
		if((active_hotlines.len = 0) && !hotline_global)
			deltimer(timer_id)
			timer_id = 0
			for(var/obj/item/weapon/phone/hotline/H in clients)
				H.ringing = FALSE

/datum/hotline/proc/ring()
	timer_id = addtimer(CALLBACK(src, .proc/ring, FALSE), 6 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)
	for(var/obj/item/weapon/phone/hotline/H in clients)
		if(((H.hotline_name in active_hotlines) || hotline_global) && !H.disconnected && !H.picked)
			H.ringing = TRUE
			playsound(H, 'sound/weapons/phone_ring.ogg', VOL_EFFECTS_MASTER, null, FALSE, 4)
		else
			H.ringing = FALSE

		if(!((H.hotline_name in active_hotlines) || hotline_global) && !H.disconnected && H.picked)
			H.listener.playsound_local(null, 'sound/weapons/phone_beeps.ogg', VOL_EFFECTS_MASTER, 50, FALSE)
			H.disconnected = TRUE
		H.update_verbs()



/obj/item/weapon/phone/hotline
	name = "red phone"
	desc = "The rotary dial has been replaced with a black knob of unknown purpose. Should anything ever go wrong..."
	var/disconnected = FALSE
	var/ringing = FALSE
	var/picked = FALSE
	var/hotline_name = "Hotline"
	var/mob/listener = null
	var/track_delay = 0

/obj/item/weapon/phone/hotline/atom_init()
	. = ..()
	admin_hotline.clients += src
	track_delay = world.time

/obj/item/weapon/phone/hotline/Destroy()
	STOP_PROCESSING(SSobj, src)
	admin_hotline.clients -= src
	listener = null
	return ..()

/obj/item/weapon/phone/hotline/process()
	if(track_delay > world.time)
		return
	if(listener)
		var/turf/mainloc = get_turf(src)
		if(!(listener in range(1,mainloc)))
			hang_phone()
	track_delay = world.time + 1 // 0.1 second

/obj/item/weapon/phone/hotline/proc/update_verbs()
	if(ringing)
		verbs += /obj/item/weapon/phone/hotline/proc/pick_verb
	else
		verbs -= /obj/item/weapon/phone/hotline/proc/pick_verb

	if(picked)
		verbs += /obj/item/weapon/phone/hotline/proc/hang_verb
	else
		verbs -= /obj/item/weapon/phone/hotline/proc/hang_verb

/obj/item/weapon/phone/hotline/proc/pick_verb()
	set name = "Pick Phone"
	set category = "Object"
	set src in oview(1)
	if(!ishuman(usr) || usr.incapacitated() || usr.lying)
		return

	disconnected = FALSE
	ringing = FALSE
	picked = TRUE
	listener = usr
	to_chat(usr, "You picked up the phone.")
	playsound(src, 'sound/weapons/phone_pick.ogg', VOL_EFFECTS_MASTER, null, FALSE, -2)
	message_admins("<font color='red'>HOTLINE:</font> [key_name_admin(usr)] picked up a [hotline_name]'s phone. [ADMIN_JMP(usr)]")

	START_PROCESSING(SSobj, src)
	update_verbs()

/obj/item/weapon/phone/hotline/proc/hang_phone()
	to_chat(listener, "You hung up the phone.")
	playsound(src, 'sound/weapons/phone_hang.ogg', VOL_EFFECTS_MASTER, null, FALSE, -2)
	message_admins("<font color='red'>HOTLINE:</font> [key_name_admin(listener)] hanged off a [hotline_name]'s phone. [ADMIN_JMP(listener)]")

	picked = FALSE
	listener = null

	STOP_PROCESSING(SSobj, src)
	update_verbs()

/obj/item/weapon/phone/hotline/proc/hang_verb()
	set name = "Hang Phone"
	set category = "Object"
	set src in oview(1)
	if(!ishuman(usr) || usr.incapacitated() || usr.lying)
		return
	if(usr != listener)
		if(disconnected)
			return

		if(usr.a_intent == I_HURT)
			listener.playsound_local(null, 'sound/weapons/phone_beeps.ogg', VOL_EFFECTS_MASTER, 50, FALSE)
			disconnected = TRUE
		else
			to_chat(usr, "Why you even want do disrupt a call?")
		return
	hang_phone()

/obj/item/weapon/phone/hotline/proc/say(message)
	if(listener)
		var/part_a = "<span class='secradio'><span class='name'>"
		var/part_b = "</span><b> [bicon(src)]\[Hotline\]</b> <span class='message'>"
		var/part_c = "</span></span>"
		var/rendered = "[part_a][hotline_name][part_b]says, \"[message]\"[part_c]"
		listener.show_message(rendered, SHOWMSG_AUDIO)

/client/proc/hotline_set()
	set name = "Hotline Setup"
	set category = "Special Verbs"
	set desc = "Setup an IC admin-to-mob hotline."

	// Some code from response_team()
	if(!ticker)
		to_chat(usr, "<span class='warning'>The game hasn't started yet!</span>")
		return
	if(ticker.current_state < GAME_STATE_PLAYING)
		to_chat(usr, "<span class='warning'>The round hasn't started yet!</span>")
		return

	var/list/hotlines = admin_hotline.update()
	if(!hotlines)
		to_chat(usr, "<span class='warning'>There is no Hotline phones!</span>")
		return
	hotlines += "All"
	var/destination = input(usr, "Please, choose the hotline you want to setup.") as null|anything in hotlines
	if(!destination)
		return
	hotlines -= "All"

	if((destination in admin_hotline.active_hotlines) || admin_hotline.hotline_global)
		switch(alert("Stop the hotline?",,"Yes","No"))
			if("Yes")
				message_admins("<font color='red'>HOTLINE:</font> [key_name(usr)] stopped a [destination]'s hotline.")
				if(destination == "All")
					admin_hotline.active_hotlines.Cut()
					admin_hotline.hotline_global = ""
				else if(admin_hotline.hotline_global)
					for(var/H in hotlines)
						admin_hotline.active_hotlines[H] = admin_hotline.hotline_global
					admin_hotline.active_hotlines -= destination
					admin_hotline.hotline_global = ""
				else
					admin_hotline.active_hotlines -= destination
				admin_hotline.stop_ring()
		return

	switch(alert("Start the hotline?",,"Yes","No"))
		if("No")
			return
	var/hotline_name = sanitize_safe(input(usr, "Pick a name for the Hotline.", "Name") as text)
	if(!hotline_name)
		hotline_name = "Hotline"
	message_admins("<font color='red'>HOTLINE:</font> [key_name(usr)] started a [destination]'s hotline with name [hotline_name].")
	if(destination == "All")
		admin_hotline.hotline_global = hotline_name
		admin_hotline.active_hotlines.Cut()
	else
		admin_hotline.active_hotlines[destination] = hotline_name

	admin_hotline.ring()

/client/proc/hotline_say()
	set name = "Hotline Say"
	set category = "Special Verbs"
	set desc = "Say to the Hotline"

	// Some code from response_team()
	if(!ticker)
		to_chat(usr, "<span class='warning'>The game hasn't started yet!</span>")
		return
	if(ticker.current_state < GAME_STATE_PLAYING)
		to_chat(usr, "<span class='warning'>The round hasn't started yet!</span>")
		return

	if(!admin_hotline.active_hotlines)
		to_chat(usr, "<span class='warning'>The Hotline isn't active!</span>")
		return

	var/list/hotlines = list()
	for(var/H in admin_hotline.active_hotlines)
		hotlines += H
	hotlines += "All"
	var/destination = input(usr, "Please, choose the hotline you want send message to.") as null|anything in hotlines
	if(!destination)
		return

	var/message = sanitize_safe(input(usr, "Message:", "Hotline message") as text)
	if(!message)
		return

	var/heard = admin_hotline.transmit(message, destination)

	log_say("Hotline/[key_name(usr)] : \[[destination]\]: [message]")
	message_admins("<font color='red'>HOTLINE:</font> [key_name(usr)] messaged [destination]([heard]). Message: \"[message]\".")