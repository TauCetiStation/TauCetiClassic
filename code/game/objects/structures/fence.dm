/obj/structure/fence
	name = "Indestructible Concrete Fence"
	desc = "Спрячь за высоким забором таяру - выкраду вместе с забором!"

	icon = 'icons/obj/fence.dmi'
	icon_state = "fence_concrete"

	flags = ON_BORDER
	layer = INFRONT_MOB_LAYER

	climbable = TRUE

	throwpass = TRUE

	resistance_flags = FULL_INDESTRUCTIBLE

	anchored = TRUE //Забор всегда прикручен к тайлу.
	var/screwed = TRUE //Подкручен и сломается если перелезть.


	var/fence_full = TRUE
	var/fence_cover_chance = 40

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
		if(W.use_tool(src, user, 50, volume = 50, quality = QUALITY_WRENCHING))
			to_chat(user, "<span class='notice'>Вы демонтируете забор.</span>")
			deconstruct(TRUE)
			return TRUE
		return FALSE
	else if(isscrewing(W))
		if(W.use_tool(src, user, 50, volume = 50, quality = QUALITY_SCREWING))
			if(screwed)
				to_chat(user, "<span class='notice'>Вы подкручиваете забор, чтобы он стал хлипким.</span>")
			else
				to_chat(user, "<span class='notice'>Вы подкручиваете забор, чтобы он был крепким.</span>")
			screwed = !screwed
			return TRUE
		return FALSE

	return ..()

/obj/structure/fence/CanPass(atom/movable/mover, turf/target, height=0)
	if(fence_cover_chance && istype(mover,/obj/item/projectile))
		return (check_cover(mover,target))
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return TRUE
	if(istype(mover) && HAS_TRAIT(mover, TRAIT_ARIBORN))
		return TRUE
	if(get_dir(loc, target) & dir)
		if(!screwed && prob(5)) //5% chance that it won't stop us from going through.
			deconstruct(FALSE)

		return FALSE

	return TRUE

/obj/structure/fence/CanAStarPass(obj/item/weapon/card/id/ID, to_dir)
	return (dir != to_dir)

/obj/structure/fence/CheckExit(atom/movable/O, turf/target)
	if(istype(O) && O.checkpass(PASSTABLE))
		return TRUE
	if(istype(O) && HAS_TRAIT(O, TRAIT_ARIBORN))
		return TRUE
	if(get_dir(O.loc, target) == dir)
		return FALSE

	return TRUE

/obj/structure/fence/on_climb(mob/living/climber, mob/living/user)
	if(!screwed)
		deconstruct(FALSE)
		climber.throw_at(get_step(user, dir), 2, 2)
		return

	return ..()

/obj/structure/fence/proc/check_cover(obj/item/projectile/P, turf/from)
	var/turf/cover = get_turf(src)
	if(get_dist(P.starting, loc) <= 1) //Too close to cover
		return TRUE

	var/first = ((get_turf(P.original) == cover) && (get_dir(cover, from) == dir)) //Projectile shot to the turf our cover is in and direction of cover covers from said projectile.
	var/second = ((get_turf(P.original) == get_step(cover, get_dir(from, cover))) && get_dir(from, cover) == dir) //Projectile shot to the turf behind our cover and direction of cover covers from said projectile.

	if(!first && !second) //Dir can't cover
		return TRUE

	if(fence_cover_chance >= 100)
		return FALSE

	var/cover_chance = fence_cover_chance

	if(ismob(P.original))
		var/mob/M = P.original
		if(M.lying)
			if(fence_full) //Full cover fully covers lying mobs
				return FALSE

			cover_chance += 20


	if(prob(cover_chance))
		return FALSE

	return TRUE



/obj/structure/fence/wood
	name = "wooden fence"
	desc = "Деревянный забор."

	icon_state = "fence_wood"

	max_integrity = 5
	resistance_flags = CAN_BE_HIT

	fence_full = FALSE
	fence_cover_chance = 20

/obj/structure/fence/wood/deconstruct(disassembled)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/wood(loc, 2)
	..()

/obj/structure/fence/metal
	name = "railings"
	desc = "Металлический забор."

	icon_state = "fence_metal"

	max_integrity = 10
	resistance_flags = FIRE_PROOF | CAN_BE_HIT

	fence_full = FALSE
	fence_cover_chance = 0

	var/mutable_appearance/Rail

/obj/structure/fence/metal/atom_init()
	. = ..()

	if(color)
		change_color(color)
	color = null

/obj/structure/fence/metal/proc/change_color(new_color)
	cut_overlay(Rail)

	if(!Rail)
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
