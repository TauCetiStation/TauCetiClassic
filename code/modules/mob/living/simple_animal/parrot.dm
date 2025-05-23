/* Parrots!
 * Contains
 * 		Defines
 *		Inventory (headset stuff)
 *		Attack responces
 *		AI
 *		Procs / Verbs (usable by players)
 *		Sub-types
 */

/*
 * Defines
 */

//Only a maximum of one action and one intent should be active at any given time.
//Actions
#define PARROT_PERCH 1		//Sitting/sleeping, not moving
#define PARROT_SWOOP 2		//Moving towards or away from a target
#define PARROT_WANDER 4		//Moving without a specific target in mind

//Intents
#define PARROT_STEAL 8		//Flying towards a target to steal it/from it
#define PARROT_ATTACK 16	//Flying towards a target to attack it
#define PARROT_RETURN 32	//Flying towards its perch
#define PARROT_FLEE 64		//Flying away from its attacker


/mob/living/simple_animal/parrot
	name = "Parrot"
	desc = "Попугай кричит, \"Это Попугай! РАААА!\""
	icon = 'icons/mob/animal.dmi'
	icon_state = "parrot_fly"
	icon_living = "parrot_fly"
	icon_dead = "parrot_dead"
	pass_flags = PASSTABLE
	w_class = SIZE_TINY

	speak = list("Прривет","Здаррова!","Кррекер?","БВААААА! Джамес Морган дрразнит меня!")
	speak_emote = list("кричит","говорит")
	emote_hear = list("кричит","бормочет")
	emote_see = list("машет крыльями")

	speak_chance = 1//1% (1 in 100) chance every tick; So about once per 150 seconds, assuming an average tick is 1.5s
	turns_per_move = 5
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/cracker = 2)

	response_help  = "pets the"
	response_disarm = "gently moves aside the"
	response_harm   = "swats the"
	stop_automated_movement = TRUE
	universal_speak = 1

	has_head = TRUE
	has_leg = TRUE

	var/parrot_state = PARROT_WANDER //Hunt for a perch when created
	var/parrot_sleep_max = 25 //The time the parrot sits while perched before looking around. Mosly a way to avoid the parrot's AI in life() being run every single tick.
	var/parrot_sleep_dur = 25 //Same as above, this is the var that physically counts down
	var/parrot_dam_zone = list(BP_CHEST , BP_HEAD , BP_L_ARM , BP_L_LEG , BP_R_ARM , BP_R_LEG) //For humans, select a bodypart to attack

	var/parrot_speed = 5 //"Delay in world ticks between movement." according to byond. Yeah, that's BS but it does directly affect movement. Higher number = slower.
	var/parrot_been_shot = 0 //Parrots get a speed bonus after being shot. This will deincrement every Life() and at 0 the parrot will return to regular speed.

	var/list/speech_buffer = list()
	var/list/available_channels = list()

	//Headset for Poly to yell at engineers :)
	var/obj/item/device/radio/headset/ears = null

	//The thing the parrot is currently interested in. This gets used for items the parrot wants to pick up, mobs it wants to steal from,
	//mobs it wants to attack or mobs that have attacked it
	var/atom/movable/parrot_interest = null

	//Parrots will generally sit on their pertch unless something catches their eye.
	//These vars store their preffered perch and if they dont have one, what they can use as a perch
	var/obj/parrot_perch = null
	var/obj/desired_perches = list(/obj/structure/computerframe, 		/obj/structure/displaycase, \
									/obj/structure/filingcabinet,		/obj/machinery/teleport, \
									/obj/machinery/computer,			/obj/machinery/clonepod, \
									/obj/machinery/dna_scannernew,		/obj/machinery/telecomms, \
									/obj/machinery/nuclearbomb,			/obj/machinery/particle_accelerator, \
									/obj/machinery/recharge_station,	/obj/machinery/smartfridge, \
									/obj/machinery/suit_storage_unit)

	//Parrots are kleptomaniacs. This variable ... stores the item a parrot is holding.
	var/obj/item/held_item = null


