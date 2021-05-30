/turf/unsimulated/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "Floor3"

/turf/unsimulated/floor/abductor
	name = "alien floor"
	icon_state = "alienpod1"

/turf/unsimulated/floor/abductor/atom_init()
	. = ..()
	icon_state = "alienpod[rand(1,9)]"

/turf/unsimulated/floor/attack_paw(user)
	return src.attack_hand(user)
