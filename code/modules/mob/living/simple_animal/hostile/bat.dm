/mob/living/simple_animal/hostile/scarybat
	name = "space bats"
	desc = "A swarm of cute little blood sucking bats that looks pretty pissed."
	icon = 'icons/mob/animal.dmi'
	icon_state = "bat"
	icon_living = "bat"
	icon_dead = "bat_dead"
	icon_gib = "bat_dead"
	speak_chance = 0
	turns_per_move = 20
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 1)
	response_help = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speed = 4
	maxHealth = 20
	health = 20
	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

/mob/living/simple_animal/hostile/scarybat/Process_Spacemove(movement_dir = 0)
	return 1
