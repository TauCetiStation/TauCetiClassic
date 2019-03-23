//Most of these are defined at this level to reduce on checks elsewhere in the code.
//Having them here also makes for a nice reference list of the various overlay-updating procs available

/mob/proc/regenerate_icons()		//TODO: phase this out completely if possible
	return

/mob/proc/update_icons()
	return

/mob/proc/update_hud()
	return

/mob/proc/update_inv_item(obj/item/I) // don't call this proc and it's subtypes directly, used in update_inv_mob proc.
	switch(I.slot_equipped)
		if(SLOT_BACK)
			update_inv_back()
		if(SLOT_WEAR_MASK)
			update_inv_wear_mask()
		if(SLOT_HANDCUFFED)
			update_inv_handcuffed()
		if(SLOT_L_HAND)
			update_inv_l_hand()
		if(SLOT_R_HAND)
			update_inv_r_hand()
		if(SLOT_BELT)
			update_inv_belt()
		if(SLOT_WEAR_ID)
			update_inv_wear_id()
		if(SLOT_L_EAR, SLOT_R_EAR)
			update_inv_ears()
		if(SLOT_GLASSES)
			update_inv_glasses()
		if(SLOT_GLOVES)
			update_inv_gloves()
		if(SLOT_HEAD)
			update_inv_head()
		if(SLOT_SHOES)
			update_inv_shoes()
		if(SLOT_WEAR_SUIT)
			update_inv_wear_suit()
		if(SLOT_W_UNIFORM)
			update_inv_w_uniform()
		if(SLOT_S_STORE)
			update_inv_s_store()
		if(SLOT_LEGCUFFED)
			update_inv_legcuffed()

/mob/living/carbon/ian/update_inv_item(obj/item/I)
	switch(I.slot_equipped)
		if(SLOT_MOUTH)
			update_inv_mouth()
		if(SLOT_NECK)
			update_inv_neck()
		else
			..()


/mob/proc/update_inv_handcuffed()
	return

/mob/proc/update_inv_legcuffed()
	return

/mob/proc/update_inv_back()
	return

/mob/proc/update_inv_l_hand()
	return

/mob/proc/update_inv_r_hand()
	return

/mob/proc/update_inv_wear_mask()
	return

/mob/proc/update_inv_wear_suit()
	return

/mob/proc/update_inv_w_uniform()
	return

/mob/proc/update_inv_belt()
	return

/mob/proc/update_inv_head()
	return

/mob/proc/update_inv_gloves()
	return

/mob/proc/update_mutations()
	return

/mob/proc/update_inv_wear_id()
	return

/mob/proc/update_inv_shoes()
	return

/mob/proc/update_inv_glasses()
	return

/mob/proc/update_inv_s_store()
	return

/mob/proc/update_inv_pockets()
	return

/mob/proc/update_inv_ears()
	return

/mob/proc/update_targeted()
	return

/mob/proc/update_fire()
	return
