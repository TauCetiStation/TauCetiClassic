
// Fallout Pip-Boy!
/obj/item/clothing/gloves/pipboy
	name = "pip-boy 3000"
	desc = "It's a strange looking device with a screen. Seems like it's worn on the arm. This thing clearly has seen better days."
	icon = 'icons/obj/xenoarchaeology/finds.dmi'
	icon_state = "pipboy3000"
	item_state = "pipboy3000"
	slot_flags = SLOT_FLAGS_BELT | SLOT_FLAGS_GLOVES
	action_button_name = "Toggle Pip-Boy"
	species_restricted = null
	protect_fingers = FALSE
	clipped = TRUE

	var/on = 1 // Is it on.
	var/profile_name = null // Master's name.
	var/screen = 1 // Which screen is currently showing.

	var/alarm_1 = "Expired: 200 years"
	var/alarm_2 = null
	var/alarm_3 = null
	var/alarm_4 = null
	var/alarm_playing = 0 // So they can't abuse alarm's sound

	var/health_analyze_mode = FALSE
	var/output_to_chat = TRUE

/obj/item/clothing/gloves/pipboy/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)
	icon_state = "[initial(icon_state)]_off"
	on = 0
	verbs -= /obj/item/clothing/gloves/pipboy/verb/switch_off


/obj/item/clothing/gloves/pipboy/process()
	if(alarm_playing == 1)
		return
	if(("[worldtime2text()]" == alarm_1) || ("[worldtime2text()]" == alarm_2) || ("[worldtime2text()]" == alarm_3) || ("[worldtime2text()]" == alarm_4))
		var/turf/T = get_turf(src)
		for(var/mob/M in T)
			for(var/obj/item/clothing/gloves/pipboy/P in M.contents)
				if(P == src)
					M.visible_message("<span class='warning'>[bicon(src)][src] rings loudly!</span>")
					alarm_playing = 1
		playsound(src, 'sound/weapons/ring.ogg', VOL_EFFECTS_MASTER)
		if(alarm_playing != 1)
			src.visible_message("<span class='warning'>[bicon(src)][src] rings loudly!</span>")
			alarm_playing = 1
		addtimer(CALLBACK(src, .proc/alarm_stop), 60)

/obj/item/clothing/gloves/pipboy/proc/alarm_stop()
	alarm_playing = 0
	return

/obj/item/clothing/gloves/pipboy/attackby(obj/item/I, mob/user, params)
	if(iscoil(I) || istype(I, /obj/item/weapon/stock_parts/cell) || iswirecutter(I) || istype(I, /obj/item/weapon/scalpel))
		return
	return ..()

/obj/item/clothing/gloves/pipboy/ui_action_click()
	open_interface()

/obj/item/clothing/gloves/pipboy/verb/open_interface()
	set name = "Open Interface"
	set category = "Object"

	if(usr.incapacitated())
		return
	src.interact(usr)

/obj/item/clothing/gloves/pipboy/verb/switch_off()
	set name = "Switch Off"
	set category = "Object"
	icon_state = "[initial(icon_state)]_off"
	playsound(src, 'sound/items/buttonclick.ogg', VOL_EFFECTS_MASTER)
	on = 0
	set_light(0)
	verbs -= /obj/item/clothing/gloves/pipboy/verb/switch_off

/obj/item/clothing/gloves/pipboy/verb/toggle_output()
	set name = "Toggle Output"
	set category = "Object"

	output_to_chat = !output_to_chat
	if(output_to_chat)
		to_chat(usr, "The scanner now outputs data to chat.")
	else
		to_chat(usr, "The scanner now outputs data in a seperate window.")

