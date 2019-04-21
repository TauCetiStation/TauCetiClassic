/datum/job/assistant
	title = "Test Subject"
	flag = ASSISTANT
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = -1
	spawn_positions = -1
	supervisors = "absolutely everyone"
	selection_color = "#dddddd"
	access = list()			//See /datum/job/assistant/get_access()
	alt_titles = list("Technical Assistant","Medical Intern","Research Assistant","Security Cadet",
	"Lawyer","Mecha Operator","Private Eye","Reporter","Security Cadet","Waiter","Vice Officer","Paranormal Investigator")

/datum/job/assistant/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)
		return 0

	if(visualsOnly)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/fluff/jane_sidsuit(H), SLOT_W_UNIFORM)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
		return

	if (H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Technical Assistant")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/color/yellow(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/yellow(H), SLOT_SHOES)
			if("Medical Intern")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/lightblue(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/blue(H), SLOT_SHOES)
			if("Research Assistant")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/scientist_new(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), SLOT_SHOES)
			if("Lawyer")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/lawyer/bluesuit(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/lawyer/bluejacket(H), SLOT_WEAR_SUIT)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), SLOT_SHOES)
				H.equip_to_slot_or_del(new /obj/item/device/pda/lawyer2(H), SLOT_BELT)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/briefcase(H), SLOT_L_HAND)
			if("Mecha Operator")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/mecha_operator(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
				H.equip_to_slot_or_del(new /obj/item/clothing/gloves/fingerless(H), SLOT_GLOVES)
			if("Private Eye")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(H), SLOT_SHOES)
				H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), SLOT_GLOVES)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/leathercoat(H), SLOT_WEAR_SUIT)
				H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(H), SLOT_GLASSES)
				H.equip_to_slot_or_del(new /obj/item/weapon/lighter/zippo(H), SLOT_L_STORE)
			if("Reporter")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/lawyer/black(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
				H.equip_to_slot_or_del(new /obj/item/device/pda/reporter(H), SLOT_BELT)
			if("Security Cadet")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/cadet(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(H), SLOT_SHOES)
			if("Test Subject")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/fluff/jane_sidsuit(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
			if("Waiter")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/waiter(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
			if("Vice Officer")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/vice	(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
			if("Paranormal Investigator")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/fluff/indiana	(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), SLOT_SHOES)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/indiana(H), SLOT_HEAD)
				H.equip_to_slot_or_del(new /obj/item/device/occult_scanner(H), SLOT_L_STORE)
				H.equip_to_slot_or_del(new /obj/item/weapon/occult_pinpointer(H), SLOT_R_STORE)

	return TRUE

/datum/job/assistant/get_access()
	if(config.assistant_maint)
		return list(access_maint_tunnels)
	else
		return list()
