/mob/living/carbon/human/verb/quick_equip()
	set name = "quick-equip"
	set hidden = 1

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		var/obj/item/I = H.get_active_hand()
		var/obj/item/weapon/storage/S = H.get_inactive_hand()
		if(!I)
			to_chat(H, "<span class='notice'>You are not holding anything to equip.</span>")
			return

	//	if(istype(I, /obj/item/clothing/head/helmet/space/rig)) // If the item to be equipped is a rigid suit helmet
	//		src << "<span class='warning'>You must fasten the helmet to a hardsuit first. (Target the head)</span>" // Stop eva helms equipping.
	//		return 0

		if(istype(I, /obj/item/clothing/suit/space)) // If the item to be equipped is a space suit
			if(H.wear_suit)
				to_chat(H, "<span class='warning'>You need to take off [H.wear_suit.name] first.</span>")
				return
			else
				var/obj/item/clothing/suit/space/rig/J = I
				if(J.equip_time > 0)
					delay_clothing_equip_to_slot_if_possible(J, SLOT_WEAR_SUIT)
					return 0

		if(istype(I, /obj/item/weapon/card/id))
			if(istype(H.wear_id, /obj/item/device/pda))
				wear_id.attackby(I, H)
				return

		if(H.equip_to_appropriate_slot(I, TRUE))
			return

		if(s_active && s_active.can_be_inserted(I,1))	//if storage active insert there
			s_active.handle_item_insertion(I)
		else if(istype(S, /obj/item/weapon/storage) && S.can_be_inserted(I,1))	//see if we have box in other hand
			S.handle_item_insertion(I)

		else
			S = H.get_item_by_slot(SLOT_BELT)
			if(istype(S, /obj/item/weapon/storage) && S.can_be_inserted(I,1))		//else we put in belt
				S.handle_item_insertion(I)
			else
				S = H.get_item_by_slot(SLOT_BACK)	//else we put in backpack
				if(istype(S, /obj/item/weapon/storage) && S.can_be_inserted(I,1))
					S.handle_item_insertion(I)
				else
					to_chat(H, "<span class='warning'>You are unable to equip that.</span>")



/mob/living/carbon/human/proc/equip_in_one_of_slots(obj/item/W, list/slots, del_on_fail = 1)
	for (var/slot in slots)
		if (equip_to_slot_if_possible(W, slots[slot], del_on_fail = 0))
			return slot
	if (del_on_fail)
		qdel(W)
	return null


/mob/living/carbon/human/has_bodypart(name)
	var/obj/item/organ/external/BP = bodyparts_by_name[name]

	return (BP && !(BP.is_stump) )

/mob/living/carbon/human/has_organ(name)
	var/obj/item/organ/internal/IO = organs_by_name[name]

	return IO

/mob/living/carbon/human/proc/specie_has_slot(slot)
	if(species && (slot in species.restricted_inventory_slots))
		return FALSE
	return TRUE

/mob/living/carbon/human/proc/has_bodypart_for_slot(slot)
	switch(slot)
		if(SLOT_BACK)
			return has_bodypart(BP_CHEST)
		if(SLOT_WEAR_MASK)
			return has_bodypart(BP_HEAD)
		if(SLOT_HANDCUFFED)
			return has_bodypart(BP_L_ARM) && has_bodypart(BP_R_ARM)
		if(SLOT_LEGCUFFED)
			return has_bodypart(BP_L_LEG) && has_bodypart(BP_R_LEG)
		if(SLOT_L_HAND)
			return has_bodypart(BP_L_ARM)
		if(SLOT_R_HAND)
			return has_bodypart(BP_R_ARM)
		if(SLOT_BELT)
			return has_bodypart(BP_CHEST)
		if(SLOT_WEAR_ID)
			// the only relevant check for this is the uniform check
			return TRUE
		if(SLOT_L_EAR)
			return has_bodypart(BP_HEAD)
		if(SLOT_R_EAR)
			return has_bodypart(BP_HEAD)
		if(SLOT_GLASSES)
			return has_bodypart(BP_HEAD)
		if(SLOT_GLOVES)
			return has_bodypart(BP_L_ARM) && has_bodypart(BP_R_ARM)
		if(SLOT_HEAD)
			return has_bodypart(BP_HEAD)
		if(SLOT_SHOES)
			return has_bodypart(BP_R_LEG) && has_bodypart(BP_L_LEG)
		if(SLOT_WEAR_SUIT)
			return has_bodypart(BP_CHEST)
		if(SLOT_W_UNIFORM)
			return has_bodypart(BP_CHEST)
		if(SLOT_L_STORE)
			return has_bodypart(BP_CHEST)
		if(SLOT_R_STORE)
			return has_bodypart(BP_CHEST)
		if(SLOT_S_STORE)
			return has_bodypart(BP_CHEST)
		if(SLOT_IN_BACKPACK)
			return TRUE
		if(SLOT_TIE)
			return TRUE

