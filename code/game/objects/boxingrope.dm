/obj/decal/boxingrope
	name = "Boxing Ropes"
	desc = "Do not exit the ring."
	density = 1
	anchored = 1
	icon = 'icons/obj/decals.dmi'
	icon_state = "ringrope"
	layer = OBJ_LAYER

/obj/decal/boxingrope/CanPass(atom/movable/mover, turf/target, height=0, air_group=0) // stolen from window.dm
	if(!density) return 1
 	if(air_group || (height==0)) return 1
 	if ((mover.flags & 2 || istype(mover, /obj/effect/meteor) || mover.throwing == 1) )
 		return 1
 	else
 		return 0

/obj/decal/boxingropeenter
	name = "Ring entrance"
	desc = "Do not exit the ring."
	density = 0
	anchored = 1
	icon = 'icons/obj/decals.dmi'
	icon_state = "ringrope"
	layer = OBJ_LAYER



/*	CanPass(atom/movable/mover, turf/target, height=0, air_group=0) // stolen from window.dm
		if (src.dir == SOUTHWEST || src.dir == SOUTHEAST || src.dir == NORTHWEST || src.dir == NORTHEAST || src.dir == SOUTH || src.dir == NORTH)
			return 0
		if(get_dir(loc, target) == dir)

			return !density
		else
			return 1

	CheckExit(atom/movable/O as mob|obj, target as turf)
		if (!src.density)
			return 1
		if (get_dir(O.loc, target) == src.dir)
			return 0
		return 1

*/