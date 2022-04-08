/*
CONTAINS:
RCD Action datum
RCD
Borg RCD
*/

/* RCD Action datum
 * Stores information about things that RCD can do
 * This could've been an element probably?
 */
/datum/rcd
	// Name of RCD action
	var/name

	// Icon of action in radial menu
	var/icon/icon

	// Cost of this action in matter units
	var/cost

	// Duration of that action
	var/duration

	// The RCD that possesses this action
	var/obj/item/weapon/rcd/holder

	// List of types that this action can be applied to
	var/list/can_act_on_types = list()

	// List of types that this action cannot be applied to
	var/list/cannot_act_on_types = list()

	//RCD effect of action
	var/image/rcd_effect

/datum/rcd/New(_holder)
	holder = _holder

/datum/rcd/Destroy(force, ...)
	. = ..()
	holder = null
	QDEL_NULL(icon)

/* action(atom/target): bool
 * Performs some particular action on target atom.
 * Returning TRUE means that action was successful
 * and matter should be consumed.
 * Otherwise, returning FALSE will not result in
 * consumption of matter.
*/
/datum/rcd/proc/action(atom/target)
	return FALSE

/datum/rcd/proc/can_act_on(atom/target, mob/user)
	var/valid_type = is_type_in_list(target, can_act_on_types) && !is_type_in_list(target, cannot_act_on_types)
	var/enough_resources = holder.checkResource(cost, user)
	return valid_type && enough_resources && !holder.working

/datum/rcd/proc/use_matter(mob/user)
	holder.useResource(cost, user)

/datum/rcd/proc/apply(atom/target, mob/user)
	if(user.is_busy())
		return
	if(!can_act_on(target, user))
		return
	holder.working = TRUE
	if(istype(holder.current_action, /datum/rcd/deconstruct))
		rcd_effect = image('icons/effects/rcd.dmi', "deconstruction", ABOVE_ALL_MOB_LAYER)
	else
		rcd_effect = image('icons/effects/rcd.dmi', "construction", ABOVE_ALL_MOB_LAYER)
	if(duration)
		target.add_overlay(rcd_effect)
	if(!do_after(user, duration, target = target))
		holder.working = FALSE
		target.cut_overlay(rcd_effect)
		return
	if(action(target))
		use_matter(user)
		holder.activate()
	target.cut_overlay(rcd_effect)
	holder.working = FALSE

/datum/rcd/deconstruct
	name = "Deconstruct"
	cost = 5
	duration = 4 SECONDS
	can_act_on_types = list(
		/turf/simulated/wall,
		/turf/simulated/floor,
		/obj/machinery/door/airlock,
		/obj/machinery/door/firedoor,
		/obj/structure/window,
		/obj/machinery/door/window,
	)
	cannot_act_on_types = list(
		/turf/simulated/wall/r_wall
	)
	icon = icon('icons/obj/decals.dmi', "blast")

/datum/rcd/deconstruct/action(atom/target)
	if(istype(target, /turf/simulated/floor))
		var/turf/simulated/floor/F = target
		F.BreakToBase()
	else if(istype(target, /turf/simulated/wall))
		var/turf/simulated/wall/W = target
		W.ChangeTurf(/turf/simulated/floor/plating/airless)
	else
		qdel(target)
	return TRUE

/datum/rcd/deconstruct/advanced
	// Can deconstruct reinforced walls
	cannot_act_on_types = list()

/datum/rcd/wall
	name = "Wall"
	cost = 3
	duration = 2 SECONDS
	can_act_on_types = list(
		/turf/simulated/floor,
	)
	icon = icon('icons/mob/radial_rcd.dmi', "box_small")

/datum/rcd/wall/action(turf/simulated/floor/F)
	F.ChangeTurf(/turf/simulated/wall)
	return TRUE

/datum/rcd/floor
	name = "Floor"
	cost = 1
	duration = 0 SECONDS
	can_act_on_types = list(
		/turf/environment/space,
	)
	icon = icon('icons/mob/radial_rcd.dmi', "plating_small")

/datum/rcd/floor/action(turf/environment/space/S)
	S.ChangeTurf(/turf/simulated/floor/plating/airless)
	return TRUE

// These actions will act only on non-dense turfs
/datum/rcd/nondense
	can_act_on_types = list(
		/turf/simulated/floor
	)

/datum/rcd/nondense/airlock/can_act_on(atom/target)
	if(target.density)
		return FALSE
	for(var/atom/A in target)
		if(A.density || (is_type_in_list(A, list(/obj/machinery/door, /obj/structure/mineral_door)) && !istype(A, /obj/machinery/door/firedoor)))
			return FALSE
	return ..()

/datum/rcd/nondense/firedoor/can_act_on(atom/target)
	if(target.density)
		return FALSE
	for(var/atom/A in target)
		if(A.density || is_type_in_list(A, list(/obj/machinery/door/firedoor)))
			return FALSE
	return ..()

/datum/rcd/nondense/airlock
	name = "Airlock"
	cost = 10
	duration = 5 SECONDS
	icon = icon('icons/mob/radial_rcd.dmi', "closed_filled")

/datum/rcd/nondense/airlock/action(turf/simulated/floor/F)
	new /obj/machinery/door/airlock(F)
	return TRUE

