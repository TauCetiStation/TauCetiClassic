/turf/environment/sand
	icon = 'icons/misc/beach.dmi'
	name = "sand"
	icon_state = "desert"
	plane = FLOOR_PLANE

	basetype = /turf/environment/sand
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
	if(prob(10))
		icon_state += "[rand(0,4)]"

/turf/environment/sand/Destroy()
	SHOULD_CALL_PARENT(FALSE)
	return QDEL_HINT_LETMELIVE

/turf/environment/sand/attackby(obj/item/C, mob/user)
	build_floor_support(C, user, 100)

/turf/environment/sand/singularity_act()
	return
