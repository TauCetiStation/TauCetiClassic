//Shiba-Inu!
/mob/living/simple_animal/shiba
	name = "Shiba Inu"
	real_name = "shiba inu"
	desc = "It's a small, agile cute doggy."
	icon_state = "shiba"
	icon_living = "shiba"
	icon_dead = "shiba_dead"
	speak = list("Kyan!","Van!", "Woof!", "Bark!", "AUUUUUU", "Yap!")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks", "woofs", "pants", "vans")
	emote_see = list("shakes its head", "shivers", "looks cute")
	speak_chance = 20
	turns_per_move = 3
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/shiba = 2)
	response_help  = "pets the"
	response_disarm = "bops the"
	response_harm   = "kicks the"
	see_in_dark = 5
	min_oxy = 16 //Require atleast 16kPA oxygen
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius

	has_head = TRUE
	has_leg = TRUE

	var/facehugger
	var/turns_since_scan = 0
	var/mob/living/simple_animal/mouse/movement_target

/obj/item/weapon/reagent_containers/food/snacks/meat/shiba
	name = "shiba meat"
	desc = "Tastes like... well you know..."

/mob/living/simple_animal/shiba/regenerate_icons()
	cut_overlays()
	if(facehugger)
		add_overlay(image('icons/mob/mask.dmi',"facehugger_corgi"))

/mob/living/simple_animal/shiba/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/weapon/newspaper))
		user.SetNextMove(CLICK_CD_MELEE)
		if(!stat)
			visible_message("<span class='notice'>[user] baps [name] on the nose with the rolled up [O]</span>")
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2))
					dir = i
					sleep(1)
	else
		..()

/mob/living/simple_animal/shiba/Life()
	..()

	if(!stat && !resting && !buckled)
		if(prob(1))
			emote(pick("chases its tail"))
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
					dir = i
					sleep(1)

	for(var/obj/item/weapon/bikehorn/dogtoy/histoy in oview(src, 3))
		if(prob(30))
			emote(pick("barks!","woofs loudly!","eyes [histoy] joyfully."))
		break

	if(!stat && !resting && !buckled)
		turns_since_scan++
		if(turns_since_scan > 5)
			walk_to(src,0)
			turns_since_scan = 0
			if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
				movement_target = null
				stop_automated_movement = 0
			if( !movement_target || !(movement_target.loc in oview(src, 3)) )
				movement_target = null
				stop_automated_movement = 0
				for(var/obj/item/weapon/bikehorn/dogtoy/histoy in oview(src,3))
					if(isturf(histoy.loc))
						movement_target = histoy
						break
			if(movement_target)
				stop_automated_movement = 1
				walk_to(src,movement_target,0,3)
	for(var/obj/item/weapon/bikehorn/dogtoy/histoy in oview(1,src))
		if(prob(50))
			for(var/i in list(1,2,4,8,4,2,1,2))
				dir = i
				sleep(1)
		if(prob(40))
			src.visible_message(pick("[bicon(src)][src] joyfully plays with the toy!","[bicon(src)][src] rolls the toy back and forth!","[bicon(src)][src] happily twists and spins the toy!","[bicon(src)][src] thoroughly sniffs the toy all around!"), 2)
