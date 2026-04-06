
#define SPINNING_WEB 1
#define LAYING_EGGS 2
#define MOVING_TO_TARGET 3
#define SPINNING_COCOON 4

//basic spider mob, these generally guard nests
/mob/living/simple_animal/hostile/giant_spider
	name = "giant spider"
	desc = "Мохнатый и черный с тёмно-красными глазами. У вас бегают мурашки по коже, когда вы смотрите на него."
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
	faction = "spiders"
	pass_flags = PASSTABLE
	move_to_delay = 6
	speed = 3
	environment_smash = 1
	weather_immunities = list("ash", "acid")

	has_head = TRUE
	has_leg = TRUE

	var/busy = 0
	var/web_mult = 1
	var/list/webs = list(/obj/structure/spider/stickyweb)
	var/food_mult = 0.5
	var/fed = 0
	var/poison_per_bite = 5
	var/poison_type = "toxin"
	var/list/spider_actions = list(/datum/action/innate/spider/evolve, /datum/action/innate/spider/spin_web, /datum/action/innate/spider/lay_egg_cluster, /datum/action/innate/spider/cocoon)
	var/reproduced = FALSE

/mob/living/simple_animal/hostile/giant_spider/atom_init(mapload)
	. = ..()
	var/datum/action/innate/spider/E
	for(var/V in spider_actions)
		E = new V (src)
		E.Grant(src)

/mob/living/simple_animal/hostile/giant_spider/LateLogin()
	. = ..()

/mob/living/simple_animal/hostile/giant_spider/CtrlClickOn(atom/A)
	if(get_dist(src, A) < 2 && !busy_with_action)
		if(isturf(A))
			spin_web(A)
		else if(istype(A, /obj/structure/spider/stickyweb))
			lay_egg_cluster(get_turf(A))
		else if(istype(A, /atom/movable))
			cocoon(A)
	. = ..()

/datum/action/innate/spider
	check_flags = AB_CHECK_INCAPACITATED

/datum/action/innate/spider/IsAvailable()
	if(!..())
		return
	if(!istype(owner, /mob/living/simple_animal/hostile/giant_spider))
		return FALSE
	return TRUE

/datum/action/innate/spider/spin_web
	name = "Spin web"
	button_icon_state = "lay_web"

/datum/action/innate/spider/spin_web/Activate()
	var/mob/living/simple_animal/hostile/giant_spider/S = owner
	S.spin_web(get_turf(src))

/datum/action/innate/spider/lay_egg_cluster
	name = "Lay egg cluster"
	button_icon_state = "lay_eggs"

/datum/action/innate/spider/lay_egg_cluster/Activate()
	var/mob/living/simple_animal/hostile/giant_spider/S = owner
	S.lay_egg_cluster(get_turf(src))

/datum/action/innate/spider/cocoon
	name = "Cocoon"
	button_icon_state = "wrap_0"

/datum/action/innate/spider/cocoon/Activate()
	var/mob/living/simple_animal/hostile/giant_spider/S = owner
	var/list/targets = list()
	for(var/atom/movable/T in range(1, S))
		if(istype(T, /obj/structure/spider/cocoon) || T.anchored)
			continue
		targets[T] = image(T.icon, icon_state = T.icon_state)
	var/atom/movable/radial_choose = show_radial_menu(owner, owner, targets, require_near = TRUE)
	S.cocoon(radial_choose)

/datum/action/innate/spider/evolve
	name = "Evolve"
	button_icon_state = "guard"

/datum/action/innate/spider/evolve/Activate()
	if(!isliving(owner))
		return
	var/mob/living/L = owner
	if(L.health < L.maxHealth)
		to_chat(src, "<span class='notice'>Мы слишком ранены, что бы эволюционировать.</span>")
		return
	var/static/tarantula = image(icon = 'icons/mob/animal.dmi', icon_state = "tarantula")
	var/static/viper = image(icon = 'icons/mob/animal.dmi', icon_state = "viper")
	var/static/midwife = image(icon = 'icons/mob/animal.dmi', icon_state = "midwife")

	var/list/options = list()
	options["Тарантула. Живучий, сильный, медленный. Охотится засадами в паутине."] = tarantula
	options["Вайпер. Слабый, медленный, плюется ядом. Охотится загонным образом."] = viper
	options["Вдова. Быстрая, среднеживучая, крайне ядовитая. Охотится методом бей-беги."] = midwife
	var/choise = show_radial_menu(owner, owner, options, tooltips = TRUE)
	switch(choise)
		if("Тарантула. Крепкий, сильный, медленный. Охотится засадами в паутине.")
			choise = /mob/living/simple_animal/hostile/giant_spider/tarantula
		if("Вайпер. Слабый, медленный, плюется ядом. Охотится загонным образом.")
			choise = /mob/living/simple_animal/hostile/giant_spider/viper
		if("Вдова. Быстрая, среднеживучая, крайне ядовитая. Охотится методом бей-беги.")
			choise = /mob/living/simple_animal/hostile/giant_spider/midwife
	if(!choise)
		return
	owner.visible_message("<span class='notice'>\the [src] begins to twist and shed it's chitin!</span>")
	if(!do_after(owner, 5 SECONDS, FALSE, owner))
		return
	if(!owner.client)
		return
	var/mob/living/simple_animal/hostile/giant_spider/S = new choise (get_turf(owner))
	S.ckey = owner.ckey

	var/obj/structure/spider/cocoon/C = new(owner.loc)
	owner.forceMove(C)
	QDEL_IN(C, 5 SECONDS)

	qdel(owner)

