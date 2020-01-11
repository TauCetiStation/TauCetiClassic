/datum/job/captain
	title = "Captain"
	flag = CAPTAIN
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "Nanotrasen officials and Space law"
	selection_color = "#ccccff"
	idtype = /obj/item/weapon/card/id/gold
	req_admin_notify = 1
	access = list() 			//See get_access()
	minimal_player_age = 14
	minimal_player_ingame_minutes = 3900
	restricted_species = list(SKRELL, UNATHI, TAJARAN, DIONA, IPC)

/datum/job/captain/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0

	switch(H.backbag)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/captain(H), SLOT_BACK)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/alt(H), SLOT_BACK)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/cap(H), SLOT_BACK)
		if(5) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)

	var/obj/item/clothing/under/U = new /obj/item/clothing/under/rank/captain(H)
	if(H.age > (H.species.min_age + H.species.max_age) / 2)
		var/obj/item/clothing/accessory/medal/gold/captain/new_medal = new
		U.accessories += new_medal
		new_medal.on_attached(U, H, TRUE)
	H.equip_to_slot_or_del(U, SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/caphat(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(H), SLOT_GLASSES)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain(H), SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/device/pda/captain(H), SLOT_BELT)
	if(H.backbag == 1)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/ids(H), SLOT_R_HAND)
	else
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/ids(H.back), SLOT_IN_BACKPACK)

	var/obj/item/weapon/implant/mindshield/loyalty/L = new(H)
	L.inject(H)
	START_PROCESSING(SSobj, L)
	to_chat(world, "<b>[H.real_name] is the captain!</b>")//maybe should be announcment, not OOC notification?

	score["captain"] += H.real_name

	return TRUE

/datum/job/captain/get_access()
	return get_all_accesses()


/datum/job/hop
	title = "Head of Personnel"
	flag = HOP
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ddddff"
	idtype = /obj/item/weapon/card/id/silver
	req_admin_notify = 1
	minimal_player_age = 10
	minimal_player_ingame_minutes = 2400
	access = list(
		access_security, access_sec_doors, access_brig, access_forensics_lockers,
		access_medical, access_engine, access_change_ids, access_ai_upload, access_eva, access_heads,
		access_all_personal_lockers, access_maint_tunnels, access_bar, access_janitor, access_construction, access_morgue,
		access_crematorium, access_kitchen, access_cargo, access_cargo_bot, access_mailsorting, access_qm, access_hydroponics, access_lawyer,
		access_theatre, access_chapel_office, access_library, access_research, access_mining, access_heads_vault, access_mining_station,
		access_clown, access_mime, access_hop, access_RC_announce, access_keycard_auth, access_gateway, access_recycler, access_detective, access_barber
	)
	restricted_species = list(SKRELL, UNATHI, TAJARAN, DIONA, IPC)


/datum/job/hop/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	switch(H.backbag)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(H), SLOT_BACK)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/alt(H), SLOT_BACK)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/norm(H), SLOT_BACK)
		if(5) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/head_of_personnel(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), SLOT_SHOES)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/hop(H), SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/device/pda/heads/hop(H), SLOT_BELT)
	if(H.backbag == 1)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/ids(H), SLOT_R_HAND)
	else
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/ids(H.back), SLOT_IN_BACKPACK)

	return TRUE
