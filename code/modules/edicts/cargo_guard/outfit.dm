// CARGO GUARD OUTFIT
// Shared by the edict job and the cargotech "Private Security Company" quality (positiveish.dm).
/datum/outfit/job/cargo_psc
	name = OUTFIT_JOB_NAME("Cargo Guard")

	uniform = /obj/item/clothing/under/rank/cargotech
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/boots

	l_ear = /obj/item/device/radio/headset/headset_cargo
	belt = /obj/item/device/pda/cargo

	l_hand_back = /obj/item/weapon/handcuffs

	backpack_contents = list(/obj/item/weapon/paper/psc)

	back_style = BACKPACK_STYLE_SECURITY

// Tajaran can't handle the WJPP, so they carry a flash instead of the pistol + spare mags.
/datum/outfit/job/cargo_psc/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(H.get_species() == TAJARAN)
		backpack_contents += /obj/item/device/flash
	else
		suit_store = /obj/item/weapon/gun/projectile/automatic/pistol/wjpp
		backpack_contents += /obj/item/ammo_box/magazine/wjpp/rubber
		backpack_contents += /obj/item/ammo_box/magazine/wjpp/rubber
