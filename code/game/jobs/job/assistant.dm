/datum/job/assistant
	title = "Test Subject"
	flag = ASSISTANT
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = -1
	spawn_positions = -1
	supervisors = "absolutely everyone"
	selection_color = "#dddddd"
	access = list(access_kitchen)			//See /datum/job/assistant/get_access()
	salary = 20
	alt_titles = list("Lawyer","Reporter","Waiter", "Paranormal Investigator")

/datum/job/assistant/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)
		return 0

	if(visualsOnly)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/fluff/jane_sidsuit(H), SLOT_W_UNIFORM)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
		return

	if (H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Lawyer")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/lawyer/bluesuit(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/lawyer/bluejacket(H), SLOT_WEAR_SUIT)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), SLOT_SHOES)
				H.equip_to_slot_or_del(new /obj/item/device/pda/lawyer2(H), SLOT_BELT)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/briefcase(H), SLOT_L_HAND)
				access = list()
			if("Mecha Operator")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/mecha_operator(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
				H.equip_to_slot_or_del(new /obj/item/clothing/gloves/fingerless(H), SLOT_GLOVES)
				access = list()
			if("Private Eye")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(H), SLOT_SHOES)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/leathercoat(H), SLOT_WEAR_SUIT)
				H.equip_to_slot_or_del(new /obj/item/weapon/lighter/zippo(H), SLOT_L_STORE)
				access = list()
			if("Vice Officer")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/vice	(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
				access = list()
			if("Reporter")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/lawyer/black(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
				H.equip_to_slot_or_del(new /obj/item/device/pda/reporter(H), SLOT_BELT)
				H.equip_to_slot_or_del(new /obj/item/device/camera(H), SLOT_L_STORE)
				access = list()
			if("Test Subject")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/fluff/jane_sidsuit(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
				access = list()
			if("Paranormal Investigator")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/fluff/indiana	(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), SLOT_SHOES)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/indiana(H), SLOT_HEAD)
				H.equip_to_slot_or_del(new /obj/item/device/occult_scanner(H), SLOT_L_STORE)
				H.equip_to_slot_or_del(new /obj/item/weapon/occult_pinpointer(H), SLOT_R_STORE)
				access = list()
			if("Waiter")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/waiter(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
				access = list(access_kitchen)
	return TRUE
