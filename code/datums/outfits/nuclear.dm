/obj/item/weapon/storage/backpack/nuke
	startswith = list(
	/obj/item/weapon/reagent_containers/pill/cyanide,
	/obj/item/weapon/crowbar/red,
	/obj/item/ammo_box/magazine/m9mm,
	/obj/item/clothing/accessory/holster/armpit,
	/obj/item/weapon/pinpointer/nukeop,
	/obj/item/weapon/kitchenknife/combat,
	/obj/item/clothing/accessory/storage/syndi_vest,
	/obj/item/weapon/mining_voucher/kit,
	/obj/item/weapon/mining_voucher/armour,)

/obj/item/weapon/storage/pouch/pistol_holster/stechkin
	startswith = list(
	/obj/item/weapon/gun/projectile/automatic/pistol,
	)

/datum/outfit/nuclear
	name = "Syndicate: Nuclear Agent"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/boots/combat
	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/syndicate
	gloves = /obj/item/clothing/gloves/combat
	l_ear = /obj/item/device/radio/headset/syndicate
	l_pocket = /obj/item/weapon/storage/pouch/ammo
	r_pocket = /obj/item/weapon/storage/pouch/pistol_holster/stechkin
	id = /obj/item/weapon/card/id/syndicate/nuker
	belt = /obj/item/weapon/storage/belt/military
	back = /obj/item/weapon/storage/backpack/nuke
	implants = list(
		/obj/item/weapon/implant/dexplosive
		)
	survival_box = TRUE

	survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen/engi)
	prevent_survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen)


/obj/item/weapon/storage/pouch/pistol_holster/revolver
	startswith = list(
	/obj/item/weapon/gun/projectile/revolver,
	)


/obj/item/weapon/storage/backpack/nuke/commander
	startswith = list(
	/obj/item/weapon/reagent_containers/pill/cyanide,
	/obj/item/weapon/crowbar/red,
	/obj/item/ammo_box/a357,
	/obj/item/clothing/accessory/holster/armpit,
	/obj/item/weapon/pinpointer/nukeop,
	/obj/item/device/radio/uplink,
	/obj/item/weapon/kitchenknife/combat,
	/obj/item/clothing/accessory/storage/syndi_vest,
	/obj/item/weapon/mining_voucher/kit,
	/obj/item/weapon/mining_voucher/armour,)

/datum/outfit/nuclear/leader
	name = "Syndicate: Nuclear Commander"
	id = /obj/item/weapon/card/id/syndicate/commander
	back = /obj/item/weapon/storage/backpack/nuke/commander
	r_pocket = /obj/item/weapon/storage/pouch/pistol_holster/revolver

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
