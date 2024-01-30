/mob/living/simple_animal/grown_larvae
	name = "larvae"
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
	name = "Nabber larvae"
	icon_state = "larvae-serpentid"
	icon_living = "larvae-serpentid"
	icon_dead = "larvae-serpentid_dead"

/mob/living/simple_animal/grown_larvae/serpentid/Login()
	. = ..()
	to_chat(src, "<span class='userdanger'>Вы агрессивная форма жизни практикующая канибализм, так как мясо вашего вида очень вкусное.</span>")

/mob/living/simple_animal/grown_larvae/serpentid/evolve_to_young_adult()
	var/mob/living/simple_animal/grown_larvae/snake/S = new(loc)
	mind.transfer_to(S)
	qdel(src)

/mob/living/simple_animal/grown_larvae/serpentid/death()
	if(butcher_results)
		for(var/path in butcher_results)
			for(var/i = 1 to butcher_results[path])
				new path(loc)
	qdel(src)

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

/mob/living/simple_animal/grown_larvae/snake/Login()
	. = ..()
	to_chat(src, "<span class='userdanger'>Вы агрессивная форма жизни в стадии развития до взрослой особи. Ваша сила укуса растёт.</span>")

/mob/living/simple_animal/grown_larvae/snake/handle_get_out()
	if(istype(loc, /obj))
		forceMove(get_turf(loc))
		qdel(loc)
	if(istype(loc, /obj/item/weapon/storage))
		forceMove(get_turf(loc))
		qdel(loc)
	if(istype(loc, /mob/living))
		forceMove(get_turf(loc))
		var/mob/living/L = loc
		L.apply_damage(melee_damage)

/mob/living/simple_animal/grown_larvae/snake/evolve_to_young_adult()
	var/datum/effect/effect/system/smoke_spread/bad/smoke = new /datum/effect/effect/system/smoke_spread/bad()
	smoke.set_up(10, 0, loc)
	smoke.start()
	playsound(src, 'sound/effects/bamf.ogg', VOL_EFFECTS_MASTER)
	var/mob/living/carbon/human/serpentid/S = new(loc)
	mind.transfer_to(S)
	create_and_setup_role(/datum/role/animal, S)
	var/lore = "Вы агрессивная форма жизни с примитивным интеллектом уровня обезьяны. Вторжение в вашу комфортную зону означает агрессию по отношению к вам. Представителей своего вида вы предпочитаете видеть в качестве завтрака. Своей хваткой вы способны разрывать тела на части. Ваша цель - выжить."
	to_chat(S, "<span class='userdanger'>[lore]</span>")
	S.mind.store_memory(lore)
	qdel(src)

/mob/living/simple_animal/grown_larvae/small_moth
	name = "Young moth"
	icon_state = "small_moth"
	icon_living = "small_moth"
	icon_dead = "small_moth_dead"
	minbodytemp = 288
	maxbodytemp = 301
	heat_damage_per_tick = 9
	bodytemperature = 293

/mob/living/simple_animal/grown_larvae/small_moth/Login()
	. = ..()
	to_chat(src, "<span class='userdanger'>Вы дружелюбная форма жизни в стадии развития до взрослой особи. Помните, чем больше вы растёте, тем больше в вас мяса.</span>")

/mob/living/simple_animal/grown_larvae/small_moth/evolve_to_young_adult()
	var/mob/living/carbon/human/moth/M = new(loc)
	mind.transfer_to(M)
	create_and_setup_role(/datum/role/animal, M)
	var/lore = "Вы всеядная форма жизни с примитивным интеллектом уровня обезьяны, предпочитающая питаться падалью. В число ваших врагов входят только Серпентиды, отношение к остальным зачастую нейтральное. Ваша цель - выжить."
	to_chat(M, "<span class='userdanger'>[lore]</span>")
	M.mind.store_memory(lore)
	qdel(src)

/mob/living/simple_animal/mouse/rat/newborn_moth
	name = "Newborn moth"
	real_name = "Newborn moth"
	desc = "It's a little alien skittery critter. Hiss."
	health = 5
	maxHealth = 5
	melee_damage = 0
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
	ventcrawler = 2
	has_arm = FALSE
	has_leg = FALSE

/mob/living/simple_animal/mouse/rat/newborn_moth/Login()
	. = ..()
	to_chat(src, "<span class='userdanger'>Вы дружелюбная форма жизни готовая съесть что-угодно.</span>")

/mob/living/simple_animal/mouse/rat/newborn_moth/atom_init()
	. = ..()
	addtimer(CALLBACK(src, .proc/handle_evolving), 100, TIMER_UNIQUE)

/mob/living/simple_animal/mouse/rat/newborn_moth/evolve_to_young_adult()
	var/mob/living/simple_animal/grown_larvae/small_moth/moth = new(loc)
	mind.transfer_to(moth)
	qdel(src)

/mob/living/simple_animal/mouse/rat/newborn_moth/death()
	if(butcher_results)
		for(var/path in butcher_results)
			for(var/i = 1 to butcher_results[path])
				new path(loc)
	qdel(src)

//sweet to attract hungry assistants
/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/alien_meat
	name = "Larvae meat"
	desc = "Meat. Sometimes liquid, sometimes jelly-like, sometimes crunchy and sweet. Despite the texture, it smells delicious."
	icon_state = "xenomeat"
	filling_color = "#cadaba"
