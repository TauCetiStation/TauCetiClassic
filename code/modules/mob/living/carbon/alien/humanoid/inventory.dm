//unequip
/* TODO check this
/mob/living/carbon/alien/humanoid/attack_ui(slot_id)
	var/obj/item/W = get_active_hand()
	if(W)
		if(!istype(W))	return
		switch(slot_id)
			if(slot_l_store)
				if(l_store)
					return
				if(W.w_class > 3)
					return
				u_equip(W)
				l_store = W
			if(slot_r_store)
				if(r_store)
					return
				if(W.w_class > 3)
					return
				u_equip(W)
				r_store = W
	else
		switch(slot_id)
			if(slot_wear_suit)
				if(wear_suit)	wear_suit.attack_alien(src)
			if(slot_head)
				if(head)		head.attack_alien(src)
			if(slot_l_store)
				if(l_store)		l_store.attack_alien(src)
			if(slot_r_store)
				if(r_store)		r_store.attack_alien(src)
*/
