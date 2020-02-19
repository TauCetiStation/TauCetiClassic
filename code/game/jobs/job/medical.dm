/datum/job/cmo
	title = "Chief Medical Officer"
	flag = CMO
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffddf0"
	idtype = /obj/item/weapon/card/id/medGold
	req_admin_notify = 1
	access = list(
		access_medical, access_morgue, access_paramedic, access_genetics, access_heads,
		access_chemistry, access_virology, access_cmo, access_surgery, access_RC_announce,
		access_keycard_auth, access_sec_doors, access_psychiatrist, access_maint_tunnels,
		access_medbay_storage
	)
	minimal_player_age = 10
	minimal_player_ingame_minutes = 2400
	restricted_species = list(UNATHI, TAJARAN, DIONA)

/datum/job/cmo/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	switch(H.backbag)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/medic(H), SLOT_BACK)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/alt(H), SLOT_BACK)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/med(H), SLOT_BACK)
		if(5) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chief_medical_officer(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/device/pda/heads/cmo(H), SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat/cmo(H), SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/adv(H), SLOT_L_HAND)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight/pen(H), SLOT_S_STORE)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/cmo(H), SLOT_L_EAR)

	return TRUE


/datum/job/doctor
	title = "Medical Doctor"
	flag = DOCTOR
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 4
	spawn_positions = 3
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/med
	access = list(access_medical, access_morgue, access_surgery, access_maint_tunnels, access_medbay_storage)
	alt_titles = list("Surgeon", "Nurse")
	minimal_player_ingame_minutes = 960
	restricted_species = list(UNATHI, TAJARAN, DIONA)

/datum/job/doctor/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	switch(H.backbag)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/medic(H), SLOT_BACK)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/alt(H), SLOT_BACK)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/med(H), SLOT_BACK)
		if(5) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/adv(H), SLOT_L_HAND)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight/pen(H), SLOT_S_STORE)

	if(visualsOnly)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical(H), SLOT_W_UNIFORM)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(H), SLOT_WEAR_SUIT)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_med(H), SLOT_L_EAR)
	if (H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Surgeon")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical/blue(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(H), SLOT_WEAR_SUIT)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/surgery/blue(H), SLOT_HEAD)

			if("Medical Doctor")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical(H), SLOT_W_UNIFORM)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(H), SLOT_WEAR_SUIT)

			if("Nurse")
				if(H.gender == FEMALE)
					if(prob(50))
						H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/nursesuit(H), SLOT_W_UNIFORM)
					else
						H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/nurse(H), SLOT_W_UNIFORM)
					H.equip_to_slot_or_del(new /obj/item/clothing/head/nursehat(H), SLOT_HEAD)
				else
					H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical/purple(H), SLOT_W_UNIFORM)

	else
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical(H), SLOT_W_UNIFORM)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(H), SLOT_WEAR_SUIT)

	H.equip_to_slot_or_del(new /obj/item/device/pda/medical(H), SLOT_BELT)

	return TRUE

/datum/job/paramedic
	title = "Paramedic"
	flag = PARAMEDIC
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/med
	access = list(access_medical, access_morgue, access_paramedic, access_maint_tunnels, access_external_airlocks, access_sec_doors, access_research, access_mailsorting, access_medbay_storage, access_engineering_lobby)
	minimal_player_ingame_minutes = 1500 //they have too much access, so you have to play more to unlock it
	restricted_species = list(IPC, DIONA)

/datum/job/paramedic/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/fr_jacket(H), SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/adv(H), SLOT_L_HAND)

	switch(H.backbag)
		if(2)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/medic(H), SLOT_BACK)
		if(3)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/alt(H), SLOT_BACK)
		if(4)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/med(H), SLOT_BACK)
		if(5)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_med(H), SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/device/pda/medical(H), SLOT_BELT)

	return TRUE


//Chemist is a medical job damnit	//YEAH FUCK YOU SCIENCE	-Pete	//Guys, behave -Erro
/datum/job/chemist
	title = "Chemist"
	flag = CHEMIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/med
	access = list(access_medical, access_chemistry, access_medbay_storage)
	alt_titles = list("Pharmacist")
	minimal_player_ingame_minutes = 960

/datum/job/chemist/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0

	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chemist(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat/chemist(H), SLOT_WEAR_SUIT)

	switch(H.backbag)
		if(2)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/backpack_chem(H), SLOT_BACK)
		if(3)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/alt/chem(H), SLOT_BACK)
		if(4)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/chem(H), SLOT_BACK)
		if(5)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_med(H), SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/device/pda/chemist(H), SLOT_BELT)

	return TRUE


/datum/job/geneticist
	title = "Geneticist"
	flag = GENETICIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer and research director"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/med
	access = list(access_medical, access_morgue, access_genetics, access_research, access_medbay_storage)
	minimal_player_ingame_minutes = 960

/datum/job/geneticist/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/geneticist(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat/genetics(H), SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight/pen(H), SLOT_S_STORE)

	switch(H.backbag)
		if(2)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/backpack_gen(H), SLOT_BACK)
		if(3)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/alt/gen(H), SLOT_BACK)
		if(4)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/gen(H), SLOT_BACK)
		if(5)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_medsci(H), SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/device/pda/geneticist(H), SLOT_BELT)

	return TRUE


/datum/job/virologist
	title = "Virologist"
	flag = VIROLOGIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/med
	access = list(access_medical, access_virology, access_medbay_storage)
	alt_titles = list("Pathologist","Microbiologist")
	minimal_player_ingame_minutes = 960
	restricted_species = list(UNATHI, TAJARAN, DIONA)

/datum/job/virologist/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0

	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/virologist(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/surgical(H), SLOT_WEAR_MASK)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat/virologist(H), SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight/pen(H), SLOT_S_STORE)

	switch(H.backbag)
		if(2)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/backpack_vir(H), SLOT_BACK)
		if(3)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/alt/vir(H), SLOT_BACK)
		if(4)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/vir(H), SLOT_BACK)
		if(5)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_med(H), SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/device/pda/viro(H), SLOT_BELT)

	return TRUE


/datum/job/psychiatrist
	title = "Psychiatrist"
	flag = PSYCHIATRIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/med
	access = list(access_medical, access_psychiatrist, access_medbay_storage)
	alt_titles = list("Psychologist")
	minimal_player_ingame_minutes = 960

/datum/job/psychiatrist/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	switch(H.backbag)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(H), SLOT_BACK)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/alt(H), SLOT_BACK)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/norm(H), SLOT_BACK)
		if(5) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(H), SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(H), SLOT_SHOES)

	if(visualsOnly)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical(H), SLOT_W_UNIFORM)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_med(H), SLOT_L_EAR)
	if (H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Psychiatrist")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/psych(H), SLOT_W_UNIFORM)
			if("Psychologist")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/psych/turtleneck(H), SLOT_W_UNIFORM)
	else
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/device/pda/medical(H), SLOT_BELT)

	return TRUE


/datum/job/intern
	title = "Medical Intern"
	flag = INTERN
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/med
	access = list(access_medical)

/datum/job/intern/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)
		return 0
	switch(H.backbag)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(H), SLOT_BACK)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/alt(H), SLOT_BACK)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/norm(H), SLOT_BACK)
		if(5) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), SLOT_SHOES)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_med(H), SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/device/pda, SLOT_BELT)


	return TRUE