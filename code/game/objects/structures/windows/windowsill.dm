/**
 * Windowsill
 */

/obj/structure/windowsill
	name = "windowsill"
	desc = "A windowsill. You can mount a window on it."
	icon = 'icons/obj/smooth_structures/windows/window_sill.dmi'
	icon_state = "box"

	density = TRUE
	anchored = TRUE
	layer = CONTAINER_STRUCTURE_LAYER
	throwpass = TRUE
	climbable = TRUE

	smooth = SMOOTH_TRUE
	canSmoothWith = CAN_SMOOTH_WITH_WALLS
	smooth_adapters = SMOOTH_ADAPTERS_WALLS

	max_integrity = 100
	resistance_flags = CAN_BE_HIT

/obj/structure/windowsill/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return TRUE
	if(istype(mover) && HAS_TRAIT(mover, TRAIT_ARIBORN))
		return TRUE
	if(locate(/obj/structure/windowsill) in get_turf(mover))
		return TRUE

	return ..()

/obj/structure/windowsill/attackby(obj/item/W, mob/user)
	var/obj/structure/grille/grille_in_loc = locate() in loc

	if(!grille_in_loc && istype(W, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = W
		R.try_to_build_grille(user, loc)
		return

	else if(istype(W, /obj/item/stack/sheet/glass) || istype(W, /obj/item/stack/sheet/rglass))
		if(grille_in_loc && !grille_in_loc.anchored) // grille optional, but if we have one - should be secured
			to_chat(user, "<span class='warning'>You need to secure [grille_in_loc] first!</span>")
			return

		var/type

		if(istype(W, /obj/item/stack/sheet/glass/phoronglass))
			type = /obj/structure/window/fulltile/phoron
		else if(istype(W, /obj/item/stack/sheet/glass/phoronrglass))
			type = /obj/structure/window/fulltile/reinforced/phoron
		else if(istype(W, /obj/item/stack/sheet/glass))
			type = /obj/structure/window/fulltile
		else if(istype(W, /obj/item/stack/sheet/rglass))
			type = /obj/structure/window/fulltile/reinforced

		if(!type) // should not happen
			return
		
		if(!W.use_tool(src, user, 20, 2))
			return

		new type(loc, !!grille_in_loc)
		QDEL_NULL(grille_in_loc)
		qdel(src)

	else if(iswrenching(W))
		if(grille_in_loc)
			to_chat(user, "<span class='warning'>You need to remove [grille_in_loc] first!</span>")
			return

		to_chat(user, "<span class='notice'>You begin disassembling \the [src].</span>")
		
		if(W.use_tool(src, user, 20))
			deconstruct(TRUE)

		return

	return ..()

/obj/structure/windowsill/deconstruct(disassembled)
	if(flags & NODECONSTRUCT)
		return ..()

	if(disassembled)
		new /obj/item/stack/sheet/metal(loc, 2)

	return ..()
