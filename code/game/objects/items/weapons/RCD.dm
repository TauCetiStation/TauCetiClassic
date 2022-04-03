/*
CONTAINS:
RCD
*/

/obj/item/weapon/rcd
	name = "rapid-construction-device (RCD)"
	desc = "A device used to rapidly build walls/floor."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	opacity = FALSE
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
	var/matter = 30
	var/max_matter = 30
	var/working = FALSE
	var/mode = 1
	var/canRwall = FALSE
	var/disabled = FALSE
	var/static/list/selection_modes
	var/static/list/selection_doors

	action_button_name = "Switch RCD"

/obj/item/weapon/rcd/atom_init()
	. = ..()
	rcd_list += src
	desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
	spark_system = new /datum/effect/effect/system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/weapon/rcd/Destroy()
	rcd_list -= src
	qdel(spark_system)
	spark_system = null
	return ..()

/obj/item/weapon/rcd/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/rcd_ammo))
		var/obj/item/weapon/rcd_ammo/A = I
		if((matter + A.matter) > max_matter)
			to_chat(user, "<span class='notice'>The RCD cant hold any more matter-units.</span>")
			return
		qdel(I)
		matter += A.matter
		playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>The RCD now holds [matter]/[max_matter] matter-units.</span>")
		desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."

	else
		return ..()

/obj/item/weapon/rcd/proc/can_use(atom/target, mob/living/user)
	if(disabled && !isrobot(user))
		return FALSE
	if(istype(target, /area/shuttle))
		return FALSE
	if(user.is_busy())
		return FALSE
	if(!(istype(target, /turf) || istype(target, /obj/machinery/door/airlock) || istype(target, /obj/machinery/door/firedoor) || istype(target, /obj/structure/window) || istype(target, /obj/machinery/door/window)))
		return FALSE
	return TRUE

/obj/item/weapon/rcd/proc/populate_selection()
	selection_modes = list(
	"Floor & Walls" = image(icon = 'icons/turf/walls/has_false_walls/wall.dmi', icon_state = "box_plating"),
	"Airlock" = image(icon = 'icons/obj/doors/airlocks/station/public.dmi', icon_state = "closed_filled_glassed_hazarded"),
	"Deconstruct" = image(icon = 'icons/obj/decals.dmi', icon_state = "blast")
	)
	selection_doors = list(
	"Solid Airlock" = image(icon = 'icons/obj/doors/airlocks/station/public.dmi', icon_state = "closed_filled"),
	"Glass Airlock" = image(icon = 'icons/obj/doors/airlocks/station2/glass.dmi', icon_state = "closed_small"),
	"Emergency Shutter" = image(icon = 'icons/obj/doors/DoorHazard.dmi', icon_state = "door_closed_small")
	)

/obj/item/weapon/rcd/attack_self(mob/user)	//Change the mode
	if(!selection_modes)
		populate_selection()
	var/selection_m = show_radial_menu(user, src, selection_modes, require_near = TRUE, tooltips = TRUE)
	switch(selection_m)
		if("Cancel")
			return
		if("Floor & Walls")
			mode = 1
			to_chat(user, "<span class='notice'>Changed mode to 'Floor & Walls'</span>")
		if("Airlock")
			var/selection_d = show_radial_menu(user, src, selection_doors, require_near = TRUE, tooltips = TRUE)
			switch(selection_d)
				if("Cancel")
					return
				if("Solid Airlock")
					mode = 2
					to_chat(user, "<span class='notice'>Changed mode to 'Solid Airlock'</span>")
				if("Glass Airlock")
					mode = 3
					to_chat(user, "<span class='notice'>Changed mode to 'Glass Airlock'</span>")
				if("Emergency Shutter")
					mode = 4
					to_chat(user, "<span class='notice'>Changed mode to 'Emergency Shutter'</span>")
		if("Deconstruct")
			mode = 5
			to_chat(user, "<span class='notice'>Changed mode to 'Deconstruct'</span>")

	playsound(src, 'sound/effects/pop.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	if(prob(20))
		spark_system.start()

/obj/item/weapon/rcd/proc/activate()
	playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)

/obj/item/weapon/rcd/afterattack(atom/target, mob/living/user, proximity, params)
	if(!proximity)
		return FALSE
	if(!can_use(target, user))
		return FALSE
	var/delay = 50

