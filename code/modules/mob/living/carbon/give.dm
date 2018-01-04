/mob/living/carbon/verb/give()
	set category = "IC"
	set name = "Give"
	set src in view(1)

	if(src.stat == DEAD || usr.stat == DEAD || src.client == null)
		return
	if(src == usr || isalien(src) || isslime(src))
		to_chat(usr, "<span class='red'>I feel stupider, suddenly.</span>")
		return
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		var/obj/item/organ/external/BP = H.bodyparts_by_name[H.hand ? BP_L_ARM : BP_R_ARM]
		if(BP && !BP.is_usable())
			return
	var/obj/item/I = usr.get_active_hand()
	if(!I)
		to_chat(usr, "<span class='red'>You don't have anything in your hand to give to [src.name]</span>")
		return
	if(I.flags & (ABSTRACT | DROPDEL))
		to_chat(usr, "<span class='red'>You can't give this to [name]</span>")
		return
	if(!src.get_active_hand() || !src.get_inactive_hand())
		switch(alert(src,"[usr] wants to give you \a [I]?",,"Yes","No"))
			if("Yes")
				if(!I)
					return
				if(!Adjacent(usr))
					to_chat(usr, "<span class='red'>You need to stay in reaching distance while giving an object.</span>")
					to_chat(src, "<span class='red'>[usr.name] moved too far away.</span>")
					return
				if(usr.get_active_hand() != I)
					to_chat(usr, "<span class='red'>You need to keep the item in your active hand.</span>")
					to_chat(src, "<span class='red'>[usr.name] seem to have given up on giving \the [I.name] to you.</span>")
					return
				if(src.get_active_hand() && src.get_inactive_hand())
					to_chat(src, "<span class='red'>Your hands are full.</span>")
					to_chat(usr, "<span class='red'>Their hands are full.</span>")
					return
				else
					usr.drop_item()
					src.put_in_hands(I)
				I.add_fingerprint(src)
				src.visible_message("<span class='notice'>[usr.name] handed \the [I.name] to [src.name].</span>")
			if("No")
				src.visible_message("<span class='red'>[usr.name] tried to hand [I.name] to [src.name] but [src.name] didn't want it.</span>")
	else
		to_chat(usr, "<span class='red'>[src.name]'s hands are full.</span>")
