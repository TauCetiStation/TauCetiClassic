/obj/item/device/contraband_finder
	name = "contraband finder"
	icon_state = "contraband_scanner"
	item_state = "contraband_scanner"
	desc = "A hand-held body scanner able to detect items that can't go past customs."
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 3
	w_class = SIZE_TINY
	throw_speed = 4
	throw_range = 10
	m_amt = 200
	origin_tech = "magnets=4;biotech=4"

	var/can_scan = TRUE

	var/scanner_ready = TRUE

	var/contraband_listing = /datum/contraband_listing/velocity

	var/flash_danger_color = FALSE
	var/display_item = FALSE
	var/display_item_delay = 2
	var/can_display_log = FALSE
	var/save_full_log = FALSE

	var/obj/effect/overlay/item_image

	var/warrant_template_type = /obj/item/weapon/paper/warrant/velocity

	var/warrant_name = "Warrant:"
	var/list/pos_warrant_stamps = list("Cargo Industries", "Head of Security", "Captain", "Central Command")
	// Even though Velocity Chief is not in Crew Manifest, and thus can't sign a warrant.
	// We'll put him here for the time being.
	var/list/pos_warrant_head_positions = list("Velocity Chief", "Head of Security", "Captain")

	var/list/warrants

	// You shouldn't be able to use the same warrant multiple times.
	var/warrant_expiration = 10 MINUTES

	var/list/colors_to_hex = list(
		"white" = "#ffffff",
		"green" = "#96c641",
		"yellow" = "#ffd569",
		"orange" = "#e6ba94",
		"red" = "#e38a8a",
	)

	var/obj/effect/overlay/screen
	var/screen_color

	var/list/last_search_log

/obj/item/device/contraband_finder/atom_init()
	. = ..()

	screen = new
	screen.icon = 'icons/obj/device.dmi'
	screen.icon_state = "[icon_state]_screen"
	screen.plane = plane
	screen.layer = layer + 0.01

	screen.blend_mode = BLEND_INSET_OVERLAY

	screen.appearance_flags |= KEEP_TOGETHER

	screen.mouse_opacity = MOUSE_OPACITY_TRANSPARENT//So you can't click on it.
	screen.name = name

	vis_contents += screen

	reset_color()

/obj/item/device/contraband_finder/Destroy()
	set_item_image(null)
	vis_contents -= screen
	QDEL_NULL(screen)
	return ..()

/obj/item/device/contraband_finder/equipped(mob/user, slot)
	. = ..()
	screen.plane = plane
	screen.layer = layer + 0.01

/obj/item/device/contraband_finder/dropped(mob/user)
	. = ..()
	screen.plane = plane
	screen.layer = layer + 0.01

/obj/item/device/contraband_finder/get_standing_overlay(mob/living/carbon/human/H, def_icon_path, sprite_sheet_slot, layer, bloodied_icon_state = null, icon_state_appendix = null)
	var/image/base = ..()

	var/image/I = image(base.icon, base, "[base.icon_state]_screen")
	I.color = screen_color
	I.plane = base.plane
	I.layer = base.layer + 0.01

	base.add_overlay(I)

	return base

/obj/item/device/contraband_finder/attack_self(mob/user)
	if(!scanner_ready)
		return

	if(last_search_log)
		print_search_report(user)
	else
		print_warrant_template(user)

	scanner_ready = FALSE
	user.visible_message("[bicon(src, time_stamp=world.time)] <span class='notice'>Bloop.</span>")
	playsound(user, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)
	flash_color("green")

/obj/item/device/contraband_finder/proc/print_warrant_template(mob/living/user)
	var/obj/item/weapon/paper/P = new warrant_template_type
	if(user.put_in_hands(P))
		return
	if(ismob(loc))
		P.forceMove(loc.loc)
	else
		P.forceMove(loc)

/obj/item/device/contraband_finder/proc/print_search_report(mob/living/user)
	if(!last_search_log || !last_search_log.len)
		return

	var/obj/item/weapon/paper/P = new
	P.name = "Search Report"

	for(var/i in last_search_log)
		P.info += "<hr>"
		P.info += "<font size=\"4\"><b>[i]</b>"
		var/list/data = last_search_log[i]
		if(!islist(data))
			P.info += "(<i>[data]</i>)<br>"
			continue

		P.info += "</font><br>"

		for(var/c in data)
			P.info += "<font size=\"4\"><i>[c]</i></font><br><ul>"
			for(var/reason in data[c])
				P.info += "<li>* [reason]</li><br>"
			P.info += "</ul>"

	P.update_icon()
	P.updateinfolinks()

	last_search_log = null

	if(user.put_in_hands(P))
		return
	if(ismob(loc))
		P.forceMove(loc.loc)
	else
		P.forceMove(loc)

