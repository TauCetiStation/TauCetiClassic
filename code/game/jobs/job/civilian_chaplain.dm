//Due to how large this one is it gets its own file
/datum/job/chaplain
	title = "Chaplain"
	flag = CHAPLAIN
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/civ
	access = list(access_morgue, access_chapel_office, access_crematorium)
	alt_titles = list("Counselor")
	minimal_player_ingame_minutes = 480

/datum/job/chaplain/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)
		return FALSE
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chaplain(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)

	if(visualsOnly)
		return

	INVOKE_ASYNC(global.chaplain_religion, /datum/religion/chaplain.proc/create_by_chaplain, H)

	H.equip_to_slot_or_del(new /obj/item/device/pda/chaplain(H), SLOT_BELT)
	return TRUE
