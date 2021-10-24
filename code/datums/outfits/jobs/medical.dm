// Chief Medical Officer OUTFIT
/datum/outfit/job/cmo
	name = OUTFIT_JOB_NAME("Chief Medical Officer")

	uniform = /obj/item/clothing/under/rank/chief_medical_officer
	uniform_f = /obj/item/clothing/under/rank/chief_medical_officer/skirt
	shoes = /obj/item/clothing/shoes/brown
	suit = /obj/item/clothing/suit/storage/labcoat/cmo

	belt = /obj/item/device/pda/heads/cmo
	l_ear = /obj/item/device/radio/headset/heads/cmo

	l_hand = /obj/item/weapon/storage/firstaid/adv
	suit_store = /obj/item/device/flashlight/pen

	back_style = BACKPACK_STYLE_MEDICAL

// DOCTOR OUTFIT
/datum/outfit/job/doctor
	name = OUTFIT_JOB_NAME("Medical Doctor")

	uniform = /obj/item/clothing/under/rank/medical
	uniform_f =/obj/item/clothing/under/rank/medical/skirt
	shoes = /obj/item/clothing/shoes/white
	suit = /obj/item/clothing/suit/storage/labcoat

	belt = /obj/item/device/pda/medical
	l_ear = /obj/item/device/radio/headset/headset_med

	l_hand = /obj/item/weapon/storage/firstaid/adv
	suit_store = /obj/item/device/flashlight/pen

	back_style = BACKPACK_STYLE_MEDICAL


// SURGEON OUTFIT
/datum/outfit/job/surgeon
	name = OUTFIT_JOB_NAME("Surgeon")

	uniform = /obj/item/clothing/under/rank/medical/blue
	shoes = /obj/item/clothing/shoes/white
	suit = /obj/item/clothing/suit/storage/labcoat
	head = /obj/item/clothing/head/surgery/blue

	belt = /obj/item/device/pda/medical
	l_ear = /obj/item/device/radio/headset/headset_med

	l_hand = /obj/item/weapon/storage/firstaid/adv
	suit_store = /obj/item/device/flashlight/pen

	back_style = BACKPACK_STYLE_MEDICAL

// NURSE OUTFIT
/datum/outfit/job/nurse
	name = OUTFIT_JOB_NAME("Nurse")

	uniform = /obj/item/clothing/under/rank/medical/purple
	uniform_f = /obj/item/clothing/under/rank/nurse
	shoes = /obj/item/clothing/shoes/white

	belt = /obj/item/device/pda/medical
	l_ear = /obj/item/device/radio/headset/headset_med

	l_hand = /obj/item/weapon/storage/firstaid/adv
	suit_store = /obj/item/device/flashlight/pen

	back_style = BACKPACK_STYLE_MEDICAL

/datum/outfit/job/nurse/pre_equip(mob/living/carbon/human/H)
	if(H.use_skirt)
		if(prob(50))
			uniform_f = /obj/item/clothing/under/rank/nursesuit
		head = /obj/item/clothing/head/nursehat


// PARAMEDIC OUTFIT
/datum/outfit/job/paramedic
	name = OUTFIT_JOB_NAME("Paramedic")

	uniform = /obj/item/clothing/under/rank/medical
	shoes = /obj/item/clothing/shoes/white
	suit = /obj/item/clothing/suit/storage/fr_jacket

	belt = /obj/item/device/pda/medical
	l_ear = /obj/item/device/radio/headset/headset_med

	l_hand = /obj/item/weapon/storage/firstaid/adv

	back_style = BACKPACK_STYLE_MEDICAL

// CHEMIST OUTFIT
/datum/outfit/job/chemist
	name = OUTFIT_JOB_NAME("Chemist")

	uniform = /obj/item/clothing/under/rank/chemist
	uniform_f = /obj/item/clothing/under/rank/chemist/skirt
	shoes = /obj/item/clothing/shoes/white
	suit = /obj/item/clothing/suit/storage/labcoat/chemist

	belt = /obj/item/device/pda/chemist
	l_ear = /obj/item/device/radio/headset/headset_med

	back_style = BACKPACK_STYLE_CHEMIST

// GENETICIST OUTFIT
/datum/outfit/job/geneticist
	name = OUTFIT_JOB_NAME("Geneticist")

	uniform = /obj/item/clothing/under/rank/geneticist
	uniform_f = /obj/item/clothing/under/rank/geneticist/skirt
	shoes = /obj/item/clothing/shoes/white
	suit = /obj/item/clothing/suit/storage/labcoat/genetics
	suit_store = /obj/item/device/flashlight/pen

	belt = /obj/item/device/pda/geneticist
	l_ear = /obj/item/device/radio/headset/headset_medsci

	back_style = BACKPACK_STYLE_GENETICIST

// VIROLOGIST OUTFIT
/datum/outfit/job/virologist
	name = OUTFIT_JOB_NAME("Virologist")

	uniform =/obj/item/clothing/under/rank/virologist
	uniform_f = /obj/item/clothing/under/rank/virologist/skirt
	mask = /obj/item/clothing/mask/surgical
	shoes = /obj/item/clothing/shoes/white
	suit = /obj/item/clothing/suit/storage/labcoat/virologist

	belt = /obj/item/device/pda/viro
	l_ear = /obj/item/device/radio/headset/headset_med

	back_style = BACKPACK_STYLE_VIROLOGIST

// PSYCHIATRIST OUTFIT
/datum/outfit/job/psychiatrist
	name = OUTFIT_JOB_NAME("Psychiatrist")

	uniform = /obj/item/clothing/under/rank/psych
	shoes = /obj/item/clothing/shoes/laceup
	suit = /obj/item/clothing/suit/storage/labcoat

	belt = /obj/item/device/pda/medical
	l_ear = /obj/item/device/radio/headset/headset_med

// PSYCHOLOGIST OUTFIT
/datum/outfit/job/psychologist
	name = OUTFIT_JOB_NAME("Psychologist")

	uniform = /obj/item/clothing/under/rank/psych/turtleneck
	shoes = /obj/item/clothing/shoes/laceup
	suit = /obj/item/clothing/suit/storage/labcoat

	belt = /obj/item/device/pda/medical
	l_ear = /obj/item/device/radio/headset/headset_med

// MEDICAL INTERN OUTFIT
/datum/outfit/job/intern
	name = OUTFIT_JOB_NAME("Medical Intern")

	uniform = /obj/item/clothing/under/rank/medical
	shoes = /obj/item/clothing/shoes/white

	belt = /obj/item/device/pda
	l_ear = /obj/item/device/radio/headset/headset_med
