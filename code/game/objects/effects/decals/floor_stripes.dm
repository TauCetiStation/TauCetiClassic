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

	loc.overlays += src
	return INITIALIZE_HINT_QDEL

/obj/effect/decal/hatched_mark
	icon = 'icons/obj/decals.dmi'
	icon_state = "mule_dropoff"
	layer = 2

/obj/effect/decal/hatched_mark/atom_init()
	..()

	loc.overlays += src
	return INITIALIZE_HINT_QDEL

/obj/effect/decal/outline
	icon = 'icons/obj/decals.dmi'
	icon_state = "mule_beacon"
	layer = 2

/obj/effect/decal/outline/atom_init()
	..()

	loc.overlays += src
	return INITIALIZE_HINT_QDEL

/obj/effect/decal/siding
	icon = 'icons/obj/decals.dmi'
	icon_state = "spline_plain"
	layer = 2

/obj/effect/decal/siding/atom_init()
	..()

	loc.overlays += src
	return INITIALIZE_HINT_QDEL

/obj/effect/decal/wood_siding
	icon = 'icons/obj/decals.dmi'
	icon_state = "grass_edges"
	layer = 2

/obj/effect/decal/wood_siding/atom_init()
	..()

	loc.overlays += src
	return INITIALIZE_HINT_QDEL
