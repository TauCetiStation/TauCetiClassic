/obj/machinery/door
	name = "Door"
	desc = "It opens and closes."
	icon = 'icons/obj/doors/Doorint.dmi'
	icon_state = "door1"
	anchored = 1
	opacity = 1
	density = 1
	layer = DOOR_LAYER
	power_channel = ENVIRON
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

	var/door_open_sound  = 'sound/machines/airlock/airlockToggle_2.ogg'
	var/door_close_sound = 'sound/machines/airlock/airlockToggle_2.ogg'

/obj/machinery/door/New()
	. = ..()
	if(density)
		layer = base_layer + DOOR_CLOSED_MOD //Above most items if closed
		explosion_resistance = initial(explosion_resistance)
		update_heat_protection(get_turf(src))
	else
		layer = base_layer //Under all objects if opened. 2.7 due to tables being at 2.6
		explosion_resistance = 0

	update_nearby_tiles(need_rebuild=1)
	return


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
	if(operating)	return
	if(user.last_airflow > world.time - vsc.airflow_delay) //Fakkit
		return
	src.add_fingerprint(user)
	if(!src.requiresID())
		user = null

	if(density)
		if(allowed(user) || emergency)
			open()
		else
			do_animate("deny")
	return

/obj/machinery/door/meteorhit(obj/M)
	src.open()
	return


/obj/machinery/door/attack_ai(mob/user)
	return src.attack_hand(user)


/obj/machinery/door/attack_paw(mob/user)
	return src.attack_hand(user)


/obj/machinery/door/attack_hand(mob/user)
	return src.attackby(user, user)

/obj/machinery/door/attack_tk(mob/user)
	if(requiresID() && !allowed(null))
		return
	..()

