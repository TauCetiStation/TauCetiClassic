/datum/outfit/nuclear
	name = "Nuclear Agent"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/boots/combat
	l_ear = /obj/item/device/radio/headset/syndicate
	id = /obj/item/weapon/card/id/syndicate/nuker
	belt = /obj/item/weapon/gun/projectile/automatic/pistol
	backpack_contents = list(
		/obj/item/device/radio/uplink,
		/obj/item/weapon/reagent_containers/pill/cyanide,
		/datum/uplink_item/ammo/pistol,
		)
	implants = list(
		/obj/item/weapon/implant/dexplosive
		)
	box = /obj/item/weapon/storage/box/survival

/datum/outfit/nuclear/leader
	name = "Nuclear Commander"
	id = /obj/item/weapon/card/id/syndicate/commander
	belt = /obj/item/weapon/gun/projectile/revolver
	backpack_contents = list(
		/obj/item/device/radio/uplink,
		/obj/item/weapon/reagent_containers/pill/cyanide,
		/obj/item/ammo_box/a357,
		)

/datum/outfit/nuclear/pre_equip(mob/living/carbon/human/synd_mob)
	switch(synd_mob.backbag)
		if(1, 2)
			back = /obj/item/weapon/storage/backpack
		if(3)
			back = /obj/item/weapon/storage/backpack/alt
		if(4)
			back = /obj/item/weapon/storage/backpack/satchel/norm
		if(5)
			back = /obj/item/weapon/storage/backpack/satchel
	
	switch(synd_mob.get_species())
		if(UNATHI)
			backpack_contents += list(/obj/item/device/modkit/syndie/unathi)
			shoes = /obj/item/clothing/shoes/boots/combat/cut
		if(TAJARAN)
			backpack_contents += list(/obj/item/device/modkit/syndie/tajaran)
			shoes = /obj/item/clothing/shoes/boots/combat/cut
		if(SKRELL)
			backpack_contents += list(/obj/item/device/modkit/syndie/skrell)
		if(VOX)
			backpack_contents += list(/obj/item/device/modkit/syndie/vox)
			l_hand = /obj/item/weapon/tank/nitrogen
			mask = /obj/item/clothing/mask/gas/vox
			shoes = /obj/item/clothing/shoes/magboots/vox
