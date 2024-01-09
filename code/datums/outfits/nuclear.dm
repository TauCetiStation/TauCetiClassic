/obj/item/weapon/storage/pouch/pistol_holster/stechkin
	startswith = list(
	/obj/item/weapon/gun/projectile/automatic/pistol/stechkin,
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
	back = PREFERENCE_BACKPACK
	implants = list(
		/obj/item/weapon/implant/dexplosive
		)
	survival_box = TRUE
	backpack_contents = list(/obj/item/weapon/mining_voucher/kit, /obj/item/weapon/mining_voucher/armour)

	survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen/engi)
	prevent_survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen)


/obj/item/weapon/storage/pouch/pistol_holster/revolver
	startswith = list(
	/obj/item/weapon/gun/projectile/revolver,
	)

/datum/outfit/nuclear/leader
	name = "Syndicate: Nuclear Commander"
	id = /obj/item/weapon/card/id/syndicate/commander
	r_pocket = /obj/item/weapon/storage/pouch/pistol_holster/revolver

/datum/outfit/nuclear/unathi_equip()
	backpack_contents += list(/obj/item/device/modkit/unathi)

/datum/outfit/nuclear/tajaran_equip()
	backpack_contents += list(/obj/item/device/modkit/tajaran)

/datum/outfit/nuclear/skrell_equip()
	backpack_contents += list(/obj/item/device/modkit/skrell)

/datum/outfit/nuclear/ipc_equip()
	backpack_contents += list(/obj/item/rig_module/cooling_unit/advanced)

/datum/outfit/nuclear/vox_equip()
	backpack_contents += list(/obj/item/device/modkit/vox)
	l_hand = /obj/item/weapon/tank/nitrogen
	mask = /obj/item/clothing/mask/gas/vox
