/obj/structure/lattice
	desc = "A lightweight support lattice."
	name = "lattice"
	icon = 'icons/obj/structures.dmi'
	icon_state = "latticefull"
	density = 0
	anchored = 1.0
	layer = 2.3 //under pipes
	plane = FLOOR_PLANE
	//	flags = CONDUCT

/obj/structure/lattice/atom_init()
	. = ..()
	if(!istype(loc, /turf/space))
		return INITIALIZE_HINT_QDEL
	for(var/obj/structure/lattice/LAT in loc)
		if(LAT != src)
			warning("Found stacked lattice at [COORD(src)] while initializing map.")
			QDEL_IN(LAT, 0)
	icon = 'icons/obj/smoothlattice.dmi'
	icon_state = "latticeblank"
	updateOverlays()
	for (var/dir in cardinal)
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, get_step(src, dir))
		if(L)
			L.updateOverlays()

/obj/structure/lattice/Destroy()
	for (var/dir in cardinal)
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, get_step(src, dir))
		if(L)
			L.updateOverlays(loc)
	return ..()

/obj/structure/lattice/blob_act()
	qdel(src)
	return

/obj/structure/lattice/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			qdel(src)
			return
		if(3.0)
			return
		else
	return

/obj/structure/lattice/attackby(obj/item/C, mob/user)

	if(istype(C, /obj/item/stack/tile/plasteel) || istype(C, /obj/item/stack/rods))
		var/turf/T = get_turf(src)
		T.attackby(C, user) //BubbleWrap - hand this off to the underlying turf instead
		return
	if (iswelder(C))
		var/obj/item/weapon/weldingtool/WT = C
		if(WT.use(0, user))
			to_chat(user, "<span class='notice'>Slicing lattice joints ...</span>")
			new /obj/item/stack/rods(loc)
			qdel(src)

	return

/obj/structure/lattice/proc/updateOverlays()
	//if(!(istype(src.loc, /turf/space)))
	//	qdel(src)
	spawn(1)
		cut_overlays()

		var/dir_sum = 0

		for (var/direction in cardinal)
			if(locate(/obj/structure/lattice, get_step(src, direction)))
				dir_sum += direction
			else
				if(!(istype(get_step(src, direction), /turf/space)))
					dir_sum += direction

		icon_state = "lattice[dir_sum]"
		return
