/*
CONTAINS:
RCD
*/
/obj/item/weapon/rcd
	name = "rapid-construction-device (RCD)"
	desc = "A device used to rapidly build walls/floor."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	opacity = 0
	density = FALSE
	anchored = FALSE
	flags = CONDUCT
	force = 10.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = SIZE_SMALL
	m_amt = 50000
	origin_tech = "engineering=4;materials=2"
	var/datum/effect/effect/system/spark_spread/spark_system
	var/matter = 0
	var/working = 0
	var/mode = 1
	var/canRwall = 0
	var/disabled = 0
	var/image/RCD_deconstruct_effect    // RCD overlay for targets
	var/image/RCD_build_effect
	action_button_name = "Switch RCD"


/obj/item/weapon/rcd/atom_init()
	. = ..()
	rcd_list += src
	desc = "A RCD. It currently holds [matter]/30 matter-units."
	spark_system = new /datum/effect/effect/system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	RCD_deconstruct_effect = image('icons/effects/effects.dmi', "disappear")
	RCD_deconstruct_effect.plane = ABOVE_LIGHTING_PLANE
	RCD_build_effect = image('icons/effects/effects.dmi', "appear")
	RCD_build_effect.plane = ABOVE_LIGHTING_PLANE

/obj/item/weapon/rcd/Destroy()
	rcd_list -= src
	qdel(spark_system)
	spark_system = null
	return ..()

/obj/item/weapon/rcd/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/rcd_ammo))
		if((matter + 10) > 30)
			to_chat(user, "<span class='notice'>The RCD cant hold any more matter-units.</span>")
			return
		qdel(I)
		matter += 10
		playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>The RCD now holds [matter]/30 matter-units.</span>")
		desc = "A RCD. It currently holds [matter]/30 matter-units."

	else
		return ..()

/obj/item/weapon/rcd/attack_self(mob/user)
	//Change the mode
	playsound(src, 'sound/effects/pop.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	switch(mode)
		if(1)
			mode = 2
			to_chat(user, "<span class='notice'>Changed mode to 'Airlock'</span>")
			if(prob(20))
				spark_system.start()
			return
		if(2)
			mode = 3
			to_chat(user, "<span class='notice'>Changed mode to 'Emergency Shutter'</span>")
			if(prob(20))
				spark_system.start()
			return
		if(3)
			mode = 4
			to_chat(user, "<span class='notice'>Changed mode to 'Deconstruct'</span>")
			if(prob(20))
				spark_system.start()
			return
		if(4)
			mode = 1
			to_chat(user, "<span class='notice'>Changed mode to 'Floor & Walls'</span>")
			if(prob(20))
				spark_system.start()
/*
/obj/item/weapon/rcd/use_tool(atom/target, mob/living/user, delay, amount = 0, volume = 0, act = 0,quality = null, datum/callback/extra_checks = null)
	if(act == 1)		//building
		target.add_overlay(RCD_build_effect)
		INVOKE_ASYNC(src, .proc/start_welding, target)
		var/datum/callback/checks  = CALLBACK(src, .proc/check_active_and_extra, extra_checks)
		. = ..(target, user, delay, amount, volume, extra_checks = checks)
		stop_welding()
		target.cut_overlay(RCD_build_effect)

	if(act == 2)		/deconstructing
		target.add_overlay(RCD_deconstruct_effect)
		INVOKE_ASYNC(src, .proc/start_welding, target)
		var/datum/callback/checks  = CALLBACK(src, .proc/check_active_and_extra, extra_checks)
		. = ..(target, user, delay, amount, volume, extra_checks = checks)
		stop_welding()
		target.cut_overlay(RCD_deconstruct_effect)
*/
/obj/item/weapon/rcd/proc/activate()
	playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)


