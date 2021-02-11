/obj/effect/decal/turf_decal/warning_stripes
	name = "warning line"
	icon = 'icons/effects/warning_stripes.dmi'
	icon_state = "warningline"
	layer = TURF_DECAL_LAYER

/obj/effect/decal/turf_decal/warning_stripes/corner
	icon_state = "warninglinecorners"

/obj/effect/decal/turf_decal/warning_stripes/three
	icon_state = "warninglinethree"

/obj/effect/decal/turf_decal/warning_stripes/full
	icon_state = "warninglinefull"

/obj/effect/decal/turf_decal/atom_init()
	..()

	loc.add_overlay(src)
	return INITIALIZE_HINT_QDEL
