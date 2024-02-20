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
