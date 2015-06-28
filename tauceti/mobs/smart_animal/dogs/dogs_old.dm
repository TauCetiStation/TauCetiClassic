#define DOG_STAT_WAIT 1
#define DOG_STAT_FOLLOW 2
#define DOG_STAT_COME 3
//#define DOG_STAT_FREE 4

#define DOG_STAT_HOLD 4
#define DOG_STAT_FAKE_DEAD 5
#define DOG_STAT_SIT 6
#define DOG_STAT_LIE 7

#define DOG_STAT_FIGHT 10
#define DOG_STAT_FAS 11

/*
 *TODO:
 * Упорядочить режим боя
 * Далее: боевой режим, дефолтные проки атаки и реакция на них, механизм хозяина(смена, лояльность, задабривание мясом и так далее)
 * Финал: перевод, оптимизация и рефакторинг
 * заметка: плохо реагирует на команды последнее время
 * пофиксить самозагрызание, после смерти walk отрубить, НЕРФ БОЯ И БЕГА
 */

/mob/living/simple_animal/dog

	name = "Dog"
	desc = "Just Dog"
	icon = 'tauceti/mobs/smart_animal/dogs/doge.dmi'
	icon_state = "shepherd"
	icon_dead = "shepherd_dead"
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/dog
	meat_amount = 3
	see_in_dark = 6
	stop_automated_movement = 0
	health = 150
	maxHealth = 150

	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "pokes"

	var/mob/living/carbon/human/owner
	var/mob/dog_target
	var/old_coords[3]	//x, y, z
	var/dog_state = DOG_STAT_WAIT
	var/loyalty = 0	//between 0 and 100, affects the chance of disobedience
	var/dog_icon = "shepherd"
	var/list/dog_names = list("dog", "собак", "пес", "пёс", "псина")
	var/list/enemy_list[0]
	var/idle_time = 0
	var/target_point = null

/mob/living/simple_animal/dog/sheppard
	name = "Sheppard"
	desc = "Real hero guarding our galaxy"
//	loyalty = 70

/mob/living/simple_animal/dog/sheppard/New()
	..()
	dog_names.Add("shep", "шеп", "шееп")

/mob/living/simple_animal/dog/mishka
	name = "Mishka"
	desc = "The dog who can say: 'I love you!'"
//	loyalty = 70

	icon_state = "husky"
	icon_dead = "husky_dead"
	dog_icon = "husky"

/mob/living/simple_animal/dog/mishka/New()
	..()
	dog_names.Add("mish", "миш", "хаски")

/obj/item/weapon/reagent_containers/food/snacks/meat/dog
	name = "Dog meat"
	desc = "Tastes like... well you know..."

/mob/living/simple_animal/dog/proc/listen_command(var/message, var/mob/user as mob)

	message = lowertext_plus(message)

	if(!message)
		return

	//временный костыль, потом привязать шанс к лояльности
	if(user != owner)
		return

	if(stat)
		return

//	owner = user//временно
//	owner.dog_owner = src

	var/dog_command
	for(var/dogname in dog_names)
		if(findtext(message, dogname))	//okay, it's about this dog
			dog_command = 1
			break

	if(!dog_command)
		var/count = 0
		for(var/mob/living/carbon/C in view(7,src)) //проверяем, как много мобов вокруг
			count++
		if(prob(count*15))	//вероятность провала команды без обращения зависит от количества людей вокруг
			return

	for(var/word in list("голос", "скажи"))
		if(findtext(message, word))
			bark()
			return

/*
 *NEW STAT PART
 */
	//теперь проверим сообщение на команды
	//todo: что-то с этим сделать

	var/new_state = 0
	if(!new_state)
		for(var/word in list("ждать", "жди", "фу"))
			if(findtext(message, word))
				new_state = DOG_STAT_WAIT
				break

	if(!new_state)
		for(var/word in list("за мной", "пошли"))
			if(findtext(message, word))
				new_state = DOG_STAT_FOLLOW
				break

	if(!new_state)
		for(var/word in list("к ноге", "ко мне", "сюда"))
			if(findtext(message, word))
				new_state = DOG_STAT_COME
				break

	if(!new_state)
		for(var/word in list("стой", "вста"))
			if(findtext(message, word))
				new_state = DOG_STAT_HOLD
				break

	if(!new_state)
		for(var/word in list("умри", "мертвым"))
			if(findtext(message, word))
				new_state = DOG_STAT_FAKE_DEAD
				break

	if(!new_state)
		for(var/word in list("сидеть", "сиди", "с&#255;д"))
			if(findtext(message, word))
				new_state = DOG_STAT_SIT
				break

	if(!new_state)
		for(var/word in list("лежать", "л&#255;г"))
			if(findtext(message, word))
				new_state = DOG_STAT_LIE
				break

	if(!new_state && dog_state != DOG_STAT_FIGHT)
		for(var/word in list("фас", "кусай", "атакуй", "оторви"))
			if(findtext(message, word))
				new_state = DOG_STAT_FAS
				break

