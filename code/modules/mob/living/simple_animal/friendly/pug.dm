//Corgi
/mob/living/simple_animal/pug
	name = "pug"
	real_name = "pug"
	desc = "Это мопс."
	icon_state = "pug"
	icon_living = "pug"
	icon_dead = "pug_dead"
	speak = list("Гав!", "Вуф!", "АУУУУ!")
	speak_emote = list("лает", "воет")
	emote_hear = list("лает", "воет")
	emote_see = list("виляет хвостом", "облизываетася")
	speak_chance = 1
	turns_per_move = 10
	w_class = SIZE_NORMAL
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/pug = 3)
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	see_in_dark = 5

	has_head = TRUE
	has_leg = TRUE

	default_emotes = list(
		/datum/emote/dance,
	)

/mob/living/simple_animal/pug/Life()
	..()

	if(stat == CONSCIOUS && !buckled)
		if(prob(1))
			emote("dance")

/mob/living/simple_animal/pug/attackby(obj/item/O, mob/user)  //Marker -Agouri
	if(istype(O, /obj/item/weapon/newspaper))
		user.SetNextMove(CLICK_CD_INTERACT)
		if(stat == CONSCIOUS)
			user.visible_message("<span class='notice'>[user] baps [name] on the nose with the rolled up [O]</span>")
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2))
					set_dir(i)
					sleep(1)
	else
		..()
