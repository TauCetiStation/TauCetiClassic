/datum/catastrophe_event/carp_alert
	name = "Carp alert"

	one_time_event = TRUE

	weight = 100

	event_type = "harmful"
	steps = 3

	var/list/spawned_carp = list()
	var/wave_timer = 30
	var/check_timer = 30

	//manual_stop = TRUE // uncomment to make carp spawning unlimited

	var/carp_soft_limit = 10
	var/carp_hard_limit = 20

/datum/catastrophe_event/carp_alert/on_step()
	switch(step)
		if(1)
			announce("Èñõîä, íå çíàþ â êóðñå ëè âû, íî ýòî âðåì[JA_PLACEHOLDER] ãîäà [JA_PLACEHOLDER]âë[JA_PLACEHOLDER]åòñ[JA_PLACEHOLDER] áðà÷íûì ñåçîíîì äë[JA_PLACEHOLDER] êîñìè÷åñêèõ êàðïîâ. Îíè ñîáèðàþòñ[JA_PLACEHOLDER] â áîëüøèå ãðóïïû è ìîãóò ïðåäñòàâë[JA_PLACEHOLDER]òü áîëüøóþ óãðîçó. Áóäüòå îñòîðîæíû ð[JA_PLACEHOLDER]äîì ñ îêíàìè")
		if(2)
			announce("Âíèìàíèå, ïî íåèçâåñòíûì ïðè÷èíàì, êàðïû ñòàëè íåâåðî[JA_PLACEHOLDER]òíî àãðåññèâíûìè. Áóäüòå îñòîðîæíû, êîñìè÷åñêà[JA_PLACEHOLDER] ðûáàëêà çàïðåùåíà äî ñòàáèëèçàöèè ñèòóàöèè.")
			carp_soft_limit *= 2
			carp_hard_limit *= 2
		if(3)
			var/list/valid_marks = list()
			for(var/obj/effect/landmark/C in landmarks_list)
				if(C.name == "carpspawn")
					valid_marks += C

			announce("Âíèìàíèå, íà ðàäàðå îáíàðóæåíî íåèçâåñòíîå ñóùåñòâî. Ïî ôîðìå îíî íàïîìèíàåò… îãðîìíîãî êîñìè÷åñêîãî êàðïà. Îíî äâèæåòñ[JA_PLACEHOLDER] â ñòîðîíó âàøåé ñòàíöèè, Èñõîä. Ïðèãîòîâüòåñü ê áîþ")
			if(valid_marks.len)
				var/turf/T = pick(valid_marks).loc
				message_admins("Carp Queen was created in [T.x],[T.y],[T.z] [ADMIN_JMP(T)]")
				new /mob/living/simple_animal/hostile/carp/megacarp/boss(T)

/datum/catastrophe_event/carp_alert/process_event()
	..()

	if(spawned_carp.len < carp_soft_limit)
		wave_timer -= 1
	else if(spawned_carp.len < carp_hard_limit && prob(20)) // Slow down if there are too much carps
		wave_timer -= 1

	check_timer -= 1
	if(check_timer <= 0)
		check_timer = 30
		check_dead_carps()

	if(wave_timer <= 0)
		spawn_wave()
		wave_timer = rand(100, 300) // 3-10 mins or ~25 if there are >20 carps

/datum/catastrophe_event/carp_alert/proc/spawn_wave()
	for(var/obj/effect/landmark/C in landmarks_list)
		if(C.name == "carpspawn")
			if(prob(30))
				var/pack_size = rand(2, 4)
				for (var/i in 1 to pack_size)

					if(step >= 2)
						if(prob(80))
							spawned_carp.Add(new /mob/living/simple_animal/hostile/carp/angry(C.loc))
						else
							spawned_carp.Add(new /mob/living/simple_animal/hostile/carp/megacarp/angry(C.loc))
					else
						if(prob(95))
							spawned_carp.Add(new /mob/living/simple_animal/hostile/carp(C.loc))
						else
							spawned_carp.Add(new /mob/living/simple_animal/hostile/carp/megacarp(C.loc))

