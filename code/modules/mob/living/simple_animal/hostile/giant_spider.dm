
#define SPINNING_WEB 1
#define LAYING_EGGS 2
#define MOVING_TO_TARGET 3
#define SPINNING_COCOON 4

//basic spider mob, these generally guard nests
/mob/living/simple_animal/hostile/giant_spider
	name = "giant spider"
	desc = "Мохнатый и черный с тёмно-красными глазами. У вас бегают мурашки по коже, когда вы смотрите на него."
	var/butcher_state = 8 // Icon state for dead spider icons
	icon_state = "guard"
	icon_living = "guard"
	icon_dead = "guard_dead"
	icon_move = "guard_move"
	speak_emote = list("шипит")
	emote_hear = list("шипит")
	speak_chance = 5
	turns_per_move = 5
	see_in_dark = 10
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/spidermeat = 2, /obj/item/weapon/reagent_containers/food/snacks/spiderleg = 8)
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "pokes the"
	stop_automated_movement_when_pulled = FALSE
	maxHealth = 200
	health = 200
	melee_damage = 18
	heat_damage_per_tick = 20
	cold_damage_per_tick = 20
	var/poison_per_bite = 5
	var/poison_type = "toxin"
	faction = "spiders"
	var/busy = 0
	pass_flags = PASSTABLE
	move_to_delay = 6
	speed = 3
	environment_smash = 1
	weather_immunities = list("ash", "acid")

	has_head = TRUE
	has_leg = TRUE

//nursemaids - these create webs and eggs
/mob/living/simple_animal/hostile/giant_spider/nurse
	desc = "Мохнатый и черный с зелеными глазами. У вас бегают мурашки по коже, когда вы смотрите на него."
	icon_state = "nurse"
	icon_living = "nurse"
	icon_dead = "nurse_dead"
	icon_move = "nurse_move"
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/spidermeat = 2, /obj/item/weapon/reagent_containers/food/snacks/spiderleg = 8, /obj/item/weapon/reagent_containers/food/snacks/spidereggs = 4)
	maxHealth = 40
	health = 40
	melee_damage = 8
	poison_per_bite = 10
	var/atom/cocoon_target
	poison_type = "stoxin"
	var/fed = 0

//hunters have the most poison and move the fastest, so they can find prey
/mob/living/simple_animal/hostile/giant_spider/hunter
	desc = "Мохнатый и черный с фиолетовыми глазами. У вас бегают мурашки по коже, когда вы смотрите на него."
	icon_state = "hunter"
	icon_living = "hunter"
	icon_dead = "hunter_dead"
	icon_move = "hunter_move"
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/spidermeat = 2, /obj/item/weapon/reagent_containers/food/snacks/spiderleg = 8)
	maxHealth = 120
	health = 120
	melee_damage = 15
	poison_per_bite = 5
	move_to_delay = 4

/mob/living/simple_animal/hostile/giant_spider/UnarmedAttack(atom/target)
	..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.reagents)
			L.reagents.add_reagent("toxin", poison_per_bite)
			if(prob(poison_per_bite))
				to_chat(L, "<span class='warning'>Вы чувствуете слабый укол.</span>")
				L.reagents.add_reagent(poison_type, 5)

/mob/living/simple_animal/hostile/giant_spider/Life()
	..()
	if(stat == CONSCIOUS)
		if(stance == HOSTILE_STANCE_IDLE)
			//1% chance to skitter madly away
			if(!busy && prob(1))
				/*var/list/move_targets = list()
				for(var/turf/T in orange(20, src))
					move_targets.Add(T)*/
				stop_automated_movement = TRUE
				walk_to(src, pick(orange(20, src)), 1, move_to_delay)
				spawn(50)
					stop_automated_movement = FALSE
					walk(src,0)

/mob/living/simple_animal/hostile/giant_spider/nurse/proc/GiveUp(C)
	spawn(100)
		if(busy == MOVING_TO_TARGET)
			if(cocoon_target == C && get_dist(src,cocoon_target) > 1)
				cocoon_target = null
			busy = 0
			stop_automated_movement = FALSE

