/obj/effect/junkyard_beacon
	name = "Junkyard Beacon"
	var/amount_of_garbage = 0
	var/amount_of_centipedes = 0
	var/amount_of_aggressive = 0
	var/delay_process = 60
	var/process = 0
	var/delay_process_pile = 7
	var/process_pile = 0
	var/max_centipedes = 16
	var/max_aggressive = 6
	var/max_garbage = 600
	var/area/parent_area
	var/list/cordinate

/obj/effect/junkyard_beacon/atom_init()
	. = ..()
	parent_area = get_area(src)
	LAZYINITLIST(cordinate)
	for(var/turf/simulated/floor/plating/ironsand/junkyard/turf_junk in parent_area.contents)
		LAZYADD(cordinate, "[turf_junk.x], [turf_junk.y]")

/obj/effect/junkyard_beacon/process()
	process +=1
	if(process >= delay_process)

		if(amount_of_garbage > max_garbage/6 && amount_of_centipedes < max_centipedes/4)
			new /mob/living/simple_animal/centipede(pick(turf_spawn_list))
		if(amount_of_garbage > max_garbage/2 && amount_of_centipedes < max_centipedes/2)
			new /mob/living/simple_animal/centipede(pick(turf_spawn_list))
		if(amount_of_garbage > max_garbage && amount_of_centipedes < max_centipedes)
			new /mob/living/simple_animal/centipede(pick(turf_spawn_list))

		if(amount_of_aggressive < max_aggressive/2 && prob(20))
			new /obj/random/mobs/dangerous(pick(turf_spawn_list))
		if(amount_of_aggressive < max_aggressive && prob(40))
			new /obj/random/mobs/moderate(pick(turf_spawn_list))

		process_pile += 1

		if(process_pile >= delay_process_pile)
			var/turf/spawn_pile = pick(turf_spawn_list)
			var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread(spawn_pile)
			smoke.set_up(5, 0, spawn_pile)
			smoke.start()
			if(max_aggressive < amount_of_aggressive)
				if(prob(50))
					new /obj/random/mobs/dangerous(spawn_pile)
				else
					new /obj/random/mobs/moderate(spawn_pile)
			new /obj/effect/scrap_pile_generator(spawn_pile)
			process_pile = 0

		process = 0