/*
 * Food summoning
 * Grants a lot of food while you AFK near the altar. Even more food if you finish the ritual.
 */
/datum/religion_rites/standing/food
	name = "Создание Еды"
	desc = "Нужно больше и больше еды!"
	ritual_length = (30 SECONDS)
	ritual_invocations = list("О Господь, мы молим тебя: услышь наши молитвы, чтобы они были исполнены по милости Твоей, во славу имени Твоего...",
						"...Наши посевы и сады, мы заслужили кару за наши грехи, мы страдаем из-за птиц, червей, мышей, кротов и других тварей Господних...",
						"...и изгнанные Твоей властью в дебри пустынные, пусть они не причинят вреда никому, кроме этих полей и вод...",
						"...и сады будут оставлены в покое, все, что растет и рождается в них, будет служить во славу твою...",
						"...и наши горечи сокрушены , ибо мы восхваляем тебя...")
	invoke_msg = "..ИБО МЫ ВОСХВАЛЯЕМ ТЕБЯ!!"
	favor_cost = 300

	needed_aspects = list(
		ASPECT_FOOD = 1,
	)

// This proc is also used by spells/religion.dm "spawn food". Stupid architecture, gotta deal with it some time ~Luduk
// Perhaps allow God to do rituals instead? ~Luduk
/proc/spawn_food(atom/location, amount)
	var/static/list/borks = subtypesof(/obj/item/weapon/reagent_containers/food)

	playsound(location, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

	for(var/i in 1 to amount)
		var/chosen = pick(borks)
		var/obj/B = new chosen(location)
		if(!B.icon_state || !B.reagents || !B.reagents.reagent_list.len)
			QDEL_NULL(B)
			var/random_type = PATH_OR_RANDOM_PATH(pick(/obj/random/foods/drink_can, /obj/random/foods/drink_bottle, /obj/random/foods/food_snack, /obj/random/foods/food_without_garbage))
			B = new random_type
		if(B && prob(80))
			for(var/j in 1 to rand(1, 3))
				step(B, pick(NORTH, SOUTH, EAST, WEST))

/datum/religion_rites/standing/food/invoke_effect(mob/user, obj/AOG)
	. = ..()
	if(!.)
		return FALSE

	playsound(AOG, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

	for(var/mob/living/carbon/human/M in viewers(get_turf(AOG)))
		if(M.mind && !M.mind.holy_role && M.eyecheck() <= 0)
			M.flash_eyes()

	spawn_food(get_turf(AOG), 4 + rand(2, 5) * divine_power)

	usr.visible_message("<span class='notice'>[usr] has been finished the rite of [name]!</span>")
	return TRUE

/datum/religion_rites/standing/food/rite_step(mob/user, obj/AOG)
	..()
	if(prob(50))
		spawn_food(get_turf(AOG), 1)

/*
 * Prayer
 * Increases favour while you AFK near altar, heals everybody around if invoked succesfully.
 */
/datum/religion_rites/standing/pray
	name = "Молитва"
	desc = "За добрые слова вы получаете немного favor'а."
	ritual_length = (2 MINUTES)
	ritual_invocations = list("Господи помилуй, О Господи помилуй...",
							  "...Воставше от сна, припадаем Тебе, Блаже, и ангельскую песнь воспоем Тебе...",
							  "...Свят будь, Боже, Богородица помилуй нас...",
							  "...Господи помилуй...",
							  "...Боже, очисти меня грешного, как никогда сотворив благое перед Тобою...",
							  "...но избави меня от лукавого, и да будет во мне воля Твоя...",
							  "...Да неосужденно открою уста мои недостойные и восхвалю имя Твое святое...",
							  "...Отца и Сына и Святого Духа, ныне и присно и во веки веков. Аминь...",)
	invoke_msg = "Господи помилуй. Двенадцать Раз."
	favor_cost = 0

	var/adding_favor = 0

	needed_aspects = list(
		ASPECT_RESCUE = 1,
	)

/datum/religion_rites/standing/pray/invoke_effect(mob/user, obj/AOG)
	. = ..()
	if(!.)
		return FALSE

	var/heal_num = -15 * divine_power
	for(var/mob/living/L in range(2, src))
		L.apply_damages(heal_num, heal_num, heal_num, heal_num, heal_num, heal_num)

	adding_favor = min(adding_favor + 2.0, 20.0)

	usr.visible_message("<span class='notice'>[usr] has been finished the rite of [name]!</span>")
	return TRUE

/datum/religion_rites/standing/pray/rite_step(mob/user, obj/AOG, stage)
	..()
	religion.adjust_favor(15 + adding_favor)
	adding_favor = min(adding_favor + 0.1, 20.0)

/*
 * Honk
 * The ritual creates a honk that everyone hears.
 */
/datum/religion_rites/standing/honk
	name = "Клоунский Крик"
	desc = "Разносит хонк по всей станции."
	ritual_length = (1 MINUTES)
	ritual_invocations = list("Все кто способен слышать, услышьте!...",
							  "...Данное послание для всех вас...",
							  "...Пусть будут ваши тела здоровы, а ваши умы светлы...",
							  "...Пусть будут ваши шутки смешными...",
							  "...и души ваши чисты!...",
							  "...Этот крик посвящен всем шуткам и клоунам...",)
	invoke_msg = "...Да услышьте его!!!"
	favor_cost = 200

	needed_aspects = list(
		ASPECT_WACKY = 1,
	)

/datum/religion_rites/standing/honk/invoke_effect(mob/user, obj/AOG)
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/M in player_list)
		M.playsound_local(null, 'sound/items/AirHorn.ogg', VOL_EFFECTS_MASTER, null, FALSE, channel = CHANNEL_ANNOUNCE, wait = TRUE)

	user.visible_message("<span class='notice'>[user] has finished the rite of [name]!</span>")
	return TRUE

/datum/religion_rites/standing/honk/rite_step(mob/user, obj/AOG, stage)
	..()
	var/ratio = (100 / ritual_invocations.len) * stage
	playsound(AOG, 'sound/items/bikehorn.ogg', VOL_EFFECTS_MISC, ratio)

/*
 * Revitalizing items.
 * It makes a thing move and say something. You can't pick up a thing until you kill a item-mob.
 */
/datum/religion_rites/standing/animation
	name = "Анимация"
	desc = "Возрождает вещи на алтаре."
	ritual_length = (50 SECONDS)
	ritual_invocations = list("Я обращаюсь к тебе - Всевышний...",
							  "...свет, дарованный мудростью возвратившихся богов...",
							  "...Они наделили Анимацию человеческими страстями и чувствами...",
							  "...Анимация, пришедшая из Нового Царства, радуйся свету!...",)
	invoke_msg = "Я обращаюсь к тебе! Я взываю! Очнись ото сна!"
	favor_cost = 80

	needed_aspects = list(
		ASPECT_SPAWN = 1,
		ASPECT_WEAPON = 1,
	)

/datum/religion_rites/standing/animation/on_chosen(mob/user, obj/AOG)
	if(!..())
		return FALSE
	var/anim_items = 0
	for(var/obj/item/O in get_turf(AOG))
		anim_items++
	if(!anim_items)
		to_chat(user, "<span class='warning'>Put any the item on the altar!</span>")
		return FALSE
	favor_cost = round((initial(favor_cost) * religion.members.len * anim_items / divine_power), 10)
	religion.update_rites()
	return TRUE

/datum/religion_rites/standing/animation/invoke_effect(mob/user, obj/AOG)
	. = ..()
	if(!.)
		return FALSE

	var/list/anim_items = list()
	for(var/obj/item/O in get_turf(AOG))
		anim_items += O

	favor_cost = round((initial(favor_cost) * religion.members.len * anim_items.len) / divine_power, 10)
	religion.update_rites()

	if(!religion.check_costs(favor_cost, piety_cost, user))
		return FALSE

	if(anim_items.len != 0)
		for(var/obj/item/O in anim_items)
			var/mob/living/simple_animal/hostile/mimic/copy/religion/R = new(O.loc, O)
			religion.add_member(R, HOLY_ROLE_PRIEST)
			R.friends = religion.members

		user.visible_message("<span class='notice'>[user] has finished the rite of [name]!</span>")
	return TRUE

/*
 * Spook
 * This ritual spooks players: Light lamps pop out, and people start to shake
 */
/datum/religion_rites/standing/spook
	name = "Испуг"
	desc = "Издаёт из алтаря страшный крик."
	ritual_length = (20 SECONDS)
	ritual_invocations = list("Я призываю сюда души людей, я отправляю твою душу к потустороннему вору, в черное зеркало...",
							  "...Позволь злу захватить тебя и запереть...",
							  "...Мучить тебя, пытать тебя, истощать тебя, уничтожать тебя...",
							  "...Я вселяю зло в твою душу...",
							  "...Я впускаю зло в твою голову, в твое сердце, в твою печень, в твою кровь...",
							  "...Я не приказываю...",
							  "...Как я сказал, так и будет! Я закрываю на ключ, закрываю на замок...")
	invoke_msg = "...Я заклинаю! Я заклинаю! Я заклинаю!"
	favor_cost = 100

	needed_aspects = list(
		ASPECT_OBSCURE = 1,
	)

/datum/religion_rites/standing/spook/proc/remove_spook_effect(mob/living/carbon/M)
	M.remove_alt_appearance("spookyscary")

/datum/religion_rites/standing/spook/invoke_effect(mob/user, obj/AOG)
	. = ..()
	if(!.)
		return FALSE

	playsound(AOG, 'sound/effects/screech.ogg', VOL_EFFECTS_MASTER, null, FALSE)

	for(var/mob/living/carbon/M in hearers(4, get_turf(AOG)))
		if(M?.mind?.holy_role)
			M.make_jittery(50)
		else
			M.AdjustConfused(10 * divine_power)
			M.make_jittery(50)
			if(prob(50))
				M.visible_message("<span class='warning bold'>[M]'s face clearly depicts true fear.</span>")

		var/image/I = image(icon = 'icons/mob/human.dmi', icon_state = pick("ghost", "husk_s", "zombie", "skeleton"), layer = INFRONT_MOB_LAYER, loc = M)
		I.override = TRUE
		M.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/everyone, "spookyscary", I)
		addtimer(CALLBACK(src, PROC_REF(remove_spook_effect), M), 10 SECONDS * divine_power)

	var/list/targets = list()
	for(var/turf/T in range(4))
		targets += T
	light_off_range(targets, AOG)

	return TRUE

