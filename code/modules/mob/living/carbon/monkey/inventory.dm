//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
//set redraw_mob to 0 if you don't wish the hud to be updated - if you're doing it manually in your own proc.
/mob/living/carbon/monkey/equip_to_slot(obj/item/W, slot, redraw_mob = 1)
	if(!slot)
		return
	if(!istype(W))
		return

	W.screen_loc = null // will get moved if inventory is visible
	W.loc = src

	switch(slot)
		if(SLOT_HEAD)
			head = W
			W.equipped(src, slot)
			update_inv_head(redraw_mob)
		if(SLOT_BACK)
			src.back = W
			W.equipped(src, slot)
			update_inv_back(redraw_mob)
		if(SLOT_WEAR_MASK)
			src.wear_mask = W
			W.equipped(src, slot)
			update_inv_wear_mask(redraw_mob)
		if(SLOT_HANDCUFFED)
			src.handcuffed = W
			update_inv_handcuffed(redraw_mob)
		if(SLOT_LEGCUFFED)
			src.legcuffed = W
			W.equipped(src, slot)
			update_inv_legcuffed(redraw_mob)
		if(SLOT_L_HAND)
			src.l_hand = W
			W.equipped(src, slot)
			update_inv_l_hand(redraw_mob)
		if(SLOT_R_HAND)
			src.r_hand = W
			W.equipped(src, slot)
			update_inv_r_hand(redraw_mob)
		if(SLOT_IN_BACKPACK)
			if(src.get_active_hand() == W)
				src.remove_from_mob(W)
			W.loc = src.back
		else
			to_chat(usr, "<span class='red'>You are trying to eqip this item to an unsupported inventory slot. How the heck did you manage that? Stop it...</span>")
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
