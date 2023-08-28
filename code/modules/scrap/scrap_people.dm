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
	if(prob(80))
		var/random_type = PATH_OR_RANDOM_PATH(/obj/random/cloth/under)
		var/atom/random_item = new random_type
		equip_to_slot_or_del(random_item, SLOT_W_UNIFORM)
	if(prob(60))
		var/random_type = PATH_OR_RANDOM_PATH(/obj/random/cloth/shoes)
		var/atom/random_item = new random_type
		equip_to_slot_or_del(random_item, SLOT_SHOES)
	if(prob(30))
		var/random_type = PATH_OR_RANDOM_PATH(/obj/random/cloth/backpack)
		var/atom/random_item = new random_type
		equip_to_slot_or_del(random_item, SLOT_BACK)
	if(prob(80))
		var/random_type = PATH_OR_RANDOM_PATH(/obj/random/cloth/gloves)
		var/atom/random_item = new random_type
		equip_to_slot_or_del(random_item, SLOT_GLOVES)
	if(prob(30))
		var/random_type = PATH_OR_RANDOM_PATH(/obj/random/cloth/randomsuit)
		var/atom/random_item = new random_type
		equip_to_slot_or_del(random_item, SLOT_WEAR_SUIT)
	if(prob(80))
		var/random_type = PATH_OR_RANDOM_PATH(/obj/random/misc/lightsource)
		var/atom/random_item = new random_type
		equip_to_slot_or_del(random_item, SLOT_R_HAND)
	if(prob(25))
		var/random_type = PATH_OR_RANDOM_PATH(/obj/random/cloth/randomhead)
		var/atom/random_item = new random_type
		equip_to_slot_or_del(random_item, SLOT_HEAD)
	equip_to_slot_or_del(new /obj/item/weapon/shovel(src), SLOT_L_HAND)
	for(var/obj/item/loot in contents)
		loot.make_old()
	randomize_human(src)
	sight |= SEE_BLACKNESS

/mob/proc/make_bum()
	var/obj/effect/landmark/location = pick(junkyard_bum_list)
	var/mob/living/carbon/human/bum/host = new /mob/living/carbon/human/bum(location.loc)
	host.ckey = src.ckey
	to_chat(host, "<span class='warning'>You are space bum now. Try to survive. Try to cooperate. Try to be friendly. Only remember: there are no rules!</span>")
	return host