/*
 * Illuminate
 * The ritual turns on the flash in range, create overlay of "spirit" and the person begins to glow
 */
/datum/religion_rites/standing/illuminate
	name = "Озарение"
	desc = "Создаёт пучок света над вами."
	ritual_length = (30 SECONDS)
	ritual_invocations = list("Иди ко мне, огонек...",
							  "...Явись мне тем, кого все хотят...",
							  "...к кому обращаются за помощью!...",
							  "...Хороший огонек, способный рассеять тьму...",
							  "...я прошу тебя о помощи...",
							  "...Услышь меня, не отвергай меня...",
							  "...Ибо я нарушаю твой покой не только из любопытства...")
	invoke_msg = "...Я молю, пожалуйста, приди!"
	favor_cost = 200

	var/shield_icon = "at_shield2"

	needed_aspects = list(
		ASPECT_LIGHT = 1,
	)

/datum/religion_rites/standing/illuminate/invoke_effect(mob/user, obj/AOG)
	. = ..()
	if(!.)
		return FALSE

	var/list/blacklisted_lights = list(/obj/item/device/flashlight/flare, /obj/item/device/flashlight/slime, /obj/item/weapon/reagent_containers/food/snacks/glowstick)
	for(var/mob/living/carbon/human/H in range(3, get_turf(AOG)))
		for(var/obj/item/device/flashlight/F in H.contents)
			if(is_type_in_list(F, blacklisted_lights))
				continue
			if(F.brightness_on)
				if(!F.on)
					F.on = !F.on
					F.icon_state = "[initial(F.icon_state)]-on"
					F.set_light(F.brightness_on)

	for(var/obj/item/device/flashlight/F in range(3, get_turf(AOG)))
		if(F.brightness_on)
			if(!F.on)
				F.on = !F.on
				F.icon_state = "[initial(F.icon_state)]-on"
				F.set_light(F.brightness_on)

	var/image/I = image('icons/effects/effects.dmi', icon_state = shield_icon, layer = MOB_LAYER + 0.01)
	var/matrix/M = matrix(I.transform)
	M.Scale(0.3)
	I.alpha = 150
	I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	I.transform = M
	I.pixel_x = 12
	I.pixel_y = 12
	user.add_overlay(I)
	user.set_light(7)
	return TRUE

