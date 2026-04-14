
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
	unsuitable_atoms_damage = 8	// This damage is taken when atmos doesn't fit all the requirements above
	faction = "spiders"
	pass_flags = PASSTABLE
	move_to_delay = 6
	speed = 3
	environment_smash = 1
	weather_immunities = list("ash", "acid")
	projectilesound = 'sound/weapons/pierce.ogg'

	has_head = TRUE
	has_leg = TRUE
	can_point = TRUE
	universal_understand = TRUE

	///Used only by bot
	var/busy = 0
	///How fast we can produce webs
	var/web_mult = 1
	///List of available webs
	var/list/webs = list(/obj/structure/spider/stickyweb)
	///How much food we currantly have. To reproduce we need 1.
	var/fed = 0
	///How much poison we inject on attack
	var/poison_per_bite = 5
	///What poison we inject on attack
	var/poison_type = "toxin"
	///Actions we will have on atom init
	var/list/spider_actions = list(/datum/action/innate/spider/evolve, /datum/action/innate/spider/spin_web, /datum/action/innate/spider/lay_egg_cluster, /datum/action/innate/spider/cocoon)
	///How many times we reproduced. Used in adaptation action, plus objective
	var/reproduced = 0
	///Num to which we change our alpha if we get on web
	var/alpha_change = 255
	///Upgrades we got
	var/list/adaptations = list()
	///How many upgrades we got by inheretence
	var/inhereted = 0
	///Can we speak to ALL spiders at once
	var/can_speak_hivemind = FALSE

/mob/living/simple_animal/hostile/giant_spider/atom_init(mapload, passed_adaptations)
	. = ..()
	if(passed_adaptations)
		adaptations = passed_adaptations
		inhereted = length(passed_adaptations)

	var/datum/action/innate/spider/E
	for(var/V in spider_actions)
		E = new V (src)
		E.Grant(src)

	AddElement(/datum/element/prevent_attacking_of_types, global.typecache_general_bad_attack_targets, "This tastes awful!")

/mob/living/simple_animal/hostile/giant_spider/Life()
	. = ..()
	health = min(health + maxHealth * 0.01, maxHealth) //1% regen per tick

/mob/living/simple_animal/hostile/giant_spider/LateLogin()
	. = ..()
	name = "[initial(name)] ([rand(100, 999)])"
	if(!isrolebytype(/datum/role/spider, src))
		if(!SSticker?.mode) //We have someone logged in before roundstart, so we need to create faction later, after roundstart
			RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(on_start_spider))
			return
		var/datum/faction/spiders/F = create_uniq_faction(/datum/faction/spiders)
		add_faction_member(F, src, FALSE)

/mob/living/simple_animal/hostile/giant_spider/proc/on_start_spider()
	var/datum/faction/spiders/F = create_uniq_faction(/datum/faction/spiders)
	add_faction_member(F, src, FALSE)
	UnregisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING)

/mob/living/simple_animal/hostile/giant_spider/Moved(atom/OldLoc, Dir)
	. = ..()
	var/web = FALSE
	for(var/obj/structure/spider/stickyweb/W in get_turf(loc))
		web = TRUE
		if(alpha > alpha_change)
			animate(src, 1 SECOND, alpha = alpha_change)
		return
	if(!web)
		alpha = 255

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
	if(owner.busy_with_action)
		return FALSE
	return TRUE

/datum/action/innate/spider/spin_web
	name = "Spin web"
	button_icon_state = "lay_web"

/datum/action/innate/spider/spin_web/Activate()
	var/mob/living/simple_animal/hostile/giant_spider/S = owner
	S.spin_web(get_turf(S))

/datum/action/innate/spider/lay_egg_cluster
	name = "Lay egg cluster"
	button_icon_state = "lay_eggs"

/datum/action/innate/spider/lay_egg_cluster/Activate()
	var/mob/living/simple_animal/hostile/giant_spider/S = owner
	S.lay_egg_cluster(get_turf(S))

