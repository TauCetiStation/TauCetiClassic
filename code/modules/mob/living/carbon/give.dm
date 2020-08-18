/mob/living/carbon/verb/give(mob/M in oview(1))
	set category = "IC"
	set name = "Give"


	if(!M.can_accept_gives(src, show_warnings = TRUE) || !can_give(M, show_warnings = TRUE) || M.client == null)
		return
	var/obj/item/I = src.get_active_hand()
	if(!I)
		to_chat(src, "<span class='red'>You don't have anything in your hand to give to [M]</span>")
		return
	if(I.flags & (ABSTRACT | DROPDEL))
		to_chat(src, "<span class='red'>You can't give this to [name]</span>")
		return
	if(HULK in M.mutations)
		if(I.w_class < ITEM_SIZE_LARGE)
			to_chat(src, "<span class='red'>[I] is too small for [name] to hold.</span>")
			return
	switch(alert(M,"[src] wants to give you \a [I]?",,"Yes","No"))
		if("Yes")
			if(!can_give(M, show_warnings = TRUE))
				return
			if(!M.can_accept_gives(src, show_warnings = TRUE))
				return
			if(QDELETED(I))
				return
			if(!Adjacent(M))
				to_chat(src, "<span class='red'>You need to stay in reaching distance while giving an object.</span>")
				to_chat(M, "<span class='red'>[src] moved too far away.</span>")
				return
			if(get_active_hand() != I)
				to_chat(src, "<span class='red'>You need to keep the item in your active hand.</span>")
				to_chat(M, "<span class='red'>[src] seem to have given up on giving \the [I] to you.</span>")
				return
			else
				drop_from_inventory(I)
				M.put_in_hands(I)
			I.add_fingerprint(M)
			M.visible_message("<span class='notice'>[src] handed \the [I] to [M].</span>")
		if("No")
			M.visible_message("<span class='red'>[src] tried to hand [I] to [M] but [M] didn't want it.</span>")


/mob/living/carbon/proc/can_give(mob/M, show_warnings = FALSE)
	if(M.incapacitated())
		if(show_warnings)
			to_chat(src, "<span class='warning'>[M] is incapable of being given anything to.</span>")
		return FALSE
	if(incapacitated())
		if(show_warnings)
			to_chat(src, "<span class='warning'>You are of giving anything.</span>")
		return FALSE
	return TRUE

/mob/proc/can_accept_gives(mob/giver, show_warnings = FALSE)
	if(show_warnings)
		to_chat(giver, "<span class='red'>[src] doesn't have hands for you to give them anything.</span>")
	return FALSE

/mob/living/carbon/can_accept_gives(mob/giver, show_warnings = FALSE)
	if(get_active_hand() && get_inactive_hand())
		if(show_warnings)
			to_chat(giver, "<span class='red'>[src]'s hands are full.</span>")
		return FALSE
	return TRUE

/mob/living/carbon/ian/can_accept_gives(mob/giver, show_warnings = FALSE)
	if(get_active_hand() && get_inactive_hand())
		if(show_warnings)
			to_chat(giver, "<span class='red'>[src]'s mouth is full.</span>")
		return FALSE
	return TRUE

/mob/living/carbon/human/can_accept_gives(mob/giver, show_warnings = FALSE)
	var/obj/item/organ/external/left_hand = bodyparts_by_name[BP_L_ARM]
	var/obj/item/organ/external/right_hand = bodyparts_by_name[BP_R_ARM]
	if((!left_hand || !left_hand.is_usable() || l_hand) && (!right_hand || !right_hand.is_usable() || r_hand))
		to_chat(giver, "<span class='red'>[src] can't take</span>")
		return FALSE
	return TRUE

/mob/living/carbon/slime/can_accept_gives(mob/giver, show_warnings = FALSE)
	if(show_warnings)
		to_chat(giver, "<span class='red'>[src] doesn't have hands for you to give them anything.</span>")
	return FALSE

/mob/living/carbon/xenomorph/can_accept_gives(mob/giver, show_warnings = FALSE)
	if(show_warnings)
		to_chat(giver, "<span class='red'>[src] doesn't have hands for you to give them anything.</span>")
	return FALSE
