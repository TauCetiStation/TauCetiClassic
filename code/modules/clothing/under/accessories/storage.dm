/obj/item/clothing/accessory/storage
	name = "load bearing equipment"
	desc = "Used to hold things when you don't have enough hands."
	icon_state = "webbing"
	item_color = "webbing"
	slot = "utility"
	var/slots = 3
	var/max_w_class = ITEM_SIZE_SMALL //pocket sized
	var/obj/item/weapon/storage/internal/hold

/obj/item/clothing/accessory/storage/atom_init()
	. = ..()
	hold = new/obj/item/weapon/storage/internal(src)
	hold.set_slots(slots, max_w_class)

/obj/item/clothing/accessory/storage/attack_hand(mob/user)
	if (has_suit) // if we are part of a suit
		hold.open(user)
		return

	if (hold.handle_attack_hand(user)) // otherwise interact as a regular storage item
		..(user)

/obj/item/clothing/accessory/storage/MouseDrop(obj/over_object)
	if (has_suit)
		return

	if (hold.handle_mousedrop(usr, over_object))
		..(over_object)

/obj/item/clothing/accessory/storage/attack_accessory(obj/item/I, mob/user, params)
	hold.attackby(I, user, params)
	return TRUE

/obj/item/clothing/accessory/storage/emp_act(severity)
	hold.emplode(severity)
	..()

/obj/item/clothing/accessory/storage/hear_talk(mob/M, msg, verb, datum/language/speaking)
	hold.hear_talk(M, msg, verb, speaking)
	..()

/obj/item/clothing/accessory/storage/attack_self(mob/user)
	to_chat(user, "<span class='notice'>You empty [src].</span>")
	var/turf/T = get_turf(src)
	hold.hide_from(usr)
	for(var/obj/item/I in hold.contents)
		hold.remove_from_storage(I, T)
	add_fingerprint(user)

/obj/item/clothing/accessory/storage/webbing
	name = "webbing"
	desc = "Strudy mess of synthcotton belts and buckles, ready to share your burden."
	icon_state = "webbing"
	item_color = "webbing"

/obj/item/clothing/accessory/storage/black_vest
	name = "black webbing vest"
	desc = "Robust black synthcotton vest with lots of pockets to hold whatever you need, but cannot hold in hands."
	icon_state = "vest_black"
	item_color = "vest_black"
	slots = 5

/obj/item/clothing/accessory/storage/brown_vest
	name = "brown webbing vest"
	desc = "Worn brownish synthcotton vest with lots of pockets to unload your hands."
	icon_state = "vest_brown"
	item_color = "vest_brown"
	slots = 5

/obj/item/clothing/accessory/storage/syndi_vest
	name = "suspicious webbing vest"
	desc = "A villainous red synthcotton vest with lots of pockets to unload your hands."
	icon_state = "syndi_vest"
	item_color = "syndi_vest"
	slots = 5

/obj/item/clothing/accessory/storage/knifeharness
	name = "decorated harness"
	desc = "A heavily decorated harness of sinew and leather with two knife-loops."
	icon_state = "unathiharness2"
	item_color = "unathiharness2"
	slots = 2
	max_w_class = ITEM_SIZE_NORMAL //for knives

/obj/item/clothing/accessory/storage/knifeharness/atom_init()
	. = ..()
	hold.can_hold = list(
		/obj/item/weapon/hatchet/unathiknife,
		/obj/item/weapon/kitchenknife/plastic,
		/obj/item/weapon/kitchenknife,
		/obj/item/weapon/kitchenknife/ritual
		)
	new /obj/item/weapon/hatchet/unathiknife(hold)
	new /obj/item/weapon/hatchet/unathiknife(hold)

/obj/item/clothing/accessory/storage/black_vest/mauser_belt
	name = "Mauser holster"
	desc = "A gun holster."
	icon_state = "Leather_belt_Mauser"
	item_color = "Leather_belt_Mauser"