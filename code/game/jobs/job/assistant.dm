/datum/job/assistant
	title = "Test Subject"
	flag = ASSISTANT
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = -1
	spawn_positions = -1
	supervisors = "absolutely everyone"
	selection_color = "#dddddd"

/datum/job/assistant/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)
		return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/under/fluff/jane_sidsuit(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)

	if(visualsOnly)
		return

	var/obj/item/weapon/implant/explosive/E = new(H)
	E.inject(H)

	return TRUE

