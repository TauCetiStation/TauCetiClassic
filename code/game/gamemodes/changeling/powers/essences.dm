/mob/living/parasite/essence
	var/datum/changeling/changeling
	var/flags_allowed = (ESSENCE_HIVEMIND | ESSENCE_PHANTOM | ESSENCE_POINT | ESSENCE_SPEAK_TO_HOST)
	var/obj/effect/essence_phantom/phantom
	var/self_voice = FALSE
	var/is_controling_body = FALSE
	var/obj/screen/essence_voice/voice
	var/obj/screen/essence_phantom/phantom_s

/mob/living/parasite/essence/atom_init(mapload, mob/living/carbon/host, mob/living/carbon/victim)
	. = ..()
	changeling = host.mind.changeling
	changeling.essences += src
	name = victim.mind.name
	victim.mind.transfer_to(src)
	enter_host(host)
	overlays = victim.overlays
	phantom = new(src, src)
	phantom.create_overlay(src)

/mob/living/parasite/essence/Destroy()
	if(host)
		exit_host()
	changeling = null
	QDEL_NULL(phantom)
	return ..()

/mob/living/parasite/essence/Login()
	..()
	if(hud_used)
		hud_used.reload_fullscreen()
	if(changeling)
		for(var/mob/living/parasite/essence/E in changeling.essences)
			if(E.phantom && E.phantom.showed)
				client.images += E.phantom.overlay

/mob/living/parasite/essence/Logout()
	phantom.hide_phantom()
	return ..()

/mob/living/parasite/essence/exit_host()
	..()
	phantom.hide_phantom()
	if(client)
		client.images.Cut()
		client.screen.Cut()

/mob/living/parasite/essence/proc/transfer(atom/new_host)
	exit_host()
	if(iscarbon(new_host))
		enter_host(new_host)
		return
	loc = new_host
	if(client)
		client.eye = new_host

/mob/living/parasite/essence/say(message as text)
	if(!host)
		to_chat(src, "<span class='userdanger'>You can't speak without host!</span>")
		return

	var/message_mode = parse_message_mode(message)
	if(message_mode == "alientalk")
		if(!(flags_allowed & ESSENCE_SPEAK_TO_HOST))
			to_chat(src, "<span class='userdanger'>Your host forbade you speaking to him</span>")
			return
		message = copytext(message, 3) // deleting prefix
		var/n_message = sanitize_plus_chat(message)
		for(var/M in changeling.essences)
			to_chat(M, "<span class='shadowling'><b>[name]:</b> [n_message]</span>")
		to_chat(host, "<span class='shadowling'><b>[name]:</b> [n_message]</span>")
		log_say("Changeling Mind: [name]/[key] : [n_message]")
		return
	else if(message_mode == "changeling")
		if(!(flags_allowed & ESSENCE_HIVEMIND))
			to_chat(src, "<span class='userdanger'>Your host forbade you speaking in hivemind</span>")
			return
		message = copytext(message, 3) // deleting prefix
		var/n_message = sanitize_plus_chat(message)
		for(var/mob/M in mob_list)
			if(M.mind && M.mind.changeling)
				to_chat(M, "<span class='changeling'><b>[changeling.changelingID]'s Essence of [name]:</b> [n_message]</span>")
				for(var/mob in M.mind.changeling.essences)
					to_chat(mob, "<span class='changeling'><b>[changeling.changelingID]'s Essence of [name]:</b> [n_message]</span>")
			else if(isobserver(M) && M.client)
				to_chat(M, "<span class='changeling'><b>[changeling.changelingID]'s Essence of [name]:</b> [n_message]</span>")
		log_say("Changeling Hivechat: [name]/[key] : [n_message]")
		return

	if(!(flags_allowed & ESSENCE_SPEAK))
		to_chat(src, "<span class='userdanger'>Your host forbade you speaking!</span>")
		return

	if(message_mode && !(flags_allowed & ESSENCE_SPEAK_IN_RADIO))
		to_chat(src, "<span class='userdanger'>Your host forbade you speaking in radio!</span>")
		return

	if(ishuman(host) && self_voice)
		var/mob/living/carbon/human/H = host
		var/saved_special_voice = H.special_voice
		H.special_voice = name
		host.say(message, TRUE)
		H.special_voice = saved_special_voice
		return
	host.say(message)