/mob/living/carbon/human/u_equip(obj/item/W)
	if(!W)
		return

	if (W == wear_suit)
		if(s_store)
			drop_from_inventory(s_store)
		wear_suit = null
	else if (W == w_uniform)
		if (r_store)
			drop_from_inventory(r_store)
		if (l_store)
			drop_from_inventory(l_store)
		if (wear_id)
			drop_from_inventory(wear_id)
		if (belt)
			drop_from_inventory(belt)
		w_uniform = null
		update_suit_sensors()
	else if (W == gloves)
		gloves = null
	else if (W == glasses)
		glasses = null
	else if (W == head)
		head = null
	else if (W == l_ear)
		l_ear = null
	else if (W == r_ear)
		r_ear = null
	else if (W == shoes)
		shoes = null
	else if (W == belt)
		belt = null
	else if (W == wear_mask)
		wear_mask = null
		if(internal)
			internal = null
		sec_hud_set_security_status()
	else if (W == wear_id)
		wear_id = null
		sec_hud_set_ID()
		sec_hud_set_security_status()
	else if (W == r_store)
		r_store = null
	else if (W == l_store)
		l_store = null
	else if (W == s_store)
		s_store = null
	else if (W == back)
		back = null
	else if (W == handcuffed)
		handcuffed = null
		if(buckled && buckled.buckle_require_restraints)
			buckled.unbuckle_mob()
	else if (W == legcuffed)
		legcuffed = null
	else if (W == r_hand)
		r_hand = null
	else if (W == l_hand)
		l_hand = null
	else
		return

	W.update_inv_mob()

/mob/living/carbon/human/proc/equipOutfit(outfit, visualsOnly = FALSE)
	var/datum/outfit/O = null

	if(ispath(outfit))
		O = new outfit
	else
		O = outfit
		if(!istype(O))
			return 0
	if(!O)
		return 0

	return O.equip(src, visualsOnly)

