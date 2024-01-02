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
	var/turf/location = pick_landmarked_location("Junkyard Bum")
	var/mob/living/carbon/human/bum/host = new /mob/living/carbon/human/bum(location)
	host.ckey = src.ckey
	to_chat(host, "<span class='warning'>You are space bum now. Try to survive. Try to cooperate. Try to be friendly. Only remember: there are no rules!</span>")
	var/area/host_area = get_area(host)
	SEND_SIGNAL(host_area, COMSIG_AREA_ENTERED, host, null)
	host.mind.skills.add_available_skillset(/datum/skillset/jack_of_all_trades)
	host.mind.skills.maximize_active_skills()
	return host
