/obj/structure/fence
	name = "Undestructable Concrete Fence"
	desc = "Спрячь за высоким забором таяру - выкраду вместе с забором!"

	icon = 'icons/obj/fence.dmi'
	icon_state = "fence_concrete"

	flags = ON_BORDER
	layer = INFRONT_MOB_LAYER

	climbable = TRUE

	throwpass = 1

	resistance_flags = FULL_INDESTRUCTIBLE

	anchored = TRUE //Забор всегда прикручен к тайлу.
	var/screwed = TRUE //Подкручен и сломается если перелезть. Можно крутить.

	var/cancover = TRUE

/obj/structure/fence/atom_init()
	. = ..()

	update_layer()

/obj/structure/fence/proc/update_layer()
	switch(dir)
		if(NORTH)
			layer = initial(layer) - 0.01
		if(SOUTH)
			layer = initial(layer) + 0.01
		else
			layer = initial(layer)

/obj/structure/fence/set_dir()
	. = ..()
	update_layer()

/obj/structure/fence/attackby(obj/item/W, mob/user)
	if(iswrenching(W))
		if(W.use_tool(src, user, 50, volume = 50))
			to_chat(user, "<span class='notice'>Вы демонтируете забор.</span>")
			deconstruct(TRUE)
			return TRUE
		return FALSE
	else if(isscrewing(W))
		if(W.use_tool(src, user, 50, volume = 50))
			if(screwed)
				to_chat(user, "<span class='notice'>Вы откручиваете забор.</span>")
			else
				to_chat(user, "<span class='notice'>Вы прикручиваете забор.</span>")
			screwed = !screwed
			return TRUE
		return FALSE

	return ..()

/obj/structure/fence/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return TRUE
	if(istype(mover) && HAS_TRAIT(mover, TRAIT_ARIBORN))
		return TRUE
	if(get_dir(loc, target) & dir)
		return FALSE

	return TRUE

/obj/structure/fence/CanAStarPass(obj/item/weapon/card/id/ID, to_dir)
	if(dir == to_dir)
		return FALSE

	return TRUE

/obj/structure/fence/CheckExit(atom/movable/O, turf/target)
	if(istype(O) && O.checkpass(PASSTABLE))
		return TRUE
	if(istype(O) && HAS_TRAIT(O, TRAIT_ARIBORN))
		return TRUE
	if(get_dir(O.loc, target) == dir)
		return FALSE

	return TRUE

/obj/structure/fence/verb/rotate()
	set name = "Повернуть забор"
	set category = "Object"
	set src in oview(1)

	if(isobserver(usr) || usr.incapacitated())
		return

	if(screwed)
		to_chat(usr, "[src] прикручен к полу!")
		return

	set_dir(turn(dir, 90))

/obj/structure/fence/on_climb(mob/living/climber, mob/living/user)
	if(!screwed)
		deconstruct(FALSE)
		climber.throw_at(get_step(user, dir), 2, 2)
		return

	var/turf/T
	if(get_turf(climber) == get_turf(src))
		T = get_step(get_turf(src), dir)
	else
		T = get_turf(src)
	if(T.density)
		return
	for(var/atom/A in T)
		if(A == src)
			continue
		if(!A.CanPass(climber, T))
			return

	user.forceMove(T)



/obj/structure/fence/wood
	name = "wooden fence"
	desc = "Деревянный забор."

	icon_state = "fence_wood"

	max_integrity = 5
	resistance_flags = CAN_BE_HIT

/obj/structure/fence/wood/deconstruct(disassembled)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/wood(loc, 2)
	..()

/obj/structure/fence/metal
	name = "railings"
	desc = "Металлический забор."

	icon_state = "fence_metal"
	cancover = FALSE

	max_integrity = 10
	resistance_flags = FIRE_PROOF | CAN_BE_HIT

	var/mutable_appearance/Rail

/obj/structure/fence/metal/atom_init()
	. = ..()

	if(color)
		change_color(color)
	color = null

/obj/structure/fence/metal/proc/change_color(new_color)
	cut_overlay(Rail)
	Rail = mutable_appearance(icon, "fence_metal_color")
	Rail.color = new_color
	add_overlay(Rail)

/obj/structure/fence/metal/proc/change_paintjob(obj/item/weapon/airlock_painter/W, mob/user)
	if(!istype(W))
		return

	if(!W.can_use(user, 1))
		return

	var/new_color = input(user, "Выберите цвет!") as color|null

	if(!new_color)
		return

	if(W.use_tool(src, user, 50, 1))
		change_color(new_color)

/obj/structure/fence/metal/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/airlock_painter))
		change_paintjob(W, user)
		return

	return ..()

/obj/structure/fence/metal/deconstruct(disassembled)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, 2)
	..()
