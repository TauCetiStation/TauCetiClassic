//Cargo
/datum/job/qm
	title = "Quartermaster"
	flag = QUARTERMASTER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#d7b088"
	idtype = /obj/item/weapon/card/id/cargoGold
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station, access_recycler)
	minimal_player_ingame_minutes = 1200
	restricted_species = list(TAJARAN, DIONA)

/datum/job/qm/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	if(H.gender == FEMALE)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/cargo_fem(H), slot_w_uniform)
	else
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/cargo(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(H), slot_glasses)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_cargo(H), slot_l_ear)
	H.equip_to_slot_or_del(new /obj/item/device/pda/quartermaster(H), slot_belt)

	return TRUE


/datum/job/cargo_tech
	title = "Cargo Technician"
	flag = CARGOTECH
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#d7b088"
	idtype = /obj/item/weapon/card/id/cargo
	access = list(access_maint_tunnels, access_cargo, access_cargo_bot, access_mailsorting)
	minimal_player_ingame_minutes = 960
	restricted_species = list(SKRELL, DIONA)


/datum/job/cargo_tech/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/cargotech(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_cargo(H), slot_l_ear)
	H.equip_to_slot_or_del(new /obj/item/device/pda/cargo(H), slot_belt)

	return TRUE


/datum/job/mining
	title = "Shaft Miner"
	flag = MINER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#d7b088"
	idtype = /obj/item/weapon/card/id/cargo
	access = list(access_mining, access_mint, access_mining_station, access_mailsorting)
	minimal_player_ingame_minutes = 960
	restricted_species = list(SKRELL)

/datum/job/mining/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	switch(H.backbag)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/industrial(H), slot_back)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/eng(H), slot_back)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/miner(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_cargo (H), slot_l_ear)
	H.equip_to_slot_or_del(new /obj/item/device/pda/shaftminer(H), slot_belt)
	H.equip_to_slot_or_del(new /obj/item/weapon/mining_voucher(H), slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/weapon/survivalcapsule(H), slot_in_backpack)

	return TRUE


/datum/job/recycler
	title = "Recycler"
	flag = RECYCLER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#d7b088"
	idtype = /obj/item/weapon/card/id/cargo
	access = list(access_mining, access_mint, access_mailsorting, access_recycler)
	minimal_player_ingame_minutes = 960
	restricted_species = list(SKRELL)

/datum/job/recycler/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/recycler(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/recyclervest/(H), slot_wear_suit)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_cargo(H), slot_l_ear)
	H.equip_to_slot_or_del(new /obj/item/device/pda/cargo(H), slot_belt)

	return TRUE

//Food
/datum/job/bartender
	title = "Bartender"
	flag = BARTENDER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#bbe291"
	idtype = /obj/item/weapon/card/id/civ
	access = list(access_bar)
	minimal_player_ingame_minutes = 480
	restricted_species = list(TAJARAN)

/datum/job/bartender/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	switch(H.backbag)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/norm(H), slot_back)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
	if(H.gender == FEMALE)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/bartender_fem(H), slot_w_uniform)
	else
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/bartender(H), slot_w_uniform)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/pda/bar(H), slot_belt)
	if(H.backbag == 1)
		var/obj/item/weapon/storage/box/Barpack = new /obj/item/weapon/storage/box(H)
		H.equip_to_slot_or_del(Barpack, slot_r_hand)
		new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
		new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
		new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
		new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
	else
		H.equip_to_slot_or_del(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)
		H.equip_to_slot_or_del(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)
		H.equip_to_slot_or_del(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)
		H.equip_to_slot_or_del(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)

	return TRUE


/datum/job/chef
	title = "Chef"
	flag = CHEF
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#bbe291"
	idtype = /obj/item/weapon/card/id/civ
	access = list(access_kitchen)
	alt_titles = list("Cook")
	minimal_player_ingame_minutes = 480
	restricted_species = list(TAJARAN, SKRELL)

/datum/job/chef/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chef(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/pda/chef(H), slot_belt)

	return TRUE


/datum/job/hydro
	title = "Botanist"
	flag = BOTANIST
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#bbe291"
	idtype = /obj/item/weapon/card/id/civ
	access = list(access_hydroponics) // Removed tox and chem access because STOP PISSING OFF THE CHEMIST GUYS // //Removed medical access because WHAT THE FUCK YOU AREN'T A DOCTOR YOU GROW WHEAT //Given Morgue access because they have a viable means of cloning.
	alt_titles = list("Hydroponicist")
	minimal_player_ingame_minutes = 480
	restricted_species = list(SKRELL)