/obj/item/device/contraband_finder/proc/check_warrant(obj/item/weapon/paper/P, mob/living/user)
	if(!dd_hasprefix(P.name, warrant_name))
		return FALSE

	var/warrant_name_len = length(warrant_name)
	var/victim_name = trim(copytext(P.name, warrant_name_len + 1))

	// Signed by the victim, they're into this. So, why not?
	if(P.signed_by && P.signed_by[victim_name] && P.signed_by[victim_name] + warrant_expiration >= world.time)
		if(P.last_info_change <= P.signed_by[victim_name] && P.last_name_change <= P.signed_by[victim_name])
			return victim_name

	if(P.stamped_by)
		for(var/stamp in pos_warrant_stamps)
			if(!P.stamped_by[stamp])
				continue
			if(P.stamped_by[stamp] + warrant_expiration < world.time)
				continue
			// Stamped by a head.
			if(P.last_info_change <= P.stamped_by[stamp] && P.last_name_change <= P.stamped_by[stamp])
				return victim_name

	if(!P.signed_by)
		return FALSE

	var/list/manifest = data_core.get_manifest()
	if(!manifest)
		return FALSE

	for(var/dep in manifest)
		for(var/person in manifest[dep])
			if(!(person["rank"] in pos_warrant_head_positions))
				continue
			if(!(person["name"] in P.signed_by))
				continue

			if(P.signed_by[person["name"]] && P.signed_by[person["name"]] + warrant_expiration < world.time)
				continue

			if(P.last_info_change > P.signed_by[person["name"]] || P.last_name_change > P.signed_by[person["name"]])
				continue

			// Signed by a head.
			return victim_name

	return FALSE

/obj/item/device/contraband_finder/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/weapon/paper))
		return ..()

	var/victim_name = check_warrant(I, user)
	if(!victim_name)
		scanner_ready = FALSE
		user.visible_message(
			"[bicon(src, time_stamp=world.time)] <span class='warning bold'>Bleep! Bleep! Bleep!</span>",
			"[bicon(src, time_stamp=world.time)] <span class='warning'>Inappropriate warrant submitted. Make sure the name is of the format Warrant: NAME OF SUSPECT, is signed by suspect, or head, or stamped by a head in the last 10 minutes.</span>",
			"[bicon(src, time_stamp=world.time)] <span class='warning bold'>Bleep! Bleep! Bleep!</span>",
		)
		playsound(user, 'sound/effects/triple_beep.ogg', VOL_EFFECTS_MASTER)
		flash_color("red")
		return

	if(LAZYACCESS(warrants, victim_name))
		scanner_ready = FALSE
		user.visible_message(
			"[bicon(src, time_stamp=world.time)] <span class='warning bold'>Bleep! Bleep! Bleep!</span>",
			"[bicon(src, time_stamp=world.time)] <span class='warning'>Warrant already present in database. Go ahead and search them already!</span>",
			"[bicon(src, time_stamp=world.time)] <span class='warning bold'>Bleep! Bleep! Bleep!</span>",
		)
		playsound(user, 'sound/effects/triple_beep.ogg', VOL_EFFECTS_MASTER)
		flash_color("red")
		return

	LAZYSET(warrants, victim_name, TRUE)
	if(warrants.len > 10)
		warrants.Cut(1, 2)

	scanner_ready = FALSE
	visible_message(
		"[bicon(src, time_stamp=world.time)] <span class='notice'>Bloop.</span>",
		"[bicon(src, time_stamp=world.time)] <span class='notice'>Bloop.</span>",
	)
	playsound(user, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)
	flash_color("green")

/obj/item/device/contraband_finder/proc/reset_color()
	screen_color = colors_to_hex["white"]
	screen.color = screen_color

	set_light(2, 1, screen_color)

	set_item_image(null)

	update_inv_mob()
	scanner_ready = TRUE

/obj/item/device/contraband_finder/proc/flash_color(color)
	screen_color = colors_to_hex[color]
	screen.color = screen_color

	set_light(2, 1, screen_color)

	update_inv_mob()
	addtimer(CALLBACK(src, PROC_REF(reset_color)), 2 SECONDS)

