// CAPTAIN OUTFIT
/datum/outfit/job/captain
	name = OUTFIT_JOB_NAME("Captain")

	uniform = /obj/item/clothing/under/rank/captain
	shoes = /obj/item/clothing/shoes/brown
	head = /obj/item/clothing/head/caphat
	glasses = /obj/item/clothing/glasses/sunglasses

	l_ear = /obj/item/device/radio/headset/heads/captain
	belt = /obj/item/device/pda/captain

	r_hand_back = /obj/item/weapon/storage/box/ids

	back_style = BACKPACK_STYLE_CAPTAIN
	
	implants = list(
		/obj/item/weapon/implant/mindshield/loyalty
		)

/datum/outfit/job/captain/pre_equip(mob/living/carbon/human/H)
	if(H.age > (H.species.min_age + H.species.max_age) / 2)
		neck = /obj/item/clothing/accessory/medal/gold/captain
// HOP OUTFIT
/datum/outfit/job/hop
	name = OUTFIT_JOB_NAME("Head of Personnel")

	uniform = /obj/item/clothing/under/rank/head_of_personnel
	shoes = /obj/item/clothing/shoes/brown

	l_ear = /obj/item/device/radio/headset/heads/hop
	belt = /obj/item/device/pda/heads/hop

	r_hand_back = /obj/item/weapon/storage/box/ids
