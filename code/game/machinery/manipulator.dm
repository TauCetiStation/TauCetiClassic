/*
	      ✞
	Abandon hope.
	      ✞

	Отче наш, сущий на небесах!
	Да святится имя Твоё;
	да приидет Царствие Твоё;
	да будет воля Твоя и на земле,
	как на небе;
	хлеб наш насущный дай нам на сей день;
	и прости нам долги наши,
	как и мы прощаем должникам нашим;
	и не введи нас в искушение, но избавь нас от лукавого.
	Ибо Твоё есть Царство и сила и слава во веки.
	Аминь.
	                                          — Мф. 6:9—13

	Manipulator is a machinery that simulates clicking stuff on stuff.
	Currently it creates it's own mob to click stuff with.
	Which is I might say. Sinful.
 */

#define MANIPULATOR_STATE_OFF "off"
#define MANIPULATOR_STATE_IDLE "idle"
#define MANIPULATOR_STATE_FAIL "fail"
#define MANIPULATOR_STATE_INTERACTING_FROM "interacting_from"
#define MANIPULATOR_STATE_INTERACTING_TO "interacting_to"

/mob/living/carbon/human/bluespace
	var/target_zone

	var/datum/skills/skills

/mob/living/carbon/human/bluespace/atom_init()
	. = ..()
	skills = new
	skills.add_available_skillset(/datum/skillset/max)
	skills.maximize_active_skills()

/mob/living/carbon/human/bluespace/get_targetzone()
	if(zone_sel)
		return ..()
	return target_zone

/mob/living/carbon/human/bluespace/SetNextMove(num)
	return

/mob/living/carbon/human/bluespace/AdjustNextMove(num)
	return

/mob/living/carbon/human/bluespace/get_skills()
	return skills

/obj/item/weapon/circuitboard/manipulator
	name = "Circuit board (Manipulator)"
	build_path = /obj/machinery/manipulator
	origin_tech = "programming=3;materials=3;engineering=3"
	board_type = "machine"

	req_components = list(
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/weapon/stock_parts/capacitor = 1,
		/obj/item/weapon/stock_parts/micro_laser = 1,
	)

	m_amt = 50
	g_amt = 50

/obj/machinery/manipulator
	name = "manipulator"
	desc = "Manipulates stuff. I think we'll put this thing right here..."

	icon = 'icons/obj/machines/logistic.dmi'
	icon_state = "base"

	anchored = TRUE

	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100

	var/delay = 0

	var/turf/from_turf
	var/turf/to_turf

	var/turf/fail_turf

	var/mob/living/carbon/human/bluespace/clicker

	var/state = MANIPULATOR_STATE_IDLE

	var/mirrored = FALSE
	var/fail_angle = 90

	var/image/decal
	var/image/panel
	var/image/status
	var/image/eyes
	var/atom/movable/hand
	var/atom/movable/item

	var/item_x = 0
	var/item_y = 15
	var/item_scale = 0.75

	// Initialized in atom_init because BYOND is weird with int assoc lists like that.
	var/list/hand_offset

	var/busy_moving = FALSE

	// This is here solely for the coolness of manipulators opening crates.
	// If something enters the tile even when manipulator is working, it will remember it,
	// and activate whenver it stops being busy.
	var/remember_trigger = FALSE

	var/datum/wires/manipulator/wires

	var/target_zone = "random"

	var/static/list/possible_target_zones = TARGET_ZONE_ALL + list("random")

	// Whether the next activation chain should be forced (i.e. even when a manipulator doesn't find an item to click with).
	var/forced = FALSE

	// Whether instead of clicking to something we should click the item in hand.
	var/attack_self_interaction = FALSE
	// When pulsed attack self interact only once.
	var/next_attack_self_interaction = FALSE

	// Whether the manipulator will automatically activate on items entering the turf.
	var/auto_activation = TRUE

	// Whether we are cute and have googly eyes.
	var/has_eyes = FALSE
	// The idea of the googly eyes icon.
	var/eyes_id = 1
	// Is currently shaking eyes.
	var/shaking_eyes = FALSE