/obj/item/clothing/gloves/pipboy/attack(mob/living/M, mob/living/user, def_zone)
	if(!health_analyze_mode || !on)
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.flags[IS_SYNTHETIC] || H.species.flags[IS_PLANT])
			add_fingerprint(user)
			var/message = ""
			if(!output_to_chat)
				message += "<HTML><head><title>[M.name]'s scan results</title></head><BODY>"

			message += "<span class = 'notice'>Analyzing Results for ERROR:\n&emsp; Overall Status: ERROR</span><br>"
			message += "&emsp; Key: <font color='blue'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FFA500'>Burns</font>/<font color='red'>Brute</font><br>"
			message += "&emsp; Damage Specifics: <font color='blue'>?</font> - <font color='green'>?</font> - <font color='#FFA500'>?</font> - <font color='red'>?</font><br>"
			message += "<span class = 'notice'>Body Temperature: [H.bodytemperature-T0C]&deg;C ([H.bodytemperature*1.8-459.67]&deg;F)</span><br>"
			message += "<span class = 'warning bold'>Warning: Blood Level ERROR: --% --cl.</span><span class = 'notice bold'>Type: ERROR</span><br>"
			message += "<span class = 'notice'>Subject's pulse:</span><font color='red'>-- bpm.</font><br>"

			if(!output_to_chat)
				message += "</BODY></HTML>"
				user << browse(message, "window=[M.name]_scan_report;size=400x400;can_resize=1")
				onclose(user, "[M.name]_scan_report")
			else
				to_chat(user, message)
		else
			add_fingerprint(user)
			var/dat = health_analyze(M, user, TRUE, output_to_chat)
			if(!output_to_chat)
				user << browse(dat, "window=[M.name]_scan_report;size=400x400;can_resize=1")
				onclose(user, "[M.name]_scan_report")
			else
				to_chat(user, dat)
	else
		to_chat(user, "<span class = 'warning'>Analyzing Results not compiled. Unknown anatomy detected.</span>")

/obj/item/clothing/gloves/pipboy/attack_self(mob/user)
	return src.interact(user)

/obj/item/clothing/gloves/pipboy/interact(mob/user)
	health_analyze_mode = FALSE
	if(on)
		if(profile_name)
			playsound(src, 'sound/items/buttonclick.ogg', VOL_EFFECTS_MASTER)
			var/dat = "<body link='#30CC30' alink='white' bgcolor='#1A351A'><font color='#30CC30'>[name]<br>"
			switch(screen)
				if(1)
					dat += "Hello, [profile_name]!<br>"
					dat += "<h3>MENU</h3>"
					dat += "<br>"
					dat += "<A href='?src=\ref[src];menu=2'>STATS</A><br>"
					dat += "<br>"
					dat += "<A href='?src=\ref[src];menu=3'>ITEMS</A><br>"
					dat += "<br>"
					dat += "<A href='?src=\ref[src];menu=4'>DATA</A><br>"
					dat += "<br>"
					dat += "<br>"
					dat += "<A href='?src=\ref[src];close=1'>Close</A><br>"
				if(2)
					health_analyze_mode = TRUE
					dat += "<h3>STATS</h3>"
					dat += "\The [src.name] is now ready to analyze health!"
					dat += "<br>"
					dat += "<br>"
					dat += "<A href='?src=\ref[src];menu=1'>Back to menu</A><br>"
				if(3)
					dat += "<h3>ITEMS</h3>"
					dat += "<A href='?src=\ref[src];menu=1'>Back to menu</A><br>"
					dat += "<br>"
					dat += list_of_items(user)
					dat += "<br>"
				if(4)
					dat += "<h3>DATA</h3>"
					dat += "<br>"
					dat += "ALARMS LIST<br>"
					dat += "<br>"
					for(var/i in 1 to 4)
						dat += "Alarm [i]. Ringing Time:      "
						var/current_alarm = null
						switch(i)
							if(1)
								current_alarm = alarm_1
							if(2)
								current_alarm = alarm_2
							if(3)
								current_alarm = alarm_3
							if(4)
								current_alarm = alarm_4
						if(current_alarm)
							dat += "[current_alarm]<br>"
						else
							dat += "NOT SET<br>"
					dat += "<br>"
					dat += "<A href='?src=\ref[src];setalarm=1'>Set Alarm 1</A><br>"
					dat += "<br>"
					dat += "<A href='?src=\ref[src];setalarm=2'>Set Alarm 2</A><br>"
					dat += "<br>"
					dat += "<A href='?src=\ref[src];setalarm=3'>Set Alarm 3</A><br>"
					dat += "<br>"
					dat += "<A href='?src=\ref[src];setalarm=4'>Set Alarm 4</A><br>"
					dat += "<br>"
					dat += "<br>"
					dat += "<A href='?src=\ref[src];menu=1'>Back to menu</A><br>"
			dat += "</font></body>"
			user << browse(dat, "window=pipboy")
			onclose(user, "pipboy")
			return
		else
			var/mob/living/U = usr
			create_personality(U)
			to_chat(user, "<span class='notice'>[bicon(src)]You have successfully created a profile! Hello, [profile_name]!</span>")
			return
	else
		icon_state = "[initial(icon_state)]"
		to_chat(user, "<span class='notice'>[bicon(src)]You blow the dust off the [name]'s screen and twist the power button. A small screen happily lights up. This device is now on.</span>")
		set_light(2, 1, "#59f65f")
		on = 1
		verbs += /obj/item/clothing/gloves/pipboy/verb/switch_off
		playsound(src, 'sound/mecha/powerup.ogg', VOL_EFFECTS_MASTER, 30)
		return

