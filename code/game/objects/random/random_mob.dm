
//MOBS RANDOM
/obj/random/mobs/peacefull
	name = "Random peacefull mob"
	desc = "This is a peacefull mob."
	icon = 'code/modules/jungle/jungle.dmi'
	icon_state = "tindalos"
/obj/random/mobs/peacefull/item_to_spawn()
		return pick(\
						/mob/living/simple_animal/tindalos,\
						/mob/living/simple_animal/lizard,\
						/mob/living/simple_animal/mouse,\
						/mob/living/simple_animal/yithian\
		)

/obj/random/mobs/moderate
	name = "Random moderate mob"
	desc = "This is a random moderate mob."
	icon = 'code/modules/jungle/jungle.dmi'
	icon_state = "samas"
/obj/random/mobs/moderate/item_to_spawn()
		return pick(subtypesof(/mob/living/simple_animal/hostile/asteroid))

/obj/random/mobs/dangerous
	name = "Random Syringe"
	desc = "This is a random syringe."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"
/obj/random/mobs/dangerous/item_to_spawn()
		return pick(\
						/mob/living/simple_animal/hostile/giant_spider/nurse,\
						/mob/living/simple_animal/hostile/giant_spider/hunter,\
						/mob/living/simple_animal/hostile/giant_spider\
					)