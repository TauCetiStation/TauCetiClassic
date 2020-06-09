/turf/unsimulated/wall
	name = "wall"
	icon = 'icons/turf/walls/riveted.dmi'
	icon_state = "box"
	opacity = 1
	density = 1
	smooth = SMOOTH_TRUE

/turf/unsimulated/wall/iron
	icon = 'icons/turf/walls/iron.dmi'

/turf/unsimulated/wall/fakeglass
	name = "window"
	icon = 'icons/turf/walls/fakeglass.dmi'
	icon_state = "box"
	opacity = 0
	smooth = SMOOTH_TRUE

/turf/unsimulated/wall/splashscreen
	name = "Space Station 13"
	icon = 'icons/misc/fullscreen_loading.dmi'
	icon_state = "title"
	layer = FLY_LAYER
	smooth = FALSE

/turf/unsimulated/wall/splashscreen/atom_init()
	. = ..()
	var/newyear = FALSE
	#ifdef NEWYEARCONTENT
	icon = pick('icons/misc/fullscreen_newyear.dmi', 'icons/misc/fullscreen_leshiy.dmi')
	newyear = TRUE
	#endif
	if(!newyear)
		icon = pick('icons/misc/fullscreen_standart.dmi', 'icons/misc/fullscreen_leshiy.dmi')

/turf/unsimulated/wall/abductor
	icon = 'icons/turf/walls.dmi'
	icon_state = "alien1"
	smooth = FALSE
