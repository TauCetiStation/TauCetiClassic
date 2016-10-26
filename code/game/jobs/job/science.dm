/datum/job/rd
	title = "Research Director"
	flag = RD
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffddff"
	idtype = /obj/item/weapon/card/id/silver
	req_admin_notify = 1
	access = list(access_rd, access_heads, access_tox, access_genetics, access_morgue,
			            access_tox_storage, access_teleporter, access_sec_doors, access_minisat,
			            access_research, access_robotics, access_xenobiology, access_ai_upload,
			            access_RC_announce, access_keycard_auth, access_tcomsat, access_gateway, access_xenoarch)
	minimal_access = list(access_rd, access_heads, access_tox, access_genetics, access_morgue,
			            access_tox_storage, access_teleporter, access_sec_doors, access_minisat,
			            access_research, access_robotics, access_xenobiology, access_ai_upload,
			            access_RC_announce, access_keycard_auth, access_tcomsat, access_gateway, access_xenoarch)
	minimal_player_age = 7
	minimal_player_ingame_minutes = 2400

/datum/job/rd/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/research_director(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(H), slot_wear_suit)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/rd(H), slot_l_ear)
	H.equip_to_slot_or_del(new /obj/item/device/pda/heads/rd(H), slot_belt)
	switch(H.backbag)
		if(1) H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/backpack_tox(H), slot_back)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_tox(H), slot_back)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)

	return 1


/datum/job/scientist
	title = "Scientist"
	flag = SCIENTIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 5
	spawn_positions = 3
	supervisors = "the research director"
	selection_color = "#ffeeff"
	access = list(access_robotics, access_tox, access_tox_storage, access_research, access_xenobiology, access_xenoarch)
	minimal_access = list(access_tox, access_tox_storage, access_research, access_xenoarch)
	alt_titles = list("Xenoarcheologist", "Anomalist", "Phoron Researcher")
	minimal_player_ingame_minutes = 1560

/datum/job/scientist/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/scientist(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat/science(H), slot_wear_suit)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sci(H), slot_l_ear)
	H.equip_to_slot_or_del(new /obj/item/device/pda/science(H), slot_belt)
	switch(H.mind.role_alt_title)
		if("Scientist")
			minimal_access = list(access_tox, access_research)
		if("Xenoarcheologist")
			minimal_access = list(access_xenoarch, access_research)
		if("Anomalist")
			minimal_access = list(access_xenoarch, access_research)
		if("Phoron Researcher")
			minimal_access = list(access_research, access_tox_storage)

	switch(H.backbag)
		if(1) H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/backpack_tox(H), slot_back)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_tox(H), slot_back)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)

	return 1


/datum/job/xenobiologist
	title = "Xenobiologist"
	flag = XENOBIOLOGIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the research director"
	selection_color = "#ffeeff"
	access = list(access_robotics, access_tox, access_tox_storage, access_research, access_xenobiology)
	minimal_access = list(access_research, access_xenobiology)
	minimal_player_ingame_minutes = 1560

/datum/job/xenobiologist/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H) return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/scientist(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat/science(H), slot_wear_suit)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sci(H), slot_l_ear)
	H.equip_to_slot_or_del(new /obj/item/device/pda/science(H), slot_belt)
	switch(H.backbag)
		if(1) H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/backpack_tox(H), slot_back)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_tox(H), slot_back)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)

	return 1


/datum/job/roboticist
	title = "Roboticist"
	flag = ROBOTICIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "research director"
	selection_color = "#ffeeff"
	access = list(access_robotics, access_tox, access_tox_storage, access_tech_storage, access_morgue, access_research) //As a job that handles so many corpses, it makes sense for them to have morgue access.
	minimal_access = list(access_robotics, access_tech_storage, access_morgue, access_research) //As a job that handles so many corpses, it makes sense for them to have morgue access.
	alt_titles = list("Biomechanical Engineer","Mechatronic Engineer")
	minimal_player_ingame_minutes = 1560

/datum/job/roboticist/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	if(H.backbag == 2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(H), slot_back)
	if(H.backbag == 3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
	if(H.gender == FEMALE)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/roboticist_fem(H), slot_w_uniform)
	else
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/roboticist(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(H), slot_wear_suit)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sci(H), slot_l_ear)
	H.equip_to_slot_or_del(new /obj/item/device/pda/roboticist(H), slot_belt)
	if(H.backbag == 1)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
	else
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)

	return 1
