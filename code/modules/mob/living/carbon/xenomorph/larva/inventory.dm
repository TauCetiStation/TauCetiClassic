/mob/living/carbon/xenomorph/larva/u_equip(obj/item/W)
	if(W == r_hand)
		r_hand = null
	W.update_inv_mob()

/mob/living/carbon/xenomorph/larva/attack_ui(slot_id)
	return
