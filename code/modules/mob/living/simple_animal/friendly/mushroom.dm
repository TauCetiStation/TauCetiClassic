/mob/living/simple_animal/mushroom
	name = "walking mushroom"
	desc = "Это огромный гриб... на ножках?"
	icon_state = "mushroom"
	icon_living = "mushroom"
	icon_dead = "mushroom_dead"
	w_class = SIZE_MINUSCULE
	speak_chance = 0
	turns_per_move = 1
	maxHealth = 5
	health = 5
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice = 1)
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "whacks the"
	harm_intent_damage = 5
	ventcrawler = 2

	has_head = TRUE
	has_leg = TRUE