/mob/living/parasite/essence/whisper(message as text)
	if(!host)
		to_chat(src, "<span class='userdanger'>You can't speak without host!</span>")
		return
	if(!(flags_allowed & ESSENCE_WHISP))
		to_chat(src, "<span class='userdanger'>Your host forbade you whispering!</span>")
		return

	if(ishuman(host) && self_voice)
		var/mob/living/carbon/human/H = host
		var/saved_special_voice = H.special_voice
		H.special_voice = name
		host.whisper(message)
		H.special_voice = saved_special_voice
		return

	return host.whisper(message)

/mob/living/parasite/essence/me_verb(message as text)
	set name = "Me"
	if(!host)
		to_chat(src, "<span class='userdanger'>You can't speak without host!</span>")
		return

	if(!(flags_allowed & ESSENCE_EMOTE))
		to_chat(src, "<span class='userdanger'>Your host forbade you emoting!</span>")
		return

	return host.custom_emote(1, message)

/mob/living/parasite/essence/say_understands(mob/other, datum/language/speaking)
	if(!host)
		return FALSE

	return host.say_understands(other, speaking)

/mob/living/parasite/essence/ShiftClickOn(atom/A)
	if(!host || host.blinded)
		return
	examinate(A)

/mob/living/parasite/essence/pointed(atom/A in oview(host))
	set name = "Point To"
	set category = "Object"

	if(!host || host.stat)
		return
	if(!(flags_allowed & ESSENCE_POINT))
		to_chat(src, "<span class='userdanger'>Your host forbade you pointing!</span>")
		return
	var/tile = get_turf(A)
	if(!tile)
		return

	var/obj/O = new /obj/effect/decal/point()
	var/obj/effect/essence_phantom/point = new(tile, src)
	point.create_overlay(O)
	point.pixel_x = A.pixel_x
	point.pixel_y = A.pixel_y
	point.layer = 16
	point.show_phantom(tile)
	qdel(O)
	QDEL_IN(point, 15)

/mob/living/parasite/essence/Life()
	if(!client)
		return
	else
		add_ingame_age()
	if(!host)
		return

	sight = host.sight
	see_in_dark = host.see_in_dark
	see_invisible = host.see_invisible

	for(var/image/hud in client.images) // hud shit goes here
		if(copytext(hud.icon_state, 1, 4) == "hud")
			client.images.Remove(hud)
	if(ishuman(host))
		var/mob/living/carbon/human/H = host
		set_EyesVision(H.sightglassesmod)
		if(H.glasses)
			if(istype(H.glasses, /obj/item/clothing/glasses/sunglasses/sechud))
				var/obj/item/clothing/glasses/sunglasses/sechud/O = H.glasses
				if(O.hud)
					O.hud.process_hud(src)
			else if(istype(H.glasses, /obj/item/clothing/glasses/hud))
				var/obj/item/clothing/glasses/hud/O = H.glasses
				O.process_hud(src)
			else if(istype(H.glasses, /obj/item/clothing/glasses/sunglasses/hud/secmed))
				var/obj/item/clothing/glasses/sunglasses/hud/secmed/O = H.glasses
				O.process_hud(src)


		for(var/scr in screens) // screens shit
			if(!(scr in host.screens))
				clear_fullscreen(scr)

		for(var/scr in host.screens)
			var/obj/screen/fullscreen/host_screen = host.screens[scr]
			overlay_fullscreen(scr, host_screen.type, host_screen.severity)

		for(var/alert in alerts) // alerts shit
			if(!(alert in host.alerts))
				clear_alert(alert)

		for(var/alert in host.alerts)
			var/obj/screen/alert/host_alert = host.alerts[alert]
			if(length(host_alert.overlays) > 0)
				continue
			var/obj/screen/alert/new_alert = throw_alert(alert)
			if(new_alert)
				new_alert.icon_state = host_alert.icon_state

		if(healthdoll && host.healthdoll)
			healthdoll.overlays.Cut()
			healthdoll.icon_state = host.healthdoll.icon_state
			healthdoll.overlays += host.healthdoll.overlays
		if(healths && host.healths)
			healths.icon_state = host.healths.icon_state
		if(internals && host.internals)
			internals.icon_state = host.internals.icon_state

