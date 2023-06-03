/obj/effect/proc_holder/changeling/implant_managment
	name = "Implant Managment"
	req_human = TRUE
	can_be_used_in_abom_form = FALSE
	genomecost = 0
	var/list/topics_trait_keys = list(
		"implant_m" = TRAIT_MINDSHIELD,
		"implant_l" = TRAIT_LOYAL,
		"implant_o" = TRAIT_OBEY,
		"implant_c" = TRAIT_CHEM_IMPLANTED,
		"implant_t" = TRAIT_TRACK_IMPLANTED
	)

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
	var/enabled_mindshield = HAS_TRAIT_FROM(H, TRAIT_MINDSHIELD, FAKE_IMPLANT_TRAIT)
	var/enabled_loyal = HAS_TRAIT_FROM(H, TRAIT_LOYAL, FAKE_IMPLANT_TRAIT)
	var/enabled_obey = HAS_TRAIT_FROM(H, TRAIT_OBEY, FAKE_IMPLANT_TRAIT)
	var/enabled_chem = HAS_TRAIT_FROM(H, TRAIT_CHEM_IMPLANTED, FAKE_IMPLANT_TRAIT)
	var/enabled_track = HAS_TRAIT_FROM(H, TRAIT_TRACK_IMPLANTED, FAKE_IMPLANT_TRAIT)
	text += get_implant_text(enabled_mindshield, enabled_loyal, enabled_obey, enabled_chem, enabled_track)
	return text

/obj/effect/proc_holder/changeling/implant_managment/Topic(href, href_list)
	var/mob/M = usr
	if(!istype(M))
		return
	if(href_list["remove"])
		REMOVE_TRAIT(M, topics_trait_keys[href_list["remove"]], FAKE_IMPLANT_TRAIT)
	if(href_list["add"])
		ADD_TRAIT(M, topics_trait_keys[href_list["add"]], FAKE_IMPLANT_TRAIT)
	if(isliving(M))
		var/mob/living/L = M
		L.sec_hud_set_implants()
	setup_brows(M)

/obj/effect/proc_holder/changeling/implant_managment/proc/get_implant_text(mindshield_arg, loyal_arg, obey_arg, chem_arg, track_arg)
	var/out = ""
	if(mindshield_arg)
		out += "Mind Shield Implant:[setup_mimicry_active_text("implant_m")]"
	else
		out += "Mind Shield Implant:[setup_mimicry_unactive_text("implant_m")]"
	if(loyal_arg)
		out += "Loyalty Implant:[setup_mimicry_active_text("implant_l")]"
	else
		out += "Loyalty Implant:[setup_mimicry_unactive_text("implant_l")]"
	if(obey_arg)
		out += "Obedience Implant:[setup_mimicry_active_text("implant_o")]"
	else
		out += "Obedience Implant:[setup_mimicry_unactive_text("implant_o")]"
	if(chem_arg)
		out += "Chemical Implant:[setup_mimicry_active_text("implant_c")]"
	else
		out += "Chemical Implant:[setup_mimicry_unactive_text("implant_c")]"
	if(track_arg)
		out += "Tracking Implant:[setup_mimicry_active_text("implant_t")]"
	else
		out += "Tracking Implant:[setup_mimicry_unactive_text("implant_t")]"
	return out

/obj/effect/proc_holder/changeling/implant_managment/proc/setup_mimicry_active_text(topic_implant)
	return "<a href='?src=\ref[src];remove=[topic_implant]'>Stop mimicry</a>|<b>Implanted</b></br>"

/obj/effect/proc_holder/changeling/implant_managment/proc/setup_mimicry_unactive_text(topic_implant)
	return "<b>No Implant</b>|<a href='?src=\ref[src];add=[topic_implant]'>Mimicry!</a></br>"
