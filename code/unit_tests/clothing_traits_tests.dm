/datum/unit_test/clothing_traits_noslip_sources
	name = "CLOTHING TRAITS: noslip sources follow equipped clothing"

/datum/unit_test/clothing_traits_noslip_sources/start_test()
	var/turf/T = locate(1, 1, 1)
	var/mob/living/carbon/human/H = new(T)
	var/obj/item/clothing/shoes/shoes = new(H)
	H.equip_to_slot_or_del(shoes, SLOT_SHOES)
	if(HAS_TRAIT(H, TRAIT_NOSLIP))
		qdel(H)
		fail("Plain shoes granted noslip before soles were attached")
		return TRUE

	var/obj/item/noslip_sole/sole = new(H)
	H.put_in_hands(sole)
	shoes.attackby(sole, H)
	if(sole.loc != shoes || !HAS_TRAIT(H, TRAIT_NOSLIP))
		qdel(H)
		fail("Attached soles did not grant noslip to the wearer")
		return TRUE

	var/obj/item/clothing/suit/suit = new(H)
	suit.attach_clothing_traits(TRAIT_NOSLIP)
	H.equip_to_slot_or_del(suit, SLOT_WEAR_SUIT)
	shoes.AltClick(H)
	if(!HAS_TRAIT(H, TRAIT_NOSLIP))
		qdel(H)
		fail("Removing one clothing source removed another source's noslip trait")
		return TRUE

	H.drop_from_inventory(suit)
	if(HAS_TRAIT(H, TRAIT_NOSLIP))
		qdel(H)
		fail("Noslip remained after all clothing sources were removed")
		return TRUE

	qdel(H)
	pass("Noslip follows dynamic clothing sources independently")
	return TRUE

/datum/unit_test/clothing_traits_ian_slots
	name = "CLOTHING TRAITS: Ian held items are not worn"

/datum/unit_test/clothing_traits_ian_slots/start_test()
	var/turf/T = locate(1, 1, 1)
	var/mob/living/carbon/ian/Ian = new(T)
	var/obj/item/clothing/shoes/boots/galoshes/shoes = new(T)
	Ian.put_in_hands(shoes)
	if(HAS_TRAIT(Ian, TRAIT_NOSLIP))
		qdel(Ian)
		fail("Clothing held in Ian's mouth granted its worn trait")
		return TRUE

	var/obj/item/clothing/head/headwear = new(T)
	headwear.attach_clothing_traits(TRAIT_NOSLIP)
	Ian.equip_to_slot_or_del(headwear, SLOT_HEAD)
	if(!HAS_TRAIT(Ian, TRAIT_NOSLIP))
		qdel(Ian)
		fail("Clothing worn by Ian did not grant its trait")
		return TRUE

	qdel(Ian)
	pass("Ian clothing traits distinguish held and worn slots")
	return TRUE
