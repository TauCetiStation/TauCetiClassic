/datum/job/chief_engineer
	title = "Chief Engineer"
	flag = CHIEF
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffeeaa"
	idtype = /obj/item/weapon/card/id/engGold
	req_admin_notify = 1
	access = list(
		access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels,
		access_teleporter, access_external_airlocks, access_atmospherics, access_emergency_storage, access_eva,
		access_heads, access_construction, access_sec_doors, access_minisat,
		access_ce, access_RC_announce, access_keycard_auth, access_tcomsat, access_ai_upload, access_engineering_lobby
	)
	minimal_player_age = 7
	minimal_player_ingame_minutes = 2400
	restricted_species = list(UNATHI, TAJARAN, DIONA)

	survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen/engi)

	prevent_survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen)

/datum/job/chief_engineer/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	switch(H.backbag)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/industrial(H), SLOT_BACK)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/alt(H), SLOT_BACK)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/eng(H), SLOT_BACK)
		if(5) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chief_engineer(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/workboots(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/hardhat/white(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(H), SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), SLOT_GLOVES)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/ce(H), SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/device/pda/heads/ce(H), SLOT_L_STORE)

	return TRUE


/datum/job/engineer
	title = "Station Engineer"
	flag = ENGINEER
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	supervisors = "the chief engineer"
	selection_color = "#fff5cc"
	idtype = /obj/item/weapon/card/id/eng
	access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_external_airlocks, access_construction, access_engineering_lobby)
	alt_titles = list("Maintenance Technician","Engine Technician","Electrician")
	minimal_player_age = 3
	minimal_player_ingame_minutes = 540

	survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen/engi)

	prevent_survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen)

/datum/job/engineer/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	switch(H.backbag)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/industrial(H), SLOT_BACK)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/alt(H), SLOT_BACK)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/eng(H), SLOT_BACK)
		if(5) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/engineer(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/workboots(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(H), SLOT_BELT)
	if(prob(75))
		H.equip_to_slot_or_del(new /obj/item/clothing/head/hardhat/yellow(H), SLOT_HEAD)
	else
		H.equip_to_slot_or_del(new /obj/item/clothing/head/hardhat/yellow/visor(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/device/t_scanner(H), SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/device/pda/engineering(H), SLOT_L_STORE)
	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_eng(H), SLOT_L_EAR)

	return TRUE


/datum/job/atmos
	title = "Atmospheric Technician"
	flag = ATMOSTECH
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	supervisors = "the chief engineer"
	selection_color = "#fff5cc"
	idtype = /obj/item/weapon/card/id/eng
	access = list(access_atmospherics, access_maint_tunnels, access_emergency_storage, access_construction, access_external_airlocks, access_engineering_lobby)
	minimal_player_age = 3
	minimal_player_ingame_minutes = 600

	survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen/engi)

	prevent_survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen)

/datum/job/atmos/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	switch(H.backbag)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/industrial(H), SLOT_BACK)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/alt(H), SLOT_BACK)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/eng(H), SLOT_BACK)
		if(5) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/atmospheric_technician(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/workboots(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/device/pda/atmos(H), SLOT_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/atmostech/(H), SLOT_BELT)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_eng(H), SLOT_L_EAR)

	return TRUE


/datum/job/technical_assistant
	title = "Technical Assistant"
	flag = TECHNICASSISTANT
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the chief engineer"
	selection_color = "#fff5cc"
	idtype = /obj/item/weapon/card/id/eng
	access = list(access_engineering_lobby, access_construction, access_maint_tunnels)

/datum/job/technical_assistant/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)
		return 0
	switch(H.backbag)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/industrial(H), SLOT_BACK)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/alt(H), SLOT_BACK)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/eng(H), SLOT_BACK)
		if(5) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/color/yellow(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/yellow(H), SLOT_SHOES)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/pda, SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_eng(H), SLOT_L_EAR)

	return TRUE


/proc/get_airlock_wires_identification()
	var/list/wire_list = same_wires[/obj/machinery/door/airlock]
	var/list/wire_functions_list = list(
		"[AIRLOCK_WIRE_IDSCAN]"      = "ID scan",
		"[AIRLOCK_WIRE_MAIN_POWER1]" = "main power",
		"[AIRLOCK_WIRE_MAIN_POWER2]" = "backup power",
		"[AIRLOCK_WIRE_DOOR_BOLTS]"  = "door Bolts",
		"[AIRLOCK_WIRE_OPEN_DOOR]"   = "open door",
		"[AIRLOCK_WIRE_AI_CONTROL]"  = "ai control",
		"[AIRLOCK_WIRE_ELECTRIFY]"   = "electrify",
		"[AIRLOCK_WIRE_SAFETY]"      = "door safety",
		"[AIRLOCK_WIRE_SPEED]"       = "timing mechanism",
		"[AIRLOCK_WIRE_LIGHT]"       = "bolt light"
	)

	var/info = ""

	for(var/wire in wire_list)
		var/current_wire_index = wire_list[wire]
		var/current_wire_function = wire_functions_list["[current_wire_index]"]

		if(current_wire_function)
			info += "[capitalize(wire)] wire is [current_wire_function].<br>"

	return info