//deconstructing
	if(mode == 5)
		if(checkResource(5, user))
			if(istype(target, /turf/simulated/wall))
				if(istype(target, /turf/simulated/wall/r_wall) && !canRwall)
					return FALSE
				delay = 40

			to_chat(user, "Deconstructing [target.name]...")
			var/obj/effect/constructing_effect/rcd_effect = new(get_turf(target), delay, src.mode)
			rcd_effect.update_icon_state()
			playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
			if(do_after(user, delay, target = target))
				if(!useResource(5, user))
					qdel(rcd_effect)
					return FALSE
				activate()
				rcd_effect.end_animation()
				if(istype(target, /turf/simulated/wall))
					var/turf/simulated/wall/W = target
					W.ChangeTurf(/turf/simulated/floor/plating/airless)
				else if(istype(target, /turf/simulated/floor))
					var/turf/simulated/floor/F = target
					F.BreakToBase()
				else
					qdel(target)
				return TRUE
			qdel(rcd_effect)
		return FALSE

//turf building
	else if(mode == 1)
		if(isenvironmentturf(target))
			if(!checkResource(1, user))
				return FALSE
			delay = 0
		if(istype(target, /turf/simulated/floor))
			if(!checkResource(3, user))
				return FALSE
			for(var/atom/AT in target)
				if(AT.density)
					to_chat(user, "<span class='warning'>You can't build wall here.</span>")
					return FALSE
			delay = 20

		if(isenvironmentturf(target))
			to_chat(user, "Building Floor...")
		else
			to_chat(user, "Building Wall...")
		var/obj/effect/constructing_effect/rcd_effect = new(get_turf(target), delay, src.mode)
		rcd_effect.update_icon_state()
		playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
		if(do_after(user, delay, target = target))
			if(isenvironmentturf(target))
				if(!useResource(1, user))
					qdel(rcd_effect)
					return FALSE
			else
				if(!useResource(3, user))
					qdel(rcd_effect)
					return FALSE
			activate()
			rcd_effect.end_animation()
			if(isenvironmentturf(target))
				var/turf/T = target
				T.ChangeTurf(/turf/simulated/floor/plating/airless)
			else if(istype(target, /turf/simulated/floor))
				var/turf/simulated/floor/F = target
				F.ChangeTurf(/turf/simulated/wall)
			return TRUE
		qdel(rcd_effect)
		return FALSE

//airlock building
	else
		if(istype(target, /turf/simulated/floor))
			if(mode == 4)
				for(var/atom/AT in target)
					if(AT.density || istype(AT, /obj/machinery/door/firedoor))
						to_chat(user, "<span class='warning'>You can't build emergency shutter here.</span>")
						return FALSE
				if(!checkResource(5, user))
					return FALSE
			else
				for(var/atom/AT in target)
					if(AT.density || (istype(AT, /obj/machinery/door) && !istype(AT, /obj/machinery/door/firedoor)) || istype(AT, /obj/structure/mineral_door))
						if(mode == 2)
							to_chat(user, "<span class='warning'>You can't build airlock here.</span>")
						else
							to_chat(user, "<span class='warning'>You can't build glass airlock here.</span>")
						return FALSE
				if(!checkResource(10, user))
					return FALSE

			if(mode == 2)
				to_chat(user, "Building Airlock...")
			else if(mode == 3)
				to_chat(user, "Building Glass Airlock...")
			else
				to_chat(user, "Building Emergency Shutter...")
			var/obj/effect/constructing_effect/rcd_effect = new(get_turf(target), delay, src.mode)
			rcd_effect.update_icon_state()
			playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
			if(do_after(user, delay, target = target))
				switch(mode)
					if(2)
						if(!useResource(10, user))
							qdel(rcd_effect)
							return FALSE
						new /obj/machinery/door/airlock(target)
					if(3)
						if(!useResource(10, user))
							qdel(rcd_effect)
							return FALSE
						new /obj/machinery/door/airlock/glass(target)
					if(4)
						if(!useResource(5, user))
							qdel(rcd_effect)
							return FALSE
						new /obj/machinery/door/firedoor(target)
				activate()
				rcd_effect.end_animation()
				return TRUE
			qdel(rcd_effect)
	return FALSE

/obj/item/weapon/rcd/proc/useResource(amount, mob/user)
	if(matter < amount)
		return FALSE
	matter -= amount
	desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
	return TRUE

/obj/item/weapon/rcd/proc/checkResource(amount, mob/user)
	return matter >= amount

/obj/item/weapon/rcd/borg/useResource(amount, mob/user)
	if(!isrobot(user))
		return FALSE
	return user:cell:use(amount * 30)

/obj/item/weapon/rcd/borg/checkResource(amount, mob/user)
	if(!isrobot(user))
		return FALSE
	return user:cell:charge >= (amount * 30)

/obj/item/weapon/rcd/borg/atom_init()
	. = ..()
	desc = "A device used to rapidly build walls/floor."
	canRwall = TRUE

/obj/item/weapon/rcd_ammo
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for the RCD."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	opacity = FALSE
	density = FALSE
	anchored = FALSE
	origin_tech = "materials=2"
	m_amt = 30000
	g_amt = 15000
	var/matter = 10