/mob/living/simple_animal/hostile/giant_spider/proc/spin_web(atom/A, web = /obj/structure/spider/stickyweb)
	var/turf/T = get_turf(A)
	var/n = 0
	for(var/obj/structure/spider/S in T)
		n++
	if(n > 3)
		to_chat(src, "<span class='notice'>Слишком много паутины в одном месте!</span>")
		return
	visible_message("<span class='notice'>\the [src] begins to secrete a sticky substance.</span>")

	var/choice = /obj/structure/spider/stickyweb
	if(length(webs) > 1 && client)
		var/list/options = list()
		for(var/obj/structure/spider/type in webs)
			options[initial(type.name)] = image(type.icon, icon_state = type.icon_state)

		choice = show_radial_menu(src, src, options, tooltips = TRUE)
		switch(choice)
			if("sticky web")
				choice = /obj/structure/spider/stickyweb
			if("web spikes")
				for(var/obj/structure/spider in T.contents)
					to_chat(src, "<span class='notice'>Шипы могут быть установлены лишь на открытом месте!</span>")
					return
				choice = /obj/structure/spider/spikes
			if("sticky web")
				choice = /obj/structure/spider/stickyweb/sticky
			if("sealed web")
				choice = /obj/structure/spider/stickyweb/sealed
			if("solid web")
				choice = /obj/structure/spider/stickyweb/solid
			if("Reflective silk screen")
				choice = /obj/structure/spider/stickyweb/reflector

	if(!do_after(src, 4 * web_mult SECONDS, FALSE, get_turf(T)))
		return

	new choice (get_turf(T))

/mob/living/simple_animal/hostile/giant_spider/proc/lay_egg_cluster(turf/T)
	if(!T)
		return
	var/obj/structure/spider/eggcluster/E = locate() in T
	if(E)
		to_chat(src, "<span class='notice'>Здесь уже есть кладка яиц. Нужно другое место.</span>")
		return
	if(fed < 1)
		to_chat(src, "<span class='notice'>Нужно кого-нибудь съесть, что бы создать кладку яиц.</span>")
		return
	visible_message("<span class='notice'>\the [src] begins to lay a cluster of eggs.</span>")
	if(!do_after(src, 6 SECONDS, FALSE, T))
		return
	E = new (T)
	E.sentient = TRUE
	fed--
	reproduced = TRUE

/mob/living/simple_animal/hostile/giant_spider/proc/cocoon(atom/movable/cocoon_target)
	if(get_dist(src, cocoon_target) > 1 || cocoon_target.anchored || cocoon_target == src)
		return
	visible_message("<span class='notice'>\the [src] begins to secrete a sticky substance around \the [cocoon_target].</span>")
	if(isliving(cocoon_target))
		var/mob/living/M = cocoon_target
		if(M.stat != DEAD) //To prevent unusual behaviour and abuse
			to_chat(src, "<span class='notice'>Жертва ещё трепыхается и мешает! Нужно её убить, прежде чем заворачивать.</span>")
			return
		if(fed)
			to_chat(src, "<span class='notice'>Мы пока не голодны. Нужно отложить яйцы!</span>")
			return
	if(!do_after(src, cocoon_target.w_class SECONDS, FALSE, cocoon_target)) //The bigger target - the more time it takes
		return
	if(cocoon_target && get_dist(src, cocoon_target) <= 1)
		var/obj/structure/spider/cocoon/C = new(cocoon_target.loc)
		C.pixel_x = cocoon_target.pixel_x
		C.pixel_y = cocoon_target.pixel_y
		if(isliving(cocoon_target))
			var/mob/living/M = cocoon_target
			if(istype(M, /mob/living/simple_animal/hostile/giant_spider)) //There is some dupe, but takes a long time
				fed += 0.1 * food_mult
			else
				fed += 1 * food_mult
			C.icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")
			visible_message("<span class='warning'>\the [src] sticks a proboscis into \the [cocoon_target] and sucks a viscous substance out.</span>")
			cocoon_target.forceMove(C)
			C.pixel_x = M.pixel_x
			C.pixel_y = M.pixel_y
		else
			cocoon_target.forceMove(C)
			if(cocoon_target.w_class > SIZE_NORMAL)
				icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")

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
	ranged = TRUE
	retreat_distance = 5
	minimum_distance = 5
	projectiletype = /obj/item/projectile/acid_special_spider
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged_cooldown = 5

