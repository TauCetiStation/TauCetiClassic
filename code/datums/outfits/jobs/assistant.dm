// ASSISTANT OUTFIT
/datum/outfit/job/assistant
	name = OUTFIT_JOB_NAME("Test Subject")

	uniform = /obj/item/clothing/under/fluff/jane_sidsuit
	shoes = /obj/item/clothing/shoes/black

	back_style = BACKPACK_STYLE_COMMON

/datum/outfit/job/assistant/pre_equip(mob/living/carbon/human/H)
	if (H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Lawyer")
				uniform = /obj/item/clothing/under/lawyer/bluesuit
				suit = /obj/item/clothing/suit/storage/lawyer/bluejacket
				shoes = /obj/item/clothing/shoes/brown
				belt = /obj/item/device/pda/lawyer2
				l_hand = /obj/item/weapon/storage/briefcase
			if("Mecha Operator")
				uniform = /obj/item/clothing/under/rank/mecha_operator
				shoes = /obj/item/clothing/shoes/black
				gloves = /obj/item/clothing/gloves/fingerless
			if("Private Eye")
				uniform = /obj/item/clothing/under/color/black
				shoes = /obj/item/clothing/shoes/boots
				suit = /obj/item/clothing/suit/leathercoat
				l_pocket = /obj/item/weapon/lighter/zippo
			if("Reporter")
				uniform = /obj/item/clothing/under/lawyer/black
				shoes = /obj/item/clothing/shoes/black
				belt = /obj/item/device/pda/reporter
				l_pocket = /obj/item/device/camera
			if("Security Cadet")
				uniform = /obj/item/clothing/under/rank/cadet
				shoes = /obj/item/clothing/shoes/boots
			if("Test Subject")
				uniform = /obj/item/clothing/under/fluff/jane_sidsuit
				shoes = /obj/item/clothing/shoes/black
			if("Waiter")
				uniform = /obj/item/clothing/under/waiter
				shoes = /obj/item/clothing/shoes/black
			if("Vice Officer")
				uniform = /obj/item/clothing/under/rank/vice
				shoes = /obj/item/clothing/shoes/black
			if("Paranormal Investigator")
				uniform = /obj/item/clothing/under/fluff/indiana
				shoes = /obj/item/clothing/shoes/brown
				head = /obj/item/clothing/head/indiana
				l_pocket = /obj/item/device/occult_scanner
				r_pocket = /obj/item/weapon/occult_pinpointer
