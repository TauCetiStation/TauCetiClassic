//Corgi
/mob/living/simple_animal/pug
	name = "pug"
	real_name = "pug"
	desc = "It's a pug."
	icon_state = "pug"
	icon_living = "pug"
	icon_dead = "pug_dead"
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks", "woofs", "yaps","pants")
	emote_see = list("shakes its head", "chases its tail","shivers")
	speak_chance = 1
	turns_per_move = 10
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/pug = 3)
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	see_in_dark = 5

	has_head = TRUE
	has_leg = TRUE

/mob/living/simple_animal/pug/Life()
	..()

	if(!stat && !resting && !buckled)
		if(prob(1))
			emote(pick("chases its tail"))
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
					dir = i
					sleep(1)

/mob/living/simple_animal/pug/attackby(obj/item/O, mob/user)  //Marker -Agouri
	if(istype(O, /obj/item/weapon/newspaper))
		user.SetNextMove(CLICK_CD_INTERACT)
		if(!stat)
			user.visible_message("<span class='notice'>[user] baps [name] on the nose with the rolled up [O]</span>")
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2))
					dir = i
					sleep(1)
	else
		..()