/obj/machinery/manipulator/atom_init()
	. = ..()

	hand_offset = list(
		"[NORTH]" = list(-1, 4),
		"[SOUTH]" = list(0, 0),
		"[WEST]" = list(-2, 2),
		"[EAST]" = list(2, 3),
	)

	wires = new(src)

	var/image/I = image(icon, src, "manipulator", layer + 0.1, dir)

	hand = new(null)
	hand.simulated = FALSE
	hand.anchored = TRUE
	hand.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	hand.appearance = I

	vis_contents += hand

	eyes_id = rand(1, 3)

	decal = image(icon, src, "manip_decor", layer, dir)
	panel = image(icon, src, "base-wires", layer, dir)
	status = image(icon, src, "power_on", layer, dir)
	eyes = image(icon, src, "eyes-[eyes_id]", layer, dir)

	add_overlay(decal)

	create_clicker()

	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)

	RefreshParts()

	set_dir(dir)

	if(is_operational() && !panel_open)
		add_overlay(status)

/obj/machinery/manipulator/RefreshParts()
	delay = 6

	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		delay -= M.rating

	// Min delay between clicks is 1, so we need at least 2 tick delay to actually be able to interact.
	delay = max(delay, 2)

	var/laser_rating = 1

	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		laser_rating += M.rating

	clicker.mood_multiplicative_actionspeed_modifier = max(-1.0 / (15.0 - laser_rating), -0.9)

/obj/machinery/manipulator/Destroy()
	QDEL_NULL(clicker)

	vis_contents -= hand
	if(item)
		hand.vis_contents -= item

	cut_overlay(decal)
	cut_overlay(panel)
	cut_overlay(status)
	overlays -= eyes

	QDEL_NULL(hand)
	QDEL_NULL(item)
	QDEL_NULL(decal)
	QDEL_NULL(eyes)
	QDEL_NULL(panel)
	QDEL_NULL(status)

	from_turf = null
	to_turf = null
	fail_turf = null

	return ..()

/obj/machinery/manipulator/proc/do_sleep(_delay, datum/callback/extra_checks=null)
	busy_moving = TRUE

	var/endtime = world.time + _delay

	. = TRUE

	while(world.time < endtime)
		stoplag()
		if(QDELETED(src))
			. = FALSE
			break

		if(extra_checks && !extra_checks.Invoke())
			. = FALSE
			break

	busy_moving = FALSE

/obj/machinery/manipulator/proc/set_mirrored(mirrored)
	src.mirrored = mirrored

	if(mirrored)
		fail_angle = -90
	else
		fail_angle = 90

	if(fail_turf)
		UnregisterSignal(fail_turf, list(COMSIG_PARENT_QDELETING))
	set_fail_turf()

	decal.icon_state = "manip_decor[mirrored ? "-mirrored" : ""]"
	cut_overlay(decal)
	add_overlay(decal)

/obj/machinery/manipulator/power_change()
	..()
	if(is_operational() && !panel_open)
		add_overlay(status)

/obj/machinery/manipulator/update_icon()
	if(!clicker)
		return

	var/obj/item/I = clicker.get_active_hand()
	if(!I)
		if(item)
			hand.vis_contents -= item
			item = null
		return

	var/image/IM = image(I.icon, src, I.icon_state, layer + 0.11, SOUTH)

	var/matrix/M = matrix()
	M.Scale(item_scale, item_scale)

	IM.transform = M

	if(item)
		return

	item = new(null)
	item.simulated = FALSE
	item.anchored = TRUE

	item.pixel_x = item_x
	item.pixel_y = item_y

	item.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	item.appearance = IM
	item.appearance_flags |= KEEP_TOGETHER

	hand.vis_contents += item

/obj/machinery/manipulator/proc/get_hand_angle()
	var/hand_angle = 0
	switch(state)
		if(MANIPULATOR_STATE_IDLE)
			hand_angle = 0 // -fail_angle if you want this state to be visible too.
		if(MANIPULATOR_STATE_FAIL)
			hand_angle = fail_angle
		if(MANIPULATOR_STATE_INTERACTING_FROM)
			hand_angle = 0
		if(MANIPULATOR_STATE_INTERACTING_TO)
			hand_angle = 180

	// -180 because manipulator is on the opposite side of where the base is facing.
	return dir2angle(dir) - 180 + hand_angle

/obj/machinery/manipulator/proc/set_state(new_state)
	if(state == new_state)
		return

	state = new_state

	var/hand_angle = get_hand_angle()

	var/matrix/M = matrix()
	M.Turn(hand_angle)

	update_icon()

	animate(hand, time=delay, transform=M)
	if(item)
		var/item_angle = hand_angle

		var/matrix/MI = matrix()

		MI.Turn(item_angle)
		MI.Scale(item_scale, item_scale)

		var/p_x = item_x + hand.pixel_x
		var/p_y = item_y + hand.pixel_y

		var/x = p_x * cos(item_angle) + p_y * sin(item_angle)
		var/y = -p_x * sin(item_angle) + p_y * cos(item_angle)
		animate(item, time=delay, pixel_x=x, pixel_y=y, transform=MI)

	use_power(active_power_usage)

