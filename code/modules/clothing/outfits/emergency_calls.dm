/datum/outfit/ert/nt
	w_uniform = /obj/item/clothing/under/ert
	shoes = /obj/item/clothing/shoes/swat
	mask = /obj/item/clothing/mask/gas/sechailer
	id = /obj/item/weapon/card/id/ert
	l_ear = /obj/item/device/radio/headset/ert
	r_store = /obj/item/weapon/tank/emergency_oxygen/double
	accessory = /obj/item/clothing/accessory/storage/black_vest

/datum/outfit/ert/nt/leader
	name = "NT ERT Leader"

	wear_suit = /obj/item/clothing/suit/space/rig/ert/commander
	back = /obj/item/weapon/storage/backpack/ert/commander
	belt = /obj/item/weapon/storage/belt/security/full
	gloves = /obj/item/clothing/gloves/swat
	head = /obj/item/clothing/head/helmet/space/rig/ert/commander
	glasses = /obj/item/clothing/glasses/night
	l_store = /obj/item/weapon/storage/firstaid/small_firstaid_kit/space
	suit_store = /obj/item/weapon/gun/energy/gun/nuclear
	title = "Emergency Response Team Leader"

/datum/outfit/ert/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/weapon/pinpointer/advpinpointer, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/wjpp/spec, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_box/magazine/m9mm_2/rubber, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_box/magazine/m9mm_2, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_box/magazine/m9mm_2, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/device/remote_device/ERT, SLOT_IN_BACKPACK)


	var/obj/item/weapon/implant/mindshield/loyalty/L = new(H)
	START_PROCESSING(SSobj, L)
	L.inject(H)

/datum/outfit/ert/nt/security
	name = "NT ERT Security"

	wear_suit = /obj/item/clothing/suit/space/rig/ert/security
	back = /obj/item/weapon/storage/backpack/ert/security
	belt = /obj/item/weapon/storage/belt/security/full
	gloves = /obj/item/clothing/gloves/swat
	head = /obj/item/clothing/head/helmet/space/rig/ert/security
	glasses = /obj/item/clothing/glasses/night
	l_store = /obj/item/weapon/storage/firstaid/small_firstaid_kit/space
	suit_store = /obj/item/weapon/gun/energy/gun/nuclear
	title = "Emergency Response Team Security"

/datum/outfit/ert/nt/security/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/automatic, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_box/magazine/msmg9mm, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_box/magazine/msmg9mm, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_box/magazine/msmg9mm, SLOT_IN_BACKPACK)

/datum/outfit/ert/security/shotgun
	name = "NT ERT Security (Shotgun)"

	suit_store = /obj/item/weapon/gun/projectile/shotgun/combat

/datum/outfit/ert/security/shotgun/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/tele, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_box/shotgun, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_box/shotgun/beanbag, SLOT_IN_BACKPACK)

/datum/outfit/ert/medic
	name = "NT ERT Medic"

	wear_suit = /obj/item/clothing/suit/space/rig/ert/medical
	back = /obj/item/weapon/storage/backpack/ert/medical
	belt = /obj/item/weapon/storage/belt/medical/full
	gloves = /obj/item/clothing/gloves/latex
	head = /obj/item/clothing/head/helmet/space/rig/ert/medical
	glasses = /obj/item/clothing/glasses/night
	l_store = /obj/item/weapon/reagent_containers/hypospray
	suit_store = /obj/item/weapon/gun/energy/gun/nuclear
	title = "Emergency Response Team Medic"