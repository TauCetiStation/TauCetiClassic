// overlays abuse can cause additional server and client load, so use it carefully

/obj/effect/decal/turf_decal
	name = "Turf Decals"
	icon = 'icons/turf/turf_decals.dmi'

/obj/effect/decal/turf_decal/atom_init()
	..()

	var/turf/T = get_turf(src)

	var/mutable_appearance/MA = mutable_appearance(icon, icon_state)
	MA.color = color
	MA.alpha = alpha

	T.add_turf_decal(MA)

	return INITIALIZE_HINT_QDEL

// It's just for quick access, feel free to varset decals with any color and alpha in map editor

/obj/effect/decal/turf_decal/alpha // for strips and text decals
	name = "Transparent Turf Decals"
	alpha = 100

/obj/effect/decal/turf_decal/alpha/yellow
	name = "Transparent Yellow Turf Decals"
	color = "#ffff00"

/obj/effect/decal/turf_decal/alpha/black
	name = "Transparent Black Turf Decals"
	color = "#000000"

/obj/effect/decal/turf_decal/alpha/red
	name = "Transparent Red Turf Decals"
	color = "#ff0000"

/obj/effect/decal/turf_decal/wood // sidings / borders
	name = "Wood Turf Decals"
	color = "#ffc500"