/obj/machinery/manipulator/proc/set_from_turf()
	SIGNAL_HANDLER
	var/opposite_dir = turn(dir, 180)
	from_turf = get_step(src, opposite_dir)
	RegisterSignal(from_turf, list(COMSIG_ATOM_ENTERED), .proc/on_from_entered)
	RegisterSignal(from_turf, list(COMSIG_PARENT_QDELETING), .proc/set_from_turf)

/obj/machinery/manipulator/proc/set_fail_turf()
	SIGNAL_HANDLER
	var/fail_dir = turn(dir, fail_angle)
	fail_turf = get_step(src, fail_dir)
	RegisterSignal(fail_turf, list(COMSIG_PARENT_QDELETING), .proc/set_fail_turf)

/obj/machinery/manipulator/proc/set_to_turf()
	SIGNAL_HANDLER
	to_turf = get_step(src, dir)
	RegisterSignal(to_turf, list(COMSIG_PARENT_QDELETING), .proc/set_to_turf)

/obj/machinery/manipulator/set_dir(new_dir)
	. = ..()

	if(from_turf)
		UnregisterSignal(from_turf, list(COMSIG_ATOM_ENTERED, COMSIG_PARENT_QDELETING))
	if(fail_turf)
		UnregisterSignal(fail_turf, list(COMSIG_PARENT_QDELETING))
	if(to_turf)
		UnregisterSignal(to_turf, list(COMSIG_PARENT_QDELETING))

	set_from_turf()
	set_fail_turf()
	set_to_turf()

	var/string_dir = "[dir]"
	hand.pixel_x = hand_offset[string_dir][1]
	hand.pixel_y = hand_offset[string_dir][2]
	var/matrix/M = matrix()
	M.Turn(get_hand_angle())
	hand.transform = M

	decal.dir = dir
	cut_overlay(decal)
	add_overlay(decal)

/obj/machinery/manipulator/is_operational()
	return ..() && anchored

/obj/machinery/manipulator/proc/on_from_entered(datum/source, atom/movable/entering, atom/oldLoc)
	SIGNAL_HANDLER

	if(!auto_activation)
		return

	if(!can_activate(entering))
		remember_trigger = TRUE
		return

	activate(entering)

/obj/machinery/manipulator/proc/can_activate(atom/target=null)
	if(!is_operational())
		return FALSE

	if(state != MANIPULATOR_STATE_IDLE)
		return FALSE

	if(busy_moving)
		return FALSE

	return TRUE

/obj/machinery/manipulator/proc/activate(atom/target=null)
	INVOKE_ASYNC(src, .proc/try_interact_from, target)

/obj/machinery/manipulator/proc/after_activate()
	var/obj/item/device/assembly/signaler/S = wires.get_attached_signaler(
		wires.get_color_by_index(MANIPULATOR_WIRE_AFTER_ACTIVATE)
	)
	if(S)
		S.signal()

	for(var/obj/item/I in clicker)
		clicker.drop_from_inventory(I, loc)

/obj/machinery/manipulator/verb/rotate()
	set category = "Object"
	set name = "Rotate"
	set desc = "Rotate the manipulator."
	set src in oview(1)

	if(usr.incapacitated())
		return

	if(state != MANIPULATOR_STATE_IDLE)
		to_chat(usr, "<span class='warning'>You cannot rotate [src] while it's working.</span>")
		return

	if(busy_moving)
		to_chat(usr, "<span class='warning'>You cannot rotate [src] while it's working.</span>")
		return

	playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
	set_dir(turn(dir, -90))
	to_chat(usr, "<span class='notice'>You rotate [src].</span>")

/obj/machinery/manipulator/verb/mirror()
	set category = "Object"
	set name = "Mirror"
	set desc = "Mirror the manipulator."
	set src in oview(1)

	if(usr.incapacitated())
		return

	if(state != MANIPULATOR_STATE_IDLE)
		to_chat(usr, "<span class='warning'>You cannot mirror [src] while it's working.</span>")
		return

	if(busy_moving)
		to_chat(usr, "<span class='warning'>You cannot mirror [src] while it's working.</span>")
		return

	playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
	set_mirrored(!mirrored)
	to_chat(usr, "<span class='notice'>You mirror [src].</span>")

/obj/machinery/manipulator/attack_hand(mob/user)
	if(wires.interact(user))
		return

	return ..()

