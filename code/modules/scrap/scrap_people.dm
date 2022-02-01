var/global/list/junkyard_bum_list = list()     //list of all bums placements

/obj/effect/landmark/junkyard_bum/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD // i guess we wan't to allow join anyone only after everything setups, in case junkyard working thru map loader.

/obj/effect/landmark/junkyard_bum/atom_init_late()
	junkyard_bum_list += src

/obj/effect/landmark/junkyard_bum/Destroy()
	junkyard_bum_list -= src
	return ..()

/mob/living/carbon/human/bum/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD // because of qdel(CATCH) - we are not allowed to qdel anyone else inside atom_init

/mob/living/carbon/human/bum/atom_init_late()
	..() // in case someone implements something for parent inside late init, that i'm pretty sure will require calling parent.
	generate_random_bum()

/mob/living/carbon/human/proc/generate_random_bum()
	var/obj/randomcatcher/CATCH = new /obj/randomcatcher(src)
	if(prob(80))
		equip_to_slot_or_del(CATCH.get_item(/obj/random/cloth/under), SLOT_W_UNIFORM)
	if(prob(60))
		equip_to_slot_or_del(CATCH.get_item(/obj/random/cloth/shoes), SLOT_SHOES)
	if(prob(30))
		equip_to_slot_or_del(CATCH.get_item(/obj/random/cloth/backpack), SLOT_BACK)
	if(prob(80))
		equip_to_slot_or_del(CATCH.get_item(/obj/random/cloth/gloves), SLOT_GLOVES)
	if(prob(30))
		equip_to_slot_or_del(CATCH.get_item(/obj/random/cloth/randomsuit), SLOT_WEAR_SUIT)
	if(prob(80))
		equip_to_slot_or_del(CATCH.get_item(/obj/random/misc/lightsource), SLOT_R_HAND)
	if(prob(25))
		equip_to_slot_or_del(CATCH.get_item(/obj/random/cloth/randomhead), SLOT_HEAD)
	equip_to_slot_or_del(new /obj/item/weapon/shovel(src), SLOT_L_HAND)
	for(var/obj/item/loot in contents)
		loot.make_old()
	qdel(CATCH)
	gender = pick(MALE, FEMALE)
	if(gender == MALE)
		name = pick(first_names_male)
	else
		name = pick(first_names_female)
	name += " [pick(last_names)]"
	real_name = name
	var/datum/preferences/A = new()	//Randomize appearance for the human
	A.randomize_appearance_for(src)
	sight |= SEE_BLACKNESS
	update_inv_head()
	update_inv_wear_suit()
	update_inv_gloves()
	update_inv_shoes()
	update_inv_w_uniform()
	update_inv_r_hand()
	update_inv_l_hand()

/mob/proc/make_bum()
	var/obj/effect/landmark/location = pick(junkyard_bum_list)
	var/mob/living/carbon/human/bum/host = new /mob/living/carbon/human/bum(location.loc)
	host.ckey = src.ckey
	to_chat(host, "<span class='warning'>You are space bum now. Try to survive. Try to cooperate. Try to be friendly. Only remember: there are no rules!</span>")
	return host