/datum/catastrophe_event/carp_alert/proc/check_dead_carps()
	for(var/mob/living/simple_animal/hostile/carp/C in spawned_carp)
		if(!C || C.stat == DEAD)
			spawned_carp -= C

// These ones will destroy any glass window they see
/mob/living/simple_animal/hostile/carp/angry
	search_objects = 1
	wanted_objects = list(/obj/structure/window/reinforced, /obj/structure/window/basic, /obj/structure/grille)

/mob/living/simple_animal/hostile/carp/megacarp/angry
	search_objects = 1
	wanted_objects = list(/obj/structure/window/reinforced, /obj/structure/window/basic, /obj/structure/grille)

// Moves towards a random station area, spawns minions-carps, has a ton of hp, looks scary
/mob/living/simple_animal/hostile/carp/megacarp/boss
	name = "carp queen"
	desc = "Is that even a fish? Looks more like a whale. Also, RUN"

	maxHealth = 2000
	health = 2000

	move_to_delay = 20

	environment_smash = 2

	wander = FALSE

	var/list/minions = list()
	var/max_minions = 5
	var/minions_timer = 0
	var/minions_move_timer = 2
	var/turf/target_turf
	var/new_target_turf_timer = 10
	turns_per_move = 2

	mouse_opacity = 1

	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/carpmeat = 10)


/mob/living/simple_animal/hostile/carp/megacarp/boss/atom_init()
	. = ..()

	var/matrix/Mx = matrix()
	Mx.Scale(3)
	Mx.Translate(0, 32)
	transform = Mx

	get_target_turf()

/mob/living/simple_animal/hostile/carp/megacarp/boss/proc/get_target_turf()
	var/area/impact_area = findEventArea()
	var/list/area_turfs = get_area_turfs(impact_area)
	var/try_count = 0
	while(!area_turfs.len && try_count < 10)
		impact_area = findEventArea()
		area_turfs = get_area_turfs(impact_area)
		try_count += 1
	if(area_turfs.len)
		target_turf = pick(area_turfs)

/mob/living/simple_animal/hostile/carp/megacarp/boss/Life()
	. = ..()

	if(stat == DEAD)
		return

	if(!client && !target && !stop_automated_movement && !anchored && target_turf)
		if(isturf(src.loc) && !resting && !buckled && canmove) // This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				step_towards(src, target_turf)
				turns_since_move = 0
		new_target_turf_timer -= 1
		if(new_target_turf_timer <= 0)
			new_target_turf_timer = 10
			get_target_turf()

	if(stance == HOSTILE_STANCE_IDLE)
		DestroySurroundings()


	if(minions.len < max_minions)
		minions_timer -= 1
	if(minions_timer <= 0)
		minions_timer = 2

	 	for (var/i in 1 to rand(1, 2))
	 		minions.Add(new /mob/living/simple_animal/hostile/carp(loc))

	for(var/mob/living/simple_animal/hostile/carp/C in minions)
		if(!C || C.stat == DEAD || get_dist(src, C) > 10)
			minions -= C

	minions_move_timer -= 1
	if(minions_move_timer <= 0)
		minions_move_timer = 5

		for(var/mob/living/simple_animal/hostile/carp/C in minions)
			if(!C.target)
				C.Goto(src, move_to_delay, minimum_distance = 3)

/mob/living/simple_animal/hostile/carp/megacarp/boss/DestroySurroundings()
	..()

	for(var/dir in cardinal) // North, South, East, West
		for(var/obj/machinery/door/firedoor/A in get_step(src, dir))
			if(A.density)
				if(A.blocked)
					A.blocked = FALSE
				A.open(TRUE)

		for(var/obj/machinery/door/airlock/A in get_step(src, dir))
			if(A.density)
				if(A.welded || A.locked)
					A.door_rupture(src)
					playsound(loc, pick('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg'), 50, 1)
				else
					A.open(TRUE)
