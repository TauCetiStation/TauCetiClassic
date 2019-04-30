/mob/living/simple_animal/mouse
	name = "mouse"
	real_name = "mouse"
	desc = "It's a small, disease-ridden rodent."
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	icon_move = "mouse_gray_move"
	speak = list("Squeek!","SQUEEK!","Squeek?")
	speak_emote = list("squeeks","squeeks","squiks")
	emote_hear = list("squeeks","squeaks","squiks")
	emote_see = list("runs in a circle", "shakes", "scritches at something")
	pass_flags = PASSTABLE
	small = TRUE
	speak_chance = 1
	turns_per_move = 8
	see_in_dark = 6
	maxHealth = 15
	health = 15
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 1)
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "stamps on the"
	density = FALSE
	var/body_color //brown, gray and white, leave blank for random
	layer = MOB_LAYER
	min_oxy = 16 //Require atleast 16kPA oxygen
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius
	universal_understand = 1
	holder_type = /obj/item/weapon/holder/mouse
	ventcrawler = 2

/obj/items/weapons/traiorcheese

/mob/living/simple_animal/mouse/Life()
	..()
	if(!stat && prob(speak_chance))
		for(var/mob/M in view())
			M << 'sound/effects/mousesqueek.ogg'

	if(!ckey && stat == CONSCIOUS && prob(0.5))
		stat = UNCONSCIOUS
		icon_state = "mouse_[body_color]_sleep"
		wander = 0
		speak_chance = 0
		//snuffles
	else if(stat == UNCONSCIOUS)
		if(ckey || prob(1))
			stat = CONSCIOUS
			icon_state = "mouse_[body_color]"
			wander = 1
		else if(prob(5))
			emote("snuffles")

/mob/living/simple_animal/mouse/atom_init()
	. = ..()
	name = "[name] ([rand(1, 1000)])"
	real_name = name

	if(!body_color)
		body_color = pick( list("brown","gray","white") )
		switch(body_color)
			if("brown")
				holder_type = /obj/item/weapon/holder/mouse/brown
			if("gray")
				holder_type = /obj/item/weapon/holder/mouse/gray
			if("white")
				holder_type = /obj/item/weapon/holder/mouse/white
	icon_state = "mouse_[body_color]"
	icon_living = "mouse_[body_color]"
	icon_dead = "mouse_[body_color]_dead"
	icon_move = "mouse_[body_color]_move"
	desc = "It's a small [body_color] rodent, often seen hiding in maintenance areas and making a nuisance of itself."


/mob/living/simple_animal/mouse/proc/splat()
	health = 0
	stat = DEAD
	icon_dead = "mouse_[body_color]_splat"
	icon_state = "mouse_[body_color]_splat"
	layer = MOB_LAYER
	timeofdeath = world.time
	if(client)
		client.time_died_as_mouse = world.time

/mob/living/simple_animal/mouse/MouseDrop(atom/over_object)

	var/mob/living/carbon/H = over_object
	if(!istype(H) || !Adjacent(H) || ismob(H.loc))
		return ..()

	if(H.a_intent == "help")
		get_scooped(H)
		return
	else
		return ..()

/mob/living/simple_animal/mouse/get_scooped(mob/living/carbon/grabber)
	if (stat >= DEAD)
		return
	..()
//copy paste from alien/larva, if that func is updated please update this one alsoghost
/mob/living/simple_animal/mouse/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Mouse"

	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		to_chat(src, text("\blue You are now hiding."))
		/*
		for(var/mob/O in oviewers(src, null))
			if ((O.client && !( O.blinded )))
				to_chat(O, text("<B>[] scurries to the ground!</B>", src))
		*/
	else
		layer = MOB_LAYER
		to_chat(src, text("\blue You have stopped hiding."))
		/*
		for(var/mob/O in oviewers(src, null))
			if ((O.client && !( O.blinded )))
				to_chat(O, text("[] slowly peaks up from the ground...", src))
		*/

