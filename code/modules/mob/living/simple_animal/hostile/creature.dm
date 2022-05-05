/mob/living/simple_animal/hostile/creature
	name = "creature"
	desc = "A sanity-destroying otherthing."
	speak_emote = list("gibbers")
	icon_state = "otherthing"
	icon_living = "otherthing"
	icon_dead = "otherthing-dead"
	health = 80
	maxHealth = 80
	melee_damage = 38
	w_class = SIZE_HUMAN
	attacktext = "chomp"
	attack_sound = list('sound/weapons/bite.ogg')
	faction = "creature"
	speed = 4

/mob/living/simple_animal/hostile/creature/troglodit
	name = "Троглодит"
	desc = "Это его пещера"
	icon_state = "troglodit"
	icon_dead = "troglodit_dead"
	butcher_results  = list(/obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice = 3)
	health = 50
	maxHealth = 50
	speed = 3
	melee_damage = 11

/mob/living/simple_animal/hostile/creature/ahaha
	name = "Землянной элементаль"
	desc  = "Ищи себя в наебаных дермо-демонами"
	icon = 'icons/mob/amorph.dmi'
	icon_state = "standing"
	icon_dead = "lying"
	melee_damage = 15