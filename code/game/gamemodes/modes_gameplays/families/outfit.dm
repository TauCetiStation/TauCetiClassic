/obj/item/weapon/storage/belt/security/cops/atom_init()
	. = ..()
	new /obj/item/weapon/melee/baton(src)
	for (var/i in 1 to 2)
		new /obj/item/weapon/grenade/flashbang(src)
	for (var/i in 1 to 3)
		new /obj/item/weapon/handcuffs(src)
	new /obj/item/weapon/shield/riot/tele(src)

/obj/item/weapon/storage/belt/security/tactical/cops/atom_init()
	. = ..()
	new /obj/item/weapon/melee/baton(src)
	for (var/i in 1 to 2)
		new /obj/item/weapon/grenade/flashbang(src)
	for (var/i in 1 to 3)
		new /obj/item/weapon/handcuffs(src)
		new /obj/item/ammo_box/magazine/m556(src)

/datum/outfit/families_police/beatcop
	name = "Families: Офицер"

	uniform = /obj/item/clothing/under/rank/security/beatcop
	back = /obj/item/weapon/storage/backpack/satchel/sec/cops
	shoes = /obj/item/clothing/shoes/boots/swat
	glasses = /obj/item/clothing/glasses/sunglasses
	l_ear = /obj/item/device/radio/headset/headset_sec/alt
	head = /obj/item/clothing/head/spacepolice
	belt = /obj/item/weapon/storage/belt/security/cops
	r_pocket = /obj/item/device/flashlight
	l_pocket = /obj/item/device/flash
	id = /obj/item/weapon/card/id/space_police
	r_hand = /obj/item/weapon/gun/energy/taser

	survival_box = TRUE

	backpack_contents = list(
		/obj/item/ammo_box/magazine/c45r = 3,
		/obj/item/ammo_box/c45 = 2,
		/obj/item/weapon/gun/projectile/automatic/colt1911 = 1,
	)

	implants = list(
		/obj/item/weapon/implant/mind_protect/loyalty,
	)

/datum/outfit/families_police/beatcop/armored
	name = "Families: Вооруженный Офицер"
	suit = /obj/item/clothing/suit/armor/vest/security
	head = /obj/item/clothing/head/helmet
	suit_store = /obj/item/weapon/gun/projectile/shotgun/dungeon
	backpack_contents = list(
		/obj/item/weapon/storage/box/teargas = 1,
		/obj/item/weapon/storage/box/shotgun/buckshot = 2,
		/obj/item/ammo_box/magazine/c45r = 3,
		/obj/item/ammo_box/c45 = 2,
		/obj/item/weapon/gun/projectile/automatic/colt1911 = 1,
	)

/datum/outfit/families_police/beatcop/swat
	name = "Families: Боец Тактической Группы"
	suit = /obj/item/clothing/suit/armor/vest/fullbody
	head = /obj/item/clothing/head/helmet
	mask = /obj/item/clothing/mask/gas/sechailer
	gloves = /obj/item/clothing/gloves/combat
	suit_store = /obj/item/weapon/gun/projectile/shotgun/combat
	backpack_contents = list(
		/obj/item/weapon/storage/box/handcuffs = 1,
		/obj/item/weapon/storage/box/teargas = 1,
		/obj/item/weapon/shield/riot/tele = 1,
		/obj/item/weapon/storage/box/shotgun/buckshot = 2,
		/obj/item/weapon/gun/projectile/automatic/colt1911 = 1,
	)

/datum/outfit/families_police/beatcop/fbi
	name = "Families: Инспектор"
	suit = /obj/item/clothing/suit/armor/laserproof
	back = /obj/item/weapon/storage/backpack/satchel
	head = /obj/item/clothing/head/beret/spacepolice
	glasses = /obj/item/clothing/glasses/sunglasses/big
	gloves = /obj/item/clothing/gloves/white
	suit_store = /obj/item/weapon/gun/projectile/automatic
	backpack_contents = list(
		/obj/item/weapon/storage/box/handcuffs = 1,
		/obj/item/ammo_box/magazine/msmg9mm = 3,
		/obj/item/ammo_box/c9mm = 2,
	)

/datum/outfit/families_police/beatcop/military
	name = "Families: Боец ВСНТ"
	uniform = /obj/item/clothing/under/tactical/marinad
	suit = /obj/item/clothing/suit/marinad
	head = /obj/item/clothing/head/helmet/tactical/marinad
	belt = /obj/item/weapon/storage/belt/security/tactical/cops
	gloves = /obj/item/clothing/gloves/security/marinad
	back = /obj/item/weapon/storage/backpack/dufflebag/marinad
	suit_store = /obj/item/weapon/gun/projectile/automatic/a28
	backpack_contents = list(
		/obj/item/weapon/storage/box/handcuffs = 1,
		/obj/item/weapon/storage/box/teargas = 1,
		/obj/item/weapon/storage/box/flashbangs = 1,
		/obj/item/weapon/shield/riot/tele = 1,
		/obj/item/ammo_box/a357 = 2,
		/obj/item/weapon/gun/projectile/revolver/mateba = 1,
	)

/datum/outfit/families_traitor
	name = "Families: Агент Синдиката"
	uniform = /obj/item/clothing/under/syndicate
	head = /obj/item/clothing/head/helmet/space/syndicate
	suit = /obj/item/clothing/suit/space/syndicate
	mask = /obj/item/clothing/mask/breath
	shoes = /obj/item/clothing/shoes/boots/combat
	l_hand = /obj/item/weapon/tank/jetpack/oxygen/harness
	l_pocket = /obj/item/weapon/tank/emergency_oxygen/engi
	l_ear = /obj/item/device/radio/headset
	id = /obj/item/weapon/card/id/syndicate/nuker
	belt = /obj/item/device/pda
	back = PREFERENCE_BACKPACK_FORCE
	backpack_contents = list(
		/obj/item/weapon/reagent_containers/pill/cyanide,
		/obj/item/weapon/extraction_pack/syndicate,
		)
	survival_box = TRUE