/obj/machinery/manipulator/attackby(obj/item/I, mob/user, params)
	if(isscrewing(I))
		panel_open = !panel_open
		if(panel_open)
			if(is_operational())
				cut_overlay(status)
			add_overlay(panel)
		else
			if(is_operational())
				add_overlay(status)
			cut_overlay(panel)

	else if(iscutter(I))
		wires.interact(user)
		return

	else if(ispulsing(I))
		wires.interact(user)
		return

	else if(issignaler(I))
		wires.interact(user)
		return

	else if(default_unfasten_wrench(user, I) && !busy_moving && state == MANIPULATOR_STATE_IDLE)
		if(issilicon(user))
			to_chat(user, "<span class='warning'>Sorry! Automatic protocols preventing AI from becoming too powerful can't allow you to unwrench this!</span>")
			return

		if(state != MANIPULATOR_STATE_IDLE)
			to_chat(user, "<span class='warning'>You cannot unwrench [src] while it's working.</span>")
			return

		if(busy_moving)
			to_chat(user, "<span class='warning'>You cannot unwrench [src] while it's working.</span>")
			return

		if(!panel_open)
			if(anchored)
				add_overlay(stat)
				set_dir(dir)
			else
				cut_overlay(stat)
		return

	else if(istype(I, /obj/item/weapon/pen))
		to_chat(user, "<span class='notice'>You draw googly eyes on the chassis of [src]. Somehow they even shake!</span>")
		overlays += eyes
		has_eyes = TRUE
		return

	else if(default_deconstruction_crowbar(I))
		return

	return ..()

/obj/machinery/manipulator/proc/create_clicker()
	clicker = new /mob/living/carbon/human/bluespace(src)
	clicker.simulated = FALSE
	clicker.real_name = "manipulator ([rand(0, 999)])"
	clicker.name = clicker.real_name
	clicker.status_flags |= GODMODE
	clicker.canmove = FALSE
	clicker.invisibility = INVISIBILITY_ABSTRACT
	clicker.anchored = TRUE
	clicker.density = FALSE
	clicker.layer = BELOW_TURF_LAYER
	clicker.plane = CLICKCATCHER_PLANE

	global.mob_list -= clicker
	global.living_list -= clicker
	global.carbon_list -= clicker
	global.human_list -= clicker
	global.alive_mob_list -= clicker

/obj/machinery/manipulator/proc/before_click()
	if(name != "manipulator")
		clicker.real_name = name
		clicker.name = clicker.real_name

	clicker.rejuvenate()
	clicker.target_zone = target_zone
	if(target_zone == "random")
		clicker.target_zone = pick(TARGET_ZONE_ALL)
	clicker.forceMove(loc)

/obj/machinery/manipulator/proc/after_click()
	clicker.forceMove(src)

/obj/machinery/manipulator/proc/clickability_from(atom/movable/A)
	return !A.anchored

/obj/machinery/manipulator/proc/clickability_to(atom/A)
	return TRUE

/obj/machinery/manipulator/proc/find_clickable(turf/T, datum/callback/clickability)
	if(!T.contents.len)
		return null

	var/atom/most_clickable

	for(var/C in T.contents)
		var/atom/movable/A = C

		if(A.name == "")
			continue

		if(!A.simulated)
			continue

		if(A.invisibility > clicker.see_invisible)
			continue

		if(clickability && !clickability.Invoke(A))
			continue

		if(!most_clickable)
			most_clickable = A
			continue

		if(A.plane > most_clickable.plane)
			most_clickable = A

		else if(A.plane == most_clickable.plane && A.layer > most_clickable.layer)
			most_clickable = A

	return most_clickable

/obj/machinery/manipulator/proc/DoClick(atom/A, list/params)
	if(!A)
		return
	usr = clicker
	clicker.ClickOn(A, params)

/obj/machinery/manipulator/proc/ClickAndCallBack(atom/A, list/params, list/datum/callback/callbacks)
	DoClick(A, params)

	after_click()

	for(var/datum/callback/C in callbacks)
		C.Invoke()

/obj/machinery/manipulator/proc/simulate_click(atom/A, list/datum/callback/callbacks)
	var/static/list/fake_params = "[ICON_X]=16&[ICON_Y]=16"

	before_click()

	INVOKE_ASYNC(src, .proc/ClickAndCallBack, A, fake_params, callbacks)

