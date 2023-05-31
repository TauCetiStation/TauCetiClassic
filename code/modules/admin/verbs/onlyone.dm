/client/proc/only_one()
	if(!SSticker)
		tgui_alert(usr, "The game hasn't started yet!")
		return

	for(var/mob/living/carbon/human/H in player_list)
		if(H.stat == DEAD || !(H.client)) continue
		if(is_special_character(H)) continue

		create_and_setup_role(/datum/role/traitor/syndbeacon, H)

		for (var/obj/item/I in H)
			if (istype(I, /obj/item/weapon/implant))
				continue
			qdel(I)
		H.sec_hud_set_implants()

		H.equip_to_slot_or_del(new /obj/item/clothing/under/kilt(H), SLOT_W_UNIFORM)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain(H), SLOT_L_EAR)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/beret/red(H), SLOT_HEAD)
		H.equip_to_slot_or_del(new /obj/item/weapon/claymore(H), SLOT_L_HAND)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/boots/combat(H), SLOT_SHOES)
		H.equip_to_slot_or_del(new /obj/item/weapon/pinpointer(H.loc), SLOT_L_STORE)

		var/obj/item/weapon/card/id/W = new(H)
		W.assign(H.real_name)
		W.icon_state = "centcom"
		W.access = get_all_accesses()
		W.access += get_all_centcom_access()
		W.assignment = "Highlander"
		H.equip_to_slot_or_del(W, SLOT_WEAR_ID)

	message_admins("<span class='notice'>[key_name_admin(usr)] used THERE CAN BE ONLY ONE!</span>")
	log_admin("[key_name(usr)] used there can be only one.")