/datum/rcd/nondense/airlock/glass
	name = "Glass Airlock"
	cost = 10
	duration = 5 SECONDS
	icon = icon('icons/mob/radial_rcd.dmi', "closed_small")

/datum/rcd/nondense/airlock/glass/action(turf/simulated/floor/F)
	new /obj/machinery/door/airlock/glass(F)
	return TRUE

/datum/rcd/nondense/firedoor
	name = "Emergency Shutter"
	cost = 5
	duration = 3 SECONDS
	icon = icon('icons/mob/radial_rcd.dmi', "door_closed_small")

/datum/rcd/nondense/firedoor/action(turf/simulated/floor/F)
	new /obj/machinery/door/firedoor(F)
	return TRUE

/datum/rcd/nondense/grilleglass
	name = "Window"
	cost = 3
	duration = 1.5 SECONDS
	icon = icon('icons/mob/radial_rcd.dmi', "grilleglass")
	var/window_type = /obj/structure/window/basic

/datum/rcd/nondense/grilleglass/action(turf/simulated/floor/F)
	new /obj/structure/grille(F)
	var/obj/structure/window/W = new window_type(F)
	W.set_dir(SOUTHWEST)
	W.ini_dir = SOUTHWEST
	return TRUE

/datum/rcd/nondense/grilleglass/reinforced
	name = "Reinforced Window"
	cost = 4
	duration = 3 SECONDS
	icon = icon('icons/mob/radial_rcd.dmi', "grillerglass")
	window_type = /obj/structure/window/reinforced

/obj/item/weapon/rcd
	name = "rapid-construction-device (RCD)"
	desc = "A device used to rapidly build walls/floor."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	item_state = "rcd30"
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
	var/max_matter = 30
	var/matter = 30
	var/working = FALSE
	var/disabled = FALSE

	var/list/action_types = list(
		/datum/rcd/deconstruct,
		/datum/rcd/nondense/airlock,
		/datum/rcd/nondense/airlock/glass,
		/datum/rcd/nondense/firedoor,
		/datum/rcd/floor,
		/datum/rcd/wall,
		/datum/rcd/nondense/grilleglass,
	)
	var/list/datum/rcd/actions = list()
	// Used by radial menu
	var/list/action_icons = list()
	var/list/action_by_name = list()
	var/datum/rcd/current_action = null
	action_button_name = "Switch RCD"


/obj/item/weapon/rcd/atom_init()
	. = ..()
	rcd_list += src
	desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
	spark_system = new /datum/effect/effect/system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	init_actions()

/obj/item/weapon/rcd/Destroy()
	rcd_list -= src
	qdel(spark_system)
	spark_system = null
	current_action = null
	action_icons = null
	action_by_name = null
	QDEL_LIST(actions)
	return ..()

/obj/item/weapon/rcd/proc/init_actions()
	for(var/action_type in action_types)
		var/datum/rcd/A = new action_type(src)
		actions += A
		action_icons[A.name] = A.icon
		action_by_name[A.name] = A

/obj/item/weapon/rcd/update_icon(mob/user)
	icon_state = initial(icon_state) + "[CEIL(matter / 10) * 10]"
	if(!matter)
		item_state = "rcd0"
	else
		item_state = "rcd30"
	user.update_inv_l_hand()
	user.update_inv_r_hand()
	return

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
		update_icon(user)
	else
		return ..()

/obj/item/weapon/rcd/attack_self(mob/user)
	prompt_action(user)

/obj/item/weapon/rcd/proc/prompt_action(mob/user)
	// we have to do some hacking cause of rig rcd module
	var/choice = show_radial_menu(user, user, action_icons, uniqueid = "rcd\ref[user]\ref[src]", tooltips = TRUE)
	if(!choice)
		return
	current_action = action_by_name[choice]
	to_chat(user, "<span class='notice'>You switch [src] to \"[choice]\".</span>")
	playsound(src, 'sound/effects/pop.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	if(prob(20))
		spark_system.start()

/obj/item/weapon/rcd/proc/activate()
	playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)

/obj/item/weapon/rcd/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(disabled && !isrobot(user))
		return FALSE
	if(istype(target, /area/shuttle))
		return FALSE

	current_action?.apply(target, user)


/obj/item/weapon/rcd/proc/useResource(amount, mob/user)
	if(matter < amount)
		return FALSE
	matter -= amount
	desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
	update_icon(user)
	return TRUE

/obj/item/weapon/rcd/borg/useResource(amount, mob/user)
	if(!isrobot(user))
		return FALSE
	return user:cell:use(amount * 30)

/obj/item/weapon/rcd/proc/checkResource(amount, mob/user)
	return matter >= amount

/obj/item/weapon/rcd/borg/checkResource(amount, mob/user)
	if(!isrobot(user))
		return FALSE
	return user:cell:charge >= (amount * 30)

/obj/item/weapon/rcd/borg
	action_types = list(
		/datum/rcd/deconstruct/advanced,
		/datum/rcd/nondense/airlock,
		/datum/rcd/nondense/airlock/glass,
		/datum/rcd/nondense/firedoor,
		/datum/rcd/floor,
		/datum/rcd/wall,
		/datum/rcd/nondense/grilleglass,
		/datum/rcd/nondense/grilleglass/reinforced,
	)

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
	var/matter = 10
