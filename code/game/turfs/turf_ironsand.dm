/turf/environment/ironsand
	name = "Iron Sand"
	icon = 'icons/turf/floors.dmi'
	icon_state = "ironsand1"
	plane = FLOOR_PLANE
	
	dynamic_lighting = DYNAMIC_LIGHTING_ENABLED
	force_lighting_update = TRUE

	basetype = /turf/environment/ironsand
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_SAND

	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 12000

	has_resources = TRUE

/turf/environment/ironsand/atom_init()
	. = ..()
	icon_state = "ironsand[rand(1, 15)]"

/turf/environment/ironsand/surround_by_scrap()
	if(prob(77))
		return FALSE
	if(prob(9))
		new /obj/structure/scrap/poor/structure(src)
		return TRUE
	else if(prob(17))
		new /obj/random/scrap/sparse_weighted(src)
		return TRUE
	if(prob(4))
		new /obj/item/blueprints/junkyard(src)
	if(prob(17))
		new /obj/effect/glowshroom(src)
	if(prob(26))
		var/decals_spawn = pick(/obj/effect/decal/cleanable/generic ,/obj/effect/decal/cleanable/ash, /obj/effect/decal/cleanable/molten_item, /obj/effect/decal/cleanable/vomit, /obj/effect/decal/cleanable/blood/oil)
		new decals_spawn(src)
	if(prob(26))
		new /obj/random/foods/food_trash(src)

	return TRUE
