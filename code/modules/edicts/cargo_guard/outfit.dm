// CARGO GUARD OUTFIT
/datum/outfit/job/cargo_psc
	name = OUTFIT_JOB_NAME("Cargo Guard")

	uniform = /obj/item/clothing/under/rank/cargotech
	shoes = /obj/item/clothing/shoes/boots

	l_ear = /obj/item/device/radio/headset/headset_cargo
	belt = /obj/item/device/pda/cargo

	back_style = BACKPACK_STYLE_SECURITY

/datum/outfit/job/cargo_psc/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_or_collect(new /obj/item/clothing/suit/armor/vest(H), SLOT_WEAR_SUIT)
	if(visualsOnly)
		return

	H.equip_or_collect(new /obj/item/weapon/paper/psc(H), SLOT_IN_BACKPACK)
	if(H.get_species() == TAJARAN)
		H.equip_or_collect(new /obj/item/device/flash(H), SLOT_IN_BACKPACK)
	else
		H.equip_or_collect(new /obj/item/weapon/gun/projectile/automatic/pistol/wjpp(H), SLOT_S_STORE)
		H.equip_or_collect(new /obj/item/ammo_box/magazine/wjpp/rubber(H), SLOT_IN_BACKPACK)
		H.equip_or_collect(new /obj/item/ammo_box/magazine/wjpp/rubber(H), SLOT_IN_BACKPACK)
	H.equip_or_collect(new /obj/item/weapon/handcuffs(H), SLOT_IN_BACKPACK)
