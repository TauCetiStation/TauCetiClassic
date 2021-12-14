/*
CONTAINS:
RCD Action datum
RCD
Borg RCD
Advanced RCD
*/

/* RCD Action datum
 * Stores information about things that RCD can do
 * This could've been an element probably?
 */
/datum/rcd
	// Name of RCD action
	var/name

	// Image of action in radial menu
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

/datum/rcd/proc/can_act_on(atom/target)
	var/valid_type = is_type_in_list(target, can_act_on_types) && !is_type_in_list(target, cannot_act_on_types)
	var/enough_resources = holder.checkResource(cost)
	return valid_type && enough_resources && !holder.working

/datum/rcd/proc/use_matter()
	holder.useResource(cost)

/datum/rcd/proc/apply(atom/target, mob/user)
	if(user.is_busy())
		return
	if(!can_act_on(target))
		return
	holder.working = TRUE
	if(!do_after(user, duration, target = target))
		holder.working = FALSE
		return
	if(action(target))
		use_matter()
		holder.activate()
	holder.working = FALSE

/datum/rcd/deconstruct
	name = "Deconstruct"
	cost = 5
	duration = 4 SECONDS
	can_act_on_types = list(
		/turf/simulated/wall,
		/turf/simulated/floor,
		/obj/machinery/door/airlock,
	)
	cannot_act_on_types = list(
		/turf/simulated/wall/r_wall
	)
	icon = icon('icons/mob/radial.dmi', "radial_delet")

/datum/rcd/deconstruct/action(atom/target)
	if(istype(target, /turf/simulated/floor))
		var/turf/simulated/floor/F = target
		F.BreakToBase()
	else if(istype(target, /turf/simulated/wall))
		var/turf/simulated/wall/W = target
		W.ChangeTurf(/turf/simulated/floor/plating/airless)
	else if(istype(target, /obj/machinery/door/airlock))
		qdel(target)
	else
		return FALSE
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
	icon = icon('icons/turf/walls/has_false_walls/wall.dmi', "box")

/datum/rcd/wall/action(turf/simulated/floor/F)
	F.ChangeTurf(/turf/simulated/wall)
	return TRUE

/datum/rcd/floor
	name = "Floor"
	cost = 1
	duration = 0 SECONDS
	can_act_on_types = list(
		/turf/space,
	)
	icon = icon('icons/turf/floors.dmi', "plating")

/datum/rcd/floor/action(turf/space/S)
	S.ChangeTurf(/turf/simulated/floor/plating/airless)
	return TRUE

// These actions will act only on non-dense turfs
/datum/rcd/nondense
	can_act_on_types = list(
		/turf/simulated/floor
	)

/datum/rcd/nondense/can_act_on(atom/target)
	if(target.density)
		return FALSE
	for(var/atom/A in target)
		if(A.density || is_type_in_list(A, list(/obj/machinery/door, /obj/structure/mineral_door)))
			return FALSE
	return ..()

/datum/rcd/nondense/airlock
	name = "Airlock"
	cost = 10
	duration = 5 SECONDS
	icon = icon('icons/obj/doors/airlocks/station/maintenance.dmi', "construction")

/datum/rcd/nondense/airlock/action(turf/simulated/floor/F)
	new /obj/machinery/door/airlock(F)
	return TRUE

/datum/rcd/nondense/grilleglass
	name = "Window"
	cost = 3
	duration = 1.5 SECONDS
	icon = icon('icons/turf/walls/fakeglass.dmi', "grilleglass")
	var/window_type = /obj/structure/window/basic

/datum/rcd/nondense/airlock/action(turf/simulated/floor/F)
	new /obj/structure/grille(F)
	var/obj/structure/window/W = new window_type(F)
	W.set_dir(SOUTHWEST)
	W.ini_dir = SOUTHWEST

/datum/rcd/nondense/grilleglass/reinforced
	name = "Reinforced Window"
	cost = 4
	duration = 3 SECONDS
	icon = icon('icons/turf/walls/fakeglass.dmi', "grillerglass")
	window_type = /obj/structure/window/reinforced

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
	var/max_matter = 30
	var/matter = 0
	var/working = FALSE
	var/disabled = FALSE

	var/list/action_types = list(
		/datum/rcd/deconstruct,
		/datum/rcd/nondense/airlock,
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
	desc = "A RCD. It currently holds [matter]/30 matter-units."
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

/obj/item/weapon/rcd/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/rcd_ammo))
		var/obj/item/weapon/rcd_ammo/A = I
		if((matter + A.matter) > max_matter)
			to_chat(user, "<span class='notice'>The RCD cant hold any more matter-units.</span>")
			return
		qdel(I)
		matter += A.matter
		playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>The RCD now holds [matter]/30 matter-units.</span>")
		desc = "A RCD. It currently holds [matter]/30 matter-units."
	else
		return ..()

/obj/item/weapon/rcd/attack_self(mob/user)
	//Change the mode
	var/choice = show_radial_menu(user, src, action_icons, tooltips = TRUE)
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
		return 0
	if(istype(target, /area/shuttle))
		return 0

	current_action.apply(target, user)


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

/obj/item/weapon/rcd/borg
	action_types = list(
		/datum/rcd/deconstruct/advanced,
		/datum/rcd/nondense/airlock,
		/datum/rcd/floor,
		/datum/rcd/wall,
		/datum/rcd/nondense/grilleglass,
	)

// More robust CE pyrometer
/obj/item/weapon/rcd/advanced
	name = "advanced RCD"
	icon_state = "arcd"
	force = 20
	throwforce = 20
	origin_tech = "engineering=5;materials=4"
	max_matter = 50
	action_types = list(
		/datum/rcd/deconstruct/advanced,
		/datum/rcd/nondense/airlock,
		/datum/rcd/floor,
		/datum/rcd/wall,
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
