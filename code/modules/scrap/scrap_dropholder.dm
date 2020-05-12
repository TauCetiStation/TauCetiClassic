/obj/effect/falling_effect
	name = "you should not see this"
	desc = "no data"
	invisibility = 101
	anchored = 1
	density = 0
	var/falling_type = /obj/random/scrap/moderate_weighted

/obj/effect/falling_effect/atom_init(mapload, type = /obj/random/scrap/moderate_weighted)
	..()
	falling_type = type
	return INITIALIZE_HINT_LATELOAD

/obj/effect/falling_effect/atom_init_late()
	new falling_type(src)
	var/atom/movable/dropped = pick(src.contents) //stupid, but allows to get spawn result without efforts if it is other type
	dropped.loc = get_turf_loc(src)
	var/initial_x = dropped.pixel_x
	var/initial_y = dropped.pixel_y
	dropped.plane = 1
	dropped.pixel_x = rand(-150, 150)
	dropped.pixel_y = 500 //when you think that pixel_z is height but you are wrong
	dropped.density = 0
	dropped.opacity = 0
	animate(dropped, pixel_y = initial_y, pixel_x = initial_x , time = 7)
	addtimer(CALLBACK(dropped, /atom/movable.proc/end_fall), 7)
	qdel(src)

/atom/movable/proc/end_fall()
	for(var/atom/movable/AM in loc)
		if(AM != src)
			AM.ex_act(1)
	for(var/mob/living/M in oviewers(6, src))
		shake_camera(M, 2, 2)
	if(istype(src, /obj/structure/scrap))
		playsound(src, 'sound/effects/scrap_fall.ogg', VOL_EFFECTS_MASTER)
	else
		playsound(src, 'sound/effects/meteorimpact.ogg', VOL_EFFECTS_MASTER)
	density = initial(density)
	opacity = initial(opacity)
	plane = initial(plane)

/obj/effect/falling_effect/ex_act()
	return