/datum/action/innate/spider/cocoon
	name = "Cocoon"
	button_icon_state = "wrap_0"

/datum/action/innate/spider/cocoon/Activate()
	var/mob/living/simple_animal/hostile/giant_spider/S = owner
	var/list/targets = list()
	for(var/atom/movable/T in range(1, S))
		if(istype(T, /obj/structure/spider/cocoon) || T == S || T.anchored)
			continue
		targets[T] = image(T.icon, icon_state = T.icon_state)
	var/atom/movable/radial_choose = show_radial_menu(owner, owner, targets, require_near = TRUE)
	S.cocoon(radial_choose)

/mob/living/simple_animal/hostile/giant_spider/say(message)

	if(silent)
		return

	message = sanitize(message)

	if(!message)
		return
	if(stat == DEAD)
		return say_dead(message)

	if(message[1] == "*")
		return emote(copytext(message, 2))

	if(length(message) >= 1)
		if(message[1] == ";" && can_speak_hivemind)
			message = copytext(message, 1 + length(message[1]))
			message = trim(message)
			spider_talk(message)
			return

	if(stat == CONSCIOUS)
		return ..(message)

/mob/living/simple_animal/hostile/giant_spider/proc/spider_talk(message)
	if(!message)
		return

	message = trim(message)
	log_say("[key_name(src)] : УЛЕЙ: [name] шепчет, [message]")

	var/rendered = "<span class='hive'>УЛЕЙ: <i>[name] шепчет, \"[message]\"</i></span>"
	var/datum/faction/spiders/F = find_faction_by_type(/datum/faction/spiders)
	for(var/datum/role/R in F.members)
		var/mob/M = R.antag?.current
		if(M && M.stat == CONSCIOUS && M.client)
			M.show_message(rendered, SHOWMSG_AUDIO)

	for(var/mob/M as anything in observer_list)
		if(!M.client)
			continue
		var/tracker = FOLLOW_LINK(M, src)
		to_chat(M, "[tracker] [rendered]")

/datum/action/innate/spider/evolve
	name = "Evolve"
	button_icon_state = "guard"
	COOLDOWN_DECLARE(ready2evolve)

/datum/action/innate/spider/evolve/Grant(mob/T)
	. = ..()
	COOLDOWN_START(src, ready2evolve, 3 MINUTES)
	to_chat(T, "<span class='notice'>Нам нужно пережить 3 минуты, что бы эволюционировать.</span>")

/datum/action/innate/spider/evolve/Activate()
	if(!isliving(owner))
		return
	if(!COOLDOWN_FINISHED(src, ready2evolve))
		var/timeleft = round(COOLDOWN_TIMELEFT(src, ready2evolve) * 0.1)
		to_chat(owner, "<span class='notice'>Нам нужно пережить еще [timeleft] [pluralize_russian(timeleft, "секунду", "секунды", "секунд")], что бы эволюционировать.</span>")
		return
	var/mob/living/L = owner
	if(L.health < L.maxHealth)
		to_chat(owner, "<span class='notice'>Мы слишком ранены, что бы эволюционировать.</span>")
		return
	var/static/tarantula = image(icon = 'icons/mob/animal.dmi', icon_state = "tarantula")
	var/static/viper = image(icon = 'icons/mob/animal.dmi', icon_state = "viper")
	var/static/midwife = image(icon = 'icons/mob/animal.dmi', icon_state = "midwife")
	var/list/options = list()
	options["Тарантула. Живучий, сильный, медленный. Охотится засадами в паутине."] = tarantula
	options["Вайпер. Слабый, медленный, плюется ядом. Охотится загонным образом."] = viper
	options["Вдова. Быстрая, среднеживучая, крайне ядовитая. Охотится методом бей-беги."] = midwife
	var/choice = show_radial_menu(owner, owner, options, tooltips = TRUE)
	switch(choice)
		if("Тарантула. Живучий, сильный, медленный. Охотится засадами в паутине.")
			choice = /mob/living/simple_animal/hostile/giant_spider/tarantula
		if("Вайпер. Слабый, медленный, плюется ядом. Охотится загонным образом.")
			choice = /mob/living/simple_animal/hostile/giant_spider/viper
		if("Вдова. Быстрая, среднеживучая, крайне ядовитая. Охотится методом бей-беги.")
			choice = /mob/living/simple_animal/hostile/giant_spider/midwife
	if(!choice)
		return
	owner.visible_message("<span class='notice'>\the [src] begins to twist and shed it's chitin!</span>")
	if(!do_after(owner, 5 SECONDS, FALSE, owner))
		return
	if(!owner.client)
		return
	var/mob/living/simple_animal/hostile/giant_spider/old_s = owner
	var/mob/living/simple_animal/hostile/giant_spider/S = new choice (get_turf(owner), old_s?.adaptations, old_s?.inhereted)

	S.mind = old_s.mind
	old_s.mind.set_current(S)
	S.key = old_s.key

	qdel(old_s)
	var/obj/structure/spider/cocoon/C = new(owner.loc)
	S.forceMove(C)
	QDEL_IN(C, 5 SECONDS)

