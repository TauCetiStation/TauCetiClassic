/mob/living/carbon/slime/examine(mob/user)
	var/msg = "<span class='info'>*---------*\nThis is [bicon(src)] \a <EM>[src]</EM>!\n"
	if (src.stat == DEAD)
		msg += "<span class='deadsay'>Он размяк и не реагирует.</span>\n"
	else
		if (getBruteLoss())
			msg += "<span class='warning'>"
			if (getBruteLoss() < 40)
				msg += "У него видно несколько дыр."
			else
				msg += "<B>У него серьезные проколы и разрывы в теле.</B>"
			msg += "</span>\n"

		switch(powerlevel)
			if(2 to 3)
				msg += "Он слабо мерцает.\n"
			if(4 to 5)
				msg += "Он слабо светится.\n"
			if(6 to 9)
				msg += "<span class='warning'>Он ярко светится.</span>\n"
			if(10)
				msg += "<span class='warning'><B>Он горит очень ярким светом!</B></span>\n"

	if(w_class)
		msg += "It is a [get_size_flavor()] sized creature.\n"

	msg += "*---------*</span>"
	to_chat(user, msg)