/mob/living/simple_animal/parrot/atom_init()
	. = ..()
	if(!ears)
		var/headset = pick(/obj/item/device/radio/headset/headset_sec, \
						/obj/item/device/radio/headset/headset_eng, \
						/obj/item/device/radio/headset/headset_med, \
						/obj/item/device/radio/headset/headset_sci, \
						/obj/item/device/radio/headset/headset_cargo)
		ears = new headset(src)

	parrot_sleep_dur = parrot_sleep_max //In case someone decides to change the max without changing the duration var

	verbs.Add(/mob/living/simple_animal/parrot/proc/steal_from_ground, \
			  /mob/living/simple_animal/parrot/proc/steal_from_mob, \
			  /mob/living/simple_animal/parrot/verb/drop_held_item_player, \
			  /mob/living/simple_animal/parrot/proc/perch_player)

	ADD_TRAIT(src, TRAIT_ARIBORN, TRAIT_ARIBORN_FLYING)

/mob/living/simple_animal/parrot/death()
	if(held_item)
		held_item.loc = src.loc
		held_item = null
	walk(src,0)
	..()

/mob/living/simple_animal/parrot/Stat()
	..()
	if(statpanel("Status"))
		stat("Held Item", held_item)

/*
 * Inventory
 */
/mob/living/simple_animal/parrot/show_inv(mob/user)
	user.set_machine(src)
	if(user.incapacitated()) return

	var/dat = ""
	if(ears)
		dat +=	"<br><b>Headset:</b> [ears] (<a href='byond://?src=\ref[src];remove_inv=ears'>Remove</a>)"
	else
		dat +=	"<br><b>Headset:</b> <a href='byond://?src=\ref[src];add_inv=ears'>Nothing</a>"

	var/datum/browser/popup = new(user, "mob[real_name]", "Inventory of [name]", 325, 500)
	popup.set_content(dat)
	popup.open()
	return

/mob/living/simple_animal/parrot/Topic(href, href_list)

	//Can the usr physically do this?
	if(usr.incapacitated() || !Adjacent(usr))
		return

	//Is the usr's mob type able to do this? (lolaliens)
	if(ishuman(usr) || ismonkey(usr) || isrobot(usr) ||  isxenoadult(usr))

		//Removing from inventory
		if(href_list["remove_inv"])
			var/remove_from = href_list["remove_inv"]
			switch(remove_from)
				if("ears")
					if(ears)
						if(available_channels.len)
							say("[pick(available_channels)] БВААААА! ОСТАВЬ НАУШНИК! БВААААА!")
						else
							say("БВААААА! ОСТАВЬ НАУШНИК! БВААААА!")
						ears.loc = src.loc
						ears = null
						for(var/possible_phrase in speak)
							if(copytext(possible_phrase,1,2 + length(possible_phrase[2])) in department_radio_keys)
								possible_phrase = copytext(possible_phrase, 2 + length(possible_phrase[2]),-1)
					else
						to_chat(usr, "<span class='warning'>There is nothing to remove from its [remove_from].</span>")
						return

		//Adding things to inventory
		else if(href_list["add_inv"])
			var/add_to = href_list["add_inv"]
			if(!usr.get_active_hand())
				to_chat(usr, "<span class='warning'>You have nothing in your hand to put on its [add_to].</span>")
				return
			switch(add_to)
				if("ears")
					if(ears)
						to_chat(usr, "<span class='warning'>It's already wearing something.</span>")
						return
					else
						var/obj/item/item_to_add = usr.get_active_hand()
						if(!item_to_add)
							return

						if( !istype(item_to_add,  /obj/item/device/radio/headset) )
							to_chat(usr, "<span class='warning'>This object won't fit.</span>")
							return

						var/obj/item/device/radio/headset/headset_to_add = item_to_add

						usr.drop_from_inventory(headset_to_add, src)
						src.ears = headset_to_add
						to_chat(usr, "You fit the headset onto [src].")

						clearlist(available_channels)
						for(var/ch in headset_to_add.channels)
							switch(ch)
								if("Engineering")
									available_channels.Add(":e")
								if("Command")
									available_channels.Add(":c")
								if("Security")
									available_channels.Add(":s")
								if("Science")
									available_channels.Add(":n")
								if("Medical")
									available_channels.Add(":m")
								if("Mining")
									available_channels.Add(":d")
								if("Cargo")
									available_channels.Add(":q")

						if(headset_to_add.translate_binary)
							available_channels.Add(":b")
		else
			..()


