/turf/environment/grass
	icon = 'icons/turf/floors.dmi'
	name = "grass"
	icon_state = "grass1"
	plane = FLOOR_PLANE

	basetype = /turf/environment/grass
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	heavyfootstep = FOOTSTEP_GRASS

	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 12000

	level_light_source = TRUE

/turf/environment/grass/atom_init(mapload)
	. = ..()
	if(type == /turf/environment/grass)
		icon_state = "grass[rand(1,4)]"

/turf/environment/grass/Destroy()
	SHOULD_CALL_PARENT(FALSE)
	return QDEL_HINT_LETMELIVE

/turf/environment/grass/attackby(obj/item/C, mob/user)
	build_floor_support(C, user, 100)

/turf/environment/grass/singularity_act()
	return

/turf/environment/grass/lake
	name = "lake"
	icon = 'icons/misc/beach.dmi'
	icon_state = "seashallow"

	basetype = /turf/environment/grass/lake
	footstep = FOOTSTEP_WATER_DEEP
	barefootstep = FOOTSTEP_WATER_DEEP
	clawfootstep = FOOTSTEP_WATER_DEEP
	heavyfootstep = FOOTSTEP_WATER_DEEP
	static_fluid_depth  = 800

/turf/environment/grass/lake/atom_init()
	. = ..()
	AddComponent(/datum/component/fishing, list(/obj/item/fish_carp = 15, /obj/item/fish_carp/mega = 8, /obj/item/fish_carp/full_size = 5, /obj/item/fish_carp/over_size = 3, PATH_OR_RANDOM_PATH(/obj/random/mecha/wreckage) = 1, PATH_OR_RANDOM_PATH(/obj/random/cloth/shittysuit) = 1), 10 SECONDS, rand(1, 30) , 20)

/turf/environment/grass/lake/Entered(atom/movable/AM, atom/old_loc)
	..()
	if(!istype(old_loc, type))
		AM.entered_water_turf()

/turf/environment/grass/lake/Exited(atom/movable/AM, atom/new_loc)
	..()
	if(!istype(new_loc, type))
		AM.exited_water_turf()
