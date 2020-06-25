/mob/living/carbon/verb/give(mob/M in oview(1))
	set category = "IC"
	set name = "Give"


	if(!iscarbon(M))
		to_chat(src, "<span class='danger'>Wait a second... \the [M] HAS NO HANDS! AHH!</span>")//cheesy messages ftw
		return

	if(!can_give(M) || !can_accept_gives(M) || M.client == null)
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/BP = H.bodyparts_by_name[H.hand ? BP_L_ARM : BP_R_ARM]
		if(BP && !BP.is_usable())
			return
	var/obj/item/I = src.get_active_hand()
	if(!I)
		to_chat(src, "<span class='red'>You don't have anything in your hand to give to [M.name]</span>")
		return
	if(I.flags & (ABSTRACT | DROPDEL))
		to_chat(src, "<span class='red'>You can't give this to [name]</span>")
		return
	if(HULK in M.mutations)
		if(I.w_class < ITEM_SIZE_LARGE)
			to_chat(src, "<span class='red'>[I] is too small for [name] to hold.</span>")
			return
	if(M.get_active_hand() && M.get_inactive_hand())
		to_chat(src, "<span class='red'>[M.name]'s hands are full.</span>")
		return
	switch(alert(M,"[src] wants to give you \a [I]?",,"Yes","No"))
		if("Yes")
			if(!can_give(M) || !can_accept_gives(M))
				return
			if(QDELETED(I))
				return
			if(!Adjacent(M))
				to_chat(src, "<span class='red'>You need to stay in reaching distance while giving an object.</span>")
				to_chat(M, "<span class='red'>[src.name] moved too far away.</span>")
				return
			if(get_active_hand() != I)
				to_chat(src, "<span class='red'>You need to keep the item in your active hand.</span>")
				to_chat(M, "<span class='red'>[src.name] seem to have given up on giving \the [I.name] to you.</span>")
				return
			if(M.get_active_hand() && M.get_inactive_hand())
				to_chat(M, "<span class='red'>Your hands are full.</span>")
				to_chat(src, "<span class='red'>Their hands are full.</span>")
				return
			else
				drop_from_inventory(I)
				M.put_in_hands(I)
			I.add_fingerprint(M)
			M.visible_message("<span class='notice'>[src.name] handed \the [I.name] to [M.name].</span>")
		if("No")
			M.visible_message("<span class='red'>[src.name] tried to hand [I.name] to [M.name] but [M.name] didn't want it.</span>")

/mob/living/carbon/proc/can_give(mob/M)
	return !M.incapacitated() && !incapacitated()

/mob/living/proc/can_accept_gives(mob/giver)
  return !giver.get_active_hand() || !giver.get_inactive_hand()

/mob/living/carbon/slime/can_accept_gives(mob/giver)
  return FALSE

/mob/living/carbon/blahblahlbahl/xeno/can_accept_gives(mob/giver)
  return FALSE
