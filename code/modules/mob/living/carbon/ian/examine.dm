/mob/living/carbon/ian/examine(mob/user)
	var/skipface = FALSE

	if(head)
		skipface = head.flags_inv & HIDEFACE

	var/t_He = "It"
	var/t_his = "its"
	var/t_him = "it"
	var/t_has = "has"
	var/t_is = "is"

	var/msg = "<span class='info'>*---------*\nThis is "

	if(skipface)
		t_He = "They"
		t_his = "their"
		t_him = "them"
		t_has = "have"
		t_is = "are"
	else
		t_He = "He"
		t_his = "his"
		t_him = "him"

	msg += "<EM>[src.name]</EM>!\n"

	//head
	if(head)
		if(head.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_is] wearing [bicon(head)] [head.gender==PLURAL?"some":"a"] [head.dirt_description()] on [t_his] head!</span>\n"
		else if(head.wet)
			msg += "<span class='wet'>[t_He] [t_is] wearing [bicon(head)] [head.gender==PLURAL?"some":"a"] wet [head.name] on [t_his] head!</span>\n"
		else
			msg += "[t_He] [t_is] wearing [bicon(head)] \a [head] on [t_his] head.\n"

	//back
	if(back)
		if(back.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_has] [bicon(back)] [back.gender==PLURAL?"some":"a"] [back.dirt_description()] on [t_his] back.</span>\n"
		else if(back.wet)
			msg += "<span class='wet'>[t_He] [t_has] [bicon(back)] [back.gender==PLURAL?"some":"a"] wet [back] on [t_his] back.</span>\n"
		else
			msg += "[t_He] [t_has] [bicon(back)] \a [back] on [t_his] back.\n"

	//hand (err.. mouth!)
	if(!skipface && mouth && !(mouth.flags&ABSTRACT)) // Yesh, hide hand if face is obscured. Err, i mean mouth!
		if(mouth.blood_DNA)
			msg += "<span class='warning'>[t_He] [t_is] holding [bicon(mouth)] [mouth.gender==PLURAL?"some":"a"] [mouth.dirt_description()] in [t_his] mouth!</span>\n"
		else if(mouth.wet)
			msg += "<span class='wet'>[t_He] [t_is] holding [bicon(mouth)] [mouth.gender==PLURAL?"some":"a"] wet [mouth.name] in [t_his] mouth!</span>\n"
		else
			msg += "[t_He] [t_is] holding [bicon(mouth)] \a [mouth] in [t_his] mouth.\n"

	//handcuffed?
	if(handcuffed)
		if(istype(handcuffed, /obj/item/weapon/handcuffs/cable))
			msg += "<span class='warning'>[t_He] [t_is] [bicon(handcuffed)] restrained with cable!</span>\n"
		else
			msg += "<span class='warning'>[t_He] [t_is] [bicon(handcuffed)] handcuffed!</span>\n"

	//buckled
	if(buckled)
		msg += "<span class='warning'>[t_He] [t_is] [bicon(buckled)] buckled to [buckled]!</span>\n"

	//ID
	if(neck)
		msg += "[t_He] [t_is] wearing [bicon(neck)] \a [neck] on [t_his] neck.\n"

	var/distance = get_dist(user,src)
	if(isobserver(user) || user.stat == DEAD) // ghosts can see anything
		distance = 1

	if(stat == DEAD)
		if(distance <= 3)
			msg += "<span class='warning'>[t_He] does not appear to be breathing.</span>\n"
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
		if(fire_stacks > 0)
			msg += "[t_He] [t_is] covered in something flammable.\n"
		if(fire_stacks < 0)
			msg += "[t_He] look[t_is] a little soaked.\n"
		if (stat)
			msg += "[t_He] [t_is]n't responding to anything around [t_him] and seems to be asleep.\n"
		msg += "</span>"

	if(ishuman(user) && !user.stat && distance <= 1)
		visible_message("[user] checks [src]'s pulse.")
		spawn(15)
			if(distance <= 1 && user && user.stat != UNCONSCIOUS)
				if(stat == DEAD)
					to_chat(user, "<span class='deadsay'>[t_He] has no pulse[src.client ? "" : " and [t_his] soul has departed"]...</span>")
				else
					to_chat(user, "<span class='deadsay'>[t_He] has a pulse!</span>")

	msg += "*---------*</span>"

	to_chat(user, msg)