/mob/living/simple_animal/hostile/giant_spider/UnarmedAttack(atom/target)
	..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.reagents)
			L.reagents.add_reagent("toxin", poison_per_bite)
			if(prob(poison_per_bite) || client)
				to_chat(L, "<span class='warning'>Вы чувствуете слабый укол.</span>")
				L.reagents.add_reagent(poison_type, 5)

/mob/living/simple_animal/hostile/giant_spider/Life()
	..()
	if(stat == CONSCIOUS && !client)
		if(stance == HOSTILE_STANCE_IDLE)
			//1% chance to skitter madly away
			if(!busy && prob(1))
				stop_automated_movement = TRUE
				var/list/D = orange(20, src)
				if(!length(D))
					return
				walk_to(src, pick(D), 1, move_to_delay)
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
	if(stop_automated_movement)
		return
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
					stop_automated_movement = TRUE
					spin_web()
					busy = FALSE
					stop_automated_movement = FALSE
				else
					//third, lay an egg cluster there
					busy = LAYING_EGGS
					stop_automated_movement = TRUE
					lay_egg_cluster(get_turf(src))
					busy = 0
					stop_automated_movement = FALSE

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
					stop_automated_movement = TRUE
					walk(src,0)
					cocoon(cocoon_target)
					busy = 0
					stop_automated_movement = FALSE

		else
			busy = 0
			stop_automated_movement = FALSE

#undef SPINNING_WEB
#undef LAYING_EGGS
#undef MOVING_TO_TARGET
#undef SPINNING_COCOON

/mob/living/simple_animal/hostile/giant_spider/tarantula
	name = "tarantula"
	desc = "Мохнатый и черный, а ещё большой. У вас бегают мурашки по коже, когда вы смотрите на него. У этого глаза красные"
	icon_state = "tarantula"
	icon_living = "tarantula"
	icon_dead = "tarantula_dead"
	icon_move = null
	maxHealth = 200
	health = 200
	melee_damage = 45
	poison_per_bite = 5
	poison_type = "toxin"
	speed = 3
	spider_actions = list(/datum/action/innate/spider/spin_web, /datum/action/innate/spider/lay_egg_cluster, /datum/action/innate/spider/cocoon)
	webs = list(/obj/structure/spider/stickyweb,
				/obj/structure/spider/spikes)
	environment_smash = 2

/mob/living/simple_animal/hostile/giant_spider/viper
	name = "viper spider"
	desc = "Мохнатый и черный. У вас бегают мурашки по коже, когда вы смотрите на него. У этого глаза ядовито-зеленые."
	icon_state = "viper"
	icon_living = "viper"
	icon_dead = "viper_dead"
	icon_move = null
	maxHealth = 55
	health = 55
	melee_damage = 15
	poison_per_bite = 5
	poison_type = "stoxin"
	speed = 0
	projectiletype = /obj/item/projectile/acid_special_spider
	spider_actions = list(/datum/action/innate/spider/spin_web, /datum/action/innate/spider/lay_egg_cluster, /datum/action/innate/spider/cocoon)
	//player_speed_modifier = -2.5

/mob/living/simple_animal/hostile/giant_spider/midwife
	name = "Midwife"
	desc = "Мохнатый и черный, а ещё большой. У вас бегают мурашки по коже, когда вы смотрите на него. У этого глаза ядовито-зеленые."
	gender = FEMALE
	icon_state = "midwife"
	icon_living = "midwife"
	icon_dead = "midwife_dead"
	icon_move = null
	poison_type = "stoxin"
	maxHealth = 100
	health = 100
	melee_damage = 15
	speed = -1.2
	spider_actions = list(/datum/action/innate/spider/spin_web, /datum/action/innate/spider/lay_egg_cluster, /datum/action/innate/spider/cocoon)

/mob/living/simple_animal/hostile/giant_spider/midwife/omnibuilder
	webs = list(/obj/structure/spider/stickyweb/reflector,
				/obj/structure/spider/spikes,
				/obj/structure/spider/stickyweb/solid,
				/obj/structure/spider/stickyweb/sealed,
				/obj/structure/spider/stickyweb/sticky,
				/obj/structure/spider/stickyweb)
	web_mult = 0.2
