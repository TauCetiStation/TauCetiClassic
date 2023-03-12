/* Table parts and rack parts
 * Contains:
 *		Table Parts
 *		Reinforced Table Parts
 *		Glass Table Parts
 *		Wooden Table Parts
 *		Fancy Table Parts
 *		Black Fancy Table Parts
 *		Rack Parts
 */



/*
 * Table Parts
 */
// Return TRUE if reacted to a tool.
/obj/item/weapon/table_parts
	var/build_time = 0

/obj/item/weapon/table_parts/proc/attack_tools(obj/item/W, mob/user)
	if(iswrenching(W))
		deconstruct(TRUE, user)
		return TRUE

	else if(istype(W, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = W
		if (R.use(4))
			new /obj/item/weapon/table_parts/reinforced( user.loc )
			to_chat(user, "<span class='notice'>You reinforce the [name].</span>")
			qdel(src)
		else
			to_chat(user, "<span class='warning'>You need at least four rods to do this.</span>")
		return TRUE
	return FALSE

/obj/item/weapon/table_parts/attackby(obj/item/I, mob/user, params)
	if(attack_tools(I, user))
		return

	return ..()

/obj/item/weapon/table_parts/deconstruct(disassembled, user = FALSE)
	if(flags & NODECONSTRUCT)
		return ..()
	var/turf/T = get_turf(user || src)
	for(var/debrit_type in debris)
		new debrit_type(T)
	..()

/obj/item/weapon/table_parts/attack_self(mob/user)
	var/turf/simulated/T = get_turf(user)
	if(!can_place(T))
		to_chat(user, "<span class='warning'>You can't put it here!</span>")
		return
	if(build_time > 0 && !handle_fumbling(user, src, build_time, list(/datum/skill/engineering = SKILL_LEVEL_NOVICE)))
		return
	if(!can_place(T))
		to_chat(user, "<span class='warning'>You can't put it here!</span>")
		return
	var/obj/structure/table/R = new table_type(T)
	to_chat(user, "<span class='notice'>You assemble [src].</span>")
	R.add_fingerprint(user)
	qdel(src)

/obj/item/weapon/table_parts/proc/can_place(turf/T)
	return T && T.CanPass(null, T)

/*
 * Reinforced Table Parts
 */
/obj/item/weapon/table_parts/reinforced
	build_time = SKILL_TASK_AVERAGE

/obj/item/weapon/table_parts/reinforced/attack_tools(obj/item/W, mob/user)
	if(iswrenching(W))
		deconstruct(TRUE, user)
		return TRUE
	return FALSE

/*
 * Glass Table Parts
 */
/obj/item/weapon/table_parts/glass/attack_tools(obj/item/W, mob/user)
	if(iswrenching(W))
		deconstruct(TRUE, user)
		return TRUE
	return FALSE


/*
 * Wooden Table Parts
 */
/obj/item/weapon/table_parts/wood/attack_tools(obj/item/W, mob/user)
	if(iswrenching(W))
		deconstruct(TRUE, user)
		return TRUE

	else if(istype(W, /obj/item/stack/tile/grass))
		var/obj/item/stack/tile/grass/Grass = W
		Grass.use(1)
		new /obj/item/weapon/table_parts/wood/poker(loc)
		visible_message("<span class='notice'>[user] adds grass to the wooden table parts</span>")
		qdel(src)
		return TRUE

	return FALSE

/*
 * Fancy Wooden Table Parts
 */
/obj/item/weapon/table_parts/wood/fancy/attack_tools(obj/item/W, mob/user)
	if(iswrenching(W))
		deconstruct(TRUE, user)
		return TRUE
	return FALSE

/*
 * Poker Table Parts
 */

/obj/item/weapon/table_parts/wood/poker/attack_tools(obj/item/W, mob/user)
	if(iswrenching(W))
		deconstruct(TRUE, user)
		return TRUE
	return FALSE

/*
 * Rack Parts
 */
/obj/item/weapon/rack_parts/attackby(obj/item/I, mob/user, params)
	if(iswrenching(I))
		deconstruct(TRUE, user)
		return
	return ..()

/obj/item/weapon/rack_parts/deconstruct(disassembled, user = FALSE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(get_turf(user || src))
	..()

/obj/item/weapon/rack_parts/attack_self(mob/user)
	var/turf/simulated/T = get_turf(user)
	if(T.CanPass(null, T))
		var/obj/structure/rack/R = new /obj/structure/rack( T )
		to_chat(user, "<span class='notice'>You assemble [src].</span>")
		R.add_fingerprint(user)
		qdel(src)
	else
		to_chat(user, "<span class='warning'>You can't put it here!</span>")