/*
 * Attack responces
 */
/mob/living/simple_animal/parrot/hurtReaction(mob/living/carbon/human/attacker, show_message = TRUE)
	. = ..()
	if(client)
		return
	if(stat == CONSCIOUS)
		icon_state = "parrot_fly" //It is going to be flying regardless of whether it flees or attacks

		if(parrot_state == PARROT_PERCH)
			parrot_sleep_dur = parrot_sleep_max //Reset it's sleep timer if it was perched

		parrot_interest = attacker
		parrot_state = PARROT_SWOOP //The parrot just got hit, it WILL move, now to pick a direction..

		if(attacker.health < 50) //Weakened mob? Fight back!
			parrot_state |= PARROT_ATTACK
		else
			parrot_state |= PARROT_FLEE		//Otherwise, fly like a bat out of hell!
			drop_held_item(0)

//Mobs with objects
/mob/living/simple_animal/parrot/attackby(obj/item/O, mob/user)
	..()
	if(stat == CONSCIOUS && !client && !istype(O, /obj/item/stack/medical))
		if(O.force)
			if(parrot_state == PARROT_PERCH)
				parrot_sleep_dur = parrot_sleep_max //Reset it's sleep timer if it was perched

			parrot_interest = user
			parrot_state = PARROT_SWOOP | PARROT_FLEE
			icon_state = "parrot_fly"
			drop_held_item(0)
	return

//Bullets
/mob/living/simple_animal/parrot/bullet_act(obj/item/projectile/Proj, def_zone)
	. = ..()
	if(. == PROJECTILE_ABSORBED || . == PROJECTILE_FORCE_MISS)
		return
	if(stat == CONSCIOUS && !client)
		if(parrot_state == PARROT_PERCH)
			parrot_sleep_dur = parrot_sleep_max //Reset it's sleep timer if it was perched

		parrot_interest = null
		parrot_state = PARROT_WANDER //OWFUCK, Been shot! RUN LIKE HELL!
		parrot_been_shot += 5
		icon_state = "parrot_fly"
		drop_held_item(0)

/*
 * AI - Not really intelligent, but I'm calling it AI anyway.
 */
/mob/living/simple_animal/parrot/Life()
	..()

	//Sprite and AI update for when a parrot gets pulled
	if(pulledby && stat == CONSCIOUS)
		icon_state = "parrot_fly"
		if(!client)
			parrot_state = PARROT_WANDER
		return

	if(client || stat != CONSCIOUS)
		return //Lets not force players or dead/incap parrots to move

	if(!isturf(src.loc) || !canmove)
		return //If it can't move, dont let it move.


//-----SPEECH
	/* Parrot speech mimickry!
	   Phrases that the parrot hears in mob/living/say() get added to speach_buffer.
	   Every once in a while, the parrot picks one of the lines from the buffer and replaces an element of the 'speech' list.
	   Then it clears the buffer to make sure they dont magically remember something from hours ago. */
	if(speech_buffer.len && prob(10))
		if(speak.len)
			speak.Remove(pick(speak))

		speak.Add(pick(speech_buffer))
		clearlist(speech_buffer)


