/mob/living/simple_animal/grown_larvae/proc/evolve_to_young_adult()
	return

/mob/living/simple_animal/grown_larvae/proc/handle_evolving()
	if(stat == DEAD)
		return
	if(!mind || !client || !key)
		addtimer(CALLBACK(src, .proc/handle_evolving), 100, TIMER_UNIQUE)
		return
	if(evolv_stage < 4)
		addtimer(CALLBACK(src, .proc/handle_evolving), 100, TIMER_UNIQUE)
		evolv_stage++
		switch(evolv_stage)
			if(2)
				maxHealth = 20
				health += 20
			if(3)
				maxHealth = 40
				health += 40
				speed -= 0.5
				melee_damage = 2
		return
	evolve_to_young_adult()

/mob/living/simple_animal/grown_larvae
	name = "larva"
	desc = "It's a little alien skittery critter. Hiss."
	icon = 'icons/mob/animal.dmi'
	health = 10
	maxHealth = 10
	response_help   = "hugs"
	response_disarm = "gently pushes"
	response_harm   = "punches"
	has_head = TRUE
	has_arm = TRUE
	has_leg = TRUE
	turns_per_move = 4
	speed = 3
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/alien_meat = 3)

/mob/living/simple_animal/grown_larvae/atom_init()
	. = ..()
	handle_evolving()

/mob/living/simple_animal/grown_larvae/Stat()
	..()
	stat(null)
	if(statpanel("Status"))
		stat("Прогресс роста: [evolv_stage * 25]/100")

/mob/living/simple_animal/grown_larvae/serpentid
	name = "Nabber larva"
	icon_state = "larvae-serpentid"
	icon_living = "larvae-serpentid"
	icon_dead = "larvae-serpentid_dead"
	holder_type = /obj/item/weapon/holder/nabber

/mob/living/simple_animal/grown_larvae/serpentid/Login()
	. = ..()
	to_chat(src, "<span class='userdanger'>Вы агрессивная форма жизни, практикующая каннибализм, так как мясо вашего вида очень вкусное.</span>")

/mob/living/simple_animal/grown_larvae/serpentid/evolve_to_young_adult()
	var/mob/living/simple_animal/grown_larvae/snake/S = new(get_turf(loc))
	mind.transfer_to(S)
	qdel(src)

/mob/living/simple_animal/grown_larvae/serpentid/death()
	if(butcher_results)
		for(var/path in butcher_results)
			for(var/i = 1 to butcher_results[path])
				new path(loc)
	qdel(src)

/mob/living/simple_animal/grown_larvae/serpentid/helpReaction(mob/living/carbon/human/attacker, show_message = TRUE)
	get_scooped(attacker)

/mob/living/simple_animal/grown_larvae/snake
	name = "Snake"
	desc = "Hiss"
	icon_state = "snake"
	icon_living = "snake"
	icon_dead = "snake_dead"
	ventcrawler = 2
	melee_damage = 5
	speed = 1
	has_arm = FALSE
	has_leg = FALSE
	holder_type = /obj/item/weapon/holder/snake

/mob/living/simple_animal/grown_larvae/snake/Login()
	. = ..()
	to_chat(src, "<span class='userdanger'>Вы агрессивная форма жизни в стадии развития до взрослой особи. Ваша сила укуса растёт.</span>")

/mob/living/simple_animal/grown_larvae/snake/evolve_to_young_adult()
	var/datum/effect/effect/system/smoke_spread/bad/smoke = new /datum/effect/effect/system/smoke_spread/bad()
	smoke.set_up(10, 0, loc)
	smoke.start()
	playsound(src, 'sound/effects/bamf.ogg', VOL_EFFECTS_MASTER)
	var/mob/living/carbon/human/serpentid/S = new(get_turf(loc))
	mind.transfer_to(S)
	create_and_setup_role(/datum/role/animal, S)
	var/lore = "Вы агрессивная форма жизни с примитивным интеллектом уровня обезьяны. Вторжение в вашу комфортную зону означает агрессию по отношению к вам. Представителей своего вида вы предпочитаете видеть в качестве завтрака. Своей хваткой вы способны разрывать тела на части. Ваша цель - выжить."
	to_chat(S, "<span class='userdanger'>[lore]</span>")
	S.mind.store_memory(lore)
	qdel(src)

