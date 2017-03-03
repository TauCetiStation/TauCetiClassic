/obj/item/clothing/suit/hooded
	action_button_name = "Hood"
	var/obj/item/clothing/head/hood
	var/hoodtype = /obj/item/clothing/head //so the chaplain hoodie or other hoodies can override this
	var/hooded = 0

/obj/item/clothing/suit/hooded/New()
	MakeHood()
	..()

/obj/item/clothing/suit/hooded/Destroy()
	qdel(hood)
	return ..()

/obj/item/clothing/suit/hooded/proc/MakeHood()
	if(!hood)
		var/obj/item/clothing/head/W = new hoodtype(src)
		hood = W

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

/obj/item/clothing/suit/hooded/dropped()
	..()
	RemoveHood()

/obj/item/clothing/suit/hooded/proc/ToggleHood()
	if(!hooded)
		if(ishuman(src.loc))
			var/mob/living/carbon/human/H = src.loc
			if(H.wear_suit != src)
				to_chat(H,"<span class='warning'>You must be wearing [src] to put up the hood!</span>")
				return
			if(H.head)
				to_chat(H,"<span class='warning'>You're already wearing something on your head!</span>")
				return
			H.equip_to_slot_if_possible(hood,slot_head,0,0,1)
	else
		RemoveHood()
	hooded = !hooded