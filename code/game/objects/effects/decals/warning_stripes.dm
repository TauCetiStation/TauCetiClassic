/obj/effect/decal/warning_stripes
	icon = 'icons/effects/warning_stripes.dmi'
	layer = 2

/obj/effect/decal/warning_stripes/atom_init()
	..()

	loc.overlays += src
	return INITIALIZE_HINT_QDEL