/mob/living/simple_animal/grown_larvae/snake/helpReaction(mob/living/carbon/human/attacker, show_message = TRUE)
	get_scooped(attacker)

/mob/living/simple_animal/grown_larvae/small_moth
	name = "Young moth"
	icon_state = "small_moth"
	icon_living = "small_moth"
	icon_dead = "small_moth_dead"
	minbodytemp = 288
	maxbodytemp = 301
	heat_damage_per_tick = 9
	bodytemperature = 293
	holder_type = /obj/item/weapon/holder/moth_small

/mob/living/simple_animal/grown_larvae/small_moth/Login()
	. = ..()
	to_chat(src, "<span class='userdanger'>Вы дружелюбная форма жизни в стадии развития до взрослой особи. Помните, чем больше вы растёте, тем больше в вас мяса.</span>")

/mob/living/simple_animal/grown_larvae/small_moth/evolve_to_young_adult()
	var/mob/living/carbon/human/moth/M = new(get_turf(loc))
	mind.transfer_to(M)
	M.mind.name = M.real_name
	create_and_setup_role(/datum/role/animal, M)
	var/lore = "Вы всеядная форма жизни с примитивным интеллектом уровня обезьяны, предпочитающая питаться падалью. В число ваших врагов входят только Серпентиды, отношение к остальным зачастую нейтральное. Ваша цель - выжить."
	to_chat(M, "<span class='userdanger'>[lore]</span>")
	M.mind.store_memory(lore)
	qdel(src)

/mob/living/simple_animal/grown_larvae/small_moth/helpReaction(mob/living/carbon/human/attacker, show_message = TRUE)
	get_scooped(attacker)

/mob/living/simple_animal/grown_larvae/newborn_moth
	name = "Newborn moth"
	real_name = "Newborn moth"
	desc = "It's a little alien skittery critter. Hiss."
	maxHealth = 5
	health = 5
	melee_damage = 2
	ventcrawler = 0
	icon_state = "newborn_moth"
	icon_living = "newborn_moth"
	icon_dead = "small_moth_dead"
	icon_move = null
	speak_chance = 0
	speak = list("Chirp!", "Chirp?")
	speak_emote = list()
	emote_hear = list()
	emote_see = list()
	response_help   = "hugs"
	response_disarm = "gently pushes"
	response_harm   = "punches"
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/alien_meat = 1)
	minbodytemp = 288
	maxbodytemp = 301
	heat_damage_per_tick = 9
	bodytemperature = 293
	holder_type = null
	faction = "neutral"
	has_arm = FALSE
	has_leg = FALSE
	holder_type = /obj/item/weapon/holder/mothroach

/mob/living/simple_animal/grown_larvae/newborn_moth/atom_init()
	. = ..()
	AddComponent(/datum/component/gnawing)

/mob/living/simple_animal/grown_larvae/newborn_moth/Login()
	. = ..()
	to_chat(src, "<span class='userdanger'>Вы дружелюбная форма жизни, готовая съесть что угодно.</span>")

/mob/living/simple_animal/grown_larvae/newborn_moth/atom_init()
	. = ..()
	addtimer(CALLBACK(src, .proc/handle_evolving), 100, TIMER_UNIQUE)

/mob/living/simple_animal/grown_larvae/newborn_moth/evolve_to_young_adult()
	var/mob/living/simple_animal/grown_larvae/small_moth/moth = new(get_turf(loc))
	mind.transfer_to(moth)
	qdel(src)

/mob/living/simple_animal/grown_larvae/newborn_moth/death()
	if(butcher_results)
		for(var/path in butcher_results)
			for(var/i = 1 to butcher_results[path])
				new path(loc)
	qdel(src)

/mob/living/simple_animal/grown_larvae/newborn_moth/helpReaction(mob/living/carbon/human/attacker, show_message = TRUE)
	get_scooped(attacker)

//sweet to attract hungry assistants
/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/alien_meat
	name = "Larva meat"
	desc = "Meat. Sometimes liquid, sometimes jelly-like, sometimes crunchy and sweet. Despite the texture, it smells delicious."
	icon_state = "xenomeat"
	filling_color = "#cadaba"
