var/global/list/wedge_image_cache = list()

/obj/machinery/door
	name = "Door"
	desc = "It opens and closes."
	anchored = TRUE
	opacity = 1
	density = TRUE
	can_block_air = TRUE

	layer = DOOR_LAYER
	var/base_layer = DOOR_LAYER
	var/layer_delta = DOOR_CLOSED_MOD

	power_channel = STATIC_ENVIRON
	hud_possible = list(DIAG_AIRLOCK_HUD)
	var/icon_state_open  = "door0"
	var/icon_state_close = "door1"

	var/secondsElectrified = 0
	var/p_open = 0
	var/operating = 0
	var/autoclose = 0
	var/glass = 0 // glass doors are transparent when closed, also does something with door materials and icon
	var/always_transparent = FALSE // will make closed door always transpanert, regardless "glass" flag
	var/allow_passglass = TRUE // too many strange flags, future refactoring needed
	var/normalspeed = 1
	var/heat_proof = 0 // For glass airlocks/opacity firedoors
	var/air_properties_vary_with_direction = 0
	var/block_air_zones = 1 //If set, air zones cannot merge across the door even when it is opened.
	var/emergency = 0 // Emergency access override
	/// Unrestricted sides. A bitflag for which direction (if any) can open the door with no access
	var/unres_sides = NONE

	var/door_open_sound  = 'sound/machines/airlock/toggle.ogg'
	var/door_close_sound = 'sound/machines/airlock/toggle.ogg'

	var/dock_tag

	var/obj/item/wedged_item

	var/next_crush = 0

	var/can_wedge_items = TRUE
	var/wedging = FALSE

/obj/machinery/door/atom_init()
	. = ..()
	if(density)
		layer = base_layer + layer_delta //Above most items if closed
		explosive_resistance = initial(explosive_resistance)
		update_heat_protection(get_turf(src))
	else
		layer = base_layer //Under all objects if opened. 2.7 due to tables being at 2.6
		explosive_resistance = 0

	prepare_huds()
	var/datum/atom_hud/data/diagnostic/diag_hud = global.huds[DATA_HUD_DIAGNOSTIC]
	diag_hud.add_to_hud(src)
	diag_hud_set_electrified()

	update_nearby_tiles()


/obj/machinery/door/Destroy()
	density = FALSE
	update_nearby_tiles()
	var/datum/atom_hud/data/diagnostic/diag_hud = global.huds[DATA_HUD_DIAGNOSTIC]
	diag_hud.remove_from_hud(src)
	QDEL_NULL(wedged_item)
	return ..()

/obj/machinery/door/Bumped(atom/movable/AM)
	if(p_open || operating)
		return
	if(world.time - last_bumped <= 7)
		return //Can bump-open one airlock per animation. This is to prevent shock spam.
	last_bumped = world.time

	if(ismob(AM))
		var/mob/M = AM
		if(!M.restrained() && M.w_class >= SIZE_SMALL)
			bumpopen(M)
		return

	if(AM.w_class < SIZE_NORMAL) //Big item tries to open a door anyways
		if(!length(AM.GetAccess()) || check_access(null)) //Door that requires access and we have a card
			return
	try_open(AM)

/obj/machinery/door/AltClick(mob/user)
	if(user.incapacitated())
		return
	if(!Adjacent(user))
		return
	if(!user.IsAdvancedToolUser())
		return

	if(!wedged_item)
		if(!try_wedge_item(user))
			return ..()
	else
		take_out_wedged_item(user)

/obj/machinery/door/proc/generate_wedge_overlay()
	var/cache_string = "[wedged_item.icon]||[wedged_item.icon_state]||[wedged_item.overlays.len]||[wedged_item.underlays.len]"

	if(!global.wedge_image_cache[cache_string])
		var/image/I = image(wedged_item.icon, wedged_item.icon_state)
		I.appearance = wedged_item

		I.layer = layer
		I.plane = plane

		I.pixel_x = -4
		I.pixel_y = -15

		I.add_filter("half-cut", 1, alpha_mask_filter(icon=icon('icons/effects/cut.dmi', "cut_up")))

		global.wedge_image_cache[cache_string] = I
		underlays += I
	else
		underlays += global.wedge_image_cache[cache_string]

/obj/machinery/door/c_airblock(turf/other)
	if(block_air_zones)
		return ..() | ZONE_BLOCKED
	return ..()

/obj/machinery/door/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && allow_passglass && mover.checkpass(PASSGLASS))
		return !opacity
	return !density

