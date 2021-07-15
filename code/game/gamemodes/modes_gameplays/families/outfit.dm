/datum/outfit/families_police/beatcop
	name = "Families: Офицер"

	uniform = /obj/item/clothing/under/rank/security/beatcop
	back = /obj/item/weapon/storage/backpack/dufflebag/cops
	shoes = /obj/item/clothing/shoes/boots/swat
	glasses = /obj/item/clothing/glasses/sunglasses
	l_ear = /obj/item/device/radio/headset/headset_sec/alt
	head = /obj/item/clothing/head/spacepolice
	belt = /obj/item/weapon/gun/projectile/automatic/colt1911
	r_pocket = /obj/item/weapon/lighter
	l_pocket = /obj/item/weapon/handcuffs
	id = /obj/item/weapon/card/id/space_police
	r_hand = /obj/item/weapon/gun/energy/taser

	backpack_contents = list(
		/obj/item/weapon/storage/box/handcuffs = 1,
		/obj/item/weapon/storage/box/teargas = 1,
		/obj/item/weapon/storage/box/flashbangs = 1,
		/obj/item/weapon/shield/riot/tele = 1,
		/obj/item/ammo_box/magazine/c45r = 3,
		/obj/item/ammo_box/c45 = 2,
		/obj/item/weapon/melee/baton,
		/obj/item/weapon/storage/box/survival
	)

/datum/outfit/families_police/beatcop/armored
	name = "Families: Вооруженный Офицер"
	suit = /obj/item/clothing/suit/armor/vest/security
	head = /obj/item/clothing/head/helmet
	l_hand = /obj/item/weapon/gun/projectile/shotgun/combat
	backpack_contents = list(
		/obj/item/weapon/storage/box/handcuffs = 1,
		/obj/item/weapon/storage/box/teargas = 1,
		/obj/item/weapon/storage/box/flashbangs = 1,
		/obj/item/weapon/shield/riot/tele = 1,
		/obj/item/weapon/storage/box/shotgun/buckshot = 2,
		/obj/item/weapon/melee/baton,
		/obj/item/weapon/storage/box/survival
	)

/datum/outfit/families_police/beatcop/swat
	name = "Families: Боец Тактической Группы"
	suit = /obj/item/clothing/suit/armor/riot
	head = /obj/item/clothing/head/helmet
	gloves = /obj/item/clothing/gloves/combat
	l_hand = /obj/item/weapon/gun/projectile/shotgun/combat
	backpack_contents = list(
		/obj/item/weapon/storage/box/handcuffs = 1,
		/obj/item/weapon/storage/box/teargas = 1,
		/obj/item/weapon/storage/box/flashbangs = 1,
		/obj/item/weapon/shield/riot/tele = 1,
		/obj/item/weapon/storage/box/shotgun/buckshot = 2,
		/obj/item/weapon/melee/baton,
		/obj/item/weapon/storage/box/survival
	)

/datum/outfit/families_police/beatcop/fbi
	name = "Families: Инспектор"
	suit = /obj/item/clothing/suit/armor/laserproof
	head = /obj/item/clothing/head/helmet/riot
	head = /obj/item/clothing/head/helmet/HoS/dermal
	belt = /obj/item/weapon/gun/projectile/automatic
	gloves = /obj/item/clothing/gloves/combat
	backpack_contents = list(
		/obj/item/weapon/storage/box/handcuffs = 1,
		/obj/item/weapon/storage/box/teargas = 1,
		/obj/item/weapon/storage/box/flashbangs = 1,
		/obj/item/weapon/shield/riot/tele = 1,
		/obj/item/ammo_box/magazine/msmg9mm = 3,
		/obj/item/ammo_box/c9mm = 2,
		/obj/item/weapon/melee/baton,
		/obj/item/weapon/storage/box/survival
	)

/datum/outfit/families_police/beatcop/military
	name = "Families: Боец ВСНТ"
	uniform = /obj/item/clothing/under/tactical/marinad
	suit = /obj/item/clothing/suit/marinad
	head = /obj/item/clothing/head/helmet/tactical/marinad
	belt = /obj/item/weapon/gun/projectile/revolver/mateba
	gloves = /obj/item/clothing/gloves/security/marinad
	back = /obj/item/weapon/storage/backpack/dufflebag/marinad
	backpack_contents = list(
		/obj/item/weapon/storage/box/handcuffs = 1,
		/obj/item/weapon/storage/box/teargas = 1,
		/obj/item/weapon/storage/box/flashbangs = 1,
		/obj/item/weapon/shield/riot/tele = 1,
		/obj/item/ammo_box/magazine/m556 = 2,
		/obj/item/weapon/melee/baton,
		/obj/item/weapon/gun/projectile/automatic/a28,
		/obj/item/weapon/storage/box/survival
	)
