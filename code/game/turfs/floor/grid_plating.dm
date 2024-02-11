/**
 * ## catwalk flooring
 *
 * They show what's underneath their catwalk flooring (pipes and the like)
 * you can screwdriver it to interact with the underneath stuff without destroying the tile...
 * unless you want to!
 */
/turf/simulated/floor/grid_floor	//the base type, meant to look like a maintenance panel
	name = "grid floor"
	icon = 'icons/turf/floors/grid_plating.dmi'
	icon_state = "grid_1"
	desc = "Плитка показывает коммуникации под ней. Выбор инженеров!"
	floor_type = /obj/item/stack/tile/grid
	layer = TURF_CAP_LAYER
	footstep = FOOTSTEP_CATWALK
	underfloor_accessibility = UNDERFLOOR_VISIBLE
	var/covered = TRUE
	var/static/mutable_appearance/background

/turf/simulated/floor/grid_floor/atom_init(mapload)
	. = ..()
	if(!background)
		background = mutable_appearance(DEFAULT_UNDERLAY_ICON, DEFAULT_UNDERLAY_ICON_STATE, BELOW_TURF_LAYER, UNDERFLOOR_PLANE)
	underlays += background

/turf/simulated/floor/grid_floor/examine(mob/user)
	. = ..()

	if(covered)
		to_chat(user, "<span class='notice'>Вы можете <b>открутить</b> защитную решетку для доступа к содержимому.</span>")
	else
		to_chat(user, "<span class='notice'>Кто-то открутил защитную решетку. Вы можете <b>закрутить</b> её обратно.</span>")

/turf/simulated/floor/grid_floor/make_plating()
	ChangeTurf(/turf/simulated/floor/plating)

/turf/simulated/floor/grid_floor/proc/toggle_cower()
	covered = !covered
	if(!covered)
		underfloor_accessibility = UNDERFLOOR_INTERACTABLE
		icon_state = "[initial(icon_state)]_open"
		footstep = initial(footstep)
	else
		footstep = FOOTSTEP_FLOOR
		underfloor_accessibility = UNDERFLOOR_VISIBLE
		icon_state = initial(icon_state)

	levelupdate()
