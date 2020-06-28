/obj/item/clothing/suit/hooded
	action_button_name = "Hood"
	var/obj/item/clothing/head/hood
	var/hoodtype = /obj/item/clothing/head //so the chaplain hoodie or other hoodies can override this
	var/hooded = FALSE
	var/icon_suit_up

/obj/item/clothing/suit/hooded/atom_init()
	. = ..()
	hood = new hoodtype(src)
	hood.canremove = FALSE
	hood.unacidable = FALSE

/obj/item/clothing/suit/hooded/Destroy()
	qdel(hood)
	return ..()


/obj/item/clothing/suit/hooded/ui_action_click()
	ToggleHood()

/obj/item/clothing/suit/hooded/equipped(mob/living/carbon/human/user, slot)
	if(slot != user.wear_suit)
		RemoveHood()
	..()

/obj/item/clothing/suit/hooded/proc/RemoveHood()
	if(ishuman(hood.loc))
		var/mob/living/carbon/H = hood.loc
		H.unEquip(hood, 1)
	hood.loc = src
	hooded = !hooded
	if(icon_suit_up)
		icon_state = initial(icon_state)
		usr.update_inv_wear_suit()

/obj/item/clothing/suit/hooded/dropped()
	..()
	RemoveHood()

/obj/item/clothing/suit/hooded/proc/ToggleHood()
	if(!hooded)
		if(ishuman(src.loc))
			var/mob/living/carbon/human/H = src.loc
			if(H.wear_suit != src)
				to_chat(H, "<span class='usedanger'>You must be wearing [src] to put up the hood!</span>")
				return
			if(H.head)
				to_chat(H, "<span class='userdanger'>You're already wearing something on your head!</span>")
				return
			H.equip_to_slot_if_possible(hood, SLOT_HEAD, 0, 0, 1)
			if(icon_suit_up)
				icon_state = icon_suit_up
				usr.update_inv_wear_suit()
			hooded = !hooded
	else
		RemoveHood()
