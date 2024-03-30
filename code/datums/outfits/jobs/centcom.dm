
// LAWYER OUTFIT
/datum/outfit/job/lawyer
	name = OUTFIT_JOB_NAME("Internal Affairs Agent")

	uniform = /obj/item/clothing/under/rank/internalaffairs
	shoes = /obj/item/clothing/shoes/black
	suit = /obj/item/clothing/suit/storage/internalaffairs
	glasses = /obj/item/clothing/glasses/sunglasses/big

	l_ear = /obj/item/device/radio/headset/headset_int
	belt = /obj/item/device/pda/lawyer

	l_hand = /obj/item/weapon/storage/briefcase/centcomm

	l_pocket = /obj/item/device/flash

	implants = list(
		/obj/item/weapon/implant/mind_protect/loyalty
		)

/datum/outfit/job/lawyer/pre_equip(mob/living/carbon/human/H)
	if(HAS_ROUND_ASPECT(ROUND_ASPECT_HF_AGENT))
		r_hand = /obj/item/weapon/melee/chainofcommand

// BLUESHIELD OUTFIT
/datum/outfit/job/blueshield
	name = OUTFIT_JOB_NAME("Blueshield Officer")

	uniform = /obj/item/clothing/under/rank/blueshield
	shoes = /obj/item/clothing/shoes/boots
	glasses = /obj/item/clothing/glasses/sunglasses/hud/sechud/tactical

	l_ear = /obj/item/device/radio/headset/headset_int/blueshield
	belt = /obj/item/device/pda/blueshield

	r_pocket = /obj/item/device/flash
	r_pocket_back = /obj/item/weapon/handcuffs
	l_pocket = /obj/item/weapon/pinpointer/heads

	implants = list(
		/obj/item/weapon/implant/mind_protect/loyalty, /obj/item/weapon/implant/blueshield)
