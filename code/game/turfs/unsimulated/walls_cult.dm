/turf/unsimulated/wall/cult
	name = "wall"
	desc = "The patterns engraved on the wall seem to shift as you try to focus on them. You feel sick."
	icon = 'icons/turf/walls/cult/wall.dmi'
	icon_state = "box"
	canSmoothWith = list(/turf/simulated/wall/cult/runed/anim, /turf/simulated/wall/cult/runed, /turf/simulated/wall/cult, /turf/unsimulated/wall/cult, /turf/unsimulated/wall/cult/runed, /turf/unsimulated/wall/cult/runed/anim)

/turf/unsimulated/wall/cult/runed
	icon = 'icons/turf/walls/cult/runed.dmi'
	canSmoothWith = list(/turf/simulated/wall/cult/runed/anim, /turf/simulated/wall/cult/runed, /turf/simulated/wall/cult, /turf/unsimulated/wall/cult, /turf/unsimulated/wall/cult/runed, /turf/unsimulated/wall/cult/runed/anim)

/turf/unsimulated/wall/cult/runed/anim
	icon = 'icons/turf/walls/cult/runed_anim.dmi'
	canSmoothWith = list(/turf/simulated/wall/cult/runed/anim, /turf/simulated/wall/cult/runed, /turf/simulated/wall/cult, /turf/unsimulated/wall/cult, /turf/unsimulated/wall/cult/runed, /turf/unsimulated/wall/cult/runed/anim)

/turf/unsimulated/floor/cult
	name = "engraved floor"
	icon_state = "cult"

/turf/unsimulated/floor/cult/lava
	name = "lava"
	icon_state = "cultlava"
	light_color = "#9c660e"
	light_power = 2
	light_range = 3
