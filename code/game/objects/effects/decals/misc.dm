/obj/effect/decal/point
	name = "arrow"
	desc = "It's an arrow hanging in mid-air. There may be a wizard about."
	icon = 'icons/hud/screen1.dmi'
	icon_state = "arrow"
	plane = POINT_PLANE
	anchored = TRUE

/obj/effect/decal/point/atom_init(mapload, invisibility = 0)
	. = ..()
	var/atom/old_loc = loc
	abstract_move(get_turf(src))
	src.pixel_x = old_loc.pixel_x
	src.pixel_y = old_loc.pixel_y
	src.invisibility = invisibility

//Nice purple arrow for ghost
/obj/effect/decal/point/ghost
	icon_state = "arrow_ghost"

/obj/effect/decal/point/ghost/atom_init(mapload, invisibility)
	. = ..()
	var/image/I = image(icon, src, icon_state)
	I.plane = GHOST_ILLUSION_PLANE
	I.alpha = 200
	// s = short buffer
	var/s = add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/see_ghosts, "see_ghosts", I)
	var/datum/atom_hud/alternate_appearance/basic/see_ghosts/AA = s
	AA.set_image_layering(GHOST_ILLUSION_PLANE)

//Eminence' arrow
/obj/effect/decal/point/eminence
	icon = null
	icon_state = null

/obj/effect/decal/point/eminence/atom_init(mapload, invisibility = 0)
	. = ..()
	var/image/I = image('icons/hud/screen1.dmi', src, "arrow_eminence")
	I.alpha = 200
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/my_religion, "eminence_point", I, src, cult_religion)

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
