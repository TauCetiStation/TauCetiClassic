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
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/cargo_fem(H), SLOT_W_UNIFORM)
	else
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/cargo(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(H), SLOT_GLASSES)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_cargo(H), SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/device/pda/quartermaster(H), SLOT_BELT)

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
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/cargotech(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_cargo(H), SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/device/pda/cargo(H), SLOT_BELT)

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
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/industrial(H), SLOT_BACK)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/eng(H), SLOT_BACK)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/miner(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_cargo (H), SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/device/pda/shaftminer(H), SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/weapon/mining_voucher(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/survivalcapsule(H), SLOT_IN_BACKPACK)

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
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/recycler(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/recyclervest/(H), SLOT_WEAR_SUIT)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_cargo(H), SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/device/pda/cargo(H), SLOT_BELT)

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
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(H), SLOT_BACK)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/norm(H), SLOT_BACK)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
	if(H.gender == FEMALE)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/bartender_fem(H), SLOT_W_UNIFORM)
	else
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/bartender(H), SLOT_W_UNIFORM)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/pda/bar(H), SLOT_BELT)
	if(H.backbag == 1)
		var/obj/item/weapon/storage/box/Barpack = new /obj/item/weapon/storage/box(H)
		H.equip_to_slot_or_del(Barpack, SLOT_R_HAND)
		new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
		new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
		new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
		new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
	else
		H.equip_to_slot_or_del(new /obj/item/ammo_casing/shotgun/beanbag(H), SLOT_IN_BACKPACK)
		H.equip_to_slot_or_del(new /obj/item/ammo_casing/shotgun/beanbag(H), SLOT_IN_BACKPACK)
		H.equip_to_slot_or_del(new /obj/item/ammo_casing/shotgun/beanbag(H), SLOT_IN_BACKPACK)
		H.equip_to_slot_or_del(new /obj/item/ammo_casing/shotgun/beanbag(H), SLOT_IN_BACKPACK)

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
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chef(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/pda/chef(H), SLOT_BELT)

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
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
	switch(H.backbag)
		if(1) H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H), SLOT_R_HAND)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/backpack_hyd(H), SLOT_BACK)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/hyd(H), SLOT_BACK)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)
	if(H.gender == FEMALE)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/hydroponics_fem(H), SLOT_W_UNIFORM)
	else
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/hydroponics(H), SLOT_W_UNIFORM)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/pda/botanist(H), SLOT_BELT)

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
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/janitor(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/pda/janitor(H), SLOT_BELT)
	if(H.backbag == 1)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H), SLOT_R_HAND)
	else
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H.back), SLOT_IN_BACKPACK)

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

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(H), SLOT_SHOES)

	if(visualsOnly)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/barber(H), SLOT_W_UNIFORM)
		return

	if(H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Barber")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/barber(H), SLOT_W_UNIFORM)
			if("Stylist")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/lawyer/purpsuit(H), SLOT_W_UNIFORM)

	H.equip_to_slot_or_del(new /obj/item/device/pda/barber(H), SLOT_BELT)

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
	H.equip_to_slot_or_del(new /obj/item/clothing/under/suit_jacket/red(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/weapon/barcodescanner(H), SLOT_L_HAND)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/weapon/storage/bag/bookbag(H), SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/device/pda/librarian(H), SLOT_R_STORE)

	return TRUE


//var/global/lawyer = 0//Checks for another lawyer //This changed clothes on 2nd lawyer, both IA get the same dreds.
/datum/job/lawyer
	title = "Internal Affairs Agent"
	flag = LAWYER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "The Central Command"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/int
	access = list(access_lawyer, access_court, access_sec_doors, access_medical, access_research, access_mailsorting, access_engine, access_engine_equip)
	minimal_player_ingame_minutes = 1560
	restricted_species = list(UNATHI, TAJARAN, DIONA)

/datum/job/lawyer/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	switch(H.backbag)
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(H), SLOT_BACK)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/norm(H), SLOT_BACK)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/internalaffairs(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/internalaffairs(H), SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/big(H), SLOT_GLASSES)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/briefcase/centcomm(H), SLOT_L_HAND)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/flash(H), SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_int(H), SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/device/pda/lawyer(H), SLOT_BELT)

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
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/clown(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(H), SLOT_WEAR_MASK)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/pda/clown(H), SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/bikehorn(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/stamp/clown(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/toy/crayon/rainbow(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/fancy/crayons(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/toy/waterflower(H), SLOT_IN_BACKPACK)
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
		if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/mime(H), SLOT_BACK)
		if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/norm(H), SLOT_BACK)
		if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/mime(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/white(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/mime(H), SLOT_WEAR_MASK)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/beret(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/suspenders(H), SLOT_WEAR_SUIT)

	if(visualsOnly)
		return

	H.equip_to_slot_or_del(new /obj/item/device/pda/mime(H), SLOT_BELT)
	if(H.backbag == 1)
		H.equip_to_slot_or_del(new /obj/item/toy/crayon/mime(H), SLOT_L_STORE)
		H.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing(H), SLOT_L_HAND)
	else
		H.equip_to_slot_or_del(new /obj/item/toy/crayon/mime(H), SLOT_IN_BACKPACK)
		H.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing(H), SLOT_IN_BACKPACK)
	H.verbs += /client/proc/mimespeak
	H.verbs += /client/proc/mimewall
	H.mind.special_verbs += /client/proc/mimespeak
	H.mind.special_verbs += /client/proc/mimewall
	H.miming = 1
	return TRUE
