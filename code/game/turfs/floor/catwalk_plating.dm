/**
 * ## catwalk flooring
 *
 * They show what's underneath their catwalk flooring (pipes and the like)
 * you can screwdriver it to interact with the underneath stuff without destroying the tile...
 * unless you want to!
 */
/turf/simulated/floor/catwalk_floor	//the base type, meant to look like a maintenance panel
	icon = 'icons/turf/floors/catwalk_plating.dmi'
	icon_state = "maint_above"
	name = "catwalk floor"
	//desc = "Плитка показывает коммуникации под ней. Выбор инженеров!"
	desc = "Это покрытие показывает коммуникации под ним. Выбор инженеров!"
	//floor_tile = /obj/item/stack/tile/catwalk_tile
	layer = CATWALK_LAYER
	footstep = FOOTSTEP_CATWALK
	underfloor_accessibility = UNDERFLOOR_VISIBLE
	var/covered = TRUE
	var/catwalk_type = "maint"
	var/static/list/catwalk_underlays = list()

/turf/simulated/floor/catwalk_floor/atom_init(mapload)
	. = ..()
	if(!catwalk_underlays[catwalk_type])
		var/mutable_appearance/plating_underlay = mutable_appearance(icon, "[catwalk_type]_below", TURF_LAYER)
		catwalk_underlays[catwalk_type] = plating_underlay
	underlays += catwalk_underlays[catwalk_type]
	//update_appearance()

/turf/simulated/floor/catwalk_floor/examine(mob/user)
	. = ..()

	if(covered)
		to_chat(user, "<span class='notice'>Вы можете <b>открутить</b> защитную крышку для доступа к содержимому.</span>")
	else
		to_chat(user, "<span class='notice'>Кто-то открыл защитную крышку. Вы можете <b>закрутить</b> её обратно.</span>")

/turf/simulated/floor/catwalk_floor/proc/toggle_cower()
	covered = !covered
	if(!covered)
		underfloor_accessibility = UNDERFLOOR_INTERACTABLE
		layer = TURF_LAYER
		icon_state = "[catwalk_type]_below"
	else
		underfloor_accessibility = UNDERFLOOR_VISIBLE
		layer = CATWALK_LAYER
		icon_state = "[catwalk_type]_above"

	levelupdate()
	//update_appearance()

//Reskins! More fitting with most of our tiles, and appear as a radial on the base type
/turf/simulated/floor/catwalk_floor/iron
	name = "iron plated catwalk floor"
	icon_state = "iron_above"
	//floor_tile = /obj/item/stack/tile/catwalk_tile/iron
	catwalk_type = "iron"

/turf/simulated/floor/catwalk_floor/iron_white
	name = "white plated catwalk floor"
	icon_state = "whiteiron_above"
	//floor_tile = /obj/item/stack/tile/catwalk_tile/iron_white
	catwalk_type = "whiteiron"

/turf/simulated/floor/catwalk_floor/iron_dark
	name = "dark plated catwalk floor"
	icon_state = "darkiron_above"
	//floor_tile = /obj/item/stack/tile/catwalk_tile/iron_dark
	catwalk_type = "darkiron"

/turf/simulated/floor/catwalk_floor/flat_white
	name = "white large plated catwalk floor"
	icon_state = "flatwhite_above"
	//floor_tile = /obj/item/stack/tile/catwalk_tile/flat_white
	catwalk_type = "flatwhite"

/turf/simulated/floor/catwalk_floor/titanium
	name = "titanium plated catwalk floor"
	icon_state = "titanium_above"
	//floor_tile = /obj/item/stack/tile/catwalk_tile/titanium
	catwalk_type = "titanium"


/turf/simulated/floor/catwalk_floor/iron_smooth //the original green type
	name = "smooth plated catwalk floor"
	icon_state = "smoothiron_above"
	//floor_tile = /obj/item/stack/tile/catwalk_tile/iron_smooth
	catwalk_type = "smoothiron"
