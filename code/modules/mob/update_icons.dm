//Most of these are defined at this level to reduce on checks elsewhere in the code.
//Having them here also makes for a nice reference list of the various overlay-updating procs available

/mob/proc/regenerate_icons()		//TODO: phase this out completely if possible
	return

/mob/proc/update_icons()
	return

/mob/proc/update_hud()
	return

// don't call this proc and it's subtypes directly, use update_inv_mob proc if you are working with item.
/mob/proc/update_inv_slot(slot)
	switch(slot)
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
		if(SLOT_L_STORE, SLOT_R_STORE)
			update_inv_pockets()
		if(SLOT_S_STORE)
			update_inv_s_store()
		if(SLOT_LEGCUFFED)
			update_inv_legcuffed()

/mob/living/carbon/ian/update_inv_slot(slot)
	switch(slot)
		if(SLOT_MOUTH)
			update_inv_mouth()
		if(SLOT_NECK)
			update_inv_neck()
		else
			..()

/mob/living/carbon/human/update_inv_slot(slot)
	..()
	if(slot == SLOT_WEAR_MASK || slot == SLOT_HEAD || slot == SLOT_WEAR_SUIT || slot == SLOT_W_UNIFORM)
		update_hair()

/obj/item/proc/update_inv_mob()
	if(!slot_equipped || !ismob(loc))
		return

	var/mob/M = loc
	M.update_inv_slot(slot_equipped)

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
	cut_overlay(target_locked)
	if(!targeted_by && target_locked)
		qdel(target_locked)
	if (targeted_by && target_locked)
		add_overlay(target_locked)
	return

/mob/proc/update_fire()
	return
