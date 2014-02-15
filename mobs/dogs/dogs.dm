#define DOG_STAT_WAIT 1
#define DOG_STAT_FOLLOW 2
#define DOG_STAT_COME 3
//#define DOG_STAT_FREE 4

#define DOG_STAT_FAKE_DEAD 5
#define DOG_STAT_SIT 6
#define DOG_STAT_LIE 7

#define DOG_STAT_FIGHT 10
#define DOG_STAT_FAS 11

/*
 *TODO:
 * исправить косяки, ночью кодить плохо для кода...
 * убрать вероятность слушаться приказа, когда рядом есть другие собаки(или вообще сделать эту вероятнотсь зависимой от количества мобов вокруг, дабы в пустой комнате точно послушался)
 *
 * Далее: боевой режим, дефолтные проки атаки и реакция на них, механизм хозяина(смена, лояльность, задабривание мясом и так далее)
 * Финал: перевод, оптимизация и рефакторинг
 */

/mob/living/simple_animal/dog

	name = "Dog"
	desc = "Just Dog"
	icon = 'tauceti/mobs/dogs/doge.dmi'
	icon_state = "shepherd"
	icon_dead = "shepherd_dead"
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/dog
	meat_amount = 3
	see_in_dark = 6
	stop_automated_movement = 0
	health = 150
	maxHealth = 150

	var/mob/owner
	var/mob/dog_target
	var/old_coords[3]	//x, y, z
	var/dog_state = DOG_STAT_WAIT
	var/loyalty = 50	//between 0 and 100, affects the chance of disobedience
	var/dog_icon = "shepherd"
	var/list/dog_names = list("dog", "собак")

/mob/living/simple_animal/dog/sheppard
	name = "Sheppard"
	desc = "Real hero guarding our galaxy"
	dog_names = list("dog","собак","shep","шеп", "пес", "пёс", "псина")//как я с этим заебался. Бьенд, твоя взяла.
	loyalty = 70

/mob/living/simple_animal/dog/mishka
	name = "Mishka"
//	desc = "Real hero guarding our galaxy"
	dog_names = list("dog","собак","mish","миш", "хаски")//как я с этим заебался. Бьенд, твоя взяла.
	loyalty = 70

	icon_state = "husky"
	icon_dead = "husky_dead"
	dog_icon = "husky"

/obj/item/weapon/reagent_containers/food/snacks/meat/dog
	name = "Dog meat"
	desc = "Tastes like... well you know..."

/mob/living/simple_animal/dog/proc/listen_command(var/message, var/mob/user as mob)

	message = lowertext_tc(message)

	if(!message)
		return

	owner = user//временно

	var/dog_command
	for(var/dogname in dog_names)
		if(findtext(message, dogname))	//okay, it's about this dog
			dog_command = 1
			break

/*
 *NEW STAT PART
 */
	//теперь проверим сообщение на команды
	//todo: просто проходить по словам в сообщении
	var/new_state = 0
	if(!new_state)
		for(var/word in list("ждать", "жди", "стой"))
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

/*	if(!new_state)
		for(var/word in list("гул&#255;й", "свободен", "играй"))
			if(findtext(message, word))
				new_state = DOG_STAT_FREE
				break
*/

	if(!new_state)
		for(var/word in list("умри", "мертвым"))
			if(findtext(message, word))
				new_state = DOG_STAT_FAKE_DEAD
				break

	if(!new_state)
		for(var/word in list("сидеть", "сиди"))
			if(findtext(message, word))
				new_state = DOG_STAT_SIT
				break

	if(!new_state)
		for(var/word in list("лежать", "л&#255;г"))
			if(findtext(message, word))
				new_state = DOG_STAT_LIE
				break

/*
 *NEW STAT PART END
 */

	var/emotional_reaction

	//воспитанная собака!
	if(!emotional_reaction)
		for(var/word in list("сук", "бл&#255;", "идиот", "туп"))
			if(findtext(message, word))
				custom_emote(1, "whines")
				emotional_reaction = 1
				break

	//позитивные реакции на похвалу
	if(!emotional_reaction)
		if(dog_command)
			for(var/word in list("&#255;н", "лиз", "миш", "молод", "хорош", "отличн"))
				if(findtext(message, word))
					custom_emote(1, "waves his tail")
					emotional_reaction = 1
					break

	//закончили, пора обновить статус
	if(new_state)
		if(dog_command)
			dog_state = new_state
			state_update(user)
		else if(prob(40))
			dog_state = new_state
			state_update(user)
	else
		if(dog_command)
			bark()

/mob/living/simple_animal/dog/Life()
	..()

	switch(dog_state)

		if(DOG_STAT_FOLLOW)
			walk_to(src, dog_target, 1, 4)

		if(DOG_STAT_COME)
			walk_to(src, dog_target, 1, 4)
			if(get_dist(src, dog_target) <=1)
				dog_state = DOG_STAT_WAIT
//где-то тут капризничает компилятор. исправить и откоментить
//		if(DOG_STAT_FAKE_DEAD, DOG_STAT_SIT, DOG_STAT_LIE)
//			if(old_coords[1] != x || old_coords[2] != y || old_coords[3] = z)
//				dog_state = DOG_STAT_WAIT

/mob/living/simple_animal/dog/proc/state_update(var/mob/user as mob)

//	sleep(200)

	if(dog_state != DOG_STAT_WAIT)
		stop_automated_movement = 0
	else
		stop_automated_movement = 1

	if(dog_state == DOG_STAT_SIT)
		custom_emote(1, "сел")
		walk(src, 0)
		icon_state = "[dog_icon]_sit"

	if(dog_state == DOG_STAT_SIT)
		custom_emote(1, "лёг")
		walk(src, 0)
		icon_state = "[dog_icon]_lie"

	if(dog_state == DOG_STAT_FOLLOW)
		dog_target = user
		bark()

	if(dog_state == DOG_STAT_COME)
		dog_target = user

	if(dog_state == DOG_STAT_LIE)
		custom_emote(1, "сел")
		walk(src, 0)
		icon_state = "[dog_icon]_lie"

	if(DOG_STAT_FAKE_DEAD || DOG_STAT_SIT || DOG_STAT_LIE)
		old_coords[1] = x
		old_coords[2] = y
		old_coords[3] = z

	if(dog_state == DOG_STAT_FAKE_DEAD)//+ таймер, не вечно же ей лежать тут
		custom_emote(1, "упал и умер")
		walk(src, 0)
		icon_state = "[dog_icon]_dead"

	if(dog_state != DOG_STAT_FAKE_DEAD && dog_state != DOG_STAT_SIT)
		icon_state = dog_icon

/mob/living/simple_animal/dog/proc/bark()
	say(pick("Aw!", "YAP!", "Woof!", "Wof!", "Bark!"))

/mob/living/simple_animal/dog/mishka/bark()
	say(pick("Aw!", "Oaoaoa!", "Aoaoao!", "Yaya!"))

#undef DOG_STAT_WAIT
#undef DOG_STAT_FOLLOW
#undef DOG_STAT_FIGHT
#undef DOG_STAT_FAKE_DEAD

#undef DOG_STAT_FAS