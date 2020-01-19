// HOTLINE
// A IC solution for Admin-to-mob hotline.

var/list/hotline_clients = list()
var/list/hotline_active = list()
var/hotline_global = ""
var/hotline_timer_id = 0

/obj/item/weapon/phone/hotline
	name = "red phone"
	desc = "The rotary dial has been replaced with a black knob of unknown purpose. Should anything ever go wrong..."
	var/activated = TRUE
	var/beeps = FALSE
	var/ringing = FALSE
	var/picked = FALSE
	var/verb_pick = FALSE
	var/verb_hang = FALSE
	var/hotline_name = "Hotline"
	var/mob/listener = null
	var/track_delay = 0

/obj/item/weapon/phone/hotline/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)
	hotline_clients += src
	track_delay = world.time

/obj/item/weapon/phone/hotline/Destroy()
	STOP_PROCESSING(SSobj, src)
	hotline_clients -= src
	return ..()

/obj/item/weapon/phone/hotline/process()
	if(track_delay > world.time)
		return
	if(listener)
		var/turf/mainloc = get_turf(src)
		if(!(listener in range(1,mainloc)))
			hang_phone(listener)
	track_delay = world.time + 1 // 0.1 second

/obj/item/weapon/phone/hotline/proc/update_verbs()
	if(ringing && !verb_pick)
		verb_pick = TRUE
		src.verbs += /obj/item/weapon/phone/hotline/proc/pick_phone
	if(!ringing)
		verb_pick = FALSE
		src.verbs -= /obj/item/weapon/phone/hotline/proc/pick_phone

	if(picked && !verb_hang)
		verb_hang = TRUE
		src.verbs += /obj/item/weapon/phone/hotline/proc/hang_phone
	if(!picked)
		verb_hang = FALSE
		src.verbs -= /obj/item/weapon/phone/hotline/proc/hang_phone

/obj/item/weapon/phone/hotline/proc/pick_phone()
	set name = "Pick Phone"
	set category = "Object"
	set src in oview(usr, 1)
	if(!ishuman(usr) || usr.incapacitated() || usr.lying)
		return

	beeps = FALSE
	ringing = FALSE
	picked = TRUE
	listener = usr
	to_chat(usr, "You picked up phone.")
	playsound(src, 'sound/weapons/phone_pick.ogg', VOL_EFFECTS_MASTER, null, FALSE, -2)
	update_verbs()

/obj/item/weapon/phone/hotline/proc/hang_phone(user as mob)
	beeps = TRUE
	picked = FALSE
	listener = null
	to_chat(user, "You hanged up phone.")
	playsound(src, 'sound/weapons/phone_hang.ogg', VOL_EFFECTS_MASTER, null, FALSE, -2)
	update_verbs()

/obj/item/weapon/phone/hotline/proc/hang_verb()
	set name = "Hang Phone"
	set category = "Object"
	set src in oview(usr, 1)
	if(!ishuman(usr) || usr.incapacitated() || usr.lying)
		return

	hang_phone(usr)

/obj/item/weapon/phone/hotline/proc/say(message)
	if(listener)
		listener.show_message(message, SHOWMSG_AUDIO)

/proc/hotline_ring()
	hotline_timer_id = addtimer(CALLBACK(GLOBAL_PROC, .proc/hotline_ring, FALSE), 6 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)
	for(var/obj/item/weapon/phone/hotline/h in hotline_clients)
		if(((h.hotline_name in hotline_active) || hotline_global)  && h.activated && !h.picked)
			h.ringing = TRUE
			playsound(h, 'sound/weapons/phone_ring.ogg', VOL_EFFECTS_MASTER, null, FALSE, 4)
		else
			if(h.picked && !h.beeps)
				h.listener.playsound_local(null, 'sound/weapons/phone_beeps.ogg', VOL_EFFECTS_MASTER, 50, FALSE)
				h.beeps = TRUE
			h.ringing = FALSE
		h.update_verbs()

