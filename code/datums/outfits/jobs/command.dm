// CAPTAIN OUTFIT
/datum/outfit/job/captain
	name = OUTFIT_JOB_NAME("Captain")

	uniform = /obj/item/clothing/under/rank/captain
	shoes = /obj/item/clothing/shoes/brown
	head = /obj/item/clothing/head/caphat
	glasses = /obj/item/clothing/glasses/sunglasses

	l_ear = /obj/item/device/radio/headset/heads/captain
	belt = /obj/item/weapon/melee/chainofcommand

	r_hand_back = /obj/item/weapon/storage/box/ids
	l_pocket = /obj/item/device/pda/captain
	back_style = BACKPACK_STYLE_CAPTAIN

	implants = list(
		/obj/item/weapon/implant/mind_protect/loyalty
		)

/datum/outfit/job/captain/pre_equip(mob/living/carbon/human/H)
	if(HAS_ROUND_ASPECT(ROUND_ASPECT_HF_AGENT))
		implants += /obj/item/weapon/implant/obedience


// HOP OUTFIT
/datum/outfit/job/hop
	name = OUTFIT_JOB_NAME("Head of Personnel")

	uniform = /obj/item/clothing/under/rank/head_of_personnel
	shoes = /obj/item/clothing/shoes/brown

	l_ear = /obj/item/device/radio/headset/heads/hop
	belt = /obj/item/device/pda/heads/hop

	r_hand_back = /obj/item/weapon/storage/box/ids

/datum/outfit/job/hop/pre_equip(mob/living/carbon/human/H)
	if(HAS_ROUND_ASPECT(ROUND_ASPECT_HF_AGENT))
		implants += /obj/item/weapon/implant/obedience