/obj/item/clothing/gloves/pipboy/Topic(href, href_list, mob/user)
	..()
	usr.set_machine(src)

	if(href_list["menu"]) // Switches menu screens. Converts a sent text string into a number. Saves a LOT of code.
		screen = text2num(href_list["menu"])

	if(href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=pipboy")
	if(href_list["setalarm"])
		var/newnumberalarm = text2num(href_list["setalarm"])
		create_alarm_clock(usr, newnumberalarm)

	updateSelfDialog()

/obj/item/clothing/gloves/pipboy/proc/create_personality(mob/living/U = usr)
	playsound(src, 'sound/items/buttonclick.ogg', VOL_EFFECTS_MASTER)
	U.visible_message("<span class='notice'>[U] taps on \his [name]'s screen.</span>")
	U.last_target_click = world.time
	var/t = sanitize(input(U, "Please enter your name", name, null) as text)
	t = replacetext(t, "&#34;", "\"")

	if (!t)
		return

	if (!in_range(src, U))
		return

	if (!(on))
		return

	if(U.incapacitated())
		return

	playsound(src, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER)
	profile_name = "[t]"

/obj/item/clothing/gloves/pipboy/proc/create_alarm_clock(mob/living/U = usr, numb_of_alarm)
	playsound(src, 'sound/items/buttonclick.ogg', VOL_EFFECTS_MASTER)
	U.visible_message("<span class='notice'>[U] taps on \his [name]'s screen.</span>")
	U.last_target_click = world.time
	var/alarm = sanitize(input(U, "Please time for the alarm to ring(e.g. 12:00)", name, null) as text)
	switch(numb_of_alarm)
		if(1)
			alarm_1 = "[alarm]"
		if(2)
			alarm_2 = "[alarm]"
		if(3)
			alarm_3 = "[alarm]"
		if(4)
			alarm_4 = "[alarm]"

/obj/item/clothing/gloves/pipboy/proc/list_of_items(mob/user)
	var/message
	var/message_items
	var/message_clothing
	var/mob/living/H = user
	for(var/obj/item/T in H.contents)
		if(T == src)
			continue
		if(istype(T, /obj/item/clothing))
			message_clothing += "[bicon(T)][T.name]<br>"
		else
			if(istype(T, /obj/item/weapon/storage))
				message_clothing += "[bicon(T)][T.name]<br>"
				for(var/obj/item/B in T.contents)
					if(istype(B, /obj/item/clothing))
						message_clothing += "[bicon(B)][B.name]<br>"
					else
						if(istype(B, /obj/item/weapon/storage))
							for(var/obj/item/G in B.contents)
								if(istype(G, /obj/item/clothing))
									message_clothing += "[bicon(G)][G.name]<br>"
								else
									message_items += "[bicon(G)][G.name]<br>"
						message_items += "[bicon(B)][B.name]<br>"
				continue
			else
				message_items += "[bicon(T)][T.name]<br>"

	message = "CLOTHING<br>"
	message += message_clothing
	message += "<br>"
	message += "ITEMS<br>"
	message += message_items

	return message

/obj/item/clothing/gloves/pipboy/pimpboy3billion
	name = "pimp-boy 3 billion"
	desc = "It's a strange looking device with what appears to be gold and silver plating as well as encrusted diamonds. Seems like it's worn on the arm."
	icon_state = "pimpboy3billion"
	item_state = "pimpboy3billion"

/obj/item/clothing/gloves/pipboy/pipboy3000mark4
	name = "pip-boy 3000 mark IV"
	icon_state = "pipboy3000mark4"
	item_state = "pipboy3000mark4"