//-----SLEEPING
	if(parrot_state == PARROT_PERCH)
		if(parrot_perch && parrot_perch.loc != src.loc) //Make sure someone hasnt moved our perch on us
			if(parrot_perch in view(src))
				parrot_state = PARROT_SWOOP | PARROT_RETURN
				icon_state = "parrot_fly"
				return
			else
				parrot_state = PARROT_WANDER
				icon_state = "parrot_fly"
				return

		if(--parrot_sleep_dur) //Zzz
			return

		else
			//This way we only call the stuff below once every [sleep_max] ticks.
			parrot_sleep_dur = parrot_sleep_max

			//Cycle through message modes for the headset
			if(speak.len)
				var/list/newspeak = list()

				if(available_channels.len && src.ears)
					for(var/possible_phrase in speak)

						//50/50 chance to not use the radio at all
						var/useradio = 0
						if(prob(50))
							useradio = 1

						if(copytext(possible_phrase,1, 2 + length(possible_phrase[2])) in department_radio_keys)
							possible_phrase = "[useradio?pick(available_channels):""] [copytext(possible_phrase,2 + length(possible_phrase[2]))]" //crop out the channel prefix
						else
							possible_phrase = "[useradio?pick(available_channels):""] [possible_phrase]"

						newspeak.Add(possible_phrase)

				else //If we have no headset or channels to use, dont try to use any!
					for(var/possible_phrase in speak)
						if(copytext(possible_phrase,1, 2 + length(possible_phrase[2])) in department_radio_keys)
							possible_phrase = "[copytext(possible_phrase,2 + length(possible_phrase[2]))]" //crop out the channel prefix
						newspeak.Add(possible_phrase)
				speak = newspeak

			//Search for item to steal
			parrot_interest = search_for_item()
			if(parrot_interest)
				me_emote("looks in [parrot_interest]'s direction and takes flight")
				parrot_state = PARROT_SWOOP | PARROT_STEAL
				icon_state = "parrot_fly"
			return

//-----WANDERING - This is basically a 'I dont know what to do yet' state
	else if(parrot_state == PARROT_WANDER)
		//Stop movement, we'll set it later
		walk(src, 0)
		parrot_interest = null

		//Wander around aimlessly. This will help keep the loops from searches down
		//and possibly move the mob into a new are in view of something they can use
		if(prob(90))
			step(src, pick(cardinal))
			return

		if(!held_item && !parrot_perch) //If we've got nothing to do.. look for something to do.
			var/atom/movable/AM = search_for_perch_and_item() //This handles checking through lists so we know it's either a perch or stealable item
			if(AM)
				if(isitem(AM) || isliving(AM))	//If stealable item
					parrot_interest = AM
					me_emote("turns and flies towards [parrot_interest]")
					parrot_state = PARROT_SWOOP | PARROT_STEAL
					return
				else	//Else it's a perch
					parrot_perch = AM
					parrot_state = PARROT_SWOOP | PARROT_RETURN
					return
			return

		if(parrot_interest && (parrot_interest in view(src)))
			parrot_state = PARROT_SWOOP | PARROT_STEAL
			return

		if(parrot_perch && (parrot_perch in view(src)))
			parrot_state = PARROT_SWOOP | PARROT_RETURN
			return

		else //Have an item but no perch? Find one!
			parrot_perch = search_for_perch()
			if(parrot_perch)
				parrot_state = PARROT_SWOOP | PARROT_RETURN
				return
//-----STEALING
	else if(parrot_state == (PARROT_SWOOP | PARROT_STEAL))
		walk(src,0)
		if(!parrot_interest || held_item)
			parrot_state = PARROT_SWOOP | PARROT_RETURN
			return

		if(!(parrot_interest in view(src)))
			parrot_state = PARROT_SWOOP | PARROT_RETURN
			return

		if(in_range(src, parrot_interest))	// ! changing this to Adjacent() will probably break it
											// ! and i'm not going to invent new alg for this
			if(isliving(parrot_interest))
				steal_from_mob()

			else //This should ensure that we only grab the item we want, and make sure it's not already collected on our perch
				if(!parrot_perch || parrot_interest.loc != parrot_perch.loc)
					held_item = parrot_interest
					parrot_interest.loc = src
					visible_message("[src] grabs the [held_item]!", "<span class='notice'>You grab the [held_item]!</span>", "You hear the sounds of wings flapping furiously.")

			parrot_interest = null
			parrot_state = PARROT_SWOOP | PARROT_RETURN
			return

		walk_to(src, parrot_interest, 1, parrot_speed)
		return

