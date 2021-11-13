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

/obj/decal/boxingrope/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(!density)
		return TRUE
	if(air_group || (height==0))
		return TRUE
	if ((mover.pass_flags & PASSTABLE || istype(mover, /obj/effect/meteor) || mover.throwing == 1) )
		return TRUE
	else
		return FALSE

/obj/decal/boxingropeenter
	name = "Ring entrance"
	desc = "Do not exit the ring."
	density = FALSE
	anchored = TRUE
	icon = 'icons/obj/decals.dmi'
	icon_state = "ringrope"
	layer = OBJ_LAYER
