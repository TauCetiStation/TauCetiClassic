/mob/living/simple_animal/lizard
	name = "lizard"
	desc = "A cute tiny lizard."
	icon_state = "lizard"
	icon_living = "lizard"
	icon_dead = "lizard_dead"
	icon_gib = "lizard_gib"
	small = TRUE
	speak = list("hiss", "hiss", "hiss", "hiss", "hiss?", "hiss...")
	speak_emote = list("hisses")
	emote_hear = list("hisses")
	emote_see = list("runs in a circle", "shakes", "scritches at something")
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

	has_head = TRUE
	has_leg = TRUE

/mob/living/simple_animal/lizard/death()
	. = ..()
	desc = "It doesn't hiss anymore."

/mob/living/simple_animal/lizard/Crossed(atom/movable/AM)
	if(ishuman(AM))
		if(!stat)
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



