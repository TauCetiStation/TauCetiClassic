/turf/simulated/floor/glass
	name = "glass floor"
	desc = "Магия зеркал позволяет добиться естественного освещения и красивой эстетики, абсолютно безопасным для станции способом."

	floor_type = /obj/item/stack/tile/glass

	icon = 'icons/turf/floors/glass/glass.dmi'
	icon_state = "box"
	smooth = SMOOTH_TRUE

	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

	underfloor_accessibility = UNDERFLOOR_HIDDEN

	var/image/environment_underlay

	level_light_source = TRUE

/turf/simulated/floor/glass/atom_init()
	update_icon()

	return ..()

/turf/simulated/floor/glass/update_icon()
	if(environment_underlay)
		underlays -= environment_underlay
	environment_underlay = SSenvironment.turf_image[z]
	underlays |= environment_underlay

/turf/simulated/floor/glass/make_plating()
	ChangeTurf(/turf/simulated/floor/plating)

/turf/simulated/floor/glass/proc/toggle_underfloor()
	if(underfloor_accessibility == UNDERFLOOR_VISIBLE)
		underfloor_accessibility = UNDERFLOOR_HIDDEN
	else
		underfloor_accessibility = UNDERFLOOR_VISIBLE

	levelupdate()

/turf/simulated/floor/glass/airless
	airless = TRUE

/turf/simulated/floor/glass/reinforced
	name = "reinforced glass floor"

	floor_type = /obj/item/stack/tile/glass/reinforced

	icon = 'icons/turf/floors/glass/glass_reinforced.dmi'


/turf/simulated/floor/glass/reinforced/airless
	airless = TRUE

/turf/simulated/floor/glass/phoron
	name = "phoron glass floor"

	floor_type = /turf/simulated/floor/glass/phoron

	icon = 'icons/turf/floors/glass/phoron_glass.dmi'

/turf/simulated/floor/glass/phoron/airless
	airless = TRUE

/turf/simulated/floor/glass/reinforced/phoron
	name = "reinforced phoron glass floor"

	floor_type = /turf/simulated/floor/glass/reinforced/phoron

	icon = 'icons/turf/floors/glass/phoron_glass_reinforced.dmi'

/turf/simulated/floor/glass/reinforced/phoron/airless
	airless = TRUE
