/*
 * Gradual creation of a things.
 */
/datum/religion_rites/standing/spawn_item
	//Type for the item to be spawned
	var/spawn_type
	//Type for the item to be sacrificed. If you specify the type here, then the component itself will change spawn_type to sacrifice_type.
	var/sacrifice_type
	//Additional favor per sacrificing-item
	var/adding_favor = 75

/datum/religion_rites/standing/spawn_item/New()
	AddComponent(/datum/component/rite/spawn_item, spawn_type, 1, sacrifice_type, adding_favor, divine_power, CALLBACK(src, PROC_REF(modify_item)))

// Used to apply some effect to an item after its spawn.
/datum/religion_rites/standing/spawn_item/proc/modify_item(atom/item)


/*
 * Spawn banana
 */
/datum/religion_rites/standing/spawn_item/banana
	name = "Атомная Реконструкция Молекулярной Решётки Целого Благословлённого Банана."
	desc = "БАНАНЫ!"
	ritual_length = (10 SECONDS)
	ritual_invocations = list("О великая Мать!...",
							"...Пусть твоя сила снизойдет к нам и одарит нас...",
							"...Отойдя от сна , в темной ночи, я приношу тебе песню...",
							"...склоняясь на коленях, Я взываю к Тебе...",
							"...сжалься надо мной, и всеми клоунами мира!...",
							"...подними меня, небрежно лежащего, и спаси меня...")
	invoke_msg = "...Пошли мне силу!!!"
	favor_cost = 75
	spawn_type = /obj/item/weapon/reagent_containers/food/snacks/grown/banana

	needed_aspects = list(
		ASPECT_WACKY = 1,
		ASPECT_CHAOS = 1,
	)

/datum/religion_rites/standing/spawn_item/banana/modify_item(atom/item)
	if(prob(20))
		var/atom/before_item_loc = item.loc
		qdel(item)
		item = new /obj/item/weapon/reagent_containers/food/snacks/grown/banana/honk(before_item_loc)

