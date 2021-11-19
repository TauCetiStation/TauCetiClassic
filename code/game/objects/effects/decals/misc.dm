/obj/effect/decal/point
	name = "arrow"
	desc = "It's an arrow hanging in mid-air. There may be a wizard about."
	icon = 'icons/mob/screen1.dmi'
	icon_state = "arrow"
	plane = GAME_PLANE
	layer = POINT_LAYER
	anchored = TRUE

/obj/effect/decal/point/atom_init(mapload, invisibility = 0)
	. = ..()
	var/atom/old_loc = loc
	abstract_move(get_turf(src))
	src.pixel_x = old_loc.pixel_x
	src.pixel_y = old_loc.pixel_y
	src.invisibility = invisibility

// Used for spray that you spray at walls, tables, hydrovats etc
/obj/effect/decal/spraystill
	density = FALSE
	anchored = TRUE
	layer = 50

//Used by spraybottles.
/obj/effect/decal/chempuff
	name = "chemicals"
	icon = 'icons/obj/chempuff.dmi'
	pass_flags = PASSTABLE | PASSGRILLE
