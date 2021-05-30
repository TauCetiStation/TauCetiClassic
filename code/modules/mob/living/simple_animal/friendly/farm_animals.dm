//goat
/mob/living/simple_animal/hostile/retaliate/goat
	name = "goat"
	desc = "Not known for their pleasant disposition."
	icon_state = "goat"
	icon_living = "goat"
	icon_dead = "goat_dead"
	speak = list("EHEHEHEHEH","eh?")
	speak_emote = list("brays")
	emote_hear = list("brays")
	emote_see = list("shakes its head", "stamps a foot", "glares around")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 4)
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "kick"
	faction = "goat"
	attacktext = "kicks"
	health = 40
	melee_damage = 3
	var/datum/reagents/udder = null
	footstep_type = FOOTSTEP_MOB_SHOE

	has_head = TRUE
	has_leg = TRUE

/mob/living/simple_animal/hostile/retaliate/goat/atom_init()
	udder = new(50)
	udder.my_atom = src
	. = ..()

/mob/living/simple_animal/hostile/retaliate/goat/Destroy()
	QDEL_NULL(udder)
	return ..()

/mob/living/simple_animal/hostile/retaliate/goat/Life()
	. = ..()
	if(.)
		//chance to go crazy and start wacking stuff
		if(!enemies.len && prob(1))
			Retaliate()

		if(enemies.len && prob(10))
			enemies = list()
			LoseTarget()
			src.visible_message("<span class='notice'>[src] calms down.</span>")

		if(stat == CONSCIOUS)
			if(udder && prob(5))
				udder.add_reagent("milk", rand(5, 10))

		if(locate(/obj/effect/spacevine) in loc)
			var/obj/effect/spacevine/SV = locate(/obj/effect/spacevine) in loc
			qdel(SV)
			if(prob(10))
				say("Nom")

		if(!pulledby)
			for(var/direction in shuffle(list(1,2,4,8,5,6,9,10)))
				var/step = get_step(src, direction)
				if(step)
					if(locate(/obj/effect/spacevine) in step)
						Move(step)

/mob/living/simple_animal/hostile/retaliate/goat/Retaliate()
	..()
	src.visible_message("<span class='warning'>[src] gets an evil-looking gleam in their eye.</span>")

/mob/living/simple_animal/hostile/retaliate/goat/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()
	if(!stat)
		if(locate(/obj/effect/spacevine) in loc)
			var/obj/effect/spacevine/SV = locate(/obj/effect/spacevine) in loc
			qdel(SV)
			if(prob(10))
				say("Nom")

/mob/living/simple_animal/hostile/retaliate/goat/attackby(obj/item/O, mob/user)
	if(stat == CONSCIOUS && istype(O, /obj/item/weapon/reagent_containers/glass))
		user.SetNextMove(CLICK_CD_INTERACT)
		user.visible_message("<span class='notice'>[user] milks [src] using \the [O].</span>")
		var/obj/item/weapon/reagent_containers/glass/G = O
		var/transfered = udder.trans_id_to(G, "milk", rand(5,10))
		if(G.reagents.total_volume >= G.volume)
			to_chat(user, "<span class='warning'>The [O] is full.</span>")
		if(!transfered)
			to_chat(user, "<span class='warning'>The udder is dry. Wait a bit longer...</span>")
	else
		..()

/mob/living/simple_animal
	name = "animal"
	desc = "Just simple animal"
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "kicks the"
	attacktext = "kicks"

//cow
/mob/living/simple_animal/cow
	name = "cow"
	desc = "Known for their milk, just don't tip them over."
	icon_state = "cow"
	icon_living = "cow"
	icon_dead = "cow_dead"
	icon_gib = "cow_gib"
	speak = list("moo?","moo","MOOOOOO")
	speak_emote = list("moos","moos hauntingly")
	emote_hear = list("brays")
	emote_see = list("shakes its head")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab = 6)
	health = 50

	has_head = TRUE
	has_leg = TRUE

	var/datum/reagents/udder = null

/mob/living/simple_animal/cow/atom_init()
	udder = new(50)
	udder.my_atom = src
	. = ..()

/mob/living/simple_animal/cow/Destroy()
	QDEL_NULL(udder)
	return ..()

/mob/living/simple_animal/cow/attackby(obj/item/O, mob/user)
	if(stat == CONSCIOUS && istype(O, /obj/item/weapon/reagent_containers/glass))
		user.SetNextMove(CLICK_CD_INTERACT)
		user.visible_message("<span class='notice'>[user] milks [src] using \the [O].</span>")
		var/obj/item/weapon/reagent_containers/glass/G = O
		var/transfered = udder.trans_id_to(G, "milk", rand(5,10))
		if(G.reagents.total_volume >= G.volume)
			to_chat(user, "<span class='warning'>The [O] is full.</span>")
		if(!transfered)
			to_chat(user, "<span class='warning'>The udder is dry. Wait a bit longer...</span>")
	else
		..()

/mob/living/simple_animal/cow/Life()
	. = ..()
	if(stat == CONSCIOUS)
		if(udder && prob(5))
			udder.add_reagent("milk", rand(5, 10))
		else if(prob(15))
			playsound(src, 'sound/voice/cowmoos.ogg', VOL_EFFECTS_MASTER, null, null, -3)

/mob/living/simple_animal/cow/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()
	if(. && prob(55))
		playsound(src, 'sound/misc/cowbell.ogg', VOL_EFFECTS_MASTER, null, null, -3)

