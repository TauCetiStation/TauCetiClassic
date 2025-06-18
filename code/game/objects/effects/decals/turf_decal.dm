// overlays abuse can cause additional server and client load, so use it carefully

/obj/effect/decal/turf_decal
	name = "Turf Decals"
	icon = 'icons/turf/turf_decals.dmi'

	var/skip_decal = FALSE

/obj/effect/decal/turf_decal/atom_init(mapload, new_state, new_dir, new_color, new_alpha)
	. = ..()

	if(skip_decal)
		return INITIALIZE_HINT_QDEL

	icon_state = new_state || icon_state

	if(!icon_state)
		CRASH("Attempt to create turf decal with no state! [x].[y].[z]")

	var/turf/T = get_turf(src)

	var/image/I = image(icon, icon_state, dir = (new_dir || dir)) // temp image to work around mutable_appearance dir problem (thx tg for this solution)

	var/mutable_appearance/MA = new(I) // todo: it creates new MA for every new decal, need to optimise reuse (i think tg did it with elements)
	MA.color = new_color || color
	MA.alpha = new_alpha || alpha
	T.add_turf_decal(MA)

	return INITIALIZE_HINT_QDEL

// It's just for quick access, feel free to varset decals with any color and alpha in map editor

// strips and text decals
/obj/effect/decal/turf_decal/orange
	name = "Transparent Orange Turf Decals"
	color = "#efb341"

/obj/effect/decal/turf_decal/white
	name = "Transparent White Turf Decals"
	color = "#bcbcbc"

/obj/effect/decal/turf_decal/purple
	name = "Transparent Purple Turf Decals"
	color = "#d381c9"

/obj/effect/decal/turf_decal/blue
	name = "Transparent Blue Turf Decals"
	color = "#52b4e9"

/obj/effect/decal/turf_decal/dark_red
	name = "Transparent Dark Red Turf Decals"
	color = "#b11111"

/obj/effect/decal/turf_decal/green
	name = "Transparent Green Turf Decals"
	color = "#9fed58"

/obj/effect/decal/turf_decal/alpha
	name = "Transparent Turf Decals"
	alpha = 100

/obj/effect/decal/turf_decal/alpha/yellow
	name = "Transparent Yellow Turf Decals"
	color = "#ffff00"

/obj/effect/decal/turf_decal/alpha/cyan
	name = "Transparent Cyan Turf Decals"
	color = "#00ffff"

/obj/effect/decal/turf_decal/alpha/black
	name = "Transparent Black Turf Decals"
	color = "#000000"

/obj/effect/decal/turf_decal/alpha/red
	name = "Transparent Red Turf Decals"
	color = "#ff0000"

/obj/effect/decal/turf_decal/alpha/gray
	name = "Transparent Gray Turf Decals"
	color = "#666666"

/obj/effect/decal/turf_decal/alpha/orange
	name = "Transparent Orange Turf Decals"
	color = "#efb341"

/obj/effect/decal/turf_decal/alpha/white
	name = "Transparent White Turf Decals"
	color = "#bcbcbc"

/obj/effect/decal/turf_decal/alpha/purple
	name = "Transparent Purple Turf Decals"
	color = "#d381c9"

/obj/effect/decal/turf_decal/alpha/blue
	name = "Transparent Blue Turf Decals"
	color = "#52b4e9"

/obj/effect/decal/turf_decal/alpha/dark_red
	name = "Transparent Dark Red Turf Decals"
	color = "#b11111"

/obj/effect/decal/turf_decal/alpha/green
	name = "Transparent Green Turf Decals"
	color = "#9fed58"

// sidings / borders
/obj/effect/decal/turf_decal/wood
	name = "Wood Turf Decals"
	color = "#ffc500"

/obj/effect/decal/turf_decal/wood/dark
	name = "Dark Wood Turf Decals"
	color = "#5d341f"

/obj/effect/decal/turf_decal/metal
	name = "Metal Turf Decals"
	color = "#404040"

// special decals
/obj/effect/decal/turf_decal/goonplaque
	name = "Goon Plaque"
	icon_state = "plaque" // who resprited it as Tau Ceti? Possible we lost some goon reference

/obj/effect/decal/turf_decal/goonplaque/atom_init()
	. = ..()

	// maybe not the best way, but i want to get rid of plaque-turf
	var/turf/T = get_turf(src)
	T.name = "Comemmorative Plaque";
	T.desc = "\"Это металлический диск в честь наших товарищей на станциях G-4407. Надеемся, модель TG-4407 сможет служить на ваше благо.\" Ниже выцарапано грубое изображение метеора и космонавта. Космонавт смеется. Метеор взрывается.";

// modifiers
/obj/effect/decal/turf_decal/religion_emblem
	name = "Set as religion emblem place"
	icon_state = "religion_christianity"
	skip_decal = TRUE

/obj/effect/decal/turf_decal/religion_emblem/atom_init(mapload, new_state, new_dir, new_color, new_alpha)
	. = ..()
	// don't place decal, just mark for religion
	if(istype(loc, /turf/simulated/floor/carpet)) // why carpets? idk
		var/turf/simulated/floor/carpet/T = loc
		T.religion_tile = TRUE

	return INITIALIZE_HINT_QDEL

/obj/effect/decal/turf_decal/set_damaged
	name = "Set floor as damaged"

	icon = 'icons/turf/floors/damaged_overlays.dmi'
	icon_state = "damaged_1"

	skip_decal = TRUE

/obj/effect/decal/turf_decal/set_damaged/atom_init()
	. = ..()

	if(isfloorturf(loc)) // todo: unsim
		var/turf/simulated/floor/T = loc
		T.break_tile()
	else if(istype(loc, /turf/unsimulated/floor)) // fallback behaviour before we remove unsim
		var/turf/unsimulated/floor/T = loc
		T.add_overlay(mutable_appearance(icon, icon_state))

	return INITIALIZE_HINT_QDEL

/obj/effect/decal/turf_decal/set_burned
	name = "Set floor as burned"

	icon = 'icons/turf/floors/damaged_overlays.dmi'
	icon_state = "scorched_1"

	skip_decal = TRUE

/obj/effect/decal/turf_decal/set_burned/atom_init()
	. = ..()

	if(isfloorturf(loc)) // todo: unsim
		var/turf/simulated/floor/T = loc
		T.burn_tile()
	else if(istype(loc, /turf/unsimulated/floor)) // fallback behaviour before we remove unsim
		var/turf/unsimulated/floor/T = loc
		T.add_overlay(mutable_appearance(icon, icon_state))

	return INITIALIZE_HINT_QDEL
