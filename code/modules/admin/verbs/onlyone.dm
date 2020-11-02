/client/proc/only_one()
	if(!SSticker)
		alert("The game hasn't started yet!")
		return

	for(var/mob/living/carbon/human/H in player_list)
		if(H.stat == DEAD || !(H.client)) continue
		if(is_special_character(H)) continue

		SSticker.mode.traitors += H.mind
		H.mind.special_role = "traitor"

		var/datum/objective/steal/steal_objective = new
		steal_objective.owner = H.mind
		steal_objective.set_target("nuclear authentication disk")
		H.mind.objectives += steal_objective

		var/datum/objective/hijack/hijack_objective = new
		hijack_objective.owner = H.mind
		H.mind.objectives += hijack_objective

		to_chat(H, "<B>You are the traitor.</B>")
		var/obj_count = 1
		for(var/datum/objective/OBJ in H.mind.objectives)
			to_chat(H, "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]")
			obj_count++

		for (var/obj/item/I in H)
			if (istype(I, /obj/item/weapon/implant))
				continue
			qdel(I)

		H.equip_to_slot_or_del(new /obj/item/clothing/under/kilt(H), SLOT_W_UNIFORM)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain(H), SLOT_L_EAR)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/beret/red(H), SLOT_HEAD)
		H.equip_to_slot_or_del(new /obj/item/weapon/claymore(H), SLOT_L_HAND)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/boots/combat(H), SLOT_SHOES)
		H.equip_to_slot_or_del(new /obj/item/weapon/pinpointer(H.loc), SLOT_L_STORE)

		var/obj/item/weapon/card/id/W = new(H)
		W.name = "[H.real_name]'s ID Card"
		W.icon_state = "centcom"
		W.access = get_all_accesses()
		W.access += get_all_centcom_access()
		W.assignment = "Highlander"
		W.registered_name = H.real_name
		H.equip_to_slot_or_del(W, SLOT_WEAR_ID)

	message_admins("<span class='notice'>[key_name_admin(usr)] used THERE CAN BE ONLY ONE!</span>")
	log_admin("[key_name(usr)] used there can be only one.")