/client/proc/hotline_set()
	set name = "Hotline Setup"
	set category = "Special Verbs"
	set desc = "Setup a IC admin-to-mob hotline."

	// Some code from response_team()
	if(!holder)
		to_chat(usr, "<span class='warning'>Only administrators may use this command.</span>")
		return
	if(!ticker)
		to_chat(usr, "<span class='warning'>The game hasn't started yet!</span>")
		return
	if(ticker.current_state == 1)
		to_chat(usr, "<span class='warning'>The round hasn't started yet!</span>")
		return

	var/list/hotlines = list()
	for(var/obj/item/weapon/phone/hotline/dist in hotline_clients)
		if(!(dist.hotline_name in hotlines))
			hotlines += dist.hotline_name
	if(!hotlines)
		to_chat(usr, "<span class='warning'>There is not Hotline phones!</span>")
		return
	hotlines += "All"
	var/destination = input(usr, "Please, choose the hotline you want to setup.") as null|anything in hotlines
	if(!destination)
		return
	hotlines -= "All"

	if((destination in hotline_active) || hotline_global)
		switch(alert("Stop a hotline?",,"Yes","No"))
			if("Yes")
				if(destination == "All")
					LAZYCLEARLIST(hotline_active)
					hotline_global = ""
				else if(hotline_global)
					for(var/h in hotlines)
						hotline_active[h] = hotline_global
					hotline_active -= destination
					hotline_global = ""
				else
					hotline_active -= destination
				if(!hotline_active && !hotline_global)
					if(hotline_timer_id)
						deltimer(hotline_timer_id)
						hotline_timer_id = 0
						for(var/obj/item/weapon/phone/hotline/h in hotline_clients)
							h.ringing = FALSE
		return

	switch(alert("Start a hotline?",,"Yes","No"))
		if("No")
			return
	var/hotline_name = sanitize_safe(input(usr, "Pick a name for the Hotline.", "Name") as text)
	if(!hotline_name)
		hotline_name = "Hotline"
	if(destination == "All")
		hotline_global = hotline_name
		LAZYCLEARLIST(hotline_active)
	else
		hotline_active[destination] = hotline_name

	if(!hotline_timer_id)
		hotline_ring()

/client/proc/hotline_say()
	set name = "Hotline Say"
	set category = "Special Verbs"
	set desc = "Say to the Hotline"

	// Some code from response_team()
	if(!holder)
		to_chat(usr, "<span class='warning'>Only administrators may use this command.</span>")
		return
	if(!ticker)
		to_chat(usr, "<span class='warning'>The game hasn't started yet!</span>")
		return
	if(ticker.current_state == 1)
		to_chat(usr, "<span class='warning'>The round hasn't started yet!</span>")
		return

	if(!hotline_active)
		to_chat(usr, "<span class='warning'>The Hotline isn't active!</span>")
		return

	var/list/hotlines = list()
	for(var/h in hotline_active)
		hotlines += h
	hotlines += "All"
	var/destination = input(usr, "Please, choose the hotline you want send message to.") as null|anything in hotlines
	if(!destination)
		return

	var/message = sanitize_safe(input(usr, "Message:", "Hotline message") as text)
	if(!message)
		return

	var/obj/item/weapon/phone/hotline/phone = new
	var/part_a = "<span class='secradio'><span class='name'>"
	var/part_b = "</span><b> [bicon(phone)]\[Hotline\]</b> <span class='message'>"
	var/part_c = "</span></span>"
	var/rendered = "[part_a][hotline_global][part_b]says, \"[message]\"[part_c]"

	var/heard = 0
	if(destination == "All")
		for(var/obj/item/weapon/phone/hotline/h in hotline_clients)
			if(h.picked)
				h.say(rendered)
				heard++
	else
		var/hotline_name = hotline_active[destination]
		for(var/obj/item/weapon/phone/hotline/client in hotline_clients)
			if(client.picked && (client.hotline_name == destination))
				client.say("[part_a][hotline_name][part_b]says, \"[message]\"[part_c]")
				heard++

	log_say("Hotline/[key_name(usr)] : \[[destination]\]: [message]")
	message_admins("Hotline/[destination]: [key_name_admin(usr)]. Heard by [heard] clients. Message: \"[message]\".")