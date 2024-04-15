// ASSISTANT OUTFIT
/datum/outfit/job/assistant
	name = OUTFIT_JOB_NAME("Assistant Gear")

	uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/black

/datum/outfit/job/assistant/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(SSholiday.holidays[APRIL_FOOLS])
		H.equip_or_collect(new /obj/item/toy/balloon/arrest(H), SLOT_IN_BACKPACK)

/datum/outfit/job/assistant/lawyer
	name = OUTFIT_JOB_NAME("Lawyer")

	uniform = /obj/item/clothing/under/lawyer/bluesuit
	suit = /obj/item/clothing/suit/storage/lawyer/bluejacket
	shoes = /obj/item/clothing/shoes/brown
	belt = /obj/item/device/pda/lawyer2
	l_hand = /obj/item/weapon/storage/briefcase

/datum/outfit/job/assistant/private_eye
	name = OUTFIT_JOB_NAME("Private Eye")

	uniform = /obj/item/clothing/under/color/black
	shoes = /obj/item/clothing/shoes/boots
	suit = /obj/item/clothing/suit/leathercoat
	l_pocket = /obj/item/weapon/lighter/zippo

/datum/outfit/job/assistant/reporter
	name = OUTFIT_JOB_NAME("Reporter")

	uniform = /obj/item/clothing/under/lawyer/black
	shoes = /obj/item/clothing/shoes/black
	belt = /obj/item/device/pda/reporter
	l_pocket = /obj/item/device/camera/polar

/datum/outfit/job/assistant/test_subject
	name = OUTFIT_JOB_NAME("Test Subject")

	uniform = /obj/item/clothing/under/test_subject
	shoes = /obj/item/clothing/shoes/black

/datum/outfit/job/assistant/waiter
	name = OUTFIT_JOB_NAME("Waiter")

	uniform = /obj/item/clothing/under/waiter
	shoes = /obj/item/clothing/shoes/black

/datum/outfit/job/assistant/vice_officer
	name = OUTFIT_JOB_NAME("Vice Officer")

	uniform = /obj/item/clothing/under/rank/vice
	shoes = /obj/item/clothing/shoes/black

/datum/outfit/job/assistant/paranormal_investigator
	name = OUTFIT_JOB_NAME("Paranormal Investigator")

	uniform = /obj/item/clothing/under/indiana
	shoes = /obj/item/clothing/shoes/brown
	head = /obj/item/clothing/head/indiana
	l_pocket = /obj/item/device/occult_scanner
	r_pocket = /obj/item/weapon/occult_pinpointer
