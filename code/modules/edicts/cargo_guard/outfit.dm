// CARGO GUARD ("Карго ЧОП") OUTFIT
/datum/outfit/job/cargo_psc
	name = OUTFIT_JOB_NAME("Cargo Guard")

	uniform = /obj/item/clothing/under/rank/cargotech
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/boots

	l_ear = /obj/item/device/radio/headset/headset_cargo
	belt = /obj/item/device/pda/cargo

	suit_store = /obj/item/weapon/gun/projectile/automatic/pistol/wjpp
	l_hand_back = /obj/item/weapon/handcuffs

	backpack_contents = list(
		/obj/item/ammo_box/magazine/wjpp/rubber,
		/obj/item/ammo_box/magazine/wjpp/rubber,
		/obj/item/weapon/paper/psc
		)

	back_style = BACKPACK_STYLE_SECURITY
