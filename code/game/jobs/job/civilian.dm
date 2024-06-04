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
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargoshop, access_qm, access_mint, access_mining, access_mining_station, access_recycler)
	salary = 0
	starting_money = 60
	minimal_player_ingame_minutes = 960
	outfit = /datum/outfit/job/qm
	skillsets = list("Quartermaster" = /datum/skillset/quartermaster)
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND SAVEFILE_VERSION_SPECIES_JOBS
		~Luduk
	*/
	restricted_species = list(TAJARAN, VOX, DIONA)

	department_stocks = list("Cargo" = 40)
	flags = JOB_FLAG_CARGO

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
	access = list(access_maint_tunnels, access_cargo, access_cargoshop, access_mailsorting)
	salary = 0
	starting_money = 25
	minimal_player_ingame_minutes = 480
	outfit = /datum/outfit/job/cargo_tech
	skillsets = list("Cargo Technician" = /datum/skillset/cargotech)

	department_stocks = list("Cargo" = 20)
	flags = JOB_FLAG_CARGO

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
	salary = 0
	starting_money = 30
	minimal_player_ingame_minutes = 480
	outfit = /datum/outfit/job/mining
	skillsets = list("Shaft Miner" = /datum/skillset/miner)

	department_stocks = list("Cargo" = 10)
	flags = JOB_FLAG_CARGO

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
	access = list(access_mailsorting, access_recycler)
	salary = 0
	starting_money = 20
	minimal_player_ingame_minutes = 480
	outfit = /datum/outfit/job/recycler
	skillsets = list("Recycler" = /datum/skillset/recycler)
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND SAVEFILE_VERSION_SPECIES_JOBS
		~Luduk
	*/

	department_stocks = list("Cargo" = 10)
	flags = JOB_FLAG_CARGO

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
	outfit = /datum/outfit/job/bartender
	skillsets = list("Bartender" = /datum/skillset/bartender)
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND SAVEFILE_VERSION_SPECIES_JOBS
		~Luduk
	*/
	flags = JOB_FLAG_CIVIL

/datum/job/chef
	title = "Chef"
	flag = CHEF
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#bbe291"
	idtype = /obj/item/weapon/card/id/civ
	access = list(access_kitchen)
	salary = 40
	alt_titles = list("Cook")
	minimal_player_ingame_minutes = 240
	outfit = /datum/outfit/job/chef
	skillsets = list("Chef" = /datum/skillset/chef)
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND SAVEFILE_VERSION_SPECIES_JOBS
		~Luduk
	*/
	flags = JOB_FLAG_CIVIL

/datum/job/chef/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!visualsOnly)
		var/obj/item/weapon/implant/bork/B = new(H)
		B.inject(H, BP_HEAD)
	return ..()

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
	outfit = /datum/outfit/job/hydro
	skillsets = list("Botanist" = /datum/skillset/botanist)
	flags = JOB_FLAG_CIVIL

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
	access = list(access_janitor, access_maint_tunnels, access_sec_doors, access_research, access_mailsorting, access_medical, access_engineering_lobby)
	salary = 50
	minimal_player_ingame_minutes = 120
	outfit = /datum/outfit/job/janitor
	skillsets = list("Janitor" = /datum/skillset/janitor)
	flags = JOB_FLAG_CIVIL

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
	alt_titles = list("Stylist" = /datum/outfit/job/stylist)
	minimal_player_ingame_minutes = 120
	outfit = /datum/outfit/job/barber
	skillsets = list("Barber" = /datum/skillset/barber)
	flags = JOB_FLAG_CIVIL

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
	outfit = /datum/outfit/job/librarian
	skillsets = list("Librarian" = /datum/skillset/librarian)
	flags = JOB_FLAG_CIVIL

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
	outfit = /datum/outfit/job/clown
	skillsets = list("Clown" = /datum/skillset/clown)
	restricted_species = list(SKRELL)
	flags = JOB_FLAG_CIVIL

/datum/job/clown/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!visualsOnly)
		ADD_TRAIT(H, TRAIT_CLUMSY, GENETIC_MUTATION_TRAIT)
	H.real_name = pick(clown_names)
	H.rename_self("clown")

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
	outfit = /datum/outfit/job/mime
	skillsets = list("Mime" = /datum/skillset/mime)
	flags = JOB_FLAG_CIVIL

/datum/job/mime/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!visualsOnly)
		H.AddSpell(new /obj/effect/proc_holder/spell/targeted/forcewall/mimewall)
		H.AddSpell(new /obj/effect/proc_holder/spell/no_target/mime_speak)
		ADD_TRAIT(H, TRAIT_MIMING, GENERIC_TRAIT)
	H.real_name = pick(mime_names)
	H.rename_self("mime")
