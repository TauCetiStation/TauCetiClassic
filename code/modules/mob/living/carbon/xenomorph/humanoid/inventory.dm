//unequip
/mob/living/carbon/xenomorph/humanoid/u_equip(obj/item/W)
	if (W == wear_suit)
		wear_suit = null
	else if (W == head)
		head = null
	else if (W == r_store)
		r_store = null
	else if (W == l_store)
		l_store = null
	else if (W == r_hand)
		r_hand = null
	else if (W == l_hand)
		l_hand = null
	W.update_inv_mob()

/mob/living/carbon/xenomorph/humanoid/attack_ui(slot_id) // here was some legacy stuff regerding alien inventory slots which arent even shown on hud and so this proc has nothing to provide.
	return // Handles equipping items into clothing slots, refer into /mob/proc/attack_ui() for a clue if you want to add support, remove this one and work with parent proc unless very specific stuff.
