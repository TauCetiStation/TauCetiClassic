#define setup_mimicry_active_text(topic_implant) "<a href='byond://?src=\ref[src];remove=[topic_implant]'>Stop mimicry</a>|<b>Implanted</b></br>"
#define setup_mimicry_unactive_text(topic_implant) "<b>No Implant</b>|<a href='byond://?src=\ref[src];add=[topic_implant]'>Mimicry!</a></br>"

/obj/effect/proc_holder/changeling/implant_managment
	name = "Implant Managment"
	button_icon_state = "implant_managment"
	req_human = TRUE
	can_be_used_in_abom_form = FALSE
	genomecost = 0

	var/list/fake_implant_keys = list(
		"implant_m" = /obj/item/weapon/implant/fake/mindshield,
		"implant_l" = /obj/item/weapon/implant/fake/loyalty,
		"implant_o" = /obj/item/weapon/implant/fake/obedience,
		"implant_c" = /obj/item/weapon/implant/fake/chem,
		"implant_t" = /obj/item/weapon/implant/fake/tracking,
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
	if(locate(/obj/item/weapon/implant/fake/mindshield) in H.implants)
		text += "Mind Shield Implant:[setup_mimicry_active_text("implant_m")]"
	else
		text += "Mind Shield Implant:[setup_mimicry_unactive_text("implant_m")]"
	if(locate(/obj/item/weapon/implant/fake/loyalty) in H.implants)
		text += "Loyalty Implant:[setup_mimicry_active_text("implant_l")]"
	else
		text += "Loyalty Implant:[setup_mimicry_unactive_text("implant_l")]"
	if(locate(/obj/item/weapon/implant/fake/obedience) in H.implants)
		text += "Obedience Implant:[setup_mimicry_active_text("implant_o")]"
	else
		text += "Obedience Implant:[setup_mimicry_unactive_text("implant_o")]"
	if(locate(/obj/item/weapon/implant/fake/chem) in H.implants)
		text += "Chemical Implant:[setup_mimicry_active_text("implant_c")]"
	else
		text += "Chemical Implant:[setup_mimicry_unactive_text("implant_c")]"
	if(locate(/obj/item/weapon/implant/fake/tracking) in H.implants)
		text += "Tracking Implant:[setup_mimicry_active_text("implant_t")]"
	else
		text += "Tracking Implant:[setup_mimicry_unactive_text("implant_t")]"
	return text

/obj/effect/proc_holder/changeling/implant_managment/Topic(href, href_list)
	..()

	var/mob/living/L = usr
	if(!istype(L))
		return
	if(href_list["remove"])
		var/type = fake_implant_keys[href_list["remove"]]
		for(var/obj/item/weapon/implant/I as anything in L.implants)
			if(istype(I, type))
				qdel(I)
	if(href_list["add"])
		var/type = fake_implant_keys[href_list["add"]]
		//validation preventing double-trait adding
		if(locate(type) in L.implants)
			return
		new type(L)

	setup_brows(L)

#undef setup_mimicry_active_text
#undef setup_mimicry_unactive_text
