/datum/outfit/ert/nt
	uniform = /obj/item/clothing/under/ert
	shoes = /obj/item/clothing/shoes/boots/swat
	mask = /obj/item/clothing/mask/gas/sechailer
	id = /obj/item/weapon/card/id/centcom/ert
	l_ear = /obj/item/device/radio/headset/ert
	r_pocket = /obj/item/weapon/tank/emergency_oxygen/double
	accessory = /obj/item/clothing/accessory/storage/black_vest
	implants = list(/obj/item/weapon/implant/mindshield/loyalty = /obj/item/organ/external/head)
	survival_box = FALSE

/datum/outfit/ert/nt/leader
	name = "NT ERT Leader"

	suit = /obj/item/clothing/suit/space/rig/ert/commander
	back = /obj/item/weapon/storage/backpack/ert/commander
	belt = /obj/item/weapon/storage/belt/security/full
	gloves = /obj/item/clothing/gloves/swat
	head = /obj/item/clothing/head/helmet/space/rig/ert/commander
	glasses = /obj/item/clothing/glasses/night
	l_pocket = /obj/item/weapon/storage/firstaid/small_firstaid_kit/space
	suit_store = /obj/item/weapon/gun/energy/gun/nuclear
	backpack_contents = list(/obj/item/weapon/pinpointer/advpinpointer = 1, /obj/item/weapon/gun/projectile/glock/spec = 1, /obj/item/ammo_box/magazine/m9mm_2/rubber = 1, /obj/item/ammo_box/magazine/m9mm_2 = 2, /obj/item/device/remote_device/ERT = 1, /obj/item/weapon/plastique = 2, /obj/item/device/aicard = 1)
	assignment = "Emergency Response Team Leader"

/datum/outfit/ert/nt/security
	name = "NT ERT Security"

	suit = /obj/item/clothing/suit/space/rig/ert/security
	back = /obj/item/weapon/storage/backpack/ert/security
	belt = /obj/item/weapon/storage/belt/security/full
	gloves = /obj/item/clothing/gloves/swat
	head = /obj/item/clothing/head/helmet/space/rig/ert/security
	glasses = /obj/item/clothing/glasses/night
	l_pocket = /obj/item/weapon/storage/firstaid/small_firstaid_kit/space
	suit_store = /obj/item/weapon/gun/energy/gun/nuclear
	backpack_contents = list(/obj/item/weapon/gun/projectile/automatic = 1, /obj/item/ammo_box/magazine/msmg9mm = 3, /obj/item/weapon/plastique = 1)
	assignment = "Emergency Response Team Security"

/datum/outfit/ert/security/shotgun
	name = "NT ERT Security (Shotgun)"

	suit_store = /obj/item/weapon/gun/projectile/shotgun/combat
	backpack_contents = list(/obj/item/weapon/shield/riot/tele = 1, /obj/item/ammo_box/shotgun = 1, /obj/item/ammo_box/shotgun/beanbag = 1, /obj/item/weapon/plastique = 1)

/datum/outfit/ert/security/sniper
	name = "NT ERT Security (Sniper)"

	suit_store = /obj/item/weapon/gun/energy/sniperrifle
	backpack_contents = list(/obj/item/weapon/gun/projectile/glock/spec = 1, /obj/item/ammo_box/magazine/m9mm_2/rubber = 1, /obj/item/ammo_box/magazine/m9mm_2 = 2, /obj/item/weapon/plastique = 1)

/datum/outfit/ert/nt/medic
	name = "NT ERT Medic"

	suit = /obj/item/clothing/suit/space/rig/ert/medical
	back = /obj/item/weapon/storage/backpack/ert/medical
	belt = /obj/item/weapon/storage/belt/medical/full
	gloves = /obj/item/clothing/gloves/latex
	head = /obj/item/clothing/head/helmet/space/rig/ert/medical
	glasses = /obj/item/clothing/glasses/hud/health
	l_pocket = /obj/item/weapon/reagent_containers/hypospray
	suit_store = /obj/item/weapon/gun/energy/gun/nuclear //doesn't really have space for ammo or sidearm
	backpack_contents = list(/obj/item/weapon/storage/firstaid/adv = 1, /obj/item/weapon/storage/firstaid/fire = 1, /obj/item/weapon/storage/firstaid/o2 = 1, /obj/item/weapon/storage/firstaid/toxin = 1, /obj/item/weapon/storage/firstaid/small_firstaid_kit/combat = 2, /obj/item/weapon/storage/firstaid/small_firstaid_kit/space = 2)
	assignment = "Emergency Response Team Medic"

/datum/outfit/ert/nt/engineer
	name = "NT ERT Engineer"

	suit = /obj/item/clothing/suit/space/rig/ert/engineer
	back = /obj/item/weapon/storage/backpack/ert/engineer
	belt = /obj/item/weapon/storage/belt/utility/full
	gloves = /obj/item/clothing/gloves/yellow
	head = /obj/item/clothing/head/helmet/space/rig/ert/engineer
	glasses = /obj/item/clothing/glasses/meson
	l_pocket = /obj/item/device/multitool
	suit_store = /obj/item/weapon/gun/energy/ionrifle
	backpack_contents = list(/obj/item/weapon/gun/projectile/automatic = 1, /obj/item/ammo_box/magazine/msmg9mm = 2, /obj/item/weapon/plastique = 3, /obj/item/weapon/rcd/loaded = 1, /obj/item/weapon/rcd_ammo = 3)
	assignment = "Emergency Response Team Engineer"