/obj/machinery/door/attackby(obj/item/I, mob/user)
	if(HULK in user.mutations) //#Z2 Hulk can open any door with his power and break any door with harm intent.
		if(!src.density) return
		var/cur_loc = user.loc
		var/cur_dir
		var/found = 0
		for(var/direction in cardinal)
			var/turf/T = get_step(src,direction)
			for(var/mob/living/carbon/human/H in T.contents)
				if(H == user)
					found = 1
					break
			if(found)
				break
		if(!found) return
		if(I != user)
			to_chat(user, "\red You can't force open door with [I] in hand!")
			return
		var/obj/machinery/door/airlock/A = src
		if(istype(A,/obj/machinery/door/airlock/))
			if(user.a_intent == "hurt")
				if(prob(90))
					user.visible_message("\red <B>[user]</B> has punched \the <B>[src]!</B>",\
					"You punch \the [src]!",\
					"\red You feel some weird vibration!")
					playsound(user.loc, 'sound/effects/grillehit.ogg', 50, 1)
					return
				else
					user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
					user.visible_message("\red <B>[user]</B> has destroyed some mechanic in \the <B>[src]!</B>",\
					"You destroy some mechanic in \the [src] door, which holds it in place!",\
					"\red <B>You feel some weird vibration!</B>")
					playsound(user.loc, pick('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg'), 50, 1)
					if(istype(A,/obj/machinery/door/airlock/multi_tile/)) //Some kind runtime with multi_tile airlock... So delete for now... #Z2
						qdel(A)
					else
						var/obj/structure/door_assembly/da = new A.assembly_type(A.loc)
						da.anchored = 0

						var/target = da.loc
						cur_dir = user.dir
						for(var/i=0, i<4, i++)
							target = get_turf(get_step(target,cur_dir))
						da.throw_at(target, 200, 100)

						if(A.mineral)
							da.change_mineral_airlock_type(A.mineral)
						if(A.glass && da.can_insert_glass)
							da.set_glass(TRUE)
						da.state = ASSEMBLY_WIRED
						da.created_name = src.name
						da.update_state()

						var/obj/item/weapon/airlock_electronics/ae
						ae = new/obj/item/weapon/airlock_electronics( A.loc )
						if(!A.req_access)
							A.check_access()
						if(A.req_access.len)
							ae.conf_access = A.req_access
						else if (A.req_one_access.len)
							ae.conf_access = A.req_one_access
							ae.one_access = 1
						ae.loc = da
						da.electronics = ae

						qdel(A)
					return
			else if(A.locked && user.a_intent != "hurt")
				to_chat(user, "\red The door is bolted and you need more aggressive force to get thru!")
				return
		user.visible_message("\red \The [user] starts to force \the [src] open with a bare hands!",\
				"You start forcing \the [src] open with a bare hands!",\
				"You hear metal strain.")
		if(do_after(user, 30, target = src))
			found = 0
			for(var/direction in cardinal)
				var/turf/T = get_step(src,direction)
				for(var/mob/living/carbon/human/H in T.contents)
					if(H == user)
						found = 1
						if(direction == 1)
							cur_dir = 2
						else if(direction == 2)
							cur_dir = 1
						else if(direction == 4)
							cur_dir = 8
						else if(direction == 8)
							cur_dir = 4
						break
				if(found)
					break
			if(!found) return
			if(!src.density) return
			if(cur_loc != user.loc) return
			spawn(0)
				user.canmove = 0
				user.density = 0
				var/target = user.loc
				open()
				user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
				var/turf/simulated/floor/tile = target
				if(tile)
					tile.break_tile()
				for(var/i=0, i<2, i++)
					target = get_turf(get_step(target,cur_dir))
				playsound(user.loc, 'sound/weapons/thudswoosh.ogg', 50, 1)
				user.throw_at(target, 200, 100)
				user.visible_message("\red \The [user] forces \the [src] open with a bare hands!",\
						"You force \the [src] open with a bare hands!",\
						"You hear metal strain, and a door open.")
				user.canmove = 1
				user.density = 1
				close()
		return //##Z2
	if(istype(I, /obj/item/device/detective_scanner))
		return
	if(src.operating || isrobot(user))	return //borgs can't attack doors open because it conflicts with their AI-like interaction with them.
	src.add_fingerprint(user)
	if(!Adjacent(user))
		user = null
	if(!src.requiresID())
		user = null
	if(src.density && hasPower() && (istype(I, /obj/item/weapon/card/emag)||istype(I, /obj/item/weapon/melee/energy/blade)))
		update_icon(AIRLOCK_EMAG)
		sleep(6)
		if(!open())
			update_icon(AIRLOCK_CLOSED)
		operating = -1
		return 1
	if(src.allowed(user))
		if(src.density)
			open()
		else
			close()
		return
	if(src.density)
		do_animate("deny")
	return


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
	if(!operating && ticker)
		if(!forced)
			return normal_open_checks()
		return TRUE
	return FALSE

/obj/machinery/door/proc/close_checks(forced)
	if(!operating && ticker)
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
	playsound(src, door_open_sound, 100, 1)
	do_animate("opening")
	sleep(3)
	set_opacity(FALSE)
	density = FALSE
	sleep(9)
	layer = base_layer
	explosion_resistance = 0
	update_icon()
	update_nearby_tiles()

/obj/machinery/door/proc/do_close()
	playsound(src, door_close_sound, 100, 1)
	do_animate("closing")
	sleep(3)
	density = TRUE
	sleep(9)
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

/obj/machinery/door/proc/update_nearby_tiles(need_rebuild)
	if(!SSair)
		return 0

	for(var/turf/simulated/turf in locs)
		update_heat_protection(turf)
		SSair.mark_for_update(turf)

	return 1

/obj/machinery/door/proc/update_heat_protection(turf/simulated/source)
	if(istype(source))
		if(src.density && (src.opacity || src.heat_proof))
			source.thermal_conductivity = DOOR_HEAT_TRANSFER_COEFFICIENT
		else
			source.thermal_conductivity = initial(source.thermal_conductivity)

/obj/machinery/door/Move(new_loc, new_dir)
	..()
	update_nearby_tiles()

/obj/machinery/door/proc/hasPower()
	return !(stat & NOPOWER)

/obj/machinery/door/morgue
	icon = 'icons/obj/doors/doormorgue.dmi'
	door_open_sound  = 'sound/machines/shutter_open.ogg'
	door_close_sound = 'sound/machines/shutter_close.ogg'