//-----RETURNING TO PERCH
	else if(parrot_state == (PARROT_SWOOP | PARROT_RETURN))
		walk(src, 0)
		if(!parrot_perch || !isturf(parrot_perch.loc)) //Make sure the perch exists and somehow isnt inside of something else.
			parrot_perch = null
			parrot_state = PARROT_WANDER
			return

		if(in_range(src, parrot_perch))	// ! changing this to Adjacent() will probably break it
										// ! and i'm not going to invent new alg for this
			src.loc = parrot_perch.loc
			drop_held_item()
			parrot_state = PARROT_PERCH
			icon_state = "parrot_sit"
			return

		walk_to(src, parrot_perch, 1, parrot_speed)
		return

//-----FLEEING
	else if(parrot_state == (PARROT_SWOOP | PARROT_FLEE))
		walk(src,0)
		if(!parrot_interest || !isliving(parrot_interest)) //Sanity
			parrot_state = PARROT_WANDER

		walk_away(src, parrot_interest, 1, parrot_speed-parrot_been_shot)
		parrot_been_shot--
		return

//-----ATTACKING
	else if(parrot_state == (PARROT_SWOOP | PARROT_ATTACK))

		//If we're attacking a nothing, an object, a turf or a ghost for some stupid reason, switch to wander
		if(!parrot_interest || !isliving(parrot_interest))
			parrot_interest = null
			parrot_state = PARROT_WANDER
			return

		var/mob/living/L = parrot_interest

		//If the mob is close enough to interact with
		if(in_range(src, parrot_interest))	// ! changing this to Adjacent() will probably break it
											// ! and i'm not going to invent new alg for this
			//If the mob we've been chasing/attacking dies or falls into crit, check for loot!
			if(L.stat != CONSCIOUS)
				parrot_interest = null
				if(!held_item)
					held_item = steal_from_ground()
					if(!held_item)
						held_item = steal_from_mob() //Apparently it's possible for dead mobs to hang onto items in certain circumstances.
				if(parrot_perch in view(src)) //If we have a home nearby, go to it, otherwise find a new home
					parrot_state = PARROT_SWOOP | PARROT_RETURN
				else
					parrot_state = PARROT_WANDER
				return

			//Time for the hurt to begin!
			var/damage = rand(5,10)

			if(ishuman(parrot_interest))
				var/mob/living/carbon/human/H = parrot_interest
				var/obj/item/organ/external/BP = H.bodyparts_by_name[ran_zone(pick(parrot_dam_zone))]

				H.apply_damage(damage, BRUTE, BP, H.run_armor_check(BP, MELEE), DAM_SHARP)
				me_emote(pick("pecks [H]'s [BP.name]", "cuts [H]'s [BP.name] with its talons"))

			else
				L.adjustBruteLoss(damage)
				me_emote(pick("pecks at [L]", "claws [L]"))
			return

		//Otherwise, fly towards the mob!
		else
			walk_to(src, parrot_interest, 1, parrot_speed)
		return
//-----STATE MISHAP
	else //This should not happen. If it does lets reset everything and try again
		walk(src,0)
		parrot_interest = null
		parrot_perch = null
		drop_held_item()
		parrot_state = PARROT_WANDER
		return

/*
 * Procs
 */

/mob/living/simple_animal/parrot/movement_delay()
	if(client && stat == CONSCIOUS && parrot_state != "parrot_fly")
		icon_state = "parrot_fly"
	..()

/mob/living/simple_animal/parrot/proc/search_for_item()
	for(var/atom/movable/AM in view(src))
		//Skip items we already stole or are wearing or are too big
		if(parrot_perch && AM.loc == parrot_perch.loc || AM.loc == src)
			continue

		if(isitem(AM))
			var/obj/item/I = AM
			if(I.w_class < SIZE_TINY)
				return I

		if(iscarbon(AM))
			var/mob/living/carbon/C = AM
			if((C.l_hand && C.l_hand.w_class <= SIZE_TINY) || (C.r_hand && C.r_hand.w_class <= SIZE_TINY))
				return C
	return null

