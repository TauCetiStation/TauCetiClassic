/mob/living/carbon/alien/facehugger/u_equip(obj/item/W)
	if (W == r_hand)
		r_hand = null
		update_inv_r_hand(0)

/mob/living/carbon/alien/facehugger/attack_ui(slot_id)
	return
