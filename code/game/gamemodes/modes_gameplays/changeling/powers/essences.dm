/mob/living/parasite/essence
	alpha = 127
	icon = 'icons/mob/human.dmi'
	var/datum/role/changeling/changeling
	var/flags_allowed = (ESSENCE_HIVEMIND | ESSENCE_PHANTOM | ESSENCE_POINT | ESSENCE_SPEAK_TO_HOST)
	var/obj/effect/essence_phantom/phantom
	var/self_voice = FALSE
	var/is_changeling = FALSE
	var/atom/movable/screen/essence/voice/voice
	var/atom/movable/screen/essence/phantom/phantom_s
	var/rehost_timer_id = 0

/mob/living/parasite/essence/atom_init(mapload, mob/living/carbon/host, mob/living/carbon/victim)
	. = ..()
	changeling = host.mind.GetRoleByType(/datum/role/changeling)
	changeling.essences += src
	name = victim.mind.name
	victim.mind.transfer_to(src)
	enter_host(host)
	phantom = new(src, src)
	phantom.create_overlay(victim)

/mob/living/parasite/essence/Destroy()
	if(host)
		exit_host()
	changeling = null
	QDEL_NULL(phantom)
	if(rehost_timer_id)
		deltimer(rehost_timer_id)
	return ..()

/mob/living/parasite/essence/Login()
	..()
	reload_fullscreen()
	if(changeling)
		for(var/mob/living/parasite/essence/E in changeling.essences)
			if(E.phantom && E.phantom.showed)
				client.images += E.phantom.overlay
		changeling.add_ui(hud_used)
	if(rehost_timer_id)
		deltimer(rehost_timer_id)
		rehost_timer_id = 0

/mob/living/parasite/essence/Logout()
	if(phantom)
		phantom.hide_phantom()
	if(is_changeling)
		rehost_timer_id = addtimer(CALLBACK(src, PROC_REF(change_main_changeling)), 10 MINUTES, TIMER_STOPPABLE)
	return ..()

/mob/living/parasite/essence/proc/change_main_changeling()
	changeling.controled_by = null
	is_changeling = FALSE
	to_chat(host, "<span class='changeling'>The influence on a body of [changeling.changelingID] was weakened,\
	 giving you the opportunity to become a new master.</span>")

/mob/living/parasite/essence/exit_host()
	phantom.hide_phantom()
	..()
	if(client)
		for(var/scr in screens)
			clear_fullscreen(scr)
		for(var/alert in alerts)
			clear_alert(alert)

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
		message = copytext(message, 2 + length(message[2])) // deleting prefix
		var/n_message = sanitize(message)
		for(var/M in changeling.essences)
			to_chat(M, "<span class='shadowling'><b>[name]:</b> [n_message]</span>")
		for(var/datum/orbit/O in host.orbiters)
			to_chat(O.orbiter, "<span class='shadowling'><b>[name]:</b> [n_message]</span>")

		to_chat(host, "<span class='shadowling'><b>[name]:</b> [n_message]</span>")
		log_say("Changeling Mind: [name]/[key] : [n_message]")
		return
	else if(message_mode == "changeling")
		if(!(flags_allowed & ESSENCE_HIVEMIND))
			to_chat(src, "<span class='userdanger'>Your host forbade you speaking in hivemind</span>")
			return
		message = copytext(message, 2 + length(message[2])) // deleting prefix
		var/n_message = sanitize(message)
		for(var/mob/M as anything in mob_list)
			if(ischangeling(M))
				to_chat(M, "<span class='changeling'><b>[changeling.changelingID]'s Essence of [name]:</b> [n_message]</span>")
				var/datum/role/changeling/C = M.mind.GetRoleByType(/datum/role/changeling)
				for(var/mob in C.essences)
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

	if(host.stat == DEAD)
		return

	if(ishuman(host) && self_voice)
		var/mob/living/carbon/human/H = host
		var/saved_special_voice = H.special_voice
		H.special_voice = name
		host.say(message, TRUE)
		H.special_voice = saved_special_voice
		return
	log_say("Essence [name]/[key] via changeling body: [message]")
	host.say(message)

/mob/living/parasite/essence/whisper(message as text)
	if(!host)
		to_chat(src, "<span class='userdanger'>You can't speak without host!</span>")
		return
	if(host.stat == DEAD)
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

	log_whisper("Essence [name]/[key] via changeling body: [message]")
	return host.whisper(message)

/mob/living/parasite/essence/me_emote(message, message_type = SHOWMSG_VISUAL, intentional=FALSE)
	if(!host && intentional)
		to_chat(src, "<span class='userdanger'>You can't speak without host!</span>")
		return

	if(host.stat == DEAD)
		return

	if(!(flags_allowed & ESSENCE_EMOTE))
		to_chat(src, "<span class='userdanger'>Your host forbade you emoting!</span>")
		return

	log_emote("Essence [name]/[key] with changeling body: [message]")
	return host.me_emote(message, message_type, intentional)

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

	if(!host || host.stat != CONSCIOUS)
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
	point.layer = ABOVE_LIGHTING_LAYER
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
	if(changeling)
		client.screen += changeling.lingchemdisplay

	sight = host.sight
	see_in_dark = host.see_in_dark
	see_invisible = host.see_invisible

	if(ishuman(host))
		var/mob/living/carbon/human/H = host
		if(H.glasses)
			set_EyesVision(H.sightglassesmod)

		for(var/scr in screens)
			if(!(scr in host.screens))
				clear_fullscreen(scr)

		for(var/scr in host.screens)
			var/atom/movable/screen/fullscreen/host_screen = host.screens[scr]
			overlay_fullscreen(scr, host_screen.type, host_screen.severity)

		for(var/alert in alerts)
			if(!(alert in host.alerts))
				clear_alert(alert)

		for(var/alert in host.alerts)
			var/atom/movable/screen/alert/host_alert = host.alerts[alert]
			if(length(host_alert.overlays) > 0)
				continue
			var/atom/movable/screen/alert/new_alert = throw_alert(alert, host_alert.type)
			if(new_alert)
				new_alert.icon_state = host_alert.icon_state

		if(healthdoll && host.healthdoll)
			healthdoll.cut_overlays()
			healthdoll.icon_state = host.healthdoll.icon_state
			healthdoll.add_overlay(host.healthdoll.overlays)
		if(healths && host.healths)
			healths.icon_state = host.healths.icon_state