/obj/effect/proc_holder/changeling/manage_essencies
	name = "Manage Essencies"
	genomecost = 0
	req_stat = UNCONSCIOUS
	var/mob/living/parasite/essence/choosen_essence

/obj/effect/proc_holder/changeling/manage_essencies/can_sting(mob/user)
	if(req_stat < user.stat)
		to_chat(user, "<span class='warning'>We are incapacitated.</span>")
		return FALSE
	return TRUE

/obj/effect/proc_holder/changeling/manage_essencies/sting_action(mob/user)
	var/datum/changeling/changeling = user.mind.changeling
	if(changeling.is_controled_by_essence)
		return
	var/dat = ""
	for(var/mob/living/parasite/essence/M in changeling.essences)
		dat += "Essence of [M.name] is [M.client ? "<font color='green'>active</font>" : "<font color='red'>hibernating</font>"]<BR> \
		<a href ='?src=\ref[src];permissions=\ref[M]'>(See permissions)</a>\
		 <a href ='?src=\ref[src];trusted=\ref[M]'>[changeling.trusted_entity == M ? "T" : "unt"]rusted</a>"
		if(M.client)
			dat += " <a href ='?src=\ref[src];share_body=\ref[M]>Delegate Control</a><BR>'>"
		else
			dat += "<BR><BR>"
		if(M != choosen_essence)
			continue

		var/allowed = (M.flags_allowed & ESSENCE_SPEAK)
		dat += "Speak as you \
		<a href='byond://?src=\ref[src];toggle_speak=1'>[allowed ? "" : "dis"]allowed</a><BR>"

		allowed = (M.flags_allowed & ESSENCE_WHISP)
		dat += "Whisper as you \
		<a href='byond://?src=\ref[src];toggle_whisp=1'>[allowed ? "" : "dis"]allowed</a><BR>"

		allowed = (M.flags_allowed & ESSENCE_SPEAK_IN_RADIO)
		dat += "Use radio as you \
		<a href='byond://?src=\ref[src];toggle_radio=1'>[allowed ? "" : "dis"]allowed</a><BR>"

		allowed = (M.flags_allowed & ESSENCE_HIVEMIND)
		dat += "Communicate through hivechat \
		<a href='byond://?src=\ref[src];toggle_hivemind=1'>[allowed ? "" : "dis"]allowed</a><BR>"

		allowed = (M.flags_allowed & ESSENCE_SPEAK_TO_HOST)
		dat += "Speak to you \
		<a href='byond://?src=\ref[src];toggle_speak_host=1'>[allowed ? "" : "dis"]allowed</a><BR>"

		allowed = (M.flags_allowed & ESSENCE_SELF_VOICE)
		dat += "Speak with their voice \
		<a href='byond://?src=\ref[src];toggle_voice=1'>[allowed ? "" : "dis"]allowed</a><BR>"

		allowed = (M.flags_allowed & ESSENCE_PHANTOM)
		dat += "Manifest as a phantom for you \
		<a href='byond://?src=\ref[src];toggle_phantom=1'>[allowed ? "" : "dis"]allowed</a><BR>"

		allowed = (M.flags_allowed & ESSENCE_POINT)
		dat += "Show you something \
		<a href='byond://?src=\ref[src];toggle_point=1'>[allowed ? "" : "dis"]allowed</a><BR>"

		allowed = (M.flags_allowed & ESSENCE_EMOTE)
		dat += "Control your emotions \
		<a href='byond://?src=\ref[src];toggle_emote=1'>[allowed ? "" : "dis"]allowed</a><BR><BR>"

	var/datum/browser/popup = new(user, "essence_managing", "Essence Management Panel", 350)
	popup.set_content(dat)
	popup.open()

