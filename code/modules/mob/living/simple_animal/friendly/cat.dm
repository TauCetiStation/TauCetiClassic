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
					stop_automated_movement = FALSE
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
				stop_automated_movement = FALSE
			if( !movement_target || !(movement_target.loc in oview(src, 3)) )
				movement_target = null
				stop_automated_movement = FALSE
				for(var/mob/living/simple_animal/mouse/snack in oview(src,3))
					if(isturf(snack.loc) && !snack.stat)
						movement_target = snack
						break
			if(movement_target)
				stop_automated_movement = TRUE
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
			usr.drop_from_inventory(item_to_add, src)
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

/mob/living/simple_animal/cat/Runtime/atom_init()
	. = ..()
	chief_animal_list += src

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


// Real runtime cat

var/global/cat_number = 0

/mob/living/simple_animal/cat/real_runtime
	name = "Dusty"
	desc = "Мурлыкающая жертва экспериментов. Пробирается в наше измерение, когда сама вуаль реальности разрывается на части."
	icon_state = "runtimecat"
	density = FALSE
	universal_speak = TRUE
	can_be_pulled = FALSE

	a_intent = INTENT_HARM

	status_flags = GODMODE // Bluespace cat
	min_oxy = 0
	minbodytemp = 0
	maxbodytemp = INFINITY

	harm_intent_damage = 10
	melee_damage = 10
	attacktext = "slashed"
	attack_sound = 'sound/weapons/bladeslice.ogg'

	var/const/cat_life_duration = 1 MINUTES

/mob/living/simple_animal/cat/real_runtime/atom_init(mapload, runtime_line)
	. = ..()
	cat_number += 1
	playsound(loc, 'sound/magic/Teleport_diss.ogg', VOL_EFFECTS_MASTER, 50)
	new /obj/effect/temp_visual/pulse(loc)
	new /obj/effect/temp_visual/sparkles(loc)

	addtimer(CALLBACK(src, .proc/back_to_bluespace), cat_life_duration)
	addtimer(CALLBACK(src, .proc/say_runtime, runtime_line), 5 SECONDS)

	for(var/i in rand(1, 3))
		step(src, pick(global.alldirs))

/mob/living/simple_animal/cat/real_runtime/Destroy()
	cat_number -= 1

	playsound(loc, 'sound/magic/Teleport_diss.ogg', VOL_EFFECTS_MASTER, 50)
	new /obj/effect/temp_visual/pulse(loc)
	new /obj/effect/temp_visual/sparkles(loc)
	return ..()

/mob/living/simple_animal/cat/real_runtime/attackby(obj/item/O, mob/living/user)
	. = ..()
	if(.)
		visible_message("<span class='danger'>[user]'s [O.name] harmlessly passes through \the [src].</span>")
		strike_back(user)

// It's easier to do this than to climb into a combos
/mob/living/simple_animal/cat/real_runtime/attack_hand(mob/living/carbon/human/M)
	switch(M.a_intent)

		if(INTENT_HELP)
			M.visible_message("<span class='notice'>[M] pets \the [src].</span>")

		if(INTENT_PUSH)
			M.visible_message("<span class='notice'>[M]'s hand passes through \the [src].</span>")
			M.do_attack_animation(src)

		if(INTENT_GRAB)
			if(M == src)
				return
			if(!(status_flags & CANPUSH))
				return

			M.visible_message("<span class='notice'>[M]'s hand passes through \the [src].</span>")
			M.do_attack_animation(src)

		if(INTENT_HARM)
			M.visible_message("<span class='warning'>[M] tries to kick \the [src] but [M.gender == FEMALE ? "her" : "his"] foot passes through.</span>")
			M.do_attack_animation(src)
			visible_message("<span class='warning'>\The [src] hisses.</span>")
			strike_back(M)

/mob/living/simple_animal/cat/real_runtime/proc/say_runtime(runtime_line)
	if(!runtime_line)
		return
	var/text = "Зафиксирована аномалия #[runtime_line]. Пожалуйста, отойдите подальше."
	say(text)

/mob/living/simple_animal/cat/real_runtime/proc/back_to_bluespace()
	qdel(src)

/mob/living/simple_animal/cat/real_runtime/proc/strike_back(mob/living/target_mob)
	if(!Adjacent(target_mob))
		return
	target_mob.attack_unarmed(src)

/mob/living/simple_animal/cat/real_runtime/bullet_act(obj/item/projectile/proj)
	return PROJECTILE_FORCE_MISS

/mob/living/simple_animal/cat/real_runtime/ex_act(severity)
	return

/mob/living/simple_animal/cat/real_runtime/singularity_act()
	return

/mob/living/simple_animal/cat/real_runtime/MouseDrop(atom/over_object)
	return