/obj/effect/proc_holder/changeling/manage_essencies
	name = "Manage Essencies"
	button_icon_state = "manage_essensies"
	genomecost = 0
	req_stat = UNCONSCIOUS
	var/mob/living/parasite/essence/choosen_essence

/obj/effect/proc_holder/changeling/manage_essencies/can_sting(mob/user)
	if(req_stat < user.stat)
		to_chat(user, "<span class='warning'>We are incapacitated.</span>")
		return FALSE
	return TRUE

/obj/effect/proc_holder/changeling/manage_essencies/sting_action(mob/user)
	var/datum/role/changeling/changeling = user.mind.GetRoleByType(/datum/role/changeling)
	if(!changeling || changeling.controled_by)
		return FALSE
	var/dat = ""
	for(var/mob/living/parasite/essence/M in changeling.essences)
		dat += "Essence of [M.name] is [M.client ? "<font color='green'>active</font>" : "<font color='red'>hibernating</font>"]<BR> \
		<a href ='?src=\ref[src];permissions=\ref[M]'>See permissions</a>\
		 <a href ='?src=\ref[src];trusted=\ref[M]'>[changeling.trusted_entity == M ? "T" : "unt"]rusted</a>"
		if(M.client)
			dat += " <a href ='?src=\ref[src];share_body=\ref[M]'>Delegate Control</a><BR>"
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
	return FALSE

/mob/living/carbon/proc/delegate_body_to_essence(mob/living/parasite/essence/E)
	if(!ischangeling(src))
		return FALSE
	var/datum/role/changeling/changeling = mind.GetRoleByType(/datum/role/changeling)
	var/changing_changeling_key = TRUE
	if(changeling.delegating)
		return FALSE
	changeling.delegating = TRUE
	sleep(1)
	if(changeling.controled_by)
		changing_changeling_key = FALSE
		if(changeling.controled_by.client)
			changing_changeling_key = TRUE
			changeling.controled_by.is_changeling = FALSE
			var/mob/temp_mob = changeling.controled_by.ghostize(FALSE, FALSE)
			changeling.controled_by.key = key
			key = temp_mob.key
			if(!E)
				changeling.controled_by = null
				changeling.delegating = FALSE
				return
	if(changing_changeling_key)
		E.is_changeling = TRUE
		changeling.controled_by = E
	var/mob/temp_mob = E.ghostize(FALSE, FALSE)
	E.key = key
	key = temp_mob.key
	E.flags_allowed = ESSENCE_ALL
	changeling.delegating = FALSE

/obj/effect/proc_holder/changeling/manage_essencies/Topic(href, href_list)
	if(!ischangeling(usr))
		return
	var/datum/role/changeling/C = usr.mind.GetRoleByType(/datum/role/changeling)
	if(C.controled_by)
		return
	if(href_list["share_body"])
		var/mob/living/parasite/essence/M = locate(href_list["share_body"])
		var/mob/living/carbon/carbon = usr
		carbon.delegate_body_to_essence(M)
	else if(href_list["trusted"])
		var/T = locate(href_list["trusted"])
		if(T == C.trusted_entity)
			C.trusted_entity = null
		else
			C.trusted_entity = T
			C.trusted_entity.flags_allowed = ESSENCE_ALL
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
		choosen_essence.voice.update_icon(choosen_essence)
	else if(href_list["toggle_phantom"])
		choosen_essence.flags_allowed ^= ESSENCE_PHANTOM
		choosen_essence.phantom.hide_phantom()
	else if(href_list["toggle_point"])
		choosen_essence.flags_allowed ^= ESSENCE_POINT
	else if(href_list["toggle_emote"])
		choosen_essence.flags_allowed ^= ESSENCE_EMOTE
	sting_action(usr)

/obj/effect/essence_phantom
	anchored = TRUE
	invisibility = SEE_INVISIBLE_OBSERVER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/showed = FALSE
	var/mob/living/parasite/essence/host
	var/image/overlay

/obj/effect/essence_phantom/atom_init(mapload, mob/living/host)
	. = ..()
	src.host = host

/obj/effect/essence_phantom/proc/create_overlay(atom/f_overlay)
	if(overlay)
		hide_phantom()
		QDEL_NULL(overlay)
	overlay = image(f_overlay.icon, f_overlay.icon_state)
	overlay.alpha = 200
	overlay.copy_overlays(f_overlay)
	overlay.loc = src

/obj/effect/essence_phantom/proc/show_phantom(atom/place)
	if(!host || !host.host)
		return
	if(showed)
		return
	loc = get_turf(place ? place : host)
	showed = TRUE
	host.phantom_s?.update_icon(host)
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
	showed = FALSE
	loc = host
	host.phantom_s?.update_icon(host)
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
