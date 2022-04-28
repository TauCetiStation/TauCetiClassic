/datum/outfit/nuclear
	name = "Nuclear Agent"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/boots/combat
	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/syndicate
	gloves = /obj/item/clothing/gloves/combat
	l_ear = /obj/item/device/radio/headset/syndicate
	l_pocket = /obj/item/weapon/storage/pouch/ammo
	r_pocket = /obj/item/weapon/storage/pouch/pistol_holster
	id = /obj/item/weapon/card/id/syndicate/nuker
	belt = /obj/item/weapon/storage/belt/military
	belt_contents = list(
		/obj/item/clothing/accessory/holster,
		/obj/item/weapon/pinpointer/nukeop,
	)
	back = PREFERENCE_BACKPACK_FORCE
	backpack_contents = list(
		/obj/item/weapon/reagent_containers/pill/cyanide,
		/obj/item/weapon/gun/projectile/automatic/pistol,
		/obj/item/ammo_box/magazine/m9mm,
		)
	implants = list(
		/obj/item/weapon/implant/dexplosive
		)
	survival_box = TRUE

	survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen/engi)
	prevent_survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen)

/datum/outfit/nuclear/leader
	name = "Nuclear Commander"
	id = /obj/item/weapon/card/id/syndicate/commander
	backpack_contents = list(
		/obj/item/device/radio/uplink,
		/obj/item/weapon/gun/projectile/revolver,
		/obj/item/weapon/reagent_containers/pill/cyanide,
		/obj/item/ammo_box/a357,
		)

/datum/outfit/nuclear/unathi_equip()
	backpack_contents += list(/obj/item/device/modkit/syndie/unathi)

/datum/outfit/nuclear/tajaran_equip()
	backpack_contents += list(/obj/item/device/modkit/syndie/tajaran)

/datum/outfit/nuclear/skrell_equip()
	backpack_contents += list(/obj/item/device/modkit/syndie/skrell)

/datum/outfit/nuclear/vox_equip()
	backpack_contents += list(/obj/item/device/modkit/syndie/vox)
	l_hand = /obj/item/weapon/tank/nitrogen
	mask = /obj/item/clothing/mask/gas/vox
