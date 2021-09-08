/turf/simulated/floor/transparent/glass
	name = "glass floor"
	icon_state = "reinf_glass"

/turf/simulated/floor/transparent/glass/atom_init()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/turf/simulated/floor/transparent/glass/atom_init_late()
	. = ..()
	AddElement(/datum/element/turf_z_transparency, TRUE)