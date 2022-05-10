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

/mob/living/simple_animal/hostile/troglodit
	name = "Троглодит"
	desc = "Это его пещера"
	icon_state = "troglodit"
	icon_dead = "troglodit_dead"
	faction = "Nigon"
	butcher_results  = list(/obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice = 3)
	health = 50
	maxHealth = 50
	speed = 3
	melee_damage = 11

/mob/living/simple_animal/hostile/creature/ahaha
	name = "Землянной элементаль"
	desc  = "Ищи себя в выебаных дермо-демонами"
	icon = 'icons/mob/amorph.dmi'
	icon_state = "standing"
	icon_dead = "lying"
	melee_damage = 15

mob/living/simple_animal/hostile/beholder
	name = "Злобоглаз"
	desc = "Он сглазит тебя"
	icon = 'icons/misc/jungle.dmi'
	icon_state = "native1"
	icon_living = "native1"
	icon_dead = "native1_dead"
	faction = "Nigon"
	speak_chance = 25
	speak = list("РЕЕЕЕЕ")
	speak_emote = list("кричит")
	ranged = TRUE
	ranged_message = "пялится"
	melee_damage = 10
	turns_per_move = 1
	retreat_distance = 5
	minimum_distance = 5
	projectiletype = /obj/item/projectile/temp/beholder
	projectilesound = 'sound/Event/beholder.ogg'
	stop_automated_movement_when_pulled = FALSE
	w_class= SIZE_HUMAN
	var/my_type = 1
	speed = 3


/obj/item/projectile/temp/beholder
	name = ""
	icon_state = "ice_2"
	desc = "Ты как это осмотрел блять?"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"
	temperature = 50
	var/type_of_cursed
	var/isChickenCurse = FALSE

/obj/item/projectile/temp/beholder/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
	..()
	var/mob/living/L = target
	if(isChickenCurse)
		if(isliving(L)&&(L.mind)&&(istype(L,/mob/living/carbon/human)))
			L.MyTrueNotChikenBody = target
			var/mob/living/simple_animal/chicken/C = new/mob/living/simple_animal/chicken(L.loc)
			L.mind.transfer_to(C)
			C.MyTrueNotChikenBody = L.MyTrueNotChikenBody
			playsound(L, 'sound/Event/cursed.ogg', VOL_EFFECTS_MASTER)
			L.loc = null
		else
			return


/obj/item/projectile/temp/beholder/atom_init()
	..()
	type_of_cursed = rand(0,2)
	switch(type_of_cursed)
		if(0)
			name = "Леденящий снаряд"
			icon_state = "ice_2"
			temperature = 50
		if(1)
			name = "Огненный снаряд"
			icon_state = "red_1"
			temperature = 400
		if(2)
			name = "КУРИНЫЙ СНАРЯД"
			icon_state = "bluespace"
			temperature = 0
			isChickenCurse = TRUE