/obj/machinery/door/proc/bumpopen(mob/user)
	if(!COOLDOWN_FINISHED(user, last_airflow)) //Fakkit
		return
	if(!density)
		return
	try_open(user)

/obj/machinery/door/proc/try_open(atom/movable/AM, obj/item/tool = null)
	if(operating)
		return

	if(ismob(AM))
		var/mob/user = AM
		add_fingerprint(user)

		if(ishuman(user) && prob(40) && density)
			var/mob/living/carbon/human/H = user
			if(H.getBrainLoss() >= 60)
				playsound(src, 'sound/effects/bang.ogg', VOL_EFFECTS_MASTER, 25)
				var/armor_block = H.run_armor_check(BP_HEAD, "melee")
				if(armor_block)
					visible_message("<span class='userdanger'> [user] headbutts the airlock.</span>")
				else
					visible_message("<span class='userdanger'> [user] headbutts the airlock. Good thing they're wearing a helmet.</span>")
				if(H.apply_damage(10, BRUTE, BP_HEAD, armor_block))
					H.Stun(2)
					H.Weaken(5)
				return

		user.SetNextMove(CLICK_CD_INTERACT)

	if(!requiresID() && !check_access(null))
		do_animate("deny")
		return

	if(allowed(AM))
		if(density)
			open()
		else
			close()
		return

	if(density)
		do_animate("deny")

/obj/machinery/door/allowed(atom/movable/M)
	if(emergency)
		return TRUE
	if(unrestricted_side(M))
		return TRUE
	return ..()

/obj/machinery/door/proc/unrestricted_side(atom/opener) //Allows for specific side of airlocks to be unrestrected (IE, can exit maint freely, but need access to enter)
	return get_dir(src, opener) & unres_sides

/obj/machinery/door/attack_hand(mob/user)
	if(user.a_intent == INTENT_GRAB && wedged_item && !user.get_active_hand())
		take_out_wedged_item(user)
		return

	try_open(user)

/obj/machinery/door/attack_tk(mob/user)
	if(requiresID() && !allowed(null))
		return FALSE

	..()

/obj/machinery/door/attack_ghost(mob/user)
	if(IsAdminGhost(user))
		if(density)
			open()
		else
			close()

/obj/machinery/door/attackby(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/device/detective_scanner))
		return
	if(src.operating)
		return
	if(src.density && hasPower() && istype(I, /obj/item/weapon/melee/energy/blade))
		update_icon(AIRLOCK_EMAG)
		sleep(6)
		if(!open())
			update_icon(AIRLOCK_CLOSED)
		operating = -1
		return 1
	if(isrobot(user))
		return //borgs can't attack doors open because it conflicts with their AI-like interaction with them.
	add_fingerprint(user)
	try_open(user, I)

/obj/machinery/door/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(glass)
				playsound(loc, 'sound/effects/glasshit.ogg', VOL_EFFECTS_MASTER, 90, TRUE)
			else if(damage_amount)
				playsound(loc, 'sound/weapons/smash.ogg', VOL_EFFECTS_MASTER, 50, TRUE)
			else
				playsound(loc, 'sound/weapons/tap.ogg', VOL_EFFECTS_MASTER, 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER, 100, TRUE)


/obj/machinery/door/emag_act(mob/user)
	if(density && hasPower() && !wedged_item)
		update_icon(AIRLOCK_EMAG)
		sleep(6)
		if(!open())
			update_icon(AIRLOCK_CLOSED)
		operating = -1
		return TRUE
	if(!hasPower())
		to_chat(user, "<span class='warning'>You can't use a emag on a non-powered airlock.</span>")
	else if(wedged_item)
		to_chat(user, "<span class='warning'>Why would you waste your time hacking a non-blocking airlock?</span>")
	return FALSE

/obj/machinery/door/ex_act(severity)
	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(75))
				return
		if(EXPLODE_LIGHT)
			if(prob(80))
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(2, 1, src)
				s.start()
				return
	qdel(src)


/obj/machinery/door/update_icon()
	if(density)
		icon_state = icon_state_close
	else
		icon_state = icon_state_open

	if(underlays.len)
		underlays.Cut()

	if(wedged_item)
		generate_wedge_overlay()

/obj/machinery/door/MouseDrop(obj/over_object)
	if(usr.IsAdvancedToolUser() && usr == over_object && !usr.incapacitated() && Adjacent(usr))
		take_out_wedged_item(usr)
		return

	return ..()

/obj/machinery/door/examine(mob/user)
	. = ..()
	if(wedged_item)
		to_chat(user, "You can see [bicon(wedged_item)] [wedged_item] wedged into it.")

