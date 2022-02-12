/datum/outfit/spy
	name = "Espionage Agent"
	uniform = /obj/item/clothing/under/syndicate
	glasses = /obj/item/clothing/glasses/sunglasses/big
	shoes = /obj/item/clothing/shoes/boots/combat
	l_ear = /obj/item/device/radio/headset/syndicate/alt
	id = /obj/item/weapon/card/id/syndicate
	belt = /obj/item/weapon/gun/projectile/automatic/pistol
	back = /obj/item/weapon/storage/backpack/satchel
	backpack_contents = list(
		/obj/item/weapon/reagent_containers/pill/cyanide,
		/obj/item/ammo_box/magazine/m9mm,
		/obj/item/ammo_box/magazine/m9mm,
		)
	implants = list(
		/obj/item/weapon/implant/dexplosive
		)
	survival_box = TRUE

	survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen/engi)
	prevent_survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen)
