/obj/effect/decal/floor_decals

	icon = 'icons/effects/turf_decals.dmi'
	layer = 2

/obj/effect/decal/floor_decals/warning_stripes/atom_init()
	..()

	loc.add_overlay(src)
	return INITIALIZE_HINT_QDEL

/obj/effect/decal/floor_decals/warning_stripes
	icon_state = "warningline"

/obj/effect/decal/floor_decals/warning_stripes/corner
	icon_state = "warninglinecorners"

//////// BAY

//Plain Splines of all varieties

/obj/effect/decal/floor_decals/spline/plain
	name = "spline - plain"
	icon_state = "spline_plain"

/obj/effect/decal/floor_decals/spline/plain/black
	color = "#333333"

/obj/effect/decal/floor_decals/spline/plain/blue
	color = COLOR_BLUE_GRAY

/obj/effect/decal/floor_decals/spline/plain/paleblue
	color = COLOR_PALE_BLUE_GRAY

/obj/effect/decal/floor_decals/spline/plain/green
	color = COLOR_GREEN_GRAY

/obj/effect/decal/floor_decals/spline/plain/lime
	color = COLOR_PALE_GREEN_GRAY

/obj/effect/decal/floor_decals/spline/plain/yellow
	color = COLOR_BROWN

/obj/effect/decal/floor_decals/spline/plain/beige
	color = COLOR_BEIGE

/obj/effect/decal/floor_decals/spline/plain/red
	color = COLOR_RED_GRAY

/obj/effect/decal/floor_decals/spline/plain/pink
	color = COLOR_PALE_RED_GRAY

/obj/effect/decal/floor_decals/spline/plain/purple
	color = COLOR_PURPLE_GRAY

/obj/effect/decal/floor_decals/spline/plain/mauve
	color = COLOR_PALE_PURPLE_GRAY

/obj/effect/decal/floor_decals/spline/plain/orange
	color = COLOR_DARK_ORANGE

/obj/effect/decal/floor_decals/spline/plain/brown
	color = COLOR_DARK_BROWN

/obj/effect/decal/floor_decals/spline/plain/white
	color = COLOR_WHITE

/obj/effect/decal/floor_decals/spline/plain/grey

// Fancy Splines
	color = "#8d8c8c"

/obj/effect/decal/floor_decals/spline/fancy
	name = "spline - fancy"
	icon_state = "spline_fancy"

/obj/effect/decal/floor_decals/spline/fancy/black
	color = COLOR_GRAY

/obj/effect/decal/floor_decals/spline/fancy/black/corner
	icon_state = "spline_fancy_corner"

/obj/effect/decal/floor_decals/spline/fancy/black/cee
	icon_state = "spline_fancy_cee"

/obj/effect/decal/floor_decals/spline/fancy/black/three_quarters
	icon_state = "spline_fancy_full"


/obj/effect/decal/floor_decals/spline/fancy/wood
	name = "spline - wood"
	color = "#cb9e04"

/obj/effect/decal/floor_decals/spline/fancy/wood/corner
	icon_state = "spline_fancy_corner"

/obj/effect/decal/floor_decals/spline/fancy/wood/cee
	icon_state = "spline_fancy_cee"

/obj/effect/decal/floor_decals/spline/fancy/wood/three_quarters
	icon_state = "spline_fancy_full"

// Industrial Variety

/obj/effect/decal/floor_decals/industrial/loading
	name = "loading area"
	icon_state = "loadingarea"

/obj/effect/decal/floor_decals/industrial/delivery
	name = "delivery area"
	icon_state = "delivery"

/obj/effect/decal/floor_decals/industrial/outlineb
	name = "bold industrial outline"
	icon_state = "outline_bold"

/obj/effect/decal/floor_decals/industrial/outlineb/yellow
	color = COLOR_YELLOW
