/turf/unsimulated/wall
	name = "wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "riveted"
	opacity = 1
	density = 1

/turf/unsimulated/wall/fakeglass
	name = "window"
	icon_state = "fakewindows"
	opacity = 0

/turf/unsimulated/wall/splashscreen
	name = "Space Station 13"
	icon = 'icons/misc/fullscreen_loading.dmi'
	icon_state = "title"
	layer = FLY_LAYER

/turf/unsimulated/wall/splashscreen/atom_init()
	. = ..()
	var/newyear = FALSE
	#ifdef NEWYEARCONTENT
	icon = pick('icons/misc/fullscreen_newyear.dmi', 'icons/misc/fullscreen_leshiy.dmi')
	newyear = TRUE
	#endif
	if(!newyear)
		icon = pick('icons/misc/fullscreen_standart.dmi', 'icons/misc/fullscreen_leshiy.dmi')

/turf/unsimulated/wall/other
	icon_state = "r_wall"

/turf/unsimulated/wall/abductor
	icon_state = "alien1"
