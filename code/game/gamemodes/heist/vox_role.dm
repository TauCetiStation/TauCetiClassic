var/global/vox_tick = 1

/mob/living/carbon/human/proc/equip_vox_raider()

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate
	R.set_frequency(SYND_FREQ) // Same frequency as the syndicate team in Nuke mode.
	equip_to_slot_or_del(R, SLOT_L_EAR)

	equip_to_slot_or_del(new /obj/item/clothing/under/vox/vox_robes, SLOT_W_UNIFORM)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots/vox, SLOT_SHOES) // REPLACE THESE WITH CODED VOX ALTERNATIVES.
	equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow/vox, SLOT_GLOVES) // AS ABOVE.
	equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/kitbag, SLOT_BACK)
	equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/small_firstaid_kit/nutriment, SLOT_IN_BACKPACK)

	switch(vox_tick)
		if(1) // Vox raider!
			equip_to_slot_or_del(new /obj/item/clothing/suit/space/vox/carapace, SLOT_WEAR_SUIT)
			equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/vox/carapace, SLOT_HEAD)
			equip_to_slot_or_del(new /obj/item/weapon/melee/telebaton, SLOT_BELT)
			equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/monocle, SLOT_GLASSES) // REPLACE WITH CODED VOX ALTERNATIVE.
			equip_to_slot_or_del(new /obj/item/device/chameleon, SLOT_L_STORE)

			var/obj/item/weapon/spikethrower/W = new
			equip_to_slot_or_del(W, SLOT_IN_BACKPACK)

		if(2) // Vox engineer!
			equip_to_slot_or_del(new /obj/item/clothing/suit/space/vox/pressure, SLOT_WEAR_SUIT)
			equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/vox/pressure, SLOT_HEAD)
			equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full, SLOT_BELT)
			equip_to_slot_or_del(new /obj/item/clothing/glasses/meson, SLOT_GLASSES) // REPLACE WITH CODED VOX ALTERNATIVE.
			equip_to_slot_or_del(new /obj/item/device/multitool, SLOT_IN_BACKPACK)
			equip_to_slot_or_del(new /obj/item/weapon/storage/box/emps, SLOT_IN_BACKPACK)

		if(3) // Vox saboteur!
			equip_to_slot_or_del(new /obj/item/clothing/suit/space/vox/stealth, SLOT_WEAR_SUIT)
			equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/vox/stealth, SLOT_HEAD)
			equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full, SLOT_BELT)
			equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/monocle, SLOT_GLASSES) // REPLACE WITH CODED VOX ALTERNATIVE.
			equip_to_slot_or_del(new /obj/item/weapon/card/emag, SLOT_L_STORE)
			equip_to_slot_or_del(new /obj/item/device/multitool, SLOT_IN_BACKPACK)
			equip_to_slot_or_del(new /obj/item/weapon/gun/dartgun/vox/raider, SLOT_IN_BACKPACK)

		if(4) // Vox medic!
			equip_to_slot_or_del(new /obj/item/clothing/suit/space/vox/medic, SLOT_WEAR_SUIT)
			equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/vox/medic, SLOT_HEAD)
			equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full, SLOT_BELT) // Who needs actual surgical tools?
			equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health, SLOT_GLASSES) // REPLACE WITH CODED VOX ALTERNATIVE.
			equip_to_slot_or_del(new /obj/item/weapon/circular_saw, SLOT_L_STORE)
			equip_to_slot_or_del(new /obj/item/weapon/gun/dartgun/vox/medical, SLOT_IN_BACKPACK)

	equip_to_slot_or_del(new /obj/item/clothing/mask/gas/vox, SLOT_WEAR_MASK)
	equip_to_slot_or_del(new /obj/item/device/flashlight, SLOT_R_STORE)

	var/obj/item/weapon/tank/nitrogen/NITRO = new
	equip_to_slot_or_del(NITRO, SLOT_S_STORE)
	internal = NITRO
	internals.icon_state = "internal1"

	var/obj/item/weapon/card/id/syndicate/C = new(src)
	C.name = "[real_name]'s Legitimate Human ID Card"
	C.icon_state = "id"
	C.access = list(access_syndicate)
	C.assignment = "Trader"
	C.registered_name = real_name
	C.registered_user = src
	var/obj/item/weapon/storage/wallet/W = new(src)
	W.handle_item_insertion(C)
	spawn_money(rand(50, 150) * 10, W)
	equip_to_slot_or_del(W, SLOT_WEAR_ID)
	vox_tick++

	if(vox_tick > 4)
		vox_tick = 1

	return 1
