/mob/living/carbon/monkey/examine(mob/user)
	set src in oview()

	if(!usr || !src)	return
	if((usr.sdisabilities & BLIND || usr.blinded || usr.stat) && !istype(usr,/mob/dead/observer))
		to_chat(usr, "<span class='notice'>Something is there but you can't see it.</span>")
		return

	var/t_He = "It"
	var/t_his = "its"
	var/t_him = "it"
	var/t_has = "has"
	var/t_is = "is"
	var/msg = "<span class='info'>*---------*\nThis is [bicon(src)] \a <EM>[src]</EM>!\n"

	if(handcuffed)
		if(istype(handcuffed, /obj/item/weapon/handcuffs/cable))
			msg += "<span class='warning'>[t_He] [t_is] [bicon(handcuffed)] restrained with cable!</span>\n"
		else
			msg += "<span class='warning'>[t_He] [t_is] [bicon(handcuffed)] handcuffed!</span>\n"

	if(legcuffed)
		msg += "<span class='warning'>[t_He] [t_has] [bicon(legcuffed)] [legcuffed.name] on [t_his] legs!</span>\n"

	if(buckled)
		msg += "<span class='warning'>[t_He] [t_is] [bicon(buckled)] buckled to [buckled]!</span>\n"

	if(wear_mask)
		if(wear_mask.dirt_overlay)
			msg += "<span class='warning'>[t_He] [t_has] [bicon(wear_mask)] [wear_mask.gender==PLURAL?"some":"a"] [wear_mask.dirt_description()] on [t_his] face!</span>\n"
		else if(wear_mask.wet)
			msg += "<span class='wet'>[t_He] [t_has] [bicon(wear_mask)] [wear_mask.gender==PLURAL?"some":"a"] wet [wear_mask.name] on [t_his] face!</span>\n"
		else
			msg += "[t_He] [t_has] [bicon(wear_mask)] \a [wear_mask] on [t_his] face.\n"

	if(l_hand)
		if(l_hand.dirt_overlay)
			msg += "<span class='warning'>[t_He] [t_is] holding [bicon(l_hand)] [l_hand.gender==PLURAL?"some":"a"] [l_hand.dirt_description()] in [t_his] left hand!</span>\n"
		else if(l_hand.wet)
			msg += "<span class='wet'>[t_He] [t_is] holding [bicon(l_hand)] [l_hand.gender==PLURAL?"some":"a"] wet [l_hand.name] in [t_his] left hand!</span>\n"
		else
			msg += "[t_He] [t_is] holding [bicon(l_hand)] \a [l_hand] in [t_his] left hand.\n"

	if(r_hand)
		if(r_hand.dirt_overlay)
			msg += "<span class='warning'>[t_He] [t_is] holding [bicon(r_hand)] [r_hand.gender==PLURAL?"some":"a"] [r_hand.dirt_description()] in [t_his] right hand!</span>\n"
		else if(r_hand.wet)
			msg += "<span class='wet'>[t_He] [t_is] holding [bicon(r_hand)] [r_hand.gender==PLURAL?"some":"a"] wet [r_hand.name] in [t_his] right hand!</span>\n"
		else
			msg += "[t_He] [t_is] holding [bicon(r_hand)] \a [r_hand] in [t_his] right hand.\n"

	if(back)
		if(back.dirt_overlay)
			msg += "<span class='warning'>[t_He] [t_has] [bicon(back)] [back.gender==PLURAL?"some":"a"] [back.dirt_description()] on [t_his] back.</span>\n"
		else if(back.wet)
			msg += "<span class='wet'>[t_He] [t_has] [bicon(back)] [back.gender==PLURAL?"some":"a"] wet [back] on [t_his] back.</span>\n"
		else
			msg += "[t_He] [t_has] [bicon(back)] \a [back] on [t_his] back.\n"

	if(stat == DEAD)
		msg += "<span class='deadsay'>[t_He] [t_is] limp and unresponsive, with no signs of life.</span>\n"

	else
		msg += "<span class='warning'>"
		if (src.getBruteLoss())
			if (src.getBruteLoss() < 30)
				msg += "[t_He] [t_has] minor bruising.\n"
			else
				msg += "<B>[t_He] [t_has] severe bruising!</B>\n"
		if (src.getFireLoss())
			if (src.getFireLoss() < 30)
				msg += "[t_He] [t_has] minor burns.\n"
			else
				msg += "<B>[t_He] [t_has] severe burns!</B>\n"
		if (src.stat == UNCONSCIOUS)
			msg += "[t_He] [t_is]n't responding to anything around [t_him]; [t_him] seems to be asleep.\n"
		msg += "</span>"

	if (src.digitalcamo)
		msg += "<span class='warning'>[t_He] [t_is] moving [t_his] body in an unnatural and blatantly unsimian manner.</span>\n"

	msg += "*---------*</span>"

	to_chat(user, msg)
	return
