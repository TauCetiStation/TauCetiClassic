//Cat
/mob/living/simple_animal/cat
	name = "cat"
	desc = "A domesticated, feline pet. Has a tendency to adopt crewmembers."
	icon_state = "cat"
	icon_living = "cat"
	icon_dead = "cat_dead"
	speak = list("Meow!","Esp!","Purr!","HSSSSS")
	speak_emote = list("purrs", "meows")
	emote_hear = list("meows","mews")
	emote_see = list("shakes its head", "shivers")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 2)
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "kicks the"
	var/turns_since_scan = 0
	var/mob/living/simple_animal/mouse/movement_target
	min_oxy = 16 //Require atleast 16kPA oxygen
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius
	holder_type = /obj/item/weapon/holder/cat

	has_head = TRUE
	has_leg = TRUE

	var/obj/item/inventory_mouth

/mob/living/simple_animal/cat/Life()
	//MICE!
	if((src.loc) && isturf(src.loc))
		if(!stat && !resting && !buckled)
			for(var/mob/living/simple_animal/mouse/M in view(1,src))
				if(!M.stat)
					M.splat()
					emote(pick("<span class='warning'>splats the [M]!</span>","<span class='warning'>toys with the [M]</span>","worries the [M]"))
					movement_target = null
					stop_automated_movement = 0
					break

	..()

	for(var/mob/living/simple_animal/mouse/snack in oview(src, 3))
		if(prob(15))
			emote(pick("hisses and spits!","mrowls fiercely!","eyes [snack] hungrily."))
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
				for(var/mob/living/simple_animal/mouse/snack in oview(src,3))
					if(isturf(snack.loc) && !snack.stat)
						movement_target = snack
						break
			if(movement_target)
				stop_automated_movement = 1
				walk_to(src,movement_target,0,3)

/mob/living/simple_animal/cat/death()
	if(inventory_mouth)
		inventory_mouth.loc = src.loc
		inventory_mouth = null
		regenerate_icons()
	return ..()

/mob/living/simple_animal/cat/MouseDrop(atom/over_object)

	var/mob/living/carbon/H = over_object
	if(!istype(H) || !Adjacent(H) || ismob(H.loc))
		return ..()

	//This REALLY needs to be moved to a general mob proc somewhere.
	if(H.a_intent == INTENT_HELP)
		get_scooped(H)
		return
	else
		return ..()

/mob/living/simple_animal/cat/show_inv(mob/user)
	if(user.incapacitated())
		return

	user.set_machine(src)

	var/dat
	if(inventory_mouth)
		dat = "<br><b>Mouth:</b><a href='?src=\ref[src];remove_inv=mouth'>Remove</a>"
	else
		dat = "<br><b>Mouth:</b><a href='?src=\ref[src];add_inv=mouth'>Nothing</a>"

	//dat += "<br><a href='?src=\ref[user];mach_close=mob[type]'>Close</a>"

	var/datum/browser/popup = new(user, "mob[type]", "Inventory of [name]", 325, 500)
	popup.set_content(dat)
	popup.open()

/mob/living/simple_animal/cat/Topic(href, href_list)
	if(usr.incapacitated() || !Adjacent(usr) || !(ishuman(usr) || ismonkey(usr)))
		return

	//Removing from inventory
	if(href_list["remove_inv"])
		if(inventory_mouth)
			inventory_mouth.loc = src.loc
			inventory_mouth = null
			regenerate_icons()
			show_inv(usr)
		else
			return

	else if(href_list["add_inv"])
		var/obj/item/item_to_add = usr.get_active_hand()
		if(!item_to_add || inventory_mouth)
			return
		else if(item_to_add.type == /obj/item/clothing/mask/cigarette)
			usr.drop_item()
			item_to_add.loc = src
			src.inventory_mouth = item_to_add
			regenerate_icons()
			show_inv(usr)
	else
		..()

/mob/living/simple_animal/cat/regenerate_icons()
	cut_overlays()

	if(inventory_mouth)
		add_overlay(image('icons/mob/animal.dmi',inventory_mouth.icon_state))

//RUNTIME IS ALIVE! SQUEEEEEEEE~
/mob/living/simple_animal/cat/Runtime
	name = "Runtime"
	desc = "Its fur has the look and feel of velvet, and its tail quivers occasionally."

/mob/living/simple_animal/cat/Syndi
	name = "SyndiCat"
	desc = "It's a SyndiCat droid."
	icon_state = "Syndicat"
	icon_living = "Syndicat"
	icon_dead = "Syndicat_dead"
	//gender = FEMALE
	flags = list(
	 IS_SYNTHETIC = TRUE
	,NO_BREATHE = TRUE
	)
	faction = list("syndicate")
	//var/turns_since_scan = 0
	//var/mob/living/simple_animal/mouse/movement_target
