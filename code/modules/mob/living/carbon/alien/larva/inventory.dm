/mob/living/carbon/alien/larva/u_equip(obj/item/W)
	if(W == r_hand)
		r_hand = null
		update_inv_r_hand(0)

/mob/living/carbon/alien/larva/attack_ui(slot_id)
	return