//make mice fit under tables etc? this was hacky, and not working
/*
/mob/living/simple_animal/mouse/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)

	var/turf/target_turf = get_step(src,dir)
	//CanReachThrough(src.loc, target_turf, src)
	var/can_fit_under = 0
	if(target_turf.ZCanPass(get_turf(src),1))
		can_fit_under = 1

	. = ..()
	if(can_fit_under)
		src.loc = target_turf
	for(var/d in cardinal)
		var/turf/O = get_step(T,d)
		//Simple pass check.
		if(O.ZCanPass(T, 1) && !(O in open) && !(O in closed) && O in possibles)
			open += O
			*/

///mob/living/simple_animal/mouse/restrained() //Hotfix to stop mice from doing things with MouseDrop
//	return 1

/mob/living/simple_animal/mouse/start_pulling(atom/movable/AM)//Prevents mouse from pulling things
	to_chat(src, "<span class='warning'>You are too small to pull anything.</span>")
	return

/mob/living/simple_animal/mouse/Crossed(AM as mob|obj)
	if( ishuman(AM) )
		if(!stat)
			var/mob/M = AM
			to_chat(M, "\blue [bicon(src)] Squeek!")
			M << 'sound/effects/mousesqueek.ogg'
	..()

/mob/living/simple_animal/mouse/death()
	layer = MOB_LAYER
	if(client)
		client.time_died_as_mouse = world.time
	..()

var/obj/item/held_item = null

/mob/living/simple_animal/mouse/verb/drop_held_item()
	set name = "Drop held item"
	set category = "mouse"
	set desc = "Drop the item you're holding."
	if(strong==1)
		if(stat)
			return

		if(!held_item)
			to_chat(usr, "\red You have nothing to drop!")
			return 0

		if(istype(held_item, /obj/item/weapon/grenade))
			visible_message("\red [src] launches \the [held_item]!", "\red You launch \the [held_item]!", "You hear a skittering noise and a thump!")
			var/obj/item/weapon/grenade/G = held_item
			G.loc = src.loc
			G.prime()
			held_item = null
			return 1

		visible_message("\blue [src] drops \the [held_item]!", "\blue You drop \the [held_item]!", "You hear a skittering noise and a soft thump.")

		held_item.loc = src.loc
		held_item = null
		return 1
	else
		to_chat(usr, "\red You not enough strong")
	return

/mob/living/simple_animal/mouse/verb/get_item()
	set name = "Pick up item"
	set category = "mouse"
	set desc = "Allows you to take a nearby small item."
	if(strong==1)
		if(stat)
			return -1

		if(held_item)
			to_chat(src, "\red You are already holding \the [held_item]")
			return 1

		var/list/items = list()
		for(var/obj/item/I in view(1,src))
			if(I.loc != src && I.w_class <= ITEM_SIZE_SMALL)
				items.Add(I)

		var/obj/selection = input("Select an item.", "Pickup") in items

		if(selection)
			for(var/obj/item/I in view(1, src))
				if(selection == I)
					held_item = selection
					selection.loc = src
					visible_message("\blue [src] scoops up \the [held_item]!", "\blue You grab \the [held_item]!", "You hear a skittering noise and a clink.")
					return held_item
			to_chat(src, "\red \The [selection] is too far away.")
			return 0

		to_chat(src, "\red There is nothing of interest to take.")
		return 0
	else
		to_chat(usr, "\red You not enough strong")


/*
 * Mouse types
 */

/mob/living/simple_animal/mouse/white
	body_color = "white"
	icon_state = "mouse_white"
	holder_type = /obj/item/weapon/holder/mouse/white

/mob/living/simple_animal/mouse/gray
	body_color = "gray"
	icon_state = "mouse_gray"
	holder_type = /obj/item/weapon/holder/mouse/gray

/mob/living/simple_animal/mouse/brown
	body_color = "brown"
	icon_state = "mouse_brown"
	holder_type = /obj/item/weapon/holder/mouse/brown

//TOM IS ALIVE! SQUEEEEEEEE~K :)
/mob/living/simple_animal/mouse/brown/Tom
	name = "Tom"
	desc = "Jerry the cat is not amused."
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "splats"
