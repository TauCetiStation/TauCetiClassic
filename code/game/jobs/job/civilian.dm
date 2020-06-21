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
	salary = 160
	minimal_player_ingame_minutes = 960
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND ALSO LOCATING THE "job_loop:" THINGY AND CHANGING
		THE VERSION THERE. CURRENTLY THE VERSION THERE IS 26.
		~Luduk
	*/
	restricted_species = list(UNATHI, TAJARAN, VOX, DIONA)

/datum/job/qm/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equipOutfit(/datum/outfit/job/qm, visualsOnly)
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
	salary = 50
	minimal_player_ingame_minutes = 480

/datum/job/cargo_tech/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equipOutfit(/datum/outfit/job/cargo_tech, visualsOnly)
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
	salary = 80
	minimal_player_ingame_minutes = 480

/datum/job/mining/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equipOutfit(/datum/outfit/job/mining, visualsOnly)
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
	salary = 60
	minimal_player_ingame_minutes = 480
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND ALSO LOCATING THE "job_loop:" THINGY AND CHANGING
		THE VERSION THERE. CURRENTLY THE VERSION THERE IS 26.
		~Luduk
	*/
	restricted_species = list(DIONA)

/datum/job/recycler/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equipOutfit(/datum/outfit/job/recycler, visualsOnly)
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
	salary = 40
	minimal_player_ingame_minutes = 240
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND ALSO LOCATING THE "job_loop:" THINGY AND CHANGING
		THE VERSION THERE. CURRENTLY THE VERSION THERE IS 26.
		~Luduk
	*/
	restricted_species = list(TAJARAN)

	survival_kit_items = list(/obj/item/ammo_casing/shotgun/beanbag,
	                          /obj/item/ammo_casing/shotgun/beanbag,
	                          /obj/item/ammo_casing/shotgun/beanbag,
	                          /obj/item/ammo_casing/shotgun/beanbag
	                          )

/datum/job/bartender/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equipOutfit(/datum/outfit/job/bartender, visualsOnly)
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
	salary = 40
	alt_titles = list("Cook")
	minimal_player_ingame_minutes = 240
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND ALSO LOCATING THE "job_loop:" THINGY AND CHANGING
		THE VERSION THERE. CURRENTLY THE VERSION THERE IS 26.
		~Luduk
	*/
	restricted_species = list(TAJARAN)

/datum/job/chef/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equipOutfit(/datum/outfit/job/chef, visualsOnly)
	if(visualsOnly)
		return
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
	salary = 60
	alt_titles = list("Hydroponicist")
	minimal_player_ingame_minutes = 120

/datum/job/hydro/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equipOutfit(/datum/outfit/job/hydro, visualsOnly)
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
	salary = 50
	minimal_player_ingame_minutes = 120

/datum/job/janitor/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equipOutfit(/datum/outfit/job/janitor, visualsOnly)
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
	salary = 40
	alt_titles = list("Stylist")
	minimal_player_ingame_minutes = 120

/datum/job/barber/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)
		return FALSE
	H.equipOutfit(/datum/outfit/job/barber, visualsOnly)
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
	salary = 40
	alt_titles = list("Journalist")
	minimal_player_ingame_minutes = 120

/datum/job/librarian/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equipOutfit(/datum/outfit/job/librarian, visualsOnly)
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
	access = list(access_lawyer, access_sec_doors, access_medical, access_research, access_mailsorting, access_engine, access_engineering_lobby)
	salary = 200
	minimal_player_ingame_minutes = 1560
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND ALSO LOCATING THE "job_loop:" THINGY AND CHANGING
		THE VERSION THERE. CURRENTLY THE VERSION THERE IS 26.
		~Luduk
	*/
	restricted_species = list(SKRELL, UNATHI, TAJARAN, DIONA, VOX)

/datum/job/lawyer/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equipOutfit(/datum/outfit/job/lawyer, visualsOnly)
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
	salary = 20
	minimal_player_ingame_minutes = 120

/datum/job/clown/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equipOutfit(/datum/outfit/job/clown, visualsOnly)

	if(visualsOnly)
		return

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
	salary = 20

/datum/job/mime/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H)	return 0
	H.equipOutfit(/datum/outfit/job/mime, visualsOnly)

	if(visualsOnly)
		return

	H.verbs += /client/proc/mimespeak
	H.verbs += /client/proc/mimewall
	H.mind.special_verbs += /client/proc/mimespeak
	H.mind.special_verbs += /client/proc/mimewall
	H.miming = 1
	return TRUE
