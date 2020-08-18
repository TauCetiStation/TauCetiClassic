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

		if(H.equip_to_appropriate_slot(I, TRUE))
			if(hand)
				update_inv_l_hand()
			else
				update_inv_r_hand()

		else if(s_active && s_active.can_be_inserted(I,1))	//if storage active insert there
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

/mob/living/carbon/human/u_equip(obj/W)
	if(!W)	return 0

	if (W == wear_suit)
		if(s_store)
			drop_from_inventory(s_store)
		wear_suit = null
		var/update_hair = 0
		if((W.flags & BLOCKHAIR) || (W.flags & BLOCKHEADHAIR))
			update_hair = 1
		else if(istype(W, /obj/item))
			var/obj/item/I = W
			if(I.flags_inv & HIDEMASK)
				update_hair = 1
		if(update_hair)
			update_hair()
			update_inv_ears()
			update_inv_wear_mask()
		update_inv_wear_suit()
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
		update_inv_w_uniform()
	else if (W == gloves)
		gloves = null
		update_inv_gloves()
	else if (W == glasses)
		glasses = null
		update_inv_glasses()
	else if (W == head)
		head = null

		var/update_hair = 0
		if((W.flags & BLOCKHAIR) || (W.flags & BLOCKHEADHAIR))
			update_hair = 1
		else if(istype(W, /obj/item))
			var/obj/item/I = W
			if(I.flags_inv & HIDEMASK)
				update_hair = 1
		if(update_hair)
			update_hair()
			update_inv_ears()
			update_inv_wear_mask()

		update_inv_head()
	else if (W == l_ear)
		l_ear = null
		update_inv_ears()
	else if (W == r_ear)
		r_ear = null
		update_inv_ears()
	else if (W == shoes)
		shoes = null
		update_inv_shoes()
	else if (W == belt)
		belt = null
		update_inv_belt()
	else if (W == wear_mask)
		wear_mask = null
		if((W.flags & BLOCKHAIR) || (W.flags & BLOCKHEADHAIR))
			update_hair()	//rebuild hair
		if(internal)
			if(internals)
				internals.icon_state = "internal0"
			internal = null
		update_inv_wear_mask()
	else if (W == wear_id)
		wear_id = null
		update_inv_wear_id()
	else if (W == r_store)
		r_store = null
		update_inv_pockets()
	else if (W == l_store)
		l_store = null
		update_inv_pockets()
	else if (W == s_store)
		s_store = null
		update_inv_s_store()
	else if (W == back)
		back = null
		update_inv_back()
	else if (W == handcuffed)
		handcuffed = null
		update_inv_handcuffed()
		if(buckled && buckled.buckle_require_restraints)
			buckled.unbuckle_mob()
	else if (W == legcuffed)
		legcuffed = null
		update_inv_legcuffed()
	else if (W == r_hand)
		r_hand = null
		update_inv_r_hand()
	else if (W == l_hand)
		l_hand = null
		update_inv_l_hand()
	else
		return 0

	return 1

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
//set redraw_mob to 0 if you don't wish the hud to be updated - if you're doing it manually in your own proc.
/mob/living/carbon/human/equip_to_slot(obj/item/W, slot, redraw_mob = 1)
	if(!slot)
		return
	if(!istype(W))
		return
	if(!has_bodypart_for_slot(slot))
		return
	if(!specie_has_slot(slot))
		return

	W.screen_loc = null // will get moved if inventory is visible
	W.loc = src

	switch(slot)
		if(SLOT_BACK)
			src.back = W
			W.equipped(src, slot)
			update_inv_back()
		if(SLOT_WEAR_MASK)
			src.wear_mask = W
			if((wear_mask.flags & BLOCKHAIR) || (wear_mask.flags & BLOCKHEADHAIR))
				update_hair()
			W.equipped(src, slot)
			update_inv_wear_mask()
		if(SLOT_HANDCUFFED)
			src.handcuffed = W
			update_inv_handcuffed()
		if(SLOT_LEGCUFFED)
			src.legcuffed = W
			W.equipped(src, slot)
			update_inv_legcuffed()
		if(SLOT_L_HAND)
			src.l_hand = W
			W.equipped(src, slot)
			update_inv_l_hand()
		if(SLOT_R_HAND)
			src.r_hand = W
			W.equipped(src, slot)
			update_inv_r_hand()
		if(SLOT_BELT)
			playsound(src, 'sound/effects/equip_belt.ogg', VOL_EFFECTS_MASTER, 50, FALSE, -5)
			src.belt = W
			W.equipped(src, slot)
			update_inv_belt()
		if(SLOT_WEAR_ID)
			src.wear_id = W
			W.equipped(src, slot)
			update_inv_wear_id()
		if(SLOT_L_EAR)
			src.l_ear = W
			if(l_ear.slot_flags & SLOT_FLAGS_TWOEARS)
				var/obj/item/clothing/ears/offear/O = new(W)
				O.loc = src
				src.r_ear = O
				O.layer = ABOVE_HUD_LAYER
				O.plane = ABOVE_HUD_LAYER
				O.appearance_flags = APPEARANCE_UI
			W.equipped(src, slot)
			update_inv_ears()
		if(SLOT_R_EAR)
			src.r_ear = W
			if(r_ear.slot_flags & SLOT_FLAGS_TWOEARS)
				var/obj/item/clothing/ears/offear/O = new(W)
				O.loc = src
				src.l_ear = O
				O.layer = ABOVE_HUD_LAYER
				O.plane = ABOVE_HUD_LAYER
				O.appearance_flags = APPEARANCE_UI
			W.equipped(src, slot)
			update_inv_ears()
		if(SLOT_GLASSES)
			src.glasses = W
			W.equipped(src, slot)
			update_inv_glasses()
		if(SLOT_GLOVES)
			src.gloves = W
			W.equipped(src, slot)
			update_inv_gloves()
		if(SLOT_HEAD)
			src.head = W
			if((W.flags & BLOCKHAIR) || (W.flags & BLOCKHEADHAIR))
				update_hair()	//rebuild hair
			if(istype(W,/obj/item/clothing/head/kitty))
				W.update_icon(src)
			W.equipped(src, slot)
			update_inv_head()
		if(SLOT_SHOES)
			playsound(src, 'sound/effects/equip_shoes.ogg', VOL_EFFECTS_MASTER, 50, FALSE, -5)
			src.shoes = W
			W.equipped(src, slot)
			update_inv_shoes()
		if(SLOT_WEAR_SUIT)
			src.wear_suit = W
			if((W.flags & BLOCKHAIR) || (W.flags & BLOCKHEADHAIR))
				update_hair()	//rebuild hair
			W.equipped(src, slot)
			update_inv_wear_suit()
		if(SLOT_W_UNIFORM)
			playsound(src, 'sound/effects/equip_uniform.ogg', VOL_EFFECTS_MASTER, 50, FALSE, -5)
			src.w_uniform = W
			W.equipped(src, slot)
			update_inv_w_uniform()
		if(SLOT_L_STORE)
			src.l_store = W
			W.equipped(src, slot)
			update_inv_pockets()
		if(SLOT_R_STORE)
			src.r_store = W
			W.equipped(src, slot)
			update_inv_pockets()
		if(SLOT_S_STORE)
			src.s_store = W
			W.equipped(src, slot)
			update_inv_s_store()
		if(SLOT_IN_BACKPACK)
			if(src.get_active_hand() == W)
				src.remove_from_mob(W)
			W.loc = src.back
		if(SLOT_TIE)
			var/obj/item/clothing/under/uniform = w_uniform
			uniform.attackby(W, src)
		else
			to_chat(src, "<span class='warning'>You are trying to eqip this item to an unsupported inventory slot. How the heck did you manage that? Stop it...</span>")
			return

	if(W == l_hand && slot != SLOT_L_HAND)
		l_hand = null
		update_inv_l_hand() // So items actually disappear from hands.
	else if(W == r_hand && slot != SLOT_R_HAND)
		r_hand = null
		update_inv_r_hand()

	W.layer = ABOVE_HUD_LAYER
	W.plane = ABOVE_HUD_PLANE
	W.appearance_flags = APPEARANCE_UI
	W.slot_equipped = slot

/mob/living/carbon/human/put_in_l_hand(obj/item/W)
	if(!has_bodypart(BP_L_ARM))
		return FALSE
	return ..()

/mob/living/carbon/human/put_in_r_hand(obj/item/W)
	if(!has_bodypart(BP_R_ARM))
		return FALSE
	return ..()