/obj/item/device/contraband_finder/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	if(!ismob(loc))
		return ..()
	if(!CanMouseDrop(src))
		return

	var/mob/M = loc

	if(M.get_active_hand() != src)
		return

	if(!M.IsAdvancedToolUser())
		to_chat(M, "<span class='warning'>You can not comprehend what to do with this.</span>")
		return FALSE

	add_fingerprint(M)
	INVOKE_ASYNC(src, PROC_REF(scan), over, M)
	return TRUE

/obj/item/device/contraband_finder/proc/can_scan(atom/target, mob/user)
	if(!scanner_ready)
		return FALSE

	if(!ishuman(target))
		return TRUE

	var/list/manifest = data_core.get_manifest()
	if(!manifest)
		return TRUE

	var/mob/living/carbon/human/H = target

	if(H.incapacitated())
		return TRUE

	if(security_level != SEC_LEVEL_GREEN)
		return TRUE

	var/obj/item/weapon/card/id/I = H.get_idcard()
	if(!I)
		return TRUE

	for(var/dep in manifest)
		for(var/person in manifest[dep])
			if(person["name"] == I.registered_name)
				if(warrants && warrants[I.registered_name])
					var/obj/item/weapon/paper/P = H.get_active_hand()
					if(!istype(P))
						P = H.get_inactive_hand()

					if(!istype(P))
						user.visible_message(
							"[bicon(src, time_stamp=world.time)] <span class='warning bold'>Bleep! Bleep! Bleep!</span>",
							"[bicon(src, time_stamp=world.time)] <span class='warning'>Suspect must be holding the warrant.</span>",
							"[bicon(src, time_stamp=world.time)] <span class='warning bold'>Bleep! Bleep! Bleep!</span>",
						)
						return FALSE

					if(I.registered_name != check_warrant(P, user))
						user.visible_message(
							"[bicon(src, time_stamp=world.time)] <span class='warning bold'>Bleep! Bleep! Bleep!</span>",
							"[bicon(src, time_stamp=world.time)] <span class='warning'>Warrant inappropriate.</span>",
							"[bicon(src, time_stamp=world.time)] <span class='warning bold'>Bleep! Bleep! Bleep!</span>",
						)
						return FALSE

					LAZYREMOVE(warrants, I.registered_name)
					return TRUE

				user.visible_message(
					"[bicon(src, time_stamp=world.time)] <span class='warning bold'>Bleep! Bleep! Bleep!</span>",
					"[bicon(src, time_stamp=world.time)] <span class='warning'>Cannot search unrestrained suspects while <b>Alert Level</b> is <span class='bold nicegreen'>GREEN</span> without a warrant.</span>",
					"[bicon(src, time_stamp=world.time)] <span class='warning bold'>Bleep! Bleep! Bleep!</span>",
				)
				return FALSE

	return TRUE

/obj/item/device/contraband_finder/proc/get_item_image(atom/target)
	var/image/I = image(target.icon, screen, target.icon_state)

	I.appearance = target

	I.plane = screen.plane
	I.layer = screen.layer + 0.1

	I.blend_mode = BLEND_INSET_OVERLAY

	I.appearance_flags |= RESET_COLOR|KEEP_TOGETHER|PIXEL_SCALE
	I.color = rgb(125, 180, 225)
	I.alpha = 200

	var/matrix/M = matrix()
	M.Scale(0.5, 0.5)
	I.transform = M

	var/image/holo_mask = image('icons/effects/effects.dmi', I, "scanline")
	holo_mask.blend_mode = BLEND_MULTIPLY
	I.overlays += holo_mask

	return I

/obj/item/device/contraband_finder/proc/set_item_image(atom/target)
	if(item_image)
		screen.overlays -= item_image
		QDEL_NULL(item_image)

	if(!target)
		return

	var/image/I = get_item_image(target)
	item_image = I

	screen.overlays += item_image

/obj/item/device/contraband_finder/proc/scan_item(atom/target, mob/user, datum/contraband_listing/CL)
	return CL.get_info(target, user, can_display_log && save_full_log)

/obj/item/device/contraband_finder/proc/get_scannables(atom/target, mob/user)
	var/list/targets = list(target)
	. = list()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		for(var/bodypart in H.bodyparts)
			targets += bodypart

	for(var/atom/A as anything in targets)
		. += A.get_contents()
		. += A