/datum/religion_rites/standing/spawn_item/banana/invoke_effect(mob/living/user, obj/AOG)
	. = ..()

	playsound(AOG, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

	for(var/mob/living/carbon/human/M in viewers(get_turf(AOG)))
		if(M.mind && !M.mind.holy_role && M.eyecheck() <= 0 && !(M.IsClumsy()))
			M.flash_eyes()

	user.visible_message("<span class='notice'>[user] has finished the rite of [name]!</span>")
	return TRUE

/*
 * Spawn bananium ore
 */
/datum/religion_rites/standing/spawn_item/banana_ore
	name = "Обогащение Молекул Кислорода Атомами Банана"
	desc = "Восстановление Империи!"
	ritual_length = (50 SECONDS)
	ritual_invocations = list("О Великая Мать!...",
							"...Помоги нам в напасти!...",
							"...Мы молим, пошли нам стойкость!...",
							"...Наполни эти бананы своей энергией...",
							"...И пусть они обретут твою могучую силу, дабы помочь нам!...",
							"...Мы нуждаемся в твоей помощи, пожалуйста, помоги, о Великая!...")
	invoke_msg = "...Мы молим тебя!!!"
	favor_cost = 150
	sacrifice_type = /obj/item/weapon/reagent_containers/food/snacks/grown/banana
	spawn_type = /obj/item/weapon/ore/clown

	needed_aspects = list(
		ASPECT_WACKY = 1,
		ASPECT_RESOURCES = 1,
	)

/datum/religion_rites/standing/spawn_item/banana_ore/invoke_effect(mob/living/user, obj/AOG)
	. = ..()

	playsound(AOG, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

	for(var/mob/living/carbon/human/M in viewers(get_turf(AOG)))
		if(M.mind && !M.mind.holy_role && M.eyecheck() <= 0 && !(M.IsClumsy()))
			M.flash_eyes()

	user.visible_message("<span class='notice'>[user] has finished the rite of [name]!</span>")
	return TRUE

/datum/religion_rites/standing/spawn_item/banana_ore/modify_item(atom/item)
	if(prob(20))
		new item.type(item.loc)

/*
 * Create random friendly animal.
 * Any ghost with preference can become animal.
 */
/datum/religion_rites/standing/spawn_item/call_animal
	name = "Призыв Животного"
	desc = "Создаёт случайного дружелюбного помощника."
	ritual_length = (1 MINUTES)
	ritual_invocations = list("Как все сложные узлы мира взаимосвязаны...",
						"...так и мое животное связано этим местом...",
						"...Моя воля позволила мне создать тебя и призвать к жизни...",
						"...Ты существуешь ради выполнения цели...",
						"...Приди же...")
	invoke_msg = "...Да будет так!"
	favor_cost = 150

	needed_aspects = list(
		ASPECT_SPAWN = 1,
	)

	var/list/summon_type = list(/mob/living/simple_animal/corgi/puppy, /mob/living/simple_animal/hostile/retaliate/goat, /mob/living/simple_animal/corgi, /mob/living/simple_animal/cat, /mob/living/simple_animal/parrot, /mob/living/simple_animal/crab, /mob/living/simple_animal/cow, /mob/living/simple_animal/chick, /mob/living/simple_animal/chicken, /mob/living/simple_animal/pig, /mob/living/simple_animal/turkey, /mob/living/simple_animal/goose, /mob/living/simple_animal/seal, /mob/living/simple_animal/walrus, /mob/living/simple_animal/fox, /mob/living/simple_animal/lizard, /mob/living/simple_animal/mouse, /mob/living/simple_animal/mushroom, /mob/living/simple_animal/pug, /mob/living/simple_animal/shiba, /mob/living/simple_animal/yithian, /mob/living/simple_animal/tindalos, /mob/living/carbon/monkey, /mob/living/carbon/monkey/skrell, /mob/living/carbon/monkey/tajara, /mob/living/carbon/monkey/unathi, /mob/living/simple_animal/slime)

/datum/religion_rites/standing/spawn_item/call_animal/New()
	spawn_type = choose_spawn_type()
	AddComponent(/datum/component/rite/spawn_item, spawn_type, 1, sacrifice_type, adding_favor, divine_power, CALLBACK(src, PROC_REF(modify_item)), CALLBACK(src, PROC_REF(choose_spawn_type)), "This ritual creates a <i>random friendly animal</i>.")

/datum/religion_rites/standing/spawn_item/call_animal/proc/choose_spawn_type()
	return pick(summon_type)

/datum/religion_rites/standing/spawn_item/call_animal/proc/call_ghost(mob/animal)
	create_spawner(/datum/spawner/living/religion_familiar, _mob = animal, _religion = religion)

	var/god_name
	if(religion.active_deities.len == 0)
		god_name = pick(religion.deity_names)
	else
		var/mob/god = pick(religion.active_deities)
		god_name = god.name

	animal.name = "familiar of [god_name] [num2roman(rand(1, 20))]"
	animal.real_name = animal.name
	animal.universal_understand = TRUE

/datum/religion_rites/standing/spawn_item/call_animal/modify_item(mob/animal)
	INVOKE_ASYNC(src, PROC_REF(call_ghost), animal)

/datum/religion_rites/standing/spawn_item/call_animal/invoke_effect(mob/living/user, obj/AOG)
	. = ..()

	for(var/mob/living/carbon/human/M in viewers(usr.loc, null))
		if(M.mind && !M.mind.holy_role && M.eyecheck() <= 0)
			M.flash_eyes()

	return TRUE

/*
 * Create religious sword
 * Just create claymore with reduced damage.
 */
/datum/religion_rites/standing/spawn_item/create_sword
	name = "Создание Меча"
	desc = "Создаёт меч во имя Бога."
	ritual_length = (40 SECONDS)
	ritual_invocations = list("Святой Дух, который спасает от напасти, который освещает путь, чтобы я мог достичь своей цели....",
						"...Ты даешь мне Божественный дар прощения и прощение всего зла, совершенного против меня...",
						"...Ты со мной, во всех жизненных бурях...",
						"...В этой молитве я хочу поблагодарить тебя за все...",
						"...Ожидаю время когда я докажу, что никогда не расстанусь с тобой...",
						"...несмотря на любые мирские трудности...",
						"...Я хочу пребывать в твоем вечном величии...",
						"...Я благодарю тебя за все милости мне и моим соседям...",)
	invoke_msg = "...Да будет так!"
	favor_cost = 100

	spawn_type = /obj/item/weapon/claymore/religion

	needed_aspects = list(
		ASPECT_WEAPON = 1
	)

/datum/religion_rites/standing/spawn_item/create_sword/modify_item(atom/sword)
	var/god_name
	if(religion.active_deities.len == 0)
		god_name = pick(religion.deity_names)
	else
		var/mob/god = pick(religion.active_deities)
		god_name = god.name
	sword.name = "[sword.name] of [god_name]"

/datum/religion_rites/standing/spawn_item/create_sword/invoke_effect(mob/living/user, obj/AOG)
	. = ..()

	for(var/mob/living/carbon/human/M in viewers(usr.loc, null))
		if(M.mind && !M.mind.holy_role && M.eyecheck() <= 0)
			M.flash_eyes()

	return TRUE

/datum/religion_rites/standing/spawn_item/talisman
	name = "Создание Талисмана"
	desc = "Создаёт пустой талисман, в который можно поместить ритуал."
	ritual_length = (1 MINUTE)
	invoke_msg = "Portable magic!!!"
	favor_cost = 200
	spawn_type = /obj/item/weapon/paper/talisman/chaplain

	needed_aspects = list(
		ASPECT_RESOURCES = 1,
	)