/*
 *NEW STAT PART END
 */

	var/emotional_reaction

	//воспитанная собака!
	if(!emotional_reaction)
		for(var/word in list("сук", "бл&#255;", "идиот", "туп", "нах"))
			if(findtext(message, word))
				custom_emote(1, "whines")
				emotional_reaction = 1
				break

	//позитивные реакции на похвалу
	if(!emotional_reaction)
		for(var/word in list("&#255;н", "лиз", "миш", "молод", "хорош", "отличн", "умн"))
			if(findtext(message, word))
				custom_emote(1, "waves his tail")
				emotional_reaction = 1
				break

	if(new_state)
		turn_to(user)
		state_update(new_state, user)
	else
		if(dog_command)
			turn_to(user)
			bark()

/mob/living/simple_animal/dog/Life()
	. =..()
	if(!.)
		return

	if(stat)
		return

//	world << loyalty

	switch(dog_state)

		if(DOG_STAT_FOLLOW)
			walk_to(src, dog_target, 1, 4)
			turn_to(dog_target)

		if(DOG_STAT_COME)
			walk_to(src, dog_target, 1, 4)
			if(get_dist(src, dog_target) <=1)
				turn_to(dog_target)
				state_update(DOG_STAT_HOLD)

		if(DOG_STAT_FAKE_DEAD, DOG_STAT_SIT, DOG_STAT_LIE, DOG_STAT_HOLD)
			if(old_coords[1] != x || old_coords[2] != y || old_coords[3] != z)
				state_update(DOG_STAT_WAIT)

			idle_time++
			if(idle_time > 100)
				state_update(DOG_STAT_WAIT)

		if(DOG_STAT_FIGHT)

			idle_time++
			if(enemy_list.len == 0 || !dog_target || idle_time > 1000)
				state_update(DOG_STAT_WAIT)
				return

			var/dist = get_dist(src, dog_target)
			if(!dist || dist > 7 || prob(20))
				dog_target = select_enemy()
				bark()
			else if(dist <=1)
				Attack()
				idle_time = 0
			else
				walk_to(src, dog_target, 1, 4)
				turn_to(dog_target)

			if(dog_target.stat > 0)
				enemy_list -= dog_target
				dog_target = select_enemy()

	if(prob(5))
		for (var/atom/A in view(1,src))
			if(istype(A, /obj/machinery/bot/secbot))
				custom_emote(1, "growls at [A]")
				bark()
				turn_to(A)
			else if(istype(A, /obj/item))
				if(prob(20))
					turn_to(A)
					custom_emote(1, "sniffs [A]")

	if(prob(20))
		if(owner && dog_state != DOG_STAT_FIGHT)
			if(owner.stat == DEAD && get_dist(src, owner) <= 7)
				state_update(DOG_STAT_COME, owner)
				custom_emote(1, "whines")

	if(prob(1))
		dir = pick(WEST, EAST, NORTH, SOUTH)

/mob/living/simple_animal/dog/proc/owner_in_danger(var/mob/possible_enemy, var/mob/user)
	if(owner != user || owner == possible_enemy)
		return

	if(get_dist(src, owner) >= 8)
		return

	if(!(possible_enemy in enemy_list))
		enemy_list += possible_enemy

	state_update(DOG_STAT_FIGHT, possible_enemy)

/mob/living/simple_animal/dog/proc/select_enemy()
	var/possible_target
	var/dist
	var/dist_min
//	world << "Выбираем цель из списка, кандидаты:"
	for (var/mob/M in enemy_list)
//		world << M
		dist = get_dist(M, src)
		if(!dist) continue
		if(!dist_min) dist_min = dist
		if(dist <= dist_min)
			possible_target = M

//	world << "Была выбрана цель из возможных: [possible_target]"


	return possible_target

/mob/living/simple_animal/dog/proc/target_point(var/mob/possible_target, var/mob/user)
	if(owner != user || owner == possible_target)
		return

	if(get_dist(src, owner) >= 14 || get_dist(src, possible_target) > 14)
		return

	if(ismob(possible_target))
		if(dog_state == DOG_STAT_FIGHT)
			enemy_list += possible_target
		else
			target_point = possible_target


/mob/living/simple_animal/dog/proc/state_update(var/state, var/mob/user as mob)

	if(user)
		dog_target = user

	if(state)
		dog_state = state

	idle_time = 0

	if(dog_state != DOG_STAT_WAIT)
		stop_automated_movement = 1
	else
		stop_automated_movement = 0

	if(dog_state == DOG_STAT_FOLLOW)
		bark()

	if(dog_state == DOG_STAT_WAIT || dog_state == DOG_STAT_HOLD)
		walk(src, 0)

	//if(dog_state == DOG_STAT_COME)

	if(dog_state == DOG_STAT_FAKE_DEAD)
		custom_emote(1, "has fallen and died")
		walk(src, 0)
		icon_state = "[dog_icon]_dead"

	if(dog_state == DOG_STAT_SIT)
		custom_emote(1, "sat down")
		walk(src, 0)
		icon_state = "[dog_icon]_sit"

	if(dog_state == DOG_STAT_LIE)
		custom_emote(1, "layed down")
		walk(src, 0)
		icon_state = "[dog_icon]_lie"

	if(dog_state == DOG_STAT_FIGHT)
		say("Hrrrrr", "Aw!", "Rawr!")
	else
		enemy_list = list()

	if(dog_state == DOG_STAT_FAS)
		if(!target_point)
			custom_emote(1, "whines")
		else
			fatality()
	else
		target_point = 0

	if(dog_state == DOG_STAT_FAKE_DEAD || dog_state == DOG_STAT_SIT || dog_state == DOG_STAT_LIE)
		old_coords[1] = x
		old_coords[2] = y
		old_coords[3] = z

	if(dog_state != DOG_STAT_FAKE_DEAD && dog_state != DOG_STAT_SIT && dog_state != DOG_STAT_LIE)
		icon_state = dog_icon

