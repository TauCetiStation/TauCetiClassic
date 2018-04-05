/client/spawn_fluid_proc()
	..()
	var/turf/T = get_turf(usr)
	for(var/thing in RANGE_TURFS(1, T))
		var/obj/effect/fluid/F = locate() in thing
		if(!F)
			F = new(thing)
		F.set_depth(2000)
