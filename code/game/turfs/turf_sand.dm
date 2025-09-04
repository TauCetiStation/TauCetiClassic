/turf/environment/sand
	icon = 'icons/misc/beach.dmi'
	name = "sand"
	icon_state = "desert"
	plane = FLOOR_PLANE

	basetype = /turf/environment/grass
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_SAND

	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T150C
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 12000

	light_color = COLOR_SUN
	light_power = 2
	light_range = 2

/turf/environment/sand/atom_init(mapload)
	. = ..()
	if((type == /turf/environment/sand) && prob(10))
		icon_state += "[rand(0,4)]"

/turf/environment/sand/Destroy()
	SHOULD_CALL_PARENT(FALSE)
	return QDEL_HINT_LETMELIVE

/turf/environment/sand/attackby(obj/item/C, mob/user)
	build_floor_support(C, user, 100)

/turf/environment/sand/singularity_act()
	return

/turf/environment/sand/oasis
	name = "oasis"
	icon = 'icons/misc/beach.dmi'
	icon_state = "seashallow"

	basetype = /turf/environment/grass/lake
	footstep = FOOTSTEP_WATER_DEEP
	barefootstep = FOOTSTEP_WATER_DEEP
	clawfootstep = FOOTSTEP_WATER_DEEP
	heavyfootstep = FOOTSTEP_WATER_DEEP
	static_fluid_depth  = 800

/turf/environment/sand/oasis/atom_init()
	. = ..()
	AddComponent(/datum/component/fishing, list(/obj/item/fish_carp = 15, /obj/item/fish_carp/mega = 8, /obj/item/fish_carp/full_size = 5, /obj/item/fish_carp/over_size = 3, PATH_OR_RANDOM_PATH(/obj/random/mecha/wreckage) = 1, PATH_OR_RANDOM_PATH(/obj/random/cloth/shittysuit) = 1), 10 SECONDS, rand(1, 30) , 20)

/turf/environment/sand/oasis/Entered(atom/movable/AM, atom/old_loc)
	..()
	if(!istype(old_loc, type))
		AM.entered_water_turf()

/turf/environment/sand/oasis/Exited(atom/movable/AM, atom/new_loc)
	..()
	if(!istype(new_loc, type))
		AM.exited_water_turf()
