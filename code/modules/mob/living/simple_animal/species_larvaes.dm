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
	var/stage = 1

/mob/living/simple_animal/grown_larvae/atom_init()
	. = ..()
	handle_evolving()

/mob/living/simple_animal/grown_larvae/Stat()
	..()
	stat(null)
	if(statpanel("Status"))
		stat("Прогресс роста: [stage * 25]/100")

/mob/living/simple_animal/grown_larvae/serpentid
	name = "Serpentid larvae"
	icon_state = "larvae-serpentid"
	icon_living = "larvae-serpentid"
	icon_dead = "larvae-serpentid_dead"

/mob/living/simple_animal/grown_larvae/small_moth
	name = "Young moth"
	icon_state = "small_moth"
	icon_living = "small_moth"
	icon_dead = "small_moth_dead"
	minbodytemp = 288
	maxbodytemp = 301
	heat_damage_per_tick = 9
	bodytemperature = 293

/mob/living/simple_animal/grown_larvae/small_moth/evolve_to_young_adult()
	var/mob/living/carbon/human/moth/M = new(loc)
	mind.transfer_to(M)
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

/mob/living/simple_animal/mouse/rat/newborn_moth/atom_init()
	. = ..()
	addtimer(CALLBACK(src, .proc/handle_evolving), 100, TIMER_UNIQUE)

/mob/living/simple_animal/mouse/rat/newborn_moth/evolve_to_young_adult()
	var/mob/living/simple_animal/small_moth/moth = new(loc)
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
