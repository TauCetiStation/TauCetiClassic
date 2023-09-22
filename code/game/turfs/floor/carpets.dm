// todo: fix type paths to mach with icons

/* classic carpets */
/turf/simulated/floor/carpet
	name = "red classic carpet"
	icon_state = "center_8" // for webmap and map editors only, "box" is too noisy

	floor_type = /obj/item/stack/tile/carpet

	icon = 'icons/turf/floors/carpets/carpet_classic_red.dmi'
	smooth = SMOOTH_TRUE

	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	clawfootstep = FOOTSTEP_CARPET_BAREFOOT

	var/religion_tile = FALSE // todo: why religion so in love with carpets?

/turf/simulated/floor/carpet/make_plating()
	ChangeTurf(/turf/simulated/floor/plating)

/turf/unsimulated/floor/carpet // copypaste because we still have unsim as different type :(
	name = "red classic carpet"
	icon_state = "center_8"
	icon = 'icons/turf/floors/carpets/carpet_classic_red.dmi'
	smooth = SMOOTH_TRUE

/turf/simulated/floor/holofloor/carpet // pain
	name = "red classic carpet"
	icon_state = "center_8"
	icon = 'icons/turf/floors/carpets/carpet_classic_red.dmi'
	smooth = SMOOTH_TRUE

/turf/simulated/floor/plating/airless/carpet // PAIN
	name = "red classic carpet"
	icon_state = "center_8"
	icon = 'icons/turf/floors/carpets/carpet_classic_red.dmi'
	smooth = SMOOTH_TRUE

/turf/simulated/floor/plating/airless/carpet/make_plating()
	ChangeTurf(/turf/simulated/floor/plating)

/turf/simulated/floor/carpet/green
	name = "green classic carpet"
	icon = 'icons/turf/floors/carpets/carpet_classic_green.dmi'
	floor_type = /obj/item/stack/tile/carpet/green

/turf/unsimulated/floor/carpet/green
	name = "green classic carpet"
	icon = 'icons/turf/floors/carpets/carpet_classic_green.dmi'


/turf/simulated/floor/carpet/cyan
	name = "cyan classic carpet"
	floor_type = /obj/item/stack/tile/carpet/cyan
	icon = 'icons/turf/floors/carpets/carpet_classic_cyan.dmi'

/turf/unsimulated/floor/carpet/cyan
	name = "cyan classic carpet"
	icon = 'icons/turf/floors/carpets/carpet_classic_cyan.dmi'

/* lattice carpets */
/turf/simulated/floor/carpet/black
	name = "black lattice carpet"
	icon = 'icons/turf/floors/carpets/carpet_lattice_black.dmi'
	floor_type = /obj/item/stack/tile/carpet/black

/turf/unsimulated/floor/carpet/black
	name = "black lattice carpet"
	icon = 'icons/turf/floors/carpets/carpet_lattice_black.dmi'


/turf/simulated/floor/carpet/purple
	name = "purple lattice carpet"
	icon = 'icons/turf/floors/carpets/carpet_lattice_purple.dmi'
	floor_type = /obj/item/stack/tile/carpet/purple

/turf/unsimulated/floor/carpet/purple
	name = "purple lattice carpet"
	icon = 'icons/turf/floors/carpets/carpet_lattice_purple.dmi'


/turf/simulated/floor/carpet/orange
	name = "orange lattice carpet"
	icon = 'icons/turf/floors/carpets/carpet_lattice_orange.dmi'
	floor_type = /obj/item/stack/tile/carpet/orange

/turf/unsimulated/floor/carpet/orange
	name = "orange lattice carpet"
	icon = 'icons/turf/floors/carpets/carpet_lattice_orange.dmi'


/turf/simulated/floor/carpet/blue
	name = "blue lattice carpet"
	icon = 'icons/turf/floors/carpets/carpet_lattice_blue.dmi'
	floor_type = /obj/item/stack/tile/carpet/blue

/turf/unsimulated/floor/carpet/blue
	name = "blue lattice carpet"
	icon = 'icons/turf/floors/carpets/carpet_lattice_blue.dmi'


/turf/simulated/floor/carpet/blue2
	name = "lightblue lattice carpet"
	icon = 'icons/turf/floors/carpets/carpet_lattice_lightblue.dmi'
	floor_type = /obj/item/stack/tile/carpet/blue2

/turf/unsimulated/floor/carpet/blue2
	name = "lightblue lattice carpet"
	icon = 'icons/turf/floors/carpets/carpet_lattice_lightblue.dmi'


/turf/simulated/floor/carpet/red
	name = "red lattice carpet"
	icon = 'icons/turf/floors/carpets/carpet_lattice_red.dmi'
	floor_type = /obj/item/stack/tile/carpet/red

/turf/unsimulated/floor/carpet/red
	name = "red lattice carpet"
	icon = 'icons/turf/floors/carpets/carpet_lattice_red.dmi'
