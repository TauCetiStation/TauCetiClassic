// HOS OUTFIT
/datum/outfit/job/hos
	name = OUTFIT_JOB_NAME("Head of Security")

	uniform = /obj/item/clothing/under/rank/head_of_security
	uniform_f = /obj/item/clothing/under/rank/head_of_security_fem
	gloves = /obj/item/clothing/gloves/black
	shoes = /obj/item/clothing/shoes/boots
	l_ear = /obj/item/device/radio/headset/heads/hos
	glasses = /obj/item/clothing/glasses/sunglasses/hud/sechud

	suit_store = /obj/item/weapon/gun/energy/gun
	belt = /obj/item/weapon/melee/chainofcommand
	l_pocket_back = /obj/item/weapon/handcuffs
	l_pocket = /obj/item/device/pda/heads/hos
	r_pocket = /obj/item/device/flash

	implants = list(/obj/item/weapon/implant/mind_protect/loyalty)

	back_style = BACKPACK_STYLE_SECURITY

/datum/outfit/job/hos/pre_equip(mob/living/carbon/human/H)
	if(HAS_ROUND_ASPECT(ROUND_ASPECT_HF_AGENT))
		implants += /obj/item/weapon/implant/obedience

// WARDEN OUTFIT
/datum/outfit/job/warden
	name = OUTFIT_JOB_NAME("Warden")

	uniform = /obj/item/clothing/under/rank/warden
	uniform_f = /obj/item/clothing/under/rank/warden_fem
	belt = /obj/item/device/pda/warden
	gloves = /obj/item/clothing/gloves/black
	shoes = /obj/item/clothing/shoes/boots
	l_ear = /obj/item/device/radio/headset/headset_sec
	glasses = /obj/item/clothing/glasses/sunglasses/hud/sechud

	l_pocket = /obj/item/device/flash
	l_hand_back = /obj/item/weapon/handcuffs

	backpack_contents = null
	implants = list(/obj/item/weapon/implant/mind_protect/mindshield, /obj/item/weapon/implant/obedience)

	back_style = BACKPACK_STYLE_SECURITY

/datum/outfit/job/warden/pre_equip(mob/living/carbon/human/H)
	if(HAS_ROUND_ASPECT(ROUND_ASPECT_ELITE_SECURITY))
		implants += /obj/item/weapon/implant/mind_protect/loyalty
		implants += /obj/item/weapon/implant/dexplosive
		head = /obj/item/clothing/head/soft/nt_pmc_cap
		uniform = /obj/item/clothing/under/tactical
		uniform_f = /obj/item/clothing/under/tactical
		gloves = /obj/item/clothing/gloves/swat
		l_ear = /obj/item/device/radio/headset/headset_sec/nt_pmc
		glasses = /obj/item/clothing/glasses/sunglasses/hud/sechud/tactical
		ADD_TRAIT(H, TRAIT_NO_CLONE, ROUNDSTART_TRAIT)

// DETECTIVE OUTFIT
/datum/outfit/job/detective
	name = OUTFIT_JOB_NAME("Detective")

	uniform = /obj/item/clothing/under/det
	suit = /obj/item/clothing/suit/storage/det_suit
	belt = /obj/item/device/pda/detective
	gloves = /obj/item/clothing/gloves/black
	shoes = /obj/item/clothing/shoes/brown
	head = /obj/item/clothing/head/det_hat
	l_ear = /obj/item/device/radio/headset/headset_sec
	glasses = /obj/item/clothing/glasses/sunglasses/noir

	l_hand_back = /obj/item/weapon/storage/box/evidence
	l_pocket = /obj/item/weapon/lighter/zippo
	r_pocket_back = /obj/item/device/detective_scanner

// OFFICER OUTFIT
/datum/outfit/job/officer
	name = OUTFIT_JOB_NAME("Security Officer")

	uniform = /obj/item/clothing/under/rank/security
	uniform_f = /obj/item/clothing/under/rank/security/skirt
	belt = /obj/item/device/pda/security
	shoes = /obj/item/clothing/shoes/boots
	l_ear = /obj/item/device/radio/headset/headset_sec

	l_hand_back = /obj/item/weapon/handcuffs
	l_pocket = /obj/item/device/flash

	implants = list(/obj/item/weapon/implant/mind_protect/mindshield, /obj/item/weapon/implant/obedience)

	back_style = BACKPACK_STYLE_SECURITY

/datum/outfit/job/officer/pre_equip(mob/living/carbon/human/H)
	if(HAS_ROUND_ASPECT(ROUND_ASPECT_ELITE_SECURITY))
		implants += /obj/item/weapon/implant/mind_protect/loyalty
		implants += /obj/item/weapon/implant/dexplosive
		uniform = /obj/item/clothing/under/syndicate
		uniform_f = /obj/item/clothing/under/syndicate
		l_ear = /obj/item/device/radio/headset/headset_sec/nt_pmc
		ADD_TRAIT(H, TRAIT_NO_CLONE, ROUNDSTART_TRAIT)

// FORENSIC OUTFIT
/datum/outfit/job/forensic
	name = OUTFIT_JOB_NAME("Forensic Technician")

	uniform = /obj/item/clothing/under/rank/forensic_technician
	suit = /obj/item/clothing/suit/storage/forensics/red
	gloves = /obj/item/clothing/gloves/black
	shoes = /obj/item/clothing/shoes/laceup
	belt = /obj/item/device/pda/forensic
	l_ear = /obj/item/device/radio/headset/headset_sec

	r_pocket_back = /obj/item/device/detective_scanner
	l_hand_back = /obj/item/weapon/storage/box/evidence

// CADET OUTFIT
/datum/outfit/job/cadet
	name = OUTFIT_JOB_NAME("Security Cadet")

	uniform = /obj/item/clothing/under/rank/cadet
	uniform_f = /obj/item/clothing/under/rank/cadet/skirt
	belt = /obj/item/device/pda
	shoes = /obj/item/clothing/shoes/boots
	l_ear = /obj/item/device/radio/headset/headset_sec

	l_pocket = /obj/item/device/flash
	l_hand_back = /obj/item/weapon/handcuffs
	r_hand = /obj/item/weapon/book/manual/wiki/security_space_law

	implants = list(/obj/item/weapon/implant/mind_protect/mindshield, /obj/item/weapon/implant/obedience)

	back_style = BACKPACK_STYLE_SECURITY

/datum/outfit/job/cadet/pre_equip(mob/living/carbon/human/H)
	if(HAS_ROUND_ASPECT(ROUND_ASPECT_ELITE_SECURITY))
		uniform = /obj/item/clothing/under/syndicate/tacticool
		uniform_f = /obj/item/clothing/under/syndicate/tacticool
		l_ear = /obj/item/device/radio/headset/headset_sec/nt_pmc

