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
	//		src << "\red You must fasten the helmet to a hardsuit first. (Target the head)" // Stop eva helms equipping.
	//		return 0

		//if(istype(I, /obj/item/clothing/suit/space)) // If the item to be equipped is a space suit
		//	if(H.wear_suit)
		//		to_chat(H, "<span class='warning'>You need to take off [H.wear_suit.name] first.</span>")
		//		return
		//	else
		//		var/obj/item/clothing/suit/space/rig/J = I
		//		if(J.equip_time > 0)
		//			delay_clothing_equip_to_slot_if_possible(J, 13)  // 13 = suit slot
		//			return 0

		if(H.equip_to_appropriate_slot(I))
			// Do nothing (actually, mob overlays update was here and equip proc will do that itself now).
		else if(s_active && s_active.can_be_inserted(I,1))	//if storage active insert there
			s_active.handle_item_insertion(I)
		else if(istype(S, /obj/item/weapon/storage) && S.can_be_inserted(I,1))	//see if we have box in other hand
			S.handle_item_insertion(I)

		else
			S = H.get_item_by_slot(slot_belt)
			if(istype(S, /obj/item/weapon/storage) && S.can_be_inserted(I,1))		//else we put in belt
				S.handle_item_insertion(I)
			else
				S = H.get_item_by_slot(slot_back)	//else we put in backpack
				if(istype(S, /obj/item/weapon/storage) && S.can_be_inserted(I,1))
					S.handle_item_insertion(I)
				else
					to_chat(H, "<span class='warning'>You are unable to equip that.</span>")



/mob/living/carbon/human/proc/equip_in_one_of_slots(obj/item/W, list/slots, del_on_fail = 1)
	for (var/slot in slots)
		if(slot == slot_in_backpack)
			return put_in_backpack_if_possible(W)
		if (equip_to_slot_if_possible(W, slots[slot], del_on_fail = 0))
			return slot
	if (del_on_fail)
		qdel(W)
	return null


/mob/living/carbon/proc/has_bodypart(name)
	var/obj/item/bodypart/BP = bodyparts_by_name[name]

	return (BP && !BP.is_stump())

/mob/living/carbon/human/proc/has_bodypart_for_slot(slot)
	switch(slot)
		if(slot_back)
			return has_bodypart(BP_CHEST)
		if(slot_wear_mask)
			return has_bodypart(BP_HEAD)
		if(slot_handcuffed)
			return has_bodypart(BP_L_ARM) || has_bodypart(BP_R_ARM)
		if(slot_legcuffed)
			return has_bodypart(BP_L_LEG) || has_bodypart(BP_R_LEG)
		if(slot_l_hand)
			return has_bodypart(BP_L_ARM)
		if(slot_r_hand)
			return has_bodypart(BP_R_ARM)
		if(slot_belt)
			return has_bodypart(BP_CHEST)
		if(slot_wear_id)
			// the only relevant check for this is the uniform check
			return 1
		if(slot_l_ear)
			return has_bodypart(BP_HEAD)
		if(slot_r_ear)
			return has_bodypart(BP_HEAD)
		if(slot_glasses)
			return has_bodypart(BP_HEAD)
		if(slot_gloves)
			return has_bodypart(BP_L_ARM) || has_bodypart(BP_R_ARM)
		if(slot_head)
			return has_bodypart(BP_HEAD)
		if(slot_shoes)
			return has_bodypart(BP_R_LEG) || has_bodypart(BP_L_LEG)
		if(slot_wear_suit)
			return has_bodypart(BP_CHEST)
		if(slot_w_uniform)
			return has_bodypart(BP_CHEST)
		if(slot_l_store)
			return has_bodypart(BP_CHEST)
		if(slot_r_store)
			return has_bodypart(BP_CHEST)
		if(slot_s_store)
			return has_bodypart(BP_CHEST)
/*
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
	else if (W == gloves)
		gloves = null
	else if (W == glasses)
		glasses = null
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
		if((W.flags & BLOCKHAIR) || (W.flags & BLOCKHEADHAIR))
			update_hair()	//rebuild hair
		if(internal)
			if(internals)
				internals.icon_state = "internal0"
			internal = null
	else if (W == wear_id)
		wear_id = null
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
		return 0

	return 1*/

/*
	If certain item was unequipped from certain bodypart, what we should unequip with it or maybe do something important.
*/
/obj/item/bodypart/proc/unequip_chain(slot)
	return