/obj/machinery/manipulator/proc/after_interact_from()
	var/obj/item/I = clicker.get_active_hand()
	if(!I && !forced)
		if(remember_trigger)
			remember_trigger = FALSE
			set_state(MANIPULATOR_STATE_IDLE)
			do_sleep(delay)
			try_interact_from()
			return
		set_state(MANIPULATOR_STATE_IDLE)
		do_sleep(delay)
		after_activate()
		return

	forced = FALSE

	try_interact_to()

/obj/machinery/manipulator/proc/shake_eyes()
	if(shaking_eyes)
		return
	shaking_eyes = TRUE

	var/list/eyes_recipients = list()
	for(var/mob/M in viewers(src))
		if(M.client)
			eyes_recipients += M.client

	var/image/I = image(icon, src, "eyes-[eyes_id]-anim", layer, dir)
	I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	flick_overlay(I, eyes_recipients, 5)

	eyes_id = rand(1, 3)
	overlays -= eyes
	eyes = image(icon, src, "eyes-[eyes_id]", layer, dir)
	overlays += eyes

	VARSET_IN(src, shaking_eyes, FALSE, 5)

/obj/machinery/manipulator/proc/try_interact_from(atom/target=null)
	if(!target)
		target = find_clickable(from_turf)

	if(!target && !forced)
		set_state(MANIPULATOR_STATE_IDLE)
		do_sleep(delay)
		return

	set_state(MANIPULATOR_STATE_INTERACTING_FROM)
	if(!do_sleep(delay, CALLBACK(src, /obj/machinery.proc/is_operational)))
		set_state(MANIPULATOR_STATE_IDLE)
		do_sleep(delay)
		return

	if(has_eyes)
		shake_eyes()

	simulate_click(target, list(CALLBACK(src, .proc/after_interact_from)))

/obj/machinery/manipulator/proc/after_interact_to()
	var/obj/item/I = clicker.get_active_hand()
	if(I)
		set_state(MANIPULATOR_STATE_FAIL)
		do_sleep(delay)

		clicker.drop_from_inventory(I, fail_turf)

		set_state(MANIPULATOR_STATE_INTERACTING_TO)
		do_sleep(delay)

	set_state(MANIPULATOR_STATE_IDLE)
	do_sleep(delay)
	after_activate()
	try_interact_from()

/obj/machinery/manipulator/proc/try_interact_to(atom/target=null)
	if(!target)
		target = find_clickable(to_turf)

	if(!target && (attack_self_interaction || next_attack_self_interaction))
		target = clicker.get_active_hand()
		next_attack_self_interaction = FALSE

	if(!target)
		var/obj/item/I = clicker.get_active_hand()
		if(I)
			set_state(MANIPULATOR_STATE_INTERACTING_TO)
			if(!do_sleep(delay, CALLBACK(src, /obj/machinery.proc/is_operational)))
				set_state(MANIPULATOR_STATE_IDLE)
				do_sleep(delay)
				after_activate()
				return

			if(QDELETED(I))
				set_state(MANIPULATOR_STATE_IDLE)
				do_sleep(delay)
				after_activate()
				return

			clicker.drop_from_inventory(I, to_turf)

		INVOKE_ASYNC(src, .proc/after_interact_to)
		return

	set_state(MANIPULATOR_STATE_INTERACTING_TO)
	if(!do_sleep(delay, CALLBACK(src, /obj/machinery.proc/is_operational)))
		set_state(MANIPULATOR_STATE_IDLE)
		do_sleep(delay)
		after_activate()
		return

	simulate_click(target, list(CALLBACK(src, .proc/after_interact_to)))

/obj/machinery/manipulator/proc/cycle_target_zone()
	var/cur_target_index = possible_target_zones.Find(target_zone)
	cur_target_index += 1

	if(cur_target_index > length(possible_target_zones))
		cur_target_index -= length(possible_target_zones)

	target_zone = possible_target_zones[cur_target_index]

/obj/machinery/manipulator/emag_act(mob/user)
	if(emagged)
		return FALSE
	clicker.a_intent = INTENT_HARM
	to_chat(user, "<span class='warning'>You short out [src]'s harm prevention systems.</span>")
	visible_message("[src] hums oddly...")
	emagged = TRUE
	return TRUE

/obj/machinery/manipulator/Moved(atom/OldLoc, Dir)
	. = ..()
	if(has_eyes)
		shake_eyes()

#undef MANIPULATOR_STATE_IDLE
#undef MANIPULATOR_STATE_FAIL
#undef MANIPULATOR_STATE_INTERACTING_FROM
#undef MANIPULATOR_STATE_INTERACTING_TO
