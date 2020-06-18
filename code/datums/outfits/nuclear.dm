/datum/outfit/nuclear
	name = "Nuclear Agent"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/boots/combat
	id = /obj/item/weapon/card/id/syndicate/nuker
	belt = /obj/item/weapon/gun/projectile/automatic/pistol
	l_ear = /obj/item/device/radio/headset/syndicate

/datum/outfit/nuclear/leader
	name = "Nuclear Commander"
	id = /obj/item/weapon/card/id/syndicate/commander
	belt = /obj/item/weapon/gun/projectile/revolver

/datum/outfit/nuclear/post_equip(mob/living/carbon/human/synd_mob, visualsOnly = FALSE)
	var/back = null
	switch(synd_mob.backbag)
		if(2)
			back = /obj/item/weapon/storage/backpack
		if(3)
			back = /obj/item/weapon/storage/backpack/alt
		if(4)
			back = /obj/item/weapon/storage/backpack/satchel/norm
		if(5)
			back = /obj/item/weapon/storage/backpack/satchel
	synd_mob.equip_to_slot_or_del(new back(synd_mob), SLOT_BACK)

	synd_mob.equip_to_slot_or_del(new /obj/item/device/radio/uplink(synd_mob), SLOT_IN_BACKPACK)
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/pill/cyanide(synd_mob), SLOT_IN_BACKPACK)
	synd_mob.species.after_job_equip(synd_mob, SSjob.GetJob("Test Subject"))
	if(belt == /obj/item/weapon/gun/projectile/revolver)
		synd_mob.equip_to_slot_or_del(new /obj/item/ammo_box/a357(synd_mob), SLOT_IN_BACKPACK)
	else
		synd_mob.equip_to_slot_or_del(new /datum/uplink_item/ammo/pistol(synd_mob), SLOT_IN_BACKPACK)

	switch(synd_mob.get_species())
		if(UNATHI)
			synd_mob.equip_to_slot_or_del(new /obj/item/device/modkit/syndie/unathi(synd_mob), SLOT_IN_BACKPACK)
			synd_mob.equip_to_slot_or_del(new /obj/item/clothing/shoes/boots/combat/cut(synd_mob), SLOT_SHOES)
		if(TAJARAN)
			synd_mob.equip_to_slot_or_del(new /obj/item/device/modkit/syndie/tajaran(synd_mob), SLOT_IN_BACKPACK)
			synd_mob.equip_to_slot_or_del(new /obj/item/clothing/shoes/boots/combat/cut(synd_mob), SLOT_SHOES)
		if(SKRELL)
			synd_mob.equip_to_slot_or_del(new /obj/item/device/modkit/syndie/skrell(synd_mob), SLOT_IN_BACKPACK)
			synd_mob.equip_to_slot_or_del(new /obj/item/clothing/shoes/boots/combat(synd_mob), SLOT_SHOES)
		if(VOX)
			synd_mob.equip_to_slot_or_del(new /obj/item/weapon/tank/nitrogen(synd_mob), SLOT_L_HAND)
			synd_mob.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/vox(synd_mob), SLOT_WEAR_MASK)
			synd_mob.equip_to_slot_or_del(new /obj/item/device/modkit/syndie/vox(synd_mob), SLOT_IN_BACKPACK)
			synd_mob.equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots/vox(synd_mob), SLOT_SHOES)
		else
			synd_mob.equip_to_slot_or_del(new /obj/item/clothing/shoes/boots/combat(synd_mob), SLOT_SHOES)
