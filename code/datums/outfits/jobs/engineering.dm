// CHIEF_ENGINEER OUTFIT
/datum/outfit/job/chief_engineer
	name = OUTFIT_JOB_NAME("Chief Engineer")

	uniform = /obj/item/clothing/under/rank/chief_engineer
	shoes = /obj/item/clothing/shoes/boots/work
	head = /obj/item/clothing/head/hardhat/white
	belt = /obj/item/weapon/storage/belt/utility/full
	gloves = /obj/item/clothing/gloves/black
	l_ear = /obj/item/device/radio/headset/heads/ce

	l_pocket = /obj/item/device/pda/heads/ce

	list/back_style = BACKPACK_STYLE_ENGINEERING

// ENGINEER OUTFIT
/datum/outfit/job/engineer
	name = OUTFIT_JOB_NAME("Station Engineer")

	uniform = /obj/item/clothing/under/rank/engineer
	shoes = /obj/item/clothing/shoes/boots/work
	belt = /obj/item/weapon/storage/belt/utility/full
	head = /obj/item/clothing/head/hardhat/yellow
	l_ear = /obj/item/device/radio/headset/headset_eng

	l_pocket = /obj/item/device/pda/engineering
	r_pocket = /obj/item/device/t_scanner

	list/back_style = BACKPACK_STYLE_ENGINEERING

/datum/outfit/job/engineer/pre_equip()
	if(prob(75))
		head = /obj/item/clothing/head/hardhat/yellow
	else
		head = /obj/item/clothing/head/hardhat/yellow/visor

// ATMOS OUTFIT
/datum/outfit/job/atmos
	name = OUTFIT_JOB_NAME("Atmospheric Technician")

	uniform = /obj/item/clothing/under/rank/atmospheric_technician
	shoes = /obj/item/clothing/shoes/boots/work
	belt = /obj/item/weapon/storage/belt/utility/atmostech/
	l_ear = /obj/item/device/radio/headset/headset_eng

	l_pocket = /obj/item/device/pda/atmos

	list/back_style = BACKPACK_STYLE_ENGINEERING

// TECHNICAL_ASSISTANT OUTFIT
/datum/outfit/job/technical_assistant
	name = OUTFIT_JOB_NAME("Technical Assistant")

	uniform = /obj/item/clothing/under/color/yellow
	shoes = /obj/item/clothing/shoes/yellow
	belt = /obj/item/device/pda
	l_ear = /obj/item/device/radio/headset/headset_eng

	list/back_style = BACKPACK_STYLE_ENGINEERING
