// This outfit preserves varedits made on the items
// Created from admin helpers.
/datum/outfit/varedit
	var/list/vv_values
	var/list/stored_access
	var/update_id_name = FALSE //If the name of the human is same as the name on the id they're wearing we'll update provided id when equipping

/datum/outfit/varedit/pre_equip(mob/living/carbon/human/H, visualsOnly)
	H.delete_equipment() //Applying VV to wrong objects is not reccomended.
	. = ..()

/datum/outfit/varedit/proc/set_equipement_by_slot(slot,item_path)
	switch(slot)
		if(SLOT_W_UNIFORM)
			uniform = item_path
		if(SLOT_BACK)
			back = item_path
		if(SLOT_WEAR_SUIT)
			suit = item_path
		if(SLOT_BELT)
			belt = item_path
		if(SLOT_GLOVES)
			gloves = item_path
		if(SLOT_SHOES)
			shoes = item_path
		if(SLOT_HEAD)
			head = item_path
		if(SLOT_WEAR_MASK)
			mask = item_path
		if(SLOT_NECK)
			neck = item_path
		if(SLOT_L_EAR)
			l_ear = item_path
		if(SLOT_R_EAR)
			r_ear = item_path
		if(SLOT_GLASSES)
			glasses = item_path
		if(SLOT_WEAR_ID)
			id = item_path
		if(SLOT_S_STORE)
			suit_store = item_path
		if(SLOT_L_STORE)
			l_pocket = item_path
		if(SLOT_R_STORE)
			r_pocket = item_path
