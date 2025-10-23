/turf/simulated/ocean
	flooded = "water"

// Map helpers.
/obj/effect/spawner/mapped_flood
	name = "mapped fluid area"
	alpha = FLUID_MAX_ALPHA
	icon_state = "ocean"
	color = COLOR_LIQUID_WATER
	var/fluid_type = "water"

/obj/effect/spawner/mapped_flood/atom_init(mapload, unset_flooded = FALSE)
	. = ..()
	var/turf/my_turf = get_turf(src)
	if(my_turf)
		if(!unset_flooded)
			my_turf.set_flooded(fluid_type)
		else
			my_turf.set_flooded(null)
	return INITIALIZE_HINT_QDEL
