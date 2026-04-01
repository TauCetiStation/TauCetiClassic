/turf/unsimulated
	name = "command"
	plane = FLOOR_PLANE
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD

	flags = NOSTEPSOUND | NOBLOODY

/turf/unsimulated/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/turf/unsimulated/atom_init_late()
	levelupdate()