/obj/item/weapon/rcd/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(disabled && !isrobot(user))
		return 0
	if(istype(target, /area/shuttle))
		return 0
	if(!(istype(target, /turf) || istype(target, /obj/machinery/door/airlock) || istype(target, /obj/machinery/door/firedoor) || istype(target, /obj/structure/window) || istype(target, /obj/machinery/door/window)))
		return 0
	if(istype(target, ))
		return 0

	switch(mode)
		if(1)
			if(isenvironmentturf(target))
				var/turf/T = target
				if(useResource(1, user))
					to_chat(user, "Building Floor...")
					activate()
					T.ChangeTurf(/turf/simulated/floor/plating/airless)
					return 1
				return 0

			if(istype(target, /turf/simulated/floor))
				for(var/atom/AT in target)
					if(AT.density)
						to_chat(user, "<span class='warning'>You can't build wall here.</span>")
						return 0
				var/turf/simulated/floor/F = target
				if(checkResource(3, user))
					to_chat(user, "Building Wall ...")
					playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
					if(do_after(user, 20, target = F))
						if(!useResource(3, user))
							return 0
						activate()
						F.ChangeTurf(/turf/simulated/wall)
						return 1
				return 0

		if(2)
			if(istype(target, /turf/simulated/floor))
				for(var/atom/AT in target)
					if(AT.density || (istype(AT, /obj/machinery/door) && !istype(AT, /obj/machinery/door/firedoor)) || istype(AT, /obj/structure/mineral_door))
						to_chat(user, "<span class='warning'>You can't build airlock here.</span>")
						return 0
				if(checkResource(10, user) && !user.is_busy())
					to_chat(user, "Building Airlock...")
					playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
					if(do_after(user, 50, target = target))
						if(!useResource(10, user))
							return 0
						activate()
						new /obj/machinery/door/airlock(target)
						return 1
					return 0
				return 0

		if(3)
			if(istype(target, /turf/simulated/floor))
				for(var/atom/AT in target)
					if(AT.density || istype(AT, /obj/machinery/door/firedoor))
						to_chat(user, "<span class='warning'>You can't build emergency shutter here.</span>")
						return 0
				if(checkResource(10, user) && !user.is_busy())
					to_chat(user, "Building Emergency Shutter...")
					playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
					if(do_after(user, 50, target = target))
						if(!useResource(10, user))
							return 0
						activate()
						new /obj/machinery/door/firedoor(target)
						return 1
					return 0
				return 0

		if(4)
			if(istype(target, /turf/simulated/wall))
				var/turf/simulated/wall/W = target
				if(istype(W, /turf/simulated/wall/r_wall) && !canRwall)
					return 0
				if(checkResource(5, user) && !user.is_busy())
					to_chat(user, "Deconstructing Wall...")
					playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
					if(do_after(user, 40, target = W))
						if(!useResource(5, user))
							return 0
						activate()
						W.ChangeTurf(/turf/simulated/floor/plating/airless)
						return 1
				return 0

			if(istype(target, /obj/structure/window))
				if(checkResource(10, user))
					to_chat(user, "Deconstructing Window...")
					playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
					if(do_after(user, 50, target = target))
						if(!useResource(10, user))
							return 0
						activate()
						qdel(target)
						return 1
				return 0

			if(istype(target, /obj/machinery/door/window))
				if(checkResource(10, user))
					to_chat(user, "Deconstructing Interior Door...")
					playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
					if(do_after(user, 50, target = target))
						if(!useResource(10, user))
							return 0
						activate()
						qdel(target)
						return 1
				return 0

			if(istype(target, /turf/simulated/floor))
				var/turf/simulated/floor/F = target
				if(checkResource(5, user) && !user.is_busy())
					to_chat(user, "Deconstructing Floor...")
					playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
					if(do_after(user, 50, target = F))
						if(!useResource(5, user))
							return 0
						activate()
						F.BreakToBase()
						return 1
				return 0

			if(istype(target, /obj/machinery/door/airlock) || istype(target, /obj/machinery/door/firedoor))
				if(checkResource(10, user))
					to_chat(user, "Deconstructing Airlock...")
					playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
					if(do_after(user, 50, target = target))
						if(!useResource(10, user))
							return 0
						activate()
						qdel(target)
						return 1
				return 0
			return 0
		else
			to_chat(user, "ERROR: RCD in MODE: [mode] attempted use by [user]. Send this text #coderbus or an admin.")
			return 0

/obj/item/weapon/rcd/proc/useResource(amount, mob/user)
	if(matter < amount)
		return 0
	matter -= amount
	desc = "A RCD. It currently holds [matter]/30 matter-units."
	return 1

/obj/item/weapon/rcd/proc/checkResource(amount, mob/user)
	return matter >= amount
/obj/item/weapon/rcd/borg/useResource(amount, mob/user)
	if(!isrobot(user))
		return 0
	return user:cell:use(amount * 30)

/obj/item/weapon/rcd/borg/checkResource(amount, mob/user)
	if(!isrobot(user))
		return 0
	return user:cell:charge >= (amount * 30)

/obj/item/weapon/rcd/borg/atom_init()
	. = ..()
	desc = "A device used to rapidly build walls/floor."
	canRwall = 1

/obj/item/weapon/rcd_ammo
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for the RCD."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	opacity = 0
	density = FALSE
	anchored = FALSE
	origin_tech = "materials=2"
	m_amt = 30000
	g_amt = 15000
