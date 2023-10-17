/obj/item/weapon/storage/belt/security/cops
	startswith = list(/obj/item/weapon/melee/baton = 1, /obj/item/weapon/grenade/flashbang = 2, /obj/item/weapon/handcuffs = 3, /obj/item/weapon/shield/riot/tele = 1)

/obj/item/weapon/storage/belt/security/tactical/cops
	startswith = list(/obj/item/weapon/melee/baton = 1, /obj/item/weapon/grenade/flashbang = 2, /obj/item/weapon/handcuffs = 2, /obj/item/ammo_box/magazine/a28 = 3, /obj/item/weapon/shield/riot/tele = 1)

/datum/outfit/families_police/beatcop
	name = "Families: Офицер"

	uniform = /obj/item/clothing/under/rank/security/beatcop
	back = /obj/item/weapon/storage/backpack/satchel/sec/cops
	shoes = /obj/item/clothing/shoes/boots/police
	glasses = /obj/item/clothing/glasses/sunglasses/hud/sechud
	l_ear = /obj/item/device/radio/headset/headset_sec/alt
	head = /obj/item/clothing/head/spacepolice
	mask = /obj/item/clothing/mask/gas/sechailer/police
	belt = /obj/item/weapon/storage/belt/security/cops
	r_pocket = /obj/item/device/flashlight/seclite
	l_pocket = /obj/item/weapon/storage/firstaid/small_firstaid_kit/civilian
	id = /obj/item/weapon/card/id/space_police
	r_hand = /obj/item/weapon/gun/energy/taser

	survival_box = TRUE

	backpack_contents = list(
		/obj/item/ammo_box/magazine/colt/rubber = 3,
		/obj/item/ammo_box/c45 = 2,
		/obj/item/weapon/gun/projectile/automatic/pistol/colt1911 = 1,
	)

	implants = list(
		/obj/item/weapon/implant/mind_protect/loyalty,
	)

/datum/outfit/families_police/beatcop/armored
	name = "Families: Вооруженный Офицер"
	suit = /obj/item/clothing/suit/storage/flak/police
	head = /obj/item/clothing/head/helmet/police
	suit_store = /obj/item/weapon/gun/projectile/shotgun/dungeon
	backpack_contents = list(
		/obj/item/weapon/storage/box/teargas = 1,
		/obj/item/weapon/storage/box/shotgun/buckshot = 1,
		/obj/item/ammo_box/magazine/colt/rubber = 3,
		/obj/item/weapon/gun/projectile/automatic/pistol/colt1911 = 1,
	)

/datum/outfit/families_police/beatcop/swat
	name = "Families: Боец Тактической Группы"
	suit = /obj/item/clothing/suit/storage/flak/police/fullbody
	head = /obj/item/clothing/head/helmet/police/heavy
	mask = /obj/item/clothing/mask/gas/sechailer/police
	gloves = /obj/item/clothing/gloves/combat/police
	suit_store = /obj/item/weapon/gun/projectile/shotgun/combat
	backpack_contents = list(
		/obj/item/weapon/storage/box/handcuffs = 1,
		/obj/item/weapon/storage/box/teargas = 1,
		/obj/item/weapon/storage/box/shotgun/buckshot = 1,
		/obj/item/weapon/gun/projectile/automatic/pistol/colt1911 = 1,
		/obj/item/ammo_box/magazine/colt/rubber = 3,
	)

/datum/outfit/families_police/beatcop/fbi
	name = "Families: Инспектор"
	suit = /obj/item/clothing/suit/armor/laserproof/police
	head = /obj/item/clothing/head/helmet/laserproof/police
	shoes = /obj/item/clothing/shoes/boots/combat
	gloves = /obj/item/clothing/gloves/combat/police
	suit_store = /obj/item/weapon/gun/projectile/automatic
	backpack_contents = list(
		/obj/item/weapon/storage/box/handcuffs = 1,
		/obj/item/ammo_box/magazine/smg = 3,
		/obj/item/ammo_box/c9mm = 2,
	)

/datum/outfit/families_police/beatcop/military
	name = "Families: Боец ВСНТ"
	suit = /obj/item/clothing/suit/storage/flak/police/fullbody/heavy
	head = /obj/item/clothing/head/helmet/police/elite
	shoes = /obj/item/clothing/shoes/boots/combat
	belt = /obj/item/weapon/storage/belt/security/tactical/cops
	gloves = /obj/item/clothing/gloves/combat/police
	back = /obj/item/weapon/storage/backpack/satchel/sec/cops
	backpack_contents = list(
		/obj/item/weapon/storage/box/handcuffs = 1,
		/obj/item/weapon/storage/box/teargas = 1,
		/obj/item/weapon/storage/box/flashbangs = 1,
		/obj/item/ammo_box/speedloader/a357 = 2,
		/obj/item/weapon/gun/projectile/revolver/mateba = 1,
		/obj/item/weapon/gun/projectile/automatic/a28 = 1,
	)

/datum/outfit/families_traitor
	name = "Families: Агент Синдиката"
	uniform = /obj/item/clothing/under/syndicate
	head = /obj/item/clothing/head/helmet/space/syndicate
	suit = /obj/item/clothing/suit/space/syndicate
	mask = /obj/item/clothing/mask/gas/voice
	shoes = /obj/item/clothing/shoes/boots/combat
	l_hand = /obj/item/weapon/tank/jetpack/oxygen/harness
	suit_store = /obj/item/weapon/tank/emergency_oxygen/engi
	l_ear = /obj/item/device/radio/headset
	id = /obj/item/weapon/card/id/syndicate/nuker
	belt = /obj/item/device/pda
	back = PREFERENCE_BACKPACK_FORCE
	backpack_contents = list(
		/obj/item/weapon/reagent_containers/pill/cyanide,
		/obj/item/weapon/extraction_pack/dealer,
		)
	implants = list(
		/obj/item/weapon/implant/dexplosive
		)
	survival_box = TRUE
	internals_slot = SLOT_S_STORE
