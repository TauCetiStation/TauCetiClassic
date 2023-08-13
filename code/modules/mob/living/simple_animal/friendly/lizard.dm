/mob/living/simple_animal/lizard
	name = "lizard"
	desc = "Милая крошечная ящерица."
	icon_state = "lizard"
	icon_living = "lizard"
	icon_dead = "lizard_dead"
	icon_gib = "lizard_gib"
	speak = list("Хсс","Хсс","Хсс","Хсс","Хсс?","Хсс...")
	speak_emote = list("шипит")
	emote_hear = list("шипит")
	emote_see = list("бегает по кругу","чешется","выпускает язык")
	speak_chance = 1
	health = 10
	maxHealth = 10
	density = FALSE
	layer = MOB_LAYER
	pass_flags = PASSTABLE
	attacktext = "gnaw"
	melee_damage = 2
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"
	ventcrawler = 2
	holder_type = /obj/item/weapon/holder/lizard
	w_class = SIZE_MINUSCULE

	has_head = TRUE
	has_leg = TRUE

/mob/living/simple_animal/lizard/atom_init()
	. = ..()
	AddComponent(/datum/component/gnawing)

/mob/living/simple_animal/lizard/death()
	. = ..()
	desc = "Она больше не будет шипеть..."

/mob/living/simple_animal/lizard/Crossed(atom/movable/AM)
	if(ishuman(AM))
		if(stat == CONSCIOUS)
			var/mob/M = AM
			to_chat(M, "<span class='notice'>[bicon(src)] Hiss!</span>")
	. = ..()

/mob/living/simple_animal/lizard/MouseDrop(atom/over_object)
	var/mob/living/carbon/H = over_object
	if(!istype(H) || !Adjacent(H) || ismob(H.loc))
		return ..()

	if(H.a_intent == INTENT_HELP)
		get_scooped(H)
		return
	else
		return ..()

/mob/living/simple_animal/lizard/get_scooped(mob/living/carbon/grabber)
	if(stat >= DEAD)
		return
	..()