/datum/action/innate/spider/evolve/adapt
	name = "Adaptation"
	var/list/options = list()

/datum/action/innate/spider/evolve/adapt/Activate()
	if(!istype(owner, /mob/living/simple_animal/hostile/giant_spider))
		return
	var/mob/living/simple_animal/hostile/giant_spider/S = owner
	if(S.health < S.maxHealth)
		to_chat(owner, "<span class='notice'>Мы слишком ранены, что бы эволюционировать.</span>")
		return
	if(length(S.adaptations) >= S.reproduced + S.inhereted)
		to_chat(owner, "<span class='notice'>Для эволюции нужно оставить потомство!</span>")
		return
	if(!length(options))
		to_chat(owner, "<span class='notice'>Нам некуда более эволюционировать! Мы сильнейший космо-паук!</span>")
		return

	var/choice = show_radial_menu(owner, owner, options, radius = 64, min_angle = 12)
	if(!choice)
		return
	give_adaptation(choice)
	var/obj/structure/spider/cocoon/C = new(owner.loc)
	owner.forceMove(C)
	QDEL_IN(C, 4 SECONDS)

/datum/action/innate/spider/evolve/adapt/Grant(mob/T)
	. = ..()
	if(!istype(owner, /mob/living/simple_animal/hostile/giant_spider))
		return

	options["Сила"] = image(icon = 'icons/hud/actions.dmi', icon_state = "strength")
	options["Скорость"] = image(icon = 'icons/hud/actions.dmi', icon_state = "speed")
	options["Сила яда"] = image(icon = 'icons/hud/actions.dmi', icon_state = "alien_acid")
	options["Живучесть"] = image(icon = 'icons/hud/actions_changeling.dmi', icon_state = "fleshmend")
	options["Количество яда"] = image(icon = 'icons/hud/actions.dmi', icon_state = "transfer_plasma")
	options["Плюнуть ядом"] = image(icon = 'icons/hud/actions.dmi', icon_state = "alien_neurotoxin")
	options["Зрение"] = image(icon = 'icons/hud/actions.dmi', icon_state = "adjust_vision")
	options["Паутина"] = image(icon = 'icons/effects/effects.dmi', icon_state = "webpassage")
	options["Видимость в паутине"] = image(icon = 'icons/hud/actions.dmi', icon_state = "alpha")
	options["Общение на расстоянии"] = image(icon = 'icons/hud/actions.dmi', icon_state = "speak")
	options["Скорость плетения"] = image(icon = 'icons/hud/actions.dmi', icon_state = "wrap_0")
	options["Снос стен"] = image(icon = 'icons/hud/actions.dmi', icon_state = "regurgitate")

	var/mob/living/simple_animal/hostile/giant_spider/S = owner
	for(var/n in S.adaptations)
		give_adaptation(n, TRUE)

