/obj/effect/proc_holder/changeling/implant_managment
	name = "Implant Managment"
	req_human = TRUE
	can_be_used_in_abom_form = FALSE
	genomecost = 0

/obj/effect/proc_holder/changeling/implant_managment/Click()
	setup_brows(usr)

/obj/effect/proc_holder/changeling/implant_managment/proc/setup_brows(mob/user)
	var/dat = create_menu(user)
	var/datum/browser/popup = new(user, "window=implant_managment", "Implant Managment", 350, 200)
	popup.set_content(dat)
	popup.open()

/obj/effect/proc_holder/changeling/implant_managment/proc/create_menu(mob/user)
	var/text = ""
	if(!ishuman(user))
		text += "Not allowed in this form"
		return text
	var/mob/living/carbon/human/H = user
	if(HAS_TRAIT_FROM(H, TRAIT_MINDSHIELD, FAKE_IMPLANT_TRAIT))
		text += "Mind Shield Implant:<a href='?src=\ref[src];remove=implant_m'>Stop mimicry</a>|<b>Implanted</b></br>"
	else
		text += "Mind Shield Implant:<b>No Implant</b>|<a href='?src=\ref[src];add=implant_m'>Mimicry!</a></br>"
	if(HAS_TRAIT_FROM(H, TRAIT_LOYAL, FAKE_IMPLANT_TRAIT))
		text += "Loyalty Implant:<a href='?src=\ref[src];remove=implant_l'>Stop mimicry</a>|<b>Implanted</b></br>"
	else
		text += "Loyalty Implant:<b>No Implant</b>|<a href='?src=\ref[src];add=implant_l'>Mimicry!</a></br>"
	if(HAS_TRAIT_FROM(H, TRAIT_OBEY, FAKE_IMPLANT_TRAIT))
		text += "Obedience Implant:<a href='?src=\ref[src];remove=implant_o'>Stop mimicry</a>|<b>Implanted</b></br>"
	else
		text += "Obedience Implant:<b>No Implant</b>|<a href='?src=\ref[src];add=implant_o'>Mimicry!</a></br>"
	if(HAS_TRAIT_FROM(H, TRAIT_CHEM_IMPLANTED, FAKE_IMPLANT_TRAIT))
		text += "Chemical Implant:<a href='?src=\ref[src];remove=implant_c'>Stop mimicry</a>|<b>Implanted</b></br>"
	else
		text += "Chemical Implant:<b>No Implant</b>|<a href='?src=\ref[src];add=implant_c'>Mimicry!</a></br>"
	if(HAS_TRAIT_FROM(H, TRAIT_TRACK_IMPLANTED, FAKE_IMPLANT_TRAIT))
		text += "Tracking Implant:<a href='?src=\ref[src];remove=implant_t'>Stop mimicry</a>|<b>Implanted</b></br>"
	else
		text += "Tracking Implant:<b>No Implant</b>|<a href='?src=\ref[src];add=implant_t'>Mimicry!</a></br>"

	return text

/obj/effect/proc_holder/changeling/implant_managment/Topic(href, href_list)
	var/mob/M = usr
	if(!istype(M))
		return
	if(href_list["remove"])
		var/trait_to_remove = ""
		switch(href_list["remove"])
			if("implant_m")
				trait_to_remove = TRAIT_MINDSHIELD
			if("implant_l")
				trait_to_remove = TRAIT_LOYAL
			if("implant_o")
				trait_to_remove = TRAIT_OBEY
			if("implant_c")
				trait_to_remove = TRAIT_CHEM_IMPLANTED
			if("implant_t")
				trait_to_remove = TRAIT_TRACK_IMPLANTED
		if(trait_to_remove)
			REMOVE_TRAIT(M, trait_to_remove, FAKE_IMPLANT_TRAIT)
	if(href_list["add"])
		var/trait_to_add = ""
		switch(href_list["add"])
			if("implant_m")
				trait_to_add = TRAIT_MINDSHIELD
			if("implant_l")
				trait_to_add = TRAIT_LOYAL
			if("implant_o")
				trait_to_add = TRAIT_OBEY
			if("implant_c")
				trait_to_add = TRAIT_CHEM_IMPLANTED
			if("implant_t")
				trait_to_add = TRAIT_TRACK_IMPLANTED
		if(trait_to_add)
			ADD_TRAIT(M, trait_to_add, FAKE_IMPLANT_TRAIT)
	if(isliving(M))
		var/mob/living/L = M
		L.sec_hud_set_implants()
	setup_brows(M)
