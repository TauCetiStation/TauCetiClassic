var/global/vox_tick = 1

/mob/living/carbon/human/proc/equip_vox_raider()

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate
	R.set_frequency(SYND_FREQ) // Same frequency as the syndicate team in Nuke mode.
	equip_to_slot_or_del(R, slot_l_ear)

	equip_to_slot_or_del(new /obj/item/clothing/under/vox/vox_robes, slot_w_uniform)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots/vox, slot_shoes) // REPLACE THESE WITH CODED VOX ALTERNATIVES.
	equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow/vox, slot_gloves) // AS ABOVE.

	switch(vox_tick)
		if(1) // Vox raider!
			equip_to_slot_or_del(new /obj/item/clothing/suit/space/vox/carapace, slot_wear_suit)
			equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/vox/carapace, slot_head)
			equip_to_slot_or_del(new /obj/item/weapon/melee/telebaton, slot_belt)
			equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/monocle, slot_glasses) // REPLACE WITH CODED VOX ALTERNATIVE.
			equip_to_slot_or_del(new /obj/item/device/chameleon, slot_l_store)

			var/obj/item/weapon/spikethrower/W = new
			equip_to_slot_or_del(W, slot_r_hand)

		if(2) // Vox engineer!
			equip_to_slot_or_del(new /obj/item/clothing/suit/space/vox/pressure, slot_wear_suit)
			equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/vox/pressure, slot_head)
			equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full, slot_belt)
			equip_to_slot_or_del(new /obj/item/clothing/glasses/meson, slot_glasses) // REPLACE WITH CODED VOX ALTERNATIVE.
			equip_to_slot_or_del(new /obj/item/weapon/storage/box/emps, slot_r_hand)
			equip_to_slot_or_del(new /obj/item/device/multitool, slot_l_hand)

		if(3) // Vox saboteur!
			equip_to_slot_or_del(new /obj/item/clothing/suit/space/vox/stealth, slot_wear_suit)
			equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/vox/stealth, slot_head)
			equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full, slot_belt)
			equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/monocle, slot_glasses) // REPLACE WITH CODED VOX ALTERNATIVE.
			equip_to_slot_or_del(new /obj/item/weapon/card/emag, slot_l_store)
			equip_to_slot_or_del(new /obj/item/weapon/gun/dartgun/vox/raider, slot_r_hand)
			equip_to_slot_or_del(new /obj/item/device/multitool, slot_l_hand)

		if(4) // Vox medic!
			equip_to_slot_or_del(new /obj/item/clothing/suit/space/vox/medic, slot_wear_suit)
			equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/vox/medic, slot_head)
			equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full, slot_belt) // Who needs actual surgical tools?
			equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health, slot_glasses) // REPLACE WITH CODED VOX ALTERNATIVE.
			equip_to_slot_or_del(new /obj/item/weapon/circular_saw, slot_l_store)
			equip_to_slot_or_del(new /obj/item/weapon/gun/dartgun/vox/medical, slot_r_hand)

	equip_to_slot_or_del(new /obj/item/clothing/mask/breath/vox, slot_wear_mask)
	equip_to_slot_or_del(new /obj/item/device/flashlight, slot_r_store)

	var/obj/item/weapon/tank/nitrogen/NITRO = new
	equip_to_slot_or_del(NITRO, slot_s_store)
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
	equip_to_slot_or_del(W, slot_wear_id)
	vox_tick++

	if(vox_tick > 4)
		vox_tick = 1

	return 1