/obj/machinery/door/proc/do_animate(animation)
	switch(animation)
		if("opening")
			if(p_open)
				flick("o_doorc0", src)
			else
				flick("doorc0", src)
		if("closing")
			if(p_open)
				flick("o_doorc1", src)
			else
				flick("doorc1", src)
		if("deny")
			flick("door_deny", src)
	return


/**
 * Call this proc, if you want to open the door.
 *
 * Use `forced` param, if you want to open the door with
 * ignoring of `normal_open_checks()` conditions.
 *
 * Same for `close()`.
 */

/obj/machinery/door/proc/open(forced = FALSE)
	if(!density)
		return TRUE
	if(open_checks(forced))
		set_operating(TRUE)
		do_open()
		set_operating(FALSE)
		return TRUE
	return FALSE

/obj/machinery/door/proc/finish_crush_wedge_animation()
	density = FALSE
	do_animate("opening")
	operating = FALSE
	wedging = FALSE
	update_icon()

/obj/machinery/door/proc/crush_wedge_animation(obj/item/I)
	do_animate("closing")
	sleep(7)
	if(QDELETED(src))
		return
	if(QDELETED(I))
		finish_crush_wedge_animation()
		return
	if(I.loc != loc)
		finish_crush_wedge_animation()
		return
	force_wedge_item(I)
	playsound(src, 'sound/machines/airlock/creaking.ogg', VOL_EFFECTS_MASTER, rand(40, 70), TRUE)
	//shake_animation(12, 7, move_mult = 0.4, angle_mult = 1.0)
	sleep(7)
	if(QDELETED(src))
		return
	finish_crush_wedge_animation()

/obj/machinery/door/proc/close(forced = FALSE)
	if(density)
		return TRUE

	if(!wedging && !wedged_item && can_wedge_items)
		for(var/turf/turf in locs)
			for(var/obj/item/I in turf)
				if(I.w_class < SIZE_SMALL)
					continue
				if(isprying(I) <= 0.0)
					continue

				operating = TRUE
				density = TRUE
				wedging = TRUE

				INVOKE_ASYNC(src, PROC_REF(crush_wedge_animation), I)
				return

	if(close_checks(forced))
		set_operating(TRUE)
		do_close()
		set_operating(FALSE)
		return TRUE
	return FALSE


/**
 * DO NOT CALL THIS PROC DIRECTLY!!!
 *
 * Checks for base level conditions for door opening.
 *
 * If you want more conditions you can re-implement it in subtypes like that:
 * > /obj/machinery/door/.../open_checks()
 * >   if(..() && `more conditions`)
 * >     return TRUE
 * >   return FALSE
 * or in another way, but with TRUE or FALSE returning.
 *
 * Same for `close_checks()`.
 */

/obj/machinery/door/proc/open_checks(forced)
	if(!operating && SSticker)
		if(!forced)
			return normal_open_checks()
		return TRUE
	return FALSE

/obj/machinery/door/proc/close_checks(forced)
	if(wedged_item)
		// we can't have nice things because somebody really wanted to do some bullshit
		// where instead of flicking() an opening/closing animation we instead set icon_state
		// to a non-looping animation which ends on a open/closed sprite, which of course
		// when you in any way update the icon_state/invisibility for the airlock
		// causes the animation to play again, which shake_animation used
		// so we can't both have this thingy and the nice animation and I don't have the strength
		// to replace this with flick-s() ~Luduk
		//shake_animation(12, 7, move_mult = 0.4, angle_mult = 1.0)
		if(next_crush < world.time)
			visible_message("<span class='warning'>[src] crushed \the [wedged_item] wedged into it, but is not able to close</span>")
			wedged_item.airlock_crush_act(DOOR_CRUSH_DAMAGE)
			next_crush = world.time + 1 SECOND
		return FALSE

	if(!operating && SSticker)
		if(!forced)
			return normal_close_checks()
		return TRUE
	return FALSE

/obj/machinery/door/proc/on_wedge_destroy()
	UnregisterSignal(wedged_item, list(COMSIG_PARENT_QDELETING))
	wedged_item = null
	update_icon()

/obj/machinery/door/proc/force_wedge_item(obj/item/I)
	I.forceMove(src)
	wedged_item = I
	update_icon()
	RegisterSignal(I, list(COMSIG_PARENT_QDELETING), PROC_REF(on_wedge_destroy))