/datum/action/innate/spider/evolve/adapt/proc/give_adaptation(adaptation, inheretence = FALSE)
	if(!istype(owner, /mob/living/simple_animal/hostile/giant_spider))
		return
	var/mob/living/simple_animal/hostile/giant_spider/S = owner
	switch(adaptation)
		if("Сила")
			S.melee_damage = min(S.melee_damage + 10, 45)
			if(S.melee_damage >= 45)
				options -= "Сила"
			to_chat(S, "<span class='notice'>Наша сила увеличилась до [S.melee_damage]!</span>")

		if("Скорость")
			S.speed = max(S.speed - 0.5, -2)
			if(S.speed <= -2)
				options -= "Скорость"
			to_chat(S, "<span class='notice'>Наша скорость увеличилась!</span>")

		if("Сила яда")
			if(!S.poison_type)
				S.poison_type = "toxin"
			else if(S.poison_type == "toxin")
				S.poison_type = "spidertoxin"
			else if(S.poison_type == "spidertoxin")
				S.poison_type = "sspidertoxin"
				options -= "Сила яда"
			else //just in case
				S.poison_type = "toxin"
			to_chat(S, "<span class='notice'>Наш яд стал сильнее!</span>")

		if("Живучесть")
			S.maxHealth = min(S.maxHealth + 40, 250)
			if(S.maxHealth >= 250)
				options -= "Живучесть"
			to_chat(S, "<span class='notice'>Наша живучесть увеличилась до [S.maxHealth]!</span>")

		if("Количество яда")
			S.poison_per_bite = max(S.poison_per_bite + 7, 30)
			if(S.poison_per_bite >= 30)
				options -= "Количество яда"
			to_chat(S, "<span class='notice'>Теперь мы впрыскиваем по [S.poison_per_bite] за укус!</span>")

		if("Плюнуть ядом")
			if(!S.projectiletype || !S.ranged)
				S.projectiletype = /obj/item/projectile/acid_special_spider/poisonous
				S.ranged = TRUE
				to_chat(S, "<span class='notice'>Мы научились плеваться ядом!</span>")
			else
				S.ranged_cooldown_cap = max(S.ranged_cooldown_cap - 1, 1)
				if(S.ranged_cooldown_cap <= 1)
					options -= "Плюнуть ядом"
				to_chat(S, "<span class='notice'>Теперь мы быстрее плюемся ядом!</span>")

		if("Зрение")
			if(S.lighting_alpha > LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
				S.set_lighting_alpha(LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			else if(!(S.sight & SEE_MOBS))
				S.sight |= SEE_MOBS
			else if(!(S.sight & SEE_OBJS))
				S.sight |= SEE_TURFS|SEE_OBJS
				options -= "Зрение"
			to_chat(S, "<span class='notice'>Мы видим больше!</span>")

		if("Паутина")
			if(!(/obj/structure/spider/stickyweb/sticky in S.webs))
				S.webs |= /obj/structure/spider/stickyweb/sealed
				S.webs |= /obj/structure/spider/stickyweb/sticky
			else if(!(/obj/structure/spider/stickyweb/solid in S.webs))
				S.webs |= /obj/structure/spider/stickyweb/solid
			else if(!(/obj/structure/spider/stickyweb/reflector in S.webs))
				S.webs |= /obj/structure/spider/stickyweb/reflector
				S.webs |= /obj/structure/spider/spikes
				options -= "Паутина"
			to_chat(S, "<span class='notice'>Мы научились плести новую паутину!</span>")

		if("Скорость плетения")
			S.web_mult = max(S.web_mult - 0.3, 0.2)
			if(S.web_mult <= 0.2)
				options -= "Скорость плетения"
			to_chat(S, "<span class='notice'>Теперь мы быстрее плетем паутину!</span>")

		if("Видимость в паутине")
			S.alpha_change = max(S.alpha_change - 50, 0)
			if(S.alpha_change <= 0)
				options -= "Видимость в паутине"

		if("Общение на расстоянии")
			S.can_speak_hivemind = TRUE
			options -= "Общение на расстоянии"
			to_chat(S, "<span class='notice'>Теперь при разговоре, добавив \";\", мы сможем говорить со всеми живыми пауками!</span>")

		if("Снос стен")
			S.environment_smash = min(S.environment_smash + 1, 2)
			if(S.environment_smash >= 2)
				options -= "Снос стен"
			to_chat(S, "<span class='notice'>Теперь мы можем сносить обычные стены!</span>")

	if(inheretence)
		return
	S.adaptations += adaptation

/mob/living/simple_animal/hostile/giant_spider/proc/spin_web(atom/A, web = /obj/structure/spider/stickyweb)
	var/turf/T = get_turf(A)
	var/n = 0
	for(var/obj/structure/spider/S in T)
		n++
	if(n > 3)
		to_chat(src, "<span class='notice'>Слишком много паутины в одном месте!</span>")
		return
	if(busy_with_action)
		return
	visible_message("<span class='notice'>\the [src] begins to secrete a sticky substance.</span>")
	var/choice = /obj/structure/spider/stickyweb
	if(length(webs) > 1 && client)
		//List with images that goes to client
		var/list/web_options = list()
		//List wih types
		var/list/choices = list()
		for(var/type in webs)
			var/obj/structure/spider/W = type
			choices[initial(W.name)] = W
			web_options[initial(W.name)] = image(icon = initial(W.icon), icon_state = initial(W.icon_state))

		choice = choices[show_radial_menu(src, T, web_options, require_near = TRUE, tooltips = TRUE, radius = 48, require_near = TRUE)]
		if(choice == /obj/structure/spider/spikes)
			for(var/obj/structure/spider/spikes/s in T.contents) //To prevent unfun things
				to_chat(src, "<span class='notice'>Шипы могут быть установлены лишь на открытом месте!</span>")
				return
		if(!choice)
			return
	if(!do_after(src, 4 * web_mult SECONDS, FALSE, T))
		return

	new choice (T)

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
	if(!do_after(src, 6 SECONDS * web_mult, FALSE, T))
		return
	E = new (T)
	E.sentient = TRUE
	E.adaptations = adaptations

	fed--
	reproduced++

/mob/living/simple_animal/hostile/giant_spider/proc/cocoon(atom/movable/cocoon_target)
	if(get_dist(src, cocoon_target) > 1 || cocoon_target.anchored || cocoon_target == src)
		return
	visible_message("<span class='notice'>\the [src] begins to secrete a sticky substance around \the [cocoon_target].</span>")
	if(isliving(cocoon_target))
		var/mob/living/M = cocoon_target
		if(M.stat != DEAD) //To prevent unusual behaviour and abuse
			to_chat(src, "<span class='notice'>Жертва ещё трепыхается и мешает! Нужно её убить, прежде чем заворачивать.</span>")
			return
		if(HAS_TRAIT(M, TRAIT_HUSK))
			to_chat(src, "<span class='notice'>С него нечего есть!</span>")
			return
		if(fed >= 1)
			to_chat(src, "<span class='notice'>Мы пока не голодны. Нужно отложить яйца!</span>")
			return

	if(!do_after(src, cocoon_target.w_class * web_mult SECONDS , FALSE, cocoon_target)) //The bigger target - the more time it takes
		return

	if(cocoon_target && get_dist(src, cocoon_target) <= 1)
		var/obj/structure/spider/cocoon/C = new(cocoon_target.loc)
		C.pixel_x = cocoon_target.pixel_x
		C.pixel_y = cocoon_target.pixel_y
		if(isliving(cocoon_target))
			var/mob/living/M = cocoon_target
			ADD_TRAIT(M, TRAIT_HUSK, GENERIC_TRAIT)
			if(istype(M, /mob/living/simple_animal/hostile/giant_spider)) //There is some dupe, but takes a very long time
				fed += 0.1
				to_chat(src, "<span class='notice'>Это мясо практически непригодно как пища. (+0.1)'</span>")
			else if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.update_body()
				fed += 1
				to_chat(src, "<span class='notice'>Это отличное мясо. (+1)</span>")
			else //Monkeys, slimes, etc. Not hostile - less reward. Monkeys give 0.4, though
				var/food_amount = 0.08 * w_class
				fed += food_amount
				to_chat(src, "<span class='notice'>Это плохое мясо. (+[food_amount])</span>")

			if(fed >= 1)
				to_chat(src, "<span class='notice'>Мы готовы отложить яйца.</span>")

			C.icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")
			visible_message("<span class='warning'>\the [src] sticks a proboscis into \the [cocoon_target] and sucks a viscous substance out.</span>")
			cocoon_target.forceMove(C)
			C.pixel_x = M.pixel_x
			C.pixel_y = M.pixel_y
		else
			cocoon_target.forceMove(C)
			if(cocoon_target.w_class > SIZE_NORMAL)
				C.icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")

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
	ranged_cooldown = 5
	poison_type = "toxin"

/mob/living/simple_animal/hostile/giant_spider/UnarmedAttack(atom/target)
	..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.reagents)
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				var/dam_zone = pick(BP_CHEST , BP_L_ARM , BP_R_ARM , BP_L_LEG , BP_R_LEG)
				var/obj/item/organ/external/BP = H.bodyparts_by_name[ran_zone(dam_zone)]
				if(prob(100 - (H.run_armor_check(BP, BIO) * 0.7))) //If we have armor with 100 bio def, poison probability is 30
					L.reagents.add_reagent(poison_type, 5)
					to_chat(L, "<span class='warning'>Вы чувствуете слабый укол.</span>")
			else if(prob(poison_per_bite) || client)
				to_chat(L, "<span class='warning'>Вы чувствуете слабый укол.</span>")
				L.reagents.add_reagent(poison_type, 5)
		if(isrobot(target))
			L.Stun(1)
	else if(istype(target, /obj/mecha))
		var/obj/mecha/M = target
		M.take_damage(melee_damage) //Means twice as much damage

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
	if(stop_automated_movement || client)
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
	maxHealth = 120
	health = 120
	melee_damage = 25
	poison_per_bite = 5
	speed = 3
	spider_actions = list(/datum/action/innate/spider/evolve/adapt, /datum/action/innate/spider/spin_web, /datum/action/innate/spider/lay_egg_cluster, /datum/action/innate/spider/cocoon)
	webs = list(/obj/structure/spider/stickyweb,
				/obj/structure/spider/spikes)
	alpha_change = 80

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
	speed = 2
	web_mult = 1.2
	ranged = TRUE
	projectiletype = /obj/item/projectile/acid_special_spider/poisonous
	spider_actions = list(/datum/action/innate/spider/evolve/adapt, /datum/action/innate/spider/spin_web, /datum/action/innate/spider/lay_egg_cluster, /datum/action/innate/spider/cocoon)

/mob/living/simple_animal/hostile/giant_spider/midwife
	name = "Midwife"
	desc = "Мохнатый и черный. И мелкий. У вас бегают мурашки по коже, когда вы смотрите на него. У этого глаза лиловые."
	gender = FEMALE
	icon_state = "midwife"
	icon_living = "midwife"
	icon_dead = "midwife_dead"
	icon_move = null
	poison_type = "spidertoxin"
	maxHealth = 100
	health = 100
	melee_damage = 15
	speed = 0.5
	web_mult = 1.5
	spider_actions = list(/datum/action/innate/spider/evolve/adapt, /datum/action/innate/spider/spin_web, /datum/action/innate/spider/lay_egg_cluster, /datum/action/innate/spider/cocoon)