/mob/living/simple_animal/parrot/proc/search_for_perch()
	for(var/obj/O in view(src))
		for(var/path in desired_perches)
			if(istype(O, path))
				return O
	return null

//This proc was made to save on doing two 'in view' loops seperatly
/mob/living/simple_animal/parrot/proc/search_for_perch_and_item()
	for(var/atom/movable/AM in view(src))
		for(var/perch_path in desired_perches)
			if(istype(AM, perch_path))
				return AM

		//Skip items we already stole or are wearing or are too big
		if(parrot_perch && AM.loc == parrot_perch.loc || AM.loc == src)
			continue

		if(isitem(AM))
			var/obj/item/I = AM
			if(I.w_class <= SIZE_TINY)
				return I

		if(iscarbon(AM))
			var/mob/living/carbon/C = AM
			if(C.l_hand && C.l_hand.w_class <= SIZE_TINY || C.r_hand && C.r_hand.w_class <= SIZE_TINY)
				return C
	return null


/*
 * Verbs - These are actually procs, but can be used as verbs by player-controlled parrots.
 */
/mob/living/simple_animal/parrot/proc/steal_from_ground()
	set name = "Steal from ground"
	set category = "Parrot"
	set desc = "Grabs a nearby item."

	if(incapacitated())
		return -1

	if(held_item)
		to_chat(src, "<span class='warning'>You are already holding the [held_item]</span>")
		return 1

	for(var/obj/item/I in view(1,src))
		//Make sure we're not already holding it and it's small enough
		if(I.loc != src && I.w_class <= SIZE_TINY)

			//If we have a perch and the item is sitting on it, continue
			if(!client && parrot_perch && I.loc == parrot_perch.loc)
				continue

			held_item = I
			I.loc = src
			visible_message("[src] grabs the [held_item]!", "<span class='notice'>You grab the [held_item]!</span>", "You hear the sounds of wings flapping furiously.")
			return held_item

	to_chat(src, "<span class='warning'>There is nothing of interest to take.</span>")
	return 0

/mob/living/simple_animal/parrot/proc/steal_from_mob()
	set name = "Steal from mob"
	set category = "Parrot"
	set desc = "Steals an item right out of a person's hand!"

	if(incapacitated())
		return -1

	if(held_item)
		to_chat(src, "<span class='warning'>You are already holding the [held_item]</span>")
		return 1

	var/obj/item/stolen_item = null

	for(var/mob/living/carbon/C in view(1,src))
		if(C.l_hand && C.l_hand.w_class <= SIZE_TINY)
			stolen_item = C.l_hand

		if(C.r_hand && C.r_hand.w_class <= SIZE_TINY)
			stolen_item = C.r_hand

		if(stolen_item)
			C.remove_from_mob(stolen_item)
			held_item = stolen_item
			stolen_item.loc = src
			visible_message("[src] grabs the [held_item] out of [C]'s hand!", "<span class='notice'>You snag the [held_item] out of [C]'s hand!</span>", "You hear the sounds of wings flapping furiously.")
			return held_item

	to_chat(src, "<span class='warning'>There is nothing of interest to take.</span>")
	return 0

/mob/living/simple_animal/parrot/verb/drop_held_item_player()
	set name = "Drop held item"
	set category = "Parrot"
	set desc = "Drop the item you're holding."

	if(incapacitated())
		return

	drop_held_item()

	return

/mob/living/simple_animal/parrot/proc/drop_held_item(drop_gently = 1)
	set name = "Drop held item"
	set category = "Parrot"
	set desc = "Drop the item you're holding."

	if(incapacitated())
		return -1

	if(!held_item)
		to_chat(usr, "<span class='warning'>You have nothing to drop!</span>")
		return 0

	if(!drop_gently)
		if(istype(held_item, /obj/item/weapon/grenade))
			var/obj/item/weapon/grenade/G = held_item
			G.loc = src.loc
			G.prime()
			to_chat(src, "You let go of the [held_item]!")
			held_item = null
			return 1

	to_chat(src, "You drop the [held_item].")

	held_item.loc = src.loc
	held_item = null
	return 1

