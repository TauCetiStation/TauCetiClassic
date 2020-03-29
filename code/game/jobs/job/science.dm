/datum/job/rd
	title = "Research Director"
	flag = RD
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffddff"
	idtype = /obj/item/weapon/card/id/sciGold
	req_admin_notify = 1
	access = list(
		access_rd, access_heads, access_tox, access_genetics, access_morgue,
		access_tox_storage, access_teleporter, access_sec_doors, access_minisat,
		access_research, access_robotics, access_xenobiology, access_ai_upload,
		access_RC_announce, access_keycard_auth, access_tcomsat, access_gateway, access_xenoarch, access_maint_tunnels
	)
	minimal_player_age = 7
	minimal_player_ingame_minutes = 2400
	restricted_species = list(UNATHI, TAJARAN, DIONA)

/datum/job/rd/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/research_director(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(H), SLOT_WEAR_SUIT)

	switch(H.backbag)
		if(2)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/backpack_tox(H), SLOT_BACK)
		if(3)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/alt/tox(H), SLOT_BACK)
		if(4)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/tox(H), SLOT_BACK)
		if(5)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/rd(H), SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/device/pda/heads/rd(H), SLOT_BELT)

	return TRUE


/datum/job/scientist
	title = "Scientist"
	flag = SCIENTIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	supervisors = "the research director"
	selection_color = "#ffeeff"
	idtype = /obj/item/weapon/card/id/sci
	access = list(access_tox, access_tox_storage, access_research, access_xenoarch)
	alt_titles = list("Phoron Researcher")
	minimal_player_ingame_minutes = 1560

/datum/job/scientist/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/scientist(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat/science(H), SLOT_WEAR_SUIT)

	switch(H.backbag)
		if(2)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/backpack_tox(H), SLOT_BACK)
		if(3)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/alt/tox(H), SLOT_BACK)
		if(4)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/tox(H), SLOT_BACK)
		if(5)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sci(H), SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/device/pda/science(H), SLOT_BELT)

	return TRUE

/datum/job/xenoarchaeologist
	title = "Xenoarchaeologist"
	flag = XENOARCHAEOLOGIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the research director"
	selection_color = "#ffeeff"
	idtype = /obj/item/weapon/card/id/sci
	access = list(access_research, access_xenoarch)
	minimal_player_ingame_minutes = 1400

/datum/job/xenoarchaeologist/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/scientist(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat/science(H), SLOT_WEAR_SUIT)

	switch(H.backbag)
		if(2)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/backpack_tox(H), SLOT_BACK)
		if(3)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/alt/tox(H), SLOT_BACK)
		if(4)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/tox(H), SLOT_BACK)
		if(5)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sci(H), SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/device/pda/science(H), SLOT_BELT)

	return TRUE

/datum/job/xenobiologist
	title = "Xenobiologist"
	flag = XENOBIOLOGIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the research director"
	selection_color = "#ffeeff"
	idtype = /obj/item/weapon/card/id/sci
	access = list(access_research, access_xenobiology)
	minimal_player_ingame_minutes = 1560

/datum/job/xenobiologist/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H) return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/scientist(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat/science(H), SLOT_WEAR_SUIT)

	switch(H.backbag)
		if(2)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/backpack_tox(H), SLOT_BACK)
		if(3)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/alt/tox(H), SLOT_BACK)
		if(4)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/tox(H), SLOT_BACK)
		if(5)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sci(H), SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/device/pda/science(H), SLOT_BELT)

	return TRUE


/datum/job/roboticist
	title = "Roboticist"
	flag = ROBOTICIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "research director"
	selection_color = "#ffeeff"
	idtype = /obj/item/weapon/card/id/sci
	access = list(access_robotics, access_morgue, access_research) //As a job that handles so many corpses, it makes sense for them to have morgue access.
	alt_titles = list("Biomechanical Engineer","Mechatronic Engineer")
	minimal_player_ingame_minutes = 1560

/datum/job/roboticist/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	if(H.backbag == 2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/backpack_tox(H), SLOT_BACK)
	if(H.backbag == 3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/alt/tox(H), SLOT_BACK)
	if(H.backbag == 4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/tox(H), SLOT_BACK)
	if(H.backbag == 5) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)
	if(H.gender == FEMALE)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/roboticist_fem(H), SLOT_W_UNIFORM)
	else
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/roboticist(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(H), SLOT_WEAR_SUIT)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sci(H), SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/device/pda/roboticist(H), SLOT_BELT)

	return TRUE


/datum/job/research_assistant
	title = "Research Assistant"
	flag = RESEARCHASSISTANT
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "research director"
	selection_color = "#ffeeff"
	idtype = /obj/item/weapon/card/id/sci
	access = list(access_research)

/datum/job/research_assistant/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)
		return 0
	switch(H.backbag)
		if(2)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/backpack_tox(H), SLOT_BACK)
		if(3)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/alt/tox(H), SLOT_BACK)
		if(4)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/tox(H), SLOT_BACK)
		if(5)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/scientist_new(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), SLOT_SHOES)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sci(H), SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/device/pda, SLOT_BELT)


	return TRUE