/obj/item/device/contraband_finder/proc/add_search_log(atom/target, mob/user, list/info)
	if(!can_display_log)
		return

	if(last_search_log.len < 100)
		var/counter = 1
		var/log_name = "[target.name] #[counter]"
		while(last_search_log[log_name])
			counter += 1
			log_name = "[target.name] #[counter]"

		if(save_full_log)
			last_search_log[log_name] = info["colors"]
		else
			last_search_log[log_name] = info["color"]

		last_search_log = sortTim(last_search_log, cmp=GLOBAL_PROC_REF(cmp_text_asc))
	else

		last_search_log = list("#Error"="Too many items found during scan.")

/obj/item/device/contraband_finder/proc/scan(atom/target, mob/user)
	if(!can_scan(target, user))
		if(scanner_ready)
			scanner_ready = FALSE
			playsound(user, 'sound/effects/triple_beep.ogg', VOL_EFFECTS_MASTER)
			flash_color("red")
		return

	if(user.is_busy())
		return
	if(ismob(target))
		if(!do_after(user, SKILL_TASK_TRIVIAL, target = target))
			return
		if(!can_scan(target, user))
			if(scanner_ready)
				scanner_ready = FALSE
				playsound(user, 'sound/effects/triple_beep.ogg', VOL_EFFECTS_MASTER)
				flash_color("red")
			return

	scanner_ready = FALSE

	last_search_log = list()

	var/datum/contraband_listing/CL = global.contraband_listings[contraband_listing]

	var/max_priority_danger_color = CL.default_color
	var/max_priority_item = null

	var/list/to_check = get_scannables(target, user)

	for(var/atom/A as anything in to_check)
		var/list/info = scan_item(A, user, CL)

		var/danger_color = info["color"]

		add_search_log(A, user, info)

		if(CL.color_to_priority[danger_color] > CL.color_to_priority[max_priority_danger_color])
			max_priority_danger_color = danger_color
			max_priority_item = A

		if(display_item)
			set_item_image(A)

		if(!flash_danger_color)
			if(danger_color == CL.max_priority)
				break

			continue

		screen_color = colors_to_hex[danger_color]
		screen.color = screen_color

		update_inv_mob()

		if(!do_after(user, display_item_delay, TRUE, A, FALSE, FALSE))
			scanner_ready = TRUE
			UNSETEMPTY(last_search_log)
			reset_color()
			return

	ping(user, max_priority_danger_color)

	flash_color(max_priority_danger_color)

	if(display_item)
		set_item_image(max_priority_item, max_priority_danger_color)

	UNSETEMPTY(last_search_log)

/obj/item/device/contraband_finder/proc/ping(mob/living/user, danger_color)
	switch(danger_color)
		if("green")
			visible_message(
				"[bicon(src, time_stamp=world.time)] <span class='notice'>Ping.</span>",
				"[bicon(src, time_stamp=world.time)] <span class='notice'>Ping.</span>",
			)
			playsound(user, 'sound/machines/ping.ogg', VOL_EFFECTS_MASTER)
		if("yellow")
			visible_message(
				"[bicon(src, time_stamp=world.time)] <span class='warning'>Beep!</span>",
				"[bicon(src, time_stamp=world.time)] <span class='warning'>Beep!</span>",
			)
			playsound(user, 'sound/rig/shortbeep.ogg', VOL_EFFECTS_MASTER)
		if("orange")
			visible_message(
				"[bicon(src, time_stamp=world.time)] <span class='warning'>BEEP!</span>",
				"[bicon(src, time_stamp=world.time)] <span class='warning'>BEEP!</span>",
			)
			playsound(user, 'sound/rig/loudbeep.ogg', VOL_EFFECTS_MASTER)
		if("red")
			visible_message(
				"[bicon(src, time_stamp=world.time)] <span class='warning bold'>BE-E-E-EP!</span>",
				"[bicon(src, time_stamp=world.time)] <span class='warning bold'>BE-E-E-EP!</span>",
			)
			playsound(user, 'sound/rig/longbeep.ogg', VOL_EFFECTS_MASTER)



/obj/item/device/contraband_finder/deluxe
	name = "contraband finder deluxe"
	icon_state = "contraband_scanner_debug"
	item_state = "contraband_scanner"
	desc = "A hand-held body scanner for those who want to search people with style."
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 5
	w_class = SIZE_SMALL
	throw_speed = 4
	throw_range = 10
	m_amt = 300
	origin_tech = "magnets=5;biotech=5;programming=3"

	flash_danger_color = TRUE
	display_item = TRUE
	display_item_delay = 2
	can_display_log = TRUE
	save_full_log = TRUE