/mob/living/simple_animal/parrot/proc/perch_player()
	set name = "Sit"
	set category = "Parrot"
	set desc = "Sit on a nice comfy perch."

	if(incapacitated() || !client)
		return

	if(icon_state == "parrot_fly")
		for(var/atom/movable/AM in view(src,1))
			for(var/perch_path in desired_perches)
				if(istype(AM, perch_path))
					src.loc = AM.loc
					icon_state = "parrot_sit"
					return
	to_chat(src, "<span class='warning'>There is no perch nearby to sit on.</span>")
	return

/*
 * Sub-types
 */
ADD_TO_GLOBAL_LIST(/mob/living/simple_animal/parrot/Poly, chief_animal_list)
/mob/living/simple_animal/parrot/Poly
	name = "Poly"
	desc = "Попугай Поли. Эксперт по теории квантовых разломов."
	speak = list(
		":e Поли хочет кррекер!",
		":e Прроверьте сингулярность, лоботррясы!",
		":e Подключайте солнечные панели, ленивые даррмоеды!",
		":e КТО ВЗЯЛ ГРРЁБАНЫЕ РРИГИ?",
		":e О БОЖЕ, ОНА СБЕЖАЛА! ВЫЗЫВАЙТЕ ШАТТЛ!",
		":e Шеф, вы свой диплом купили или где-то нашли?",
		":e Нет, черртежи я не прродам.",
		":e Закажите ящик с перрчатками.",
		":e Я ЖЕ ГОВОРРИЛ, НЕ ТРРОГАЙТЕ СУПЕРРМАТЕРИЮ РРУКАМИ!",
		":e Да не нужны СМЕСЫ, мы напррямую подключим.",
		":e Я много рраз так делал, все норрмально будет.",
		":e Вы еще шалаш пострройте вокрруг бухломата.",
		":e Мы - инженерр.",
	)
	speak_chance = 3
	var/memory_saved = 0
	var/rounds_survived = 0
	var/longest_survival = 0
	var/longest_deathstreak = 0

/mob/living/simple_animal/parrot/Poly/atom_init()
	ears = new /obj/item/device/radio/headset/headset_eng(src)
	available_channels = list(":e")
	Read_Memory()
	if(rounds_survived == longest_survival)
		speak += pick("...[longest_survival].", "Чего я только не видал!", "Я прожил так много жизней!", "Что ты предо мной?")
		desc += " Старый как грех, и такой же громкий. Утверждал, что пережил [rounds_survived] [pluralize_russian(rounds_survived, "смену", "смены", "смен")]."
		speak_chance = 20 //His hubris has made him more annoying/easier to justify killing
		color = "#eeee22"
	else if(rounds_survived == longest_deathstreak)
		speak += pick("Чего же ты ждёшь!?", "Насилие поррождает насилие!", "Крровь! Кровь!", "Убей меня, если посмеешь!")
		desc += " В ушах звенят крики [-rounds_survived] [pluralize_russian(-rounds_survived, "мертвого попугая", "мертвых попугаев", "мертвых попугаев")]..."
		color = "#bb7777"
	else if(rounds_survived > 0)
		speak += pick("...снова?", "Нет, всё было кончено!", "Выпустите меня!", "Это никогда не закончится!")
		desc += " Он провел [rounds_survived] [pluralize_russian(rounds_survived, "смену", "смены", "смен")] без \"ужасных\" \"инцидентов\"!"
	else
		speak += pick("...я жив?", "Это не птичий ррай!", "Я живу, умирраю, и снова живу!", "Пустота исчезает!")
	. = ..()

/mob/living/simple_animal/parrot/Poly/Life()
	if(stat == CONSCIOUS && SSticker.current_state == GAME_STATE_FINISHED && !memory_saved)
		rounds_survived = max(++rounds_survived,1)
		if(rounds_survived > longest_survival)
			longest_survival = rounds_survived
		Write_Memory()
	..()