//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
/mob/living/carbon/human/equip_to_slot(obj/item/W, slot)
	if(!slot)
		return
	if(!istype(W))
		return

	W.screen_loc = null // will get moved if inventory is visible
	W.forceMove(src)

	switch(slot)
		if(SLOT_BACK)
			src.back = W
			W.equipped(src, slot)
		if(SLOT_WEAR_MASK)
			src.wear_mask = W
			W.equipped(src, slot)
			sec_hud_set_security_status()
		if(SLOT_HANDCUFFED)
			src.handcuffed = W
		if(SLOT_LEGCUFFED)
			src.legcuffed = W
			W.equipped(src, slot)
		if(SLOT_L_HAND)
			src.l_hand = W
			W.equipped(src, slot)
		if(SLOT_R_HAND)
			src.r_hand = W
			W.equipped(src, slot)
		if(SLOT_BELT)
			playsound(src, 'sound/effects/equip_belt.ogg', VOL_EFFECTS_MASTER, 50, FALSE, null, -5)
			src.belt = W
			W.equipped(src, slot)
		if(SLOT_WEAR_ID)
			src.wear_id = W
			W.equipped(src, slot)
			sec_hud_set_ID()
			sec_hud_set_security_status()
		if(SLOT_L_EAR)
			src.l_ear = W
			if(l_ear.slot_flags & SLOT_FLAGS_TWOEARS)
				var/obj/item/clothing/ears/offear/O = new(W)
				O.loc = src
				src.r_ear = O
				O.plane = ABOVE_HUD_PLANE
				O.appearance_flags = APPEARANCE_UI
			W.equipped(src, slot)
		if(SLOT_R_EAR)
			src.r_ear = W
			if(r_ear.slot_flags & SLOT_FLAGS_TWOEARS)
				var/obj/item/clothing/ears/offear/O = new(W)
				O.loc = src
				src.l_ear = O
				O.plane = ABOVE_HUD_PLANE
				O.appearance_flags = APPEARANCE_UI
			W.equipped(src, slot)
		if(SLOT_GLASSES)
			src.glasses = W
			W.equipped(src, slot)
		if(SLOT_GLOVES)
			src.gloves = W
			W.equipped(src, slot)
		if(SLOT_HEAD)
			src.head = W
			if(istype(W,/obj/item/clothing/head/kitty))
				W.update_icon(src)
			W.equipped(src, slot)
		if(SLOT_SHOES)
			playsound(src, 'sound/effects/equip_shoes.ogg', VOL_EFFECTS_MASTER, 50, FALSE, null, -5)
			src.shoes = W
			W.equipped(src, slot)
		if(SLOT_WEAR_SUIT)
			src.wear_suit = W
			W.equipped(src, slot)
		if(SLOT_W_UNIFORM)
			playsound(src, 'sound/effects/equip_uniform.ogg', VOL_EFFECTS_MASTER, 50, FALSE, null, -5)
			src.w_uniform = W
			W.equipped(src, slot)
			update_suit_sensors()
		if(SLOT_L_STORE)
			src.l_store = W
			W.equipped(src, slot)
		if(SLOT_R_STORE)
			src.r_store = W
			W.equipped(src, slot)
		if(SLOT_S_STORE)
			src.s_store = W
			W.equipped(src, slot)
		if(SLOT_IN_BACKPACK)
			if(get_active_hand() == W)
				remove_from_mob(W)
			W.forceMove(src.back)
		if(SLOT_TIE)
			var/obj/item/clothing/under/uniform = w_uniform
			uniform.attach_accessory(W, src)
		else
			to_chat(src, "<span class='warning'>You are trying to eqip this item to an unsupported inventory slot. How the heck did you manage that? Stop it...</span>")
			return

	if(W == l_hand && slot != SLOT_L_HAND)
		l_hand = null
		W.update_inv_mob() // So items actually disappear from hands.
	else if(W == r_hand && slot != SLOT_R_HAND)
		r_hand = null
		W.update_inv_mob()

	W.plane = ABOVE_HUD_PLANE
	W.appearance_flags = APPEARANCE_UI
	W.slot_equipped = slot
	W.update_inv_mob()

/mob/living/carbon/human/put_in_l_hand(obj/item/W)
	if(!has_bodypart(BP_L_ARM))
		return FALSE
	return ..()

/mob/living/carbon/human/put_in_r_hand(obj/item/W)
	if(!has_bodypart(BP_R_ARM))
		return FALSE
	return ..()

//delete all equipment without dropping anything
/mob/living/carbon/human/proc/delete_equipment()
	for(var/slot in get_all_slots())//order matters, dependant slots go first
		qdel(slot)

/mob/living/carbon/human/proc/get_all_slots()
	. = get_head_slots() | get_body_slots()

/mob/living/carbon/human/proc/get_body_slots()
	return list(
		back,
		s_store,
		handcuffed,
		legcuffed,
		wear_suit,
		gloves,
		shoes,
		belt,
		wear_id,
		l_store,
		r_store,
		w_uniform,
		l_hand,
		r_hand
		)

/mob/living/carbon/human/proc/get_head_slots()
	return list(
		head,
		wear_mask,
		neck,
		glasses,
		l_ear,
		r_ear
		)