/obj/item/bodypart/chest/unequip_chain(slot)
	if(!owner)
		return

	switch(slot)
		if(slot_w_uniform)
			for(var/thing in list(slot_r_store, slot_l_store, slot_wear_id, slot_belt))
				owner.dropItemToGround(item_in_slot[thing], TRUE)
		if(slot_wear_suit)
			owner.dropItemToGround(item_in_slot[slot_s_store], TRUE)

		if(slot_handcuffed)
			if(owner.buckled && owner.buckled.buckle_require_restraints)
				owner.buckled.unbuckle_mob()
		//if(slot_legcuffed)
			//owner.dropItemToGround(item_in_slot[slot_legcuffed])

/*
	When certain bodypart removed, we may force to drop items from another bodypart slots.
	Gloves, shoes, etc at this time is a single slot which inside chest, so we should drop items from that slots.
	This proc will be no longer needed, when such slots and items separated and moved into their respective bodyparts.
*/
/obj/item/bodypart/proc/drop_linked_items()
	return

/obj/item/bodypart/arm/drop_linked_items()
	owner.dropSlotToGround(slot_handcuffed, TRUE)
	owner.dropSlotToGround(slot_gloves, TRUE)

/obj/item/bodypart/leg/drop_linked_items()
	owner.dropSlotToGround(slot_legcuffed, TRUE)
	owner.dropSlotToGround(slot_shoes, TRUE)
	owner.dropSlotToGround(slot_socks, TRUE)

/*
	Which items (as flags) each bodypart can equip.
*/
/obj/item/bodypart/proc/can_hold(obj/item/I, slot, disable_warning = FALSE)
	if(!I || !slot || item_in_slot[slot])
		return FALSE
	return TRUE

/obj/item/bodypart/head/can_hold(obj/item/I, slot, disable_warning = FALSE)
	if(!I || !slot || item_in_slot[slot])
		return FALSE

	var/flags = I.slot_flags

	switch(slot)
		if(slot_head)
			if( !(flags & SLOT_HEAD) )
				return FALSE
			return TRUE
		if(slot_glasses)
			if( !(flags & SLOT_EYES) )
				return FALSE
			return TRUE
		if(slot_l_ear)
			if( I.w_class <= 1)
				return TRUE
			if( !(flags & SLOT_EARS) )
				return FALSE
			if( (flags & SLOT_TWOEARS) && item_in_slot[slot_r_ear] )
				return FALSE
			return TRUE
		if(slot_r_ear)
			if( I.w_class <= 1 )
				return TRUE
			if( !(flags & SLOT_EARS) )
				return FALSE
			if( (flags & SLOT_TWOEARS) && item_in_slot[slot_l_ear] )
				return FALSE
			return TRUE
		if(slot_wear_mask)
			if( !(flags & SLOT_MASK) )
				return FALSE
			return TRUE
		else
			return FALSE

