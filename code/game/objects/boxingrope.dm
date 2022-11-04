/obj/decal
	flags = ABSTRACT
	
/obj/decal/boxingrope
	name = "Boxing Ropes"
	desc = "Do not exit the ring."
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/decals.dmi'
	icon_state = "ringrope"
	layer = OBJ_LAYER

/obj/decal/boxingrope/CanPass(atom/movable/mover, turf/target, height=0)
	if(!density)
		return 1
	if ((mover.pass_flags & PASSTABLE || istype(mover, /obj/effect/meteor) || mover.throwing == 1) )
		return 1
	else
		return 0

/obj/decal/boxingropeenter
	name = "Ring entrance"
	desc = "Do not exit the ring."
	density = FALSE
	anchored = TRUE
	icon = 'icons/obj/decals.dmi'
	icon_state = "ringrope"
	layer = OBJ_LAYER
