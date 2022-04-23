/turf/simulated/wall/cult
	name = "wall"
	desc = "Узоры, выгравированные на стене, похоже сдвигаются когда вы пытаетесь на них сфокусироваться. Вы чувствуете себя дурно."
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
	icon_state = "cult"

/turf/simulated/floor/engine/cult/lava
	name = "lava"
	icon_state = "cultlava"
	light_color = "#9c660e"
	light_power = 2
	light_range = 3
