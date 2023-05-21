/mob/living/carbon/slime/examine(mob/user)
	var/msg = "<span class='info'>*---------*\nThis is [bicon(src)] \a <EM>[src]</EM>!\n"
	if (src.stat == DEAD)
		msg += "<span class='deadsay'>Оно вялое и не реагирует.</span>\n"
	else
		if (getBruteLoss())
			msg += "<span class='warning'>"
			if (getBruteLoss() < 40)
				msg += "Видно несколько дыр."
			else
				msg += "<B>У него серьезные проколы и разрывы в его теле.</B>"
			msg += "</span>\n"

		switch(powerlevel)
			if(2 to 3)
				msg += "Слабо мерцает.\n"
			if(4 to 5)
				msg += "Слабо светится.\n"
			if(6 to 9)
				msg += "<span class='warning'>Ярко светится.</span>\n"
			if(10)
				msg += "<span class='warning'><B>Горит очень ярким светом!</B></span>\n"

	if(w_class)
		msg += "It is a [get_size_flavor()] sized creature.\n"

	msg += "*---------*</span>"
	to_chat(user, msg)
