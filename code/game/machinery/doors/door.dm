/obj/machinery/door
	name = "Door"
	desc = "It opens and closes."
	icon = 'icons/obj/doors/Doorint.dmi'
	icon_state = "door1"
	anchored = 1
	opacity = 1
	density = 1
	layer = DOOR_LAYER
	power_channel = STATIC_ENVIRON
	var/base_layer = DOOR_LAYER
	var/icon_state_open  = "door0"
	var/icon_state_close = "door1"

	var/secondsElectrified = 0
	var/visible = 1
	var/p_open = 0
	var/operating = 0
	var/autoclose = 0
	var/glass = 0
	var/normalspeed = 1
	var/heat_proof = 0 // For glass airlocks/opacity firedoors
	var/air_properties_vary_with_direction = 0
	var/block_air_zones = 1 //If set, air zones cannot merge across the door even when it is opened.
	var/emergency = 0 // Emergency access override

	var/door_open_sound  = 'sound/machines/airlock/toggle.ogg'
	var/door_close_sound = 'sound/machines/airlock/toggle.ogg'

	var/dock_tag

/obj/machinery/door/atom_init()
	. = ..()
	if(density)
		layer = base_layer + DOOR_CLOSED_MOD //Above most items if closed
		explosion_resistance = initial(explosion_resistance)
		update_heat_protection(get_turf(src))
	else
		layer = base_layer //Under all objects if opened. 2.7 due to tables being at 2.6
		explosion_resistance = 0

	update_nearby_tiles(need_rebuild=1)


/obj/machinery/door/Destroy()
	density = 0
	update_nearby_tiles()
	return ..()

//process()
	//return

/obj/machinery/door/Bumped(atom/AM)
	if(p_open || operating) return
	if(ismob(AM))
		var/mob/M = AM
		if(world.time - M.last_bumped <= 10) return	//Can bump-open one airlock per second. This is to prevent shock spam.
		M.last_bumped = world.time
		if(!M.restrained() && !M.small)
			bumpopen(M)
		return

	if(istype(AM, /obj/machinery/bot))
		var/obj/machinery/bot/bot = AM
		if(src.check_access(bot.botcard) || emergency)
			if(density)
				open()
		return

	if(istype(AM, /obj/mecha))
		var/obj/mecha/mecha = AM
		if(density)
			if(mecha.occupant && (src.allowed(mecha.occupant) || src.check_access_list(mecha.operation_req_access)) || emergency)
				open()
			else
				do_animate("deny")
		return

	if(istype(AM, /obj/structure/stool/bed/chair/wheelchair))
		var/obj/structure/stool/bed/chair/wheelchair/wheel = AM
		if(density)
			if((wheel.pulling && src.allowed(wheel.pulling)) || emergency)
				open()
			else
				do_animate("deny")
		return
	return


/obj/machinery/door/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group) return !block_air_zones
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return !opacity
	return !density


/obj/machinery/door/proc/bumpopen(mob/user)
	if(user.last_airflow > world.time - vsc.airflow_delay) //Fakkit
		return
	if(!density)
		return
	try_open(user)

/obj/machinery/door/proc/try_open(mob/user, obj/item/tool = null)
	if(operating)
		return

	add_fingerprint(user)

	if(ishuman(user) && prob(40) && density)
		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= 60)
			playsound(src, 'sound/effects/bang.ogg', VOL_EFFECTS_MASTER, 25)
			if(!istype(H.head, /obj/item/clothing/head/helmet))
				visible_message("<span class='userdanger'> [user] headbutts the [src].</span>")
				var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_HEAD]
				H.Stun(8)
				H.Weaken(5)
				BP.take_damage(10, 0, used_weapon = "Hematoma")
			else
				visible_message("<span class='userdanger'> [user] headbutts the [src]. Good thing they're wearing a helmet.</span>")
			return

	user.SetNextMove(CLICK_CD_INTERACT)
	var/atom/check_access = user

	if(!requiresID())
		check_access = null

	if(allowed(check_access) || emergency)
		if(density)
			open()
		else
			close()
		return

	if(density)
		do_animate("deny")

/obj/machinery/door/attack_hand(mob/user)
	try_open(user)

/obj/machinery/door/attack_tk(mob/user)
	if(requiresID() && !allowed(null))
		return
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

/obj/machinery/door/emag_act(mob/user)
	if(src.density && hasPower())
		update_icon(AIRLOCK_EMAG)
		sleep(6)
		if(!open())
			update_icon(AIRLOCK_CLOSED)
		operating = -1
		return TRUE
	return FALSE

/obj/machinery/door/blob_act()
	if(prob(40))
		qdel(src)
	return


/obj/machinery/door/emp_act(severity)
	if(prob(20/severity) && (istype(src,/obj/machinery/door/airlock) || istype(src,/obj/machinery/door/window)) )
		open()
	if(prob(40/severity))
		if(secondsElectrified == 0)
			secondsElectrified = -1
			spawn(300)
				secondsElectrified = 0
	..()


/obj/machinery/door/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if(prob(25))
				qdel(src)
		if(3.0)
			if(prob(80))
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(2, 1, src)
				s.start()
	return


/obj/machinery/door/update_icon()
	if(density)
		icon_state = icon_state_close
	else
		icon_state = icon_state_open


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

/obj/machinery/door/proc/close(forced = FALSE)
	if(density)
		return TRUE
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
	if(!operating && SSticker)
		if(!forced)
			return normal_close_checks()
		return TRUE
	return FALSE


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
	explosion_resistance = 0
	update_icon()
	update_nearby_tiles()

/obj/machinery/door/proc/do_close()
	playsound(src, door_close_sound, VOL_EFFECTS_MASTER)
	do_animate("closing")
	sleep(2)
	density = TRUE
	sleep(4)
	if(visible && !glass)
		set_opacity(TRUE)
	layer = base_layer + DOOR_CLOSED_MOD
	explosion_resistance = initial(explosion_resistance)
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

/obj/machinery/door/update_nearby_tiles(need_rebuild)
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
	door_open_sound  = 'sound/machines/shutter_open.ogg'
	door_close_sound = 'sound/machines/shutter_close.ogg'
