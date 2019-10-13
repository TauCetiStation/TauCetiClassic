/*
todo:
* spawn as (Color) Teammate antag for credit roll.
*/

/datum/job/teammate
	title = "Teammate"
	flag = ENGINEER
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 40
	spawn_positions = 40
	supervisors = "the team captain"
	selection_color = "#ff9933"
	idtype = /obj/item/weapon/card/id/noteam
	access = list(access_engine_equip, access_maint_tunnels, access_external_airlocks, access_construction)
//	alt_titles = list("Red Teammate","Yellow Teammate","Green Teammate","Blue Teammate")
	minimal_player_age = 3
	minimal_player_ingame_minutes = 540
	restricted_species = list(SKRELL, UNATHI, TAJARAN, DIONA, IPC)

	survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen/engi)

	prevent_survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen)

/datum/job/teammate/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	switch(H.backbag)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/industrial(H), SLOT_BACK)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/eng(H), SLOT_BACK)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/color/orange(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(H), SLOT_SHOES)
	if(visualsOnly)
		return

/*
	if (H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Red Teammate")
				H.equip_to_slot_or_del(new /obj/item/clothing/mask/breath(H), SLOT_WEAR_MASK)
				H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sechud/tactical(H), SLOT_GLASSES)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/ert/scrapheap/red(H), SLOT_HEAD)
				H.equip_to_slot_or_del(new /obj/item/clothing/under/color/red(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/ert/scrapheap/red(H), SLOT_WEAR_SUIT)
				H.equip_to_slot_or_del(new /obj/item/weapon/tank/oxygen/red(H), SLOT_S_STORE)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(H), SLOT_BELT)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/industrial(H), SLOT_BACK)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/workboots(H), SLOT_SHOES)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/toolbox/scrapheap/red(H), SLOT_L_HAND)
				H.equip_to_slot_or_del(new /obj/item/toy/crayon/red(H), SLOT_R_STORE)
				H.equip_to_slot_or_del(new /obj/item/device/radio(H), SLOT_L_STORE)
			if("Yellow Teammate")
				H.equip_to_slot_or_del(new /obj/item/clothing/mask/breath(H), SLOT_WEAR_MASK)
				H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sechud/tactical(H), SLOT_GLASSES)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/ert/scrapheap/yellow(H), SLOT_HEAD)
				H.equip_to_slot_or_del(new /obj/item/clothing/under/color/yellow(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/ert/scrapheap/yellow(H), SLOT_WEAR_SUIT)
				H.equip_to_slot_or_del(new /obj/item/weapon/tank/oxygen/yellow(H), SLOT_S_STORE)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(H), SLOT_BELT)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/industrial(H), SLOT_BACK)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/workboots(H), SLOT_SHOES)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/toolbox/scrapheap/yellow(H), SLOT_L_HAND)
				H.equip_to_slot_or_del(new /obj/item/toy/crayon/yellow(H), SLOT_R_STORE)
				H.equip_to_slot_or_del(new /obj/item/device/radio(H), SLOT_L_STORE)
			if("Green Teammate")
				H.equip_to_slot_or_del(new /obj/item/clothing/mask/breath(H), SLOT_WEAR_MASK)
				H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sechud/tactical(H), SLOT_GLASSES)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/ert/scrapheap/green(H), SLOT_HEAD)
				H.equip_to_slot_or_del(new /obj/item/clothing/under/color/green(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/ert/scrapheap/green(H), SLOT_WEAR_SUIT)
				H.equip_to_slot_or_del(new /obj/item/weapon/tank/oxygen/yellow/green(H), SLOT_S_STORE)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(H), SLOT_BELT)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/industrial(H), SLOT_BACK)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/workboots(H), SLOT_SHOES)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/toolbox/scrapheap/green(H), SLOT_L_HAND)
				H.equip_to_slot_or_del(new /obj/item/toy/crayon/green(H), SLOT_R_STORE)
				H.equip_to_slot_or_del(new /obj/item/device/radio(H), SLOT_L_STORE)
			if("Blue Teammate")
				H.equip_to_slot_or_del(new /obj/item/clothing/mask/breath(H), SLOT_WEAR_MASK)
				H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sechud/tactical(H), SLOT_GLASSES)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/ert/scrapheap/blue(H), SLOT_HEAD)
				H.equip_to_slot_or_del(new /obj/item/clothing/under/lightblue(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/ert/scrapheap/blue(H), SLOT_WEAR_SUIT)
				H.equip_to_slot_or_del(new /obj/item/weapon/tank/oxygen(H), SLOT_S_STORE)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(H), SLOT_BELT)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/industrial(H), SLOT_BACK)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/workboots(H), SLOT_SHOES)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/toolbox/scrapheap/blue(H), SLOT_L_HAND)
				H.equip_to_slot_or_del(new /obj/item/toy/crayon/blue(H), SLOT_R_STORE)
				H.equip_to_slot_or_del(new /obj/item/device/radio(H), SLOT_L_STORE)
*/
	return TRUE