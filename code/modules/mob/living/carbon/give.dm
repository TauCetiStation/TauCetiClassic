/mob/living/carbon/verb/give(mob/living/carbon/target in oview(1))
	set category = "IC"
	set name = "Give"


	if(!iscarbon(target)) //something is bypassing the give arguments, no clue what, adding a sanity check JIC
		to_chat(usr, "<span class='danger'>Wait a second... \the [target] HAS NO HANDS! AHH!</span>")//cheesy messages ftw
		return

	if(target.stat == DEAD || usr.incapacitated() || target.client == null)
		return
	if(isxeno(target) || isslime(target))
		to_chat(usr, "<span class='red'>I feel stupider, suddenly.</span>")
		return
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/BP = H.bodyparts_by_name[H.hand ? BP_L_ARM : BP_R_ARM]
		if(BP && !BP.is_usable())
			return
	var/obj/item/I = usr.get_active_hand()
	if(!I)
		to_chat(usr, "<span class='red'>You don't have anything in your hand to give to [target.name]</span>")
		return
	if(I.flags & (ABSTRACT | DROPDEL))
		to_chat(usr, "<span class='red'>You can't give this to [name]</span>")
		return
	if(HULK in target.mutations)
		if(I.w_class < ITEM_SIZE_LARGE)
			to_chat(usr, "<span class='red'>[I] is too small for [name] to hold.</span>")
			return
	if(!target.get_active_hand() || !target.get_inactive_hand())
		switch(alert(target,"[usr] wants to give you \a [I]?",,"Yes","No"))
			if("Yes")
				if(!I)
					return
				if(!Adjacent(usr))
					to_chat(usr, "<span class='red'>You need to stay in reaching distance while giving an object.</span>")
					to_chat(target, "<span class='red'>[usr.name] moved too far away.</span>")
					return
				if(usr.get_active_hand() != I)
					to_chat(usr, "<span class='red'>You need to keep the item in your active hand.</span>")
					to_chat(target, "<span class='red'>[usr.name] seem to have given up on giving \the [I.name] to you.</span>")
					return
				if(target.get_active_hand() && target.get_inactive_hand())
					to_chat(target, "<span class='red'>Your hands are full.</span>")
					to_chat(usr, "<span class='red'>Their hands are full.</span>")
					return
				else
					usr.drop_item()
					target.put_in_hands(I)
				I.add_fingerprint(target)
				target.visible_message("<span class='notice'>[usr.name] handed \the [I.name] to [target.name].</span>")
			if("No")
				target.visible_message("<span class='red'>[usr.name] tried to hand [I.name] to [target.name] but [target.name] didn't want it.</span>")
	else
		to_chat(usr, "<span class='red'>[target.name]'s hands are full.</span>")
