/turf/simulated/floor/glass
	name = "glass floor"
	desc = "Don't jump on it, or do, I'm not your mom."

	floor_type = /obj/item/stack/tile/glass

	icon = 'icons/turf/floors/glass/glass.dmi'
	icon_state = "box"
	smooth = SMOOTH_TRUE

	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

	underfloor_accessibility = UNDERFLOOR_VISIBLE

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

/turf/simulated/floor/glass/reinforced
	name = "reinforced glass floor"
	desc = "Do jump on it, it can take it."

	floor_type = /obj/item/stack/tile/glass/reinforced

	icon = 'icons/turf/floors/glass/glass_reinforced.dmi'

/turf/simulated/floor/glass/phoron
	name = "phoron glass floor"
	desc = "Studies by the Nanotrasen Materials Safety Division have not yet determined if this is safe to jump on, do so at your own risk."

	floor_type = /turf/simulated/floor/glass/phoron

	icon = 'icons/turf/floors/glass/phoron_glass.dmi'

/turf/simulated/floor/glass/reinforced/phoron
	name = "reinforced phoron glass floor"
	desc = "Do jump on it, jump on it while in a mecha, it can take it."

	floor_type = /turf/simulated/floor/glass/reinforced/phoron

	icon = 'icons/turf/floors/glass/phoron_glass_reinforced.dmi'
