/turf/unsimulated/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"

/turf/unsimulated/floor/attack_paw(user)
	return attack_hand(user)

/turf/unsimulated/floor/abductor
	name = "alien floor"
	icon_state = "alienpod1"

/turf/unsimulated/floor/abductor/atom_init()
	. = ..()
	icon_state = "alienpod[rand(1,9)]"

/turf/unsimulated/floor/fakealien
	name = "alien weed"
	icon = 'icons/mob/xenomorph.dmi'
	icon_state = "weeds"

/turf/unsimulated/floor/fakealien/weednode
	icon_state = "weednode"

/turf/unsimulated/floor/snow
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"

/turf/unsimulated/floor/fakespace
	name = "space"
	icon = 'icons/turf/space.dmi'
	icon_state = "0"
