/obj/effect/decal/warning_stripes
	icon = 'icons/effects/warning_stripes.dmi'
	icon_state = "warningline"
	layer = 2

/obj/effect/decal/warning_stripes/corner
	icon = 'icons/effects/warning_stripes.dmi'
	icon_state = "warninglinecorners"
	layer = 2

/obj/effect/decal/warning_stripes/atom_init()
	..()

	loc.add_overlay(src)
	return INITIALIZE_HINT_QDEL