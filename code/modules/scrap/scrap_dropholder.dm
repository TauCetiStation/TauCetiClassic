/obj/effect/falling_effect
	name = "you should not see this"
	desc = "no data"
	invisibility = 101
	anchored = 1
	density = 0
	var/falling_type = /obj/random/scrap/moderate_weighted

/obj/effect/falling_effect/New(var/turf/spawnloc, var/type = /obj/random/scrap/moderate_weighted)
	..(spawnloc)
	falling_type = type
	new falling_type(src)
	var/atom/movable/dropped = pick(src.contents) //stupid, but allows to get spawn result without efforts if it is other type
	dropped.loc = get_turf_loc(src)
	var/initial_x = dropped.pixel_x
	var/initial_y = dropped.pixel_y
	dropped.pixel_x = rand(-150, 150)
	dropped.pixel_y = 500 //when you think that pixel_z is height but you are wrong
	dropped.density = 0
	dropped.opacity = 0
	animate(dropped, pixel_y = initial_y, pixel_x = initial_x , time = 7)
	spawn(7)
		for(var/atom/movable/T in dropped.loc)
			if(T != dropped)
				T.ex_act(1)
		for(var/mob/living/M in oviewers(6, dropped))
			shake_camera(M, 2, 2)
		playsound(dropped.loc, 'sound/effects/meteorimpact.ogg', 50, 1)
		dropped.density = initial(dropped.density)
		dropped.opacity = initial(dropped.opacity)
	qdel(src)

/obj/effect/falling_effec/ex_act()
	return