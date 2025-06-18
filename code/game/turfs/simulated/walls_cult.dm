/turf/simulated/wall/cult
	name = "wall"
	desc = "Узоры, выгравированные на стене, двигаются и смещаются под вашим взглядом. Голова идёт кругом..."
	icon = 'icons/turf/walls/cult/wall.dmi'
	canSmoothWith = list(/turf/simulated/wall/cult, /turf/simulated/wall/cult/runed, /turf/simulated/wall/cult/runed/anim, /turf/unsimulated/wall/cult, /turf/unsimulated/wall/cult/runed, /turf/unsimulated/wall/cult/runed/anim)

/turf/simulated/wall/cult/runed
	icon = 'icons/turf/walls/cult/runed.dmi'
	canSmoothWith = list(/turf/simulated/wall/cult/runed, /turf/simulated/wall/cult/runed/anim, /turf/simulated/wall/cult, /turf/unsimulated/wall/cult, /turf/unsimulated/wall/cult/runed, /turf/unsimulated/wall/cult/runed/anim)

/turf/simulated/wall/cult/runed/anim
	icon = 'icons/turf/walls/cult/runed_anim.dmi'
	canSmoothWith = list(/turf/simulated/wall/cult/runed/anim, /turf/simulated/wall/cult/runed, /turf/simulated/wall/cult, /turf/unsimulated/wall/cult, /turf/unsimulated/wall/cult/runed, /turf/unsimulated/wall/cult/runed/anim)

/turf/simulated/floor/engine/cult
	name = "engraved floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "cult"

	smooth = FALSE

/turf/simulated/floor/engine/cult/lava
	name = "lava"
	icon_state = "cultlava"
	light_color = "#9c660e"
	light_power = 2
	light_range = 3