/datum/job/hydro/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
	switch(H.backbag)
		if(1) H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/backpack_hyd(H), slot_back)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/hyd(H), slot_back)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	if(H.gender == FEMALE)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/hydroponics_fem(H), slot_w_uniform)
	else
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/hydroponics(H), slot_w_uniform)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/pda/botanist(H), slot_belt)

	return TRUE


/datum/job/janitor
	title = "Janitor"
	flag = JANITOR
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#bbe291"
	idtype = /obj/item/weapon/card/id/civ
	access = list(access_janitor, access_maint_tunnels)
	minimal_player_ingame_minutes = 480
	restricted_species = list(SKRELL)

/datum/job/janitor/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/janitor(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/pda/janitor(H), slot_belt)
	if(H.backbag == 1)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
	else
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)

	return TRUE


//More or less assistants
/datum/job/barber
	title = "Barber"
	flag = BARBER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#bbe291"
	idtype = /obj/item/weapon/card/id/civ
	access = list(access_barber)
	alt_titles = list("Stylist")
	minimal_player_ingame_minutes = 480

/datum/job/barber/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)
		return FALSE

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(H), slot_shoes)

	if(visualsOnly)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/barber(H), slot_w_uniform)
		return

	if(H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Barber")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/barber(H), slot_w_uniform)
			if("Stylist")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/lawyer/purpsuit(H), slot_w_uniform)

	H.equip_to_slot_or_del(new /obj/item/device/pda/barber(H), slot_belt)

	return TRUE

/datum/job/librarian
	title = "Librarian"
	flag = LIBRARIAN
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/civ
	access = list(access_library)
	alt_titles = list("Journalist")
	minimal_player_ingame_minutes = 480

/datum/job/librarian/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equip_to_slot_or_del(new /obj/item/clothing/under/suit_jacket/red(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/device/pda/librarian(H), slot_belt)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/weapon/barcodescanner(H), slot_l_hand)

	if(visualsOnly)
		return

	return TRUE


//var/global/lawyer = 0//Checks for another lawyer //This changed clothes on 2nd lawyer, both IA get the same dreds.
/datum/job/lawyer
	title = "Internal Affairs Agent"
	flag = LAWYER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the captain"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/civ
	access = list(access_lawyer, access_court, access_sec_doors)
	minimal_player_ingame_minutes = 1560
	restricted_species = list(UNATHI, TAJARAN, DIONA)

/datum/job/lawyer/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	switch(H.backbag)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/norm(H), slot_back)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/internalaffairs(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/internalaffairs(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/big(H), slot_glasses)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/briefcase/centcomm(H), slot_l_hand)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sec(H), slot_l_ear)
	H.equip_to_slot_or_del(new /obj/item/device/pda/lawyer(H), slot_belt)

	var/obj/item/weapon/implant/mindshield/loyalty/L = new(H)
	L.inject(H)
	START_PROCESSING(SSobj, L)
	return TRUE


/datum/job/clown
	title = "Clown"
	flag = CLOWN
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/clown
	access = list(access_clown, access_theatre)
	minimal_player_ingame_minutes = 480
	restricted_species = list(SKRELL)

/datum/job/clown/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/clown(H), slot_back)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(H), slot_wear_mask)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/pda/clown(H), slot_belt)
	H.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(H), slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/weapon/bikehorn(H), slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/weapon/stamp/clown(H), slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/toy/crayon/rainbow(H), slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/fancy/crayons(H), slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/toy/waterflower(H), slot_in_backpack)
	H.mutations.Add(CLUMSY)
	return TRUE


/datum/job/mime
	title = "Mime"
	flag = MIME
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/mime
	access = list(access_mime, access_theatre)
	restricted_species = list(SKRELL)

/datum/job/mime/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	switch(H.backbag)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/mime(H), slot_back)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/norm(H), slot_back)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/mime(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/white(H), slot_gloves)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/mime(H), slot_wear_mask)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/beret(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/suspenders(H), slot_wear_suit)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/pda/mime(H), slot_belt)
	if(H.backbag == 1)
		H.equip_to_slot_or_del(new /obj/item/toy/crayon/mime(H), slot_l_store)
		H.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing(H), slot_l_hand)
	else
		H.equip_to_slot_or_del(new /obj/item/toy/crayon/mime(H), slot_in_backpack)
		H.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing(H), slot_in_backpack)
	H.verbs += /client/proc/mimespeak
	H.verbs += /client/proc/mimewall
	H.mind.special_verbs += /client/proc/mimespeak
	H.mind.special_verbs += /client/proc/mimewall
	H.miming = 1
	return TRUE
