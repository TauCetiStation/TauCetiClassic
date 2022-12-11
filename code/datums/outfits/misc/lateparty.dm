/obj/item/weapon/storage/belt/security/cc_officer_helper
	startswith = list(/obj/item/weapon/melee/baton = 1, /obj/item/ammo_box/a357 = 4, /obj/item/device/flash = 1, /obj/item/weapon/shield/riot/tele = 1)

/obj/item/weapon/storage/pouch/ammo/cc_officer_helper
	startswith = list(/obj/item/ammo_casing/r4046/chem/EMP = 3)

/obj/item/weapon/storage/pouch/pistol_holster/cc_officer_helper
	startswith = list(/obj/item/weapon/gun/projectile/revolver/mateba = 1)

/obj/item/weapon/storage/pouch/ammo/cc_civillian_helper
	startswith = list(/obj/item/ammo_box/magazine/m9mm_2 = 3)

/obj/item/weapon/storage/pouch/pistol_holster/cc_civillian_helper
	startswith = list(/obj/item/weapon/gun/projectile/glock/spec = 1)

/datum/outfit/job/officer/centcomm_helper
	name = OUTFIT_JOB_NAME("Security Officer")
	uniform_f = /obj/item/clothing/under/rank/security
	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/armor/vest/fullbody
	head = /obj/item/clothing/head/helmet/riot
	l_ear = /obj/item/device/radio/headset/ert
	r_ear = /obj/item/device/radio/headset/binary
	id = /obj/item/weapon/card/id/sec
	belt = /obj/item/weapon/storage/belt/security/cc_officer_helper
	l_pocket = /obj/item/weapon/storage/pouch/ammo/cc_officer_helper
	r_pocket = /obj/item/weapon/storage/pouch/pistol_holster/cc_officer_helper
	back = /obj/item/weapon/gun/projectile/grenade_launcher/m79
	implants = list(/obj/item/weapon/implant/mind_protect/mindshield, /obj/item/weapon/implant/mind_protect/loyalty)

/datum/outfit/job/lawyer/centcomm_helper
	name = OUTFIT_JOB_NAME("Internal Affairs Agent")
	uniform = /obj/item/clothing/under/rank/internalaffairs
	shoes = /obj/item/clothing/shoes/black
	suit = /obj/item/clothing/suit/storage/internalaffairs
	glasses = /obj/item/clothing/glasses/sunglasses/big
	l_ear = /obj/item/device/radio/headset/ert
	r_ear = /obj/item/device/radio/headset/binary
	belt = /obj/item/weapon/katana
	id = /obj/item/weapon/card/id/int
	l_hand = /obj/item/weapon/storage/briefcase/centcomm
	l_pocket = /obj/item/weapon/storage/pouch/ammo/cc_civillian_helper
	r_pocket = /obj/item/weapon/storage/pouch/pistol_holster/cc_civillian_helper
	implants = list(/obj/item/weapon/implant/mind_protect/loyalty)
	backpack_contents = list(/obj/item/device/flash)

/datum/outfit/job/engineer/centcomm_helper
	name = OUTFIT_JOB_NAME("Station Engineer")
	uniform = /obj/item/clothing/under/rank/engineer
	shoes = /obj/item/clothing/shoes/boots/work
	belt = /obj/item/weapon/storage/belt/utility/full
	head = /obj/item/clothing/head/hardhat/yellow
	gloves = /obj/item/clothing/gloves/yellow
	l_ear = /obj/item/device/radio/headset/ert
	r_ear = /obj/item/device/radio/headset/binary
	id = /obj/item/weapon/card/id/eng
	l_pocket = /obj/item/weapon/storage/pouch/ammo/cc_civillian_helper
	r_pocket = /obj/item/weapon/storage/pouch/pistol_holster/cc_civillian_helper
	implants = list(/obj/item/weapon/implant/mind_protect/loyalty)
	back = /obj/item/weapon/storage/backpack/holding
	survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen/engi)
	prevent_survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen)
	backpack_contents = list(/obj/item/device/multitool/ai_detect = 1,
							/obj/item/device/flashlight/emp = 1,
							/obj/item/device/powersink = 1,
							/obj/item/mine/emp = 3
							)
