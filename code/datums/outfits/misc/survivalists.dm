/datum/outfit/survival/engineer
	name = "Survival: Engineer"
	uniform = /obj/item/clothing/under/rank/engineer
	suit = /obj/item/clothing/suit/storage/hazardvest
	glasses = /obj/item/clothing/glasses/welding
	shoes = /obj/item/clothing/shoes/boots/work
	belt = /obj/item/weapon/storage/belt/utility/cool
	head = /obj/item/clothing/head/hardhat/white
	back = /obj/item/weapon/storage/backpack/industrial
	gloves = /obj/item/clothing/gloves/insulated
	id = /obj/item/weapon/card/id/old_station/eng

	r_pocket = /obj/item/device/t_scanner
	l_hand = /obj/item/blueprints

/obj/item/weapon/storage/belt/utility/cool
	startswith = list(
	/obj/item/weapon/multi/hand_drill,
	/obj/item/weapon/multi/jaws_of_life,
	/obj/item/weapon/weldingtool/experimental,
	/obj/item/device/multitool
	)

/datum/outfit/survival/medic
	name = "Survival: Medic"

	uniform = /obj/item/clothing/under/rank/medical
	uniform_f = /obj/item/clothing/under/rank/medical/skirt
	shoes = /obj/item/clothing/shoes/white
	gloves = /obj/item/clothing/gloves/latex/nitrile
	head = /obj/item/clothing/head/beret/paramed
	belt = /obj/item/weapon/storage/belt/medical/full
	suit = /obj/item/clothing/suit/storage/labcoat/cmo
	id = /obj/item/weapon/card/id/old_station/med
	glasses = /obj/item/clothing/glasses/hud/health
	back = /obj/item/weapon/storage/backpack/medic


	l_hand = /obj/item/weapon/storage/firstaid/adv
	suit_store = /obj/item/device/healthanalyzer

/obj/item/weapon/storage/belt/medical/full
	startswith = list(
	/obj/item/weapon/reagent_containers/hypospray,
	/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack_adv,
	/obj/item/stack/medical/suture,
	/obj/item/weapon/storage/pill_bottle/bicaridine,
	/obj/item/weapon/storage/pill_bottle/dermaline,
	/obj/item/weapon/storage/pill_bottle/dylovene,
	/obj/item/weapon/storage/pill_bottle/tramadol
	)

/datum/outfit/mercenary
	name = "Mercenary"
	uniform = /obj/item/clothing/under/tactical
	suit = /obj/item/clothing/suit/space/syndicate/striker
	suit_store = /obj/item/weapon/gun/projectile/automatic/mini_uzi
	glasses = /obj/item/clothing/glasses/night
	shoes = /obj/item/clothing/shoes/boots
	belt = /obj/item/weapon/storage/belt/security/tactical/merc
	head = /obj/item/clothing/head/helmet/space/syndicate/striker
	mask = /obj/item/clothing/mask/breath
	back = /obj/item/weapon/storage/backpack/satchel/norm
	gloves = /obj/item/clothing/gloves/combat
	id = /obj/item/weapon/card/id

	r_pocket = /obj/item/weapon/tank/emergency_oxygen/double
	l_pocket = /obj/item/weapon/silencer

	backpack_contents = list(
	/obj/item/weapon/storage/firstaid/small_firstaid_kit/space,
	/obj/item/clothing/head/helmet/tactical,
	/obj/item/clothing/suit/armor/tactical
	)

/obj/item/weapon/storage/belt/security/tactical/merc
	startswith = list(/obj/item/ammo_box/magazine/mac10 = 2, /obj/item/weapon/melee/energy/sword/black = 1, /obj/item/weapon/storage/fancy/cigarettes/dromedaryco = 1, /obj/item/weapon/lighter/zippo = 1)
