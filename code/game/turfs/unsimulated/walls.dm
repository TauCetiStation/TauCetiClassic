/turf/unsimulated/wall
	name = "wall"
	icon = 'icons/turf/walls/riveted.dmi'
	icon_state = "box"
	plane = GAME_PLANE
	opacity = 1
	density = TRUE
	smooth = SMOOTH_TRUE
	canSmoothWith = CAN_SMOOTH_WITH_WALLS

/turf/unsimulated/wall/iron
	icon = 'icons/turf/walls/iron.dmi'

/turf/unsimulated/wall/log
	icon = 'icons/turf/walls/log.dmi'

/turf/unsimulated/wall/abductor
	icon = 'icons/turf/walls.dmi'
	icon_state = "alien1"
	smooth = FALSE

/turf/unsimulated/wall/fakealien
	name = "alien wall"
	icon = 'icons/obj/smooth_structures/alien/resin_wall.dmi'
	icon_state = "box"
	canSmoothWith = list(/obj/structure/alien/resin/wall, /obj/structure/alien/resin/membrane)

/turf/unsimulated/wall/fakealienmembrane
	name = "alien membrane"
	icon = 'icons/obj/smooth_structures/alien/resin_membrane.dmi'
	icon_state = "box"
	opacity = FALSE
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/obj/structure/alien/resin/wall, /obj/structure/alien/resin/membrane)

/turf/unsimulated/wall/like_a_normal
	name = "wall"
	desc = "Огромный кусок металла для разделения комнат."
	icon = 'icons/turf/walls/has_false_walls/wall.dmi'
	icon_state = "box"

	canSmoothWith = CAN_SMOOTH_WITH_WALLS
	smooth_adapters = SMOOTH_ADAPTERS_WALLS_FOR_WALLS
	smooth = SMOOTH_TRUE

/turf/unsimulated/wall/like_a_normal/yellow
	icon = 'icons/turf/walls/has_false_walls/wall_yellow.dmi'

/turf/unsimulated/wall/like_a_normal/red
	icon = 'icons/turf/walls/has_false_walls/wall_red.dmi'

/turf/unsimulated/wall/like_a_normal/purple
	icon = 'icons/turf/walls/has_false_walls/wall_purple.dmi'

/turf/unsimulated/wall/like_a_normal/green
	icon = 'icons/turf/walls/has_false_walls/wall_green.dmi'

/turf/unsimulated/wall/like_a_normal/beige
	icon = 'icons/turf/walls/has_false_walls/wall_beige.dmi'