/mob/living/simple_animal/dog/proc/turn_to(var/mob/target as mob)

	if (target.loc.x < src.x)
		dir = WEST
	else if (target.loc.x > src.x)
		dir = EAST
	else if (target.loc.y < src.y)
		dir = SOUTH
	else if (target.loc.y > src.y)
		dir = NORTH
	else
		dir = SOUTH

/mob/living/simple_animal/dog/proc/Attack()
	if(!Adjacent(dog_target))
		return
	custom_emote(1, "[pick("bites","nips")] [dog_target]")

	var/damage = 10

	if(ishuman(dog_target))
		var/mob/living/carbon/human/H = dog_target
		var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg")
		var/datum/organ/external/affecting = H.get_organ(ran_zone(dam_zone))
		H.apply_damage(damage, BRUTE, affecting, H.run_armor_check(affecting, "melee"))
		return H
	else if(isliving(dog_target))
		var/mob/living/L = dog_target
		L.adjustBruteLoss(damage)
		return L
	else if(istype(dog_target,/obj/mecha))
		var/obj/mecha/M = dog_target
		M.attack_animal(src)
		return M

/mob/living/simple_animal/dog/proc/fatality()
	if(!target_point || !ishuman(target_point))
		return
	var/mob/living/carbon/human/H = target_point
	var/clown = 0

	if(H.gender == "male")
		walk_to(src, H, 1, 4)

		if(H.mind)
			if(H.mind.assigned_role == "Clown")
				clown = 1

		bark()

		var/attempt = 0
		while(attempt < 10)
			sleep(5)
			attempt++
			var/dist = get_dist(src, H)
			if(dist <= 1)
				if(clown || prob(100))//5!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					custom_emote(1, "nibbles the groin of")
					var/dam_zone = "groin"
					var/datum/organ/external/affecting = H.get_organ(ran_zone(dam_zone))
					H.apply_damage(50, BRUTE, affecting, H.run_armor_check(affecting, "melee"))
					H.gender = "female"
					var/turf/simulated/T = H.loc
					if(istype(T))
						T.add_blood_floor(H)
					T = get_step(H,pick(NORTH, SOUTH))	//все в спешке, да еще и достало. охх.
					if(istype(T))
						T.add_blood_floor(H)
					T = get_step(H,pick(EAST, WEST))
					if(istype(T))
						T.add_blood_floor(H)
					break

	enemy_list += H
	state_update(DOG_STAT_FIGHT, H)

	return

/mob/living/simple_animal/dog/attackby(var/obj/item/O as obj, var/mob/user as mob)

//	..() //там лежал спавн мяса по тыку ножом, но.. потом перенести

	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks))
		turn_to(user)
		custom_emote(1, "eats away [O]")
		qdel(O)
		if(user == owner)
			if(loyalty < 100)
				loyalty += 10
		else
			loyalty -= 5
		return

	if(user == owner)
		custom_emote(1, "whines")
		if(loyalty < 60)
			if(prob(100-loyalty))
				owner = null
				owner.dog_owner = null
		else
			if(loyalty >= 10) loyalty -= 10
	else
		enemy_list += user
		state_update(DOG_STAT_FIGHT, user)

	..()

/mob/living/simple_animal/dog/attack_hand(mob/living/carbon/human/M as mob)

	..()

	if(M.a_intent == "help")
		if(M == owner)
			if(loyalty < 100) loyalty++
		else
			if(loyalty > 0)
				loyalty--
			if(loyalty < 30 && prob(60 - loyalty))
				change_owner(M)

//в процессе работы, пока такой вариант с лояльностью сойдет
/mob/living/simple_animal/dog/proc/change_owner(mob/living/carbon/human/M as mob)

	if(owner)
		owner.dog_owner = null

	owner = M
	bark()
	loyalty = 30
	owner.dog_owner = src

	return 1

/mob/living/simple_animal/dog/proc/bark()
	say(pick("Aw!", "YAP!", "Woof!", "Wof!", "Bark!"))

/mob/living/simple_animal/dog/mishka/bark()
	say(pick("Aw!", "Oaoaoa!", "Aoaoao!", "Yaya!"))