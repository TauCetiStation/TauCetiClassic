/mob/living/simple_animal/hostile/tomato
	name = "tomato"
	desc = "It's a horrifyingly enormous beef tomato, and it's packing extra beef!"
	icon_state = "tomato"
	icon_living = "tomato"
	icon_dead = "tomato_dead"
	icon_move = "tomato_move"
	speak_chance = 0
	turns_per_move = 5
	maxHealth = 15
	health = 15
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/tomatomeat = 1)
	response_help  = "prods the"
	response_disarm = "pushes aside the"
	response_harm   = "smacks the"
	harm_intent_damage = 5
	melee_damage_lower = 1
	melee_damage_upper = 5

/mob/living/simple_animal/hostile/tomato/atom_init(mapload, potency)
	. = ..()
	melee_damage_upper = round(potency / 6.5) //max 15, min 0
	melee_damage_lower = max((melee_damage_upper - 4), 0) //max 11, min 0
	maxHealth = max(round(potency / 4), 5) //max 25, min 5
	health = maxHealth
