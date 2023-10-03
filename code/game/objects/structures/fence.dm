/obj/structure/fence
	name = "fence"
	desc = "Спрячь за высоким забором таяру - выкраду вместе с забором!"

	icon = 'icons/obj/fences.dmi'
	icon_state = "fence_concrete"

	flags = ON_BORDER
	layer = INFRONT_MOB_LAYER

	climbable = TRUE

	throwpass = 1

	max_integrity = 15
	resistance_flags = CAN_BE_HIT

	anchored = TRUE
	var/screwed = TRUE

/obj/structure/fence/atom_init()
	switch(dir)
		if(NORTH)
			layer -= 0.01
		if(SOUTH)
			layer += 0.01

	. = ..()

/obj/structure/fence/attackby(obj/item/W, mob/user)
	if(iswrenching(W))
		if(user.is_busy(src))
			return FALSE
		to_chat(user, "<span class='notice'>Вы демонтируете забор.</span>")
		if(W.use_tool(src, user, 50, volume = 50))
			deconstruct(TRUE)
		return TRUE
	else if(isscrewing(W))
		if(user.is_busy(src))
			return FALSE
		if(W.use_tool(src, user, 50, volume = 50))
			if(screwed)
				to_chat(user, "<span class='notice'>Вы откручиваете забор.</span>")
			else
				to_chat(user, "<span class='notice'>Вы прикручиваете забор.</span>")
			screwed = !screwed
		return TRUE

	return ..()

/obj/structure/fence/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover,/obj/item/projectile))
		return TRUE
	if(get_dir(loc, target) & dir)
		if(HAS_TRAIT(mover, TRAIT_ARIBORN) || mover.checkpass(PASSTABLE))
			return TRUE
		var/turf/T = loc
		if(T.density)
			return FALSE
		for(var/atom/A in T)
			if(A == src)
				continue
			else
				if(!A.CanPass(mover, target, height))
					return FALSE
		return FALSE
	else
		return TRUE

/obj/structure/fence/CanAStarPass(obj/item/weapon/card/id/ID, to_dir, caller)
	if(dir == to_dir)
		return FALSE

	return TRUE

/obj/structure/fence/CheckExit(atom/movable/O, turf/target)
	if(istype(O,/obj/item/projectile))
		return TRUE
	if(get_dir(O.loc, target) == dir)
		if(HAS_TRAIT(O, TRAIT_ARIBORN) || O.checkpass(PASSTABLE))
			return TRUE
		var/turf/T = get_step(O, dir)
		if(T.density)
			return FALSE
		for(var/atom/A in T)
			if(!A.CanPass(O, target))
				return FALSE
		return FALSE
	return TRUE

/obj/structure/fence/verb/rotate()
	set name = "Повернуть забор"
	set category = "Object"
	set src in oview(1)

	if(isobserver(usr)) //to stop ghosts from rotating
		return

	if(screwed)
		to_chat(usr, "It is fastened to the floor therefore you can't rotate it!")
		return 0

	set_dir(turn(dir, 90))
	return

/obj/structure/fence/wood
	name = "wooden fence"
	desc = "Деревянный забор."

	icon = 'icons/obj/fences.dmi'
	icon_state = "fence_wood"

/obj/structure/fence/wood/deconstruct(disassembled)
	new /obj/item/stack/sheet/wood(loc, 2)
	..()

/obj/structure/fence/metal
	name = "railings"
	desc = "Металлический забор."

	icon = 'icons/obj/fences.dmi'
	icon_state = "fence_metal"

	var/icon/Rail

/obj/structure/fence/metal/atom_init()
	if(color)
		change_color(color)
	color = null

	. = ..()

/obj/structure/fence/metal/proc/change_color(new_color)
	cut_overlay(Rail)
	Rail = icon(icon, "[icon_state]_color")
	Rail.Blend(new_color, ICON_MULTIPLY)
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
	new /obj/item/stack/sheet/metal(loc, 2)
	..()

/obj/structure/fence/glass
	name = "glass fence"
	desc = "Стеклянный забор."

	icon = 'icons/obj/fences.dmi'
	icon_state = "fence_glass"

/obj/structure/fence/glass/deconstruct(disassembled)
	new /obj/item/stack/sheet/glass(loc, 2)
	..()

var/global/list/gates_list = list()

ADD_TO_GLOBAL_LIST(/obj/structure/fence/gate, gates_list)
/obj/machinery/door/gate
	name = "turnstile"
	desc = "Попросите вахтёра открыть."

	icon = 'icons/obj/fences.dmi'
	icon_state = "turniket_off"

	flags = ON_BORDER
	layer = INFRONT_MOB_LAYER

	throwpass = 1

	max_integrity = 50
	resistance_flags = CAN_BE_HIT

	anchored = TRUE

	block_air_zones = FALSE

	var/id
	var/open = FALSE

/obj/machinery/door/gate/bumpopen(mob/user)
	return

/obj/machinery/door/try_open(mob/user)
	return

/obj/machinery/door/gate/open()
	if(open)
		return
	icon_state = "turnstile_open"
	flick("turnstile_open_flick")
	open = TRUE

	addtimer(CALLBACK(src, PROC_REF(close)), 5 SECONDS)

/obj/machinery/door/gate/close()
	if(!open)
		return
	icon_state = "turnstile_closed"
	flick("turnstile_closed_flick")
	open = FALSE

/obj/machinery/door/gate/attackby(obj/item/W, mob/user)
	if(iswrenching(W))
		if(!open)
			return FALSE
		if(user.is_busy(src))
			return FALSE
		if(W.use_tool(src, user, 50, volume = 50))
			if(anchored)
				to_chat(user, "<span class='notice'>Вы откручиваете турникет.</span>")
			else
				to_chat(user, "<span class='notice'>Вы прикручиваете турникет.</span>")
			anchored = !anchored
		return TRUE

/obj/machinery/door/gate/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover,/obj/item/projectile))
		return TRUE
	if(open)
		close()
		return TRUE
	if(get_dir(loc, target) & dir)
		if(HAS_TRAIT(mover, TRAIT_ARIBORN) || mover.checkpass(PASSTABLE))
			return TRUE
		var/turf/T = loc
		if(T.density)
			return FALSE
		for(var/atom/A in T)
			if(A == src)
				continue
			else
				if(!A.CanPass(mover, target, height))
					return FALSE
		return FALSE
	else
		return TRUE

/obj/machinery/door/gate/CanAStarPass(obj/item/weapon/card/id/ID, to_dir, caller)
	if(dir == to_dir)
		return FALSE

	return TRUE

/obj/machinery/door/gate/CheckExit(atom/movable/O, turf/target)
	if(istype(O,/obj/item/projectile))
		return TRUE
	if(open)
		close()
		return TRUE
	if(get_dir(O.loc, target) == dir)
		if(HAS_TRAIT(O, TRAIT_ARIBORN) || O.checkpass(PASSTABLE))
			return TRUE
		var/turf/T = get_step(O, dir)
		if(T.density)
			return FALSE
		for(var/atom/A in T)
			if(!A.CanPass(O, target))
				return FALSE
		return FALSE
	return TRUE