/obj/effect/proc_holder/changeling/manage_essencies/Topic(href, href_list)
	if(href_list["share_body"])
		var/mob/living/parasite/essence/M = locate(href_list["share_body"])
		if(!M.client)
			sting_action(usr)
			return
		M.is_controling_body = TRUE
		M.flags_allowed = ESSENCE_ALL
		var/temp_key = usr.key
		usr.key = M.key
		M.key = temp_key
	else if(href_list["trusted"])
		var/T = locate(href_list["trusted"])
		if(T == usr.mind.changeling.trusted_entity)
			usr.mind.changeling.trusted_entity = null
		else
			usr.mind.changeling.trusted_entity = T
			usr.mind.changeling.trusted_entity.flags_allowed = ESSENCE_ALL
	else if(href_list["permissions"])
		var/T = locate(href_list["permissions"])
		if(T == choosen_essence)
			choosen_essence = null
		else
			choosen_essence = T
	else if(href_list["toggle_speak"])
		choosen_essence.flags_allowed ^= ESSENCE_SPEAK
	else if(href_list["toggle_whisp"])
		choosen_essence.flags_allowed ^= ESSENCE_WHISP
	else if(href_list["toggle_radio"])
		choosen_essence.flags_allowed ^= ESSENCE_SPEAK_IN_RADIO
	else if(href_list["toggle_hivemind"])
		choosen_essence.flags_allowed ^= ESSENCE_HIVEMIND
	else if(href_list["toggle_speak_host"])
		choosen_essence.flags_allowed ^= ESSENCE_SPEAK_TO_HOST
	else if(href_list["toggle_voice"])
		choosen_essence.flags_allowed ^= ESSENCE_SELF_VOICE
		choosen_essence.self_voice = FALSE
		choosen_essence.voice.icon_state = "voice_off"
	else if(href_list["toggle_phantom"])
		choosen_essence.flags_allowed ^= ESSENCE_PHANTOM
		choosen_essence.phantom.hide_phantom()
	else if(href_list["toggle_point"])
		choosen_essence.flags_allowed ^= ESSENCE_POINT
	else if(href_list["toggle_emote"])
		choosen_essence.flags_allowed ^= ESSENCE_EMOTE
	sting_action(usr)

/obj/effect/essence_phantom
	var/showed = FALSE
	var/mob/living/parasite/essence/host
	var/image/overlay
	anchored = TRUE
	invisibility = 61

/obj/effect/essence_phantom/atom_init(mapload, mob/living/host)
	. = ..()
	src.host = host

/obj/effect/essence_phantom/proc/create_overlay(atom/f_overlay)
	if(overlay)
		hide_phantom()
		QDEL_NULL(overlay)

	name = f_overlay.name
	overlay = image(f_overlay.icon, f_overlay.icon_state)
	overlay.alpha = 200
	overlay.overlays = f_overlay.overlays
	overlay.loc = src

/obj/effect/essence_phantom/proc/show_phantom(atom/place)
	if(!host || !host.host)
		return
	if(showed)
		return
	if(host.phantom_s)
		host.phantom_s.icon_state = "phantom_on"
	loc = get_turf(place ? place : host)
	showed = TRUE
	for(var/mob/living/M in host.changeling.essences)
		if(!M.client)
			continue
		M.client.images += overlay
	if(host.host.client)
		host.host.client.images += overlay


/obj/effect/essence_phantom/proc/hide_phantom()
	if(!host || !host.host)
		return
	if(!showed)
		return
	host.phantom_s.icon_state = "phantom_off"
	showed = FALSE
	loc = host
	for(var/mob/living/M in host.changeling.essences)
		if(!M.client)
			continue
		M.client.images -= overlay
	if(host.host.client)
		host.host.client.images -= overlay

/obj/effect/essence_phantom/blob_act()
	return

/obj/effect/essence_phantom/ex_act()
	return

/obj/effect/essence_phantom/Destroy()
	hide_phantom()
	QDEL_NULL(overlay)
	host = null
	return ..()

//////////////////////////////////////
/obj/structure/test
	var/type_test = FALSE

/obj/structure/test/atom_init(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/test/process()
	if(type_test)
		visible_message("This is normal message", 1, "This is blind message")
	else
		playsound(src, 'sound/items/buttonclick.ogg', 100)