/*
 * Revive
 * Revive animal
 */
/datum/religion_rites/standing/revive_animal
	name = "Возрождение Животного"
	desc = "Возвращает душу животного из лучшего мира."
	ritual_length = (30 SECONDS)
	ritual_invocations = list("Я скажу, прошепчу, тихо произнесу такие слова...",
							  "...Пусть каждая болезнь оставит тебя...",
							  "...Ты не узнаешь, что испытываешь мучения, боль и страдание...",
							  "...Никто не может причинить вреда...",
							  "...Ты должен вытравить все целиком, изгнать заразу из тела животного...",
							  "...Пусть она уйдет в сырую землю, с водой уйдет и не вернется обратно...",
							  "...Бог помогает и мои слова становятся весомее...",)
	invoke_msg = "...Да будет так!"
	favor_cost = 150
	can_talismaned = FALSE

	needed_aspects = list(
		ASPECT_SPAWN = 1,
		ASPECT_RESCUE = 1,
	)

/datum/religion_rites/standing/revive_animal/can_start(mob/user, obj/AOG)
	if(!..())
		return FALSE
	if(!AOG)
		to_chat(user, "<span class='warning'>This rite requires an altar to be performed.</span>")
		return FALSE

	if(!AOG.buckled_mob)
		to_chat(user, "<span class='warning'>This rite requires an individual to be buckled to [AOG].</span>")
		return FALSE

	if(!isanimal(AOG.buckled_mob))
		to_chat(user, "<span class='warning'>Only a animal can go through the ritual.</span>")
		return FALSE

	var/mob/living/simple_animal/S = AOG.buckled_mob
	if(!S.animalistic)
		to_chat(user, "<span class='warning'>Only a animal can go through the ritual.</span>")
		return FALSE

	if(!S.stat == DEAD)
		to_chat(user, "<span class='warning'>Only a ritual is performed on dead animals.</span>")
		return FALSE

	return TRUE

/datum/religion_rites/standing/revive_animal/invoke_effect(mob/user, obj/AOG)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/simple_animal/animal = AOG.buckled_mob
	if(!istype(animal))
		to_chat(user, "<span class='warning'>Only a animal can go through the ritual.</span>")
		return FALSE
	animal.maxHealth = clamp(initial(animal.maxHealth) * divine_power, 0, max(animal.maxHealth, 300))
	animal.rejuvenate()

	return TRUE