/mob/living/simple_animal/chick
	name = "chick"
	desc = "Adorable! They make such a racket though."
	icon_state = "chick"
	icon_living = "chick"
	icon_dead = "chick_dead"
	icon_gib = "chick_gib"
	speak = list("Cherp.","Cherp?","Chirrup.","Cheep!")
	speak_emote = list("cheeps")
	emote_hear = list("cheeps")
	emote_see = list("pecks at the ground","flaps its tiny wings")
	speak_chance = 2
	turns_per_move = 2
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 1)
	health = 1
	var/amount_grown = 0
	pass_flags = PASSTABLE | PASSGRILLE
	small = 1

	has_head = TRUE
	has_leg = TRUE

/mob/living/simple_animal/chick/atom_init()
	. = ..()
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)

/mob/living/simple_animal/chick/Life()
	. = ..()
	if(!.)
		return
	if(!stat)
		amount_grown += rand(1,2)
		if(amount_grown >= 100)
			new /mob/living/simple_animal/chicken(src.loc)
			qdel(src)

var/const/MAX_CHICKENS = 50
var/global/chicken_count = 0

/mob/living/simple_animal/chicken
	name = "chicken"
	desc = "Hopefully the eggs are good this season."
	icon_state = "chicken"
	icon_living = "chicken"
	icon_dead = "chicken_dead"
	icon_move = "chicken_move"
	speak = list("Cluck!","BWAAAAARK BWAK BWAK BWAK!","Bwaak bwak.")
	speak_emote = list("clucks","croons")
	emote_hear = list("clucks")
	emote_see = list("pecks at the ground","flaps its wings viciously")
	speak_chance = 2
	turns_per_move = 3
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 2)
	health = 10
	var/eggsleft = 0
	var/body_color
	pass_flags = PASSTABLE
	small = 1

	has_head = TRUE
	has_leg = TRUE

/mob/living/simple_animal/chicken/atom_init()
	. = ..()
	if(!body_color)
		body_color = pick(list("brown", "black", "white"))
	icon_state = "chicken_[body_color]"
	icon_living = "chicken_[body_color]"
	icon_dead = "chicken_[body_color]_dead"
	icon_move = "chicken_[body_color]_move"
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)
	chicken_count += 1

/mob/living/simple_animal/chicken/death()
	..()
	chicken_count -= 1

/mob/living/simple_animal/chicken/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/wheat)) //feedin' dem chickens
		user.SetNextMove(CLICK_CD_INTERACT)
		if(!stat && eggsleft < 8)
			user.visible_message("<span class='notice'>[user] feeds [O] to [name]! It clucks happily.</span>","<span class='notice'>You feed [O] to [name]! It clucks happily.</span>")
			user.drop_item()
			qdel(O)
			eggsleft += rand(1, 4)
			//world << eggsleft
		else
			to_chat(user, "<span class='notice'>[name] doesn't seem hungry!</span>")
	else
		..()

/mob/living/simple_animal/chicken/Life()
	. =..()
	if(!.)
		return
	if(!stat && prob(3) && eggsleft > 0)
		visible_message("[src] [pick("lays an egg.","squats down and croons.","begins making a huge racket.","begins clucking raucously.")]")
		eggsleft--
		var/obj/item/weapon/reagent_containers/food/snacks/egg/E = new(get_turf(src))
		E.pixel_x = rand(-6,6)
		E.pixel_y = rand(-6,6)
		if(chicken_count < MAX_CHICKENS && prob(10))
			START_PROCESSING(SSobj, E)

/obj/item/weapon/reagent_containers/food/snacks/egg/var/amount_grown = 0
/obj/item/weapon/reagent_containers/food/snacks/egg/process()
	if(isturf(loc))
		amount_grown += rand(1,2)
		if(amount_grown >= 100)
			visible_message("[src] hatches with a quiet cracking sound.")
			new /mob/living/simple_animal/chick(get_turf(src))
			STOP_PROCESSING(SSobj, src)
			qdel(src)
	else
		STOP_PROCESSING(SSobj, src)

/mob/living/simple_animal/pig
	name = "pig"
	desc = "Oink oink."
	icon_state = "pig"
	icon_living = "pig"
	icon_dead = "pig_dead"
	speak = list("oink?","oink","OINK")
	speak_emote = list("oinks")
	emote_see = list("rolls around")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/ham = 6)
	health = 50

	has_head = TRUE
	has_leg = TRUE

/mob/living/simple_animal/turkey
	name = "turkey"
	desc = "Benjamin Franklin would be proud."
	icon_state = "turkey"
	icon_living = "turkey"
	icon_dead = "turkey_dead"
	speak = list("gobble?","gobble","GOBBLE")
	speak_emote = list("gobble")
	emote_see = list("struts around")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 4)
	health = 50

	has_head = TRUE
	has_leg = TRUE

/mob/living/simple_animal/goose
	name = "goose"
	desc = "A pretty goose. Would make a nice comforter."
	icon_state = "goose"
	icon_living = "goose"
	icon_dead = "goose_dead"
	speak = list("quack?","quack","QUACK")
	speak_emote = list("quacks")
	emote_see = list("flaps it's wings")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 6)
	health = 50

	has_head = TRUE
	has_leg = TRUE

/mob/living/simple_animal/seal
	name = "seal"
	desc = "A beautiful white seal."
	icon_state = "seal"
	icon_living = "seal"
	icon_dead = "seal_dead"
	speak = list("Urk?","urk","URK")
	speak_emote = list("urks")
	emote_see = list("flops around")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 6)
	health = 50

	has_head = TRUE
	has_arm = TRUE

/mob/living/simple_animal/walrus
	name = "walrus"
	desc = "A big brown walrus."
	icon_state = "walrus"
	icon_living = "walrus"
	icon_dead = "walrus_dead"
	speak = list("Urk?","urk","URK")
	speak_emote = list("urks")
	emote_see = list("flops around")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 6)
	health = 50

	has_head = TRUE
	has_arm = TRUE