/obj/machinery/door/proc/try_wedge_item(mob/living/user)
	if(!can_wedge_items)
		return FALSE

	var/obj/item/I = user.get_active_hand()
	if(!istype(I))
		return FALSE

	if(I.w_class < SIZE_SMALL)
		return FALSE

	if(isprying(I) <= 0.0)
		return FALSE

	if(density)
		to_chat(user, "<span class='notice'>[I] can't be wedged into [src], while [src] is closed.</span>")
		return FALSE

	if(!user.drop_from_inventory(I))
		return FALSE

	force_wedge_item(I)
	to_chat(user, "<span class='notice'>You wedge [I] into [src].</span>")
	return TRUE

/obj/machinery/door/proc/take_out_wedged_item(mob/living/user)
	if(!wedged_item)
		return

	if(wedging)
		if(user)
			to_chat(user, "<span class='notice'>It would be too dangerous to try taking out a [wedged_item] while it's being chewed up by [src].</span>")
		return

	// If some stats are added should check for agility/strength.
	if(user && !wedged_item.use_tool(src, user, 5, quality=QUALITY_PRYING))
		return
	wedged_item.forceMove(loc)
	if(user)
		user.put_in_hands(wedged_item)
		to_chat(user, "<span class='notice'>You took [wedged_item] out of [src].</span>")

	UnregisterSignal(wedged_item, list(COMSIG_PARENT_QDELETING))
	wedged_item = null
	update_icon()

/**
 * DO NOT CALL THIS PROC DIRECTLY!!!
 *
 * Checks for additional level conditions for door opening.
 * Proc will be ignored if door was forced.
 *
 * If you want more conditions you can re-implement it in subtypes like that:
 * > /obj/machinery/door/.../normal_open_checks()
 * >   if(`condition one` && `condition two`)
 * >     return TRUE
 * >   return FALSE
 * or in another way, but with TRUE or FALSE returning.
 *
 * Same for `normal_close_checks()`.
 */

/obj/machinery/door/proc/normal_open_checks()
	return TRUE

/obj/machinery/door/proc/normal_close_checks()
	return TRUE


/**
 * DO NOT CALL THIS PROC DIRECTLY!!!
 *
 * Actually the process of opening the door.
 * Re-implement it in subtypes if you want another behavior.
 *
 * Same for `do_close()`.
 */

/obj/machinery/door/proc/do_open()
	playsound(src, door_open_sound, VOL_EFFECTS_MASTER)
	do_animate("opening")
	sleep(2)
	set_opacity(FALSE)
	density = FALSE
	sleep(4)
	layer = base_layer
	explosive_resistance = 0
	update_icon()
	update_nearby_tiles()

/obj/machinery/door/proc/do_close()
	layer = base_layer + layer_delta
	playsound(src, door_close_sound, VOL_EFFECTS_MASTER)
	do_animate("closing")
	sleep(2)
	density = TRUE
	sleep(4)
	if(!always_transparent && !glass)
		set_opacity(TRUE)
	explosive_resistance = initial(explosive_resistance)
	do_afterclose()
	update_icon()
	update_nearby_tiles()


/**
 * DO NOT CALL THIS PROC DIRECTLY!!!
 *
 * Helps to add additional behavior for closing.
 */

/obj/machinery/door/proc/do_afterclose()
	//I shall not add a check every x ticks if a door has closed over some fire.
	var/obj/fire/fire = locate() in locs
	if(fire)
		qdel(fire)

/obj/machinery/door/proc/set_operating(operating)
	if(operating && !src.operating)
		src.operating = TRUE
	else if(!operating && src.operating == 1)
		src.operating = FALSE


/obj/machinery/door/proc/requiresID()
	return 1

/obj/machinery/door/update_nearby_tiles()
	. = ..()

	if(.)
		for(var/turf/simulated/turf in locs)
			update_heat_protection(turf)

/obj/machinery/door/proc/update_heat_protection(turf/simulated/source)
	if(istype(source))
		if(src.density && (src.opacity || src.heat_proof))
			source.thermal_conductivity = DOOR_HEAT_TRANSFER_COEFFICIENT
		else
			source.thermal_conductivity = initial(source.thermal_conductivity)

/obj/machinery/door/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()
	update_nearby_tiles()

/obj/machinery/door/proc/hasPower()
	return !(stat & NOPOWER)

/obj/machinery/door/morgue
	icon = 'icons/obj/doors/doormorgue.dmi'
	icon_state = "door1"
	door_open_sound  = 'sound/machines/shutter_open.ogg'
	door_close_sound = 'sound/machines/shutter_close.ogg'