/obj/item/bodypart/chest/can_hold(obj/item/I, slot, disable_warning = FALSE)
	if(!I || !slot || item_in_slot[slot])
		return FALSE

	var/flags = I.slot_flags

	switch(slot)
		if(slot_back)
			if( !(flags & SLOT_BACK) )
				return FALSE
			return TRUE
		if(slot_wear_suit)
			if(owner && (owner.disabilities & FAT) && !(flags & ONESIZEFITSALL))
				if(!disable_warning)
					to_chat(owner, "\red You're too fat to wear the [I].")
				return FALSE
			if( !(flags & SLOT_OCLOTHING) )
				return FALSE
			return TRUE
		if(slot_w_uniform)
			if(owner && (owner.disabilities & FAT) && !(flags & ONESIZEFITSALL))
				if(!disable_warning)
					to_chat(owner, "\red You're too fat to wear the [I].")
				return FALSE
			if( !(flags & SLOT_ICLOTHING) )
				return FALSE
			return TRUE
		if(slot_undershirt)
			if(istype(I, /obj/item/clothing/under/undershirt))
				return TRUE
			return FALSE
		if(slot_underwear)
			if(istype(I, /obj/item/clothing/under/underwear))
				return TRUE
			return FALSE
		if(slot_wear_id)
			if(!item_in_slot[slot_w_uniform])
				if(owner && !disable_warning)
					to_chat(owner, "\red You need a jumpsuit before you can attach this [I].")
				return FALSE
			if( !(flags & SLOT_ID) )
				return FALSE
			return TRUE
		if(slot_l_store)
			if(!item_in_slot[slot_w_uniform])
				if(owner && !disable_warning)
					to_chat(owner, "\red You need a jumpsuit before you can attach this [I].")
				return FALSE
			if(flags & SLOT_DENYPOCKET)
				return FALSE
			if( I.w_class <= 2 || (flags & SLOT_POCKET) )
				return TRUE
			return FALSE
		if(slot_r_store)
			if(!item_in_slot[slot_w_uniform])
				if(owner && !disable_warning)
					to_chat(owner, "\red You need a jumpsuit before you can attach this [I].")
				return FALSE
			if(flags & SLOT_DENYPOCKET)
				return FALSE
			if( I.w_class <= 2 || (flags & SLOT_POCKET) )
				return TRUE
			return FALSE
		if(slot_s_store)
			if(!item_in_slot[slot_wear_suit])
				if(owner && !disable_warning)
					to_chat(owner, "\red You need a suit before you can attach this [I].")
				return FALSE
			var/obj/item/w_suit = item_in_slot[slot_wear_suit]
			if(!w_suit.allowed)
				if(owner && !disable_warning)
					to_chat(owner, "You somehow have a suit with no defined allowed items for suit storage, stop that.")
				return FALSE
			if( istype(I, /obj/item/device/pda) || istype(I, /obj/item/weapon/pen) || is_type_in_list(I, w_suit.allowed) )
				return TRUE
			return FALSE
		if(slot_belt)
			if(!item_in_slot[slot_w_uniform])
				if(owner && !disable_warning)
					to_chat(owner, "\red You need a jumpsuit before you can attach this [name].")
				return FALSE
			if( !(flags & SLOT_BELT) )
				return FALSE
			return TRUE
		if(slot_gloves) // TODO think about feature: single glove for each hand, and similar for boots.
			if(!owner) // since this slot shared with both hands..
				return FALSE
			if(!owner.has_bodypart(BP_R_ARM) || !owner.has_bodypart(BP_L_ARM)) // need both hands.
				return FALSE
			if( !(flags & SLOT_GLOVES) )
				return FALSE
			return TRUE
		if(slot_shoes)
			if(!owner) // since this slot shared with both legs..
				return FALSE
			if(!owner.has_bodypart(BP_R_LEG) || !owner.has_bodypart(BP_L_LEG)) // need both legs.
				return FALSE
			if( !(flags & SLOT_FEET) )
				return FALSE
			return TRUE
		if(slot_socks)
			if(!owner) // since this slot shared with both legs..
				return FALSE
			if(!owner.has_bodypart(BP_R_LEG) || !owner.has_bodypart(BP_L_LEG)) // need both legs.
				return FALSE
			if(istype(I, /obj/item/clothing/shoes/socks))
				return TRUE
			return FALSE
		if(slot_handcuffed)
			if(!owner)
				return FALSE
			else if(owner.bodypart_hands.len < 2)
				return FALSE
			if(!istype(I, /obj/item/weapon/handcuffs))
				return FALSE
			return TRUE
		if(slot_legcuffed)
			if(!owner)
			else if(owner.bodypart_legs.len < 2)
				return FALSE
			if(!istype(I, /obj/item/weapon/legcuffs))
				return FALSE
			return TRUE
		else
			return FALSE

/obj/item/bodypart/chest/nymph/can_hold(obj/item/I, slot, disable_warning = FALSE)
	if(!I || !slot || item_in_slot[slot])
		return FALSE

	switch(slot)
		if(slot_r_hand)
			return TRUE
	return ..()

/obj/item/bodypart/chest/unbreakable/facehugger/can_hold(obj/item/I, slot, disable_warning = FALSE)
	if(!I || !slot || item_in_slot[slot])
		return FALSE

	switch(slot)
		if(slot_r_hand)
			if(istype(I, /obj/item/weapon/fh_grab))
				return TRUE
	return FALSE

/obj/item/bodypart/chest/unbreakable/larva/can_hold(obj/item/I, slot, disable_warning = FALSE)
	return FALSE

/obj/item/bodypart/chest/monkey/can_hold(obj/item/I, slot, disable_warning = FALSE)
	if(!I || !slot || item_in_slot[slot])
		return FALSE

	if(slot == slot_undershirt)
		if(istype(I, /obj/item/clothing/under/monkey))
			return TRUE
		return FALSE
	return ..()

/obj/item/bodypart/head/unbreakable/dog/can_hold(obj/item/I, slot, disable_warning = FALSE)
	if(!I || !slot || item_in_slot[slot])
		return FALSE

	switch(slot)
		if(slot_r_hand)
			return TRUE
	return ..()

/obj/item/bodypart/chest/unbreakable/dog/can_hold(obj/item/I, slot, disable_warning = FALSE)
	if(!I || !slot || item_in_slot[slot])
		return FALSE

	var/flags = I.slot_flags

	switch(slot)
		if(slot_back)
			if(istype(I, /obj/item/clothing/suit/armor/vest))
				return TRUE
			if( !(flags & SLOT_BACK) )
				return FALSE
			return TRUE
		if(slot_wear_id)
			if( !(flags & SLOT_ID) )
				return FALSE
			return TRUE
	return ..()
