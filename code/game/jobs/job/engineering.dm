/datum/job/chief_engineer
	title = "Chief Engineer"
	flag = CHIEF
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffeeaa"
	idtype = /obj/item/weapon/card/id/silver
	req_admin_notify = 1
	access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels,
			            access_teleporter, access_external_airlocks, access_atmospherics, access_emergency_storage, access_eva,
			            access_heads, access_construction, access_sec_doors, access_minisat,
			            access_ce, access_RC_announce, access_keycard_auth, access_tcomsat, access_ai_upload)
	minimal_access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels,
			            access_teleporter, access_external_airlocks, access_atmospherics, access_emergency_storage, access_eva,
			            access_heads, access_construction, access_sec_doors, access_minisat,
			            access_ce, access_RC_announce, access_keycard_auth, access_tcomsat, access_ai_upload)
	minimal_player_age = 7
	minimal_player_ingame_minutes = 2400

/datum/job/chief_engineer/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	switch(H.backbag)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/industrial(H), slot_back)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/eng(H), slot_back)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chief_engineer(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/workboots(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/hardhat/white(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(H), slot_belt)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), slot_gloves)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/ce(H), slot_l_ear)
	H.equip_to_slot_or_del(new /obj/item/device/pda/heads/ce(H), slot_l_store)
	if(H.backbag == 1)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/engineer(H), slot_r_hand)
	else
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/engineer(H.back), slot_in_backpack)

	return 1


/datum/job/engineer
	title = "Station Engineer"
	flag = ENGINEER
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	supervisors = "the chief engineer"
	selection_color = "#fff5cc"
	access = list(access_eva, access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_external_airlocks, access_construction, access_atmospherics)
	minimal_access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_external_airlocks, access_construction)
	alt_titles = list("Maintenance Technician","Engine Technician","Electrician")
	minimal_player_age = 3
	minimal_player_ingame_minutes = 540

/datum/job/engineer/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	switch(H.backbag)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/industrial(H), slot_back)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/eng(H), slot_back)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/engineer(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/workboots(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(H), slot_belt)
	if(prob(75))
		H.equip_to_slot_or_del(new /obj/item/clothing/head/hardhat/yellow(H), slot_head)
	else
		H.equip_to_slot_or_del(new /obj/item/clothing/head/hardhat/yellow/visor(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/device/t_scanner(H), slot_r_store)
	H.equip_to_slot_or_del(new /obj/item/device/pda/engineering(H), slot_l_store)
	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_eng(H), slot_l_ear)
	if(H.backbag == 1)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/engineer(H), slot_r_hand)
	else
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/engineer(H.back), slot_in_backpack)

	return 1


/datum/job/atmos
	title = "Atmospheric Technician"
	flag = ATMOSTECH
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	supervisors = "the chief engineer"
	selection_color = "#fff5cc"
	access = list(access_eva, access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_external_airlocks, access_construction, access_atmospherics, access_external_airlocks)
	minimal_access = list(access_atmospherics, access_maint_tunnels, access_emergency_storage, access_construction, access_external_airlocks)
	minimal_player_age = 3
	minimal_player_ingame_minutes = 600

/datum/job/atmos/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	switch(H.backbag)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/norm(H), slot_back)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/atmospheric_technician(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/workboots(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/device/pda/atmos(H), slot_l_store)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/atmostech/(H), slot_belt)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_eng(H), slot_l_ear)
	if(H.backbag == 1)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/engineer(H), slot_r_hand)
	else
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/engineer(H.back), slot_in_backpack)

	return 1

proc/identify_wire()
	var/list/wires = list(
			"Orange",
			"Dark red",
			"White",
			"Yellow",
			"Red",
			"Blue",
			"Green",
			"Grey",
			"Black",
			"Gold",
			"Aqua",
			"Pink"
		)
	var/list/wirefunction = list(
	"Id Scan",
	"Main power",
	"Backup power",
	"Door Bolts",
	"non",
	"non", // here should be a BACKUP POWER 1 and 2, but they doesn't used anywhere, so fuck them
	"Open door",
	"Ai control",
	"Electrify",
	"Door safety",
	"Timing mechanism",
	"Bolt light")
	var/info = ""
	for(var/i in 1 to 12)
		if(airlockWireColorToIndex[i] == 5 ||  airlockWireColorToIndex[i] == 6) // Exception for Backup powers
			continue
		info += "[wires[i]] is [wirefunction[airlockWireColorToIndex[i]]]<br>"
	return info