/mob/living/simple_animal/hostile/giant_spider/nurse/Life()
	..()
	if(stat == CONSCIOUS)
		if(stance == HOSTILE_STANCE_IDLE)
			var/list/can_see = view(src, 10)
			//30% chance to stop wandering and do something
			if(!busy && prob(30))
				//first, check for potential food nearby to cocoon
				for(var/mob/living/C in can_see)
					if(C.stat != CONSCIOUS)
						cocoon_target = C
						busy = MOVING_TO_TARGET
						walk_to(src, C, 1, move_to_delay)
						//give up if we can't reach them after 10 seconds
						GiveUp(C)
						return

				//second, spin a sticky spiderweb on this tile
				var/obj/structure/spider/stickyweb/W = locate() in get_turf(src)
				if(!W)
					busy = SPINNING_WEB
					visible_message("<span class='notice'>\the [src] begins to secrete a sticky substance.</span>")
					stop_automated_movement = TRUE
					spawn(40)
						if(busy == SPINNING_WEB)
							new /obj/structure/spider/stickyweb(src.loc)
							busy = 0
							stop_automated_movement = FALSE
				else
					//third, lay an egg cluster there
					var/obj/structure/spider/eggcluster/E = locate() in get_turf(src)
					if(!E && fed > 0)
						busy = LAYING_EGGS
						visible_message("<span class='notice'>\the [src] begins to lay a cluster of eggs.</span>")
						stop_automated_movement = TRUE
						spawn(50)
							if(busy == LAYING_EGGS)
								E = locate() in get_turf(src)
								if(!E)
									new /obj/structure/spider/eggcluster(src.loc)
									fed--
								busy = 0
								stop_automated_movement = FALSE
					else
						//fourthly, cocoon any nearby items so those pesky pinkskins can't use them
						for(var/obj/O in can_see)

							if(O.anchored)
								continue

							if(isitem(O) || istype(O, /obj/structure) || ismachinery(O))
								cocoon_target = O
								busy = MOVING_TO_TARGET
								stop_automated_movement = TRUE
								walk_to(src, O, 1, move_to_delay)
								//give up if we can't reach them after 10 seconds
								GiveUp(O)

			else if(busy == MOVING_TO_TARGET && cocoon_target)
				if(get_dist(src, cocoon_target) <= 1)
					busy = SPINNING_COCOON
					visible_message("<span class='notice'>\the [src] begins to secrete a sticky substance around \the [cocoon_target].</span>")
					stop_automated_movement = TRUE
					walk(src,0)
					spawn(50)
						if(busy == SPINNING_COCOON)
							if(cocoon_target && istype(cocoon_target.loc, /turf) && get_dist(src,cocoon_target) <= 1)
								var/obj/structure/spider/cocoon/C = new(cocoon_target.loc)
								var/large_cocoon = 0
								C.pixel_x = cocoon_target.pixel_x
								C.pixel_y = cocoon_target.pixel_y
								for(var/mob/living/M in C.loc)
									if(istype(M, /mob/living/simple_animal/hostile/giant_spider))
										continue
									large_cocoon = 1
									fed++
									visible_message("<span class='warning'>\the [src] sticks a proboscis into \the [cocoon_target] and sucks a viscous substance out.</span>")
									M.loc = C
									C.pixel_x = M.pixel_x
									C.pixel_y = M.pixel_y
									break
								for(var/obj/item/I in C.loc)
									I.loc = C
								for(var/obj/structure/S in C.loc)
									if(!S.anchored)
										S.loc = C
										large_cocoon = 1
								for(var/obj/machinery/M in C.loc)
									if(!M.anchored)
										M.loc = C
										large_cocoon = 1
								if(large_cocoon)
									C.icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")
							busy = 0
							stop_automated_movement = FALSE

		else
			busy = 0
			stop_automated_movement = FALSE

#undef SPINNING_WEB
#undef LAYING_EGGS
#undef MOVING_TO_TARGET
#undef SPINNING_COCOON
