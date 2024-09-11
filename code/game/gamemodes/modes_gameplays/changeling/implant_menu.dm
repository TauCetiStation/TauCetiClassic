#define setup_mimicry_active_text(topic_implant) "<a href='?src=\ref[src];remove=[topic_implant]'>Stop mimicry</a>|<b>Implanted</b></br>"
#define setup_mimicry_unactive_text(topic_implant) "<b>No Implant</b>|<a href='?src=\ref[src];add=[topic_implant]'>Mimicry!</a></br>"

/obj/effect/proc_holder/changeling/implant_managment
	name = "Implant Managment"
	button_icon_state = "implant_managment"
	req_human = TRUE
	can_be_used_in_abom_form = FALSE
	genomecost = 0
	var/list/topics_trait_keys = list(
		"implant_m" = TRAIT_VISUAL_MINDSHIELD,
		"implant_l" = TRAIT_VISUAL_LOYAL,
		"implant_o" = TRAIT_VISUAL_OBEY,
		"implant_c" = TRAIT_VISUAL_CHEM,
		"implant_t" = TRAIT_VISUAL_TRACK
	)

/obj/effect/proc_holder/changeling/implant_managment/Click()
	setup_brows(usr)

/obj/effect/proc_holder/changeling/implant_managment/can_sting(mob/user)
	return TRUE

/obj/effect/proc_holder/changeling/implant_managment/sting_action(mob/user)
	setup_brows(user)

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
	if(HAS_TRAIT_FROM(H, TRAIT_VISUAL_MINDSHIELD, FAKE_IMPLANT_TRAIT))
		text += "Mind Shield Implant:[setup_mimicry_active_text("implant_m")]"
	else
		text += "Mind Shield Implant:[setup_mimicry_unactive_text("implant_m")]"
	if(HAS_TRAIT_FROM(H, TRAIT_VISUAL_LOYAL, FAKE_IMPLANT_TRAIT))
		text += "Loyalty Implant:[setup_mimicry_active_text("implant_l")]"
	else
		text += "Loyalty Implant:[setup_mimicry_unactive_text("implant_l")]"
	if(HAS_TRAIT_FROM(H, TRAIT_VISUAL_OBEY, FAKE_IMPLANT_TRAIT))
		text += "Obedience Implant:[setup_mimicry_active_text("implant_o")]"
	else
		text += "Obedience Implant:[setup_mimicry_unactive_text("implant_o")]"
	if(HAS_TRAIT_FROM(H, TRAIT_VISUAL_CHEM, FAKE_IMPLANT_TRAIT))
		text += "Chemical Implant:[setup_mimicry_active_text("implant_c")]"
	else
		text += "Chemical Implant:[setup_mimicry_unactive_text("implant_c")]"
	if(HAS_TRAIT_FROM(H, TRAIT_VISUAL_TRACK, FAKE_IMPLANT_TRAIT))
		text += "Tracking Implant:[setup_mimicry_active_text("implant_t")]"
	else
		text += "Tracking Implant:[setup_mimicry_unactive_text("implant_t")]"
	return text

/obj/effect/proc_holder/changeling/implant_managment/Topic(href, href_list)
	..()

	var/mob/M = usr
	if(!istype(M))
		return
	if(href_list["remove"])
		if(HAS_TRAIT_FROM(M, topics_trait_keys[href_list["remove"]], FAKE_IMPLANT_TRAIT))
			REMOVE_TRAIT(M, topics_trait_keys[href_list["remove"]], FAKE_IMPLANT_TRAIT)
	if(href_list["add"])
		//validation preventing double-trait adding
		if(!HAS_TRAIT_FROM(M, topics_trait_keys[href_list["add"]], FAKE_IMPLANT_TRAIT))
			ADD_TRAIT(M, topics_trait_keys[href_list["add"]], FAKE_IMPLANT_TRAIT)
	if(isliving(M))
		var/mob/living/L = M
		L.sec_hud_set_implants()
	setup_brows(M)

#undef setup_mimicry_active_text
#undef setup_mimicry_unactive_text