/mob/living/simple_animal/parrot/Poly/death(gibbed)
	if(!memory_saved)
		var/go_ghost = 0
		if(rounds_survived == longest_survival || rounds_survived == longest_deathstreak)
			go_ghost = 1
		rounds_survived = min(--rounds_survived,0)
		if(rounds_survived < longest_deathstreak)
			longest_deathstreak = rounds_survived
		Write_Memory()
		if(go_ghost)
			var/mob/living/simple_animal/parrot/Poly/ghost/G = new(loc)
			if(mind)
				mind.transfer_to(G)
			else
				G.key = key
	..(gibbed)

/mob/living/simple_animal/parrot/Poly/proc/Read_Memory()
	var/savefile/S = new /savefile("data/npc_saves/Poly.sav")
	S["phrases"] 			>> speech_buffer
	S["roundssurvived"]		>> rounds_survived
	S["longestsurvival"]	>> longest_survival
	S["longestdeathstreak"] >> longest_deathstreak

	if(isnull(speech_buffer))
		speech_buffer = list()
	else
		if(speech_buffer.len)
			speak += pick(speech_buffer)

/mob/living/simple_animal/parrot/Poly/proc/Write_Memory()
	var/savefile/S = new /savefile("data/npc_saves/Poly.sav")
	if(length(speech_buffer))
		for(var/text in speech_buffer)
			if(!istext(text))
				speech_buffer = null // omg we somehow corrupted

	S["phrases"] 			<< speech_buffer
	if(isnum(rounds_survived))
		S["roundssurvived"]		<< rounds_survived
	if(isnum(longest_survival))
		S["longestsurvival"]	<< longest_survival
	if(isnum(longest_deathstreak))
		S["longestdeathstreak"] << longest_deathstreak
	memory_saved = 1

/mob/living/simple_animal/parrot/Poly/ghost
	name = "The Ghost of Poly"
	desc = "Обреченный бродить по Земле."
	color = "#FFFFFF77"
	speak_chance = 20
	incorporeal_move = 1
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/ectoplasm = 1)

/mob/living/simple_animal/parrot/Poly/ghost/atom_init()
	memory_saved = 1 //At this point nothing is saved
	. = ..()
	ADD_TRAIT(src, ELEMENT_TRAIT_GODMODE, INNATE_TRAIT)

/mob/living/simple_animal/parrot/say(message)

	if(stat || !message)
		return

	var/verb = "says"
	if(speak_emote.len)
		verb = pick(speak_emote)


	var/message_mode=""
	if(message[1] == ";")
		message_mode = "headset"
		message = copytext(message,2)

	if(length(message) >= 2)
		var/channel_prefix = copytext(message, 1 ,2 + length(message[2]))
		message_mode = department_radio_keys[channel_prefix]

	if(message[1] == ":")
		var/positioncut = 2 + length(message[2])
		message = trim(copytext(message,positioncut))

	message = capitalize(trim_left(message))

	if(message_mode)
		if(message_mode in radiochannels)
			if(ears && istype(ears,/obj/item/device/radio))
				ears.talk_into(src,message, message_mode, verb, null)


	..(message)


/mob/living/simple_animal/parrot/hear_say(message, verb = "says", datum/language/language = null, alt_name = "",italics = 0, mob/speaker = null)
	if(speaker != src)
		parrot_hear(message)
	..(message,verb,language,alt_name,italics,speaker)



/mob/living/simple_animal/parrot/hear_radio(message, verb="says", datum/language/language=null, part_a, part_b, part_c, mob/speaker = null, hard_to_hear = 0, vname ="")
	if(speaker != src && length(available_channels) > 0)
		parrot_hear("[pick(available_channels)] [message]")
	..()


/mob/living/simple_animal/parrot/proc/parrot_hear(message="")
	if(!message || stat != CONSCIOUS)
		return
	speech_buffer.Add(message)
