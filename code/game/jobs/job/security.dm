/datum/job/hos
	title = "Head of Security"
	flag = HOS
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffdddd"
	idtype = /obj/item/weapon/card/id/secGold
	req_admin_notify = 1
	access = list(
		access_security, access_sec_doors, access_brig, access_armory, access_court,
		access_forensics_lockers, access_morgue, access_maint_tunnels, access_all_personal_lockers,
		access_research, access_engine, access_mining, access_medical, access_construction, access_mailsorting,
		access_heads, access_hos, access_RC_announce, access_keycard_auth, access_gateway, access_detective
	)
	minimal_player_age = 14
	minimal_player_ingame_minutes = 2400
	restricted_species = list(TAJARAN, DIONA, IPC)

/datum/job/hos/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	switch(H.backbag)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/security(H), SLOT_BACK)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/sec(H), SLOT_BACK)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)
	if(H.gender == FEMALE)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/head_of_security_fem(H), SLOT_W_UNIFORM)
	else
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/head_of_security(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sechud(H), SLOT_GLASSES)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun(H), SLOT_S_STORE)
	if(H.age > 49)
		H.equip_to_slot_or_del(new /obj/item/clothing/accessory/medal/silver/security(H), SLOT_L_HAND)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/flash(H), SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/hos(H), SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/device/pda/heads/hos(H), SLOT_BELT)
	if(H.backbag == 1)
		H.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(H), SLOT_L_STORE)
	else
		H.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(H), SLOT_IN_BACKPACK)
	var/obj/item/weapon/implant/mindshield/loyalty/L = new(H)
	L.inject(H)
	START_PROCESSING(SSobj, L)
	return TRUE


/datum/job/warden
	title = "Warden"
	flag = WARDEN
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of security"
	selection_color = "#ffeeee"
	idtype = /obj/item/weapon/card/id/sec
	access = list(access_security, access_sec_doors, access_brig, access_armory, access_court, access_maint_tunnels)
	minimal_player_age = 5
	minimal_player_ingame_minutes = 1800
	restricted_species = list(TAJARAN, DIONA, IPC)

/datum/job/warden/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	switch(H.backbag)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/security(H), SLOT_BACK)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/sec(H), SLOT_BACK)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)
	if(H.gender == FEMALE)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/warden_fem(H), SLOT_W_UNIFORM)
	else
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/warden(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sechud(H), SLOT_GLASSES)
	H.equip_to_slot_or_del(new /obj/item/device/flash(H), SLOT_L_STORE)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sec(H), SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/device/pda/warden(H), SLOT_BELT)
	if(H.backbag == 1)
		H.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(H), SLOT_L_HAND)
	else
		H.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(H), SLOT_IN_BACKPACK)

	var/obj/item/weapon/implant/mindshield/L = new(H)
	L.inject(H)

	return TRUE


/datum/job/detective
	title = "Detective"
	flag = DETECTIVE
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of security"
	selection_color = "#ffeeee"
	idtype = /obj/item/weapon/card/id/sec
	access = list(access_security, access_sec_doors, access_detective, access_maint_tunnels, access_court)
	minimal_player_age = 3
	minimal_player_ingame_minutes = 1560
	restricted_species = list(DIONA, IPC)

/datum/job/detective/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	switch(H.backbag)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(H), SLOT_BACK)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/norm(H), SLOT_BACK)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/det(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/det_suit(H), SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/det_hat(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/weapon/lighter/zippo(H), SLOT_L_STORE)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sec(H), SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/device/pda/detective(H), SLOT_BELT)
	if(H.backbag == 1)//Why cant some of these things spawn in his office?
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/evidence(H), SLOT_L_HAND)
		H.equip_to_slot_or_del(new /obj/item/device/detective_scanner(H), SLOT_R_STORE)
	else
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/evidence(H), SLOT_IN_BACKPACK)
		H.equip_to_slot_or_del(new /obj/item/device/detective_scanner(H), SLOT_IN_BACKPACK)

	return TRUE


/datum/job/officer
	title = "Security Officer"
	flag = OFFICER
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	supervisors = "the head of security"
	selection_color = "#ffeeee"
	idtype = /obj/item/weapon/card/id/sec
	access = list(access_security, access_sec_doors, access_brig, access_court, access_maint_tunnels)
	minimal_player_age = 3
	minimal_player_ingame_minutes = 1560
	restricted_species = list(DIONA, TAJARAN, IPC)

/datum/job/officer/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	switch(H.backbag)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/security(H), SLOT_BACK)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/sec(H), SLOT_BACK)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/security(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(H), SLOT_S_STORE)
	H.equip_to_slot_or_del(new /obj/item/device/flash(H), SLOT_L_STORE)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sec(H), SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/device/pda/security(H), SLOT_BELT)
	if(H.backbag == 1)
		H.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(H), SLOT_L_HAND)
	else
		H.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(H), SLOT_IN_BACKPACK)

	var/obj/item/weapon/implant/mindshield/L = new(H)
	L.inject(H)

	return TRUE

/datum/job/forensic
	title = "Forensic Technician"
	flag = FORENSIC
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of security"
	selection_color = "#ffeeee"
	idtype = /obj/item/weapon/card/id/sec
	access = list(access_sec_doors, access_forensics_lockers, access_morgue, access_maint_tunnels, access_court)
	minimal_player_age = 3
	minimal_player_ingame_minutes = 1560

/datum/job/forensic/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	switch(H.backbag)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(H), SLOT_BACK)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/norm(H), SLOT_BACK)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/forensic_technician(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/red(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/forensics/red(H), SLOT_WEAR_SUIT)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sec(H), SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/device/pda/forensic(H), SLOT_BELT)
	if(H.backbag == 1)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/evidence(H), SLOT_L_HAND)
		H.equip_to_slot_or_del(new /obj/item/device/detective_scanner(H), SLOT_R_STORE)
	else
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/evidence(H), SLOT_IN_BACKPACK)
		H.equip_to_slot_or_del(new /obj/item/device/detective_scanner(H), SLOT_IN_BACKPACK)

	return TRUE
