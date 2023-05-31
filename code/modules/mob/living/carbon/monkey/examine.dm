/mob/living/carbon/monkey/examine()
	set src in oview()

	if(!usr || !src)	return
	if( (usr.sdisabilities & BLIND || usr.blinded || usr.stat != CONSCIOUS) && !isobserver(usr) )
		to_chat(usr, "<span class='notice'>Something is there but you can't see it.</span>")
		return

	var/msg = "<span class='info'>*---------*\nThis is [bicon(src)] \a <EM>[src]</EM>!\n"

	if (src.handcuffed)
		msg += "It is [bicon(src.handcuffed)] handcuffed!\n"
	if (src.wear_mask)
		msg += "It has [bicon(src.wear_mask)] \a [src.wear_mask] on its head.\n"
	if (src.l_hand)
		msg += "It has [bicon(src.l_hand)] \a [src.l_hand] in its left hand.\n"
	if (src.r_hand)
		msg += "It has [bicon(src.r_hand)] \a [src.r_hand] in its right hand.\n"
	if (src.back)
		msg += "It has [bicon(src.back)] \a [src.back] on its back.\n"
	if (src.stat == DEAD)
		msg += "<span class='deadsay'>It is limp and unresponsive, with no signs of life.</span>\n"
	else
		msg += "<span class='warning'>"
		if (getBruteLoss())
			if (getBruteLoss() < 30)
				msg += "It has minor bruising.\n"
			else
				msg += "<B>It has severe bruising!</B>\n"
		if (getFireLoss())
			if (getFireLoss() < 30)
				msg += "It has minor burns.\n"
			else
				msg += "<B>It has severe burns!</B>\n"
		if (src.stat == UNCONSCIOUS)
			msg += "It isn't responding to anything around it; it seems to be asleep.\n"
		msg += "</span>"

	if(w_class)
		msg += "It is a [get_size_flavor()] sized creature.\n"

	msg += "*---------*</span>"

	to_chat(usr, msg)
	return
